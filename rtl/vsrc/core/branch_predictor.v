`timescale 1ns / 1ns

module branch_predictor (
    input clk,
    input rst,
    input invalidate,  // FENCE.I invalidates targets for possibly changed code.

    // Query from IF stage
    input  [31:0] if_bp_pc,
    output        if_bp_predict_taken,
    output [31:0] if_bp_predict_pc,
    output [ 9:0] if_bp_predict_pht_index,

    // Update from EX stage
    input        ex_bp_update_wen,
    input        ex_bp_update_is_jal,
    input [31:0] ex_bp_update_pc,
    input        ex_bp_update_taken,
    input [31:0] ex_bp_update_target,
    input [ 9:0] ex_bp_update_pht_index
);

  parameter ENTRY_NUM = 256;
  parameter GHR_WIDTH = 10;
  localparam WAY_NUM = 2;
  localparam SET_NUM = ENTRY_NUM / WAY_NUM;
  localparam SET_INDEX_WIDTH = $clog2(SET_NUM);
  localparam TAG_WIDTH = 32 - SET_INDEX_WIDTH - 2;
  localparam PHT_ENTRY_NUM = (1 << GHR_WIDTH);
  localparam [1:0] PHT_INIT_STATE = 2'b01;

  // gshare direction predictor:
  // PHT 2-bit saturating counters
  reg [1:0] pht_counter[0:PHT_ENTRY_NUM-1];
  reg [GHR_WIDTH-1:0] ghr;

  // BTB storage (2-way set-associative)
  reg btb_valid[0:WAY_NUM-1][0:SET_NUM-1];
  reg [TAG_WIDTH-1:0] btb_tag[0:WAY_NUM-1][0:SET_NUM-1];
  reg [31:0] btb_target[0:WAY_NUM-1][0:SET_NUM-1];
  reg btb_is_jal[0:WAY_NUM-1][0:SET_NUM-1];

  // Entry epoch qualifies tags across reset; valid bits also clear on FENCE.I.
  reg bp_entry_epoch[0:WAY_NUM-1][0:SET_NUM-1];
  reg lru_way[0:SET_NUM-1];  // 2-way LRU: record which way is least recently used
  reg bp_epoch;
  reg bp_rst_d;
  integer lru_i;
  integer pht_i;

  wire [SET_INDEX_WIDTH-1:0] if_bp_set = if_bp_pc[SET_INDEX_WIDTH+1:2];
  wire [SET_INDEX_WIDTH-1:0] ex_bp_set = ex_bp_update_pc[SET_INDEX_WIDTH+1:2];
  wire [TAG_WIDTH-1:0] if_bp_tag = if_bp_pc[31:SET_INDEX_WIDTH+2];
  wire [TAG_WIDTH-1:0] ex_bp_tag = ex_bp_update_pc[31:SET_INDEX_WIDTH+2];
  wire [GHR_WIDTH-1:0] if_bp_pc_index = if_bp_pc[GHR_WIDTH+1:2];
  wire [GHR_WIDTH-1:0] if_bp_pht_index = if_bp_pc_index ^ ghr;

  wire if_bp_way0_entry_valid = (bp_entry_epoch[0][if_bp_set] === bp_epoch);
  wire if_bp_way1_entry_valid = (bp_entry_epoch[1][if_bp_set] === bp_epoch);
  wire if_bp_way0_hit = if_bp_way0_entry_valid && (btb_valid[0][if_bp_set] == 1'b1) &&
                        (btb_tag[0][if_bp_set] == if_bp_tag);
  wire if_bp_way1_hit = if_bp_way1_entry_valid && (btb_valid[1][if_bp_set] == 1'b1) &&
                        (btb_tag[1][if_bp_set] == if_bp_tag);
  wire if_btb_hit = if_bp_way0_hit || if_bp_way1_hit;
  wire if_btb_is_jal = if_bp_way0_hit ? btb_is_jal[0][if_bp_set] :
                      if_bp_way1_hit ? btb_is_jal[1][if_bp_set] : 1'b0;

  wire ex_bp_way0_entry_valid = (bp_entry_epoch[0][ex_bp_set] === bp_epoch);
  wire ex_bp_way1_entry_valid = (bp_entry_epoch[1][ex_bp_set] === bp_epoch);
  wire ex_bp_way0_valid = ex_bp_way0_entry_valid && (btb_valid[0][ex_bp_set] == 1'b1);
  wire ex_bp_way1_valid = ex_bp_way1_entry_valid && (btb_valid[1][ex_bp_set] == 1'b1);
  wire ex_bp_way0_hit = ex_bp_way0_valid && (btb_tag[0][ex_bp_set] == ex_bp_tag);
  wire ex_bp_way1_hit = ex_bp_way1_valid && (btb_tag[1][ex_bp_set] == ex_bp_tag);

  wire [1:0] if_bp_counter = pht_counter[if_bp_pht_index];
  wire [1:0] ex_bp_counter = pht_counter[ex_bp_update_pht_index];

  reg ex_bp_update_way;
  always @(*) begin
    ex_bp_update_way = 1'b0;

    if (ex_bp_way0_hit) begin
      ex_bp_update_way = 1'b0;
    end else if (ex_bp_way1_hit) begin
      ex_bp_update_way = 1'b1;
    end else if (!ex_bp_way0_valid) begin
      ex_bp_update_way = 1'b0;
    end else if (!ex_bp_way1_valid) begin
      ex_bp_update_way = 1'b1;
    end else begin
      ex_bp_update_way = lru_way[ex_bp_set];
    end
  end

  // Per-entry valid flops avoid a runtime loop over a multidimensional array.
  genvar valid_way, valid_set;
  generate
    for (valid_way = 0; valid_way < WAY_NUM; valid_way = valid_way + 1) begin : valid_ways
      for (valid_set = 0; valid_set < SET_NUM; valid_set = valid_set + 1) begin : valid_sets
        localparam [SET_INDEX_WIDTH-1:0] ENTRY_INDEX = valid_set;
        localparam ENTRY_WAY = (valid_way == 1);
        always @(posedge clk) begin
          if (rst || invalidate)
            btb_valid[valid_way][valid_set] <= 1'b0;
          else if (ex_bp_update_wen && ex_bp_update_way == ENTRY_WAY && ex_bp_set == ENTRY_INDEX)
            btb_valid[valid_way][valid_set] <= 1'b1;
        end
      end
    end
  endgenerate

  reg [1:0] ex_bp_counter_next;
  always @(*) begin
    ex_bp_counter_next = ex_bp_counter;
    if (ex_bp_update_taken) begin
      if (ex_bp_counter != 2'b11) begin
        ex_bp_counter_next = ex_bp_counter + 2'b01;
      end
    end else begin
      if (ex_bp_counter != 2'b00) begin
        ex_bp_counter_next = ex_bp_counter - 2'b01;
      end
    end
  end

  // Ensure deterministic first reset behavior for epoch toggle.
  initial begin
    bp_epoch = 1'b0;
    bp_rst_d = 1'b0;
    ghr = {GHR_WIDTH{1'b0}};
    for (lru_i = 0; lru_i < SET_NUM; lru_i = lru_i + 1) begin
      lru_way[lru_i] = 1'b0;
    end
    for (pht_i = 0; pht_i < PHT_ENTRY_NUM; pht_i = pht_i + 1) begin
      pht_counter[pht_i] = PHT_INIT_STATE;
    end
  end

  always @(posedge clk) begin
    bp_rst_d <= rst;
    if (rst && !bp_rst_d) begin
      // Invalidate whole predictor table once per reset assertion.
      bp_epoch <= ~bp_epoch;
      ghr <= {GHR_WIDTH{1'b0}};
      for (lru_i = 0; lru_i < SET_NUM; lru_i = lru_i + 1) begin
        lru_way[lru_i] <= 1'b0;
      end
      for (pht_i = 0; pht_i < PHT_ENTRY_NUM; pht_i = pht_i + 1) begin
        pht_counter[pht_i] <= PHT_INIT_STATE;
      end
    end else if (!rst && !invalidate && ex_bp_update_wen) begin
      btb_tag[ex_bp_update_way][ex_bp_set] <= ex_bp_tag;
      btb_target[ex_bp_update_way][ex_bp_set] <= ex_bp_update_target;
      btb_is_jal[ex_bp_update_way][ex_bp_set] <= ex_bp_update_is_jal;
      bp_entry_epoch[ex_bp_update_way][ex_bp_set] <= bp_epoch;
      // Unconditional jumps train targets only, without changing gshare history.
      if (!ex_bp_update_is_jal) begin
        pht_counter[ex_bp_update_pht_index] <= ex_bp_counter_next;
        ghr <= {ghr[GHR_WIDTH-2:0], ex_bp_update_taken};
      end
      // Update LRU state: the other way becomes least recently used.
      lru_way[ex_bp_set] <= ~ex_bp_update_way;
    end
  end

  assign if_bp_predict_pht_index = if_bp_pht_index;
  // JAL is always taken; conditional branches still consult their PHT counter.
  assign if_bp_predict_taken = if_btb_hit && (if_btb_is_jal || if_bp_counter[1]);
  assign if_bp_predict_pc = if_bp_way0_hit ? btb_target[0][if_bp_set] :
                            if_bp_way1_hit ? btb_target[1][if_bp_set] :
                                             (if_bp_pc + 32'd4);

endmodule

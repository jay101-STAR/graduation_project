`timescale 1ns / 1ns

// Lane 0 is instruction-only; lane 1 reads or writes, one transaction per lane.
// Reads arbitrate round-robin. A data-side write has its own path and can overlap
// an instruction read. Each owner remains reserved through RLAST or B.
module mem_burst_arbiter (
    input         clk,
    input         rst,
    input  [ 1:0] s_req_valid,
    output [ 1:0] s_req_ready,
    input  [15:0] s_req_len,
    input  [63:0] s_req_addr,
    input  [ 1:0] s_req_write,
    input  [63:0] s_req_wdata,
    input  [ 7:0] s_req_wstrb,
    input         s_req_wlast,
    output [ 1:0] s_rsp_valid,
    input  [ 1:0] s_rsp_ready,
    output [63:0] s_rsp_rdata,
    output [ 1:0] s_rsp_error,
    output [ 1:0] s_rsp_last,
    output        rd_req_valid,
    input         rd_req_ready,
    output [31:0] rd_req_addr,
    output [ 7:0] rd_req_len,
    input         rd_rsp_valid,
    output        rd_rsp_ready,
    input  [31:0] rd_rsp_rdata,
    input         rd_rsp_error,
    input         rd_rsp_last,
    output        wr_req_valid,
    input         wr_req_ready,
    output [31:0] wr_req_addr,
    output [ 7:0] wr_req_len,
    output [31:0] wr_req_wdata,
    output [ 3:0] wr_req_wstrb,
    output        wr_req_wlast,
    input         wr_rsp_valid,
    output        wr_rsp_ready,
    input         wr_rsp_error
);
  reg rd_active, rd_owner, rd_offer_locked, rd_offer_owner, last_read_owner;
  reg wr_active, wr_sending;
  reg [7:0] wr_len;
  reg [8:0] wr_sent;
  wire rd_done = rd_rsp_valid && rd_rsp_ready && rd_rsp_last;
  wire wr_done = wr_rsp_valid && wr_rsp_ready;
  wire rd_available = !rd_active || rd_done;
  wire wr_available = !wr_active || wr_done;
  // A source retains one transaction until its response is consumed. In
  // particular, DCache cannot start a refill while its writeback is pending.
  wire [1:0] read_candidates = s_req_valid & ~s_req_write &
                               {(!wr_active || wr_done), 1'b1};
  wire rd_rr_grant = (&read_candidates) ? !last_read_owner : read_candidates[1];
  wire rd_grant = rd_offer_locked ? rd_offer_owner : rd_rr_grant;
  wire rd_fire = rd_req_valid && rd_req_ready;
  wire wr_fire = wr_req_valid && wr_req_ready;
  wire wr_last = wr_available ? s_req_len[15:8] == 0 : wr_sent == {1'b0, wr_len};
  wire data_read_busy = rd_active && rd_owner && !rd_done;

  assign rd_req_valid = !rst && rd_available && (|read_candidates);
  assign rd_req_addr = rd_grant ? s_req_addr[63:32] : s_req_addr[31:0];
  assign rd_req_len = rd_grant ? s_req_len[15:8] : s_req_len[7:0];
  assign wr_req_valid = !rst && !data_read_busy && (wr_available || wr_sending) &&
                        s_req_valid[1] && s_req_write[1];
  assign wr_req_addr = s_req_addr[63:32];
  assign wr_req_len = s_req_len[15:8];
  assign wr_req_wdata = s_req_wdata[63:32];
  assign wr_req_wstrb = s_req_wstrb[7:4];
  assign wr_req_wlast = wr_req_len == 0 || s_req_wlast;
  assign s_req_ready = (rd_fire ? (rd_grant ? 2'b10 : 2'b01) : 2'b00) |
                        (wr_fire ? 2'b10 : 2'b00);

  wire [1:0] read_valid = !rst && rd_active && rd_rsp_valid ?
                         (rd_owner ? 2'b10 : 2'b01) : 2'b00;
  wire write_valid = !rst && wr_active && !wr_sending && wr_rsp_valid;
  assign s_rsp_valid = read_valid | {write_valid, 1'b0};
  // Separate payloads are essential when R and B have different error status.
  assign s_rsp_rdata = {wr_active ? 32'b0 : rd_rsp_rdata, rd_rsp_rdata};
  assign s_rsp_error = {wr_active ? wr_rsp_error : rd_rsp_error, rd_rsp_error};
  assign s_rsp_last = {wr_active ? 1'b1 : rd_rsp_last, rd_rsp_last};
  assign rd_rsp_ready = !rst && rd_active && s_rsp_ready[rd_owner];
  assign wr_rsp_ready = !rst && wr_active && !wr_sending && s_rsp_ready[1];

  always @(posedge clk) begin
    if (rst) begin
      rd_active <= 0; rd_owner <= 0; rd_offer_locked <= 0;
      rd_offer_owner <= 0; last_read_owner <= 1;
      wr_active <= 0; wr_sending <= 0; wr_len <= 0; wr_sent <= 0;
    end else begin
      if (rd_done) rd_active <= 0;
      if (rd_req_valid && !rd_req_ready) begin
        rd_offer_locked <= 1;
        rd_offer_owner <= rd_grant;
      end
      if (rd_fire) begin
        rd_active <= 1;
        rd_owner <= rd_grant;
        last_read_owner <= rd_grant;
        rd_offer_locked <= 0;
      end
      if (wr_done) wr_active <= 0;
      if (wr_fire) begin
        wr_active <= 1;
        wr_sending <= !wr_last;
        if (wr_available) begin
          wr_len <= s_req_len[15:8];
          wr_sent <= 9'd1;
        end else wr_sent <= wr_sent + 9'd1;
      end
    end
  end
  // synthesis translate_off
  always @(posedge clk) if (!rst) begin
    if (s_req_valid[0] && s_req_write[0]) $fatal(1, "Instruction lane cannot write");
    if (rd_active && rd_owner && wr_active) $fatal(1, "Two data-side transactions outstanding");
    if (read_valid[1] && write_valid) $fatal(1, "Read and write responses collide on data lane");
  end
  // synthesis translate_on
endmodule

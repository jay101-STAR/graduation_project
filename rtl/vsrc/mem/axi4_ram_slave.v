`timescale 1ns / 1ns

// Native AXI4 endpoint: aligned 32-bit INCR single/16-beat transactions.
// Separate BRAM read/write ports sustain one beat per clock. One read and one
// write may be outstanding; a held response blocks the next same-direction AW/AR.
module axi4_ram_slave #(
    parameter BANK0_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank0.hex",
    parameter BANK1_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank1.hex"
) (
    input clk, input rst, output reg [31:0] tohost_value,
    input s_axi_awid,
    input [31:0] s_axi_awaddr,
    input [7:0] s_axi_awlen,
    input [2:0] s_axi_awsize,
    input [1:0] s_axi_awburst,
    input s_axi_awlock,
    input [3:0] s_axi_awcache,
    input [2:0] s_axi_awprot,
    input [3:0] s_axi_awqos,
    input [3:0] s_axi_awregion,
    input s_axi_awvalid,
    output s_axi_awready,
    input s_axi_arid,
    input [31:0] s_axi_araddr,
    input [7:0] s_axi_arlen,
    input [2:0] s_axi_arsize,
    input [1:0] s_axi_arburst,
    input s_axi_arlock,
    input [3:0] s_axi_arcache,
    input [2:0] s_axi_arprot,
    input [3:0] s_axi_arqos,
    input [3:0] s_axi_arregion,
    input s_axi_arvalid,
    output s_axi_arready,
    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input s_axi_wlast,
    input s_axi_wvalid,
    output s_axi_wready,
    output s_axi_bid,
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready,
    output s_axi_rid,
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rlast,
    output s_axi_rvalid,
    input s_axi_rready
);
  // Validate the full address before selecting a bank or narrowing to BRAM.
  // Even rejected requests retain their declared length for complete draining.
  function bad_request;
    input [31:0] addr;
    input [7:0] len;
    input [2:0] size;
    input [1:0] burst;
    input lock;
    begin
      bad_request = addr[31:16] != 16'h8000 || addr[1:0] != 0 ||
                    size != 3'd2 || burst != 2'b01 || lock ||
                    (len != 0 && len != 15) ||
                    ({1'b0, addr[11:0]} + (({5'b0, len} + 13'd1) << 2) > 13'd4096);
    end
  endfunction

  reg rd_active, rd_error, rd_id, rd_bank, rd_saved;
  reg [31:0] rd_addr, rd_data_saved;
  reg [7:0] rd_len, rd_beat;
  wire rd_last = rd_beat == rd_len;
  wire r_fire = s_axi_rvalid && s_axi_rready;
  wire ar_fire = s_axi_arvalid && s_axi_arready;
  wire [31:0] rd_next_addr = rd_addr + 32'd4;
  wire [31:0] ram_read_addr = ar_fire ? s_axi_araddr :
                             (r_fire && !rd_last) ? rd_next_addr : rd_addr;
  wire [31:0] bank0_rdata, bank1_rdata;
  wire [31:0] ram_read_data = rd_bank ? bank1_rdata : bank0_rdata;

  assign s_axi_arready = !rst && (!rd_active || (r_fire && rd_last));
  assign s_axi_rvalid = !rst && rd_active;
  assign s_axi_rdata = rd_error ? 32'b0 : rd_saved ? rd_data_saved : ram_read_data;
  assign s_axi_rresp = rd_error ? 2'b10 : 2'b00;
  assign s_axi_rid = rd_id;
  assign s_axi_rlast = rd_last;

  reg wr_active, wr_error, wr_id;
  reg [31:0] wr_addr;
  reg [7:0] wr_len, wr_beat;
  reg w_pending, w_last;
  reg [31:0] w_data;
  reg [3:0] w_strb;
  reg b_valid, b_id;
  reg [1:0] b_resp;
  wire aw_fire = s_axi_awvalid && s_axi_awready;
  wire w_fire = s_axi_wvalid && s_axi_wready;
  wire write_address_valid = wr_active || aw_fire;
  wire [31:0] write_addr = wr_active ? wr_addr : s_axi_awaddr;
  wire [7:0] write_len = wr_active ? wr_len : s_axi_awlen;
  wire [7:0] write_beat = wr_active ? wr_beat : 8'b0;
  wire write_last = write_beat == write_len;
  wire [31:0] write_data = w_pending ? w_data : s_axi_wdata;
  wire [3:0] write_strb = w_pending ? w_strb : s_axi_wstrb;
  wire write_wlast = w_pending ? w_last : s_axi_wlast;
  wire write_error = (wr_active ? wr_error :
                     bad_request(s_axi_awaddr, s_axi_awlen, s_axi_awsize, s_axi_awburst, s_axi_awlock)) ||
                     write_wlast != write_last;
  wire write_step = !rst && !b_valid && write_address_valid && (w_pending || w_fire);
  wire [3:0] ram_we = write_step && !write_error ? write_strb : 4'b0;

  assign s_axi_awready = !rst && !wr_active && !b_valid;
  // A one-beat buffer accepts W before AW. While draining it, replace it with
  // the next beat each cycle; never accept data for another transaction at LAST.
  assign s_axi_wready = !rst && !b_valid &&
                       (!w_pending || (write_address_valid && !write_last));
  assign s_axi_bvalid = !rst && b_valid;
  assign s_axi_bid = b_id;
  assign s_axi_bresp = b_resp;

  std_bram_tdp #(.HEX_FILE(BANK0_HEX)) bank0 (
      .clk(clk), .a_we(write_addr[2] ? 4'b0 : ram_we),
      .a_addr(write_addr[15:3]), .a_wdata(write_data), .a_rdata(),
      .b_we(4'b0), .b_addr(ram_read_addr[15:3]), .b_wdata(32'b0), .b_rdata(bank0_rdata)
  );
  std_bram_tdp #(.HEX_FILE(BANK1_HEX)) bank1 (
      .clk(clk), .a_we(write_addr[2] ? ram_we : 4'b0),
      .a_addr(write_addr[15:3]), .a_wdata(write_data), .a_rdata(),
      .b_we(4'b0), .b_addr(ram_read_addr[15:3]), .b_wdata(32'b0), .b_rdata(bank1_rdata)
  );

  always @(posedge clk) begin
    if (rst) begin
      rd_active <= 0; rd_error <= 0; rd_id <= 0; rd_bank <= 0; rd_saved <= 0;
      rd_addr <= 0; rd_data_saved <= 0; rd_len <= 0; rd_beat <= 0;
    end else begin
      // Snapshot a blocked response before subsequent writes can change BRAM's
      // output. The synchronous ports give read-before-write on a same-edge hit.
      if (rd_active && !rd_saved) begin
        rd_data_saved <= ram_read_data;
        rd_saved <= 1;
      end
      if (r_fire) begin
        rd_saved <= 0;
        if (rd_last) rd_active <= 0;
        else begin
          rd_addr <= rd_next_addr;
          rd_bank <= rd_next_addr[2];
          rd_beat <= rd_beat + 1'b1;
        end
      end
      // LAST consumption and the next AR may share an edge without a bubble.
      if (ar_fire) begin
        rd_active <= 1; rd_saved <= 0; rd_addr <= s_axi_araddr;
        rd_len <= s_axi_arlen; rd_beat <= 0; rd_id <= s_axi_arid;
        rd_bank <= s_axi_araddr[2];
        rd_error <= bad_request(s_axi_araddr, s_axi_arlen, s_axi_arsize, s_axi_arburst, s_axi_arlock);
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      wr_active <= 0; wr_error <= 0; wr_id <= 0; wr_addr <= 0; wr_len <= 0; wr_beat <= 0;
      w_pending <= 0; w_last <= 0; w_data <= 0; w_strb <= 0;
      b_valid <= 0; b_id <= 0; b_resp <= 0; tohost_value <= 0;
    end else begin
      if (s_axi_bvalid && s_axi_bready) b_valid <= 0;
      if (aw_fire) begin
        wr_active <= 1; wr_id <= s_axi_awid; wr_addr <= s_axi_awaddr;
        wr_len <= s_axi_awlen; wr_beat <= 0;
        wr_error <= bad_request(s_axi_awaddr, s_axi_awlen, s_axi_awsize, s_axi_awburst, s_axi_awlock);
      end
      if (w_fire) begin
        w_data <= s_axi_wdata; w_strb <= s_axi_wstrb; w_last <= s_axi_wlast;
        w_pending <= 1;
      end
      if (write_step) begin
        w_pending <= w_pending && w_fire;
        wr_error <= write_error;
        wr_addr <= write_addr + 32'd4;
        wr_beat <= write_beat + 1'b1;
        if (!write_error && write_addr == 32'h80001000) begin
          if (write_strb[0]) tohost_value[7:0] <= write_data[7:0];
          if (write_strb[1]) tohost_value[15:8] <= write_data[15:8];
          if (write_strb[2]) tohost_value[23:16] <= write_data[23:16];
          if (write_strb[3]) tohost_value[31:24] <= write_data[31:24];
        end
        // Drain AWLEN+1 beats even after an error; a burst is not atomic and
        // words committed before a malformed WLAST are not rolled back.
        if (write_last) begin
          wr_active <= 0;
          b_valid <= 1;
          b_id <= wr_active ? wr_id : s_axi_awid;
          b_resp <= write_error ? 2'b10 : 2'b00;
        end
      end
    end
  end
endmodule

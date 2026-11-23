`timescale 1ns / 1ns

// Read-burst splitter. RAM enables 1/16-beat reads; UART accepts single beats.
// Each Lite request is issued once. AW and W forwarding are independent.
module axi4_to_axi_lite #(
    parameter integer READ_BURSTS = 0
) (
    input clk, input rst,
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
    input s_axi_rready,
    output [31:0] m_lite_awaddr,
    output [2:0] m_lite_awprot,
    output m_lite_awvalid,
    input m_lite_awready,
    output [31:0] m_lite_wdata,
    output [3:0] m_lite_wstrb,
    output m_lite_wvalid,
    input m_lite_wready,
    input [1:0] m_lite_bresp,
    input m_lite_bvalid,
    output m_lite_bready,
    output [31:0] m_lite_araddr,
    output [2:0] m_lite_arprot,
    output m_lite_arvalid,
    input m_lite_arready,
    input [31:0] m_lite_rdata,
    input [1:0] m_lite_rresp,
    input m_lite_rvalid,
    output m_lite_rready
);
  reg rd_active, rd_pending, rd_error, rd_id;
  reg [31:0] rd_addr;
  reg [7:0] rd_len, rd_beat;
  reg [2:0] rd_prot;
  reg wr_active, wr_error, wr_id, aw_sent, w_sent, w_held, data_done;
  reg [31:0] wr_addr, wr_data;
  reg [3:0] wr_strb;
  reg [2:0] wr_prot;
  reg [7:0] wr_len, wr_beat;
  wire rd_last = rd_beat == rd_len;
  wire r_fire = s_axi_rvalid && s_axi_rready;
  wire rd_available = !rd_active || (r_fire && rd_last);
  wire w_fire = s_axi_wvalid && s_axi_wready;
  wire read_bad = s_axi_araddr[1:0] != 0 || s_axi_arsize != 2 || s_axi_arburst != 1 ||
                  s_axi_arlock || (s_axi_arlen != 0 && !(READ_BURSTS != 0 && s_axi_arlen == 15)) ||
                  ({1'b0,s_axi_araddr[11:0]} + (({5'b0,s_axi_arlen}+13'd1)<<2) > 13'd4096);
  wire write_bad = s_axi_awaddr[1:0] != 0 || s_axi_awlen != 0 ||
                   s_axi_awsize != 2 || s_axi_awburst != 1 || s_axi_awlock;
  // Empty channels fall through to Lite. A rejected/blocked payload is saved
  // at upstream acceptance, so VALID and data stay stable until Lite is ready.
  assign s_axi_arready = !rst && rd_available;
  assign s_axi_rvalid = !rst && rd_active && (rd_error || (rd_pending && m_lite_rvalid));
  assign s_axi_rdata = rd_error ? 32'b0 : m_lite_rdata;
  assign s_axi_rresp = rd_error ? 2'b10 : m_lite_rresp;
  assign s_axi_rid = rd_id;
  assign s_axi_rlast = rd_last;
  assign m_lite_arvalid = !rst && ((rd_available && s_axi_arvalid && !read_bad) ||
                         (!rd_available && !rd_error && (!rd_pending || (r_fire && !rd_last))));
  assign m_lite_araddr = rd_available ? s_axi_araddr : rd_addr + (({24'b0,rd_beat} + (rd_pending ? 32'd1 : 32'd0)) << 2);
  assign m_lite_arprot = rd_available ? s_axi_arprot : rd_prot;
  assign m_lite_rready = !rst && rd_active && !rd_error && rd_pending && s_axi_rready;
  assign s_axi_awready = !rst && !wr_active;
  assign s_axi_wready = !rst && wr_active && !data_done;
  assign s_axi_bvalid = !rst && wr_active && (wr_error ? data_done :
                       (aw_sent && w_sent && m_lite_bvalid));
  assign s_axi_bresp = wr_error ? 2'b10 : m_lite_bresp;
  assign s_axi_bid = wr_id;
  assign m_lite_awaddr = wr_active ? wr_addr : s_axi_awaddr;
  assign m_lite_awprot = wr_active ? wr_prot : s_axi_awprot;
  assign m_lite_awvalid = !rst && ((wr_active && !wr_error && !aw_sent) ||
                         (!wr_active && s_axi_awvalid && !write_bad));
  assign m_lite_wdata = w_held ? wr_data : s_axi_wdata;
  assign m_lite_wstrb = w_held ? wr_strb : s_axi_wstrb;
  assign m_lite_wvalid = !rst && wr_active && !wr_error && !w_sent &&
                        (w_held || (s_axi_wvalid && !data_done));
  assign m_lite_bready = !rst && wr_active && !wr_error && aw_sent && w_sent && s_axi_bready;
  always @(posedge clk) begin
    if (rst) begin
      rd_active <= 0; rd_pending <= 0; rd_error <= 0; rd_id <= 0;
      rd_addr <= 0; rd_len <= 0; rd_beat <= 0; rd_prot <= 0;
      wr_active <= 0; wr_error <= 0; wr_id <= 0; aw_sent <= 0; w_sent <= 0;
      w_held <= 0; data_done <= 0; wr_addr <= 0; wr_data <= 0; wr_strb <= 0;
      wr_prot <= 0; wr_len <= 0; wr_beat <= 0;
    end else begin
      if (r_fire) begin
        rd_pending <= 0;
        rd_beat <= rd_beat + 1'b1;
        if (rd_last) rd_active <= 0;
      end
      if (s_axi_arvalid && s_axi_arready) begin
        rd_active <= 1; rd_pending <= 0; rd_error <= read_bad; rd_id <= s_axi_arid;
        rd_addr <= s_axi_araddr; rd_len <= s_axi_arlen; rd_beat <= 0; rd_prot <= s_axi_arprot;
      end
      if (m_lite_arvalid && m_lite_arready) rd_pending <= 1;
      if (s_axi_awvalid && s_axi_awready) begin
        wr_active <= 1; wr_id <= s_axi_awid; wr_addr <= s_axi_awaddr; wr_prot <= s_axi_awprot;
        wr_len <= s_axi_awlen; wr_beat <= 0; aw_sent <= 0; w_sent <= 0; w_held <= 0; data_done <= 0;
        wr_error <= write_bad;
      end
      if (w_fire) begin
        wr_data <= s_axi_wdata; wr_strb <= s_axi_wstrb; w_held <= 1;
        wr_beat <= wr_beat + 1'b1;
        if (wr_beat == wr_len) data_done <= 1;
      end
      if (m_lite_awvalid && m_lite_awready) aw_sent <= 1;
      if (m_lite_wvalid && m_lite_wready) w_sent <= 1;
      if (s_axi_bvalid && s_axi_bready) wr_active <= 0;
    end
  end
  // synthesis translate_off
  always @(posedge clk) if (!rst && w_fire && s_axi_wlast != (wr_beat == wr_len))
    $fatal(1, "AXI4 write LAST/count mismatch");
  // synthesis translate_on
endmodule

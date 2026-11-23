// Test-only independent native/AXI channel queues; delay=0 is direct.
module axi4_master (
    input         clk,
    input         rst,
    input         rd_req_valid,
    output        rd_req_ready,
    input  [31:0] rd_req_addr,
    input  [ 7:0] rd_req_len,
    output        rd_rsp_valid,
    input         rd_rsp_ready,
    output [31:0] rd_rsp_rdata,
    output        rd_rsp_error,
    output        rd_rsp_last,
    input         wr_req_valid,
    output        wr_req_ready,
    input  [31:0] wr_req_addr,
    input  [ 7:0] wr_req_len,
    input  [31:0] wr_req_wdata,
    input  [ 3:0] wr_req_wstrb,
    input         wr_req_wlast,
    output        wr_rsp_valid,
    input         wr_rsp_ready,
    output        wr_rsp_error,
    output        m_axi_awid,
    output [31:0] m_axi_awaddr,
    output [ 7:0] m_axi_awlen,
    output [ 2:0] m_axi_awsize,
    output [ 1:0] m_axi_awburst,
    output        m_axi_awlock,
    output [ 3:0] m_axi_awcache,
    output [ 2:0] m_axi_awprot,
    output [ 3:0] m_axi_awqos,
    output [ 3:0] m_axi_awregion,
    output        m_axi_awvalid,
    input         m_axi_awready,
    output        m_axi_arid,
    output [31:0] m_axi_araddr,
    output [ 7:0] m_axi_arlen,
    output [ 2:0] m_axi_arsize,
    output [ 1:0] m_axi_arburst,
    output        m_axi_arlock,
    output [ 3:0] m_axi_arcache,
    output [ 2:0] m_axi_arprot,
    output [ 3:0] m_axi_arqos,
    output [ 3:0] m_axi_arregion,
    output        m_axi_arvalid,
    input         m_axi_arready,
    output [31:0] m_axi_wdata,
    output [ 3:0] m_axi_wstrb,
    output        m_axi_wlast,
    output        m_axi_wvalid,
    input         m_axi_wready,
    input         m_axi_bid,
    input  [ 1:0] m_axi_bresp,
    input         m_axi_bvalid,
    output        m_axi_bready,
    input         m_axi_rid,
    input  [31:0] m_axi_rdata,
    input  [ 1:0] m_axi_rresp,
    input         m_axi_rlast,
    input         m_axi_rvalid,
    output        m_axi_rready
);
  wire  inner_rd_req_valid;
  wire  inner_rd_req_ready;
  wire [31:0] inner_rd_req_addr;
  wire [ 7:0] inner_rd_req_len;
  wire  inner_rd_rsp_valid;
  wire  inner_rd_rsp_ready;
  wire [31:0] inner_rd_rsp_rdata;
  wire  inner_rd_rsp_error;
  wire  inner_rd_rsp_last;
  wire  inner_wr_req_valid;
  wire  inner_wr_req_ready;
  wire [31:0] inner_wr_req_addr;
  wire [ 7:0] inner_wr_req_len;
  wire [31:0] inner_wr_req_wdata;
  wire [ 3:0] inner_wr_req_wstrb;
  wire  inner_wr_req_wlast;
  wire  inner_wr_rsp_valid;
  wire  inner_wr_rsp_ready;
  wire  inner_wr_rsp_error;
  wire  inner_m_axi_awid;
  wire [31:0] inner_m_axi_awaddr;
  wire [ 7:0] inner_m_axi_awlen;
  wire [ 2:0] inner_m_axi_awsize;
  wire [ 1:0] inner_m_axi_awburst;
  wire  inner_m_axi_awlock;
  wire [ 3:0] inner_m_axi_awcache;
  wire [ 2:0] inner_m_axi_awprot;
  wire [ 3:0] inner_m_axi_awqos;
  wire [ 3:0] inner_m_axi_awregion;
  wire  inner_m_axi_awvalid;
  wire  inner_m_axi_awready;
  wire  inner_m_axi_arid;
  wire [31:0] inner_m_axi_araddr;
  wire [ 7:0] inner_m_axi_arlen;
  wire [ 2:0] inner_m_axi_arsize;
  wire [ 1:0] inner_m_axi_arburst;
  wire  inner_m_axi_arlock;
  wire [ 3:0] inner_m_axi_arcache;
  wire [ 2:0] inner_m_axi_arprot;
  wire [ 3:0] inner_m_axi_arqos;
  wire [ 3:0] inner_m_axi_arregion;
  wire  inner_m_axi_arvalid;
  wire  inner_m_axi_arready;
  wire [31:0] inner_m_axi_wdata;
  wire [ 3:0] inner_m_axi_wstrb;
  wire  inner_m_axi_wlast;
  wire  inner_m_axi_wvalid;
  wire  inner_m_axi_wready;
  wire  inner_m_axi_bid;
  wire [ 1:0] inner_m_axi_bresp;
  wire  inner_m_axi_bvalid;
  wire  inner_m_axi_bready;
  wire  inner_m_axi_rid;
  wire [31:0] inner_m_axi_rdata;
  wire [ 1:0] inner_m_axi_rresp;
  wire  inner_m_axi_rlast;
  wire  inner_m_axi_rvalid;
  wire  inner_m_axi_rready;
  axi4_master_impl endpoint (
    .clk(clk), .rst(rst),
    .rd_req_valid(inner_rd_req_valid),
    .rd_req_ready(inner_rd_req_ready),
    .rd_req_addr(inner_rd_req_addr),
    .rd_req_len(inner_rd_req_len),
    .rd_rsp_valid(inner_rd_rsp_valid),
    .rd_rsp_ready(inner_rd_rsp_ready),
    .rd_rsp_rdata(inner_rd_rsp_rdata),
    .rd_rsp_error(inner_rd_rsp_error),
    .rd_rsp_last(inner_rd_rsp_last),
    .wr_req_valid(inner_wr_req_valid),
    .wr_req_ready(inner_wr_req_ready),
    .wr_req_addr(inner_wr_req_addr),
    .wr_req_len(inner_wr_req_len),
    .wr_req_wdata(inner_wr_req_wdata),
    .wr_req_wstrb(inner_wr_req_wstrb),
    .wr_req_wlast(inner_wr_req_wlast),
    .wr_rsp_valid(inner_wr_rsp_valid),
    .wr_rsp_ready(inner_wr_rsp_ready),
    .wr_rsp_error(inner_wr_rsp_error),
    .m_axi_awid(inner_m_axi_awid),
    .m_axi_awaddr(inner_m_axi_awaddr),
    .m_axi_awlen(inner_m_axi_awlen),
    .m_axi_awsize(inner_m_axi_awsize),
    .m_axi_awburst(inner_m_axi_awburst),
    .m_axi_awlock(inner_m_axi_awlock),
    .m_axi_awcache(inner_m_axi_awcache),
    .m_axi_awprot(inner_m_axi_awprot),
    .m_axi_awqos(inner_m_axi_awqos),
    .m_axi_awregion(inner_m_axi_awregion),
    .m_axi_awvalid(inner_m_axi_awvalid),
    .m_axi_awready(inner_m_axi_awready),
    .m_axi_arid(inner_m_axi_arid),
    .m_axi_araddr(inner_m_axi_araddr),
    .m_axi_arlen(inner_m_axi_arlen),
    .m_axi_arsize(inner_m_axi_arsize),
    .m_axi_arburst(inner_m_axi_arburst),
    .m_axi_arlock(inner_m_axi_arlock),
    .m_axi_arcache(inner_m_axi_arcache),
    .m_axi_arprot(inner_m_axi_arprot),
    .m_axi_arqos(inner_m_axi_arqos),
    .m_axi_arregion(inner_m_axi_arregion),
    .m_axi_arvalid(inner_m_axi_arvalid),
    .m_axi_arready(inner_m_axi_arready),
    .m_axi_wdata(inner_m_axi_wdata),
    .m_axi_wstrb(inner_m_axi_wstrb),
    .m_axi_wlast(inner_m_axi_wlast),
    .m_axi_wvalid(inner_m_axi_wvalid),
    .m_axi_wready(inner_m_axi_wready),
    .m_axi_bid(inner_m_axi_bid),
    .m_axi_bresp(inner_m_axi_bresp),
    .m_axi_bvalid(inner_m_axi_bvalid),
    .m_axi_bready(inner_m_axi_bready),
    .m_axi_rid(inner_m_axi_rid),
    .m_axi_rdata(inner_m_axi_rdata),
    .m_axi_rresp(inner_m_axi_rresp),
    .m_axi_rlast(inner_m_axi_rlast),
    .m_axi_rvalid(inner_m_axi_rvalid),
    .m_axi_rready(inner_m_axi_rready)
  );
  axi4_channel_delay #(.WIDTH(40), .CHANNEL(1)) delay_rd_req (
    .clk(clk), .rst(rst),
    .in_data({rd_req_addr, rd_req_len}), .in_valid(rd_req_valid), .in_ready(rd_req_ready),
    .out_data({inner_rd_req_addr, inner_rd_req_len}), .out_valid(inner_rd_req_valid), .out_ready(inner_rd_req_ready)
  );
  axi4_channel_delay #(.WIDTH(77), .CHANNEL(2)) delay_wr_req (
    .clk(clk), .rst(rst),
    .in_data({wr_req_addr, wr_req_len, wr_req_wdata, wr_req_wstrb, wr_req_wlast}), .in_valid(wr_req_valid), .in_ready(wr_req_ready),
    .out_data({inner_wr_req_addr, inner_wr_req_len, inner_wr_req_wdata, inner_wr_req_wstrb, inner_wr_req_wlast}), .out_valid(inner_wr_req_valid), .out_ready(inner_wr_req_ready)
  );
  axi4_channel_delay #(.WIDTH(34), .CHANNEL(3)) delay_rd_rsp (
    .clk(clk), .rst(rst),
    .in_data({inner_rd_rsp_rdata, inner_rd_rsp_error, inner_rd_rsp_last}), .in_valid(inner_rd_rsp_valid), .in_ready(inner_rd_rsp_ready),
    .out_data({rd_rsp_rdata, rd_rsp_error, rd_rsp_last}), .out_valid(rd_rsp_valid), .out_ready(rd_rsp_ready)
  );
  axi4_channel_delay #(.WIDTH(1), .CHANNEL(4)) delay_wr_rsp (
    .clk(clk), .rst(rst),
    .in_data({inner_wr_rsp_error}), .in_valid(inner_wr_rsp_valid), .in_ready(inner_wr_rsp_ready),
    .out_data({wr_rsp_error}), .out_valid(wr_rsp_valid), .out_ready(wr_rsp_ready)
  );
  axi4_channel_delay #(.WIDTH(62), .CHANNEL(5)) delay_aw (
    .clk(clk), .rst(rst),
    .in_data({inner_m_axi_awid, inner_m_axi_awaddr, inner_m_axi_awlen, inner_m_axi_awsize, inner_m_axi_awburst, inner_m_axi_awlock, inner_m_axi_awcache, inner_m_axi_awprot, inner_m_axi_awqos, inner_m_axi_awregion}), .in_valid(inner_m_axi_awvalid), .in_ready(inner_m_axi_awready),
    .out_data({m_axi_awid, m_axi_awaddr, m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awlock, m_axi_awcache, m_axi_awprot, m_axi_awqos, m_axi_awregion}), .out_valid(m_axi_awvalid), .out_ready(m_axi_awready)
  );
  axi4_channel_delay #(.WIDTH(37), .CHANNEL(6)) delay_w (
    .clk(clk), .rst(rst),
    .in_data({inner_m_axi_wdata, inner_m_axi_wstrb, inner_m_axi_wlast}), .in_valid(inner_m_axi_wvalid), .in_ready(inner_m_axi_wready),
    .out_data({m_axi_wdata, m_axi_wstrb, m_axi_wlast}), .out_valid(m_axi_wvalid), .out_ready(m_axi_wready)
  );
  axi4_channel_delay #(.WIDTH(3), .CHANNEL(7)) delay_b (
    .clk(clk), .rst(rst),
    .in_data({m_axi_bid, m_axi_bresp}), .in_valid(m_axi_bvalid), .in_ready(m_axi_bready),
    .out_data({inner_m_axi_bid, inner_m_axi_bresp}), .out_valid(inner_m_axi_bvalid), .out_ready(inner_m_axi_bready)
  );
  axi4_channel_delay #(.WIDTH(62), .CHANNEL(8)) delay_ar (
    .clk(clk), .rst(rst),
    .in_data({inner_m_axi_arid, inner_m_axi_araddr, inner_m_axi_arlen, inner_m_axi_arsize, inner_m_axi_arburst, inner_m_axi_arlock, inner_m_axi_arcache, inner_m_axi_arprot, inner_m_axi_arqos, inner_m_axi_arregion}), .in_valid(inner_m_axi_arvalid), .in_ready(inner_m_axi_arready),
    .out_data({m_axi_arid, m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst, m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos, m_axi_arregion}), .out_valid(m_axi_arvalid), .out_ready(m_axi_arready)
  );
  axi4_channel_delay #(.WIDTH(36), .CHANNEL(9)) delay_r (
    .clk(clk), .rst(rst),
    .in_data({m_axi_rid, m_axi_rdata, m_axi_rresp, m_axi_rlast}), .in_valid(m_axi_rvalid), .in_ready(m_axi_rready),
    .out_data({inner_m_axi_rid, inner_m_axi_rdata, inner_m_axi_rresp, inner_m_axi_rlast}), .out_valid(inner_m_axi_rvalid), .out_ready(inner_m_axi_rready)
  );
endmodule

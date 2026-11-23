`timescale 1ns / 1ns

module axi4_subsystem #(
    parameter RAM_BANK0_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank0.hex",
    parameter RAM_BANK1_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank1.hex",
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,
    parameter integer UART_RX_FIFO_DEPTH = 4
) (
    input clk, input rst, input uart_rxd, output uart_txd,
    output [31:0] tohost_value,
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
  wire [1:0] slave_awid;
  wire [63:0] slave_awaddr;
  wire [15:0] slave_awlen;
  wire [5:0] slave_awsize;
  wire [3:0] slave_awburst;
  wire [1:0] slave_awlock;
  wire [7:0] slave_awcache;
  wire [5:0] slave_awprot;
  wire [7:0] slave_awqos;
  wire [7:0] slave_awregion;
  wire [1:0] slave_awvalid;
  wire [1:0] slave_awready;
  wire [1:0] slave_arid;
  wire [63:0] slave_araddr;
  wire [15:0] slave_arlen;
  wire [5:0] slave_arsize;
  wire [3:0] slave_arburst;
  wire [1:0] slave_arlock;
  wire [7:0] slave_arcache;
  wire [5:0] slave_arprot;
  wire [7:0] slave_arqos;
  wire [7:0] slave_arregion;
  wire [1:0] slave_arvalid;
  wire [1:0] slave_arready;
  wire [63:0] slave_wdata;
  wire [7:0] slave_wstrb;
  wire [1:0] slave_wlast;
  wire [1:0] slave_wvalid;
  wire [1:0] slave_wready;
  wire [1:0] slave_bid;
  wire [3:0] slave_bresp;
  wire [1:0] slave_bvalid;
  wire [1:0] slave_bready;
  wire [1:0] slave_rid;
  wire [63:0] slave_rdata;
  wire [3:0] slave_rresp;
  wire [1:0] slave_rlast;
  wire [1:0] slave_rvalid;
  wire [1:0] slave_rready;
  axi4_interconnect u_interconnect (
      .clk(clk), .rst(rst),
      .s_axi_awid(s_axi_awid),
      .s_axi_awaddr(s_axi_awaddr),
      .s_axi_awlen(s_axi_awlen),
      .s_axi_awsize(s_axi_awsize),
      .s_axi_awburst(s_axi_awburst),
      .s_axi_awlock(s_axi_awlock),
      .s_axi_awcache(s_axi_awcache),
      .s_axi_awprot(s_axi_awprot),
      .s_axi_awqos(s_axi_awqos),
      .s_axi_awregion(s_axi_awregion),
      .s_axi_awvalid(s_axi_awvalid),
      .s_axi_awready(s_axi_awready),
      .s_axi_arid(s_axi_arid),
      .s_axi_araddr(s_axi_araddr),
      .s_axi_arlen(s_axi_arlen),
      .s_axi_arsize(s_axi_arsize),
      .s_axi_arburst(s_axi_arburst),
      .s_axi_arlock(s_axi_arlock),
      .s_axi_arcache(s_axi_arcache),
      .s_axi_arprot(s_axi_arprot),
      .s_axi_arqos(s_axi_arqos),
      .s_axi_arregion(s_axi_arregion),
      .s_axi_arvalid(s_axi_arvalid),
      .s_axi_arready(s_axi_arready),
      .s_axi_wdata(s_axi_wdata),
      .s_axi_wstrb(s_axi_wstrb),
      .s_axi_wlast(s_axi_wlast),
      .s_axi_wvalid(s_axi_wvalid),
      .s_axi_wready(s_axi_wready),
      .s_axi_bid(s_axi_bid),
      .s_axi_bresp(s_axi_bresp),
      .s_axi_bvalid(s_axi_bvalid),
      .s_axi_bready(s_axi_bready),
      .s_axi_rid(s_axi_rid),
      .s_axi_rdata(s_axi_rdata),
      .s_axi_rresp(s_axi_rresp),
      .s_axi_rlast(s_axi_rlast),
      .s_axi_rvalid(s_axi_rvalid),
      .s_axi_rready(s_axi_rready),
      .m_axi_awid(slave_awid),
      .m_axi_awaddr(slave_awaddr),
      .m_axi_awlen(slave_awlen),
      .m_axi_awsize(slave_awsize),
      .m_axi_awburst(slave_awburst),
      .m_axi_awlock(slave_awlock),
      .m_axi_awcache(slave_awcache),
      .m_axi_awprot(slave_awprot),
      .m_axi_awqos(slave_awqos),
      .m_axi_awregion(slave_awregion),
      .m_axi_awvalid(slave_awvalid),
      .m_axi_awready(slave_awready),
      .m_axi_arid(slave_arid),
      .m_axi_araddr(slave_araddr),
      .m_axi_arlen(slave_arlen),
      .m_axi_arsize(slave_arsize),
      .m_axi_arburst(slave_arburst),
      .m_axi_arlock(slave_arlock),
      .m_axi_arcache(slave_arcache),
      .m_axi_arprot(slave_arprot),
      .m_axi_arqos(slave_arqos),
      .m_axi_arregion(slave_arregion),
      .m_axi_arvalid(slave_arvalid),
      .m_axi_arready(slave_arready),
      .m_axi_wdata(slave_wdata),
      .m_axi_wstrb(slave_wstrb),
      .m_axi_wlast(slave_wlast),
      .m_axi_wvalid(slave_wvalid),
      .m_axi_wready(slave_wready),
      .m_axi_bid(slave_bid),
      .m_axi_bresp(slave_bresp),
      .m_axi_bvalid(slave_bvalid),
      .m_axi_bready(slave_bready),
      .m_axi_rid(slave_rid),
      .m_axi_rdata(slave_rdata),
      .m_axi_rresp(slave_rresp),
      .m_axi_rlast(slave_rlast),
      .m_axi_rvalid(slave_rvalid),
      .m_axi_rready(slave_rready)
  );
  axi4_ram_slave #(.BANK0_HEX(RAM_BANK0_HEX), .BANK1_HEX(RAM_BANK1_HEX)) ram (
      .clk(clk), .rst(rst), .tohost_value(tohost_value),
      .s_axi_awid(slave_awid[0 +: 1]),
      .s_axi_awaddr(slave_awaddr[0 +: 32]),
      .s_axi_awlen(slave_awlen[0 +: 8]),
      .s_axi_awsize(slave_awsize[0 +: 3]),
      .s_axi_awburst(slave_awburst[0 +: 2]),
      .s_axi_awlock(slave_awlock[0 +: 1]),
      .s_axi_awcache(slave_awcache[0 +: 4]),
      .s_axi_awprot(slave_awprot[0 +: 3]),
      .s_axi_awqos(slave_awqos[0 +: 4]),
      .s_axi_awregion(slave_awregion[0 +: 4]),
      .s_axi_awvalid(slave_awvalid[0 +: 1]),
      .s_axi_awready(slave_awready[0 +: 1]),
      .s_axi_arid(slave_arid[0 +: 1]),
      .s_axi_araddr(slave_araddr[0 +: 32]),
      .s_axi_arlen(slave_arlen[0 +: 8]),
      .s_axi_arsize(slave_arsize[0 +: 3]),
      .s_axi_arburst(slave_arburst[0 +: 2]),
      .s_axi_arlock(slave_arlock[0 +: 1]),
      .s_axi_arcache(slave_arcache[0 +: 4]),
      .s_axi_arprot(slave_arprot[0 +: 3]),
      .s_axi_arqos(slave_arqos[0 +: 4]),
      .s_axi_arregion(slave_arregion[0 +: 4]),
      .s_axi_arvalid(slave_arvalid[0 +: 1]),
      .s_axi_arready(slave_arready[0 +: 1]),
      .s_axi_wdata(slave_wdata[0 +: 32]),
      .s_axi_wstrb(slave_wstrb[0 +: 4]),
      .s_axi_wlast(slave_wlast[0 +: 1]),
      .s_axi_wvalid(slave_wvalid[0 +: 1]),
      .s_axi_wready(slave_wready[0 +: 1]),
      .s_axi_bid(slave_bid[0 +: 1]),
      .s_axi_bresp(slave_bresp[0 +: 2]),
      .s_axi_bvalid(slave_bvalid[0 +: 1]),
      .s_axi_bready(slave_bready[0 +: 1]),
      .s_axi_rid(slave_rid[0 +: 1]),
      .s_axi_rdata(slave_rdata[0 +: 32]),
      .s_axi_rresp(slave_rresp[0 +: 2]),
      .s_axi_rlast(slave_rlast[0 +: 1]),
      .s_axi_rvalid(slave_rvalid[0 +: 1]),
      .s_axi_rready(slave_rready[0 +: 1])
  );
  axi4_uart_slave #(.UART_CLK_HZ(UART_CLK_HZ), .UART_BAUD(UART_BAUD),
      .RX_FIFO_DEPTH(UART_RX_FIFO_DEPTH)) uart (
      .clk(clk), .rst(rst), .uart_rxd(uart_rxd), .uart_txd(uart_txd),
      .s_axi_awid(slave_awid[1 +: 1]),
      .s_axi_awaddr(slave_awaddr[32 +: 32]),
      .s_axi_awlen(slave_awlen[8 +: 8]),
      .s_axi_awsize(slave_awsize[3 +: 3]),
      .s_axi_awburst(slave_awburst[2 +: 2]),
      .s_axi_awlock(slave_awlock[1 +: 1]),
      .s_axi_awcache(slave_awcache[4 +: 4]),
      .s_axi_awprot(slave_awprot[3 +: 3]),
      .s_axi_awqos(slave_awqos[4 +: 4]),
      .s_axi_awregion(slave_awregion[4 +: 4]),
      .s_axi_awvalid(slave_awvalid[1 +: 1]),
      .s_axi_awready(slave_awready[1 +: 1]),
      .s_axi_arid(slave_arid[1 +: 1]),
      .s_axi_araddr(slave_araddr[32 +: 32]),
      .s_axi_arlen(slave_arlen[8 +: 8]),
      .s_axi_arsize(slave_arsize[3 +: 3]),
      .s_axi_arburst(slave_arburst[2 +: 2]),
      .s_axi_arlock(slave_arlock[1 +: 1]),
      .s_axi_arcache(slave_arcache[4 +: 4]),
      .s_axi_arprot(slave_arprot[3 +: 3]),
      .s_axi_arqos(slave_arqos[4 +: 4]),
      .s_axi_arregion(slave_arregion[4 +: 4]),
      .s_axi_arvalid(slave_arvalid[1 +: 1]),
      .s_axi_arready(slave_arready[1 +: 1]),
      .s_axi_wdata(slave_wdata[32 +: 32]),
      .s_axi_wstrb(slave_wstrb[4 +: 4]),
      .s_axi_wlast(slave_wlast[1 +: 1]),
      .s_axi_wvalid(slave_wvalid[1 +: 1]),
      .s_axi_wready(slave_wready[1 +: 1]),
      .s_axi_bid(slave_bid[1 +: 1]),
      .s_axi_bresp(slave_bresp[2 +: 2]),
      .s_axi_bvalid(slave_bvalid[1 +: 1]),
      .s_axi_bready(slave_bready[1 +: 1]),
      .s_axi_rid(slave_rid[1 +: 1]),
      .s_axi_rdata(slave_rdata[32 +: 32]),
      .s_axi_rresp(slave_rresp[2 +: 2]),
      .s_axi_rlast(slave_rlast[1 +: 1]),
      .s_axi_rvalid(slave_rvalid[1 +: 1]),
      .s_axi_rready(slave_rready[1 +: 1])
  );
endmodule

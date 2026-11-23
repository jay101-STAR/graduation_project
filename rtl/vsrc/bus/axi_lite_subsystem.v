`timescale 1ns / 1ns

// RAM and UART occupy parallel slave slots behind the same address decoder.
module axi_lite_subsystem #(
    parameter RAM_BANK0_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank0.hex",
    parameter RAM_BANK1_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank1.hex",
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,
    parameter integer UART_RX_FIFO_DEPTH = 4
) (
    input clk, input rst, input uart_rxd, output uart_txd,
    output [31:0] tohost_value,
    input [31:0] s_axi_awaddr,
    input [2:0] s_axi_awprot,
    input s_axi_awvalid,
    output s_axi_awready,
    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input s_axi_wvalid,
    output s_axi_wready,
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready,
    input [31:0] s_axi_araddr,
    input [2:0] s_axi_arprot,
    input s_axi_arvalid,
    output s_axi_arready,
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input s_axi_rready
);
  wire [63:0] slave_awaddr;
  wire [5:0] slave_awprot;
  wire [1:0] slave_awvalid;
  wire [1:0] slave_awready;
  wire [63:0] slave_wdata;
  wire [7:0] slave_wstrb;
  wire [1:0] slave_wvalid;
  wire [1:0] slave_wready;
  wire [3:0] slave_bresp;
  wire [1:0] slave_bvalid;
  wire [1:0] slave_bready;
  wire [63:0] slave_araddr;
  wire [5:0] slave_arprot;
  wire [1:0] slave_arvalid;
  wire [1:0] slave_arready;
  wire [63:0] slave_rdata;
  wire [3:0] slave_rresp;
  wire [1:0] slave_rvalid;
  wire [1:0] slave_rready;

  axi_lite_interconnect u_interconnect (
      .clk(clk), .rst(rst),
      .s_axi_awaddr(s_axi_awaddr),
      .s_axi_awprot(s_axi_awprot),
      .s_axi_awvalid(s_axi_awvalid),
      .s_axi_awready(s_axi_awready),
      .s_axi_wdata(s_axi_wdata),
      .s_axi_wstrb(s_axi_wstrb),
      .s_axi_wvalid(s_axi_wvalid),
      .s_axi_wready(s_axi_wready),
      .s_axi_bresp(s_axi_bresp),
      .s_axi_bvalid(s_axi_bvalid),
      .s_axi_bready(s_axi_bready),
      .s_axi_araddr(s_axi_araddr),
      .s_axi_arprot(s_axi_arprot),
      .s_axi_arvalid(s_axi_arvalid),
      .s_axi_arready(s_axi_arready),
      .s_axi_rdata(s_axi_rdata),
      .s_axi_rresp(s_axi_rresp),
      .s_axi_rvalid(s_axi_rvalid),
      .s_axi_rready(s_axi_rready),
      .m_axi_awaddr(slave_awaddr),
      .m_axi_awprot(slave_awprot),
      .m_axi_awvalid(slave_awvalid),
      .m_axi_awready(slave_awready),
      .m_axi_wdata(slave_wdata),
      .m_axi_wstrb(slave_wstrb),
      .m_axi_wvalid(slave_wvalid),
      .m_axi_wready(slave_wready),
      .m_axi_bresp(slave_bresp),
      .m_axi_bvalid(slave_bvalid),
      .m_axi_bready(slave_bready),
      .m_axi_araddr(slave_araddr),
      .m_axi_arprot(slave_arprot),
      .m_axi_arvalid(slave_arvalid),
      .m_axi_arready(slave_arready),
      .m_axi_rdata(slave_rdata),
      .m_axi_rresp(slave_rresp),
      .m_axi_rvalid(slave_rvalid),
      .m_axi_rready(slave_rready)
  );

  axi_lite_ram_slave #(.BANK0_HEX(RAM_BANK0_HEX), .BANK1_HEX(RAM_BANK1_HEX)) ram (
      .clk(clk), .rst(rst),
      .tohost_value(tohost_value),
      .s_axi_awaddr(slave_awaddr[0 +: 32]),
      .s_axi_awprot(slave_awprot[0 +: 3]),
      .s_axi_awvalid(slave_awvalid[0]),
      .s_axi_awready(slave_awready[0]),
      .s_axi_wdata(slave_wdata[0 +: 32]),
      .s_axi_wstrb(slave_wstrb[0 +: 4]),
      .s_axi_wvalid(slave_wvalid[0]),
      .s_axi_wready(slave_wready[0]),
      .s_axi_bresp(slave_bresp[0 +: 2]),
      .s_axi_bvalid(slave_bvalid[0]),
      .s_axi_bready(slave_bready[0]),
      .s_axi_araddr(slave_araddr[0 +: 32]),
      .s_axi_arprot(slave_arprot[0 +: 3]),
      .s_axi_arvalid(slave_arvalid[0]),
      .s_axi_arready(slave_arready[0]),
      .s_axi_rdata(slave_rdata[0 +: 32]),
      .s_axi_rresp(slave_rresp[0 +: 2]),
      .s_axi_rvalid(slave_rvalid[0]),
      .s_axi_rready(slave_rready[0])
  );

  axi_lite_uart_slave #(
      .UART_CLK_HZ(UART_CLK_HZ), .UART_BAUD(UART_BAUD), .RX_FIFO_DEPTH(UART_RX_FIFO_DEPTH)
  ) uart (
      .clk(clk), .rst(rst),
      .uart_rxd(uart_rxd), .uart_txd(uart_txd),
      .s_axi_awaddr(slave_awaddr[32 +: 32]),
      .s_axi_awprot(slave_awprot[3 +: 3]),
      .s_axi_awvalid(slave_awvalid[1]),
      .s_axi_awready(slave_awready[1]),
      .s_axi_wdata(slave_wdata[32 +: 32]),
      .s_axi_wstrb(slave_wstrb[4 +: 4]),
      .s_axi_wvalid(slave_wvalid[1]),
      .s_axi_wready(slave_wready[1]),
      .s_axi_bresp(slave_bresp[2 +: 2]),
      .s_axi_bvalid(slave_bvalid[1]),
      .s_axi_bready(slave_bready[1]),
      .s_axi_araddr(slave_araddr[32 +: 32]),
      .s_axi_arprot(slave_arprot[3 +: 3]),
      .s_axi_arvalid(slave_arvalid[1]),
      .s_axi_arready(slave_arready[1]),
      .s_axi_rdata(slave_rdata[32 +: 32]),
      .s_axi_rresp(slave_rresp[2 +: 2]),
      .s_axi_rvalid(slave_rvalid[1]),
      .s_axi_rready(slave_rready[1])
  );

endmodule


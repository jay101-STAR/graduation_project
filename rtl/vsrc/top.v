`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module top #(
    parameter integer ICACHE_ENABLE = 1,
    parameter integer DCACHE_ENABLE = 0
) (
    input         clk,
    input         rst,                    // 保持高有效异步复位
    output [31:0] tohost_value_register,
    output [31:0] tohost_value_dataram,
    output [31:0] bp_branch_total,
    output [31:0] bp_mispredict_total,
    output [31:0] bp_target_miss_total,
    input         ext_top_uart_rxd,
    output        ext_top_uart_txd
);

  wire sync_rst;  // 异步复位同步释放，供 Core 与外部总线系统共用。
  // Core <-> external bus master: independent native read/write paths.
  wire word_rd_req_valid, word_rd_req_ready;
  wire [31:0] word_rd_req_addr;
  wire [7:0] word_rd_req_len;
  wire word_rd_rsp_valid, word_rd_rsp_ready, word_rd_rsp_error, word_rd_rsp_last;
  wire [31:0] word_rd_rsp_rdata;
  wire word_wr_req_valid, word_wr_req_ready, word_wr_req_wlast;
  wire [31:0] word_wr_req_addr, word_wr_req_wdata;
  wire [7:0] word_wr_req_len;
  wire [3:0] word_wr_req_wstrb;
  wire word_wr_rsp_valid, word_wr_rsp_ready, word_wr_rsp_error;

  // External AXI4 master <-> memory/peripheral subsystem
  wire [31:0] bridge_axi_awaddr;
  wire [ 2:0] bridge_axi_awprot;
  wire        bridge_axi_awvalid;
  wire        axi_bridge_awready;
  wire [31:0] bridge_axi_wdata;
  wire [ 3:0] bridge_axi_wstrb;
  wire        bridge_axi_wvalid;
  wire        axi_bridge_wready;
  wire [ 1:0] axi_bridge_bresp;
  wire        axi_bridge_bvalid;
  wire        bridge_axi_bready;
  wire [31:0] bridge_axi_araddr;
  wire [ 2:0] bridge_axi_arprot;
  wire        bridge_axi_arvalid;
  wire        axi_bridge_arready;
  wire [31:0] axi_bridge_rdata;
  wire [ 1:0] axi_bridge_rresp;
  wire        axi_bridge_rvalid;
  wire        bridge_axi_rready;

  wire        bridge_axi_awid;
  wire [ 7:0] bridge_axi_awlen;
  wire [ 2:0] bridge_axi_awsize;
  wire [ 1:0] bridge_axi_awburst;
  wire        bridge_axi_awlock;
  wire [ 3:0] bridge_axi_awcache;
  wire [ 3:0] bridge_axi_awqos;
  wire [ 3:0] bridge_axi_awregion;
  wire        bridge_axi_arid;
  wire [ 7:0] bridge_axi_arlen;
  wire [ 2:0] bridge_axi_arsize;
  wire [ 1:0] bridge_axi_arburst;
  wire        bridge_axi_arlock;
  wire [ 3:0] bridge_axi_arcache;
  wire [ 3:0] bridge_axi_arqos;
  wire [ 3:0] bridge_axi_arregion;
  wire        bridge_axi_wlast;
  wire        axi_bridge_bid;
  wire        axi_bridge_rid;
  wire        axi_bridge_rlast;

  localparam integer UART_CLK_HZ = 50000000;
  localparam integer UART_BAUD = 115200;
  localparam integer UART_RX_FIFO_DEPTH = 4;

  // 异步复位同步释放电路
  async_reset async_reset0 (
      .clk      (clk),
      .async_rst(rst),      // 异步高有效复位
      .sync_rst (sync_rst)  // 同步高有效复位
  );

  riscv_core #(
      .ICACHE_ENABLE(ICACHE_ENABLE),
      .DCACHE_ENABLE(DCACHE_ENABLE)
  ) u_core (
      .clk                      (clk),
      .rst                      (sync_rst),
      .mem_rd_req_valid         (word_rd_req_valid),
      .mem_rd_req_ready         (word_rd_req_ready),
      .mem_rd_req_addr          (word_rd_req_addr),
      .mem_rd_req_len           (word_rd_req_len),
      .mem_rd_rsp_valid         (word_rd_rsp_valid),
      .mem_rd_rsp_ready         (word_rd_rsp_ready),
      .mem_rd_rsp_rdata         (word_rd_rsp_rdata),
      .mem_rd_rsp_error         (word_rd_rsp_error),
      .mem_rd_rsp_last          (word_rd_rsp_last),
      .mem_wr_req_valid         (word_wr_req_valid),
      .mem_wr_req_ready         (word_wr_req_ready),
      .mem_wr_req_addr          (word_wr_req_addr),
      .mem_wr_req_len           (word_wr_req_len),
      .mem_wr_req_wdata         (word_wr_req_wdata),
      .mem_wr_req_wstrb         (word_wr_req_wstrb),
      .mem_wr_req_wlast         (word_wr_req_wlast),
      .mem_wr_rsp_valid         (word_wr_rsp_valid),
      .mem_wr_rsp_ready         (word_wr_rsp_ready),
      .mem_wr_rsp_error         (word_wr_rsp_error),
      .tohost_value_register    (tohost_value_register),
      .core_bp_branch_total     (bp_branch_total),
      .core_bp_mispredict_total (bp_mispredict_total),
      .core_bp_target_miss_total(bp_target_miss_total)
  );

  axi4_master axi4_master0 (
      .clk(clk), .rst(sync_rst),
      .rd_req_valid(word_rd_req_valid), .rd_req_ready(word_rd_req_ready),
      .rd_req_addr(word_rd_req_addr), .rd_req_len(word_rd_req_len),
      .rd_rsp_valid(word_rd_rsp_valid), .rd_rsp_ready(word_rd_rsp_ready),
      .rd_rsp_rdata(word_rd_rsp_rdata), .rd_rsp_error(word_rd_rsp_error), .rd_rsp_last(word_rd_rsp_last),
      .wr_req_valid(word_wr_req_valid), .wr_req_ready(word_wr_req_ready),
      .wr_req_addr(word_wr_req_addr), .wr_req_len(word_wr_req_len),
      .wr_req_wdata(word_wr_req_wdata), .wr_req_wstrb(word_wr_req_wstrb), .wr_req_wlast(word_wr_req_wlast),
      .wr_rsp_valid(word_wr_rsp_valid), .wr_rsp_ready(word_wr_rsp_ready), .wr_rsp_error(word_wr_rsp_error),
      .m_axi_awid    (bridge_axi_awid),
      .m_axi_awlen   (bridge_axi_awlen),
      .m_axi_awsize  (bridge_axi_awsize),
      .m_axi_awburst (bridge_axi_awburst),
      .m_axi_awlock  (bridge_axi_awlock),
      .m_axi_awcache (bridge_axi_awcache),
      .m_axi_awqos   (bridge_axi_awqos),
      .m_axi_awregion(bridge_axi_awregion),
      .m_axi_arid    (bridge_axi_arid),
      .m_axi_arlen   (bridge_axi_arlen),
      .m_axi_arsize  (bridge_axi_arsize),
      .m_axi_arburst (bridge_axi_arburst),
      .m_axi_arlock  (bridge_axi_arlock),
      .m_axi_arcache (bridge_axi_arcache),
      .m_axi_arqos   (bridge_axi_arqos),
      .m_axi_arregion(bridge_axi_arregion),
      .m_axi_wlast   (bridge_axi_wlast),
      .m_axi_bid     (axi_bridge_bid),
      .m_axi_rid     (axi_bridge_rid),
      .m_axi_rlast   (axi_bridge_rlast),
      .m_axi_awaddr  (bridge_axi_awaddr),
      .m_axi_awprot  (bridge_axi_awprot),
      .m_axi_awvalid (bridge_axi_awvalid),
      .m_axi_awready (axi_bridge_awready),
      .m_axi_wdata   (bridge_axi_wdata),
      .m_axi_wstrb   (bridge_axi_wstrb),
      .m_axi_wvalid  (bridge_axi_wvalid),
      .m_axi_wready  (axi_bridge_wready),
      .m_axi_bresp   (axi_bridge_bresp),
      .m_axi_bvalid  (axi_bridge_bvalid),
      .m_axi_bready  (bridge_axi_bready),
      .m_axi_araddr  (bridge_axi_araddr),
      .m_axi_arprot  (bridge_axi_arprot),
      .m_axi_arvalid (bridge_axi_arvalid),
      .m_axi_arready (axi_bridge_arready),
      .m_axi_rdata   (axi_bridge_rdata),
      .m_axi_rresp   (axi_bridge_rresp),
      .m_axi_rvalid  (axi_bridge_rvalid),
      .m_axi_rready  (bridge_axi_rready)
  );

  axi4_subsystem #(
      .UART_CLK_HZ       (UART_CLK_HZ),
      .UART_BAUD         (UART_BAUD),
      .UART_RX_FIFO_DEPTH(UART_RX_FIFO_DEPTH)
  ) axi4_subsystem0 (
      .clk           (clk),
      .rst           (sync_rst),
      .uart_rxd      (ext_top_uart_rxd),
      .uart_txd      (ext_top_uart_txd),
      .tohost_value  (tohost_value_dataram),
      .s_axi_awid    (bridge_axi_awid),
      .s_axi_awlen   (bridge_axi_awlen),
      .s_axi_awsize  (bridge_axi_awsize),
      .s_axi_awburst (bridge_axi_awburst),
      .s_axi_awlock  (bridge_axi_awlock),
      .s_axi_awcache (bridge_axi_awcache),
      .s_axi_awqos   (bridge_axi_awqos),
      .s_axi_awregion(bridge_axi_awregion),
      .s_axi_arid    (bridge_axi_arid),
      .s_axi_arlen   (bridge_axi_arlen),
      .s_axi_arsize  (bridge_axi_arsize),
      .s_axi_arburst (bridge_axi_arburst),
      .s_axi_arlock  (bridge_axi_arlock),
      .s_axi_arcache (bridge_axi_arcache),
      .s_axi_arqos   (bridge_axi_arqos),
      .s_axi_arregion(bridge_axi_arregion),
      .s_axi_wlast   (bridge_axi_wlast),
      .s_axi_bid     (axi_bridge_bid),
      .s_axi_rid     (axi_bridge_rid),
      .s_axi_rlast   (axi_bridge_rlast),
      .s_axi_awaddr  (bridge_axi_awaddr),
      .s_axi_awprot  (bridge_axi_awprot),
      .s_axi_awvalid (bridge_axi_awvalid),
      .s_axi_awready (axi_bridge_awready),
      .s_axi_wdata   (bridge_axi_wdata),
      .s_axi_wstrb   (bridge_axi_wstrb),
      .s_axi_wvalid  (bridge_axi_wvalid),
      .s_axi_wready  (axi_bridge_wready),
      .s_axi_bresp   (axi_bridge_bresp),
      .s_axi_bvalid  (axi_bridge_bvalid),
      .s_axi_bready  (bridge_axi_bready),
      .s_axi_araddr  (bridge_axi_araddr),
      .s_axi_arprot  (bridge_axi_arprot),
      .s_axi_arvalid (bridge_axi_arvalid),
      .s_axi_arready (axi_bridge_arready),
      .s_axi_rdata   (axi_bridge_rdata),
      .s_axi_rresp   (axi_bridge_rresp),
      .s_axi_rvalid  (axi_bridge_rvalid),
      .s_axi_rready  (bridge_axi_rready)
  );
endmodule

`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module top (
    input         clk,
    input         rst,                    // 保持高有效异步复位
    output [31:0] tohost_value_register,
    output [31:0] tohost_value_dataram,
    output [31:0] bp_branch_total,
    output [31:0] bp_mispredict_total,
    output [31:0] bp_target_miss_total,
    input         ext_top_uart_rxd,
    output        ext_top_uart_txd
    // input [16383:0] inst_rom_1

);

  wire [31:0] instrom_core_data;
  wire [31:0] instrom_core_pc;
  wire [31:0] core_instrom_addr;
  wire        core_instrom_ren;
  wire [31:0] core_dataram_addr;
  wire [31:0] core_dataram_wdata;
  wire        core_dataram_wen;
  wire        core_dataram_ren;
  wire [ 7:0] core_dataram_alucex;
  wire        core_dataram_stall;
  wire [31:0] dataram_core_rdata;
  wire        top_core_mem_stall;
  wire        sync_rst;  // 同步复位信号
  wire        dataram_access_ram;
  wire        dataram_access_uart;
  reg         dataram_access_uart_wb;
  wire [31:0] dataram_rdata_raw;
  reg  [ 3:0] core_bridge_wstrb;

  // Bridge <-> CPU local interface
  wire [31:0] bridge_top_rdata;
  wire        bridge_top_stall;
  wire        bridge_top_error;
  wire        instrom_patch_wen;
  wire [31:0] instrom_patch_wdata_aligned;

  // Bridge <-> AXI-Lite slave interface
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

  localparam [31:0] UART_ADDR = 32'h1000_0000;
  localparam integer UART_CLK_HZ = 50000000;
  localparam integer UART_BAUD = 115200;
  localparam integer UART_RX_FIFO_DEPTH = 4;

  // 异步复位同步释放电路
  async_reset async_reset0 (
      .clk      (clk),
      .async_rst(rst),      // 异步高有效复位
      .sync_rst (sync_rst)  // 同步高有效复位
  );

  riscv_core u_core (
      .clk(clk),
      .rst(sync_rst), // 使用同步复位信号
      .top_core_mem_stall(top_core_mem_stall),

      .instrom_core_data(instrom_core_data),
      .instrom_core_pc(instrom_core_pc),
      .core_instrom_addr(core_instrom_addr),
      .core_instrom_ren (core_instrom_ren),
      .tohost_value_register(tohost_value_register),

      .core_dataram_addr  (core_dataram_addr),
      .core_dataram_wdata (core_dataram_wdata),
      .core_dataram_wen   (core_dataram_wen),
      .core_dataram_ren   (core_dataram_ren),
      .core_dataram_alucex(core_dataram_alucex),
      .core_dataram_stall (core_dataram_stall),
      .core_bp_branch_total(bp_branch_total),
      .core_bp_mispredict_total(bp_mispredict_total),
      .core_bp_target_miss_total(bp_target_miss_total),
      .dataram_core_rdata (dataram_core_rdata)
  );

  // AXI/MMIO back-pressure to CPU core.
  assign top_core_mem_stall = bridge_top_stall;

  instrom instrom0 (
      // .inst_rom_1(inst_rom_1),
      .clk              (clk),
      .core_instrom_ren (core_instrom_ren),
      .core_instrom_addr(core_instrom_addr),
      .instrom_patch_wen(instrom_patch_wen),
      .instrom_patch_wstrb(core_bridge_wstrb),
      .instrom_patch_addr(core_dataram_addr),
      .instrom_patch_wdata(instrom_patch_wdata_aligned),
      .instrom_core_data(instrom_core_data),
      .instrom_core_pc(instrom_core_pc)
  );

  // 地址译码
  assign dataram_access_uart = (core_dataram_addr[31:4] == UART_ADDR[31:4]);
  assign dataram_access_ram  = (core_dataram_addr[31:16] == 16'h8000);
  assign instrom_patch_wen   = core_dataram_wen && dataram_access_ram;
  // Mirror stores to instruction memory with byte-lane alignment.
  assign instrom_patch_wdata_aligned = core_dataram_wdata << {core_dataram_addr[1:0], 3'b000};

  // Align MMIO read-source select with WB stage timing.
  always @(posedge clk) begin
    if (sync_rst) begin
      dataram_access_uart_wb <= 1'b0;
    end else if (!top_core_mem_stall) begin
      dataram_access_uart_wb <= (core_dataram_ren && dataram_access_uart);
    end
  end

  // Byte-enable generation for MMIO writes.
  // SW: 1111, SH: 0011 shifted by addr[1:0], SB: 0001 shifted by addr[1:0]
  always @(*) begin
    core_bridge_wstrb = 4'b1111;
    case (core_dataram_alucex)
      `SB_TYPE: begin
        core_bridge_wstrb = (4'b0001 << core_dataram_addr[1:0]);
      end
      `SH_TYPE: begin
        core_bridge_wstrb = (4'b0011 << core_dataram_addr[1:0]);
      end
      `SW_TYPE: begin
        core_bridge_wstrb = 4'b1111;
      end
      default: begin
        core_bridge_wstrb = 4'b1111;
      end
    endcase
  end

  mem_to_axi_lite_bridge mem_to_axi_lite_bridge0 (
      .clk         (clk),
      .rst         (sync_rst),
      .cpu_axi_addr(core_dataram_addr),
      .cpu_axi_wdata(core_dataram_wdata),
      .cpu_axi_wstrb(core_bridge_wstrb),
      .cpu_axi_wen (core_dataram_wen && dataram_access_uart),
      .cpu_axi_ren (core_dataram_ren && dataram_access_uart),
      .axi_cpu_rdata(bridge_top_rdata),
      .axi_cpu_stall(bridge_top_stall),
      .axi_cpu_error(bridge_top_error),
      .m_axi_awaddr(bridge_axi_awaddr),
      .m_axi_awprot(bridge_axi_awprot),
      .m_axi_awvalid(bridge_axi_awvalid),
      .m_axi_awready(axi_bridge_awready),
      .m_axi_wdata (bridge_axi_wdata),
      .m_axi_wstrb (bridge_axi_wstrb),
      .m_axi_wvalid(bridge_axi_wvalid),
      .m_axi_wready(axi_bridge_wready),
      .m_axi_bresp (axi_bridge_bresp),
      .m_axi_bvalid(axi_bridge_bvalid),
      .m_axi_bready(bridge_axi_bready),
      .m_axi_araddr(bridge_axi_araddr),
      .m_axi_arprot(bridge_axi_arprot),
      .m_axi_arvalid(bridge_axi_arvalid),
      .m_axi_arready(axi_bridge_arready),
      .m_axi_rdata (axi_bridge_rdata),
      .m_axi_rresp (axi_bridge_rresp),
      .m_axi_rvalid(axi_bridge_rvalid),
      .m_axi_rready(bridge_axi_rready)
  );

  axi_lite_uart_slave #(
      .UART_CLK_HZ(UART_CLK_HZ),
      .UART_BAUD(UART_BAUD),
      .RX_FIFO_DEPTH(UART_RX_FIFO_DEPTH)
  ) axi_lite_uart_slave0 (
      .clk          (clk),
      .rst          (sync_rst),
      .uart_rxd     (ext_top_uart_rxd),
      .uart_txd     (ext_top_uart_txd),
      .s_axi_awaddr (bridge_axi_awaddr),
      .s_axi_awprot (bridge_axi_awprot),
      .s_axi_awvalid(bridge_axi_awvalid),
      .s_axi_awready(axi_bridge_awready),
      .s_axi_wdata  (bridge_axi_wdata),
      .s_axi_wstrb  (bridge_axi_wstrb),
      .s_axi_wvalid (bridge_axi_wvalid),
      .s_axi_wready (axi_bridge_wready),
      .s_axi_bresp  (axi_bridge_bresp),
      .s_axi_bvalid (axi_bridge_bvalid),
      .s_axi_bready (bridge_axi_bready),
      .s_axi_araddr (bridge_axi_araddr),
      .s_axi_arprot (bridge_axi_arprot),
      .s_axi_arvalid(bridge_axi_arvalid),
      .s_axi_arready(axi_bridge_arready),
      .s_axi_rdata  (axi_bridge_rdata),
      .s_axi_rresp  (axi_bridge_rresp),
      .s_axi_rvalid (axi_bridge_rvalid),
      .s_axi_rready (bridge_axi_rready)
  );

  dataram_banked dataram0 (
      .clk                 (clk),
      .rst                 (sync_rst),
      .stall               (core_dataram_stall),
      .ex_dataram_addr     (core_dataram_addr),
      .ex_dataram_wdata    (core_dataram_wdata),
      .ex_dataram_wen      (core_dataram_wen && dataram_access_ram),
      .ex_dataram_ren      (core_dataram_ren && dataram_access_ram),
      .ex_dataram_alucex   (core_dataram_alucex),
      .dataram_wb_rdata    (dataram_rdata_raw),
      .tohost_value_dataram(tohost_value_dataram)
  );

  assign dataram_core_rdata = dataram_access_uart_wb ? bridge_top_rdata : dataram_rdata_raw;

endmodule

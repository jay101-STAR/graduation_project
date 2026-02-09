module top (
    input         clk,
    input         rst,                    // 保持高有效异步复位
    output [31:0] tohost_value_register,
    output [31:0] tohost_value_dataram
    // input [16383:0] inst_rom_1

);

  wire [31:0] instrom_openmips_data;
  wire [31:0] openmips_instrom_addr;
  wire        openmips_instrom_ren;
  wire [31:0] openmips_dataram_addr;
  wire [31:0] openmips_dataram_wdata;
  wire        openmips_dataram_wen;
  wire        openmips_dataram_ren;
  wire [ 7:0] openmips_dataram_alucex;
  wire        openmips_dataram_stall;
  wire [31:0] dataram_openmips_rdata;
  wire        sync_rst;  // 同步复位信号
  wire        dataram_access_ram;
  wire        dataram_access_uart;
  reg         uart_ren_d1;
  wire [31:0] dataram_rdata_raw;

  localparam [31:0] UART_ADDR = 32'h1000_0000;

  // 异步复位同步释放电路
  async_reset async_reset0 (
      .clk      (clk),
      .async_rst(rst),      // 异步高有效复位
      .sync_rst (sync_rst)  // 同步高有效复位
  );

  openmips openmips0 (
      .clk(clk),
      .rst(sync_rst), // 使用同步复位信号

      .instrom_openmips_data(instrom_openmips_data),
      .openmips_instrom_addr(openmips_instrom_addr),
      .openmips_instrom_ren (openmips_instrom_ren),
      .tohost_value_register(tohost_value_register),

      .openmips_dataram_addr  (openmips_dataram_addr),
      .openmips_dataram_wdata (openmips_dataram_wdata),
      .openmips_dataram_wen   (openmips_dataram_wen),
      .openmips_dataram_ren   (openmips_dataram_ren),
      .openmips_dataram_alucex(openmips_dataram_alucex),
      .openmips_dataram_stall (openmips_dataram_stall),
      .dataram_openmips_rdata (dataram_openmips_rdata)
  );

  instrom instrom0 (
      // .inst_rom_1(inst_rom_1),
      .openmips_instrom_ren (openmips_instrom_ren),
      .openmips_instrom_addr(openmips_instrom_addr),
      .instrom_openmips_data(instrom_openmips_data)
  );

  // 地址译码
  assign dataram_access_uart = (openmips_dataram_addr == UART_ADDR);
  assign dataram_access_ram  = (openmips_dataram_addr[31:16] == 16'h8000);

  // UART 输出（仿真打印）
  always @(posedge clk) begin
    if (!sync_rst && openmips_dataram_wen && dataram_access_uart) begin
      $write("%c", openmips_dataram_wdata[7:0]);
    end
  end

  // UART 读：返回 0（与 DataRAM 同步读时序对齐）
  always @(posedge clk or posedge sync_rst) begin
    if (sync_rst) begin
      uart_ren_d1 <= 1'b0;
    end else begin
      uart_ren_d1 <= openmips_dataram_ren && dataram_access_uart;
    end
  end

  dataram_banked dataram0 (
      .clk                 (clk),
      .rst                 (sync_rst),
      .stall               (openmips_dataram_stall),
      .ex_dataram_addr     (openmips_dataram_addr),
      .ex_dataram_wdata    (openmips_dataram_wdata),
      .ex_dataram_wen      (openmips_dataram_wen && dataram_access_ram),
      .ex_dataram_ren      (openmips_dataram_ren && dataram_access_ram),
      .ex_dataram_alucex   (openmips_dataram_alucex),
      .dataram_wb_rdata    (dataram_rdata_raw),
      .tohost_value_dataram(tohost_value_dataram)
  );

  assign dataram_openmips_rdata = uart_ren_d1 ? 32'b0 : dataram_rdata_raw;

endmodule

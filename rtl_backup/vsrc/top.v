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
  wire        sync_rst;  // 同步复位信号

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
      .tohost_value_dataram (tohost_value_dataram)
  );

  instrom instrom0 (
      // .inst_rom_1(inst_rom_1),
      .openmips_instrom_ren (openmips_instrom_ren),
      .openmips_instrom_addr(openmips_instrom_addr),
      .instrom_openmips_data(instrom_openmips_data)
  );


endmodule

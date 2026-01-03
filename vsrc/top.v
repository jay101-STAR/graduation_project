module top (
    input clk,
    input rst
    // input [16383:0] inst_rom_1

);

  wire [31:0] instrom_openmips_data;
  wire [31:0] openmips_instrom_addr;
  wire        openmips_instrom_ren;

  openmips openmips0 (
      .clk(clk),
      .rst(rst),

      .instrom_openmips_data(instrom_openmips_data),
      .openmips_instrom_addr(openmips_instrom_addr),
      .openmips_instrom_ren (openmips_instrom_ren)
  );

  instrom instrom0 (
      // .inst_rom_1(inst_rom_1),
      .openmips_instrom_ren (openmips_instrom_ren),
      .openmips_instrom_addr(openmips_instrom_addr),
      .instrom_openmips_data(instrom_openmips_data)
  );


endmodule

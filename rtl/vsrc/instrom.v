// `include "muxwithdefault.v"
// `include "define.v"
module instrom (
    input openmips_instrom_ren,
    input [31:0] openmips_instrom_addr,
    // input [16383:0] inst_rom_1,  //32 *1024
    output [31:0] instrom_openmips_data
);
  /* initial $readmemh("/home/jay/Desktop/ics2024/ysyx-workbench/npc/vsrc/instrom.data",inst_rom); */
  reg [31:0] inst_rom[0:31];
  // `UNPACK_ARRAY(32, 512, inst_rom, inst_rom_1)
  initial $readmemh("/home/jay/Desktop/graduation_project/rtl/vsrc/instrom/instrom.hex", inst_rom);
  initial begin
    if (openmips_instrom_addr[1:0] != 2'b00) begin
      $display("PC is not 4-byte aligned");
    end
  end
  muxwithdefault #(2, 1, 32) i0 (
      instrom_openmips_data,
      openmips_instrom_ren,
      32'b0,
      {1'b0, 32'b0, 1'b1, inst_rom[(openmips_instrom_addr-`PC_BASE_ADDR)>>2]}
  );




endmodule

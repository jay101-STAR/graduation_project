`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module dataram (
    input clk,
    input rst,

    input [31:0] ex_dataram_addr,
    input [31:0] ex_dataram_wdata,
    input        ex_dataram_wen,
    input        ex_dataram_ren,
    input [ 7:0] ex_dataram_alucex,

    output reg [31:0] dataram_wb_rdata,
    output     [31:0] tohost_value_dataram
);

  reg [31:0] mem[0:32767];  // 8192 words = 32768 bytes

  integer i;

  // 存储器初始化（仅仿真）
  initial begin
    // 使用 for 循环将所有单元置 0
    for (i = 0; i < 8192; i = i + 1) begin
      mem[i] = 32'h00;
    end

    // 从hex文件加载数据段（如果文件存在）
    // 数据段起始地址为 0x80002000，相对于基地址 0x80000000 的偏移为 0x2000
    // 字地址偏移 = 0x2000 / 4 = 0x800 = 2048
    $readmemh("/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/dataram.hex", mem, 2048);
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // 复位时不操作存储器，因为存储器通常不需要复位
      // 如果需要复位存储器，可以在这里添加逻辑
    end
  end

  wire [31:0] addr_offset = ex_dataram_addr - `PC_BASE_ADDR;
  wire [17:0] word_addr = addr_offset[19:2];
  wire [17:0] word_addr_next = word_addr + 1;
  wire [ 1:0] byte_offset = addr_offset[1:0];

  // Read current and next word for unaligned access
  wire [31:0] mem_data = mem[word_addr];
  wire [31:0] mem_data_next = mem[word_addr_next];

  // Combine 64-bit data for unaligned access
  wire [63:0] combined_data = {mem_data_next, mem_data};
  wire [63:0] shifted_data = combined_data >> (byte_offset * 8);

  wire [31:0] word_unaligned = shifted_data[31:0];
  wire [15:0] halfword_unaligned = shifted_data[15:0];
  wire [ 7:0] byte_data = shifted_data[7:0];

  always @(posedge clk) begin
    if (ex_dataram_wen) begin
      case (ex_dataram_alucex)
        `SB_TYPE: begin
          case (byte_offset)
            2'b00: mem[word_addr][7:0] <= ex_dataram_wdata[7:0];
            2'b01: mem[word_addr][15:8] <= ex_dataram_wdata[7:0];
            2'b10: mem[word_addr][23:16] <= ex_dataram_wdata[7:0];
            2'b11: mem[word_addr][31:24] <= ex_dataram_wdata[7:0];
          endcase
        end
        `SH_TYPE: begin
          case (byte_offset)
            // 偏移0：占据 [15:0]，不需要跨字
            2'b00: mem[word_addr][15:0] <= ex_dataram_wdata[15:0];

            // 偏移1：占据 [23:8]，不需要跨字 (这里是你代码错得最厉害的地方)
            2'b01: mem[word_addr][23:8] <= ex_dataram_wdata[15:0];

            // 偏移2：占据 [31:16]，不需要跨字
            2'b10: mem[word_addr][31:16] <= ex_dataram_wdata[15:0];

            // 偏移3：跨字，当前字占 [31:24]，下个字占 [7:0]
            2'b11: begin
              mem[word_addr][31:24]    <= ex_dataram_wdata[7:0];
              mem[word_addr_next][7:0] <= ex_dataram_wdata[15:8];  // 修正为只写8位
            end
          endcase
        end
        `SW_TYPE: begin
          case (byte_offset)
            2'b00: mem[word_addr] <= ex_dataram_wdata;
            2'b01: begin
              mem[word_addr][31:8]     <= ex_dataram_wdata[23:0];
              mem[word_addr_next][7:0] <= ex_dataram_wdata[31:24];
            end
            2'b10: begin
              mem[word_addr][31:16]     <= ex_dataram_wdata[15:0];
              mem[word_addr_next][15:0] <= ex_dataram_wdata[31:16];
            end
            2'b11: begin
              mem[word_addr][31:24]     <= ex_dataram_wdata[7:0];
              mem[word_addr_next][23:0] <= ex_dataram_wdata[31:8];
            end
          endcase
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if (ex_dataram_ren) begin
      case (ex_dataram_alucex)
        `LB_TYPE:  dataram_wb_rdata = {{24{byte_data[7]}}, byte_data};
        `LH_TYPE:  dataram_wb_rdata = {{16{halfword_unaligned[15]}}, halfword_unaligned};
        `LW_TYPE:  dataram_wb_rdata = word_unaligned;
        `LBU_TYPE: dataram_wb_rdata = {24'b0, byte_data};
        `LHU_TYPE: dataram_wb_rdata = {16'b0, halfword_unaligned};
        default:   dataram_wb_rdata = 32'b0;
      endcase
    end else begin
      dataram_wb_rdata = 32'b0;
    end
  end

  assign tohost_value_dataram = mem[1024];

endmodule

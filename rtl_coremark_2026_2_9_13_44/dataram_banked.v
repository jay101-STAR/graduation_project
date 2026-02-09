//============================================================================
// dataram.v - Bank 交织数据内存控制器
//============================================================================
// 特性：
// - 使用两个 Bank (Bank0: 偶数字, Bank1: 奇数字)
// - 支持单周期非对齐访存 (LB/LH/LW/LBU/LHU/SB/SH/SW)
// - 组合逻辑读取 + 时序逻辑输出（与原 dataram 相同时序）
// - 总容量 32KB (每个 Bank 16KB)
// - 支持流水线 stall 信号
//============================================================================
// 地址映射：
//   Word 0 -> Bank0[0]    Word 1 -> Bank1[0]
//   Word 2 -> Bank0[1]    Word 3 -> Bank1[1]
//   Word 4 -> Bank0[2]    Word 5 -> Bank1[2]
//   ...
//============================================================================

`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module dataram_banked (
    input clk,
    input rst,

    // 流水线控制
    input stall,  // stall 信号（保持状态）

    // CPU 接口（与原 dataram 兼容）
    input [31:0] ex_dataram_addr,   // 字节地址
    input [31:0] ex_dataram_wdata,  // 写数据
    input        ex_dataram_wen,    // 写使能
    input        ex_dataram_ren,    // 读使能
    input [ 7:0] ex_dataram_alucex, // Load/Store 类型

    // 输出
    output reg [31:0] dataram_wb_rdata,     // 读数据
    output     [31:0] tohost_value_dataram  // tohost 寄存器（仿真用）
);

  //==========================================================================
  // 参数定义
  //==========================================================================
  localparam BANK_ADDR_WIDTH = 12;  // 每个 Bank 4096 字 = 16KB
  localparam BANK_DEPTH = (1 << BANK_ADDR_WIDTH);

  //==========================================================================
  // Bank 存储器（使用 reg 数组，组合逻辑读取）
  //==========================================================================
  reg [31:0] bank0[0:BANK_DEPTH-1];  // 偶数字
  reg [31:0] bank1[0:BANK_DEPTH-1];  // 奇数字

  integer i;
  initial begin
    for (i = 0; i < BANK_DEPTH; i = i + 1) begin
      bank0[i] = 32'h0;
      bank1[i] = 32'h0;
    end
    // 如果需要加载初始数据，可以在这里添加
    // $readmemh("bank0.hex", bank0);
    // $readmemh("bank1.hex", bank1);
  end

  //==========================================================================
  // 地址计算
  //==========================================================================
  wire [               31:0] addr_offset = ex_dataram_addr - `PC_BASE_ADDR;
  wire [               17:0] word_addr = addr_offset[19:2];  // 字地址
  wire [                1:0] byte_offset = addr_offset[1:0];  // 字节偏移
  wire                       bank_sel = word_addr[0];  // 0=偶数字(Bank0), 1=奇数字(Bank1)

  // Bank 内地址
  wire [BANK_ADDR_WIDTH-1:0] inner_addr = word_addr[BANK_ADDR_WIDTH:1];

  // Bank0 和 Bank1 的访问地址
  // 当 bank_sel = 0: 当前字在 Bank0[inner_addr], 下一字在 Bank1[inner_addr]
  // 当 bank_sel = 1: 当前字在 Bank1[inner_addr], 下一字在 Bank0[inner_addr + 1]
  wire [BANK_ADDR_WIDTH-1:0] addr_bank0 = bank_sel ? (inner_addr + 1'b1) : inner_addr;
  wire [BANK_ADDR_WIDTH-1:0] addr_bank1 = inner_addr;

  //==========================================================================
  // 组合逻辑读取（与原 dataram 相同）
  //==========================================================================
  wire [               31:0] rdata_bank0 = bank0[addr_bank0];
  wire [               31:0] rdata_bank1 = bank1[addr_bank1];

  // 根据 bank_sel 排列数据
  // bank_sel = 0: 低位字 = Bank0, 高位字 = Bank1
  // bank_sel = 1: 低位字 = Bank1, 高位字 = Bank0
  wire [               31:0] word_lo = bank_sel ? rdata_bank1 : rdata_bank0;
  wire [               31:0] word_hi = bank_sel ? rdata_bank0 : rdata_bank1;
  wire [               63:0] combined_data = {word_hi, word_lo};
  wire [               63:0] shifted_data = combined_data >> (byte_offset * 8);

  // 提取各类型数据
  wire [                7:0] byte_data = shifted_data[7:0];
  wire [               15:0] half_data = shifted_data[15:0];
  wire [               31:0] word_data = shifted_data[31:0];

  //==========================================================================
  // 时序逻辑输出（与原 dataram 相同）
  //==========================================================================
  always @(posedge clk) begin
    if (!stall) begin
      if (ex_dataram_ren) begin
        case (ex_dataram_alucex)
          `LB_TYPE:  dataram_wb_rdata <= {{24{byte_data[7]}}, byte_data};
          `LH_TYPE:  dataram_wb_rdata <= {{16{half_data[15]}}, half_data};
          `LW_TYPE:  dataram_wb_rdata <= word_data;
          `LBU_TYPE: dataram_wb_rdata <= {24'b0, byte_data};
          `LHU_TYPE: dataram_wb_rdata <= {16'b0, half_data};
          default:   dataram_wb_rdata <= 32'b0;
        endcase
      end else begin
        dataram_wb_rdata <= 32'b0;
      end
    end
    // stall 时保持原值
  end

  //==========================================================================
  // 时序逻辑写入
  //==========================================================================
  always @(posedge clk) begin
    if (ex_dataram_wen && !stall) begin
      case (ex_dataram_alucex)
        //--------------------------------------------------------------
        // SB: 单字节写入，永不跨边界
        //--------------------------------------------------------------
        `SB_TYPE: begin
          if (!bank_sel) begin
            case (byte_offset)
              2'b00: bank0[inner_addr][7:0] <= ex_dataram_wdata[7:0];
              2'b01: bank0[inner_addr][15:8] <= ex_dataram_wdata[7:0];
              2'b10: bank0[inner_addr][23:16] <= ex_dataram_wdata[7:0];
              2'b11: bank0[inner_addr][31:24] <= ex_dataram_wdata[7:0];
            endcase
          end else begin
            case (byte_offset)
              2'b00: bank1[inner_addr][7:0] <= ex_dataram_wdata[7:0];
              2'b01: bank1[inner_addr][15:8] <= ex_dataram_wdata[7:0];
              2'b10: bank1[inner_addr][23:16] <= ex_dataram_wdata[7:0];
              2'b11: bank1[inner_addr][31:24] <= ex_dataram_wdata[7:0];
            endcase
          end
        end

        //--------------------------------------------------------------
        // SH: 半字写入，offset=3 时跨边界
        //--------------------------------------------------------------
        `SH_TYPE: begin
          if (!bank_sel) begin
            case (byte_offset)
              2'b00: bank0[inner_addr][15:0] <= ex_dataram_wdata[15:0];
              2'b01: bank0[inner_addr][23:8] <= ex_dataram_wdata[15:0];
              2'b10: bank0[inner_addr][31:16] <= ex_dataram_wdata[15:0];
              2'b11: begin
                bank0[inner_addr][31:24] <= ex_dataram_wdata[7:0];
                bank1[inner_addr][7:0]   <= ex_dataram_wdata[15:8];
              end
            endcase
          end else begin
            case (byte_offset)
              2'b00: bank1[inner_addr][15:0] <= ex_dataram_wdata[15:0];
              2'b01: bank1[inner_addr][23:8] <= ex_dataram_wdata[15:0];
              2'b10: bank1[inner_addr][31:16] <= ex_dataram_wdata[15:0];
              2'b11: begin
                bank1[inner_addr][31:24]    <= ex_dataram_wdata[7:0];
                bank0[inner_addr+1'b1][7:0] <= ex_dataram_wdata[15:8];
              end
            endcase
          end
        end

        //--------------------------------------------------------------
        // SW: 字写入，offset!=0 时跨边界
        //--------------------------------------------------------------
        `SW_TYPE: begin
          if (!bank_sel) begin
            case (byte_offset)
              2'b00: bank0[inner_addr] <= ex_dataram_wdata;
              2'b01: begin
                bank0[inner_addr][31:8] <= ex_dataram_wdata[23:0];
                bank1[inner_addr][7:0]  <= ex_dataram_wdata[31:24];
              end
              2'b10: begin
                bank0[inner_addr][31:16] <= ex_dataram_wdata[15:0];
                bank1[inner_addr][15:0]  <= ex_dataram_wdata[31:16];
              end
              2'b11: begin
                bank0[inner_addr][31:24] <= ex_dataram_wdata[7:0];
                bank1[inner_addr][23:0]  <= ex_dataram_wdata[31:8];
              end
            endcase
          end else begin
            case (byte_offset)
              2'b00: bank1[inner_addr] <= ex_dataram_wdata;
              2'b01: begin
                bank1[inner_addr][31:8]     <= ex_dataram_wdata[23:0];
                bank0[inner_addr+1'b1][7:0] <= ex_dataram_wdata[31:24];
              end
              2'b10: begin
                bank1[inner_addr][31:16]     <= ex_dataram_wdata[15:0];
                bank0[inner_addr+1'b1][15:0] <= ex_dataram_wdata[31:16];
              end
              2'b11: begin
                bank1[inner_addr][31:24]     <= ex_dataram_wdata[7:0];
                bank0[inner_addr+1'b1][23:0] <= ex_dataram_wdata[31:8];
              end
            endcase
          end
        end
      endcase
    end
  end

  //==========================================================================
  // tohost 寄存器（用于仿真测试）
  //==========================================================================
  // tohost 地址: 0x80001000
  // word_addr = (0x80001000 - 0x80000000) / 4 = 0x400 = 1024
  // 1024 是偶数，在 Bank0，inner_addr = 512
  assign tohost_value_dataram = bank0[512];

endmodule

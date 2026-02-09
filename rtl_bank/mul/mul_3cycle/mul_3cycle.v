`timescale 1ns / 1ps

// ============================================================================
// 3周期乘法器模块
// 基于 Booth Radix-4 编码的流水线乘法器
//
// 周期1: Booth编码 + 第一层4:2压缩
// 周期2: 第二层4:2压缩 + 第三层4:2压缩
// 周期3: 全加器 + 最终加法
// ============================================================================

module mul_3cycle (
    input         clk,
    input         rst_n,
    input  [31:0] mul_a_i,
    input  [31:0] mul_b_i,
    input         mul_a_sign,
    input         mul_b_sign,
    input         mul_start,   // 启动信号
    output [63:0] mul_result,
    output        mul_done,    // 完成信号
    output        mul_busy     // 忙碌信号
);

  // ============================================================================
  // 状态机定义
  // ============================================================================
  localparam IDLE = 2'b00;
  localparam CYCLE1 = 2'b01;
  localparam CYCLE2 = 2'b10;
  localparam CYCLE3 = 2'b11;

  reg [1:0] state, next_state;

  // ============================================================================
  // 第一周期：Booth编码 + 第一层4:2压缩
  // ============================================================================

  // Booth编码输出（17个部分积）
  wire [67:0] pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9;
  wire [67:0] pp10, pp11, pp12, pp13, pp14, pp15, pp16, pp17;

  // 第一层压缩输出
  wire [68:0] out11, out12, out21, out22, out31, out32, out41, out42;

  // Booth编码模块
  booth booth1 (
      .a_sign (mul_a_sign),
      .b_sign (mul_b_sign),
      .i_multa(mul_a_i),
      .i_multb(mul_b_i),
      .o_pp1  (pp1),
      .o_pp2  (pp2),
      .o_pp3  (pp3),
      .o_pp4  (pp4),
      .o_pp5  (pp5),
      .o_pp6  (pp6),
      .o_pp7  (pp7),
      .o_pp8  (pp8),
      .o_pp9  (pp9),
      .o_pp10 (pp10),
      .o_pp11 (pp11),
      .o_pp12 (pp12),
      .o_pp13 (pp13),
      .o_pp14 (pp14),
      .o_pp15 (pp15),
      .o_pp16 (pp16),
      .o_pp17 (pp17)
  );

  // 第一层4:2压缩器（4个并行）
  wire cout_dummy;

  compress compress1 (
      .in1 (pp1),
      .in2 (pp2),
      .in3 (pp3),
      .in4 (pp4),
      .cin (1'b0),
      .out1(out11),
      .out2(out12),
      .cout(cout_dummy)
  );

  compress compress2 (
      .in1 (pp5),
      .in2 (pp6),
      .in3 (pp7),
      .in4 (pp8),
      .cin (1'b0),
      .out1(out21),
      .out2(out22),
      .cout(cout_dummy)
  );

  compress compress3 (
      .in1 (pp9),
      .in2 (pp10),
      .in3 (pp11),
      .in4 (pp12),
      .cin (1'b0),
      .out1(out31),
      .out2(out32),
      .cout(cout_dummy)
  );

  compress compress4 (
      .in1 (pp13),
      .in2 (pp14),
      .in3 (pp15),
      .in4 (pp16),
      .cin (1'b0),
      .out1(out41),
      .out2(out42),
      .cout(cout_dummy)
  );

  // ============================================================================
  // 流水线寄存器1：保存第一周期结果
  // ============================================================================
  reg [68:0] stage1_out11, stage1_out12;
  reg [68:0] stage1_out21, stage1_out22;
  reg [68:0] stage1_out31, stage1_out32;
  reg [68:0] stage1_out41, stage1_out42;
  reg [67:0] stage1_pp17;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage1_out11 <= 69'b0;
      stage1_out12 <= 69'b0;
      stage1_out21 <= 69'b0;
      stage1_out22 <= 69'b0;
      stage1_out31 <= 69'b0;
      stage1_out32 <= 69'b0;
      stage1_out41 <= 69'b0;
      stage1_out42 <= 69'b0;
      stage1_pp17  <= 68'b0;
    end else if (state == CYCLE1) begin
      stage1_out11 <= out11;
      stage1_out12 <= out12;
      stage1_out21 <= out21;
      stage1_out22 <= out22;
      stage1_out31 <= out31;
      stage1_out32 <= out32;
      stage1_out41 <= out41;
      stage1_out42 <= out42;
      stage1_pp17  <= pp17;
    end
  end

  // ============================================================================
  // 第二周期：第二层4:2压缩 + 第三层4:2压缩
  // ============================================================================

  // 移位操作（组合逻辑）
  wire [67:0] out13, out14, out23, out24, out33, out34, out43, out44;
  assign out13 = stage1_out11[67:0] << 1;
  assign out14 = stage1_out12[67:0];
  assign out23 = stage1_out21[67:0] << 1;
  assign out24 = stage1_out22[67:0];
  assign out33 = stage1_out31[67:0] << 1;
  assign out34 = stage1_out32[67:0];
  assign out43 = stage1_out41[67:0] << 1;
  assign out44 = stage1_out42[67:0];

  // 第二层4:2压缩器（2个并行）
  wire [68:0] out51, out52, out61, out62;

  compress compress5 (
      .in1 (out13),
      .in2 (out14),
      .in3 (out23),
      .in4 (out24),
      .cin (1'b0),
      .out1(out51),
      .out2(out52),
      .cout(cout_dummy)
  );

  compress compress6 (
      .in1 (out33),
      .in2 (out34),
      .in3 (out43),
      .in4 (out44),
      .cin (1'b0),
      .out1(out61),
      .out2(out62),
      .cout(cout_dummy)
  );

  // 移位操作
  wire [67:0] out53, out54, out63, out64;
  assign out53 = out51[67:0] << 1;
  assign out54 = out52[67:0];
  assign out63 = out61[67:0] << 1;
  assign out64 = out62[67:0];

  // 第三层4:2压缩器（1个）
  wire [68:0] out71, out72;

  compress compress7 (
      .in1 (out53),
      .in2 (out54),
      .in3 (out63),
      .in4 (out64),
      .cin (1'b0),
      .out1(out71),
      .out2(out72),
      .cout(cout_dummy)
  );

  // ============================================================================
  // 流水线寄存器2：保存第二周期结果
  // ============================================================================
  reg [68:0] stage2_out71, stage2_out72;
  reg [67:0] stage2_pp17;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage2_out71 <= 69'b0;
      stage2_out72 <= 69'b0;
      stage2_pp17  <= 68'b0;
    end else if (state == CYCLE2) begin
      stage2_out71 <= out71;
      stage2_out72 <= out72;
      stage2_pp17  <= stage1_pp17;
    end
  end

  // ============================================================================
  // 第三周期：全加器 + 最终加法
  // ============================================================================

  // 移位操作
  wire [67:0] out73, out74;
  assign out73 = stage2_out71[67:0] << 1;
  assign out74 = stage2_out72[67:0];

  // 全加器（3:2压缩）
  wire [67:0] re1, re2;

  full_adder full_adder1 (
      .a (out73),
      .b (out74),
      .ci(stage2_pp17),
      .s (re1),
      .co(re2)
  );

  // 最终加法
  wire [67:0] mul_result_full;
  assign mul_result_full = re1 + re2;

  // ============================================================================
  // 输出寄存器
  // ============================================================================
  reg [63:0] result_reg;
  reg        done_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result_reg <= 64'b0;
      done_reg   <= 1'b0;
    end else if (state == CYCLE3) begin
      result_reg <= mul_result_full[63:0];
      done_reg   <= 1'b1;
    end else begin
      done_reg <= 1'b0;
    end
  end

  assign mul_result = result_reg;
  assign mul_done   = done_reg;
  assign mul_busy   = (state != IDLE);

  // ============================================================================
  // 状态机
  // ============================================================================

  // 状态转移
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // 次态逻辑
  always @(*) begin
    case (state)
      IDLE: begin
        if (mul_start) next_state = CYCLE1;
        else next_state = IDLE;
      end

      CYCLE1: begin
        next_state = CYCLE2;
      end

      CYCLE2: begin
        next_state = CYCLE3;
      end

      CYCLE3: begin
        next_state = IDLE;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule

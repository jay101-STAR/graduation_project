module div (
    input  wire        clk,
    input  wire        rst,
    input  wire        div_sign,
    input  wire        div_start,
    input  wire [31:0] dividend,
    input  wire [31:0] divisor,

    output reg  [31:0] div_result_q,
    output reg  [31:0] div_result_r,
    output reg         div_done,
    output reg         div_busy
);

  localparam IDLE = 2'b00;
  localparam WORK = 2'b01;
  localparam DONE = 2'b10;

  reg [63:0] dividend_extended;
  reg [31:0] divisor_reg;
  // reg [31:0] dividend_reg; // 【优化】删除此寄存器，节省资源
  reg [ 5:0] cnt;
  reg [1:0]  current_state, next_state;

  reg sign_q;
  reg sign_r;
  reg div_sign_reg;
  reg is_div_by_zero;
  reg is_overflow;

  // 输入预处理
  wire op1_is_neg = div_sign && dividend[31];
  wire op2_is_neg = div_sign && divisor[31];

  wire [31:0] op1_abs_dividend = op1_is_neg ? (~dividend + 1'b1) : dividend;
  wire [31:0] op2_abs_divisor  = op2_is_neg ? (~divisor  + 1'b1) : divisor;

  // 核心计算
  wire [63:0] shift_dividend_extended = {dividend_extended[62:0], 1'b0};
  wire [32:0] sub_result = {1'b0, shift_dividend_extended[63:32]} - {1'b0, divisor_reg};
  wire is_enough = ~sub_result[32];

  // 【新增】通用结果恢复逻辑
  // 无论是正常计算结束，还是除以0异常，都可以用这个逻辑恢复数据
  // 正常结束时：abs_val 是 dividend_extended[31:0] (商) 或 [63:32] (余)
  // 除以0时  ：abs_val 是 dividend_extended[31:0] (被除数绝对值)
  function [31:0] recover_val;
    input [31:0] abs_val;
    input        sign;
    begin
      recover_val = sign ? (~abs_val + 1'b1) : abs_val;
    end
  endfunction

  // Unsigned helper: power-of-two test.
  function is_pow2_32;
    input [31:0] val;
    begin
      is_pow2_32 = (val != 32'b0) && ((val & (val - 1'b1)) == 32'b0);
    end
  endfunction

  // Unsigned helper: count trailing zeros for power-of-two divisors.
  function [4:0] ctz32;
    input [31:0] val;
    integer i;
    begin : ctz32_loop
      ctz32 = 5'd0;
      for (i = 0; i < 32; i = i + 1) begin
        if (val[i]) begin
          ctz32 = i[4:0];
          disable ctz32_loop;
        end
      end
    end
  endfunction

  // 状态机
  always @(posedge clk) begin
    if (rst) current_state <= IDLE;
    else     current_state <= next_state;
  end

  always @(*) begin
    next_state = current_state;
    case (current_state)
      IDLE: if (div_start) next_state = WORK; else next_state = IDLE;
      WORK: if (div_done)  next_state = DONE; else next_state = WORK;
      DONE: next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      div_done          <= 1'b0;
      div_busy          <= 1'b0;
      div_result_q      <= 32'b0;
      div_result_r      <= 32'b0;
      cnt               <= 6'b0;
      dividend_extended <= 64'b0;
      divisor_reg       <= 32'b0;
      sign_q            <= 1'b0;
      sign_r            <= 1'b0;
      div_sign_reg      <= 1'b0;
      is_div_by_zero    <= 1'b0;
      is_overflow       <= 1'b0;
    end else begin
      case (current_state)
        IDLE: begin
          div_done <= 1'b0;
          if (div_start) begin
            div_busy          <= 1'b1;
            cnt               <= 6'b0;
            // 锁存绝对值
            dividend_extended <= {32'b0, op1_abs_dividend};
            divisor_reg       <= op2_abs_divisor;
            sign_q            <= op1_is_neg ^ op2_is_neg;
            sign_r            <= op1_is_neg;
            div_sign_reg      <= div_sign;
            // dividend_reg   <= dividend; // 删除

            // 异常判断
            if (divisor == 0)
                is_div_by_zero <= 1'b1;
            else
                is_div_by_zero <= 1'b0;

            if (div_sign && (dividend == 32'h80000000) && (divisor == 32'hFFFFFFFF))
                is_overflow <= 1'b1;
            else
                is_overflow <= 1'b0;

          end else begin
            div_busy <= 1'b0;
          end
        end

        WORK: begin
          // ----------------------------------------------------
          // 情况 1: 除以 0 (返回 -1 和 原始被除数)
          // ----------------------------------------------------
          if (is_div_by_zero) begin
            div_result_q <= 32'hFFFFFFFF;
            // 【修复Bug并优化】
            // 此时 dividend_extended[31:0] 存的是 abs(dividend)
            // 利用 recover_val 函数和 sign_r 恢复出原始被除数
            div_result_r <= recover_val(dividend_extended[31:0], sign_r);
            div_done <= 1'b1;
          end
          // ----------------------------------------------------
          // 情况 2: 溢出 (返回 被除数 和 0)
          // ----------------------------------------------------
          else if (is_overflow) begin
            div_result_q <= 32'h80000000;
            div_result_r <= 32'b0;
            div_done     <= 1'b1;
          end
          // ----------------------------------------------------
          // 情况 3: Early-out (无需完整 32 次迭代)
          // ----------------------------------------------------
          else if ((cnt == 6'd0) && (divisor_reg == 32'd1)) begin
            // q = dividend, r = 0 (signed/unsigned 都成立；INT_MIN/-1 已由 overflow 处理)
            div_result_q <= recover_val(dividend_extended[31:0], sign_q);
            div_result_r <= 32'b0;
            div_done     <= 1'b1;
          end else if ((cnt == 6'd0) && (dividend_extended[31:0] < divisor_reg)) begin
            // |dividend| < |divisor| => q = 0, r = dividend
            div_result_q <= 32'b0;
            div_result_r <= recover_val(dividend_extended[31:0], sign_r);
            div_done     <= 1'b1;
          end else if ((cnt == 6'd0) && !div_sign_reg && is_pow2_32(divisor_reg)) begin
            // DIVU/REMU 且除数为 2 的幂：移位与掩码快速返回
            div_result_q <= dividend_extended[31:0] >> ctz32(divisor_reg);
            div_result_r <= dividend_extended[31:0] & (divisor_reg - 32'd1);
            div_done     <= 1'b1;
          end
          // ----------------------------------------------------
          // 情况 4: 正常计算完成
          // ----------------------------------------------------
          else if (cnt == 6'd32) begin
            div_done     <= 1'b1;
            // 使用函数处理符号恢复，逻辑更清晰
            div_result_q <= recover_val(dividend_extended[31:0], sign_q);
            div_result_r <= recover_val(dividend_extended[63:32], sign_r);
          end
          // ----------------------------------------------------
          // 情况 5: 计算中
          // ----------------------------------------------------
          else begin
            cnt <= cnt + 1;
            if (is_enough)
              dividend_extended <= {sub_result[31:0], shift_dividend_extended[31:1], 1'b1};
            else
              dividend_extended <= shift_dividend_extended;
          end
        end

        DONE: begin
          div_busy <= 1'b0;
          div_done <= 1'b0;
        end
        default: ;
      endcase
    end
  end

endmodule

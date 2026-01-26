module driver_ctrl (
    input  wire        mclk,     // 100MHz MCLK
    input  wire        rst_n,    // 复位
    // 用户接口
    input  wire        req,      // 发起请求
    input  wire        rw_type,  // 0: Write, 1: Read
    input  wire [15:0] addr_in,  // 目标地址
    input  wire [15:0] data_wr,  // 待写入数据
    output reg  [15:0] data_rd,  // 读回的数据
    output reg         busy,     // 总线忙标志
    output reg         done,     // 操作完成标志

    // 物理接口 (连接到芯片)
    output reg         CS_AS,
    output reg         CS_RW_B,
    inout  wire [15:0] CS_AD
);

  // 状态定义
  localparam S_IDLE = 3'd0;
  localparam S_ADDR = 3'd1;
  localparam S_WRITE = 3'd2;
  localparam S_READ_WAIT = 3'd3;
  localparam S_READ_LATCH = 3'd4;

  reg [2:0] state, next_state;
  reg [ 3:0] wait_cnt;  // 用于读延迟计数
  reg [15:0] ad_out_reg;  // 用于输出到总线的寄存器
  reg        link_ad;  // 三态门控制：1=输出, 0=高阻输入

  // 三态门逻辑 (关键点)
  assign CS_AD = (link_ad) ? ad_out_reg : 16'hzzzz;

  // 状态机第一段：状态跳转
  always @(posedge mclk or negedge rst_n) begin
    if (!rst_n) state <= S_IDLE;
    else state <= next_state;
  end

  // 状态机第二段：状态逻辑
  always @(*) begin
    next_state = S_IDLE;
    case (state)
      S_IDLE: begin
        if (req) next_state = S_ADDR;
        else next_state = S_IDLE;
      end

      S_ADDR: begin
        if (CS_RW_B == 1'b0)  // 写操作
          next_state = S_WRITE;
        else  // 读操作
          next_state = S_READ_WAIT;
      end

      S_WRITE: begin
        next_state = S_IDLE;  // 写完直接结束
      end

      S_READ_WAIT: begin
        // 题目要求：1 cycle Turn-around + 8 cycles Delay = 9 cycles total
        if (wait_cnt >= 4'd8) next_state = S_READ_LATCH;
        else next_state = S_READ_WAIT;
      end

      S_READ_LATCH: begin
        next_state = S_IDLE;
      end

      default: next_state = S_IDLE;
    endcase
  end

  // 状态机第三段：输出逻辑与计数器
  always @(posedge mclk or negedge rst_n) begin
    if (!rst_n) begin
      CS_AS      <= 1'b0;
      CS_RW_B    <= 1'b1;  // 默认读状态安全
      link_ad    <= 1'b0;
      ad_out_reg <= 16'd0;
      data_rd    <= 16'd0;
      wait_cnt   <= 4'd0;
      busy       <= 1'b0;
      done       <= 1'b0;
    end else begin
      // 默认信号
      done <= 1'b0;

      case (state)
        S_IDLE: begin
          busy    <= 1'b0;
          CS_AS   <= 1'b0;
          link_ad <= 1'b0;  // 释放总线
          if (req) begin
            busy       <= 1'b1;
            CS_AS      <= 1'b1;  // 拉高AS
            CS_RW_B    <= rw_type;  // 设置读写方向
            ad_out_reg <= addr_in;  // 输出地址
            link_ad    <= 1'b1;  // 打开输出驱动
            wait_cnt   <= 4'd0;  // 清零计数器
          end
        end

        S_ADDR: begin
          CS_AS <= 1'b0;  // 拉低AS，进入数据阶段
          if (CS_RW_B == 1'b0) begin
            // Write: 输出数据
            ad_out_reg <= data_wr;
            link_ad    <= 1'b1;
          end else begin
            // Read: 释放总线
            link_ad  <= 1'b0;
            wait_cnt <= 4'd0;
          end
        end

        S_WRITE: begin
          done    <= 1'b1;  // 标记完成
          link_ad <= 1'b0;  // 释放总线
        end

        S_READ_WAIT: begin
          wait_cnt <= wait_cnt + 1'b1;
        end

        S_READ_LATCH: begin
          data_rd <= CS_AD;  // 采样总线数据
          done    <= 1'b1;
        end
      endcase
    end
  end

endmodule

`timescale 1ns / 1ns

// Simple UART transmitter (8N1):
// - Idle high
// - 1 start bit (0), 8 data bits (LSB first), 1 stop bit (1)
module uart_tx #(
    parameter integer CLK_FREQ_HZ = 50000000,
    parameter integer BAUD_RATE = 115200
) (
    input clk,
    input rst,
    input       tx_valid,
    input [7:0] tx_data,
    output      tx_ready,
    output reg  uart_txd
);

  localparam integer BAUD_DIV = ((CLK_FREQ_HZ / BAUD_RATE) > 0) ? (CLK_FREQ_HZ / BAUD_RATE) : 1;
  localparam integer BAUD_CNT_WIDTH = (BAUD_DIV <= 1) ? 1 : $clog2(BAUD_DIV);
  localparam [BAUD_CNT_WIDTH-1:0] BAUD_DIV_LAST = BAUD_CNT_WIDTH'(BAUD_DIV - 1);

  reg [BAUD_CNT_WIDTH-1:0] baud_cnt;
  reg [3:0] bit_cnt;
  reg [9:0] tx_shift_reg;
  reg tx_busy;

  wire baud_tick = (baud_cnt == BAUD_DIV_LAST);

  assign tx_ready = !tx_busy;

  always @(posedge clk) begin
    if (rst) begin
      baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
      bit_cnt <= 4'b0;
      tx_shift_reg <= 10'h3ff;
      tx_busy <= 1'b0;
      uart_txd <= 1'b1;
    end else begin
      if (!tx_busy) begin
        // Line stays high when idle.
        uart_txd <= 1'b1;
        baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
        bit_cnt <= 4'b0;

        if (tx_valid) begin
          // Load frame and drive start bit immediately.
          tx_shift_reg <= {1'b1, tx_data, 1'b0};
          tx_busy <= 1'b1;
          uart_txd <= 1'b0;
        end
      end else begin
        if (baud_tick) begin
          baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};

          if (bit_cnt == 4'd9) begin
            // Stop bit is done, return to idle.
            tx_busy <= 1'b0;
            uart_txd <= 1'b1;
          end else begin
            bit_cnt <= bit_cnt + 1'b1;
            tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
            uart_txd <= tx_shift_reg[1];
          end
        end else begin
          baud_cnt <= baud_cnt + 1'b1;
        end
      end
    end
  end

endmodule

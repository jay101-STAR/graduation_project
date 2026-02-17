`timescale 1ns / 1ns

// Simple UART receiver (8N1, LSB first):
// - Idle high
// - Start bit(0) detect
// - Mid-bit sampling for start/data/stop bits
module uart_rx #(
    parameter integer CLK_FREQ_HZ = 50000000,
    parameter integer BAUD_RATE = 115200
) (
    input             clk,
    input             rst,
    input             uart_rxd,
    output reg [7:0]  rx_data,
    output reg        rx_valid,
    output reg        rx_frame_error
);

  localparam integer BAUD_DIV = ((CLK_FREQ_HZ / BAUD_RATE) > 0) ? (CLK_FREQ_HZ / BAUD_RATE) : 1;
  localparam integer BAUD_CNT_WIDTH = (BAUD_DIV <= 1) ? 1 : $clog2(BAUD_DIV);
  localparam [BAUD_CNT_WIDTH-1:0] BAUD_DIV_LAST = BAUD_CNT_WIDTH'(BAUD_DIV - 1);
  localparam [BAUD_CNT_WIDTH-1:0] HALF_BAUD_DIV = BAUD_CNT_WIDTH'(BAUD_DIV / 2);

  localparam [1:0] RX_IDLE = 2'b00;
  localparam [1:0] RX_START = 2'b01;
  localparam [1:0] RX_DATA = 2'b10;
  localparam [1:0] RX_STOP = 2'b11;

  reg [1:0] rx_state;
  reg [BAUD_CNT_WIDTH-1:0] baud_cnt;
  reg [2:0] bit_cnt;
  reg [7:0] rx_shift;

  reg uart_rxd_meta;
  reg uart_rxd_sync;

  always @(posedge clk) begin
    if (rst) begin
      uart_rxd_meta <= 1'b1;
      uart_rxd_sync <= 1'b1;
    end else begin
      uart_rxd_meta <= uart_rxd;
      uart_rxd_sync <= uart_rxd_meta;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      rx_state <= RX_IDLE;
      baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
      bit_cnt <= 3'b0;
      rx_shift <= 8'b0;
      rx_data <= 8'b0;
      rx_valid <= 1'b0;
      rx_frame_error <= 1'b0;
    end else begin
      rx_valid <= 1'b0;

      case (rx_state)
        RX_IDLE: begin
          baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
          bit_cnt <= 3'b0;
          // Detect start edge (line goes low).
          if (!uart_rxd_sync) begin
            rx_state <= RX_START;
          end
        end

        RX_START: begin
          // Sample start bit at middle of bit period.
          if (baud_cnt == HALF_BAUD_DIV) begin
            if (!uart_rxd_sync) begin
              rx_state <= RX_DATA;
              baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
              bit_cnt <= 3'b0;
            end else begin
              // False start, return to idle.
              rx_state <= RX_IDLE;
            end
          end else begin
            baud_cnt <= baud_cnt + 1'b1;
          end
        end

        RX_DATA: begin
          if (baud_cnt == BAUD_DIV_LAST) begin
            baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
            rx_shift <= {uart_rxd_sync, rx_shift[7:1]};
            if (bit_cnt == 3'd7) begin
              rx_state <= RX_STOP;
            end else begin
              bit_cnt <= bit_cnt + 1'b1;
            end
          end else begin
            baud_cnt <= baud_cnt + 1'b1;
          end
        end

        RX_STOP: begin
          if (baud_cnt == BAUD_DIV_LAST) begin
            baud_cnt <= {BAUD_CNT_WIDTH{1'b0}};
            rx_state <= RX_IDLE;
            // Stop bit should be high.
            if (uart_rxd_sync) begin
              rx_data <= rx_shift;
              rx_valid <= 1'b1;
              rx_frame_error <= 1'b0;
            end else begin
              rx_frame_error <= 1'b1;
            end
          end else begin
            baud_cnt <= baud_cnt + 1'b1;
          end
        end

        default: begin
          rx_state <= RX_IDLE;
        end
      endcase
    end
  end

endmodule

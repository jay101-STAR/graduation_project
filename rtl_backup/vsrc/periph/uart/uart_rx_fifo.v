`timescale 1ns / 1ns

// Simple synchronous FIFO for UART RX path.
// - Single clock domain
// - Push request is ignored when full (unless pop happens in same cycle)
// - Pop request is ignored when empty
module uart_rx_fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH = 4
) (
    input                       clk,
    input                       rst,
    input                       push,
    input      [DATA_WIDTH-1:0] push_data,
    input                       pop,
    output     [DATA_WIDTH-1:0] pop_data,
    output                      full,
    output                      empty
);

  localparam integer AW = (DEPTH <= 2) ? 1 : $clog2(DEPTH);
  localparam [AW-1:0] LAST_PTR = AW'(DEPTH - 1);
  localparam [AW:0] DEPTH_COUNT = (AW + 1)'(DEPTH);

  reg [DATA_WIDTH-1:0] mem[0:DEPTH-1];
  reg [AW-1:0] wptr;
  reg [AW-1:0] rptr;
  reg [AW:0] count;

  wire do_pop = pop && (count != {(AW + 1) {1'b0}});
  wire do_push = push && ((count != DEPTH_COUNT) || do_pop);

  assign empty = (count == {(AW + 1) {1'b0}});
  assign full = (count == DEPTH_COUNT);
  assign pop_data = mem[rptr];

  always @(posedge clk) begin
    if (rst) begin
      wptr  <= {AW{1'b0}};
      rptr  <= {AW{1'b0}};
      count <= {(AW + 1) {1'b0}};
    end else begin
      if (do_push) begin
        mem[wptr] <= push_data;
        if (wptr == LAST_PTR) begin
          wptr <= {AW{1'b0}};
        end else begin
          wptr <= wptr + 1'b1;
        end
      end

      if (do_pop) begin
        if (rptr == LAST_PTR) begin
          rptr <= {AW{1'b0}};
        end else begin
          rptr <= rptr + 1'b1;
        end
      end

      case ({do_push, do_pop})
        2'b10: count <= count + 1'b1;
        2'b01: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end

endmodule


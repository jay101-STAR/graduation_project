// Test-only one-entry channel queue. Once VALID is offered it stays asserted
// with the same payload until READY; independent seeds perturb all channels.
module axi4_channel_delay #(
    parameter integer WIDTH = 1,
    parameter integer CHANNEL = 1
) (
    input clk, input rst,
    input [WIDTH-1:0] in_data, input in_valid, output in_ready,
    output [WIDTH-1:0] out_data, output out_valid, input out_ready
);
  integer max_delay = 0, seed = 1;
  reg full;
  reg [WIDTH-1:0] payload;
  reg [3:0] wait_left;
  reg [15:0] lfsr;
  initial begin
    if ($value$plusargs("handshake_delay=%d", max_delay)) begin end
    if ($value$plusargs("handshake_seed=%d", seed)) begin end
    if (max_delay < 0 || max_delay > 15 || seed == 0) $fatal(1, "Invalid AXI delay/seed");
  end
  assign in_ready = !rst && (max_delay == 0 ? out_ready : !full);
  assign out_valid = !rst && (max_delay == 0 ? in_valid : (full && wait_left == 0));
  assign out_data = max_delay == 0 ? in_data : payload;
  always @(posedge clk) begin
    if (rst) begin
      full <= 0; payload <= 0; wait_left <= 0;
      lfsr <= 16'(seed) ^ 16'(CHANNEL*16'h1237) ^ 16'hb400;
    end else if (max_delay != 0) begin
      lfsr <= {lfsr[14:0], lfsr[15]^lfsr[13]^lfsr[12]^lfsr[10]};
      if (full && wait_left != 0) wait_left <= wait_left - 1'b1;
      if (in_valid && in_ready) begin
        full <= 1;
        payload <= in_data;
        wait_left <= 4'(int'(lfsr) % (max_delay+1));
      end
      if (out_valid && out_ready) full <= 0;
    end
  end
endmodule

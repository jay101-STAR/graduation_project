// Test-only protocol-preserving delay layer. The runner renames the real
// adapter to mem_req_adapter_impl and compiles this wrapper in its place.
module mem_req_adapter #(
    parameter ID_WIDTH = 4
) (
    input clk, input rst,
    input req_valid, output req_ready,
    input [ID_WIDTH-1:0] req_id,
    input [31:0] req_addr, input req_write,
    input [31:0] req_wdata, input [7:0] req_alucex,
    output rsp_valid, input rsp_ready,
    output [ID_WIDTH-1:0] rsp_id,
    output [31:0] rsp_rdata, output rsp_error,
    output [31:0] rsp_fault_addr,
    output backend_start, output [31:0] backend_addr,
    output backend_write, output [31:0] backend_wdata,
    output [7:0] backend_alucex,
    input backend_busy, input [31:0] backend_rdata, input backend_error,
    input [31:0] backend_fault_addr
);
  integer max_delay = 0;
  integer seed = 1;
  reg [15:0] lfsr;
  reg [3:0] request_wait, response_wait;
  wire inner_req_ready, inner_rsp_valid;
  wire request_open = (request_wait == 0);
  wire response_open = (response_wait == 0);

  initial begin
    if ($value$plusargs("handshake_delay=%d", max_delay)) begin end
    if ($value$plusargs("handshake_seed=%d", seed)) begin end
    if (max_delay < 0 || max_delay > 15 || seed == 0)
      $fatal(1, "Invalid handshake delay/seed");
  end

  assign req_ready = inner_req_ready && request_open;
  assign rsp_valid = inner_rsp_valid && response_open;

  mem_req_adapter_impl #(.ID_WIDTH(ID_WIDTH)) endpoint (
      .clk(clk), .rst(rst),
      .req_valid(req_valid && request_open), .req_ready(inner_req_ready),
      .req_id(req_id), .req_addr(req_addr), .req_write(req_write),
      .req_wdata(req_wdata), .req_alucex(req_alucex),
      .rsp_valid(inner_rsp_valid), .rsp_ready(rsp_ready && response_open),
      .rsp_id(rsp_id), .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
      .rsp_fault_addr(rsp_fault_addr),
      .backend_start(backend_start), .backend_addr(backend_addr),
      .backend_write(backend_write), .backend_wdata(backend_wdata),
      .backend_alucex(backend_alucex), .backend_busy(backend_busy),
      .backend_rdata(backend_rdata), .backend_error(backend_error),
      .backend_fault_addr(backend_fault_addr)
  );

  always @(posedge clk) begin
    if (rst) begin
      lfsr <= 16'(seed);
      request_wait <= 4'(max_delay);
      response_wait <= 4'(max_delay);
    end else begin
      lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
      if (req_valid && request_wait != 0) request_wait <= request_wait - 1'b1;
      if (inner_rsp_valid && response_wait != 0) response_wait <= response_wait - 1'b1;
      if (req_valid && req_ready) request_wait <= 4'(int'(lfsr[3:0]) % (max_delay + 1));
      if (rsp_valid && rsp_ready) response_wait <= 4'(int'(lfsr[7:4]) % (max_delay + 1));
    end
  end
endmodule

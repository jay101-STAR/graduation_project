// Test-only wait injection at the shared native word boundary. Production
// RTL has no random-delay logic; zero delay preserves its cycle timing.
module axi_lite_master (
    input clk, input rst,
    input req_valid, output req_ready,
    input [31:0] req_addr, input req_write,
    input [31:0] req_wdata, input [3:0] req_wstrb,
    output rsp_valid, input rsp_ready, output [31:0] rsp_rdata, output rsp_error,
    output [31:0] m_axi_awaddr, output [2:0] m_axi_awprot,
    output m_axi_awvalid, input m_axi_awready,
    output [31:0] m_axi_wdata, output [3:0] m_axi_wstrb,
    output m_axi_wvalid, input m_axi_wready,
    input [1:0] m_axi_bresp, input m_axi_bvalid, output m_axi_bready,
    output [31:0] m_axi_araddr, output [2:0] m_axi_arprot,
    output m_axi_arvalid, input m_axi_arready,
    input [31:0] m_axi_rdata, input [1:0] m_axi_rresp,
    input m_axi_rvalid, output m_axi_rready
);
  integer max_delay = 0, seed = 1;
  reg [15:0] lfsr;
  reg [3:0] request_wait, response_wait;
  wire inner_req_ready, inner_rsp_valid;
  wire request_open = (request_wait == 0);
  wire response_open = (response_wait == 0);
  initial begin
    if ($value$plusargs("handshake_delay=%d", max_delay)) begin end
    if ($value$plusargs("handshake_seed=%d", seed)) begin end
    if (max_delay < 0 || max_delay > 15 || seed == 0) $fatal(1, "Invalid handshake delay/seed");
  end
  assign req_ready = inner_req_ready && request_open;
  assign rsp_valid = inner_rsp_valid && response_open;
  axi_lite_master_impl endpoint (
      .clk(clk), .rst(rst),
      .req_valid(req_valid && request_open), .req_ready(inner_req_ready),
      .req_addr(req_addr), .req_write(req_write), .req_wdata(req_wdata), .req_wstrb(req_wstrb),
      .rsp_valid(inner_rsp_valid), .rsp_ready(rsp_ready && response_open),
      .rsp_rdata(rsp_rdata), .rsp_error(rsp_error),
      .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot),
      .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
      .m_axi_wdata(m_axi_wdata), .m_axi_wstrb(m_axi_wstrb),
      .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
      .m_axi_bresp(m_axi_bresp), .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
      .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot),
      .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
      .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp),
      .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
  );
  always @(posedge clk) begin
    if (rst) begin
      lfsr <= 16'(seed) ^ 16'hb400;
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

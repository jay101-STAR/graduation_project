`timescale 1ns / 1ns

// Native word request/response bridge, one transaction outstanding. A new
// request can replace a consumed response at the same edge. Idle requests
// drive AXI immediately; only channels blocked by READY need saved payload.
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
  reg active, saved_write, aw_done, w_done, ar_done;
  reg [31:0] saved_addr, saved_wdata;
  reg [3:0] saved_wstrb;
  wire rsp_fire = rsp_valid && rsp_ready;
  wire available = !active || rsp_fire;
  wire offer = req_valid && req_ready;
  assign req_ready = !rst && available;
  assign rsp_valid = !rst && active && (saved_write ?
      (aw_done && w_done && m_axi_bvalid) : (ar_done && m_axi_rvalid));
  assign rsp_rdata = saved_write ? 32'b0 : m_axi_rdata;
  assign rsp_error = saved_write ? (m_axi_bresp != 2'b00) : (m_axi_rresp != 2'b00);
  assign m_axi_rready = !rst && active && !saved_write && ar_done && rsp_ready;
  assign m_axi_bready = !rst && active && saved_write && aw_done && w_done && rsp_ready;
  assign m_axi_awaddr = available ? req_addr : saved_addr;
  assign m_axi_araddr = available ? req_addr : saved_addr;
  assign m_axi_wdata = available ? req_wdata : saved_wdata;
  assign m_axi_wstrb = available ? req_wstrb : saved_wstrb;
  assign m_axi_awprot = 3'b000;
  assign m_axi_arprot = 3'b000;
  assign m_axi_awvalid = !rst && ((active && saved_write && !aw_done) || (offer && req_write));
  assign m_axi_wvalid = !rst && ((active && saved_write && !w_done) || (offer && req_write));
  assign m_axi_arvalid = !rst && ((active && !saved_write && !ar_done) || (offer && !req_write));

  always @(posedge clk) begin
    if (rst) begin
      active <= 1'b0;
      saved_write <= 1'b0;
      saved_addr <= 32'b0;
      saved_wdata <= 32'b0;
      saved_wstrb <= 4'b0;
      aw_done <= 1'b0;
      w_done <= 1'b0;
      ar_done <= 1'b0;
    end else if (offer) begin
      active <= 1'b1;
      saved_write <= req_write;
      saved_addr <= req_addr;
      saved_wdata <= req_wdata;
      saved_wstrb <= req_wstrb;
      aw_done <= req_write && m_axi_awready;
      w_done <= req_write && m_axi_wready;
      ar_done <= !req_write && m_axi_arready;
    end else begin
      if (m_axi_awvalid && m_axi_awready) aw_done <= 1'b1;
      if (m_axi_wvalid && m_axi_wready) w_done <= 1'b1;
      if (m_axi_arvalid && m_axi_arready) ar_done <= 1'b1;
      if (rsp_fire) active <= 1'b0;
    end
  end
endmodule

`timescale 1ns / 1ns

// One outstanding request over the existing synchronous RAM / UART interface.
// req_fire starts the backend exactly once. The backend is ready to return on
// the following cycle unless busy; a blocked response is captured and held.
module mem_req_adapter #(
    parameter ID_WIDTH = 4
) (
    input clk,
    input rst,
    input req_valid,
    output req_ready,
    input [ID_WIDTH-1:0] req_id,
    input [31:0] req_addr,
    input req_write,
    input [31:0] req_wdata,
    input [7:0] req_alucex,
    output rsp_valid,
    input rsp_ready,
    output [ID_WIDTH-1:0] rsp_id,
    output [31:0] rsp_rdata,
    output rsp_error,
    output [31:0] rsp_fault_addr,
    output backend_start,
    output [31:0] backend_addr,
    output backend_write,
    output [31:0] backend_wdata,
    output [7:0] backend_alucex,
    input backend_busy,
    input [31:0] backend_rdata,
    input backend_error,
    input [31:0] backend_fault_addr
);
  reg pending;
  reg response_saved;
  reg [ID_WIDTH-1:0] pending_id;
  reg [31:0] pending_addr, pending_wdata;
  reg pending_write;
  reg [7:0] pending_alucex;
  reg [31:0] saved_rdata;
  reg saved_error;
  reg [31:0] saved_fault_addr;

  wire req_fire = req_valid && req_ready;
  wire rsp_fire = rsp_valid && rsp_ready;
  assign req_ready = !rst && !pending;
  assign rsp_valid = !rst && pending && (response_saved || !backend_busy);
  assign rsp_id = pending_id;
  assign rsp_rdata = response_saved ? saved_rdata : backend_rdata;
  assign rsp_error = response_saved ? saved_error : backend_error;
  assign rsp_fault_addr = response_saved ? saved_fault_addr : backend_fault_addr;

  // Before acceptance the backend sees the offered payload; afterwards it sees
  // the saved payload, even if the requester changes all its input signals.
  assign backend_start = req_fire;
  assign backend_addr = pending ? pending_addr : req_addr;
  assign backend_write = pending ? pending_write : req_write;
  assign backend_wdata = pending ? pending_wdata : req_wdata;
  assign backend_alucex = pending ? pending_alucex : req_alucex;

  always @(posedge clk) begin
    if (rst) begin
      pending <= 1'b0;
      response_saved <= 1'b0;
      pending_id <= {ID_WIDTH{1'b0}};
      pending_addr <= 32'b0;
      pending_write <= 1'b0;
      pending_wdata <= 32'b0;
      pending_alucex <= 8'b0;
      saved_rdata <= 32'b0;
      saved_error <= 1'b0;
      saved_fault_addr <= 32'b0;
    end else begin
      if (req_fire) begin
        pending <= 1'b1;
        response_saved <= 1'b0;
        pending_id <= req_id;
        pending_addr <= req_addr;
        pending_write <= req_write;
        pending_wdata <= req_wdata;
        pending_alucex <= req_alucex;
      end
      if (pending && !response_saved && !backend_busy) begin
        response_saved <= 1'b1;
        saved_rdata <= backend_rdata;
        saved_error <= backend_error;
        saved_fault_addr <= backend_fault_addr;
      end
      if (rsp_fire) begin
        pending <= 1'b0;
        response_saved <= 1'b0;
      end
    end
  end
endmodule

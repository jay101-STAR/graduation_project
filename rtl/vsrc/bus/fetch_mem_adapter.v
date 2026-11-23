`timescale 1ns / 1ns

// One core fetch outstanding, with a fall-through response buffer. Drain the
// memory response even when the CPU stalls, releasing the shared bus for data.
module fetch_mem_adapter (
    input         clk,
    input         rst,
    input         req_valid,
    output        req_ready,
    input  [ 3:0] req_id,
    input  [31:0] req_addr,
    output        rsp_valid,
    input         rsp_ready,
    output [ 3:0] rsp_id,
    output [31:0] rsp_rdata,
    output        rsp_error,
    output        mem_req_valid,
    input         mem_req_ready,
    output [31:0] mem_req_addr,
    input         mem_rsp_valid,
    output        mem_rsp_ready,
    input  [31:0] mem_rsp_rdata,
    input         mem_rsp_error
);
  reg pending, saved_valid;
  reg [3:0] pending_id;
  reg [31:0] saved_data;
  reg saved_error;
  wire bad_addr = (req_addr[31:16] != 16'h8000) || (req_addr[1:0] != 2'b00);
  wire rsp_fire = rsp_valid && rsp_ready;
  wire available = !pending || rsp_fire;
  assign req_ready     = !rst && available && (bad_addr || mem_req_ready);
  assign mem_req_valid = !rst && available && req_valid && !bad_addr;
  assign mem_req_addr  = req_addr;
  assign rsp_valid     = !rst && (saved_valid || (pending && mem_rsp_valid));
  assign rsp_id        = pending_id;
  assign rsp_rdata     = saved_valid ? saved_data : mem_rsp_rdata;
  assign rsp_error     = saved_valid ? saved_error : mem_rsp_error;
  assign mem_rsp_ready = !rst && (!saved_valid || rsp_ready);
  always @(posedge clk) begin
    if (rst) begin
      pending     <= 1'b0;
      saved_valid <= 1'b0;
      pending_id  <= 4'b0;
      saved_data  <= 32'b0;
      saved_error <= 1'b0;
    end else begin
      if (rsp_fire) begin
        pending     <= 1'b0;
        saved_valid <= 1'b0;
      end
      if (mem_rsp_valid && mem_rsp_ready && (saved_valid || !rsp_ready)) begin
        saved_valid <= 1'b1;
        saved_data  <= mem_rsp_rdata;
        saved_error <= mem_rsp_error;
      end
      if (req_valid && req_ready) begin
        pending    <= 1'b1;
        pending_id <= req_id;
        if (bad_addr) begin
          saved_valid <= 1'b1;
          saved_data  <= 32'b0;
          saved_error <= 1'b1;
        end
      end
    end
  end
endmodule

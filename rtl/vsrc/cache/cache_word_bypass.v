`timescale 1ns / 1ns

// C0 replacement point for ICache/DCache. Only disabled mode is implemented.
// Native word requests are forwarded, never expanded into line refills.
// Maintenance is accepted only when idle and with no offered word request;
// it completes the next cycle and holds DONE until acknowledged. C2 connects
// core FENCE.I sequencing; this module alone does not implement that sequence.
module cache_word_bypass #(
    parameter integer CACHE_ENABLE = 0
) (
    input         clk,
    input         rst,
    input         cpu_req_valid,
    output        cpu_req_ready,
    input  [33:0] cpu_req_addr,
    input         cpu_req_write,
    input  [31:0] cpu_req_wdata,
    input  [ 3:0] cpu_req_wstrb,
    input         cpu_req_access_ok,
    input         cpu_req_cacheable,
    output        cpu_rsp_valid,
    input         cpu_rsp_ready,
    output [31:0] cpu_rsp_rdata,
    output        cpu_rsp_error,
    output [ 1:0] cpu_rsp_source,
    output        mem_req_valid,
    input         mem_req_ready,
    output [33:0] mem_req_addr,
    output        mem_req_write,
    output [31:0] mem_req_wdata,
    output [ 3:0] mem_req_wstrb,
    input         mem_rsp_valid,
    output        mem_rsp_ready,
    input  [31:0] mem_rsp_rdata,
    input         mem_rsp_error,
    input         maint_req_valid,
    output        maint_req_ready,
    output        maint_done_valid,
    input         maint_done_ready
);
  reg pending, done_pending;
  wire rsp_fire = cpu_rsp_valid && cpu_rsp_ready;
  wire available = !pending || rsp_fire;
  assign cpu_req_ready    = !rst && !done_pending && available && mem_req_ready;
  assign mem_req_valid    = !rst && !done_pending && available && cpu_req_valid;
  assign mem_req_addr     = cpu_req_addr;
  assign mem_req_write    = cpu_req_write;
  assign mem_req_wdata    = cpu_req_wdata;
  assign mem_req_wstrb    = cpu_req_wstrb;
  assign cpu_rsp_valid    = !rst && pending && mem_rsp_valid;
  assign mem_rsp_ready    = !rst && pending && cpu_rsp_ready;
  assign cpu_rsp_rdata    = mem_rsp_rdata;
  assign cpu_rsp_error    = mem_rsp_error;
  // 00 = error, 01 = bypass, 10 = hit, 11 = refill (reserved for C1/C3).
  assign cpu_rsp_source   = mem_rsp_error ? 2'b00 : 2'b01;
  assign maint_req_ready  = !rst && !pending && !done_pending && !cpu_req_valid;
  assign maint_done_valid = !rst && done_pending;
  always @(posedge clk) begin
    if (rst) begin
      pending      <= 1'b0;
      done_pending <= 1'b0;
    end else begin
      if (rsp_fire) pending <= 1'b0;
      if (cpu_req_valid && cpu_req_ready) pending <= 1'b1;
      if (maint_done_valid && maint_done_ready) done_pending <= 1'b0;
      if (maint_req_valid && maint_req_ready) done_pending <= 1'b1;
    end
  end

  // These attributes are the future cache lookup/allocation inputs. Disabled
  // mode forwards every word; the physical-word adapter generates access errors.
  // synthesis translate_off
  initial begin
    if (CACHE_ENABLE != 0)
      $fatal(1, "C0 supports CACHE_ENABLE=0 only; cache arrays are not implemented");
  end
  // synthesis translate_on
endmodule

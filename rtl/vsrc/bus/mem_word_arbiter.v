`timescale 1ns / 1ns

// Two native word requesters, one globally outstanding transaction. Ownership
// is locked through response acceptance; round-robin grants prevent starvation.
module mem_word_arbiter (
    input clk, input rst,
    input [1:0] s_req_valid, output [1:0] s_req_ready,
    input [63:0] s_req_addr, input [1:0] s_req_write,
    input [63:0] s_req_wdata, input [7:0] s_req_wstrb,
    output [1:0] s_rsp_valid, input [1:0] s_rsp_ready,
    output [31:0] s_rsp_rdata, output s_rsp_error,
    output req_valid, input req_ready,
    output [31:0] req_addr, output req_write,
    output [31:0] req_wdata, output [3:0] req_wstrb,
    input rsp_valid, output rsp_ready, input [31:0] rsp_rdata, input rsp_error
);
  reg active, owner, last_owner;
  reg offer_locked, offer_owner;
  wire grant = offer_locked ? offer_owner :
               s_req_valid[0] && s_req_valid[1] ? !last_owner : s_req_valid[1];
  wire completing = rsp_valid && rsp_ready;
  assign req_valid = !rst && (!active || completing) && (|s_req_valid);
  assign req_addr = grant ? s_req_addr[63:32] : s_req_addr[31:0];
  assign req_write = s_req_write[grant];
  assign req_wdata = grant ? s_req_wdata[63:32] : s_req_wdata[31:0];
  assign req_wstrb = grant ? s_req_wstrb[7:4] : s_req_wstrb[3:0];
  assign s_req_ready = req_valid && req_ready ? (grant ? 2'b10 : 2'b01) : 2'b00;
  assign s_rsp_valid = !rst && active && rsp_valid ? (owner ? 2'b10 : 2'b01) : 2'b00;
  assign rsp_ready = !rst && active && s_rsp_ready[owner];
  assign s_rsp_rdata = rsp_rdata;
  assign s_rsp_error = rsp_error;
  always @(posedge clk) begin
    if (rst) begin
      active <= 1'b0;
      owner <= 1'b0;
      last_owner <= 1'b1;
      offer_locked <= 1'b0;
      offer_owner <= 1'b0;
    end else begin
      if (completing) active <= 1'b0;
      if (req_valid && req_ready) begin
        active <= 1'b1;
        owner <= grant;
        last_owner <= grant;
        offer_locked <= 1'b0;
      end else if (req_valid && !req_ready) begin
        offer_locked <= 1'b1;
        offer_owner <= grant;
      end
    end
  end
endmodule

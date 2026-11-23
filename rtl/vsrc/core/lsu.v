`timescale 1ns / 1ns
`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

// Preserve the CPU's byte/halfword/unaligned semantics over raw 32-bit words.
// start is a one-cycle pulse from mem_req_adapter. busy drops only after all
// subtransactions complete; result/error then remain stable until the next start.
module lsu (
    input             clk,
    input             rst,
    input             start,
    input      [31:0] addr,
    input             write_access,
    input      [31:0] wdata,
    input      [ 7:0] alucex,
    output            busy,
    output reg [31:0] rdata,
    output reg        error,
    output reg [31:0] fault_addr,
    output            req_valid,
    input             req_ready,
    output     [31:0] req_addr,
    output            req_write,
    output     [31:0] req_wdata,
    output     [ 3:0] req_wstrb,
    input             rsp_valid,
    output            rsp_ready,
    input      [31:0] rsp_rdata,
    input             rsp_error
);
  localparam [1:0] IDLE = 2'd0, REQUEST = 2'd1, RESPONSE = 2'd2;
  reg [1:0] state;
  reg [31:0] saved_addr, saved_wdata, first_word;
  reg [7:0] saved_op;
  reg saved_write, split, second;
  reg [2:0] access_bytes;
  reg valid_op;
  always @(*) begin
    access_bytes = 3'd4;
    valid_op     = 1'b1;
    case (alucex)
      `LB_TYPE, `LBU_TYPE: begin
        access_bytes = 3'd1;
        valid_op     = !write_access;
      end
      `LH_TYPE, `LHU_TYPE: begin
        access_bytes = 3'd2;
        valid_op     = !write_access;
      end
      `LW_TYPE: valid_op = !write_access;
      `SB_TYPE: begin
        access_bytes = 3'd1;
        valid_op     = write_access;
      end
      `SH_TYPE: begin
        access_bytes = 3'd2;
        valid_op     = write_access;
      end
      `SW_TYPE: valid_op = write_access;
      default:  valid_op = 1'b0;
    endcase
  end
  wire [32:0] last_addr = {1'b0, addr} + {30'b0, access_bytes} - 33'd1;
  wire ram_access = (addr[31:16] == 16'h8000);
  wire uart_access = (addr[31:4] == 28'h1000000);
  wire crosses = ({1'b0, addr[1:0]} + access_bytes) > 3'd4;
  // Precheck the entire access before any store beat can have a side effect.
  wire bad_access = !valid_op ||
      (ram_access ? (last_addr >= 33'h080010000) : (!uart_access || crosses));
  wire [4:0] shift_bits = {saved_addr[1:0], 3'b000};
  wire [63:0] shifted_store = {32'b0, saved_wdata} << shift_bits;
  wire [7:0] byte_mask = ((saved_op == `SB_TYPE) ? 8'h01 :
                         (saved_op == `SH_TYPE) ? 8'h03 : 8'h0f) << saved_addr[1:0];
  wire [63:0] load_words = second ? {rsp_rdata, first_word} : {32'b0, rsp_rdata};
  wire [63:0] shifted_load = load_words >> shift_bits;

  assign busy      = (state != IDLE);
  assign req_valid = !rst && (state == REQUEST);
  assign req_addr  = {saved_addr[31:2], 2'b00} + (second ? 32'd4 : 32'd0);
  assign req_write = saved_write;
  assign req_wdata = second ? shifted_store[63:32] : shifted_store[31:0];
  assign req_wstrb = !saved_write ? 4'b0 : second ? byte_mask[7:4] : byte_mask[3:0];
  assign rsp_ready = !rst && (state == RESPONSE);

  always @(posedge clk) begin
    if (rst) begin
      state       <= IDLE;
      saved_addr  <= 32'b0;
      saved_wdata <= 32'b0;
      saved_op    <= 8'b0;
      saved_write <= 1'b0;
      first_word  <= 32'b0;
      split       <= 1'b0;
      second      <= 1'b0;
      rdata       <= 32'b0;
      error       <= 1'b0;
      fault_addr  <= 32'b0;
    end else begin
      case (state)
        IDLE:
        if (start) begin
          saved_addr  <= addr;
          saved_wdata <= wdata;
          saved_op    <= alucex;
          saved_write <= write_access;
          split       <= crosses;
          second      <= 1'b0;
          rdata       <= 32'b0;
          error       <= bad_access;
          // For a rejected RAM-spanning operation, identify its first byte
          // outside RAM. No subtransaction has been issued in this case.
          fault_addr  <= (ram_access && last_addr >= 33'h080010000) ?
                         32'h80010000 : addr;
          if (!bad_access) state <= REQUEST;
        end
        REQUEST: if (req_valid && req_ready) state <= RESPONSE;
        RESPONSE:
        if (rsp_valid && rsp_ready) begin
          if (rsp_error) begin
            error <= 1'b1;
            // An unaligned access may fail on its second aligned word. Report
            // the failing portion, while the pipeline keeps the instruction PC.
            fault_addr <= second ? req_addr : saved_addr;
            rdata <= 32'b0;
            state <= IDLE;
          end else if (split && !second) begin
            first_word <= rsp_rdata;
            second     <= 1'b1;
            state      <= REQUEST;
          end else begin
            case (saved_op)
              `LB_TYPE:  rdata <= {{24{shifted_load[7]}}, shifted_load[7:0]};
              `LBU_TYPE: rdata <= {24'b0, shifted_load[7:0]};
              `LH_TYPE:  rdata <= {{16{shifted_load[15]}}, shifted_load[15:0]};
              `LHU_TYPE: rdata <= {16'b0, shifted_load[15:0]};
              `LW_TYPE:  rdata <= shifted_load[31:0];
              default:   rdata <= 32'b0;
            endcase
            state <= IDLE;
          end
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule

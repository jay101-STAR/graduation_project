`timescale 1ns / 1ns

// 指令侧物理字适配：ICache、不可缓存字旁路、错误恢复和 FENCE.I 失效。
// 上游提供完整 34 位地址许可；缩窄到 32 位后端前检查补行命令。
// ICACHE_ENABLE 是编译期参数，本文件不包含数据侧逻辑。
module icache_phys_word #(
    parameter integer ICACHE_ENABLE = 0
) (
    input         clk,
    input         rst,
    input         req_valid,
    output        req_ready,
    input  [33:0] req_addr,
    input         req_write,
    input  [31:0] req_wdata,
    input  [ 3:0] req_wstrb,
    input         req_access_ok,
    input         req_cacheable,
    output        rsp_valid,
    input         rsp_ready,
    output [31:0] rsp_rdata,
    output        rsp_error,
    output [ 1:0] rsp_source,
    output        mem_req_valid,
    input         mem_req_ready,
    output [31:0] mem_req_addr,
    output [ 7:0] mem_req_len,
    output        mem_req_write,
    output [31:0] mem_req_wdata,
    output [ 3:0] mem_req_wstrb,
    input         mem_rsp_valid,
    output        mem_rsp_ready,
    input  [31:0] mem_rsp_rdata,
    input         mem_rsp_error,
    input         mem_rsp_last,
    input         maint_req_valid,
    output        maint_req_ready,
    output        maint_done_valid,
    input         maint_done_ready
);
  generate
    if (ICACHE_ENABLE != 0) begin : with_icache
      localparam [2:0] IDLE = 0, CACHED = 1, BYPASS_REQ = 2,
                       BYPASS_WAIT = 3, RESPONSE = 4, INVALIDATE = 5, MAINT_DONE = 6;
      reg [ 2:0] state;
      reg [33:0] saved_addr;
      reg [31:0] saved_data;
      reg saved_error, refilled, flush_for_error;
      reg cache_clear;
      wire cache_req_ready, cache_rsp_valid, cache_mem_req_valid, cache_mem_rsp_ready;
      wire [31:0] cache_rsp_rdata;
      wire cache_rsp_error;
      wire [7:0] cache_mem_req_len;
      wire [33:0] cache_mem_req_addr;
      // Replace a consumed cached response with a legal cached request. Keep
      // bypass/error transitions in IDLE, and let maintenance stop the stream.
      wire cached_response_fire = state == CACHED && cache_rsp_valid && !cache_rsp_error && rsp_ready;
      wire cache_available = state == IDLE || cached_response_fire;
      wire cache_req_valid = !rst && cache_available && !maint_req_valid &&
                             req_valid && req_access_ok && req_cacheable;
      // The upstream attributes validate the full line. Check the complete
      // aligned burst command before narrowing its physical address.
      wire cache_word_bad = (cache_mem_req_addr[33:6] != saved_addr[33:6]) ||
                            (cache_mem_req_addr[5:0] != 0) || cache_mem_req_len != 15;
      wire req_fire = req_valid && req_ready;
      wire rsp_fire = rsp_valid && rsp_ready;
      wire mem_rsp_fire = mem_rsp_valid && mem_rsp_ready;

      icache cache (
          .clk          (clk),
          .rst_n        (!rst && !cache_clear),
          .cpu_req_valid(cache_req_valid),
          .cpu_req_ready(cache_req_ready),
          .cpu_req_addr (req_addr),
          .cpu_rsp_valid(cache_rsp_valid),
          .cpu_rsp_ready(!rst && state == CACHED && rsp_ready),
          .cpu_rsp_rdata(cache_rsp_rdata),
          .cpu_rsp_error(cache_rsp_error),
          .mem_req_valid(cache_mem_req_valid),
          .mem_req_addr (cache_mem_req_addr),
          .mem_req_len  (cache_mem_req_len),
          .mem_req_ready(!rst && state == CACHED && mem_req_ready && !cache_word_bad),
          .mem_rsp_valid(!rst && state == CACHED && mem_rsp_valid),
          .mem_rsp_ready(cache_mem_rsp_ready),
          .mem_rsp_rdata(mem_rsp_rdata),
          .mem_rsp_error(mem_rsp_error),
          .mem_rsp_last (mem_rsp_last)
      );

      assign req_ready = !rst && !maint_req_valid &&
                             ((state == IDLE && (!(req_access_ok && req_cacheable) || cache_req_ready)) ||
                              (cached_response_fire && req_access_ok && req_cacheable && cache_req_ready));
      assign rsp_valid = !rst && ((state == CACHED && cache_rsp_valid && !cache_rsp_error) || state == RESPONSE);
      assign rsp_rdata = state == CACHED ? cache_rsp_rdata : saved_data;
      assign rsp_error = state == RESPONSE && saved_error;
      assign rsp_source = rsp_error ? 2'b00 : state == CACHED ? (refilled ? 2'b11 : 2'b10) : 2'b01;
      assign mem_req_valid = !rst && ((state == CACHED && cache_mem_req_valid && !cache_word_bad) ||
                                      state == BYPASS_REQ);
      assign mem_req_len = state == CACHED ? cache_mem_req_len : 8'b0;
      assign mem_req_addr = state == CACHED ? cache_mem_req_addr[31:0] : saved_addr[31:0];
      assign mem_rsp_ready = !rst && ((state == CACHED &&
                                      cache_mem_rsp_ready) || state == BYPASS_WAIT);
      assign mem_req_write = 1'b0;
      assign mem_req_wdata = 32'b0;
      assign mem_req_wstrb = 4'b0;
      // Maintenance has priority over a held CPU offer, but never cancels an
      // accepted memory transaction: cached/bypass work completes before IDLE.
      assign maint_req_ready = !rst && state == IDLE;
      assign maint_done_valid = !rst && state == MAINT_DONE;

      always @(posedge clk) begin
        if (rst) begin
          state           <= IDLE;
          saved_addr      <= 0;
          saved_data      <= 0;
          saved_error     <= 0;
          refilled        <= 0;
          flush_for_error <= 0;
          cache_clear     <= 0;
        end else begin
          // A registered pulse drives the array reset; avoid decoding a multi-bit
          // FSM state directly onto an asynchronous reset input.
          cache_clear <= 0;
          case (state)
            IDLE: begin
              if (maint_req_valid && maint_req_ready) begin
                flush_for_error <= 0;
                cache_clear     <= 1;
                state           <= INVALIDATE;
              end else if (req_fire) begin
                saved_addr  <= req_addr;
                saved_data  <= 0;
                saved_error <= !req_access_ok;
                refilled    <= 0;
                state       <= !req_access_ok ? RESPONSE : req_cacheable ? CACHED : BYPASS_REQ;
              end
            end
            CACHED: begin
              if (mem_req_valid && mem_req_ready) refilled <= 1;
              if ((cache_mem_req_valid && cache_word_bad) || (cache_rsp_valid && cache_rsp_error)) begin
                saved_data      <= 0;
                saved_error     <= 1;
                flush_for_error <= 1;
                cache_clear     <= 1;
                state           <= INVALIDATE;
              end else if (rsp_fire) begin
                if (req_fire) begin
                  saved_addr  <= req_addr;
                  saved_data  <= 0;
                  saved_error <= 0;
                  refilled    <= 0;
                  state       <= CACHED;
                end else state <= IDLE;
              end
            end
            BYPASS_REQ: if (mem_req_valid && mem_req_ready) state <= BYPASS_WAIT;
            BYPASS_WAIT:
            if (mem_rsp_fire) begin
              saved_data  <= mem_rsp_rdata;
              saved_error <= mem_rsp_error;
              state       <= RESPONSE;
            end
            RESPONSE:   if (rsp_fire) state <= IDLE;
            INVALIDATE: state <= flush_for_error ? RESPONSE : MAINT_DONE;
            MAINT_DONE: if (maint_done_ready) state <= IDLE;
            default:    state <= IDLE;
          endcase
        end
      end
    end else begin : without_icache
      reg pending, local_error;
      wire bad_addr = !req_access_ok;
      wire rsp_fire = rsp_valid && rsp_ready;
      wire available = !pending || rsp_fire;
      assign req_ready     = !rst && available && (bad_addr || mem_req_ready);
      assign mem_req_valid = !rst && available && req_valid && !bad_addr;
      assign mem_req_addr  = req_addr[31:0];
      assign mem_req_len   = 8'b0;
      assign mem_req_write = req_write;
      assign mem_req_wdata = req_wdata;
      assign mem_req_wstrb = req_wstrb;
      assign rsp_valid     = !rst && pending && (local_error || mem_rsp_valid);
      assign rsp_rdata     = local_error ? 32'b0 : mem_rsp_rdata;
      assign rsp_error     = local_error || mem_rsp_error;
      assign mem_rsp_ready = !rst && pending && !local_error && rsp_ready;
      always @(posedge clk) begin
        if (rst) begin
          pending     <= 1'b0;
          local_error <= 1'b0;
        end else begin
          if (rsp_fire) pending <= 1'b0;
          if (req_valid && req_ready) begin
            pending     <= 1'b1;
            local_error <= bad_addr;
          end
        end
      end
      assign rsp_source       = rsp_error ? 2'b00 : 2'b01;
      assign maint_req_ready  = 1'b0;
      assign maint_done_valid = 1'b0;
    end
  endgenerate

endmodule

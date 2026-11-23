`timescale 1ns / 1ns

// 数据侧物理字适配：写回 DCache / UART、tohost 字旁路 / clean 维护。
// 上游负责原始字请求的完整地址许可；本模块另外检查 Cache 产生的后端地址。
// 补行和脏行写回使用 16 拍事务；旁路保持单拍，写回每拍使用完整字节掩码。
module dcache_phys_word #(
    parameter integer DCACHE_ENABLE = 0
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
    output        mem_req_wlast,
    output [31:0] mem_req_wdata,
    output [ 3:0] mem_req_wstrb,
    input         mem_rsp_valid,
    output        mem_rsp_ready,
    input  [31:0] mem_rsp_rdata,
    input         mem_rsp_error,
    input         mem_rsp_rlast,
    input         maint_req_valid,
    output        maint_req_ready,
    output        maint_done_valid,
    input         maint_done_ready,
    output        maint_error
);
  generate
    if (DCACHE_ENABLE != 0) begin : with_dcache
      localparam [2:0] IDLE = 0, CACHED = 1, BYPASS_REQ = 2,
                       BYPASS_WAIT = 3, RESPONSE = 4, MAINTENANCE = 5;
      reg [2:0] state;
      reg [33:0] saved_addr;
      reg saved_write;
      reg [31:0] saved_wdata, saved_data;
      reg [3:0] saved_wstrb;
      reg saved_error, refilled, bad_pending;
      wire cache_req_ready, cache_rsp_valid, cache_rsp_error;
      wire [31:0] cache_rsp_rdata;
      wire cache_mem_req_valid, cache_mem_req_ready, cache_mem_req_write;
      wire [7:0] cache_mem_req_len;
      wire cache_mem_req_wlast;
      wire [33:0] cache_mem_req_addr;
      wire [31:0] cache_mem_req_wdata;
      wire cache_mem_rsp_valid, cache_mem_rsp_ready, cache_mem_rsp_error;
      wire cache_maint_ready, cache_maint_done, cache_maint_error;
      wire cache_address_valid, cache_address_cacheable, cache_line_cacheable;
      wire cache_active = state == CACHED || state == MAINTENANCE;
      wire req_fire = req_valid && req_ready;
      wire rsp_fire = rsp_valid && rsp_ready;
      wire mem_rsp_fire = mem_rsp_valid && mem_rsp_ready;
      wire maint_fire = maint_req_valid && maint_req_ready;
      wire cache_req_valid = !rst && state == IDLE && !maint_req_valid &&
                             req_valid && req_access_ok && req_cacheable;

      mem_attr_decode #(
          .LINE_BYTES(64)
      ) backend_attributes (
          .phys_addr     (cache_mem_req_addr),
          .addr_valid    (cache_address_valid),
          .executable    (),
          .cacheable     (cache_address_cacheable),
          .line_cacheable(cache_line_cacheable),
          .is_mmio       ()
      );
      // 写回可能来自其他 tag；补行读取必须仍属于已接受请求所在的行。
      wire cache_word_bad = !cache_address_valid || !cache_address_cacheable ||
                            !cache_line_cacheable || cache_mem_req_addr[1:0] != 0 ||
                            (!cache_mem_req_write &&
                             (state == MAINTENANCE || cache_mem_req_addr[33:6] != saved_addr[33:6]));
      assign cache_mem_req_ready = !rst && cache_active && !bad_pending &&
                                   (cache_word_bad || mem_req_ready);
      assign cache_mem_rsp_valid = !rst && cache_active && (bad_pending || mem_rsp_valid);
      assign cache_mem_rsp_error = bad_pending || mem_rsp_error;

      dcache cache (
          .clk             (clk),
          .rst_n           (!rst),
          .cpu_req_valid   (cache_req_valid),
          .cpu_req_ready   (cache_req_ready),
          .cpu_req_addr    (req_addr),
          .cpu_req_write   (req_write),
          .cpu_req_wdata   (req_wdata),
          .cpu_req_wstrb   (req_wstrb),
          .cpu_rsp_valid   (cache_rsp_valid),
          .cpu_rsp_ready   (!rst && state == CACHED && rsp_ready),
          .cpu_rsp_rdata   (cache_rsp_rdata),
          .cpu_rsp_error   (cache_rsp_error),
          .mem_req_valid   (cache_mem_req_valid),
          .mem_req_ready   (cache_mem_req_ready),
          .mem_req_addr    (cache_mem_req_addr),
          .mem_req_len     (cache_mem_req_len),
          .mem_req_wlast   (cache_mem_req_wlast),
          .mem_req_write   (cache_mem_req_write),
          .mem_req_wdata   (cache_mem_req_wdata),
          .mem_rsp_valid   (cache_mem_rsp_valid),
          .mem_rsp_rlast   (mem_rsp_rlast),
          .mem_rsp_ready   (cache_mem_rsp_ready),
          .mem_rsp_rdata   (bad_pending ? 32'b0 : mem_rsp_rdata),
          .mem_rsp_error   (cache_mem_rsp_error),
          .maint_req_valid (!rst && state == IDLE && maint_req_valid),
          .maint_req_ready (cache_maint_ready),
          .maint_done_valid(cache_maint_done),
          .maint_done_ready(!rst && state == MAINTENANCE && maint_done_ready),
          .maint_error     (cache_maint_error)
      );

      assign req_ready = !rst && state == IDLE && !maint_req_valid &&
                         (!(req_access_ok && req_cacheable) || cache_req_ready);
      assign rsp_valid = !rst && ((state == CACHED && cache_rsp_valid) || state == RESPONSE);
      assign rsp_rdata = state == CACHED ? cache_rsp_rdata : saved_data;
      assign rsp_error = state == CACHED ? cache_rsp_error : (state == RESPONSE && saved_error);
      assign rsp_source = rsp_error ? 2'b00 : state == CACHED ? (refilled ? 2'b11 : 2'b10) : 2'b01;
      assign mem_req_valid = !rst &&
          ((cache_active && cache_mem_req_valid && !bad_pending && !cache_word_bad) || state == BYPASS_REQ);
      assign mem_req_addr = cache_active ? cache_mem_req_addr[31:0] : saved_addr[31:0];
      assign mem_req_len = cache_active ? cache_mem_req_len : 8'd0;
      assign mem_req_wlast = cache_active ? cache_mem_req_wlast : saved_write;
      assign mem_req_write = cache_active ? cache_mem_req_write : saved_write;
      assign mem_req_wdata = cache_active ? cache_mem_req_wdata : saved_wdata;
      assign mem_req_wstrb = cache_active ? (cache_mem_req_write ? 4'hf : 4'h0) : saved_wstrb;
      assign mem_rsp_ready = !rst &&
          ((cache_active && !bad_pending && cache_mem_rsp_ready) || state == BYPASS_WAIT);
      assign maint_req_ready = !rst && state == IDLE && cache_maint_ready;
      assign maint_done_valid = !rst && state == MAINTENANCE && cache_maint_done;
      assign maint_error = cache_maint_error;

      always @(posedge clk) begin
        if (rst) begin
          state       <= IDLE;
          saved_addr  <= 0;
          saved_write <= 0;
          saved_wdata <= 0;
          saved_wstrb <= 0;
          saved_data  <= 0;
          saved_error <= 0;
          refilled    <= 0;
          bad_pending <= 0;
        end else begin
          if (cache_active && cache_mem_req_valid && cache_mem_req_ready && cache_word_bad)
            bad_pending <= 1'b1;
          if (bad_pending && cache_mem_rsp_valid && cache_mem_rsp_ready) bad_pending <= 1'b0;
          case (state)
            IDLE: begin
              if (maint_fire) begin
                state <= MAINTENANCE;
              end else if (req_fire) begin
                saved_addr  <= req_addr;
                saved_write <= req_write;
                saved_wdata <= req_wdata;
                saved_wstrb <= req_wstrb;
                saved_data  <= 0;
                saved_error <= !req_access_ok;
                refilled    <= 0;
                state       <= !req_access_ok ? RESPONSE : req_cacheable ? CACHED : BYPASS_REQ;
              end
            end
            CACHED: begin
              if (mem_req_valid && mem_req_ready && !mem_req_write) refilled <= 1'b1;
              if (rsp_fire) state <= IDLE;
            end
            BYPASS_REQ:  if (mem_req_valid && mem_req_ready) state <= BYPASS_WAIT;
            BYPASS_WAIT: begin
              if (mem_rsp_fire) begin
                saved_data  <= mem_rsp_rdata;
                saved_error <= mem_rsp_error;
                state       <= RESPONSE;
              end
            end
            RESPONSE:    if (rsp_fire) state <= IDLE;
            MAINTENANCE: if (maint_done_valid && maint_done_ready) state <= IDLE;
            default:     state <= IDLE;
          endcase
        end
      end
    end else begin : without_dcache
      // 关闭缓存时保持原有组合请求/响应通路，pending 只记录事务归属。
      reg pending, local_error;
      wire bad_addr = !req_access_ok;
      wire rsp_fire = rsp_valid && rsp_ready;
      wire available = !pending || rsp_fire;
      assign req_ready        = !rst && available && (bad_addr || mem_req_ready);
      assign mem_req_valid    = !rst && available && req_valid && !bad_addr;
      assign mem_req_addr     = req_addr[31:0];
      assign mem_req_len      = 8'b0;
      assign mem_req_write    = req_write;
      assign mem_req_wlast    = req_write;
      assign mem_req_wdata    = req_wdata;
      assign mem_req_wstrb    = req_wstrb;
      assign rsp_valid        = !rst && pending && (local_error || mem_rsp_valid);
      assign rsp_rdata        = local_error ? 32'b0 : mem_rsp_rdata;
      assign rsp_error        = local_error || mem_rsp_error;
      assign mem_rsp_ready    = !rst && pending && !local_error && rsp_ready;
      assign rsp_source       = rsp_error ? 2'b00 : 2'b01;
      assign maint_req_ready  = 1'b0;
      assign maint_done_valid = 1'b0;
      assign maint_error      = 1'b0;
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
    end
  endgenerate
endmodule

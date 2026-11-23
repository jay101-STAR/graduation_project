  // Native cache boundary checks are independent of the AXI channel checks.
  // Source codes: error=0, bypass=1, hit=2, refill=3. Actual hit/refill tracking
  // is extended with the arrays/controllers in C1/C3; C0 must only bypass.
  genvar cc_port;
  generate
    for (cc_port = 0; cc_port < 2; cc_port = cc_port + 1) begin : cache_checks
      wire enabled = (cc_port == 0) ? (top.ICACHE_ENABLE != 0) : (top.DCACHE_ENABLE != 0);
      wire req_valid = top.u_core.cache_cpu_req_valid[cc_port];
      wire req_ready = top.u_core.cache_cpu_req_ready[cc_port];
      wire rsp_valid = top.u_core.cache_cpu_rsp_valid[cc_port];
      wire rsp_ready = top.u_core.cache_cpu_rsp_ready[cc_port];
      wire rsp_error = top.u_core.cache_cpu_rsp_error[cc_port];
      wire [1:0] source = top.u_core.cache_cpu_rsp_source[cc_port*2 +: 2];
      // 两侧独立 generate 后，检查使用稳定的核内信号，不依赖分支层次名称。
      wire [33:0] phys_addr = (cc_port == 0) ? top.u_core.i_phys_addr : top.u_core.d_phys_addr;
      wire access_ok = (cc_port == 0) ? top.u_core.i_access_ok : top.u_core.d_access_ok;
      wire req_cacheable = (cc_port == 0) ? top.u_core.i_req_cacheable : top.u_core.d_req_cacheable;
      wire is_mmio = (cc_port == 0) ? top.u_core.i_is_mmio : top.u_core.d_is_mmio;
      wire bypass_req_ready = (cc_port == 0) ? top.u_core.i_bypass_req_ready : top.u_core.d_bypass_req_ready;
      wire [70:0] request_payload = {phys_addr,
          top.u_core.cache_cpu_req_write[cc_port], top.u_core.cache_cpu_req_wdata[cc_port*32 +: 32],
          top.u_core.cache_cpu_req_wstrb[cc_port*4 +: 4]};
      wire [34:0] response_payload = {source, rsp_error, top.u_core.cache_cpu_rsp_rdata[cc_port*32 +: 32]};
      reg blocked_req = 1'b0, blocked_rsp = 1'b0, pending = 1'b0;
      reg [70:0] held_request;
      reg [34:0] held_response;
      reg accepted_cacheable, accepted_access_ok;
      integer accepted = 0, completed = 0, bypasses = 0, hits = 0, refills = 0;
      integer maintenance = 0, mmio = 0, uncacheable = 0;
      always @(posedge clk) begin
        if (top.sync_rst) begin
          blocked_req <= 1'b0;
          blocked_rsp <= 1'b0;
          pending <= 1'b0;
        end else begin
          if (blocked_req && (!req_valid || request_payload !== held_request))
            $fatal(1, "Cache port %0d changed blocked request", cc_port);
          if (blocked_rsp && (!rsp_valid || response_payload !== held_response))
            $fatal(1, "Cache port %0d changed blocked response", cc_port);
          blocked_req <= req_valid && !req_ready;
          blocked_rsp <= rsp_valid && !rsp_ready;
          held_request <= request_payload;
          held_response <= response_payload;
          if (rsp_valid) begin
            if (!pending) $fatal(1, "Cache response without request port=%0d", cc_port);
            if (rsp_error ? (source != 0) : (source == 0))
              $fatal(1, "Cache source/error mismatch port=%0d", cc_port);
            if (!rsp_error && !accepted_access_ok) $fatal(1, "Illegal cache request succeeded");
            if (!rsp_error && !enabled && source != 1)
              $fatal(1, "Disabled cache reported hit/refill");
            if (source >= 2 && !accepted_cacheable) $fatal(1, "MMIO/special line cached");
          end
          if (rsp_valid && rsp_ready) begin
            pending <= 1'b0;
            completed <= completed + 1;
            if (source == 1) bypasses <= bypasses + 1;
            if (source == 2) hits <= hits + 1;
            if (source == 3) refills <= refills + 1;
          end
          if (top.u_core.cache_maint_req_valid[cc_port] && top.u_core.cache_maint_req_ready[cc_port])
            maintenance <= maintenance + 1;
          if (req_valid && req_ready) begin
            if (pending && !(rsp_valid && rsp_ready)) $fatal(1, "Cache port has two pending words");
            pending <= 1'b1;
            accepted <= accepted + 1;
            accepted_cacheable <= req_cacheable;
            accepted_access_ok <= access_ok;
            if (is_mmio) mmio <= mmio + 1;
            if (!req_cacheable) uncacheable <= uncacheable + 1;
          end
          // The C0 disabled path is one request -> one backend word, with no
          // request or response pipeline registers added to the legal path.
          if (!enabled && req_valid && access_ok &&
              bypass_req_ready && !top.u_core.cache_maint_done_valid[cc_port] &&
              (!pending || (rsp_valid && rsp_ready)) && !req_ready)
            $fatal(1, "C0 added request latency");
        end
      end
      final begin
        $display("[CACHE-BOUNDARY] port=%0d enabled=%0d accepted=%0d completed=%0d bypass=%0d hits=%0d refills=%0d maintenance=%0d mmio=%0d uncacheable=%0d",
                 cc_port, enabled, accepted, completed, bypasses, hits, refills, maintenance, mmio, uncacheable);
      end
    end
  endgenerate

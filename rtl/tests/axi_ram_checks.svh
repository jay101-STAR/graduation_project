  // Included in the CPU regression bench: prove actual AXI traversal, protocol
  // stability, and one-slave routing instead of merely checking final values.
  reg ax_rd_blocked = 1'b0, ax_wr_blocked = 1'b0, ax_ar_blocked = 1'b0, ax_aw_blocked = 1'b0;
  reg ax_w_blocked = 1'b0, ax_r_blocked = 1'b0, ax_b_blocked = 1'b0;
  reg [39:0] ax_rd_payload;
  reg [76:0] ax_wr_payload;
  reg ax_read_owner;
  reg [7:0] ax_expected_len, ax_read_beat;
  reg [7:0] ax_write_len;
  reg [8:0] ax_write_beats;
  reg ax_write_last_seen = 1'b0;
  reg [61:0] ax_ar_payload, ax_aw_payload;
  reg [36:0] ax_w_payload;
  reg [35:0] ax_r_payload;
  reg [2:0] ax_b_payload;
  integer ax_if_completed = 0, ax_if_consumed = 0;
  wire ax_r_fire = top.axi_bridge_rvalid && top.bridge_axi_rready;
  wire ax_b_fire = top.axi_bridge_bvalid && top.bridge_axi_bready;
  wire ax_ar_owner = (top.word_rd_req_valid && top.word_rd_req_ready) ?
                     top.u_core.word_arbiter.rd_grant : top.u_core.word_arbiter.rd_owner;
  reg ax_read_pending = 1'b0, ax_aw_pending = 1'b0, ax_w_pending = 1'b0;
  integer ax_if_reads = 0, ax_data_reads = 0, ax_ram_writes = 0;
  integer ax_uart_reads = 0, ax_uart_writes = 0;
  integer ax_fetch_buffered = 0;
  integer ax_overlap_cycles = 0, ax_parallel_data = 0, ax_parallel_responses = 0;
  always @(posedge clk) begin
    if (top.sync_rst) begin
      ax_rd_blocked <= 1'b0; ax_wr_blocked <= 1'b0; ax_read_owner <= 0;
      ax_ar_blocked <= 1'b0;
      ax_aw_blocked <= 1'b0;
      ax_w_blocked <= 1'b0;
      ax_r_blocked <= 1'b0;
      ax_b_blocked <= 1'b0;
      ax_read_pending <= 1'b0;
      ax_expected_len <= 0; ax_read_beat <= 0;
      ax_aw_pending <= 1'b0;
      ax_w_pending <= 1'b0;
      ax_write_len <= 0;
      ax_write_beats <= 0;
      ax_write_last_seen <= 0;
    end else begin
      if (ax_rd_blocked && (!top.word_rd_req_valid ||
          {top.word_rd_req_addr, top.word_rd_req_len} != ax_rd_payload))
        $fatal(1, "Arbiter changed a blocked read request");
      if (ax_wr_blocked && (!top.word_wr_req_valid ||
          {top.word_wr_req_addr, top.word_wr_req_len, top.word_wr_req_wdata,
           top.word_wr_req_wstrb, top.word_wr_req_wlast} != ax_wr_payload))
        $fatal(1, "Arbiter changed a blocked write request");
      if (ax_ar_blocked && (!top.bridge_axi_arvalid ||
          {top.bridge_axi_araddr, top.bridge_axi_arid, top.bridge_axi_arlen, top.bridge_axi_arsize, top.bridge_axi_arburst, top.bridge_axi_arlock, top.bridge_axi_arcache, top.bridge_axi_arprot, top.bridge_axi_arqos, top.bridge_axi_arregion} != ax_ar_payload))
        $fatal(1, "AXI AR changed under backpressure");
      if (ax_aw_blocked && (!top.bridge_axi_awvalid ||
          {top.bridge_axi_awaddr, top.bridge_axi_awid, top.bridge_axi_awlen, top.bridge_axi_awsize, top.bridge_axi_awburst, top.bridge_axi_awlock, top.bridge_axi_awcache, top.bridge_axi_awprot, top.bridge_axi_awqos, top.bridge_axi_awregion} != ax_aw_payload))
        $fatal(1, "AXI AW changed under backpressure");
      if (ax_w_blocked && (!top.bridge_axi_wvalid ||
          {top.bridge_axi_wdata, top.bridge_axi_wstrb, top.bridge_axi_wlast} != ax_w_payload))
        $fatal(1, "AXI W changed under backpressure");
      if (ax_r_blocked && (!top.axi_bridge_rvalid ||
          {top.axi_bridge_rdata, top.axi_bridge_rresp, top.axi_bridge_rid, top.axi_bridge_rlast} != ax_r_payload))
        $fatal(1, "AXI R changed under backpressure");
      if (ax_b_blocked && (!top.axi_bridge_bvalid || {top.axi_bridge_bid, top.axi_bridge_bresp} != ax_b_payload))
        $fatal(1, "AXI B changed under backpressure");
      ax_rd_blocked <= top.word_rd_req_valid && !top.word_rd_req_ready;
      ax_wr_blocked <= top.word_wr_req_valid && !top.word_wr_req_ready;
      ax_ar_blocked <= top.bridge_axi_arvalid && !top.axi_bridge_arready;
      ax_aw_blocked <= top.bridge_axi_awvalid && !top.axi_bridge_awready;
      ax_w_blocked <= top.bridge_axi_wvalid && !top.axi_bridge_wready;
      ax_r_blocked <= top.axi_bridge_rvalid && !top.bridge_axi_rready;
      ax_b_blocked <= top.axi_bridge_bvalid && !top.bridge_axi_bready;
      ax_rd_payload <= {top.word_rd_req_addr, top.word_rd_req_len};
      ax_wr_payload <= {top.word_wr_req_addr, top.word_wr_req_len, top.word_wr_req_wdata,
                        top.word_wr_req_wstrb, top.word_wr_req_wlast};
      ax_ar_payload <= {top.bridge_axi_araddr, top.bridge_axi_arid, top.bridge_axi_arlen, top.bridge_axi_arsize, top.bridge_axi_arburst, top.bridge_axi_arlock, top.bridge_axi_arcache, top.bridge_axi_arprot, top.bridge_axi_arqos, top.bridge_axi_arregion};
      ax_aw_payload <= {top.bridge_axi_awaddr, top.bridge_axi_awid, top.bridge_axi_awlen, top.bridge_axi_awsize, top.bridge_axi_awburst, top.bridge_axi_awlock, top.bridge_axi_awcache, top.bridge_axi_awprot, top.bridge_axi_awqos, top.bridge_axi_awregion};
      ax_w_payload <= {top.bridge_axi_wdata, top.bridge_axi_wstrb, top.bridge_axi_wlast};
      ax_r_payload <= {top.axi_bridge_rdata, top.axi_bridge_rresp, top.axi_bridge_rid, top.axi_bridge_rlast};
      ax_b_payload <= {top.axi_bridge_bid, top.axi_bridge_bresp};
      if (ax_read_pending && (ax_aw_pending || ax_w_pending)) ax_overlap_cycles <= ax_overlap_cycles + 1;
      if (ax_r_fire && top.bridge_axi_wvalid && top.axi_bridge_wready) ax_parallel_data <= ax_parallel_data + 1;
      if (ax_r_fire && ax_b_fire) ax_parallel_responses <= ax_parallel_responses + 1;
      if (&top.axi4_subsystem0.slave_arvalid || &top.axi4_subsystem0.slave_awvalid ||
          &top.axi4_subsystem0.slave_wvalid)
        $fatal(1, "One AXI request reached both slaves");
      if (top.u_core.word_s_rsp_valid[0] && top.u_core.word_s_rsp_ready[0] && !top.u_core.if_rsp_ready)
        ax_fetch_buffered <= ax_fetch_buffered + 1;
      if (ax_r_fire && top.axi_bridge_rlast) ax_read_pending <= 1'b0;
      if (ax_b_fire) begin
        ax_aw_pending <= 1'b0; ax_w_pending <= 1'b0;
        ax_write_beats <= 0; ax_write_last_seen <= 0;
      end
      if (top.bridge_axi_arvalid && top.axi_bridge_arready) begin
        if (ax_read_pending && !(ax_r_fire && top.axi_bridge_rlast))
          $fatal(1, "Second read issued before RLAST");
        ax_read_pending <= 1'b1;
        ax_read_owner <= ax_ar_owner;
        ax_expected_len <= top.bridge_axi_arlen;
        ax_read_beat <= 0;
        if (!ax_ar_owner) ax_if_reads <= ax_if_reads + 1;
        else if (top.bridge_axi_araddr[31:16] == 16'h8000) ax_data_reads <= ax_data_reads + 1;
        else ax_uart_reads <= ax_uart_reads + 1;
      end
      if (top.axi_bridge_rvalid && top.bridge_axi_rready) begin
        if (!ax_read_pending || top.axi_bridge_rresp != 2'b00)
          $fatal(1, "Unexpected AXI read response/error");
        if (top.axi_bridge_rlast != (ax_read_beat == ax_expected_len) || top.axi_bridge_rid != 0)
          $fatal(1, "AXI4 response length/ID mismatch");
        // A replacement AR starts a new counter at this same edge.
        if (!(top.bridge_axi_arvalid && top.axi_bridge_arready))
          ax_read_beat <= ax_read_beat + 1'b1;
        if (!ax_read_owner && top.axi_bridge_rlast) ax_if_completed <= ax_if_completed + 1;
      end
      // Disabled ICache must still traverse AXI. Enabled-cache provenance is
      // checked at the word boundary by cache_checks.svh instead of assuming
      // that every instruction has its own backend AXI read.
      if ((top.ICACHE_ENABLE == 0) && top.u_core.if_rsp_valid && top.u_core.if_rsp_ready) begin
        if (ax_if_consumed >= ax_if_completed && !(ax_r_fire && !ax_read_owner))
          $fatal(1, "Instruction reached CPU without completing an AXI read");
        ax_if_consumed <= ax_if_consumed + 1;
      end
      if (top.bridge_axi_awvalid && top.axi_bridge_awready) begin
        if ((ax_aw_pending && !ax_b_fire)) $fatal(1, "Repeated AXI AW");
        ax_aw_pending <= 1'b1;
        ax_write_len <= top.bridge_axi_awlen;
        if (top.bridge_axi_awlen != 0 && top.bridge_axi_awlen != 15)
          $fatal(1, "Unsupported AXI write length");
        if (top.bridge_axi_awaddr[31:16] == 16'h8000) ax_ram_writes <= ax_ram_writes + 1;
        else ax_uart_writes <= ax_uart_writes + 1;
      end
      if (top.bridge_axi_wvalid && top.axi_bridge_wready) begin
        if (ax_write_last_seen && !ax_b_fire) $fatal(1, "Extra AXI W after LAST");
        ax_write_beats <= ax_b_fire ? 9'd1 : ax_write_beats + 9'd1;
        if (top.bridge_axi_wlast) ax_write_last_seen <= 1'b1;
        ax_w_pending <= 1'b1;
      end
      if (top.axi_bridge_bvalid && top.bridge_axi_bready) begin
        if (!ax_aw_pending || !ax_w_pending || !ax_write_last_seen ||
            ax_write_beats != {1'b0, ax_write_len} + 9'd1 || top.axi_bridge_bresp != 2'b00)
          $fatal(1, "Unexpected AXI write response/error");
      end
    end
  end
  final begin
    $display("[AXI-PATH] if_reads=%0d data_reads=%0d ram_writes=%0d uart_reads=%0d uart_writes=%0d",
             ax_if_reads, ax_data_reads, ax_ram_writes, ax_uart_reads, ax_uart_writes);
    $display("[AXI-COVERAGE] fetch_buffered=%0d overlap_cycles=%0d parallel_RW_beats=%0d simultaneous_RB=%0d",
             ax_fetch_buffered, ax_overlap_cycles, ax_parallel_data, ax_parallel_responses);
  end

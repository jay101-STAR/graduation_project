  // Included inside a temporary copy of the full-system testbench.
  bit jal_once_mode = $test$plusargs("jal_once");
  bit jal_check_mode = $test$plusargs("jal_checks");
  bit jal_inject_mode = $test$plusargs("jal_inject_waits");
  string jal_wave_file;
  integer jal_observed_edges = 0;
  integer jal_entry_edge = -1;
  bit jal_target_seen = 0;
  reg [31:0] jal_observed_target;
  integer jal_id_count = 0, jal_ex_count = 0;
  integer jal_priority_count = 0, jal_mul_waits = 0, jal_div_waits = 0;
  integer jal_memory_waits = 0, jal_ex_memory_waits = 0;
  bit jal_id_wait_injected = 0, jal_ex_wait_injected = 0;

  initial begin
    if ($value$plusargs("jal_wave=%s", jal_wave_file)) begin
      $dumpfile(jal_wave_file);
      $dumpvars(0, testbench);
    end
  end

  always @(posedge clk) begin
    // Observe after pipeline nonblocking assignments have settled.
    #1;
    jal_observed_edges = jal_observed_edges + 1;
    if (!top.u_core.rst && jal_once_mode) begin
      if (jal_entry_edge < 0 && top.u_core.if_id_valid &&
          top.u_core.id_aluc == `JAL_TYPE && top.u_core.id_rd_addr == 5'd7) begin
        jal_entry_edge = jal_observed_edges;
        jal_observed_target = top.u_core.id_pc + top.u_core.id_imm;
        $display("[JAL-ONCE] ID time=%0t pc=%08x target=%08x",
                 $time, top.u_core.id_pc, jal_observed_target);
      end
      if (jal_entry_edge >= 0 && !jal_target_seen && top.u_core.if_id_valid &&
          top.u_core.id_pc == jal_observed_target) begin
        jal_target_seen = 1;
        $display("[JAL-ONCE] TARGET time=%0t latency=%0d periods",
                 $time, jal_observed_edges - jal_entry_edge);
`ifdef JAL_ID_BASELINE
        if (jal_observed_edges - jal_entry_edge != 5)
`else
        if (jal_observed_edges - jal_entry_edge != 4)
`endif
          $fatal(1, "Unexpected JAL target latency");
      end
      if (tohost_value_register == 1 && !jal_target_seen)
        $fatal(1, "JAL test passed without observing its target");
    end
  end

`ifndef JAL_ID_BASELINE
  reg jal_sample_redirect, jal_sample_blocked, jal_sample_priority;
  reg [31:0] jal_sample_pc, jal_sample_target, jal_sample_ex_target;
  reg [31:0] jal_sample_fetch_pc, jal_sample_ex_pc;
  reg jal_sample_resolved;

  always @(posedge clk) begin
    if (jal_check_mode && !top.u_core.rst) begin
      jal_sample_redirect = top.u_core.id_jal_redirect;
      jal_sample_pc = top.u_core.id_pc;
      jal_sample_target = top.u_core.id_jal_target;
      jal_sample_ex_target = top.u_core.ex_pc_pc_data;
      jal_sample_blocked = top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
                           top.u_core.stall_if_id && !top.u_core.branch_flush;
      jal_sample_priority = top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
                            top.u_core.branch_flush && !top.u_core.stall_if_id;
      jal_sample_fetch_pc = top.u_core.core_instrom_addr;
      jal_sample_ex_pc = top.u_core.id_ex_pc;
      jal_sample_resolved = top.u_core.ex_jal_resolved;
      // Correctly predicted JALs advance without an ID redirect as well.
      if (top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
          !top.u_core.stall_if_id && !top.u_core.branch_flush)
        jal_id_count = jal_id_count + 1;
      if (jal_sample_priority) jal_priority_count = jal_priority_count + 1;
      if (jal_sample_blocked) begin
        if (top.u_core.id_jal_redirect) $fatal(1, "Stalled ID JAL issued a redirect");
        if (top.u_core.mul_hazard) jal_mul_waits = jal_mul_waits + 1;
        if (top.u_core.div_hazard) jal_div_waits = jal_div_waits + 1;
        if (top.u_core.top_core_mem_stall) jal_memory_waits = jal_memory_waits + 1;
      end
      if (top.u_core.ex_valid && top.u_core.ex_aluc == `JAL_TYPE) begin
        if (!top.u_core.ex_jal_resolved || top.u_core.ex0.pc_redirect_jal)
          $fatal(1, "JAL repeated its redirect in EX");
        if (!top.u_core.stall_ex_dataram) jal_ex_count = jal_ex_count + 1;
        if (top.u_core.top_core_mem_stall) jal_ex_memory_waits = jal_ex_memory_waits + 1;
      end
      if (jal_sample_priority && top.u_core.id_jal_redirect)
        $fatal(1, "Younger ID JAL overrode older EX redirect");
      #1;
      if (jal_sample_redirect) begin
        if (!top.u_core.ex_valid || !top.u_core.ex_jal_resolved ||
            top.u_core.id_ex_pc != jal_sample_pc ||
            top.u_core.ex_reg_rd_data != jal_sample_pc + 32'd4 ||
            top.u_core.core_instrom_addr != jal_sample_target ||
            top.u_core.if_id_valid || top.u_core.if1_valid || top.u_core.if2_valid ||
            top.u_core.if_stall_pending_valid)
          $fatal(1, "ID JAL failed target/link/metadata/frontend checks");
      end
      if (jal_sample_blocked && (top.u_core.id_pc != jal_sample_pc ||
          top.u_core.core_instrom_addr != jal_sample_fetch_pc ||
          top.u_core.id_ex_pc != jal_sample_ex_pc ||
          top.u_core.ex_jal_resolved != jal_sample_resolved))
        $fatal(1, "Stalled JAL metadata or PC was not held");
      if (jal_sample_priority && (top.u_core.core_instrom_addr != jal_sample_ex_target ||
          top.u_core.ex_valid || top.u_core.ex_jal_resolved))
        $fatal(1, "Older redirect failed to squash ID JAL");
    end
  end

  initial begin
    if (jal_inject_mode) begin
      wait (!top.u_core.rst && top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE);
      @(negedge clk);
      force top.top_core_mem_stall = 1'b1;
      repeat (4) @(negedge clk);
      release top.top_core_mem_stall;
      jal_id_wait_injected = 1;
      wait (top.u_core.ex_valid && top.u_core.ex_aluc == `JAL_TYPE && top.u_core.ex_jal_resolved);
      @(negedge clk);
      force top.top_core_mem_stall = 1'b1;
      repeat (3) @(negedge clk);
      release top.top_core_mem_stall;
      jal_ex_wait_injected = 1;
    end
  end

  always @(negedge clk) begin
    if (jal_check_mode && tohost_value_register == 1) begin
      if (jal_id_count != jal_ex_count || jal_id_count < 10 ||
          jal_priority_count < 3 || jal_mul_waits == 0 || jal_div_waits == 0)
        $fatal(1, "Insufficient JAL coverage or duplicate/lost JAL: id=%0d ex=%0d priority=%0d mul=%0d div=%0d",
               jal_id_count, jal_ex_count, jal_priority_count, jal_mul_waits, jal_div_waits);
      if (jal_inject_mode && (!jal_id_wait_injected || !jal_ex_wait_injected ||
          jal_memory_waits < 4 || jal_ex_memory_waits < 3))
        $fatal(1, "Missing forced ID/EX memory stall coverage");
      $display("[JAL-CHECKS] PASS id=%0d ex=%0d older_priority=%0d mul_wait=%0d div_wait=%0d memory_id=%0d memory_ex=%0d",
               jal_id_count, jal_ex_count, jal_priority_count, jal_mul_waits,
               jal_div_waits, jal_memory_waits, jal_ex_memory_waits);
      jal_check_mode = 0;
    end
  end
`endif

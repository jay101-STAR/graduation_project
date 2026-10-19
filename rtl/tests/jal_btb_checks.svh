  bit btb_check_mode = $test$plusargs("jal_btb_checks");
  bit btb_latency_mode = $test$plusargs("jal_btb_latency");
  bit btb_corrupt_mode = $test$plusargs("jal_btb_corrupt");
  bit btb_wait_mode = $test$plusargs("jal_btb_waits");
  string btb_wave_file;
  integer btb_edge = 0, btb_entry_edge = 0;
  integer btb_cold = 0, btb_warm = 0;
  integer btb_accepted = 0, btb_trained = 0, btb_correct = 0, btb_corrected = 0;
  integer btb_id_waits = 0, btb_ex_waits = 0;
  bit btb_pending = 0, btb_pending_prediction = 0;
  bit btb_corrupted = 0, btb_id_injected = 0, btb_ex_injected = 0;
  reg [31:0] btb_expected_target, btb_entry_pc;
  initial begin
    if ($value$plusargs("jal_btb_wave=%s", btb_wave_file)) begin
      $dumpfile(btb_wave_file);
      $dumpvars(0, testbench);
    end
  end

  // Raw ID-to-ID latency, observed after each edge, with no injected waits.
  always @(posedge clk) begin
    #1;
    btb_edge = btb_edge + 1;
    if (btb_latency_mode && !top.u_core.rst && top.u_core.if_id_valid) begin
      if (btb_pending && top.u_core.id_pc == btb_expected_target) begin
        $display("[JAL-BTB-LATENCY] pc=%08x predicted=%0d cycles=%0d target=%08x time=%0t",
                 btb_entry_pc, btb_pending_prediction, btb_edge - btb_entry_edge,
                 btb_expected_target, $time);
        if (btb_edge - btb_entry_edge != (btb_pending_prediction ? 1 : 4))
          $fatal(1, "Unexpected JAL ID-to-target latency");
        if (btb_pending_prediction) btb_warm = btb_warm + 1;
        else btb_cold = btb_cold + 1;
        btb_pending = 0;
      end
      if (top.u_core.id_aluc == `JAL_TYPE && !top.u_core.branch_flush &&
          !top.u_core.stall_if_id && tohost_value_register == 0) begin
        if (btb_pending) $fatal(1, "Another JAL arrived before the expected target");
        btb_pending = 1;
        btb_entry_pc = top.u_core.id_pc;
        btb_expected_target = top.u_core.id_jal_target;
        btb_entry_edge = btb_edge;
`ifdef JAL_BTB_BASELINE
        btb_pending_prediction = 0;
`else
        btb_pending_prediction = top.u_core.id_jal_prediction_ok;
`endif
      end
    end
  end

`ifndef JAL_BTB_BASELINE
  reg btb_sample_accept, btb_sample_ok;
  reg [31:0] btb_sample_pc;
  reg [9:0] btb_sample_ghr;
  reg [1:0] btb_sample_pht;
  reg [9:0] btb_sample_index;
  reg btb_sample_train;
  always @(posedge clk) begin
    if (btb_check_mode && !top.u_core.rst) begin
      btb_sample_accept = top.u_core.id_jal_advance;
      btb_sample_ok = top.u_core.id_jal_prediction_ok;
      btb_sample_pc = top.u_core.id_pc;
      btb_sample_train = top.u_core.branch_predictor0.ex_bp_update_wen &&
                         top.u_core.branch_predictor0.ex_bp_update_is_jal;
      btb_sample_index = top.u_core.ex_bp_update_pht_index;
      btb_sample_ghr = top.u_core.branch_predictor0.ghr;
      btb_sample_pht = top.u_core.branch_predictor0.pht_counter[btb_sample_index];
      if (btb_sample_accept) begin
        btb_accepted = btb_accepted + 1;
        if (btb_sample_ok) begin
          btb_correct = btb_correct + 1;
          if (top.u_core.frontend_flush) $fatal(1, "Correct JAL prediction flushed frontend");
        end else begin
          btb_corrected = btb_corrected + 1;
          if (!top.u_core.id_jal_redirect) $fatal(1, "ID did not correct JAL prediction");
        end
      end
      if (btb_sample_train) btb_trained = btb_trained + 1;
      if (!top.u_core.ex_valid || top.u_core.stall_ex_dataram)
        if (top.u_core.branch_predictor0.ex_bp_update_wen)
          $fatal(1, "Invalid/stalled EX instruction trained predictor");
      if (top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
          top.u_core.stall_if_id && top.u_core.id_jal_prediction_ok)
        btb_id_waits = btb_id_waits + 1;
      if (top.u_core.ex_valid && top.u_core.ex_is_jal && top.u_core.top_core_mem_stall)
        btb_ex_waits = btb_ex_waits + 1;
      #1;
      if (btb_sample_accept && (!top.u_core.ex_valid || !top.u_core.ex_jal_resolved ||
          top.u_core.id_ex_pc != btb_sample_pc ||
          top.u_core.ex_reg_rd_data != btb_sample_pc + 32'd4 || top.u_core.ex0.pc_redirect_jal))
        $fatal(1, "Predicted/corrected JAL lost its link or resolved flag");
      if (btb_sample_train && (top.u_core.branch_predictor0.ghr != btb_sample_ghr ||
          top.u_core.branch_predictor0.pht_counter[btb_sample_index] != btb_sample_pht))
        $fatal(1, "JAL polluted conditional direction history");
    end
  end

  initial begin
    if (btb_corrupt_mode) begin
      wait (!top.u_core.rst && top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
            top.u_core.id_rd_addr == 7 && top.u_core.id_jal_prediction_ok);
      @(negedge clk);
      force top.u_core.if_id_predicted_pc = 32'h8000_4000;
      @(posedge clk); #2;
      release top.u_core.if_id_predicted_pc;
      btb_corrupted = 1;
    end
  end
  initial begin
    if (btb_wait_mode) begin
      wait (!top.u_core.rst && top.u_core.if_id_valid && top.u_core.id_aluc == `JAL_TYPE &&
            top.u_core.id_rd_addr == 7 && top.u_core.id_jal_prediction_ok);
      @(negedge clk);
      force top.top_core_mem_stall = 1'b1;
      repeat (4) @(negedge clk);
      release top.top_core_mem_stall;
      btb_id_injected = 1;
      wait (top.u_core.ex_valid && top.u_core.ex_is_jal && top.u_core.ex_jal_resolved);
      @(negedge clk);
      force top.top_core_mem_stall = 1'b1;
      repeat (3) @(negedge clk);
      release top.top_core_mem_stall;
      btb_ex_injected = 1;
    end
  end
`endif

  always @(negedge clk) begin
    if ((btb_check_mode || btb_latency_mode) && tohost_value_register == 1) begin
      if (btb_latency_mode) begin
`ifdef JAL_BTB_BASELINE
        if (btb_cold < 10 || btb_warm != 0) $fatal(1, "Missing baseline latency coverage");
`else
        if (btb_cold < 3 || btb_warm < 10) $fatal(1, "Missing cold/warm JAL latency coverage");
`endif
      end
`ifndef JAL_BTB_BASELINE
      if (btb_check_mode && (btb_accepted != btb_trained || btb_accepted < 10))
        $fatal(1, "Duplicate/lost JAL training: accepted=%0d trained=%0d", btb_accepted, btb_trained);
      if (btb_corrupt_mode && !btb_corrupted) $fatal(1, "Wrong-target injection missing");
      if (btb_wait_mode && (!btb_id_injected || !btb_ex_injected || btb_id_waits < 4 || btb_ex_waits < 3))
        $fatal(1, "Warm JAL stall injection missing");
`endif
      $display("[JAL-BTB-CHECKS] PASS accepted=%0d trained=%0d correct=%0d corrected=%0d cold=%0d warm=%0d id_wait=%0d ex_wait=%0d",
               btb_accepted, btb_trained, btb_correct, btb_corrected,
               btb_cold, btb_warm, btb_id_waits, btb_ex_waits);
      btb_check_mode = 0;
      btb_latency_mode = 0;
    end
  end

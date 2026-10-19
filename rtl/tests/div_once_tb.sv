`timescale 1ns / 1ns

// Standalone waveform bench for vsrc/instrom/div_once.s.
module testbench;
  reg clk = 1'b0;
  reg rst = 1'b1;
  wire [31:0] tohost_value_register, tohost_value_dataram;
  wire [31:0] bp_branch_total, bp_mispredict_total, bp_target_miss_total;
  wire uart_txd;
  string wave_file;
  integer starts = 0;
  integer accepts = 0;
  integer hazard_cycles = 0;
  integer iterations = 0;
  bit full_iterations;
  reg [31:0] expected_result;
  reg [31:0] expected_remainder;
  integer expected_ex_cycles;
  integer stall_cycles = 0;
  integer stall_after = 7;
  integer entry_edge = -1;
  integer edge_count = 0;
  integer ex_cycles = 0;
  bit reached_mem = 1'b0;

  top top (
      .clk(clk), .rst(rst),
      .tohost_value_register(tohost_value_register),
      .tohost_value_dataram(tohost_value_dataram),
      .bp_branch_total(bp_branch_total),
      .bp_mispredict_total(bp_mispredict_total),
      .bp_target_miss_total(bp_target_miss_total),
      .ext_top_uart_rxd(1'b1), .ext_top_uart_txd(uart_txd)
  );

  always #10 clk = ~clk;

  initial begin
    if (!$value$plusargs("wave=%s", wave_file)) wave_file = "div_once.vcd";
    if (!$value$plusargs("expected=%d", expected_result)) expected_result = 33;
    if (!$value$plusargs("expected_remainder=%d", expected_remainder)) expected_remainder = 1;
    if (!$value$plusargs("expected_ex=%d", expected_ex_cycles)) expected_ex_cycles = 9;
    full_iterations = $test$plusargs("full_iterations");
    if (full_iterations) begin
      // Waveform experiment: keep the ordinary 100/3 path but do all 32 steps.
      // Force both uses of the skip count (counter and initial dividend shift).
      force top.u_core.ex0.div0.div_skip_count = 6'd0;
      $display("[DIV] Full-iteration mode: prefix skip disabled by testbench");
    end
    $dumpfile(wave_file);
    $dumpvars(0, testbench);
    #100 rst = 1'b0;
    #10000;
    $fatal(1, "TIMEOUT");
  end

  initial begin
    if (!$value$plusargs("stall_cycles=%d", stall_cycles)) stall_cycles = 0;
    if (!$value$plusargs("stall_after=%d", stall_after)) stall_after = 7;
    if (stall_cycles > 0) begin
      wait (!rst && top.u_core.ex_valid && top.u_core.ex_is_div_instruction);
      repeat (stall_after + 1) @(negedge clk);
      force top.top_core_mem_stall = 1'b1;
      repeat (stall_cycles) @(negedge clk);
      release top.top_core_mem_stall;
    end
  end

  always @(posedge clk) begin
    // Count requests using the values actually sampled at this edge.
    if (!rst && top.u_core.ex0.div_start) starts = starts + 1;
    if (!rst && top.u_core.ex0.div_result_accept) accepts = accepts + 1;
    if (!rst && top.u_core.div_hazard) hazard_cycles = hazard_cycles + 1;
    if (!rst && full_iterations && top.u_core.ex0.div0.current_state == 2'd1 &&
        top.u_core.ex0.div0.cnt < 6'd32 && !top.u_core.ex0.div_done_raw)
      iterations = iterations + 1;
    // Inspect registers after nonblocking assignments settle.
    #1;
    edge_count = edge_count + 1;
    if (!rst) begin
      if (top.u_core.ex0.div_done_latched && top.u_core.top_core_mem_stall) begin
        if (!top.u_core.ex0.div_inflight || top.u_core.ex0.div_start ||
            !top.u_core.ex_div_done || top.u_core.ex0.div_result_q_raw != expected_result ||
            top.u_core.ex0.div_result_r_raw != expected_remainder)
          $fatal(1, "Pending DIV result was not held under memory backpressure");
      end
      if (entry_edge < 0 && top.u_core.ex_valid &&
          top.u_core.ex_is_div_instruction) begin
        entry_edge = edge_count;
        $display("[DIV] EX entry at %0t, pc=%08x", $time, top.u_core.id_ex_pc);
      end
      if (entry_edge >= 0 && !reached_mem) begin
        $display("[DIV] E%0d time=%0t ex_div=%0b state=%0d cnt=%0d raw=%0b latched=%0b stall=%0b mem_rd=%0d mem_result=%0d",
                 edge_count - entry_edge, $time, top.u_core.ex_is_div_instruction,
                 top.u_core.ex0.div0.current_state, top.u_core.ex0.div0.cnt,
                 top.u_core.ex0.div_done_raw,
                 top.u_core.ex0.div_done_latched, top.u_core.stall_ex_dataram,
                 top.u_core.ex_dataram_rd_addr, top.u_core.ex_dataram_alu_result);
        if (top.u_core.ex_dataram_valid && top.u_core.ex_dataram_rd_wen &&
            top.u_core.ex_dataram_rd_addr == 5'd7) begin
          reached_mem = 1'b1;
          ex_cycles = edge_count - entry_edge;
          if (top.u_core.ex_dataram_alu_result != expected_result)
            $fatal(1, "Incorrect DIV result");
          if (ex_cycles != expected_ex_cycles ||
              top.u_core.ex0.div_result_r_raw != expected_remainder)
            $fatal(1, "Incorrect DIV latency or remainder");
          $display("[DIV] EX residence=%0d complete clock periods (%0d ns)",
                   ex_cycles, ex_cycles * 20);
        end
      end
      if (tohost_value_register != 0) begin
        if (tohost_value_register != 1 || starts != 1 || accepts != 1 || !reached_mem)
          $fatal(1, "FAIL: tohost=%0d starts=%0d accepts=%0d reached_mem=%0b",
                 tohost_value_register, starts, accepts, reached_mem);
        if (full_iterations && (iterations != 32 ||
            hazard_cycles != 33 || top.u_core.ex0.div0.div_result_r != 32'd1))
          $fatal(1, "Full-iteration check failed: iterations=%0d EX=%0d hazard=%0d remainder=%0d",
                 iterations, ex_cycles, hazard_cycles, top.u_core.ex0.div0.div_result_r);
        if (full_iterations) $display("[DIV] Verified 32 iterations, quotient=33, remainder=1");
        $display("TEST PASSED: one DIV, result=%0d, EX cycles=%0d, hazard cycles=%0d, starts=%0d accepts=%0d",
                 expected_result, ex_cycles, hazard_cycles, starts, accepts);
        #40;
        $finish;
      end
    end
  end
endmodule

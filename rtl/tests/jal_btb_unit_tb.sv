`timescale 1ns / 1ns
module jal_btb_unit_tb;
  reg clk = 0;
  always #5 clk = !clk;
  reg rst = 1, invalidate = 0, update = 0, is_jal = 0, taken = 0;
  reg [31:0] pc = 0, update_pc = 0, target = 0;
  reg [9:0] index = 0;
  wire predict;
  wire [31:0] predicted_pc;
  wire [9:0] predicted_index;
  reg [9:0] saved_ghr;
  reg [1:0] saved_pht [0:1023];
  integer i, checks = 0;

  branch_predictor #(.ENTRY_NUM(4)) dut (
    .clk(clk), .rst(rst), .invalidate(invalidate),
    .if_bp_pc(pc), .if_bp_predict_taken(predict),
    .if_bp_predict_pc(predicted_pc), .if_bp_predict_pht_index(predicted_index),
    .ex_bp_update_wen(update), .ex_bp_update_is_jal(is_jal),
    .ex_bp_update_pc(update_pc), .ex_bp_update_taken(taken),
    .ex_bp_update_target(target), .ex_bp_update_pht_index(index)
  );

  task tick;
    @(posedge clk); #1;
  endtask
  task train(input [31:0] source, input [31:0] destination,
             input jal_kind, input direction, input [9:0] pht_index);
    @(negedge clk);
    update = 1; update_pc = source; target = destination;
    is_jal = jal_kind; taken = direction; index = pht_index;
    tick();
    @(negedge clk); update = 0;
  endtask
  task expect_prediction(input [31:0] source, input expected_taken,
                         input [31:0] destination);
    pc = source; #1;
    if (predict !== expected_taken || (expected_taken && predicted_pc !== destination))
      $fatal(1, "prediction source=%08x taken=%b target=%08x expected=%b/%08x",
             source, predict, predicted_pc, expected_taken, destination);
    checks = checks + 1;
  endtask
  task save_direction;
    saved_ghr = dut.ghr;
    for (i = 0; i < 1024; i = i + 1) saved_pht[i] = dut.pht_counter[i];
  endtask
  task expect_direction_unchanged;
    if (dut.ghr !== saved_ghr) $fatal(1, "JAL/invalidate changed GHR");
    for (i = 0; i < 1024; i = i + 1)
      if (dut.pht_counter[i] !== saved_pht[i]) $fatal(1, "JAL/invalidate changed PHT %0d", i);
    checks = checks + 1;
  endtask

  initial begin
    tick(); @(negedge clk); rst = 0;
    expect_prediction(32'h1000, 0, 0);
    save_direction();
    train(32'h1000, 32'h2000, 1, 1, 0);
    expect_direction_unchanged();
    expect_prediction(32'h1000, 1, 32'h2000); // PHT remains weak-not-taken.
    train(32'h1008, 32'h3000, 1, 1, 0);
    expect_prediction(32'h1000, 1, 32'h2000);
    expect_prediction(32'h1008, 1, 32'h3000);
    train(32'h1010, 32'h4000, 1, 1, 0);
    expect_prediction(32'h1000, 0, 0); // LRU replacement, no false tag hit.
    expect_prediction(32'h1008, 1, 32'h3000);
    expect_prediction(32'h1010, 1, 32'h4000);
    train(32'h1010, 32'h5000, 1, 1, 0);
    expect_prediction(32'h1010, 1, 32'h5000);
    expect_direction_unchanged();

    // Overwrite the same PC with a conditional branch: direction is respected.
    train(32'h1010, 32'h6000, 0, 0, 0);
    expect_prediction(32'h1010, 0, 0);
    train(32'h1010, 32'h7000, 1, 1, 0);
    expect_prediction(32'h1010, 1, 32'h7000);
    // Repeated taken branches eventually use stable all-taken history.
    pc = 32'h1004; #1;
    repeat (12) train(32'h1004, 32'h8000, 0, 1, predicted_index);
    expect_prediction(32'h1004, 1, 32'h8000);
    // Regardless of direction state, JAL must leave all 1024 counters intact.
    save_direction();
    train(32'h1000, 32'h2000, 1, 1, 17);
    expect_direction_unchanged();

    // FENCE.I wins over a simultaneous training request and preserves gshare.
    @(negedge clk); invalidate = 1; update = 1;
    tick(); @(negedge clk); invalidate = 0; update = 0;
    expect_prediction(32'h1000, 0, 0);
    expect_prediction(32'h1004, 0, 0);
    expect_direction_unchanged();
    // Two reset pulses must not revive entries trained before the first reset.
    train(32'h1000, 32'h2000, 1, 1, 0);
    @(negedge clk); rst = 1; tick(); @(negedge clk); rst = 0; tick();
    @(negedge clk); rst = 1; tick(); @(negedge clk); rst = 0;
    expect_prediction(32'h1000, 0, 0);
    $display("[JAL-BTB-UNIT] PASS checks=%0d", checks);
    $finish;
  end
  initial begin #10000; $fatal(1, "unit timeout"); end
endmodule

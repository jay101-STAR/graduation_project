`timescale 1ns / 1ns

// Legacy array-interface tests for icache.sv: 128 sets, four
// ways, 64-byte lines, active-low asynchronous reset, registered read outputs.
// No CPU, bus, or refill controller is instantiated. Read addresses are aligned
// 32-bit instructions; block_data[31:0] is the first word of an aligned line.
module icache_unit_tb;
  logic clk = 1'b0;
  logic rst_n = 1'b1;
  logic [31:0] address = 32'b0;
  logic ren = 1'b0, wen = 1'b0;
  logic [511:0] block_data = 512'b0;
  wire [31:0] inst;
  wire hit;
  string test_case, wave;
  integer checks = 0, seed = 493, operations = 0;
  logic [31:0] random_state;
  bit present [0:127][0:3];
  integer generation [0:127][0:3];
  icache dut (
      .clk(clk), .rst_n(rst_n), .address(address), .ren(ren), .wen(wen),
      .block_data(block_data), .inst(inst), .hit(hit)
  );
  always #5 clk = ~clk;

  function automatic logic [31:0] line_addr(input integer set_id, input integer tag_id);
    return {19'(19'h40000 + 19'(tag_id)), 7'(set_id), 6'b0};
  endfunction
  function automatic logic [31:0] word_data(input logic [31:0] base,
                                           input integer word_id, input integer version);
    return {base[31:6], 6'b0} ^ (32'h9e3779b9 * (32'(word_id) + 32'd1)) ^
           (32'h85ebca6b * (32'(version) + 32'd1));
  endfunction
  function automatic logic [511:0] line_data(input logic [31:0] base, input integer version);
    logic [511:0] result;
    for (int word_id = 0; word_id < 16; word_id++)
      result[word_id*32 +: 32] = word_data(base, word_id, version);
    return result;
  endfunction
  task automatic check(input bit okay, input string message);
    checks++;
    if (!okay) begin
      $display("[ICACHE-FAIL] case=%s operation=%0d address=%08h ren=%b wen=%b hit=%b inst=%08h: %s",
               test_case, operations, address, ren, wen, hit, inst, message);
      $fatal(1, "ICache unit assertion failed");
    end
  endtask
  task automatic reset_cache;
    @(negedge clk);
    rst_n = 1'b0;
    ren = 1'b0;
    wen = 1'b0;
    #1;
    check(hit === 1'b0 && inst === 32'b0, "asynchronous reset must clear outputs");
    repeat (2) @(negedge clk);
    rst_n = 1'b1;
  endtask
  task automatic access(input logic [31:0] addr, input bit read_en,
                        input bit write_en, input logic [511:0] data);
    @(negedge clk);
    address = addr;
    ren = read_en;
    wen = write_en;
    block_data = data;
    @(posedge clk);
    #1;
    operations++;
  endtask
  task automatic fill(input logic [31:0] base, input integer version = 0);
    access(base, 0, 1, line_data(base, version));
    check(hit === 1'b0 && inst === 32'b0, "fill with ren=0 must not return a read");
  endtask
  task automatic read_word(input logic [31:0] base, input integer word_id,
                           input bit expected_hit, input integer version = 0);
    logic [31:0] expected;
    expected = expected_hit ? word_data(base, word_id, version) : 32'b0;
    access({base[31:6], 6'b0} + 32'(word_id * 4), 1, 0, 512'b0);
    check(hit === expected_hit && inst === expected,
          $sformatf("expected hit=%b inst=%08h (line=%08h word=%0d version=%0d)",
                    expected_hit, expected, base, word_id, version));
  endtask

  task automatic reset_test;
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(set_id, tag_id));
    read_word(line_addr(0, 0), 0, 1);
    read_word(line_addr(127, 3), 15, 1);
    reset_cache();
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++) read_word(line_addr(set_id, tag_id), 0, 0);
    fill(line_addr(127, 3), 17);
    read_word(line_addr(127, 3), 15, 1, 17);
  endtask
  task automatic line_words_test;
    logic [31:0] base;
    base = line_addr(73, 17);
    // A nonzero write address offset must not change the aligned line's layout.
    fill(base + 32'd28, 31);
    for (int word_id = 0; word_id < 16; word_id++) read_word(base, word_id, 1, 31);
    read_word(base + 32'd64, 0, 0);
    read_word(base + 32'd8192, 0, 0);
    fill(32'hffffffc0, 7);
    read_word(32'hffffffc0, 15, 1, 7);
    fill(32'h00000000, 9);
    read_word(32'h00000000, 0, 1, 9);
  endtask
  task automatic all_sets_ways_test;
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(set_id, tag_id), set_id + tag_id);
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++)
        for (int word_id = 0; word_id < 16; word_id++)
          read_word(line_addr(set_id, tag_id), word_id, 1, set_id + tag_id);
  endtask
  task automatic address_bits_test;
    logic [31:0] first, second;
    first = 32'h80000000;
    for (int bit_id = 6; bit_id < 32; bit_id++) begin
      reset_cache();
      second = first ^ (32'd1 << bit_id);
      fill(first, 11);
      fill(second, 12);
      read_word(first, 0, 1, 11);
      read_word(first, 15, 1, 11);
      read_word(second, 0, 1, 12);
      read_word(second, 15, 1, 12);
    end
  endtask
  task automatic enables_timing_test;
    logic [31:0] base;
    base = line_addr(21, 0);
    fill(base, 5);
    read_word(base, 0, 1, 5);
    // Address and enable changes must not combinationally alter read outputs.
    address = base + 32'd4;
    #1;
    check(hit === 1'b1 && inst === word_data(base, 0, 5), "registered output changed before clock");
    @(posedge clk);
    #1;
    check(hit === 1'b1 && inst === word_data(base, 1, 5), "next clock did not sample new word");
    ren = 1'b0;
    #1;
    check(hit === 1'b1, "ren must be sampled on clock");
    @(posedge clk);
    #1;
    check(hit === 1'b0 && inst === 32'b0, "ren=0 must clear read outputs next clock");
    access(line_addr(21, 1), 0, 0, line_data(line_addr(21, 1), 99));
    read_word(line_addr(21, 1), 0, 0);
    read_word(base, 1, 1, 5);
  endtask
  task automatic four_way_capacity_test;
    integer survivors;
    for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(42, tag_id));
    for (int tag_id = 0; tag_id < 4; tag_id++) read_word(line_addr(42, tag_id), 0, 1);
    fill(line_addr(42, 4));
    survivors = 0;
    for (int tag_id = 0; tag_id < 4; tag_id++) begin
      access(line_addr(42, tag_id), 1, 0, 512'b0);
      if (hit) begin
        survivors++;
        check(inst === word_data(line_addr(42, tag_id), 0, 0), "surviving line data changed");
      end else check(inst === 32'b0, "miss data must be zero");
    end
    check(survivors == 3, "fifth distinct line must evict exactly one of four resident lines");
    read_word(line_addr(42, 4), 0, 1);
  endtask
  task automatic plru_read_history_test;
    integer left_candidate, right_candidate, candidate_half, selected, victim;
    for (int history = 0; history < 64; history++) begin
      reset_cache();
      for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(37, tag_id));
      // Abstract tree: the candidate subtree is opposite the last touched
      // subtree; each leaf candidate is opposite that pair's last touched way.
      left_candidate = 0;
      right_candidate = 2;
      candidate_half = 0;
      for (int position = 0; position < 3; position++) begin
        selected = (history >> (position * 2)) & 3;
        read_word(line_addr(37, selected), position, 1);
        if (selected < 2) begin
          candidate_half = 1;
          left_candidate = 1 - selected;
        end else begin
          candidate_half = 0;
          right_candidate = 5 - selected;
        end
      end
      victim = (candidate_half == 0) ? left_candidate : right_candidate;
      fill(line_addr(37, 4));
      for (int tag_id = 0; tag_id < 4; tag_id++) read_word(line_addr(37, tag_id), 15, tag_id != victim);
      read_word(line_addr(37, 4), 0, 1);
    end
  endtask
  task automatic set_isolation_test;
    for (int tag_id = 0; tag_id < 4; tag_id++) begin
      fill(line_addr(5, tag_id));
      fill(line_addr(127, tag_id));
    end
    read_word(line_addr(5, 0), 0, 1);    // set 5 should evict way 2
    read_word(line_addr(127, 2), 0, 1);  // set 127 should evict way 0
    fill(line_addr(5, 4));
    fill(line_addr(127, 4));
    for (int tag_id = 0; tag_id < 4; tag_id++) begin
      read_word(line_addr(5, tag_id), 0, tag_id != 2);
      read_word(line_addr(127, tag_id), 0, tag_id != 0);
    end
    read_word(line_addr(5, 4), 15, 1);
    read_word(line_addr(127, 4), 15, 1);
  endtask
  task automatic read_fill_miss_test;
    logic [31:0] base;
    base = line_addr(31, 5);
    access(base + 32'd60, 1, 1, line_data(base, 3));
    check(hit === 1'b0 && inst === 32'b0, "read and fill of missing line must observe pre-edge miss");
    read_word(base, 15, 1, 3);
    read_word(base, 0, 1, 3);
  endtask
  task automatic random_fits_test;
    integer set_id, tag_id, word_id, mode, version;
    logic [31:0] base;
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++) begin
        present[set_id][tag_id] = 0;
        generation[set_id][tag_id] = 0;
      end
    random_state = 32'(seed);
    for (int operation = 0; operation < 10000; operation++) begin
      random_state ^= random_state << 13;
      random_state ^= random_state >> 17;
      random_state ^= random_state << 5;
      set_id = int'(random_state[6:0]);
      tag_id = int'(random_state[8:7]);
      word_id = int'(random_state[12:9]);
      mode = int'(random_state[14:13]);
      version = int'(random_state[22:15]);
      base = line_addr(set_id, tag_id);
      if (!present[set_id][tag_id] && mode == 0) begin
        fill(base, version);
        present[set_id][tag_id] = 1;
        generation[set_id][tag_id] = version;
      end else if (mode == 1) begin
        access(base, 0, 0, line_data(base, version));
        check(hit === 1'b0 && inst === 32'b0, "idle cycle returned data");
      end else read_word(base, word_id, present[set_id][tag_id], generation[set_id][tag_id]);
    end
    // A final exhaustive sweep checks all allocated lines against the oracle.
    for (int set_id = 0; set_id < 128; set_id++)
      for (int tag_id = 0; tag_id < 4; tag_id++)
        for (int word_id = 0; word_id < 16; word_id++)
          read_word(line_addr(set_id, tag_id), word_id, present[set_id][tag_id], generation[set_id][tag_id]);
  endtask
  // The following two cases intentionally exercise contracts not documented
  // by icache.sv. They are reported separately from the supported basic tests.
  task automatic refill_recency_test;
    for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(19, tag_id));
    fill(line_addr(19, 4));
    fill(line_addr(19, 5));
    read_word(line_addr(19, 5), 0, 1);
    // An installed line counted as recently used should survive the next fill.
    read_word(line_addr(19, 4), 0, 1);
  endtask
  task automatic duplicate_fill_test;
    for (int tag_id = 0; tag_id < 4; tag_id++) fill(line_addr(19, tag_id), 1);
    // Current victim is way 0. Refilling tag 1 must not leave an older duplicate
    // in another way that wins the read mux and returns stale instructions.
    fill(line_addr(19, 1), 2);
    read_word(line_addr(19, 1), 0, 1, 2);
  endtask

  initial begin
    if (!$value$plusargs("case=%s", test_case)) test_case = "line_words";
    if ($value$plusargs("seed=%d", seed)) begin end
    if ($value$plusargs("wave=%s", wave)) begin
      $dumpfile(wave);
      $dumpvars(0, icache_unit_tb);
    end
    reset_cache();
    case (test_case)
      "reset": reset_test();
      "line_words": line_words_test();
      "all_sets_ways": all_sets_ways_test();
      "address_bits": address_bits_test();
      "enables_timing": enables_timing_test();
      "four_way_capacity": four_way_capacity_test();
      "plru_read_history": plru_read_history_test();
      "set_isolation": set_isolation_test();
      "read_fill_miss": read_fill_miss_test();
      "random_fits": random_fits_test();
      "refill_recency": refill_recency_test();
      "duplicate_fill": duplicate_fill_test();
      default: $fatal(1, "Unknown case: %s", test_case);
    endcase
    $display("[ICACHE-UNIT] PASS case=%s seed=%0d operations=%0d checks=%0d", test_case, seed, operations, checks);
    $finish;
  end
  initial begin
    #10000000;
    $fatal(1, "ICache unit timeout case=%s", test_case);
  end
endmodule

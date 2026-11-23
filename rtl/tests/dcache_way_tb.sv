`timescale 1ns/1ps

// Check way selection independently of the CPU store-response protocol.
module dcache_way_tb;
  logic clk = 1'b0;
  always #5 clk = !clk;
  logic rst_n = 1'b0;
  logic cpu_req_valid = 1'b0;
  logic cpu_req_ready;
  logic [33:0] cpu_req_addr = 34'b0;
  logic [31:0] cpu_req_wdata = 32'b0;
  logic [3:0] cpu_req_wstrb = 4'b0;
  logic cpu_req_write = 1'b0;
  logic cpu_rsp_valid;
  logic cpu_rsp_ready = 1'b1;
  logic [31:0] cpu_rsp_rdata;
  logic mem_req_valid;
  logic [33:0] mem_req_addr;
  logic mem_req_ready;
  logic mem_req_write;
  logic [31:0] mem_req_wdata;
  logic mem_rsp_valid;
  logic mem_rsp_ready;
  logic [31:0] mem_rsp_rdata;
  logic pending = 1'b0;
  logic delay_memory = 1'b0;
  logic [31:0] pending_data = 32'b0;
  logic stalled = 1'b0;
  logic [66:0] stalled_payload;
  logic [33:0] write_addr [16];
  logic [31:0] write_data [16];
  int response_delay = 0;
  int cycles = 0;
  int reads = 0;
  int writes = 0;
  int responses = 0;
  int checks = 0;
  string scenario;
  string wave_path;
  localparam logic [33:0] BASE = 34'h080000000;
  localparam logic [33:0] MISS = BASE + 34'h8000;

  dcache dut (
    .mem_rsp_error(1'b0), .cpu_rsp_error(),
    .maint_req_valid(1'b0), .maint_req_ready(),
    .maint_done_valid(), .maint_done_ready(1'b1), .maint_error(),
    .*
  );

  assign mem_req_ready = !pending && (!delay_memory || cycles[1:0] == 2'b00);
  assign mem_rsp_valid = pending && response_delay == 0;
  assign mem_rsp_rdata = pending_data;

  function automatic logic [31:0] memory_word(input logic [33:0] addr);
    return addr[31:0] ^ 32'h5a5aa5a5 ^ {30'b0, addr[33:32]};
  endfunction

  function automatic logic [31:0] line_word(input int way);
    return 32'h10203040 + 32'(way);
  endfunction

  always @(posedge clk) begin
    if (!rst_n) begin
      pending <= 1'b0;
      stalled <= 1'b0;
      response_delay <= 0;
      cycles <= 0;
      reads <= 0;
      writes <= 0;
      responses <= 0;
    end else begin
      cycles <= cycles + 1;
      if (stalled && (!mem_req_valid ||
          {mem_req_addr, mem_req_write, mem_req_wdata} !== stalled_payload))
        $fatal(1, "Memory request changed while stalled");
      stalled <= mem_req_valid && !mem_req_ready;
      stalled_payload <= {mem_req_addr, mem_req_write, mem_req_wdata};
      if (cpu_rsp_valid && cpu_rsp_ready) responses <= responses + 1;
      if (pending && response_delay != 0) response_delay <= response_delay - 1;
      if (mem_rsp_valid && mem_rsp_ready) pending <= 1'b0;
      if (mem_req_valid && mem_req_ready) begin
        pending <= 1'b1;
        response_delay <= delay_memory ? 2 : 0;
        pending_data <= memory_word(mem_req_addr);
        if (mem_req_write) begin
          if (writes >= 16) $fatal(1, "Unexpected extra writeback word");
          write_addr[writes] <= mem_req_addr;
          write_data[writes] <= mem_req_wdata;
          writes <= writes + 1;
        end else begin
          reads <= reads + 1;
        end
      end
    end
  end

  task automatic tick(input int count = 1);
    repeat (count) begin @(posedge clk); #1; end
  endtask

  task automatic reset_cache(input bit delayed);
    @(negedge clk);
    rst_n = 1'b0;
    cpu_req_valid = 1'b0;
    cpu_req_write = 1'b0;
    cpu_rsp_ready = 1'b1;
    delay_memory = delayed;
    tick(2);
    @(negedge clk); rst_n = 1'b1;
    tick();
  endtask

  task automatic seed_line(input int set_index, input int way,
                           input logic [33:0] addr, input bit valid,
                           input bit dirty);
    dut.tag_mem[set_index][way].valid = valid;
    dut.tag_mem[set_index][way].dirty = dirty;
    dut.tag_mem[set_index][way].tag = addr[33:13];
    dut.data_mem[set_index][way] = {16{line_word(way)}};
  endtask

  task automatic issue(input logic [33:0] addr, input bit wr = 1'b0,
                       input logic [31:0] data = 32'b0,
                       input logic [3:0] mask = 4'b0);
    int waited;
    @(negedge clk);
    cpu_req_addr = addr;
    cpu_req_write = wr;
    cpu_req_wdata = data;
    cpu_req_wstrb = mask;
    cpu_req_valid = 1'b1;
    waited = 0;
    do begin
      @(posedge clk);
      waited++;
      if (waited > 2000) $fatal(1, "CPU request timeout");
    end while (!cpu_req_ready);
    @(negedge clk); cpu_req_valid = 1'b0;
  endtask

  task automatic await_reads(input int expected_responses);
    for (int i = 0; i < 2000; i++) begin
      tick();
      if (responses == expected_responses) return;
    end
    $fatal(1, "Read response timeout: got %0d expected %0d", responses, expected_responses);
  endtask

  task automatic check_miss(input int previous_way, input int selected_way,
                            input logic [3:0] valid_mask,
                            input bit selected_dirty, input bit delayed);
    logic [2:0] plru;
    reset_cache(delayed);
    @(negedge clk);
    for (int w = 0; w < 4; w++) begin
      seed_line(0, w, BASE + 34'(w * 8192), valid_mask[w],
                valid_mask[w] && ((w == selected_way) ? selected_dirty : !selected_dirty));
    end
    seed_line(1, previous_way, BASE + 34'h40, 1'b1, 1'b0);
    case (selected_way)
      0: plru = 3'b000;
      1: plru = 3'b001;
      2: plru = 3'b100;
      3: plru = 3'b110;
      default: $fatal(1, "Bad test way");
    endcase
    dut.plur_state[0] = plru;
    issue(BASE + 34'h40);
    await_reads(1);
    tick();
    issue(MISS);
    await_reads(2);
    if (reads != 16 || writes != (selected_dirty ? 16 : 0))
      $fatal(1, "prev=%0d victim=%0d valid=%04b dirty=%0d: reads=%0d writes=%0d",
             previous_way, selected_way, valid_mask, selected_dirty, reads, writes);
    if (dut.tag_mem[0][selected_way].tag != MISS[33:13] ||
        !dut.tag_mem[0][selected_way].valid || dut.tag_mem[0][selected_way].dirty)
      $fatal(1, "Refill installed in wrong way: expected %0d", selected_way);
    for (int w = 0; w < 4; w++) begin
      if (w != selected_way &&
          (dut.tag_mem[0][w].valid != valid_mask[w] ||
           dut.tag_mem[0][w].tag != (BASE + 34'(w * 8192)) >> 13))
        $fatal(1, "Refill changed unrelated way %0d", w);
      for (int word_index = 0; word_index < 16; word_index++) begin
        if (dut.data_mem[0][w][word_index*32 +: 32] !=
            ((w == selected_way) ? memory_word(MISS + 34'(word_index * 4)) : line_word(w)))
          $fatal(1, "Wrong refill data: way=%0d word=%0d", w, word_index);
      end
    end
    if (selected_dirty) begin
      for (int word_index = 0; word_index < 16; word_index++) begin
        if (write_addr[word_index] != BASE + 34'(selected_way * 8192 + word_index * 4) ||
            write_data[word_index] != line_word(selected_way))
          $fatal(1, "Wrong writeback address/data at word %0d", word_index);
      end
    end
    checks++;
  endtask

  task automatic check_store_hit(input int previous_way, input int selected_way,
                                 input bit byte_store);
    logic [31:0] expected_word;
    reset_cache(1'b0);
    @(negedge clk);
    for (int w = 0; w < 4; w++)
      seed_line(0, w, BASE + 34'(w * 8192), 1'b1, 1'b0);
    issue(BASE + 34'(previous_way * 8192));
    await_reads(1);
    tick();
    issue(BASE + 34'(selected_way * 8192 + 12), 1'b1,
          32'hdeadbeef, byte_store ? 4'b0010 : 4'b1111);
    tick(4);
    if (reads != 0 || writes != 0) $fatal(1, "Store hit accessed memory");
    for (int w = 0; w < 4; w++) begin
      if (dut.tag_mem[0][w].dirty != (w == selected_way))
        $fatal(1, "Store dirtied wrong way: previous=%0d selected=%0d way=%0d",
               previous_way, selected_way, w);
      for (int word_index = 0; word_index < 16; word_index++) begin
        expected_word = line_word(w);
        if (w == selected_way && word_index == 3) begin
          if (byte_store) expected_word[15:8] = 8'hbe;
          else expected_word = 32'hdeadbeef;
        end
        if (dut.data_mem[0][w][word_index*32 +: 32] != expected_word)
          $fatal(1, "Store changed wrong way/word: previous=%0d selected=%0d way=%0d word=%0d",
                 previous_way, selected_way, w, word_index);
      end
    end
    checks++;
  endtask

  initial begin
    if ($value$plusargs("wave=%s", wave_path)) begin
      $dumpfile(wave_path);
      $dumpvars(0, dcache_way_tb);
    end
    if (!$value$plusargs("case=%s", scenario)) scenario = "matrix";
    case (scenario)
      "dirty_victim": check_miss(2, 0, 4'b1111, 1'b1, 1'b0);
      "hit_after_hit": check_store_hit(2, 0, 1'b0);
      "empty_way": check_miss(3, 2, 4'b0011, 1'b0, 1'b1);
      "matrix": begin
        for (int previous_way = 0; previous_way < 4; previous_way++) begin
          for (int selected_way = 0; selected_way < 4; selected_way++) begin
            check_miss(previous_way, selected_way, 4'b1111, 1'b0, 1'b1);
            check_miss(previous_way, selected_way, 4'b1111, 1'b1, 1'b1);
            check_store_hit(previous_way, selected_way, 1'b0);
            check_store_hit(previous_way, selected_way, 1'b1);
          end
          for (int mask = 0; mask < 15; mask++) begin
            for (int w = 0; w < 4; w++) begin
              if (!(mask & (1 << w))) begin
                check_miss(previous_way, w, 4'(mask), 1'b0, 1'b1);
                break;
              end
            end
          end
        end
      end
      default: $fatal(1, "Unknown case %s", scenario);
    endcase
    $display("PASS [%s]: %0d way-selection scenarios", scenario, checks);
    $finish;
  end

  initial begin
    #2000000;
    $fatal(1, "Way selection test timeout");
  end
endmodule

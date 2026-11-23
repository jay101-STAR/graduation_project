`timescale 1ns/1ps

module phys_dcache_tb;
  logic clk = 1'b0, rst = 1'b1;
  always #5 clk = !clk;
  logic req_valid = 1'b0, req_ready, req_write = 1'b0;
  logic [33:0] req_addr = 34'b0;
  logic [31:0] req_wdata = 32'b0;
  logic [3:0] req_wstrb = 4'b0;
  logic rsp_valid, rsp_ready = 1'b0, rsp_error;
  logic [31:0] rsp_rdata;
  logic [1:0] rsp_source;
  logic address_valid, cacheable, line_cacheable, force_uncached = 1'b0;
  wire access_ok = address_valid && req_addr[1:0] == 0;
  logic mem_req_valid, mem_req_ready, mem_req_write;
  logic [31:0] mem_req_addr, mem_req_wdata;
  logic [7:0] mem_req_len;
  logic mem_req_wlast, mem_rsp_rlast;
  logic [3:0] mem_req_wstrb;
  logic mem_rsp_valid, mem_rsp_ready;
  wire [31:0] mem_rsp_rdata;
  wire mem_rsp_error;
  logic maint_req_valid = 1'b0, maint_req_ready;
  logic maint_done_valid, maint_done_ready = 1'b0, maint_error;
  logic [31:0] words [0:16383];
  logic [31:0] uart_words [0:3];
  logic pending = 1'b0, pending_write = 1'b0, write_active = 1'b0;
  logic [31:0] read_addr = 0, write_base = 0;
  logic [7:0] read_left = 0;
  logic [3:0] write_beat = 0;
  logic write_failed = 0, pending_error = 0;
  logic [15:0] random_state = 16'hb9ab;
  integer delay_left = 0;
  integer reads = 0, writes = 0, mmio_reads = 0, mmio_writes = 0, checks = 0;
  integer before_reads, before_writes, before_mmio;
  logic fault_reads = 1'b0, fault_writes = 1'b0;
  logic [31:0] fault_addr = 32'hffffffff;
  logic blocked_request = 1'b0;
  logic [77:0] held_request;
  string wave;
  localparam logic [33:0] A = 34'h080000208;
  localparam logic [33:0] B = 34'h080000414;
  localparam logic [33:0] X = 34'h080000600;
  localparam logic [33:0] F = 34'h080000a00;
  localparam logic [33:0] G = 34'h080000c00;
  localparam logic [33:0] H = 34'h080000e00;

  mem_attr_decode #(.LINE_BYTES(64)) attributes (
    .phys_addr(req_addr), .addr_valid(address_valid), .executable(),
    .cacheable(cacheable), .line_cacheable(line_cacheable), .is_mmio()
  );
  dcache_phys_word #(.DCACHE_ENABLE(1)) dut (
    .clk(clk), .rst(rst), .req_valid(req_valid), .req_ready(req_ready),
    .req_addr(req_addr), .req_write(req_write), .req_wdata(req_wdata), .req_wstrb(req_wstrb),
    .req_access_ok(access_ok), .req_cacheable(access_ok && cacheable && line_cacheable && !force_uncached),
    .rsp_valid(rsp_valid), .rsp_ready(rsp_ready), .rsp_rdata(rsp_rdata),
    .rsp_error(rsp_error), .rsp_source(rsp_source),
    .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready), .mem_req_addr(mem_req_addr),
    .mem_req_len(mem_req_len), .mem_req_write(mem_req_write), .mem_req_wlast(mem_req_wlast),
    .mem_req_wdata(mem_req_wdata), .mem_req_wstrb(mem_req_wstrb),
    .mem_rsp_valid(mem_rsp_valid), .mem_rsp_ready(mem_rsp_ready),
    .mem_rsp_rdata(mem_rsp_rdata), .mem_rsp_error(mem_rsp_error), .mem_rsp_rlast(mem_rsp_rlast),
    .maint_req_valid(maint_req_valid), .maint_req_ready(maint_req_ready),
    .maint_done_valid(maint_done_valid), .maint_done_ready(maint_done_ready), .maint_error(maint_error)
  );

  assign mem_req_ready = !rst && !pending && random_state[0];
  assign mem_rsp_valid = !rst && pending && delay_left == 0;
  assign mem_rsp_rlast = !pending_write && read_left == 0;
  assign mem_rsp_rdata = pending_write ? 32'b0 :
                        read_addr[31:16] == 16'h8000 ? words[read_addr[15:2]] : uart_words[read_addr[3:2]];
  assign mem_rsp_error = pending_write ? pending_error : fault_reads && read_addr == fault_addr;

  function automatic logic [31:0] initial_word(input logic [33:0] addr);
    return 32'ha5a50000 ^ {18'b0, addr[15:2]};
  endfunction

  function automatic logic [31:0] merge_word(input logic [31:0] old_data,
                                            input logic [31:0] new_data,
                                            input logic [3:0] mask);
    logic [31:0] result;
    result = old_data;
    for (int b = 0; b < 4; b++)
      if (mask[b]) result[b*8 +: 8] = new_data[b*8 +: 8];
    return result;
  endfunction

  always @(posedge clk) begin
    if (rst) begin
      pending <= 1'b0;
      write_active <= 1'b0;
      blocked_request <= 1'b0;
    end else begin
      random_state <= {random_state[14:0], random_state[15]^random_state[13]^random_state[12]^random_state[10]};
      if (blocked_request && (!mem_req_valid ||
          {mem_req_addr, mem_req_write, mem_req_wdata, mem_req_wstrb, mem_req_len, mem_req_wlast} !== held_request))
        $fatal(1, "DCache backend request changed under backpressure");
      blocked_request <= mem_req_valid && !mem_req_ready;
      held_request <= {mem_req_addr, mem_req_write, mem_req_wdata, mem_req_wstrb, mem_req_len, mem_req_wlast};
      if (pending && delay_left != 0) delay_left <= delay_left - 1;
      if (mem_rsp_valid && mem_rsp_ready) begin
        if (!pending_write) begin
          if (read_addr[31:16] == 16'h8000) reads <= reads + 1;
          else mmio_reads <= mmio_reads + 1;
        end
        if (pending_write || read_left == 0) pending <= 1'b0;
        else begin
          read_addr <= read_addr + 32'd4;
          read_left <= read_left - 8'd1;
          delay_left <= int'(random_state[3:1]);
        end
      end
      if (mem_req_valid && mem_req_ready) begin : accept_backend
        logic [31:0] addr;
        logic [3:0] index;
        logic failed;
        if ((mem_req_len != 0 && mem_req_len != 15) || mem_req_addr[1:0] != 0)
          $fatal(1, "DCache backend length/alignment");
        if (mem_req_len == 15 && mem_req_addr[5:0] != 0)
          $fatal(1, "DCache burst is not line aligned");
        if (!mem_req_write) begin
          if (write_active) $fatal(1, "Read interrupted a write burst");
          pending <= 1'b1;
          pending_write <= 1'b0;
          read_addr <= mem_req_addr;
          read_left <= mem_req_len;
          delay_left <= int'(random_state[3:1]);
        end else begin
          index = write_active ? write_beat : 4'd0;
          addr = mem_req_addr + {26'b0, index, 2'b0};
          failed = fault_writes && addr == fault_addr;
          if (write_active && mem_req_addr != write_base) $fatal(1, "Write line changed");
          if (mem_req_wlast !== (mem_req_len == 0 || index == 15)) $fatal(1, "Write LAST/count mismatch");
          if (mem_req_len == 15 && mem_req_wstrb != 4'hf) $fatal(1, "Writeback must write complete words");
          if (addr[31:16] == 16'h8000) begin
            writes <= writes + 1;
            if (!failed) words[addr[15:2]] <= merge_word(words[addr[15:2]], mem_req_wdata, mem_req_wstrb);
          end else if (addr >= 32'h10000000 && addr <= 32'h1000000f && mem_req_len == 0) begin
            mmio_writes <= mmio_writes + 1;
            uart_words[addr[3:2]] <= merge_word(uart_words[addr[3:2]], mem_req_wdata, mem_req_wstrb);
          end else $fatal(1, "Invalid physical write address %h", addr);
          if (mem_req_wlast) begin
            write_active <= 0;
            write_beat <= 0;
            pending <= 1;
            pending_write <= 1;
            pending_error <= (write_active && write_failed) || failed;
            delay_left <= int'(random_state[3:1]);
          end else begin
            write_active <= 1;
            write_base <= mem_req_addr;
            write_beat <= index + 4'd1;
            write_failed <= (write_active && write_failed) || failed;
          end
        end
      end
    end
  end

  task automatic tick(input int count = 1);
    repeat (count) begin @(posedge clk); #1; end
  endtask

  task automatic transaction(input logic [33:0] addr, input bit wr,
                             input logic [31:0] data, input logic [3:0] mask,
                             input logic [31:0] expected, input bit error,
                             input logic [1:0] source, input int hold_cycles = 3);
    logic [34:0] held;
    int waited;
    @(negedge clk);
    req_addr = addr;
    req_write = wr;
    req_wdata = data;
    req_wstrb = mask;
    req_valid = 1'b1;
    rsp_ready = 1'b0;
    waited = 0;
    do begin
      @(posedge clk);
      waited++;
      if (waited > 5000) $fatal(1, "Request timeout at %h", addr);
    end while (!req_ready);
    @(negedge clk);
    req_valid = 1'b0;
    req_addr = 34'h300000003;
    req_write = !wr;
    req_wdata = ~data;
    req_wstrb = ~mask;
    waited = 0;
    while (!rsp_valid) begin
      tick();
      waited++;
      if (waited > 5000) $fatal(1, "Response timeout at %h", addr);
    end
    if (rsp_error !== error || rsp_source !== source || (!wr && !error && rsp_rdata !== expected))
      $fatal(1, "addr=%h write=%b data=%h expected=%h error=%b/%b source=%d/%d",
             addr, wr, rsp_rdata, expected, rsp_error, error, rsp_source, source);
    held = {rsp_source, rsp_error, rsp_rdata};
    repeat (hold_cycles) begin
      tick();
      if (!rsp_valid || {rsp_source, rsp_error, rsp_rdata} !== held || req_ready)
        $fatal(1, "Blocked DCache response changed");
    end
    @(negedge clk); rsp_ready = 1'b1;
    tick();
    @(negedge clk); rsp_ready = 1'b0;
    checks++;
  endtask

  task automatic clean(input bit expected_error = 1'b0);
    int waited;
    @(negedge clk); maint_req_valid = 1'b1;
    do @(posedge clk); while (!maint_req_ready);
    @(negedge clk); maint_req_valid = 1'b0;
    waited = 0;
    while (!maint_done_valid) begin
      tick();
      waited++;
      if (waited > 20000) $fatal(1, "DCache clean timeout");
      if (rsp_valid) $fatal(1, "Clean generated an unsolicited CPU response");
    end
    repeat (3) begin
      tick();
      if (!maint_done_valid || maint_error !== expected_error || req_ready)
        $fatal(1, "Clean result was lost under backpressure");
    end
    @(negedge clk); maint_done_ready = 1'b1;
    tick();
    @(negedge clk); maint_done_ready = 1'b0;
    checks++;
  endtask

  initial begin
    if ($value$plusargs("wave=%s", wave)) begin
      $dumpfile(wave);
      $dumpvars(0, phys_dcache_tb);
    end
    for (int n = 0; n < 16384; n++) words[n] = 32'ha5a50000 ^ 32'(n);
    for (int n = 0; n < 4; n++) uart_words[n] = 32'h12345678;
    tick(3);
    @(negedge clk); rst = 1'b0;
    transaction(A, 0, 0, 0, initial_word(A), 0, 3);
    if (reads != 16) $fatal(1, "Cold load must fetch 16 words");
    transaction(A + 4, 0, 0, 0, initial_word(A + 4), 0, 2);
    transaction(A, 1, 32'hdeadbeef, 4'b0101, 0, 0, 2);
    transaction(A, 0, 0, 0, merge_word(initial_word(A), 32'hdeadbeef, 4'b0101), 0, 2);
    if (words[A[15:2]] != initial_word(A)) $fatal(1, "Cached store unexpectedly wrote through");
    transaction(B, 1, 32'h11223344, 4'hf, 0, 0, 3);
    transaction(B, 0, 0, 0, 32'h11223344, 0, 2);
    if (words[B[15:2]] != initial_word(B)) $fatal(1, "Store miss unexpectedly wrote through");

    // Five lines in one set force replacement of a dirty line.
    transaction(X, 1, 32'hcafebabe, 4'hf, 0, 0, 3);
    for (int n = 1; n <= 4; n++)
      transaction(X + 34'(n*8192), 0, 0, 0, initial_word(X + 34'(n*8192)), 0, 3);
    if (writes != 16 || words[X[15:2]] != 32'hcafebabe)
      $fatal(1, "Dirty replacement did not write exactly one complete line");
    clean();
    if (words[A[15:2]] != merge_word(initial_word(A), 32'hdeadbeef, 4'b0101) ||
        words[B[15:2]] != 32'h11223344) $fatal(1, "Clean lost cached CPU stores");
    before_writes = writes;
    clean();
    if (writes != before_writes) $fatal(1, "Clean repeated writes of clean lines");

    before_mmio = mmio_writes;
    transaction(34'h010000000, 1, 32'haabbccdd, 4'b0010, 0, 0, 1);
    transaction(34'h010000000, 0, 0, 0, 32'h1234cc78, 0, 1);
    if (mmio_writes != before_mmio + 1 || mmio_reads != 1)
      $fatal(1, "UART access was cached or repeated");
    before_reads = reads;
    before_writes = writes;
    transaction(34'h080001020, 1, 32'h01020304, 4'b0011, 0, 0, 1);
    transaction(34'h080001020, 0, 0, 0,
                merge_word(initial_word(34'h080001020), 32'h01020304, 4'b0011), 0, 1);
    if (writes != before_writes + 1 || reads != before_reads + 1)
      $fatal(1, "Entire 64-byte tohost line must bypass DCache");
    before_reads = reads;
    transaction(34'h180000208, 0, 0, 0, 0, 1, 0);
    transaction(A + 1, 0, 0, 0, 0, 1, 0);
    if (reads != before_reads) $fatal(1, "Illegal request reached backend");

    // Refill failure must not install a partial line; retry must refill again.
    fault_addr = F[31:0] + 4;
    fault_reads = 1'b1;
    transaction(F, 0, 0, 0, 0, 1, 0);
    fault_reads = 1'b0;
    before_reads = reads;
    transaction(F, 0, 0, 0, initial_word(F), 0, 3);
    if (reads != before_reads + 16) $fatal(1, "Failed refill installed a partial line");

    // Failed replacement retains dirty data so a later miss can retry all words.
    transaction(G, 1, 32'hd00dbeef, 4'hf, 0, 0, 3);
    for (int n = 1; n <= 3; n++)
      transaction(G + 34'(n*8192), 0, 0, 0, initial_word(G + 34'(n*8192)), 0, 3);
    fault_addr = G[31:0] + 12;
    fault_writes = 1'b1;
    transaction(G + 34'h8000, 0, 0, 0, 0, 1, 0);
    fault_writes = 1'b0;
    before_writes = writes;
    transaction(G + 34'h8000, 0, 0, 0, initial_word(G + 34'h8000), 0, 3);
    if (writes != before_writes + 16 || words[G[15:2]] != 32'hd00dbeef)
      $fatal(1, "Failed writeback lost dirty state/data");

    // Clean error is reported, held, and retryable without resetting Cache.
    transaction(H, 1, 32'h76543210, 4'hf, 0, 0, 3);
    fault_addr = H[31:0] + 8;
    fault_writes = 1'b1;
    clean(1'b1);
    transaction(H, 0, 0, 0, 32'h76543210, 0, 2);
    fault_writes = 1'b0;
    before_writes = writes;
    clean();
    if (writes != before_writes + 16 || words[H[15:2]] != 32'h76543210)
      $fatal(1, "Clean failure did not preserve dirty line for retry");
    $display("[PHYS-DCACHE] PASS checks=%0d reads=%0d writes=%0d mmio_reads=%0d mmio_writes=%0d",
             checks, reads, writes, mmio_reads, mmio_writes);
    $finish;
  end

  initial begin
    #2000000;
    $fatal(1, "DCache physical port test timeout");
  end
endmodule

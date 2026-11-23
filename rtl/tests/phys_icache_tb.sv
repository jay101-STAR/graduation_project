`timescale 1ns / 1ns

module phys_icache_tb;
  reg clk = 0, rst = 1;
  always #5 clk = ~clk;
  reg cpu_req_valid = 0, cpu_rsp_ready = 0;
  reg [33:0] cpu_req_addr = 0;
  wire cpu_req_ready, cpu_rsp_valid, cpu_rsp_error;
  wire [31:0] cpu_rsp_rdata;
  wire [1:0] cpu_rsp_source;
  wire valid_addr, executable, cacheable, line_cacheable;
  reg uncached = 0;
  reg deny_access = 0, write_request = 0;
  wire mem_req_valid, mem_rsp_ready;
  wire [31:0] mem_req_addr;
  wire mem_req_write;
  wire [7:0] mem_req_len;
  reg [7:0] read_left = 0;
  wire mem_rsp_last = read_left == 0;
  integer backend_bursts = 0;
  wire [31:0] mem_req_wdata;
  wire [3:0] mem_req_wstrb;
  reg mem_req_ready = 0, mem_rsp_valid = 0, mem_rsp_error = 0;
  reg [31:0] mem_rsp_rdata = 0;
  reg maint_req_valid = 0, maint_done_ready = 0;
  wire maint_req_ready, maint_done_valid;
  reg [31:0] words [0:16383];
  reg pending = 0;
  reg [31:0] read_addr;
  reg [31:0] fault_addr = 32'hffffffff;
  reg [15:0] random_state = 16'h31ab;
  integer delay_left = 0, backend_reads = 0, checks = 0, before_reads;
  string wave;

  mem_attr_decode #(.LINE_BYTES(64)) attributes (
      .phys_addr(cpu_req_addr), .addr_valid(valid_addr), .executable(executable),
      .cacheable(cacheable), .line_cacheable(line_cacheable), .is_mmio()
  );
  // Match the top-level contract: attributes alone do not check alignment or
  // reject a write on the instruction port. The adapter consumes this verdict.
  wire access_ok = valid_addr && executable && (cpu_req_addr[1:0] == 0) &&
                   !write_request && !deny_access;
  icache_phys_word #(.ICACHE_ENABLE(1)) dut (
      .clk(clk), .rst(rst), .req_valid(cpu_req_valid), .req_ready(cpu_req_ready),
      .req_addr(cpu_req_addr), .req_write(write_request), .req_wdata(32'b0), .req_wstrb(4'b0),
      .req_access_ok(access_ok),
      .req_cacheable(access_ok && cacheable && line_cacheable && !uncached),
      .rsp_valid(cpu_rsp_valid), .rsp_ready(cpu_rsp_ready),
      .rsp_rdata(cpu_rsp_rdata), .rsp_error(cpu_rsp_error), .rsp_source(cpu_rsp_source),
      .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready), .mem_req_addr(mem_req_addr),
      .mem_req_len(mem_req_len), .mem_req_write(mem_req_write), .mem_req_wdata(mem_req_wdata), .mem_req_wstrb(mem_req_wstrb),
      .mem_rsp_valid(mem_rsp_valid), .mem_rsp_ready(mem_rsp_ready),
      .mem_rsp_last(mem_rsp_last), .mem_rsp_rdata(mem_rsp_rdata), .mem_rsp_error(mem_rsp_error),
      .maint_req_valid(maint_req_valid), .maint_req_ready(maint_req_ready),
      .maint_done_valid(maint_done_valid), .maint_done_ready(maint_done_ready)
  );

  always @(negedge clk) begin
    random_state = {random_state[14:0], random_state[15]^random_state[13]^random_state[12]^random_state[10]};
    mem_req_ready = !rst && !pending && random_state[0];
  end
  always @(posedge clk) begin
    if (rst) begin
      pending <= 0;
      mem_rsp_valid <= 0;
    end else begin
      if (mem_req_valid && mem_req_ready) begin
        if (pending) $fatal(1, "overlapping backend words");
        if (mem_req_write || mem_req_wstrb != 0) $fatal(1, "instruction port wrote backend");
        if (mem_req_addr[31:16] != 16'h8000 || mem_req_addr[1:0] != 0)
          $fatal(1, "invalid backend address %h", mem_req_addr);
        pending <= 1;
        read_addr <= mem_req_addr;
        delay_left <= 1 + int'(random_state[2:1]);
        read_left <= mem_req_len;
        backend_bursts <= backend_bursts + 1;
      end
      if (pending && !mem_rsp_valid) begin
        if (delay_left != 0) delay_left <= delay_left - 1;
        else begin
          mem_rsp_valid <= 1;
          mem_rsp_rdata <= words[read_addr[15:2]];
          mem_rsp_error <= read_addr == fault_addr;
        end
      end
      if (mem_rsp_valid && mem_rsp_ready) begin
        backend_reads <= backend_reads + 1;
        mem_rsp_valid <= 0;
        if (read_left == 0) pending <= 0;
        else begin
          read_left <= read_left - 1'b1;
          read_addr <= read_addr + 4;
          delay_left <= int'(random_state[2:1]);
        end
      end
    end
  end

  task automatic fetch(input [33:0] address, input [31:0] expected,
                       input bit error, input [1:0] source, input bit bypass = 0);
    reg [34:0] held;
    begin
      @(negedge clk);
      cpu_req_addr = address;
      cpu_req_valid = 1;
      cpu_rsp_ready = 0;
      uncached = bypass;
      do @(posedge clk); while (!cpu_req_ready);
      @(negedge clk);
      cpu_req_valid = 0;
      cpu_req_addr = 34'h3_ffffffff;
      uncached = 0;
      wait (cpu_rsp_valid);
      #1;
      if (cpu_rsp_error !== error || cpu_rsp_source !== source ||
          (!error && cpu_rsp_rdata !== expected))
        $fatal(1, "fetch %h data=%h expected=%h error=%b source=%b", address,
               cpu_rsp_rdata, expected, cpu_rsp_error, cpu_rsp_source);
      held = {cpu_rsp_source, cpu_rsp_error, cpu_rsp_rdata};
      repeat (4) begin
        @(negedge clk); #1;
        if (!cpu_rsp_valid || held !== {cpu_rsp_source,cpu_rsp_error,cpu_rsp_rdata})
          $fatal(1, "response changed under backpressure");
      end
      cpu_rsp_ready = 1;
      @(posedge clk);
      @(negedge clk);
      cpu_rsp_ready = 0;
      checks++;
    end
  endtask

  function automatic [33:0] stream_address(input integer index);
    reg [33:0] base;
    begin
      case (index % 4)
        0: base = 34'h080000000;
        1: base = 34'h080000040;
        2: base = 34'h080002000;
        default: base = 34'h080004000;
      endcase
      stream_address = base + 34'(((index / 4) % 16) * 4);
    end
  endfunction

  // Check throughput and ordering at the public interface, across different
  // sets/tags/word offsets. No lookup-state or array implementation assumptions.
  task automatic stream_hits(input bit stalls);
    integer sent, received, cycles, replacements, reads;
    reg held_valid;
    reg [34:0] held;
    reg [33:0] expected_addr;
    begin
      sent = 0;
      received = 0;
      cycles = 0;
      replacements = 0;
      held_valid = 0;
      reads = backend_reads;
      @(negedge clk);
      cpu_req_valid = 1;
      cpu_req_addr = stream_address(0);
      cpu_rsp_ready = 1;
      while (received < 128) begin
        @(posedge clk);
        if (held_valid && (!cpu_rsp_valid ||
            held !== {cpu_rsp_source, cpu_rsp_error, cpu_rsp_rdata}))
          $fatal(1, "stream response changed under backpressure");
        if (cpu_rsp_valid) begin
          if (received >= sent) $fatal(1, "stream response without accepted request");
          expected_addr = stream_address(received);
          if (cpu_rsp_error || cpu_rsp_source != 2 ||
              cpu_rsp_rdata !== words[expected_addr[15:2]])
            $fatal(1, "stream response %0d addr=%h data=%h source=%0d", received,
                   expected_addr, cpu_rsp_rdata, cpu_rsp_source);
        end
        if (!stalls && sent != received && !cpu_rsp_valid)
          $fatal(1, "warm-hit response bubble at cycle %0d", cycles);
        if (!stalls && cpu_req_valid && !cpu_req_ready)
          $fatal(1, "warm-hit request bubble at cycle %0d", cycles);
        if (cpu_req_valid && cpu_req_ready && cpu_rsp_valid && cpu_rsp_ready)
          replacements++;
        held_valid = cpu_rsp_valid && !cpu_rsp_ready;
        held = {cpu_rsp_source, cpu_rsp_error, cpu_rsp_rdata};
        if (cpu_rsp_valid && cpu_rsp_ready) begin
          received++;
          checks++;
        end
        if (cpu_req_valid && cpu_req_ready) sent++;
        cycles++;
        if (cycles > 1000) $fatal(1, "stream timeout");
        @(negedge clk);
        cpu_req_valid = sent < 128;
        cpu_req_addr = stream_address(sent);
        cpu_rsp_ready = !stalls || (cycles % 9 < 4) || (cycles % 9 > 6);
      end
      cpu_req_valid = 0;
      cpu_rsp_ready = 0;
      if (backend_reads != reads) $fatal(1, "warm stream used backend");
      if (!stalls && (cycles != 129 || replacements != 127))
        $fatal(1, "warm stream throughput cycles=%0d replacements=%0d", cycles, replacements);
      $display("[ICACHE-STREAM] stalls=%0d requests=%0d responses=%0d cycles=%0d replacements=%0d",
               stalls, sent, received, cycles, replacements);
    end
  endtask

  // Hold a second offer while the first hit is stalled, then release it. The
  // next word can miss, bypass or fail permission checks without changing A.
  task automatic queued_fetch(input [33:0] address, input [31:0] expected,
                              input bit error, input [1:0] source,
                              input bit bypass = 0, input bit denied = 0,
                              input bit write_access = 0);
    reg accepted;
    reg [34:0] held;
    begin
      @(negedge clk);
      cpu_req_addr = 34'h080000014;
      cpu_req_valid = 1;
      cpu_rsp_ready = 0;
      do @(posedge clk); while (!cpu_req_ready);
      @(negedge clk);
      cpu_req_addr = address;
      uncached = bypass;
      deny_access = denied;
      write_request = write_access;
      repeat (3) begin
        @(posedge clk);
        if (!cpu_rsp_valid || cpu_rsp_error || cpu_rsp_source != 2 ||
            cpu_rsp_rdata !== words[5] || cpu_req_ready)
          $fatal(1, "queued request changed or replaced blocked hit");
      end
      @(negedge clk); cpu_rsp_ready = 1;
      @(posedge clk);
      if (!cpu_rsp_valid || cpu_rsp_rdata !== words[5] || cpu_rsp_source != 2)
        $fatal(1, "old response corrupted on turnover");
      accepted = cpu_req_ready;
      if (!error && !bypass && !accepted) $fatal(1, "cached request did not replace hit");
      @(negedge clk);
      cpu_rsp_ready = 0;
      if (!accepted) begin
        do @(posedge clk); while (!cpu_req_ready);
        @(negedge clk);
      end
      cpu_req_valid = 0;
      cpu_req_addr = 34'h3_ffffffff;
      uncached = 0;
      deny_access = 0;
      write_request = 0;
      wait (cpu_rsp_valid);
      #1;
      if (cpu_rsp_error !== error || cpu_rsp_source !== source ||
          (!error && cpu_rsp_rdata !== expected))
        $fatal(1, "queued response addr=%h data=%h error=%b source=%0d",
               address, cpu_rsp_rdata, cpu_rsp_error, cpu_rsp_source);
      held = {cpu_rsp_source, cpu_rsp_error, cpu_rsp_rdata};
      repeat (3) begin
        @(negedge clk); #1;
        if (!cpu_rsp_valid || held !== {cpu_rsp_source, cpu_rsp_error, cpu_rsp_rdata})
          $fatal(1, "queued response changed under backpressure");
      end
      cpu_rsp_ready = 1;
      @(posedge clk);
      @(negedge clk); cpu_rsp_ready = 0;
      checks += 2;
    end
  endtask

  task automatic maintain_hit_stream;
    begin
      @(negedge clk);
      cpu_req_valid = 1;
      cpu_req_addr = 34'h080000014;
      cpu_rsp_ready = 0;
      do @(posedge clk); while (!cpu_req_ready);
      @(negedge clk);
      cpu_req_addr = 34'h080000020;
      maint_req_valid = 1;
      repeat (3) begin
        @(posedge clk);
        if (!cpu_rsp_valid || cpu_rsp_rdata !== words[5] || cpu_rsp_source != 2 ||
            cpu_req_ready || maint_req_ready)
          $fatal(1, "maintenance did not stop blocked hit stream");
      end
      @(negedge clk); cpu_rsp_ready = 1;
      @(posedge clk);
      if (!cpu_rsp_valid || cpu_req_ready) $fatal(1, "maintenance allowed hit replacement");
      @(negedge clk); cpu_rsp_ready = 0;
      do begin
        @(posedge clk);
        if (cpu_req_ready) $fatal(1, "fetch beat maintenance request");
      end while (!maint_req_ready);
      @(negedge clk); maint_req_valid = 0;
      wait (maint_done_valid);
      words[8] = 32'hcafe0020;
      repeat (3) begin
        @(negedge clk);
        if (!maint_done_valid || cpu_req_ready)
          $fatal(1, "maintenance completion did not hold off stream");
      end
      maint_done_ready = 1;
      @(posedge clk);
      @(negedge clk); maint_done_ready = 0;
      do @(posedge clk); while (!cpu_req_ready);
      @(negedge clk); cpu_req_valid = 0;
      wait (cpu_rsp_valid);
      #1;
      if (cpu_rsp_error || cpu_rsp_source != 3 || cpu_rsp_rdata !== words[8])
        $fatal(1, "hit-stream maintenance returned stale instruction");
      cpu_rsp_ready = 1;
      @(posedge clk);
      @(negedge clk); cpu_rsp_ready = 0;
      checks += 2;
    end
  endtask

  initial begin
    if ($value$plusargs("wave=%s", wave)) begin $dumpfile(wave); $dumpvars(0, phys_icache_tb); end
    for (int i=0; i<16384; i++) words[i] = 32'h60000000 + 32'(i);
    repeat (3) @(negedge clk);
    rst = 0;
    before_reads = backend_reads;
    fetch(34'h080000014, words[5], 0, 3);
    if (backend_reads != before_reads+16) $fatal(1, "refill was not 16 words");
    for (int i=0; i<16; i++) fetch(34'h080000000+34'(4*i), words[i], 0, 2);
    if (backend_reads != before_reads+16) $fatal(1, "cache hit used backend");
    fetch(34'h080000040, words[16], 0, 3);
    fetch(34'h080002000, words[2048], 0, 3);
    fetch(34'h080004000, words[4096], 0, 3);
    stream_hits(0);
    stream_hits(1);
    before_reads = backend_reads;
    queued_fetch(34'h080000060, words[24], 0, 2);
    queued_fetch(34'h080000100, words[64], 0, 3);
    if (backend_reads != before_reads+16) $fatal(1, "hit-to-miss refill address/count");
    before_reads = backend_reads;
    queued_fetch(34'h080000014, words[5], 0, 1, 1);
    queued_fetch(34'h080000014, 0, 1, 0, 0, 1);
    queued_fetch(34'h180000014, 0, 1, 0);
    queued_fetch(34'h080000014, 0, 1, 0, 0, 0, 1);
    if (backend_reads != before_reads+1) $fatal(1, "queued bypass/error backend traffic");
    fault_addr = 32'h80000180;
    queued_fetch(34'h080000180, 0, 1, 0);
    fault_addr = 32'hffffffff;
    fetch(34'h080000014, words[5], 0, 3);
    before_reads = backend_reads;
    maintain_hit_stream();
    if (backend_reads != before_reads+16) $fatal(1, "hit-stream maintenance refill");
    // Exercise 34-to-32-bit narrowing at the last executable RAM line.
    fetch(34'h08000fffc, words[16383], 0, 3);
    fetch(34'h08000ffc0, words[16368], 0, 2);
    before_reads = backend_reads;
    fetch(34'h080010000, 0, 1, 0);
    // Permission/high-address/write checks must also reject a resident tag.
    deny_access = 1;
    fetch(34'h080000014, 0, 1, 0);
    deny_access = 0;
    fetch(34'h180000014, 0, 1, 0);
    write_request = 1;
    fetch(34'h080000014, 0, 1, 0);
    write_request = 0;
    fetch(34'h110000000, 0, 1, 0);
    fetch(34'h010000000, 0, 1, 0);
    fetch(34'h080000002, 0, 1, 0);
    if (backend_reads != before_reads) $fatal(1, "invalid access reached backend");
    words[5] = 32'hfeed0014;
    fetch(34'h080000014, words[5], 0, 1, 1);
    fetch(34'h080001000, words[1024], 0, 1);
    if (backend_reads != before_reads+2) $fatal(1, "bypass expanded into a refill");

    fault_addr = 32'h8000008c;
    before_reads = backend_reads;
    fetch(34'h080000080, 0, 1, 0);
    if (backend_reads != before_reads+16) $fatal(1, "failed refill did not drain to LAST");
    fault_addr = 32'hffffffff;
    before_reads = backend_reads;
    fetch(34'h080000080, words[32], 0, 3);
    if (backend_reads != before_reads+16) $fatal(1, "failed line was cached");
    fault_addr = 32'h80001000;
    fetch(34'h080001000, 0, 1, 0);
    fault_addr = 32'hffffffff;

    // Every beat, including the last one, may fail. The failed line must
    // require a fresh full refill on retry rather than becoming a cache hit.
    for (int beat=0; beat<16; beat++) begin
      fault_addr = 32'h80000200 + 32'(beat*64 + beat*4);
      before_reads = backend_reads;
      fetch(34'h080000200 + 34'(beat*64), 0, 1, 0);
      if (backend_reads != before_reads+16) $fatal(1, "error beat %0d not drained", beat);
      fault_addr = 32'hffffffff;
      before_reads = backend_reads;
      fetch(34'h080000200 + 34'(beat*64), words[128+beat*16], 0, 3);
      if (backend_reads != before_reads+16) $fatal(1, "error beat %0d poisoned line", beat);
    end

    // Maintenance arrives during a refill, must wait for accepted work, and
    // keeps fetch blocked while its completion is backpressured.
    fork
      fetch(34'h080000100, words[64], 0, 3);
      begin
        wait (mem_req_valid && mem_req_addr == 32'h80000100);
        @(negedge clk); maint_req_valid = 1;
        if (maint_req_ready) $fatal(1, "maintenance accepted during refill");
        do @(posedge clk); while (!maint_req_ready);
        @(negedge clk); maint_req_valid = 0;
        wait (maint_done_valid);
        words[64] = 32'hcafe0100;
        repeat (3) begin
          @(negedge clk);
          if (!maint_done_valid || cpu_req_ready) $fatal(1, "maintenance completion not held");
        end
        maint_done_ready = 1;
        @(posedge clk);
        @(negedge clk); maint_done_ready = 0;
      end
    join
    before_reads = backend_reads;
    fetch(34'h080000100, words[64], 0, 3);
    if (backend_reads != before_reads+16) $fatal(1, "maintenance did not invalidate old refill");
    $display("[PHYS-ICACHE] PASS checks=%0d backend_reads=%0d", checks, backend_reads);
    $finish;
  end
  initial begin #100000; $fatal(1, "ICache boundary timeout"); end
endmodule

`timescale 1ns / 1ns

module cache_boundary_tb #(
    parameter integer INSTRUCTION_PORT = 0,
    parameter integer CACHE_ENABLE = 0
);
  reg clk = 1'b0, rst = 1'b1;
  always #5 clk = ~clk;
  reg req_valid = 1'b0, req_write = 1'b0, rsp_ready = 1'b0;
  reg [33:0] req_addr = 34'b0;
  reg [31:0] req_wdata = 32'b0;
  reg [3:0] req_wstrb = 4'b0;
  wire req_ready, rsp_valid, rsp_error;
  wire [31:0] rsp_rdata;
  wire [1:0] rsp_source;
  wire attr_valid, executable, cacheable, line_cacheable;
  wire mid_req_valid, mid_req_ready, mid_req_write, mid_rsp_valid, mid_rsp_ready, mid_rsp_error;
  wire [33:0] mid_req_addr;
  wire [31:0] mid_req_wdata, mid_rsp_rdata;
  wire [3:0] mid_req_wstrb;
  wire mem_req_valid, mem_req_write, mem_rsp_ready;
  wire [31:0] mem_req_addr, mem_req_wdata;
  wire [3:0] mem_req_wstrb;
  reg mem_req_ready = 1'b0, mem_rsp_valid = 1'b0, mem_rsp_error = 1'b0;
  reg [31:0] mem_rsp_rdata = 32'b0;
  reg maint_valid = 1'b0, done_ready = 1'b0;
  wire maint_ready, done_valid;
  integer requests = 0, responses = 0, backend_requests = 0, maint_requests = 0;
  integer n, before_backend, seed = 493;
  reg [15:0] random_state = 16'h01ed;
  string wave;
  mem_attr_decode attributes (
      .phys_addr(req_addr), .addr_valid(attr_valid), .executable(executable),
      .cacheable(cacheable), .line_cacheable(line_cacheable), .is_mmio()
  );
  wire access_ok = attr_valid && (req_addr[1:0] == 0) &&
                   ((INSTRUCTION_PORT == 0) || (executable && !req_write));
  cache_word_bypass #(.CACHE_ENABLE(CACHE_ENABLE)) boundary (
      .clk(clk), .rst(rst), .cpu_req_valid(req_valid), .cpu_req_ready(req_ready),
      .cpu_req_addr(req_addr), .cpu_req_write(req_write), .cpu_req_wdata(req_wdata), .cpu_req_wstrb(req_wstrb),
      .cpu_req_access_ok(access_ok),
      .cpu_req_cacheable(access_ok && cacheable && line_cacheable),
      .cpu_rsp_valid(rsp_valid), .cpu_rsp_ready(rsp_ready), .cpu_rsp_rdata(rsp_rdata),
      .cpu_rsp_error(rsp_error), .cpu_rsp_source(rsp_source),
      .mem_req_valid(mid_req_valid), .mem_req_ready(mid_req_ready), .mem_req_addr(mid_req_addr),
      .mem_req_write(mid_req_write), .mem_req_wdata(mid_req_wdata), .mem_req_wstrb(mid_req_wstrb),
      .mem_rsp_valid(mid_rsp_valid), .mem_rsp_ready(mid_rsp_ready),
      .mem_rsp_rdata(mid_rsp_rdata), .mem_rsp_error(mid_rsp_error),
      .maint_req_valid(maint_valid), .maint_req_ready(maint_ready),
      .maint_done_valid(done_valid), .maint_done_ready(done_ready)
  );
  generate
    if (INSTRUCTION_PORT != 0) begin : instruction_side
      icache_phys_word #(.ICACHE_ENABLE(0)) physical_port (
          .clk(clk), .rst(rst), .req_valid(mid_req_valid), .req_ready(mid_req_ready),
          .req_addr(mid_req_addr), .req_write(mid_req_write), .req_wdata(mid_req_wdata), .req_wstrb(mid_req_wstrb),
          .req_access_ok(access_ok),
          .req_cacheable(access_ok && cacheable && line_cacheable), .rsp_source(),
          .rsp_valid(mid_rsp_valid), .rsp_ready(mid_rsp_ready), .rsp_rdata(mid_rsp_rdata), .rsp_error(mid_rsp_error),
          .mem_req_len(), .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready), .mem_req_addr(mem_req_addr),
          .mem_req_write(mem_req_write), .mem_req_wdata(mem_req_wdata), .mem_req_wstrb(mem_req_wstrb),
          .mem_rsp_last(1'b1), .mem_rsp_valid(mem_rsp_valid), .mem_rsp_ready(mem_rsp_ready),
          .mem_rsp_rdata(mem_rsp_rdata), .mem_rsp_error(mem_rsp_error),
          .maint_req_valid(1'b0), .maint_req_ready(), .maint_done_valid(), .maint_done_ready(1'b1)
      );
    end else begin : data_side
      dcache_phys_word #(.DCACHE_ENABLE(0)) physical_port (
          .clk(clk), .rst(rst), .req_valid(mid_req_valid), .req_ready(mid_req_ready),
          .req_addr(mid_req_addr), .req_write(mid_req_write), .req_wdata(mid_req_wdata), .req_wstrb(mid_req_wstrb),
          .req_access_ok(access_ok),
          .req_cacheable(access_ok && cacheable && line_cacheable), .rsp_source(),
          .rsp_valid(mid_rsp_valid), .rsp_ready(mid_rsp_ready), .rsp_rdata(mid_rsp_rdata), .rsp_error(mid_rsp_error),
          .mem_req_len(), .mem_req_valid(mem_req_valid), .mem_req_ready(mem_req_ready), .mem_req_addr(mem_req_addr),
          .mem_req_write(mem_req_write), .mem_req_wdata(mem_req_wdata), .mem_req_wstrb(mem_req_wstrb),
          .mem_rsp_last(1'b1), .mem_rsp_valid(mem_rsp_valid), .mem_rsp_ready(mem_rsp_ready),
          .mem_rsp_rdata(mem_rsp_rdata), .mem_rsp_error(mem_rsp_error),
          .maint_req_valid(1'b0), .maint_req_ready(), .maint_done_valid(), .maint_done_ready(1'b1), .maint_error()
      );
    end
  endgenerate
  always @(posedge clk) begin
    if (!rst) begin
      if (req_valid && req_ready) requests = requests + 1;
      if (rsp_valid && rsp_ready) responses = responses + 1;
      if (mem_req_valid && mem_req_ready) backend_requests = backend_requests + 1;
      if (maint_valid && maint_ready) maint_requests = maint_requests + 1;
    end
  end
  task automatic payload(input [33:0] address, input bit write_access, input [3:0] mask);
    begin
      req_addr = address;
      req_write = write_access;
      req_wdata = 32'h1234abcd ^ address[31:0];
      req_wstrb = mask;
      req_valid = 1'b1;
    end
  endtask
  task automatic check_forward;
    begin
      if (!mem_req_valid || mem_req_addr !== req_addr[31:0] || mem_req_write !== req_write ||
          mem_req_wdata !== req_wdata || mem_req_wstrb !== req_wstrb)
        $fatal(1, "Word payload forwarding failed");
    end
  endtask
  task automatic transaction(input [33:0] address, input bit write_access, input [3:0] mask,
                             input bit bad, input bit bus_error, input integer wait_req,
                             input integer wait_rsp, input integer hold_rsp);
    integer previous_backend;
    reg [31:0] expected;
    begin
      @(negedge clk);
      previous_backend = backend_requests;
      mem_req_ready = 1'b0;
      rsp_ready = 1'b0;
      payload(address, write_access, mask);
      expected = 32'hdead1234 ^ address[31:0];
      // Rejected requests must be accepted locally even if the bus is blocked.
      if (!bad) begin
        repeat (wait_req) begin
          #1;
          check_forward();
          if (req_ready || rsp_valid) $fatal(1, "Accepted a blocked request");
          @(negedge clk);
        end
        mem_req_ready = 1'b1;
      end
      #1;
      if (!req_ready || (bad && mem_req_valid)) $fatal(1, "Acceptance/narrowing guard failed addr=%h", address);
      if (!bad) check_forward();
      @(posedge clk);
      @(negedge clk);
      req_valid = 1'b0;
      req_addr = 34'h3_ffffffff;
      req_write = ~write_access;
      req_wdata = 32'b0;
      req_wstrb = 4'b0;
      if (bad) begin
        if (!rsp_valid || !rsp_error || rsp_rdata != 0) $fatal(1, "Local error not returned next cycle");
      end else begin
        repeat (wait_rsp) begin
          if (rsp_valid || mem_req_valid) $fatal(1, "Premature response/repeated request");
          @(negedge clk);
        end
        mem_rsp_valid = 1'b1;
        mem_rsp_rdata = expected;
        mem_rsp_error = bus_error;
      end
      repeat (hold_rsp + 1) begin
        #1;
        if (!rsp_valid || rsp_error !== (bad || bus_error) ||
            rsp_rdata !== (bad ? 32'b0 : expected) || rsp_source !== ((bad || bus_error) ? 2'b00 : 2'b01))
          $fatal(1, "Wrong/unstable word response addr=%h", address);
        if (mem_req_valid || mem_rsp_ready || maint_ready) $fatal(1, "Response hold released ownership");
        @(negedge clk);
      end
      rsp_ready = 1'b1;
      #1;
      if (!bad && !mem_rsp_ready) $fatal(1, "Response path added a cycle");
      @(posedge clk);
      @(negedge clk);
      rsp_ready = 1'b0;
      mem_rsp_valid = 1'b0;
      mem_rsp_error = 1'b0;
      #1;
      if (rsp_valid || backend_requests != previous_backend + (bad ? 0 : 1))
        $fatal(1, "Duplicate response/backend side effect");
    end
  endtask
  // Replace an old response with a new request at the same edge, including
  // good->error and error->good. Sustained good requests must remain 1/cycle.
  task automatic overlap(input bit old_bad, input bit new_bad);
    begin
      @(negedge clk);
      mem_req_ready = 1'b1;
      payload(old_bad ? 34'h1_80006000 : 34'h0_80006000, 1'b0, 4'b0);
      #1;
      if (!req_ready) $fatal(1, "Overlap setup not ready");
      @(posedge clk);
      @(negedge clk);
      mem_rsp_valid = !old_bad;
      mem_rsp_rdata = 32'h55aa1234;
      rsp_ready = 1'b1;
      payload(new_bad ? 34'h2_80006004 : 34'h0_80006004, 1'b0, 4'b0);
      #1;
      if (!rsp_valid || rsp_error !== old_bad || !req_ready || mem_req_valid !== !new_bad)
        $fatal(1, "Response/new request overlap failed");
      @(posedge clk);
      @(negedge clk);
      req_valid = 1'b0;
      mem_rsp_valid = !new_bad;
      mem_rsp_rdata = 32'h6789abcd;
      #1;
      if (!rsp_valid || rsp_error !== new_bad || (!new_bad && rsp_rdata != 32'h6789abcd))
        $fatal(1, "Replacement response added latency or lost ownership");
      @(posedge clk);
      @(negedge clk);
      rsp_ready = 1'b0;
      mem_rsp_valid = 1'b0;
      #1;
      if (rsp_valid) $fatal(1, "Repeated replacement response");
    end
  endtask
  task automatic reset_port;
    begin
      @(negedge clk);
      rst = 1'b1;
      req_valid = 1'b0;
      maint_valid = 1'b0;
      mem_rsp_valid = 1'b0;
      repeat (2) @(negedge clk);
      if (req_ready || rsp_valid || mem_req_valid || mem_rsp_ready || maint_ready || done_valid)
        $fatal(1, "Reset leaked a handshake");
      rst = 1'b0;
      #1;
      if (rsp_valid || done_valid) $fatal(1, "Reset retained a response");
    end
  endtask
  initial begin
    if ($value$plusargs("boundary_wave=%s", wave)) begin
      $dumpfile(wave);
      $dumpvars(0, cache_boundary_tb);
    end
    if ($value$plusargs("boundary_seed=%d", seed)) random_state = 16'(seed);
    reset_port();
    transaction(34'h0_80000000, 0, 0, 0, 0, 0, 0, 0);
    transaction(34'h0_8000fffc, 0, 0, 0, 0, 7, 7, 7);
    for (n = 0; n < 8; n = n + 1)
      transaction(34'h0_80001000 + 34'(n*4), 0, 0, 0, 0, n, 0, n);
    for (n = 0; n < 16; n = n + 1)
      transaction(34'h0_80006000, 1, 4'(n), INSTRUCTION_PORT != 0, 0, n % 8, 2, 3);
    for (n = 0; n < 4; n = n + 1)
      transaction(34'h0_10000000 + 34'(n*4), 0, 0, INSTRUCTION_PORT != 0, 0, 4, 4, 4);
    if (INSTRUCTION_PORT == 0)
      transaction(34'h0_10000000, 1, 1, 0, 0, 3, 3, 3);
    transaction(34'h1_80006000, 0, 0, 1, 0, 0, 0, 7);
    transaction(34'h2_80001000, 1, 15, 1, 0, 0, 0, 7);
    transaction(34'h3_10000000, 0, 0, 1, 0, 0, 0, 7);
    transaction(34'h0_80010000, 1, 15, 1, 0, 0, 0, 4);
    transaction(34'h0_7ffffffc, 0, 0, 1, 0, 0, 0, 4);
    transaction(34'h0_10000010, 0, 0, 1, 0, 0, 0, 4);
    transaction(34'h0_80006001, 0, 0, 1, 0, 0, 0, 4);
    transaction(34'h0_80006000, 0, 0, 0, 1, 4, 4, 7);
    if (INSTRUCTION_PORT == 0) transaction(34'h0_80006000, 1, 5, 0, 1, 4, 4, 7);
    for (n = 0; n < 64; n = n + 1) begin
      random_state = {random_state[14:0], random_state[15] ^ random_state[13] ^ random_state[12] ^ random_state[10]};
      transaction({random_state[1:0], 32'h80006000}, 0, 0, |random_state[1:0],
                  random_state[2], int'(random_state[5:3]), int'(random_state[8:6]), int'(random_state[11:9]));
    end
    overlap(0, 0);
    overlap(0, 1);
    overlap(1, 0);
    overlap(1, 1);
    if (requests != responses) $fatal(1, "Lost/extra responses before reset cases");

    // Maintenance must not retract a previously offered, blocked bus request.
    @(negedge clk);
    before_backend = backend_requests;
    mem_req_ready = 1'b0;
    payload(34'h0_80006000, 0, 0);
    maint_valid = 1'b1;
    repeat (4) begin
      #1;
      check_forward();
      if (maint_ready || done_valid || req_ready) $fatal(1, "Maintenance withdrew blocked word");
      @(negedge clk);
    end
    mem_req_ready = 1'b1;
    @(posedge clk);
    @(negedge clk);
    req_valid = 1'b0;
    mem_rsp_valid = 1'b1;
    rsp_ready = 1'b0;
    repeat (3) begin
      #1;
      if (maint_ready || done_valid) $fatal(1, "Maintenance overtook held response");
      @(negedge clk);
    end
    rsp_ready = 1'b1;
    @(posedge clk);
    @(negedge clk);
    mem_rsp_valid = 1'b0;
    rsp_ready = 1'b0;
    #1;
    if (!maint_ready || done_valid) $fatal(1, "Maintenance acceptance incorrectly means completion");
    @(posedge clk);
    @(negedge clk);
    maint_valid = 1'b0;
    payload(34'h0_80006004, 0, 0);
    repeat (4) begin
      #1;
      if (!done_valid || maint_ready || req_ready || mem_req_valid) $fatal(1, "Maintenance completion not held");
      @(negedge clk);
    end
    done_ready = 1'b1;
    @(posedge clk);
    @(negedge clk);
    done_ready = 1'b0;
    #1;
    if (done_valid || backend_requests != before_backend + 1 || maint_requests != 1)
      $fatal(1, "Maintenance repeated or caused a backend side effect");
    // The word held during maintenance must now be accepted, not withdrawn.
    @(posedge clk);
    @(negedge clk);
    req_valid = 1'b0;
    mem_rsp_valid = 1'b1;
    rsp_ready = 1'b1;
    @(posedge clk);
    @(negedge clk);
    mem_rsp_valid = 1'b0;
    rsp_ready = 1'b0;
    if (requests != responses) $fatal(1, "Maintenance lost word response");

    // Reset cancels outstanding ownership/local error/maintenance completion.
    payload(34'h0_80006000, 0, 0);
    @(posedge clk);
    reset_port();
    payload(34'h3_80006000, 0, 0);
    @(posedge clk);
    reset_port();
    maint_valid = 1'b1;
    @(posedge clk);
    reset_port();
    transaction(34'h0_80006000, 0, 0, 0, 0, 0, 0, 0);
    $display("[CACHE-BOUNDARY-UNIT] PASS instruction_port=%0d requests=%0d responses=%0d backend=%0d seed=%0d",
             INSTRUCTION_PORT, requests, responses, backend_requests, seed);
    $finish;
  end
  initial begin
    #1000000;
    $fatal(1, "Boundary unit timeout");
  end
endmodule

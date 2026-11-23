`timescale 1ns/1ns
module axi4_write_burst_tb;
  logic clk = 0, rst = 1;
  always #5 clk = !clk;
  logic req_valid = 0, req_write = 1, req_wlast = 0, rsp_ready = 0;
  logic [31:0] req_addr = 0, req_wdata = 0;
  logic [7:0] req_len = 0;
  logic [3:0] req_wstrb = 0;
  wire req_ready, rsp_valid, rsp_error, rsp_rlast;
  wire [31:0] rsp_rdata;
  wire m_axi_awid;
  wire [31:0] m_axi_awaddr;
  wire [ 7:0] m_axi_awlen;
  wire [ 2:0] m_axi_awsize;
  wire [ 1:0] m_axi_awburst;
  wire m_axi_awlock;
  wire [ 3:0] m_axi_awcache;
  wire [ 2:0] m_axi_awprot;
  wire [ 3:0] m_axi_awqos;
  wire [ 3:0] m_axi_awregion;
  wire m_axi_awvalid;
  logic m_axi_awready = 0;
  wire m_axi_arid;
  wire [31:0] m_axi_araddr;
  wire [ 7:0] m_axi_arlen;
  wire [ 2:0] m_axi_arsize;
  wire [ 1:0] m_axi_arburst;
  wire m_axi_arlock;
  wire [ 3:0] m_axi_arcache;
  wire [ 2:0] m_axi_arprot;
  wire [ 3:0] m_axi_arqos;
  wire [ 3:0] m_axi_arregion;
  wire m_axi_arvalid;
  logic m_axi_arready = 0;
  wire [31:0] m_axi_wdata;
  wire [ 3:0] m_axi_wstrb;
  wire m_axi_wlast;
  wire m_axi_wvalid;
  logic m_axi_wready = 0;
  logic m_axi_bid = 0;
  logic [ 1:0] m_axi_bresp = 0;
  logic m_axi_bvalid = 0;
  wire m_axi_bready;
  logic m_axi_rid = 0;
  logic [31:0] m_axi_rdata = 0;
  logic [ 1:0] m_axi_rresp = 0;
  logic m_axi_rlast = 0;
  logic m_axi_rvalid = 0;
  wire m_axi_rready;
  int cycles = 0, aw_count = 0, w_count = 0, b_count = 0, accepted = 0, b_cycles = 0;
  int checks = 0, length = 15, aw_delay = 0, w_delay = 0, b_delay = 0;
  logic random_wait = 0, expected_error = 0, invalid_command = 0, b_error = 0;
  logic w_blocked = 0, aw_blocked = 0;
  logic [36:0] held_w;
  logic [39:0] held_aw;
  logic [31:0] address = 32'h80000200;
  string case_name, wave;
  axi4_master_serial_adapter dut(.*);

  function automatic logic [31:0] word_data(input int index);
    return 32'h81234567 ^ (32'(index) * 32'h01010101);
  endfunction
  function automatic logic [3:0] word_mask(input int index);
    case (index % 4)
      0: return 4'hf;
      1: return 4'h3;
      2: return 4'h0;
      default: return 4'h8;
    endcase
  endfunction
  always_comb begin
    m_axi_awready = !rst && cycles >= aw_delay;
    m_axi_wready = !rst && cycles >= w_delay && (!random_wait || cycles % 4 != 1);
    m_axi_bvalid = !rst && aw_count == 1 && w_count == length + 1 && b_count == 0 && b_cycles >= b_delay;
    m_axi_bresp = b_error ? 2'b10 : 2'b00;
  end
  always @(posedge clk) begin
    if (rst) begin
      cycles <= 0; aw_count <= 0; w_count <= 0; b_count <= 0; accepted <= 0; b_cycles <= 0;
      w_blocked <= 0; aw_blocked <= 0;
    end else begin
      cycles <= cycles + 1;
      if (req_valid && req_ready) accepted <= accepted + 1;
      if (w_blocked && (!m_axi_wvalid || {m_axi_wdata, m_axi_wstrb, m_axi_wlast} !== held_w))
        $fatal(1, "%s: W payload changed while blocked", case_name);
      if (aw_blocked && (!m_axi_awvalid || {m_axi_awaddr, m_axi_awlen} !== held_aw))
        $fatal(1, "%s: AW payload changed while blocked", case_name);
      w_blocked <= m_axi_wvalid && !m_axi_wready;
      aw_blocked <= m_axi_awvalid && !m_axi_awready;
      held_w <= {m_axi_wdata, m_axi_wstrb, m_axi_wlast};
      held_aw <= {m_axi_awaddr, m_axi_awlen};
      if (invalid_command && (m_axi_awvalid || m_axi_wvalid || m_axi_arvalid))
        $fatal(1, "%s: rejected request reached AXI", case_name);
      if (rsp_valid && accepted < length + 1) $fatal(1, "%s: response before native stream drained", case_name);
      if (m_axi_awvalid && m_axi_awready) begin
        if (aw_count != 0 || m_axi_awaddr !== address || m_axi_awlen != 8'(length) ||
            m_axi_awsize != 2 || m_axi_awburst != 1 || m_axi_awid != 0)
          $fatal(1, "%s: wrong/duplicate AW", case_name);
        aw_count <= aw_count + 1;
      end
      if (m_axi_wvalid && m_axi_wready) begin
        if (w_count > length || m_axi_wdata !== word_data(w_count) ||
            m_axi_wstrb !== word_mask(w_count) || m_axi_wlast !== (w_count == length))
          $fatal(1, "%s: bad W beat=%0d data=%h mask=%h last=%b", case_name, w_count, m_axi_wdata, m_axi_wstrb, m_axi_wlast);
        w_count <= w_count + 1;
      end
      if (aw_count == 1 && w_count == length + 1 && b_count == 0) b_cycles <= b_cycles + 1;
      if (m_axi_bvalid && m_axi_bready) b_count <= b_count + 1;
    end
  end
  task automatic tick(input int count = 1);
    repeat (count) begin @(posedge clk); #1; end
  endtask
  task automatic run_write(input string label, input int len, input logic [31:0] addr,
      input int aw_wait, input int w_wait, input bit random_stalls, input bit source_gaps,
      input int b_wait, input bit fail_b, input int bad_last, input bit bad_command);
    int waited;
    logic [33:0] held_response;
    @(negedge clk); rst = 1; req_valid = 0; rsp_ready = 0;
    case_name = label; length = len; address = addr; aw_delay = aw_wait; w_delay = w_wait;
    random_wait = random_stalls; b_delay = b_wait; b_error = fail_b; invalid_command = bad_command;
    expected_error = fail_b || bad_last != 0 || bad_command;
    tick(2); @(negedge clk); rst = 0;
    for (int i = 0; i <= len; i++) begin
      if (source_gaps) repeat ((i * 3 + 1) % 4) @(negedge clk);
      req_valid = 1; req_addr = addr; req_len = 8'(len); req_write = 1;
      req_wdata = word_data(i); req_wstrb = word_mask(i);
      req_wlast = bad_last == 1 ? i == 0 : bad_last == 2 ? 1'b0 : i == len;
      waited = 0;
      do begin
        @(posedge clk); waited++;
        if (waited > 100) $fatal(1, "%s: native data timeout beat=%0d", label, i);
      end while (!req_ready);
      @(negedge clk); req_valid = 0;
      req_addr = 32'hdeadbeef; req_wdata = ~word_data(i); req_wstrb = 0; req_wlast = 0;
    end
    waited = 0;
    while (!rsp_valid) begin
      tick(); waited++;
      if (waited > 200) $fatal(1, "%s: completion timeout AW=%0d W=%0d", label, aw_count, w_count);
    end
    if (rsp_error !== expected_error || !rsp_rlast || rsp_rdata != 0)
      $fatal(1, "%s: wrong completion error=%b/%b", label, rsp_error, expected_error);
    held_response = {rsp_error, rsp_rlast, rsp_rdata};
    repeat (4) begin
      tick();
      if (!rsp_valid || {rsp_error, rsp_rlast, rsp_rdata} !== held_response || m_axi_bready || req_ready)
        $fatal(1, "%s: completion changed under backpressure", label);
    end
    @(negedge clk); rsp_ready = 1;
    tick(); @(negedge clk); rsp_ready = 0;
    if (rsp_valid || !req_ready || accepted != len + 1 ||
        aw_count != (bad_command ? 0 : 1) || w_count != (bad_command ? 0 : len + 1) ||
        b_count != (bad_command ? 0 : 1))
      $fatal(1, "%s: lost/duplicate transfer native=%0d AW=%0d W=%0d B=%0d", label, accepted, aw_count, w_count, b_count);
    checks++;
    $display("[WRITE-CASE] PASS %s native=%0d AW=%0d W=%0d B=%0d", label, accepted, aw_count, w_count, b_count);
  endtask
  initial begin
    if ($value$plusargs("wave=%s", wave)) begin $dumpfile(wave); $dumpvars(0, axi4_write_burst_tb); end
    run_write("continuous", 15, 32'h80000200, 0, 0, 0, 0, 0, 0, 0, 0);
    run_write("AW_late", 15, 32'h80000200, 35, 0, 0, 0, 0, 0, 0, 0);
    run_write("W_late", 15, 32'h80000200, 0, 12, 0, 0, 0, 0, 0, 0);
    run_write("gaps_and_stalls", 15, 32'h80000200, 7, 5, 1, 1, 8, 0, 0, 0);
    run_write("B_error", 15, 32'h80000200, 0, 0, 1, 1, 4, 1, 0, 0);
    run_write("early_native_LAST", 15, 32'h80000200, 0, 3, 1, 0, 0, 0, 1, 0);
    run_write("missing_native_LAST", 15, 32'h80000200, 6, 0, 1, 1, 0, 0, 2, 0);
    run_write("single", 0, 32'h80000200, 3, 7, 0, 0, 0, 0, 0, 0);
    run_write("cross_4K", 15, 32'h80000ffc, 0, 0, 0, 1, 0, 0, 0, 1);
    run_write("unaligned", 15, 32'h80000201, 0, 0, 0, 0, 0, 0, 0, 1);
    run_write("unsupported_length", 2, 32'h80000200, 0, 0, 0, 0, 0, 0, 0, 1);
    run_write("max_rejected_length", 255, 32'h80000200, 0, 0, 0, 0, 0, 0, 0, 1);
    // Cancel a buffered write with AW and W both blocked, then start afresh.
    @(negedge clk); rst = 1; req_valid = 0; aw_delay = 100; w_delay = 100; invalid_command = 0;
    tick(2); @(negedge clk); rst = 0; req_valid = 1; req_write = 1;
    req_addr = 32'h80000200; req_len = 15; req_wdata = word_data(0); req_wstrb = 4'hf; req_wlast = 0;
    @(posedge clk); if (!req_ready) $fatal(1, "reset setup did not accept first beat");
    @(negedge clk); req_valid = 0; rst = 1;
    tick(2);
    if (m_axi_awvalid || m_axi_wvalid || rsp_valid) $fatal(1, "reset retained buffered write");
    checks++;
    run_write("after_reset", 15, 32'h80000200, 0, 0, 1, 1, 0, 0, 0, 0);
    $display("[AXI4-WRITE-BURST] PASS checks=%0d", checks);
    $finish;
  end
  initial begin #100000; $fatal(1, "write burst timeout"); end
endmodule

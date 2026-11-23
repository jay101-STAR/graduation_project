`timescale 1ns / 1ns
module mem_burst_arbiter_tb;
  reg clk = 0, rst = 1;
  always #5 clk = ~clk;
  reg [1:0] s_req_valid = 0, s_req_write = 0, s_rsp_ready = 0;
  reg [15:0] s_req_len = 0;
  reg [63:0] s_req_addr = 0, s_req_wdata = 0;
  reg [7:0] s_req_wstrb = 0;
  reg s_req_wlast = 0;
  wire [1:0] s_req_ready, s_rsp_valid, s_rsp_error, s_rsp_last;
  wire [63:0] s_rsp_rdata;
  wire rd_req_valid, rd_rsp_ready, wr_req_valid, wr_rsp_ready, wr_req_wlast;
  wire [31:0] rd_req_addr, wr_req_addr, wr_req_wdata;
  wire [7:0] rd_req_len, wr_req_len;
  wire [3:0] wr_req_wstrb;
  reg rd_pending = 0, wr_pending = 0, wr_input_done = 0;
  reg [31:0] rd_addr = 0, wr_addr = 0;
  reg [7:0] rd_len = 0, wr_len = 0;
  int rd_index = 0, wr_index = 0;
  reg random_waits = 0, early_response = 0;
  reg hold_read_req = 0, hold_write_req = 0, hold_read_rsp = 0, hold_write_rsp = 0;
  reg [15:0] random_state = 16'h91ed;
  int seed = 493;
  wire rd_rsp_valid = !rst && rd_pending && !hold_read_rsp;
  wire rd_rsp_last = rd_index == int'(rd_len);
  wire [31:0] rd_rsp_rdata = data_word(rd_addr, rd_index);
  wire rd_rsp_error = rd_addr[7] && rd_index == (int'(rd_len)/2);
  wire wr_rsp_valid = !rst && wr_pending && (wr_input_done || early_response) && !hold_write_rsp;
  wire wr_rsp_error = wr_addr[7];
  wire rd_done = rd_rsp_valid && rd_rsp_ready && rd_rsp_last;
  wire wr_done = wr_rsp_valid && wr_rsp_ready;
  wire rd_req_ready = !rst && !hold_read_req && (!rd_pending || rd_done) && (!random_waits || random_state[0]);
  wire wr_req_ready = !rst && !hold_write_req && (!wr_pending || !wr_input_done || wr_done) &&
                      (!random_waits || random_state[3]);
  int reads = 0, writes = 0, rbeats = 0, wbeats = 0, simultaneous = 0;
  int overlaps = 0, independent_reads = 0, independent_writes = 0, read_handoffs = 0;
  int stalled_reads = 0, stalled_writes = 0, errors = 0, checks = 0;
  reg rd_blocked = 0, wr_blocked = 0;
  reg [39:0] held_rd;
  reg [76:0] held_wr;
  string wave;
  mem_burst_arbiter dut(.*);
  function automatic [31:0] data_word(input [31:0] addr, input int index);
    return addr ^ 32'h635a0000 ^ (32'(index) * 32'h00010101);
  endfunction
  function automatic [3:0] mask(input int index);
    return 4'(index ^ 15);
  endfunction
  always @(negedge clk) begin
    random_state = {random_state[14:0], random_state[15]^random_state[13]^random_state[12]^random_state[10]};
    if (!rst) s_rsp_ready = random_waits ? random_state[6:5] : 2'b11;
    else s_rsp_ready = 0;
  end
  always @(posedge clk) begin
    if (rst) begin
      rd_pending <= 0; wr_pending <= 0; wr_input_done <= 0;
      rd_index <= 0; wr_index <= 0; rd_blocked <= 0; wr_blocked <= 0;
    end else begin
      if (rd_blocked && (!rd_req_valid || {rd_req_addr, rd_req_len} !== held_rd))
        $fatal(1, "read offer changed under backpressure");
      if (wr_blocked && (!wr_req_valid || {wr_req_addr, wr_req_len, wr_req_wdata, wr_req_wstrb, wr_req_wlast} !== held_wr))
        $fatal(1, "write offer changed under backpressure");
      rd_blocked <= rd_req_valid && !rd_req_ready; held_rd <= {rd_req_addr, rd_req_len};
      wr_blocked <= wr_req_valid && !wr_req_ready;
      held_wr <= {wr_req_addr, wr_req_len, wr_req_wdata, wr_req_wstrb, wr_req_wlast};
      if (rd_pending && wr_pending) overlaps++;
      if (&s_rsp_valid && &s_rsp_ready) simultaneous++;
      if (wr_rsp_ready && !wr_input_done) $fatal(1, "early write response escaped");
      if (rd_done) rd_pending <= 0;
      if (rd_rsp_valid && rd_rsp_ready) begin rd_index <= rd_index + 1; rbeats++; end
      if (wr_done) begin wr_pending <= 0; wr_input_done <= 0; end
      if (rd_req_valid && rd_req_ready) begin
        bit lane;
        lane = rd_req_addr[15];
        if (!s_req_ready[lane] || !s_req_valid[lane] || s_req_write[lane] ||
            {rd_req_addr, rd_req_len} !== {s_req_addr[lane*32 +: 32], s_req_len[lane*8 +: 8]})
          $fatal(1, "read source mismatch");
        if (rd_pending && !rd_done) $fatal(1, "two pending reads");
        if (rd_done) read_handoffs++;
        if (hold_write_req || hold_write_rsp) independent_reads++;
        reads++; rd_pending <= 1; rd_addr <= rd_req_addr; rd_len <= rd_req_len; rd_index <= 0;
      end
      if (wr_req_valid && wr_req_ready) begin
        int index;
        index = (!wr_pending || wr_done) ? 0 : wr_index;
        if (!s_req_ready[1] || !s_req_write[1] || wr_req_wdata !== data_word(wr_req_addr,index) ||
            wr_req_wstrb !== mask(index) || wr_req_wlast !== (index == int'(wr_req_len)))
          $fatal(1, "write source/data/LAST mismatch index=%0d",index);
        if (!wr_pending || wr_done) begin
          writes++; wr_addr <= wr_req_addr; wr_len <= wr_req_len;
        end else if (wr_req_addr != wr_addr || wr_req_len != wr_len || wr_input_done)
          $fatal(1, "write ownership/length changed");
        if (hold_read_req || hold_read_rsp) independent_writes++;
        wr_pending <= 1; wr_index <= index+1; wr_input_done <= index == int'(wr_req_len); wbeats++;
      end
      if (rd_req_valid && !rd_req_ready) stalled_reads++;
      if (wr_req_valid && !wr_req_ready) stalled_writes++;
      for (int lane=0; lane<2; lane++) if (s_rsp_valid[lane]) begin
        if (lane == 1 && wr_pending) begin
          if (!wr_input_done || s_rsp_rdata[63:32] != 0 || s_rsp_error[1] !== wr_rsp_error || !s_rsp_last[1])
            $fatal(1, "bad write response routing");
        end else if (!rd_pending || rd_addr[15] != 1'(lane) ||
            s_rsp_rdata[lane*32 +: 32] !== rd_rsp_rdata || s_rsp_error[lane] !== rd_rsp_error ||
            s_rsp_last[lane] !== rd_rsp_last)
          $fatal(1, "bad read response routing lane=%0d",lane);
        if (s_rsp_ready[lane] && s_rsp_error[lane]) errors++;
      end
    end
  end
  task automatic transaction(input int lane, input bit write_op, input int len, input int tag, input int gap=0);
    bit expected_error;
    int n;
    @(negedge clk);
    s_req_addr[lane*32 +: 32] = 32'h80000000 + (32'(lane)<<15) + 32'(tag*64);
    s_req_len[lane*8 +: 8] = 8'(len); s_req_write[lane] = write_op;
    n = write_op ? len+1 : 1;
    expected_error = s_req_addr[lane*32+7];
    for (int k=0; k<n; k++) begin
      s_req_wdata[lane*32 +: 32] = data_word(s_req_addr[lane*32 +: 32],k);
      s_req_wstrb[lane*4 +: 4] = mask(k);
      if (lane == 1) s_req_wlast = write_op && k == len;
      s_req_valid[lane] = 1;
      do @(posedge clk); while (!s_req_ready[lane]);
      @(negedge clk); s_req_valid[lane] = 0;
      if (k != n-1) repeat(gap) @(negedge clk);
    end
    n = write_op ? 1 : len+1;
    for (int k=0; k<n; k++) begin
      do @(posedge clk); while (!(s_rsp_valid[lane] && s_rsp_ready[lane]));
      @(negedge clk);
    end
    checks++;
  endtask
  task automatic reset_dut;
    @(negedge clk); rst = 1; s_req_valid = 0;
    repeat(3) @(negedge clk); rst = 0;
  endtask
  initial begin
    if ($value$plusargs("wave=%s",wave)) begin $dumpfile(wave); $dumpvars(0,mem_burst_arbiter_tb); end
    if ($value$plusargs("seed=%d",seed)) begin end
    random_state = 16'(seed); reset_dut();
    fork
      begin for(int k=0;k<24;k++) transaction(0,0,k%2 ? 15:0,k); end
      begin for(int k=0;k<24;k++) transaction(1,1,k%2 ? 15:0,k,1); end
    join
    random_waits=1; early_response=1;
    fork
      begin for(int k=0;k<60;k++) transaction(0,0,k%3 ? 15:0,k); end
      begin for(int k=0;k<60;k++) transaction(1,k%3 != 0,k%2 ? 15:0,k,k%3); end
    join
    random_waits=0; early_response=0;
    // Stop write requests while reads complete, then reverse the directions.
    hold_write_req=1;
    fork
      begin transaction(1,1,15,90); end
      begin transaction(0,0,15,90); @(negedge clk); hold_write_req=0; end
    join
    hold_read_req=1;
    fork
      begin transaction(0,0,15,91); end
      begin transaction(1,1,15,91); @(negedge clk); hold_read_req=0; end
    join
    hold_write_rsp=1;
    fork
      begin transaction(1,1,15,92); end
      begin transaction(0,0,15,92); @(negedge clk); hold_write_rsp=0; end
    join
    hold_read_rsp=1;
    fork
      begin transaction(0,0,15,93); end
      begin transaction(1,1,15,93); @(negedge clk); hold_read_rsp=0; end
    join
    // Both locked/stalled offers and both outstanding responses cancel on reset.
    hold_read_req=1; hold_write_req=1;
    @(negedge clk); s_req_valid=3; s_req_write=2; s_req_len=16'h0f0f; s_req_wlast=0;
    repeat(4) @(negedge clk); reset_dut(); hold_read_req=0; hold_write_req=0;
    hold_read_rsp=1; hold_write_rsp=1;
    @(negedge clk); s_req_addr={32'h80008000,32'h80000000}; s_req_len=0;
    s_req_write=2; s_req_wdata[63:32]=data_word(32'h80008000,0); s_req_wstrb[7:4]=mask(0);
    s_req_wlast=1; s_req_valid=3;
    @(posedge clk); if(s_req_ready!=3) $fatal(1,"simultaneous reset setup");
    @(negedge clk); s_req_valid=0;
    repeat(4) @(negedge clk); reset_dut();
    hold_read_rsp=0; hold_write_rsp=0;
    transaction(0,0,15,95); transaction(1,1,15,95);
    if(overlaps==0 || simultaneous==0 || independent_reads==0 || independent_writes==0 ||
       stalled_reads==0 || stalled_writes==0 || errors==0)
      $fatal(1,"parallel arbitration coverage missing");
    $display("[BURST-ARBITER] PASS checks=%0d reads=%0d writes=%0d R=%0d W=%0d overlap=%0d simultaneous=%0d independent_read=%0d independent_write=%0d handoffs=%0d errors=%0d",
      checks,reads,writes,rbeats,wbeats,overlaps,simultaneous,independent_reads,independent_writes,read_handoffs,errors);
    $finish;
  end
  initial begin #1000000; $fatal(1,"arbiter timeout"); end
endmodule

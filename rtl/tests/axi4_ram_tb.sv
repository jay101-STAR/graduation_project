`timescale 1ns / 1ns
module axi4_ram_tb;
  reg clk = 0, rst = 1;
  always #5 clk = ~clk;
  reg awid = 0;
  reg [31:0] awaddr = 0;
  reg [7:0] awlen = 0;
  reg [2:0] awsize = 0;
  reg [1:0] awburst = 0;
  reg awlock = 0;
  reg [3:0] awcache = 0;
  reg [2:0] awprot = 0;
  reg [3:0] awqos = 0;
  reg [3:0] awregion = 0;
  reg awvalid = 0;
  wire awready;
  reg arid = 0;
  reg [31:0] araddr = 0;
  reg [7:0] arlen = 0;
  reg [2:0] arsize = 0;
  reg [1:0] arburst = 0;
  reg arlock = 0;
  reg [3:0] arcache = 0;
  reg [2:0] arprot = 0;
  reg [3:0] arqos = 0;
  reg [3:0] arregion = 0;
  reg arvalid = 0;
  wire arready;
  reg [31:0] wdata = 0;
  reg [3:0] wstrb = 0;
  reg wlast = 0;
  reg wvalid = 0;
  wire wready;
  wire bid;
  wire [1:0] bresp;
  wire bvalid;
  reg bready = 0;
  wire rid;
  wire [31:0] rdata;
  wire [1:0] rresp;
  wire rlast;
  wire rvalid;
  reg rready = 0;
  wire [31:0] tohost;
  reg [31:0] model [0:16383];
  integer checks = 0, clock_count = 0;
  integer ar_count = 0, r_count = 0, aw_count = 0, w_count = 0, b_count = 0;
  string wave;
  axi4_ram_slave #(.BANK0_HEX(""), .BANK1_HEX("")) dut (
      .clk(clk), .rst(rst), .tohost_value(tohost),
      .s_axi_awid(awid),
      .s_axi_awaddr(awaddr),
      .s_axi_awlen(awlen),
      .s_axi_awsize(awsize),
      .s_axi_awburst(awburst),
      .s_axi_awlock(awlock),
      .s_axi_awcache(awcache),
      .s_axi_awprot(awprot),
      .s_axi_awqos(awqos),
      .s_axi_awregion(awregion),
      .s_axi_awvalid(awvalid),
      .s_axi_awready(awready),
      .s_axi_arid(arid),
      .s_axi_araddr(araddr),
      .s_axi_arlen(arlen),
      .s_axi_arsize(arsize),
      .s_axi_arburst(arburst),
      .s_axi_arlock(arlock),
      .s_axi_arcache(arcache),
      .s_axi_arprot(arprot),
      .s_axi_arqos(arqos),
      .s_axi_arregion(arregion),
      .s_axi_arvalid(arvalid),
      .s_axi_arready(arready),
      .s_axi_wdata(wdata),
      .s_axi_wstrb(wstrb),
      .s_axi_wlast(wlast),
      .s_axi_wvalid(wvalid),
      .s_axi_wready(wready),
      .s_axi_bid(bid),
      .s_axi_bresp(bresp),
      .s_axi_bvalid(bvalid),
      .s_axi_bready(bready),
      .s_axi_rid(rid),
      .s_axi_rdata(rdata),
      .s_axi_rresp(rresp),
      .s_axi_rlast(rlast),
      .s_axi_rvalid(rvalid),
      .s_axi_rready(rready)
  );

  reg r_blocked = 0, b_blocked = 0, aw_seen = 0;
  reg [35:0] held_r;
  reg [2:0] held_b;
  reg [8:0] accepted_w = 0, expected_w = 0;
  always @(posedge clk) begin
    clock_count <= clock_count + 1;
    if (rst) begin
      r_blocked <= 0; b_blocked <= 0; aw_seen <= 0;
      accepted_w <= 0; expected_w <= 0;
    end else begin
      if (r_blocked && (!rvalid || held_r !== {rdata, rresp, rid, rlast}))
        $fatal(1, "R changed under backpressure");
      if (b_blocked && (!bvalid || held_b !== {bid, bresp}))
        $fatal(1, "B changed under backpressure");
      r_blocked <= rvalid && !rready; held_r <= {rdata, rresp, rid, rlast};
      b_blocked <= bvalid && !bready; held_b <= {bid, bresp};
      if (arvalid && arready) ar_count <= ar_count + 1;
      if (rvalid && rready) r_count <= r_count + 1;
      if (awvalid && awready) begin
        if (aw_seen) $fatal(1, "overlapping AW");
        aw_seen <= 1; expected_w <= {1'b0, awlen} + 9'd1;
        aw_count <= aw_count + 1;
      end
      if (wvalid && wready) begin
        accepted_w <= accepted_w + 9'd1;
        w_count <= w_count + 1;
      end
      if (bvalid && (!aw_seen || accepted_w != expected_w))
        $fatal(1, "B before all AW/W handshakes");
      if (bvalid && bready) begin
        b_count <= b_count + 1; aw_seen <= 0; accepted_w <= 0;
      end
    end
  end

  task automatic send_aw(input [31:0] addr, input integer len, input integer delay_cycles);
    repeat (delay_cycles) @(negedge clk);
    awaddr = addr; awlen = 8'(len); awvalid = 1;
    do @(posedge clk); while (!awready);
    @(negedge clk); awvalid = 0; awaddr = 32'hdeadbeef;
  endtask

  task automatic send_w(input [31:0] value, input integer mask, input integer len,
                        input integer delay_cycles, input integer gaps,
                        input integer last_mode, input bit check_rate);
    integer previous_cycle;
    repeat (delay_cycles) @(negedge clk);
    previous_cycle = -1;
    for (int k=0; k<=len; k++) begin
      wdata = value + 32'(k); wstrb = mask < 0 ? 4'(k) : 4'(mask);
      wlast = last_mode == 1 ? k == 0 : last_mode == 2 ? 1'b0 : k == len;
      wvalid = 1;
      do @(posedge clk); while (!wready);
      if (check_rate && k != 0 && clock_count != previous_cycle+1)
        $fatal(1, "write burst did not sustain one beat per clock");
      previous_cycle = clock_count;
      @(negedge clk); wvalid = 0;
      repeat (gaps) @(negedge clk);
    end
  endtask

  task automatic write_words(input [31:0] addr, input [31:0] value, input integer mask=15,
                             input integer len=0, input integer adelay=0, input integer wdelay=0,
                             input integer gaps=0, input [1:0] expected_resp=0, input integer last_mode=0);
    integer before_aw, before_w, before_b;
    reg [3:0] byte_mask;
    reg [31:0] beat_data;
    @(negedge clk);
    before_aw = aw_count; before_w = w_count; before_b = b_count;
    fork
      send_aw(addr, len, adelay);
      send_w(value, mask, len, wdelay, gaps, last_mode, gaps == 0 && wdelay >= adelay);
    join
    while (!bvalid) @(negedge clk);
    repeat (4) begin
      if (!bvalid || bresp !== expected_resp || bid !== awid || awready || wready)
        $fatal(1, "B response/transaction blocking addr=%h got=%b expected=%b", addr, bresp, expected_resp);
      @(negedge clk);
    end
    bready = 1;
    @(posedge clk);
    @(negedge clk); bready = 0;
    if (bvalid || aw_count != before_aw+1 || w_count != before_w+len+1 || b_count != before_b+1)
      $fatal(1, "write handshake count mismatch");
    // A malformed final LAST leaves earlier words committed. Early LAST at
    // beat zero suppresses that beat and all remaining writes of this request.
    for (int k=0; k<=len; k++) begin
      if (expected_resp == 0 || (last_mode == 2 && k < len)) begin
        byte_mask = mask < 0 ? 4'(k) : 4'(mask);
        beat_data = value + 32'(k);
        for (int b=0; b<4; b++) if (byte_mask[b])
          model[int'(addr[15:2])+k][b*8+:8] = beat_data[b*8+:8];
      end
    end
    checks++;
  endtask

  task automatic read_words(input [31:0] addr, input integer len=0,
                            input [1:0] expected_resp=0, input bit stalled=0,
                            input [2:0] size=2, input [1:0] burst=1);
    integer previous_cycle, before_ar, before_r;
    @(negedge clk);
    before_ar = ar_count; before_r = r_count;
    araddr = addr; arlen = 8'(len); arsize = size; arburst = burst; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; araddr = 32'hdeadbeef;
    if (!rvalid) $fatal(1, "AR to first R exceeded one cycle");
    rready = !stalled; previous_cycle = -1;
    for (int k=0; k<=len; k++) begin
      if (stalled) begin
        repeat (1+k%4) @(negedge clk);
        rready = 1;
      end
      do @(posedge clk); while (!rvalid);
      if (rid !== arid || rlast !== (k == len) || rresp !== expected_resp)
        $fatal(1, "read metadata addr=%h beat=%0d", addr, k);
      if (expected_resp == 0 && rdata !== model[int'(addr[15:2])+k])
        $fatal(1, "read data addr=%h beat=%0d got=%h expected=%h", addr, k, rdata, model[int'(addr[15:2])+k]);
      if (expected_resp != 0 && rdata !== 0) $fatal(1, "error read leaked data");
      if (!stalled && k != 0 && clock_count != previous_cycle+1)
        $fatal(1, "read burst did not sustain one beat per clock");
      previous_cycle = clock_count;
      @(negedge clk);
      if (stalled) rready = 0;
    end
    rready = 0;
    if (ar_count != before_ar+1 || r_count != before_r+len+1 || rvalid)
      $fatal(1, "read handshake count mismatch");
    checks++;
  endtask

  reg [35:0] snapshot;
  initial begin
    if ($value$plusargs("wave=%s", wave)) begin $dumpfile(wave); $dumpvars(0, axi4_ram_tb); end
    for (int k=0; k<16384; k++) model[k] = 0;
    repeat (3) @(negedge clk); rst = 0;
    awsize = 2; awburst = 1; arsize = 2; arburst = 1; awid = 1; arid = 1;
    // Same-cycle AW/W, W before AW, and AW before W, for both legal lengths.
    for (int n=0; n<2; n++) begin
      write_words(32'h80000000, 32'h12340000, 15, n*15);
      write_words(32'h80000040, 32'h56780000, 15, n*15, 5, 0);
      write_words(32'h80000080, 32'h9abc0000, 15, n*15, 0, 5);
      read_words(32'h80000000, n*15);
      read_words(32'h80000040, n*15, 0, 1);
      read_words(32'h80000080, n*15);
    end
    // Every byte mask, input gaps, both banks, the final RAM line and a 4 KiB edge.
    write_words(32'h80000000, 32'hfedcba00, -1, 15, 0, 2, 2);
    read_words(32'h80000000, 15, 0, 1);
    write_words(32'h8000ffc0, 32'hdead0000, 15, 15);
    read_words(32'h8000ffc0, 15);
    write_words(32'h80000fc0, 32'hface0000, 15, 15, 3, 0);
    read_words(32'h80000fc0, 15);
    // Unaligned-to-line but word-aligned bursts still increment across banks.
    write_words(32'h80000004, 32'h31410000, 15, 15);
    read_words(32'h80000004, 15);
    fork
      read_words(32'h80000000, 15);
      write_words(32'h80000200, 32'h13570000, 15, 15);
    join
    read_words(32'h80000200, 15);
    for (int mask=0; mask<16; mask++) begin
      write_words(32'h80000004, 32'h31415926 ^ 32'(mask*971), mask);
      read_words(32'h80000004, 0, 0, 1);
    end
    // An invalid AW must drain the entire length without changing RAM/tohost.
    for (int kind=0; kind<7; kind++) begin
      awsize = kind == 0 ? 1 : 2; awburst = kind == 1 ? 0 : 1; awlock = kind == 2;
      write_words(kind == 3 ? 32'h80000ffc : kind == 4 ? 32'h80000002 :
                  kind == 5 ? 32'h90000000 : 32'h80000000,
                  32'hbad00000, 15, kind == 6 ? 3 : 15, 4, 0, 0, 2);
    end
    awsize = 2; awburst = 1; awlock = 0;
    write_words(32'h80000000, 32'hbad00000, 15, 255, 2, 0, 0, 2);
    write_words(32'h80001000, 32'hbad00000, 15, 3, 0, 2, 0, 2);
    if (tohost != 0) $fatal(1, "invalid AW changed tohost");
    read_words(32'h80000000, 15);
    read_words(32'h80000fc0, 15);
    read_words(32'h80000000, 15, 2, 1, 1);
    read_words(32'h80000000, 15, 2, 0, 2, 2);
    arlock = 1; read_words(32'h80000000, 15, 2); arlock = 0;
    read_words(32'h80000ffc, 15, 2, 1);
    read_words(32'h80000002, 0, 2);
    read_words(32'h90000000, 15, 2);
    read_words(32'h80000000, 255, 2);
    // WLAST is checked against AWLEN; errors do not truncate the drain.
    write_words(32'h80000000, 32'hbadd0000, 15, 15, 5, 0, 0, 2, 1);
    read_words(32'h80000000, 15);
    write_words(32'h80000000, 32'hbeef0000, 15, 15, 0, 0, 0, 2, 2);
    read_words(32'h80000000, 15);
    write_words(32'h80000000, 32'hbad00000, 15, 0, 3, 0, 0, 2, 2);
    read_words(32'h80000000, 15);
    // A held R payload must survive concurrent same-address writes. Later
    // burst beats read after the overwrite and therefore see the new values.
    @(negedge clk); araddr = 32'h80000000; arlen = 15; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; snapshot = {rdata, rresp, rid, rlast};
    write_words(32'h80000000, 32'hcafe0000, 15, 15);
    if (!rvalid || snapshot !== {rdata, rresp, rid, rlast}) $fatal(1, "blocked R overwritten");
    rready = 1;
    for (int k=0; k<16; k++) begin
      @(posedge clk);
      if (!rvalid || rdata !== (k == 0 ? snapshot[35:4] : model[k]) || rlast != (k == 15))
        $fatal(1, "concurrent read/write beat %0d", k);
      @(negedge clk);
    end
    rready = 0;
    // Consume LAST and replace it with a new AR on the same edge.
    @(negedge clk); araddr = 32'h80000000; arlen = 0; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); araddr = 32'h80000004; rready = 1;
    @(posedge clk);
    if (!arready || !rvalid || !rlast || rdata !== model[0]) $fatal(1, "AR replacement");
    @(negedge clk); arvalid = 0;
    @(posedge clk);
    if (!rvalid || !rlast || rdata !== model[1]) $fatal(1, "AR replacement bubble");
    @(negedge clk); rready = 0;
    write_words(32'h80001000, 32'h12345678);
    write_words(32'h80001000, 32'h89abcdef, 5);
    write_words(32'h80001000, 32'hffffffff, 0);
    if (tohost !== model[1024]) $fatal(1, "tohost byte masks");
    write_words(32'h80000ffc, 32'hffff0000, 15, 15, 0, 0, 0, 2);
    if (tohost !== model[1024]) $fatal(1, "invalid burst changed tohost");
    write_words(32'h80001000, 32'h76540000, 15, 15);
    if (tohost !== model[1024]) $fatal(1, "burst tohost update");
    write_words(32'h80001000, 32'h76540000, -1, 15);
    if (tohost !== model[1024]) $fatal(1, "burst tohost mask");
    // Reset discards pre-address data, active bursts and held responses, while
    // preserving already committed BRAM words.
    @(negedge clk); wdata = 32'hbadbad00; wstrb = 15; wlast = 1; wvalid = 1;
    @(posedge clk); if (!wready) $fatal(1, "W before AW not buffered");
    @(negedge clk); wvalid = 0; rst = 1;
    @(negedge clk); rst = 0;
    write_words(32'h80000000, 32'habcdef00);
    read_words(32'h80000000);
    @(negedge clk);
    send_aw(32'h80000000, 15, 0);
    send_w(32'h10100000, 15, 0, 0, 0, 2, 0);
    model[0] = 32'h10100000;
    rst = 1;
    @(negedge clk);
    if (rvalid || bvalid || awready || wready || arready) $fatal(1, "reset channel gating");
    rst = 0;
    read_words(32'h80000000, 15);
    @(negedge clk);
    fork
      send_aw(32'h80000008, 0, 0);
      send_w(32'hdecafbad, 15, 0, 2, 0, 0, 0);
    join
    while (!bvalid) @(negedge clk);
    model[2] = 32'hdecafbad; rst = 1;
    @(negedge clk); rst = 0;
    read_words(32'h80000008);
    @(negedge clk); araddr = 32'h80000000; arlen = 15; arvalid = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0; rst = 1;
    @(negedge clk); rst = 0;
    read_words(32'h80000000, 15);
    if (tohost != 0) $fatal(1, "tohost reset");
    $display("[AXI4-RAM] PASS checks=%0d AW=%0d W=%0d B=%0d AR=%0d R=%0d", checks, aw_count, w_count, b_count, ar_count, r_count);
    $finish;
  end
  initial begin #500000; $fatal(1, "AXI4 RAM timeout"); end
endmodule

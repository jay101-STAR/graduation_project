`timescale 1ns / 1ns

module mem_attr_decode_tb;
  reg [33:0] addr;
  reg [31:0] effective_addr;
  wire [33:0] translated;
  wire valid_addr, executable, cacheable, line_cacheable, mmio;
  wire alt_cacheable, alt_line_cacheable;
  integer n, high_bits, checks = 0;
  addr_translate_bypass translation (.effective_addr(effective_addr), .phys_addr(translated));
  mem_attr_decode dut (
      .phys_addr(addr), .addr_valid(valid_addr), .executable(executable),
      .cacheable(cacheable), .line_cacheable(line_cacheable), .is_mmio(mmio)
  );
  // Unaligned TOHOST_ADDR and a different line size catch hard-coded exclusions.
  mem_attr_decode #(.LINE_BYTES(64), .TOHOST_ADDR(34'h0_80001234)) alternate (
      .phys_addr(addr), .addr_valid(), .executable(),
      .cacheable(alt_cacheable), .line_cacheable(alt_line_cacheable), .is_mmio()
  );
  task automatic check(input [33:0] address, input [4:0] expected);
    begin
      addr = address;
      #1;
      if ({valid_addr, executable, cacheable, line_cacheable, mmio} !== expected)
        $fatal(1, "Attributes addr=%h got=%b expected=%b", address,
               {valid_addr, executable, cacheable, line_cacheable, mmio}, expected);
      checks = checks + 1;
    end
  endtask
  initial begin
    effective_addr = 32'h80000000;
    #1;
    if (translated !== 34'h0_80000000) $fatal(1, "Address zero extension failed");
    effective_addr = 32'hffffffff;
    #1;
    if (translated !== 34'h0_ffffffff) $fatal(1, "Address sign-extended");
    // Check every RAM byte, including the whole special line and both edges.
    for (n = 0; n < 65536; n = n + 1)
      check(34'h0_80000000 + 34'(n), (n >= 4096 && n < 4128) ? 5'b11000 : 5'b11110);
    for (n = 0; n < 16; n = n + 1) check(34'h0_10000000 + 34'(n), 5'b10001);
    check(34'h0_7fffffff, 5'b00000);
    check(34'h0_80010000, 5'b00000);
    check(34'h0_0fffffff, 5'b00000);
    check(34'h0_10000010, 5'b00000);
    check(34'h0_ffffffff, 5'b00000);
    for (high_bits = 1; high_bits < 4; high_bits = high_bits + 1) begin
      check({2'(high_bits), 32'h80000000}, 5'b00000);
      check({2'(high_bits), 32'h80001000}, 5'b00000);
      check({2'(high_bits), 32'h10000000}, 5'b00000);
    end
    for (n = 0; n < 128; n = n + 1) begin
      addr = 34'h0_80001200 + 34'(n);
      #1;
      if (alt_cacheable !== (n >= 64) || alt_line_cacheable !== (n >= 64))
        $fatal(1, "Parameterized tohost line failed addr=%h", addr);
    end
    $display("[MEM-ATTR-UNIT] PASS checks=%0d plus 128 alternate-line checks", checks);
    $finish;
  end
endmodule

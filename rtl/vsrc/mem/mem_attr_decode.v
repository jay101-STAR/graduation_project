`timescale 1ns / 1ns

// Decode the FULL physical address before a cache lookup or bus narrowing.
// Attributes describe byte addresses; aligned-word checking is done separately.
module mem_attr_decode #(
    parameter integer        LINE_BYTES  = 32,
    parameter         [33:0] TOHOST_ADDR = 34'h0_80001000
) (
    input  [33:0] phys_addr,
    output        addr_valid,
    output        executable,
    output        cacheable,
    output        line_cacheable,
    output        is_mmio
);
  localparam [33:0] RAM_BASE = 34'h0_80000000;
  localparam [33:0] RAM_LAST = 34'h0_8000ffff;
  localparam [33:0] UART_BASE = 34'h0_10000000;
  localparam [33:0] UART_LAST = 34'h0_1000000f;
  localparam [33:0] LINE_MASK = 34'(LINE_BYTES) - 34'd1;
  localparam [33:0] TOHOST_LINE = TOHOST_ADDR & ~LINE_MASK;
  localparam [33:0] TOHOST_LAST = TOHOST_LINE | LINE_MASK;
  wire in_ram = (phys_addr >= RAM_BASE) && (phys_addr <= RAM_LAST);
  wire in_tohost = (phys_addr >= TOHOST_LINE) && (phys_addr <= TOHOST_LAST);
  wire [33:0] line_base = phys_addr & ~LINE_MASK;
  wire [33:0] line_last = line_base | LINE_MASK;

  assign is_mmio = (phys_addr >= UART_BASE) && (phys_addr <= UART_LAST);
  assign addr_valid = in_ram || is_mmio;
  assign executable = in_ram;
  assign cacheable = in_ram && !in_tohost;
  assign line_cacheable = (line_base >= RAM_BASE) && (line_last <= RAM_LAST) &&
                         !((line_base <= TOHOST_LAST) && (line_last >= TOHOST_LINE));

  // synthesis translate_off
  initial begin
    if (LINE_BYTES < 4 || (LINE_BYTES & (LINE_BYTES - 1)) != 0)
      $fatal(1, "LINE_BYTES must be a power of two, at least four");
  end
  // synthesis translate_on
endmodule

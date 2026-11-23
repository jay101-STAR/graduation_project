`timescale 1ns / 1ns

// Current no-MMU mapping. This is an address boundary, not a TLB or a page
// permission check. Future translation must also preserve the original VA.
module addr_translate_bypass (
    input  [31:0] effective_addr,
    output [33:0] phys_addr
);
  assign phys_addr = {2'b00, effective_addr};
endmodule

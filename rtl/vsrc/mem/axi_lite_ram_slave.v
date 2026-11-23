`timescale 1ns / 1ns

// 64 KiB, interleaved bank0/bank1 images compatible with the existing tooling.
// AW and W are captured independently. Read data and both response channels
// remain stable until accepted. The memory contents are not cleared on reset.
module axi_lite_ram_slave #(
    parameter BANK0_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank0.hex",
    parameter BANK1_HEX = "/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank1.hex"
) (
    input clk, input rst,
    input [31:0] s_axi_awaddr, input [2:0] s_axi_awprot,
    input s_axi_awvalid, output s_axi_awready,
    input [31:0] s_axi_wdata, input [3:0] s_axi_wstrb,
    input s_axi_wvalid, output s_axi_wready,
    output reg [1:0] s_axi_bresp, output reg s_axi_bvalid, input s_axi_bready,
    input [31:0] s_axi_araddr, input [2:0] s_axi_arprot,
    input s_axi_arvalid, output s_axi_arready,
    output [31:0] s_axi_rdata, output [1:0] s_axi_rresp,
    output s_axi_rvalid, input s_axi_rready,
    output reg [31:0] tohost_value
);
  reg aw_pending, w_pending, read_active, read_bank, read_error, read_saved;
  reg [31:0] read_addr, read_data_saved;
  reg [31:0] awaddr, wdata;
  reg [3:0] wstrb;
  wire aw_fire = s_axi_awvalid && s_axi_awready;
  wire w_fire = s_axi_wvalid && s_axi_wready;
  wire ar_fire = s_axi_arvalid && s_axi_arready;
  wire [31:0] write_addr = aw_pending ? awaddr : s_axi_awaddr;
  wire [31:0] write_data = w_pending ? wdata : s_axi_wdata;
  wire [3:0] write_strb = w_pending ? wstrb : s_axi_wstrb;
  wire write_error = (write_addr[31:16] != 16'h8000) || (write_addr[1:0] != 2'b00);
  wire write_commit = !rst && !s_axi_bvalid &&
                      (aw_pending || aw_fire) && (w_pending || w_fire);
  wire [3:0] ram_we = write_commit && !write_error ? write_strb : 4'b0;
  wire [31:0] bank0_rdata, bank1_rdata;
  assign s_axi_awready = !rst && !aw_pending && !s_axi_bvalid;
  assign s_axi_wready = !rst && !w_pending && !s_axi_bvalid;
  wire [31:0] ram_read_addr = ar_fire ? s_axi_araddr : read_addr;
  wire [31:0] ram_read_data = read_bank ? bank1_rdata : bank0_rdata;
  assign s_axi_arready = !rst && (!read_active || s_axi_rready);
  assign s_axi_rvalid = !rst && read_active;
  assign s_axi_rdata = read_error ? 32'b0 : read_saved ? read_data_saved : ram_read_data;
  assign s_axi_rresp = read_error ? 2'b10 : 2'b00;

  std_bram_tdp #(.HEX_FILE(BANK0_HEX)) bank0 (
      .clk(clk), .a_we(write_addr[2] ? 4'b0 : ram_we),
      .a_addr(write_addr[15:3]), .a_wdata(write_data), .a_rdata(),
      .b_we(4'b0), .b_addr(ram_read_addr[15:3]), .b_wdata(32'b0), .b_rdata(bank0_rdata)
  );
  std_bram_tdp #(.HEX_FILE(BANK1_HEX)) bank1 (
      .clk(clk), .a_we(write_addr[2] ? ram_we : 4'b0),
      .a_addr(write_addr[15:3]), .a_wdata(write_data), .a_rdata(),
      .b_we(4'b0), .b_addr(ram_read_addr[15:3]), .b_wdata(32'b0), .b_rdata(bank1_rdata)
  );

  always @(posedge clk) begin
    if (rst) begin
      aw_pending <= 1'b0;
      w_pending <= 1'b0;
      read_active <= 1'b0;
      read_saved <= 1'b0;
      read_addr <= 32'b0;
      read_data_saved <= 32'b0;
      read_bank <= 1'b0;
      read_error <= 1'b0;
      awaddr <= 32'b0;
      wdata <= 32'b0;
      wstrb <= 4'b0;
      s_axi_bvalid <= 1'b0;
      s_axi_bresp <= 2'b0;
      tohost_value <= 32'b0;
    end else begin
      if (aw_fire) begin aw_pending <= 1'b1; awaddr <= s_axi_awaddr; end
      if (w_fire) begin
        w_pending <= 1'b1;
        wdata <= s_axi_wdata;
        wstrb <= s_axi_wstrb;
      end
      if (write_commit) begin
        aw_pending <= 1'b0;
        w_pending <= 1'b0;
        s_axi_bvalid <= 1'b1;
        s_axi_bresp <= write_error ? 2'b10 : 2'b00;
        if (!write_error && write_addr == 32'h80001000) begin
          if (write_strb[0]) tohost_value[7:0] <= write_data[7:0];
          if (write_strb[1]) tohost_value[15:8] <= write_data[15:8];
          if (write_strb[2]) tohost_value[23:16] <= write_data[23:16];
          if (write_strb[3]) tohost_value[31:24] <= write_data[31:24];
        end
      end else if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 1'b0;

      // The BRAM output is already registered at AR acceptance. Save it only
      // when held, protecting a blocked response from later same-word writes.
      if (read_active && !read_saved) begin
        read_data_saved <= ram_read_data;
        read_saved <= 1'b1;
      end
      if (s_axi_rvalid && s_axi_rready) read_active <= 1'b0;
      if (ar_fire) begin
        read_active <= 1'b1;
        read_saved <= 1'b0;
        read_addr <= s_axi_araddr;
        read_bank <= s_axi_araddr[2];
        read_error <= (s_axi_araddr[31:16] != 16'h8000) || (s_axi_araddr[1:0] != 2'b00);
      end
    end
  end
endmodule

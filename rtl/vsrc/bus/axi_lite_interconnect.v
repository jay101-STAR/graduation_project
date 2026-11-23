`timescale 1ns / 1ns

// One master, two parallel slaves: slot 0 = 64 KiB RAM; slot 1 = UART.
// Independent AW/W capture handles either arrival order. The selected slave
// remains locked through B/R acceptance; unmapped addresses return DECERR.
module axi_lite_interconnect (
    input clk, input rst,
    input [31:0] s_axi_awaddr, input [2:0] s_axi_awprot,
    input s_axi_awvalid, output s_axi_awready,
    input [31:0] s_axi_wdata, input [3:0] s_axi_wstrb,
    input s_axi_wvalid, output s_axi_wready,
    output [1:0] s_axi_bresp, output s_axi_bvalid, input s_axi_bready,
    input [31:0] s_axi_araddr, input [2:0] s_axi_arprot,
    input s_axi_arvalid, output s_axi_arready,
    output [31:0] s_axi_rdata, output [1:0] s_axi_rresp,
    output s_axi_rvalid, input s_axi_rready,
    output [63:0] m_axi_awaddr, output [5:0] m_axi_awprot,
    output [1:0] m_axi_awvalid, input [1:0] m_axi_awready,
    output [63:0] m_axi_wdata, output [7:0] m_axi_wstrb,
    output [1:0] m_axi_wvalid, input [1:0] m_axi_wready,
    input [3:0] m_axi_bresp, input [1:0] m_axi_bvalid, output [1:0] m_axi_bready,
    output [63:0] m_axi_araddr, output [5:0] m_axi_arprot,
    output [1:0] m_axi_arvalid, input [1:0] m_axi_arready,
    input [63:0] m_axi_rdata, input [3:0] m_axi_rresp,
    input [1:0] m_axi_rvalid, output [1:0] m_axi_rready
);
  function [1:0] decode;
    input [31:0] addr;
    begin
      decode = addr[31:16] == 16'h8000 ? 2'd0 :
               addr[31:4] == 28'h1000000 ? 2'd1 : 2'd2;
    end
  endfunction
  reg aw_held, w_held, aw_sent, w_sent, read_active;
  reg [31:0] awaddr, wdata;
  reg [3:0] wstrb;
  reg [2:0] awprot;
  reg [1:0] read_owner;
  wire [1:0] write_owner = decode(awaddr);
  wire [1:0] ar_owner = decode(s_axi_araddr);
  wire write_active = aw_held && w_held;
  wire write_sent = aw_sent && w_sent;
  assign s_axi_awready = !rst && !aw_held;
  assign s_axi_wready = !rst && !w_held;
  wire read_available = !read_active || (s_axi_rvalid && s_axi_rready);
  assign s_axi_arready = !rst && read_available &&
                         (ar_owner == 2'd2 || m_axi_arready[ar_owner[0]]);
  assign s_axi_bvalid = !rst && write_active &&
                        (write_owner == 2'd2 || (write_sent && m_axi_bvalid[write_owner[0]]));
  assign s_axi_bresp = write_owner == 2'd2 ? 2'b11 :
                       write_owner[0] ? m_axi_bresp[3:2] : m_axi_bresp[1:0];
  assign s_axi_rvalid = !rst && read_active &&
                        (read_owner == 2'd2 || m_axi_rvalid[read_owner[0]]);
  assign s_axi_rresp = read_owner == 2'd2 ? 2'b11 :
                       read_owner[0] ? m_axi_rresp[3:2] : m_axi_rresp[1:0];
  assign s_axi_rdata = read_owner == 2'd2 ? 32'b0 :
                       read_owner[0] ? m_axi_rdata[63:32] : m_axi_rdata[31:0];

  genvar slot;
  generate for (slot = 0; slot < 2; slot = slot + 1) begin : gen_slave
    assign m_axi_awaddr[slot*32 +: 32] = awaddr;
    assign m_axi_awprot[slot*3 +: 3] = awprot;
    assign m_axi_wdata[slot*32 +: 32] = wdata;
    assign m_axi_wstrb[slot*4 +: 4] = wstrb;
    assign m_axi_awvalid[slot] = !rst && write_active && !aw_sent && (write_owner == slot);
    assign m_axi_wvalid[slot] = !rst && write_active && !w_sent && (write_owner == slot);
    assign m_axi_bready[slot] = !rst && write_active && write_sent &&
                               (write_owner == slot) && s_axi_bready;
    assign m_axi_araddr[slot*32 +: 32] = s_axi_araddr;
    assign m_axi_arprot[slot*3 +: 3] = s_axi_arprot;
    assign m_axi_arvalid[slot] = !rst && read_available && s_axi_arvalid && (ar_owner == slot);
    assign m_axi_rready[slot] = !rst && read_active && (read_owner == slot) && s_axi_rready;
  end endgenerate

  always @(posedge clk) begin
    if (rst) begin
      aw_held <= 1'b0;
      w_held <= 1'b0;
      aw_sent <= 1'b0;
      w_sent <= 1'b0;
      read_active <= 1'b0;
      awaddr <= 32'b0;
      awprot <= 3'b0;
      wdata <= 32'b0;
      wstrb <= 4'b0;
      read_owner <= 2'd2;
    end else begin
      if (s_axi_awvalid && s_axi_awready) begin
        aw_held <= 1'b1;
        awaddr <= s_axi_awaddr;
        awprot <= s_axi_awprot;
      end
      if (s_axi_wvalid && s_axi_wready) begin
        w_held <= 1'b1;
        wdata <= s_axi_wdata;
        wstrb <= s_axi_wstrb;
      end
      if (| (m_axi_awvalid & m_axi_awready)) aw_sent <= 1'b1;
      if (| (m_axi_wvalid & m_axi_wready)) w_sent <= 1'b1;
      if (s_axi_bvalid && s_axi_bready) begin
        aw_held <= 1'b0;
        w_held <= 1'b0;
        aw_sent <= 1'b0;
        w_sent <= 1'b0;
      end
      if (s_axi_rvalid && s_axi_rready) read_active <= 1'b0;
      if (s_axi_arvalid && s_axi_arready) begin
        read_active <= 1'b1;
        read_owner <= ar_owner;
      end
    end
  end
endmodule

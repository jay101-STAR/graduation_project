`timescale 1ns / 1ns

// One master, RAM/UART slots. Ownership is held through RLAST/B.
// An unmapped read returns the entire requested burst with DECERR.
module axi4_interconnect (
    input clk, input rst,
    input s_axi_awid,
    input [31:0] s_axi_awaddr,
    input [7:0] s_axi_awlen,
    input [2:0] s_axi_awsize,
    input [1:0] s_axi_awburst,
    input s_axi_awlock,
    input [3:0] s_axi_awcache,
    input [2:0] s_axi_awprot,
    input [3:0] s_axi_awqos,
    input [3:0] s_axi_awregion,
    input s_axi_awvalid,
    output s_axi_awready,
    input s_axi_arid,
    input [31:0] s_axi_araddr,
    input [7:0] s_axi_arlen,
    input [2:0] s_axi_arsize,
    input [1:0] s_axi_arburst,
    input s_axi_arlock,
    input [3:0] s_axi_arcache,
    input [2:0] s_axi_arprot,
    input [3:0] s_axi_arqos,
    input [3:0] s_axi_arregion,
    input s_axi_arvalid,
    output s_axi_arready,
    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input s_axi_wlast,
    input s_axi_wvalid,
    output s_axi_wready,
    output s_axi_bid,
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready,
    output s_axi_rid,
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rlast,
    output s_axi_rvalid,
    input s_axi_rready,
    output [1:0] m_axi_awid,
    output [63:0] m_axi_awaddr,
    output [15:0] m_axi_awlen,
    output [5:0] m_axi_awsize,
    output [3:0] m_axi_awburst,
    output [1:0] m_axi_awlock,
    output [7:0] m_axi_awcache,
    output [5:0] m_axi_awprot,
    output [7:0] m_axi_awqos,
    output [7:0] m_axi_awregion,
    output [1:0] m_axi_awvalid,
    input [1:0] m_axi_awready,
    output [1:0] m_axi_arid,
    output [63:0] m_axi_araddr,
    output [15:0] m_axi_arlen,
    output [5:0] m_axi_arsize,
    output [3:0] m_axi_arburst,
    output [1:0] m_axi_arlock,
    output [7:0] m_axi_arcache,
    output [5:0] m_axi_arprot,
    output [7:0] m_axi_arqos,
    output [7:0] m_axi_arregion,
    output [1:0] m_axi_arvalid,
    input [1:0] m_axi_arready,
    output [63:0] m_axi_wdata,
    output [7:0] m_axi_wstrb,
    output [1:0] m_axi_wlast,
    output [1:0] m_axi_wvalid,
    input [1:0] m_axi_wready,
    input [1:0] m_axi_bid,
    input [3:0] m_axi_bresp,
    input [1:0] m_axi_bvalid,
    output [1:0] m_axi_bready,
    input [1:0] m_axi_rid,
    input [63:0] m_axi_rdata,
    input [3:0] m_axi_rresp,
    input [1:0] m_axi_rlast,
    input [1:0] m_axi_rvalid,
    output [1:0] m_axi_rready
);
  function [1:0] decode;
    input [31:0] addr;
    begin
      decode = addr[31:16] == 16'h8000 ? 2'd0 :
               addr[31:4] == 28'h1000000 ? 2'd1 : 2'd2;
    end
  endfunction
  reg read_active, write_active, read_id, write_id, write_done;
  reg [1:0] read_owner, write_owner;
  reg [7:0] read_len, read_beat, write_len, write_beat;
  wire [1:0] ar_owner = decode(s_axi_araddr);
  wire [1:0] aw_owner = decode(s_axi_awaddr);
  wire read_available = !read_active || (s_axi_rvalid && s_axi_rready && s_axi_rlast);
  assign s_axi_arready = !rst && read_available && (ar_owner == 2 || m_axi_arready[ar_owner[0]]);
  assign s_axi_awready = !rst && !write_active && (aw_owner == 2 || m_axi_awready[aw_owner[0]]);
  assign s_axi_wready = !rst && write_active && (write_owner == 2 ? !write_done : m_axi_wready[write_owner[0]]);
  assign s_axi_rvalid = !rst && read_active && (read_owner == 2 || m_axi_rvalid[read_owner[0]]);
  assign s_axi_rdata = read_owner == 2 ? 32'b0 : m_axi_rdata[read_owner[0]*32 +: 32];
  assign s_axi_rresp = read_owner == 2 ? 2'b11 : m_axi_rresp[read_owner[0]*2 +: 2];
  assign s_axi_rid = read_owner == 2 ? read_id : m_axi_rid[read_owner[0]];
  assign s_axi_rlast = read_owner == 2 ? read_beat == read_len : m_axi_rlast[read_owner[0]];
  assign s_axi_bvalid = !rst && write_active && (write_owner == 2 ? write_done : m_axi_bvalid[write_owner[0]]);
  assign s_axi_bresp = write_owner == 2 ? 2'b11 : m_axi_bresp[write_owner[0]*2 +: 2];
  assign s_axi_bid = write_owner == 2 ? write_id : m_axi_bid[write_owner[0]];
  genvar slot;
  generate for (slot = 0; slot < 2; slot = slot + 1) begin : slaves
    assign m_axi_awid[slot*1 +: 1] = s_axi_awid;
    assign m_axi_awaddr[slot*32 +: 32] = s_axi_awaddr;
    assign m_axi_awlen[slot*8 +: 8] = s_axi_awlen;
    assign m_axi_awsize[slot*3 +: 3] = s_axi_awsize;
    assign m_axi_awburst[slot*2 +: 2] = s_axi_awburst;
    assign m_axi_awlock[slot*1 +: 1] = s_axi_awlock;
    assign m_axi_awcache[slot*4 +: 4] = s_axi_awcache;
    assign m_axi_awprot[slot*3 +: 3] = s_axi_awprot;
    assign m_axi_awqos[slot*4 +: 4] = s_axi_awqos;
    assign m_axi_awregion[slot*4 +: 4] = s_axi_awregion;
    assign m_axi_arid[slot*1 +: 1] = s_axi_arid;
    assign m_axi_araddr[slot*32 +: 32] = s_axi_araddr;
    assign m_axi_arlen[slot*8 +: 8] = s_axi_arlen;
    assign m_axi_arsize[slot*3 +: 3] = s_axi_arsize;
    assign m_axi_arburst[slot*2 +: 2] = s_axi_arburst;
    assign m_axi_arlock[slot*1 +: 1] = s_axi_arlock;
    assign m_axi_arcache[slot*4 +: 4] = s_axi_arcache;
    assign m_axi_arprot[slot*3 +: 3] = s_axi_arprot;
    assign m_axi_arqos[slot*4 +: 4] = s_axi_arqos;
    assign m_axi_arregion[slot*4 +: 4] = s_axi_arregion;
    assign m_axi_wdata[slot*32 +: 32] = s_axi_wdata;
    assign m_axi_wstrb[slot*4 +: 4] = s_axi_wstrb;
    assign m_axi_wlast[slot*1 +: 1] = s_axi_wlast;
    assign m_axi_arvalid[slot] = !rst && read_available && s_axi_arvalid && ar_owner == slot;
    assign m_axi_awvalid[slot] = !rst && !write_active && s_axi_awvalid && aw_owner == slot;
    assign m_axi_wvalid[slot] = !rst && write_active && s_axi_wvalid && write_owner == slot;
    assign m_axi_rready[slot] = !rst && read_active && s_axi_rready && read_owner == slot;
    assign m_axi_bready[slot] = !rst && write_active && s_axi_bready && write_owner == slot;
  end endgenerate
  always @(posedge clk) begin
    if (rst) begin
      read_active <= 0; write_active <= 0; read_owner <= 2; write_owner <= 2;
      read_id <= 0; write_id <= 0; read_len <= 0; read_beat <= 0;
      write_len <= 0; write_beat <= 0; write_done <= 0;
    end else begin
      if (s_axi_rvalid && s_axi_rready) begin
        read_beat <= read_beat + 1'b1;
        if (s_axi_rlast) read_active <= 0;
      end
      if (s_axi_arvalid && s_axi_arready) begin
        read_active <= 1; read_owner <= ar_owner; read_id <= s_axi_arid;
        read_len <= s_axi_arlen; read_beat <= 0;
      end
      if (s_axi_awvalid && s_axi_awready) begin
        write_active <= 1; write_owner <= aw_owner; write_id <= s_axi_awid;
        write_len <= s_axi_awlen; write_beat <= 0; write_done <= 0;
      end
      if (s_axi_wvalid && s_axi_wready) begin
        write_beat <= write_beat + 1'b1;
        if (write_beat == write_len) write_done <= 1;
      end
      if (s_axi_bvalid && s_axi_bready) write_active <= 0;
    end
  end
  // synthesis translate_off
  always @(posedge clk) if (!rst && s_axi_wvalid && s_axi_wready &&
                           s_axi_wlast != (write_beat == write_len))
    $fatal(1, "AXI4 fabric write LAST/count mismatch");
  // synthesis translate_on
endmodule

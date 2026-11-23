`timescale 1ns / 1ns

// One transaction outstanding. A read request handshakes once; a write request
// handshakes for each data beat. AW is issued once, and writes complete after B.
module axi4_master_serial_adapter (
    input         clk,
    input         rst,
    input         req_valid,
    output        req_ready,
    input  [31:0] req_addr,
    input         req_write,
    input  [ 7:0] req_len,
    input  [31:0] req_wdata,
    input  [ 3:0] req_wstrb,
    input         req_wlast,
    output        rsp_valid,
    input         rsp_ready,
    output [31:0] rsp_rdata,
    output        rsp_error,
    output        rsp_rlast,
    output        m_axi_awid,
    output [31:0] m_axi_awaddr,
    output [ 7:0] m_axi_awlen,
    output [ 2:0] m_axi_awsize,
    output [ 1:0] m_axi_awburst,
    output        m_axi_awlock,
    output [ 3:0] m_axi_awcache,
    output [ 2:0] m_axi_awprot,
    output [ 3:0] m_axi_awqos,
    output [ 3:0] m_axi_awregion,
    output        m_axi_awvalid,
    input         m_axi_awready,
    output        m_axi_arid,
    output [31:0] m_axi_araddr,
    output [ 7:0] m_axi_arlen,
    output [ 2:0] m_axi_arsize,
    output [ 1:0] m_axi_arburst,
    output        m_axi_arlock,
    output [ 3:0] m_axi_arcache,
    output [ 2:0] m_axi_arprot,
    output [ 3:0] m_axi_arqos,
    output [ 3:0] m_axi_arregion,
    output        m_axi_arvalid,
    input         m_axi_arready,
    output [31:0] m_axi_wdata,
    output [ 3:0] m_axi_wstrb,
    output        m_axi_wlast,
    output        m_axi_wvalid,
    input         m_axi_wready,
    input         m_axi_bid,
    input  [ 1:0] m_axi_bresp,
    input         m_axi_bvalid,
    output        m_axi_bready,
    input         m_axi_rid,
    input  [31:0] m_axi_rdata,
    input  [ 1:0] m_axi_rresp,
    input         m_axi_rlast,
    input         m_axi_rvalid,
    output        m_axi_rready
);
  // Test-only facade keeps the existing serial regression stimuli unchanged.
  // Concurrent behavior is tested directly through the new split interface.
  reg pending, direction;
  reg [8:0] received;
  reg [7:0] saved_len;
  wire rd_req_ready, wr_req_ready, rd_rsp_valid, wr_rsp_valid;
  wire [31:0] rd_rsp_rdata;
  wire rd_rsp_error, rd_rsp_last, wr_rsp_error;
  wire completing = rsp_valid && rsp_ready && rsp_rlast;
  wire available = !pending || completing;
  wire can_offer = available || (pending && direction && received <= {1'b0, saved_len});
  assign req_ready = can_offer && (req_write ? wr_req_ready : rd_req_ready);
  assign rsp_valid = pending && (direction ? wr_rsp_valid : rd_rsp_valid);
  assign rsp_error = direction ? wr_rsp_error : rd_rsp_error;
  assign rsp_rlast = direction || rd_rsp_last;
  assign rsp_rdata = direction ? 32'b0 : rd_rsp_rdata;
  always @(posedge clk) begin
    if (rst) begin pending <= 0; direction <= 0; received <= 0; saved_len <= 0; end
    else begin
      if (completing) pending <= 0;
      if (req_valid && req_ready) begin
        if (available) begin
          pending <= 1; direction <= req_write; saved_len <= req_len; received <= 1;
        end else received <= received + 1'b1;
      end
    end
  end
  axi4_master endpoint (
    .clk(clk), .rst(rst),
    .rd_req_valid(req_valid && !req_write && can_offer), .rd_req_ready(rd_req_ready),
    .rd_req_addr(req_addr), .rd_req_len(req_len),
    .rd_rsp_valid(rd_rsp_valid), .rd_rsp_ready(rsp_ready && pending && !direction),
    .rd_rsp_rdata(rd_rsp_rdata), .rd_rsp_error(rd_rsp_error), .rd_rsp_last(rd_rsp_last),
    .wr_req_valid(req_valid && req_write && can_offer), .wr_req_ready(wr_req_ready),
    .wr_req_addr(req_addr), .wr_req_len(req_len), .wr_req_wdata(req_wdata),
    .wr_req_wstrb(req_wstrb), .wr_req_wlast(req_wlast),
    .wr_rsp_valid(wr_rsp_valid), .wr_rsp_ready(rsp_ready && pending && direction), .wr_rsp_error(wr_rsp_error),
    .m_axi_awid(m_axi_awid),
    .m_axi_awaddr(m_axi_awaddr),
    .m_axi_awlen(m_axi_awlen),
    .m_axi_awsize(m_axi_awsize),
    .m_axi_awburst(m_axi_awburst),
    .m_axi_awlock(m_axi_awlock),
    .m_axi_awcache(m_axi_awcache),
    .m_axi_awprot(m_axi_awprot),
    .m_axi_awqos(m_axi_awqos),
    .m_axi_awregion(m_axi_awregion),
    .m_axi_awvalid(m_axi_awvalid),
    .m_axi_awready(m_axi_awready),
    .m_axi_arid(m_axi_arid),
    .m_axi_araddr(m_axi_araddr),
    .m_axi_arlen(m_axi_arlen),
    .m_axi_arsize(m_axi_arsize),
    .m_axi_arburst(m_axi_arburst),
    .m_axi_arlock(m_axi_arlock),
    .m_axi_arcache(m_axi_arcache),
    .m_axi_arprot(m_axi_arprot),
    .m_axi_arqos(m_axi_arqos),
    .m_axi_arregion(m_axi_arregion),
    .m_axi_arvalid(m_axi_arvalid),
    .m_axi_arready(m_axi_arready),
    .m_axi_wdata(m_axi_wdata),
    .m_axi_wstrb(m_axi_wstrb),
    .m_axi_wlast(m_axi_wlast),
    .m_axi_wvalid(m_axi_wvalid),
    .m_axi_wready(m_axi_wready),
    .m_axi_bid(m_axi_bid),
    .m_axi_bresp(m_axi_bresp),
    .m_axi_bvalid(m_axi_bvalid),
    .m_axi_bready(m_axi_bready),
    .m_axi_rid(m_axi_rid),
    .m_axi_rdata(m_axi_rdata),
    .m_axi_rresp(m_axi_rresp),
    .m_axi_rlast(m_axi_rlast),
    .m_axi_rvalid(m_axi_rvalid),
    .m_axi_rready(m_axi_rready)
  );
endmodule

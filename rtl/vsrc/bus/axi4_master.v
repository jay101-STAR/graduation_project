`timescale 1ns / 1ns

// One read and one write may be outstanding independently. A read accepts one
// command; a write accepts LEN+1 data beats and completes only after AXI B.
module axi4_master (
    input         clk,
    input         rst,
    input         rd_req_valid,
    output        rd_req_ready,
    input  [31:0] rd_req_addr,
    input  [ 7:0] rd_req_len,
    output        rd_rsp_valid,
    input         rd_rsp_ready,
    output [31:0] rd_rsp_rdata,
    output        rd_rsp_error,
    output        rd_rsp_last,
    input         wr_req_valid,
    output        wr_req_ready,
    input  [31:0] wr_req_addr,
    input  [ 7:0] wr_req_len,
    input  [31:0] wr_req_wdata,
    input  [ 3:0] wr_req_wstrb,
    input         wr_req_wlast,
    output        wr_rsp_valid,
    input         wr_rsp_ready,
    output        wr_rsp_error,
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
  function bad_request;
    input [31:0] addr;
    input [7:0] len;
    begin
      bad_request = addr[1:0] != 0 || (len != 0 && len != 15) ||
          ({1'b0, addr[11:0]} + (({5'b0, len}+13'd1)<<2) > 13'd4096);
    end
  endfunction

  reg rd_active, ar_done, rd_local_error;
  reg [31:0] rd_addr;
  reg [7:0] rd_len, rd_beat;
  wire rd_completing = rd_rsp_valid && rd_rsp_ready && rd_rsp_last;
  wire rd_available = !rd_active || rd_completing;
  wire rd_start = rd_req_valid && rd_req_ready;
  wire rd_bad = bad_request(rd_req_addr, rd_req_len);
  assign rd_req_ready = !rst && rd_available;
  assign rd_rsp_valid = !rst && rd_active && (rd_local_error || (ar_done && m_axi_rvalid));
  assign rd_rsp_rdata = rd_local_error ? 32'b0 : m_axi_rdata;
  assign rd_rsp_error = rd_local_error || m_axi_rresp != 0;
  assign rd_rsp_last = rd_local_error || m_axi_rlast;
  assign m_axi_rready = !rst && rd_active && !rd_local_error && ar_done && rd_rsp_ready;
  assign m_axi_araddr = rd_available ? rd_req_addr : rd_addr;
  assign m_axi_arlen = rd_available ? rd_req_len : rd_len;
  assign m_axi_arvalid = !rst && ((rd_active && !rd_local_error && !ar_done) ||
                                 (rd_start && !rd_bad));

  reg wr_active, aw_done, w_done, wr_local_error;
  reg w_buffer_valid, write_input_done, write_error;
  reg [31:0] wr_addr, saved_wdata;
  reg [3:0] saved_wstrb;
  reg saved_wlast;
  reg [7:0] wr_len;
  reg [8:0] write_received;
  wire wr_completing = wr_rsp_valid && wr_rsp_ready;
  wire wr_available = !wr_active || wr_completing;
  // An empty transaction slot accepts the first word independent of WREADY.
  wire wr_start = !rst && wr_available && wr_req_valid;
  wire write_stream = wr_active && !write_input_done;
  wire write_space = !w_buffer_valid || m_axi_wready;
  wire wr_bad = bad_request(wr_req_addr, wr_req_len);
  wire write_offer = wr_req_valid && wr_req_ready;
  wire write_bad = wr_available ? wr_bad : wr_local_error;
  wire write_last = wr_available ? wr_req_len == 0 : write_received == {1'b0, wr_len};
  wire w_fire = m_axi_wvalid && m_axi_wready;
  assign wr_req_ready = !rst && (wr_available ||
                                (write_stream && (wr_local_error || write_space)));
  // Rejected writes still drain their declared number of native data beats.
  assign wr_rsp_valid = !rst && wr_active && (wr_local_error ? write_input_done :
                                            (aw_done && w_done && m_axi_bvalid));
  assign wr_rsp_error = wr_local_error || write_error || m_axi_bresp != 0;
  assign m_axi_bready = !rst && wr_active && !wr_local_error && aw_done && w_done && wr_rsp_ready;
  assign m_axi_awaddr = wr_available ? wr_req_addr : wr_addr;
  assign m_axi_awlen = wr_available ? wr_req_len : wr_len;
  assign m_axi_wlast = w_buffer_valid ? saved_wlast : write_last;
  assign m_axi_wdata = w_buffer_valid ? saved_wdata : wr_req_wdata;
  assign m_axi_wstrb = w_buffer_valid ? saved_wstrb : wr_req_wstrb;
  assign m_axi_awvalid = !rst && ((wr_active && !wr_local_error && !aw_done) ||
                                 (wr_start && !wr_bad));
  assign m_axi_wvalid = !rst &&
      (((wr_active && !wr_local_error && !w_done) || (wr_start && !wr_bad)) &&
       (w_buffer_valid || write_offer));
  assign m_axi_awid = 1'b0;
  assign m_axi_awsize = 3'd2;
  assign m_axi_awburst = 2'b01;
  assign m_axi_awlock = 1'b0;
  assign m_axi_awcache = 4'b0;
  assign m_axi_awprot = 3'b0;
  assign m_axi_awqos = 4'b0;
  assign m_axi_awregion = 4'b0;
  assign m_axi_arid = 1'b0;
  assign m_axi_arsize = 3'd2;
  assign m_axi_arburst = 2'b01;
  assign m_axi_arlock = 1'b0;
  assign m_axi_arcache = 4'b0;
  assign m_axi_arprot = 3'b0;
  assign m_axi_arqos = 4'b0;
  assign m_axi_arregion = 4'b0;
  always @(posedge clk) begin
    if (rst) begin
      rd_active <= 0; ar_done <= 0; rd_local_error <= 0;
      rd_addr <= 0; rd_len <= 0; rd_beat <= 0;
    end else begin
      if (rd_completing) rd_active <= 0;
      if (m_axi_rvalid && m_axi_rready) rd_beat <= rd_beat + 1'b1;
      if (m_axi_arvalid && m_axi_arready) ar_done <= 1;
      if (rd_start) begin
        rd_active <= 1;
        rd_addr <= rd_req_addr;
        rd_len <= rd_req_len;
        rd_local_error <= rd_bad;
        rd_beat <= 0;
        ar_done <= !rd_bad && m_axi_arready;
      end
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      wr_active <= 0; aw_done <= 0; w_done <= 0; wr_local_error <= 0;
      wr_addr <= 0; wr_len <= 0;
      saved_wdata <= 0; saved_wstrb <= 0; saved_wlast <= 0;
      w_buffer_valid <= 0; write_input_done <= 0; write_error <= 0; write_received <= 0;
    end else begin
      if (wr_completing) wr_active <= 0;
      if (m_axi_awvalid && m_axi_awready) aw_done <= 1;
      if (w_fire && m_axi_wlast) w_done <= 1;
      if (wr_start) begin
        wr_active <= 1;
        wr_addr <= wr_req_addr;
        wr_len <= wr_req_len;
        wr_local_error <= wr_bad;
        aw_done <= !wr_bad && m_axi_awready;
        w_done <= !wr_bad && w_fire && write_last;
        write_received <= 9'd1;
        write_input_done <= write_last;
        write_error <= wr_req_wlast != write_last;
      end else if (write_offer) begin
        write_received <= write_received + 9'd1;
        if (write_last) write_input_done <= 1'b1;
        if (wr_req_wlast != write_last || wr_req_addr != wr_addr || wr_req_len != wr_len)
          write_error <= 1'b1;
      end
      // Keep data, mask and LAST together throughout backpressure. Replace a
      // consumed buffered word with the next accepted native word on one edge.
      if (wr_start || w_fire) w_buffer_valid <= 1'b0;
      if (write_offer && !write_bad && (w_buffer_valid || !w_fire)) begin
        saved_wdata <= wr_req_wdata;
        saved_wstrb <= wr_req_wstrb;
        saved_wlast <= write_last;
        w_buffer_valid <= 1'b1;
      end
    end
  end
  // synthesis translate_off
  always @(posedge clk) if (!rst) begin
    if (m_axi_rvalid && m_axi_rready &&
        (m_axi_rid != 0 || m_axi_rlast != (rd_beat == rd_len)))
      $fatal(1, "AXI4 read ID/LAST/count mismatch");
    if (m_axi_bvalid && m_axi_bready && m_axi_bid != 0)
      $fatal(1, "AXI4 write ID mismatch");
  end
  // synthesis translate_on
endmodule

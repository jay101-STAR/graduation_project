`timescale 1ns / 1ns

// Direct AXI4 UART slave. Valid register operations are aligned 32-bit INCR
// single beats. Unsupported bursts drain their full declared length and
// return SLVERR without a TX enqueue or RX FIFO pop. AW and W are independent.
module axi4_uart_slave #(
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,
    parameter integer RX_FIFO_DEPTH = 4
) (
    input clk, input rst, input uart_rxd, output uart_txd,
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
    input s_axi_rready
);
  localparam [31:0] UART_BASE_ADDR = 32'h1000_0000;
  localparam [31:0] UART_STATUS_ADDR = 32'h1000_0004;
  localparam [31:0] UART_RXDATA_ADDR = 32'h1000_0008;

  reg uart_aw_seen, uart_bvalid;
  reg [31:0] uart_awaddr_latch, uart_wdata_latch;
  reg [3:0] uart_wstrb_latch;
  reg [7:0] uart_awlen_latch;
  reg uart_awid_latch, uart_aw_error, uart_wlast_error, first_wlast;
  reg [8:0] uart_w_count;
  reg [1:0] uart_bresp;
  reg uart_rvalid, read_error, uart_arid_latch;
  reg [7:0] uart_arlen_latch, uart_r_beat;
  reg [31:0] uart_rdata;
  reg uart_rx_pop_pending, uart_rx_overrun_reg;
  reg uart_tx_valid;
  reg [7:0] uart_tx_data;

  wire uart_aw_hs = s_axi_awvalid && s_axi_awready;
  wire uart_w_hs = s_axi_wvalid && s_axi_wready;
  wire uart_b_hs = s_axi_bvalid && s_axi_bready;
  wire uart_ar_hs = s_axi_arvalid && s_axi_arready;
  wire uart_r_hs = s_axi_rvalid && s_axi_rready;
  wire read_bad = s_axi_araddr[31:4] != 28'h1000000 || s_axi_araddr[1:0] != 0 ||
                  s_axi_arlen != 0 || s_axi_arsize != 2 || s_axi_arburst != 1 || s_axi_arlock;
  wire write_bad = s_axi_awaddr[31:4] != 28'h1000000 || s_axi_awaddr[1:0] != 0 ||
                   s_axi_awlen != 0 || s_axi_awsize != 2 || s_axi_awburst != 1 || s_axi_awlock;
  wire write_error = uart_aw_error || uart_wlast_error;
  wire write_is_tx = uart_awaddr_latch == UART_BASE_ADDR && (|uart_wstrb_latch);
  wire write_received = uart_aw_seen && uart_w_count == ({1'b0, uart_awlen_latch} + 9'd1);
  wire uart_tx_ready;
  wire write_commit = !rst && !uart_bvalid && write_received &&
                      (write_error || !write_is_tx || uart_tx_ready);
  wire [7:0] write_tx_byte = uart_wstrb_latch[0] ? uart_wdata_latch[7:0] :
                             uart_wstrb_latch[1] ? uart_wdata_latch[15:8] :
                             uart_wstrb_latch[2] ? uart_wdata_latch[23:16] :
                                                  uart_wdata_latch[31:24];

  // One early W beat may be saved before AW. After AW, accept precisely LEN+1
  // beats, including the rejected-burst case. A held B blocks the next write.
  assign s_axi_awready = !rst && !uart_aw_seen && !uart_bvalid;
  assign s_axi_wready = !rst && !uart_bvalid &&
                       (uart_aw_seen ? uart_w_count < ({1'b0, uart_awlen_latch}+9'd1) : uart_w_count == 0);
  assign s_axi_bvalid = !rst && uart_bvalid;
  assign s_axi_bresp = uart_bresp;
  assign s_axi_bid = uart_awid_latch;
  assign s_axi_arready = !rst && !uart_rvalid;
  assign s_axi_rvalid = !rst && uart_rvalid;
  assign s_axi_rdata = uart_rdata;
  assign s_axi_rresp = read_error ? 2'b10 : 2'b00;
  assign s_axi_rid = uart_arid_latch;
  assign s_axi_rlast = uart_r_beat == uart_arlen_latch;

  wire [7:0] uart_rx_fifo_rdata;
  wire uart_rx_fifo_empty, uart_rx_fifo_full;
  wire [7:0] uart_rx_byte;
  wire uart_rx_byte_valid, uart_rx_frame_error;
  wire uart_rx_pop = uart_r_hs && s_axi_rlast && !read_error && uart_rx_pop_pending;
  wire uart_rx_push_accept = uart_rx_byte_valid && (!uart_rx_fifo_full || uart_rx_pop);
  wire uart_rx_push_drop = uart_rx_byte_valid && !uart_rx_push_accept;

  uart_tx #(
      .CLK_FREQ_HZ(UART_CLK_HZ),
      .BAUD_RATE  (UART_BAUD)
  ) uart_tx0 (
      .clk     (clk),
      .rst     (rst),
      .tx_valid(uart_tx_valid),
      .tx_data (uart_tx_data),
      .tx_ready(uart_tx_ready),
      .uart_txd(uart_txd)
  );

  uart_rx #(
      .CLK_FREQ_HZ(UART_CLK_HZ),
      .BAUD_RATE  (UART_BAUD)
  ) uart_rx0 (
      .clk           (clk),
      .rst           (rst),
      .uart_rxd      (uart_rxd),
      .rx_data       (uart_rx_byte),
      .rx_valid      (uart_rx_byte_valid),
      .rx_frame_error(uart_rx_frame_error)
  );

  uart_rx_fifo #(
      .DATA_WIDTH(8),
      .DEPTH     (RX_FIFO_DEPTH)
  ) uart_rx_fifo0 (
      .clk      (clk),
      .rst      (rst),
      .push     (uart_rx_push_accept),
      .push_data(uart_rx_byte),
      .pop      (uart_rx_pop),
      .pop_data (uart_rx_fifo_rdata),
      .full     (uart_rx_fifo_full),
      .empty    (uart_rx_fifo_empty)
  );

  always @(posedge clk) begin
    if (rst) begin
      uart_aw_seen <= 0; uart_awaddr_latch <= 0; uart_awlen_latch <= 0;
      uart_awid_latch <= 0; uart_aw_error <= 0; uart_wlast_error <= 0;
      uart_w_count <= 0; uart_wdata_latch <= 0; uart_wstrb_latch <= 0; first_wlast <= 0;
      uart_bvalid <= 0; uart_bresp <= 0;
      uart_rvalid <= 0; uart_arid_latch <= 0; uart_arlen_latch <= 0;
      uart_r_beat <= 0; uart_rdata <= 0; read_error <= 0;
      uart_rx_pop_pending <= 0; uart_rx_overrun_reg <= 0;
      uart_tx_valid <= 0; uart_tx_data <= 0;
    end else begin
      uart_tx_valid <= 0;
      if (uart_aw_hs) begin
        uart_aw_seen <= 1;
        uart_awaddr_latch <= s_axi_awaddr;
        uart_awlen_latch <= s_axi_awlen;
        uart_awid_latch <= s_axi_awid;
        uart_aw_error <= write_bad;
        if (uart_w_count != 0) uart_wlast_error <= first_wlast != (s_axi_awlen == 0);
      end
      if (uart_w_hs) begin
        uart_w_count <= uart_w_count + 9'd1;
        if (uart_w_count == 0) begin
          uart_wdata_latch <= s_axi_wdata;
          uart_wstrb_latch <= s_axi_wstrb;
          first_wlast <= s_axi_wlast;
        end
        if (uart_aw_seen || uart_aw_hs) begin
          if (s_axi_wlast != (uart_w_count == {1'b0, (uart_aw_seen ? uart_awlen_latch : s_axi_awlen)}))
            uart_wlast_error <= 1;
        end
      end
      if (write_commit) begin
        uart_bvalid <= 1;
        uart_bresp <= write_error ? 2'b10 : 2'b00;
        if (!write_error && write_is_tx) begin
          uart_tx_valid <= 1;
          uart_tx_data <= write_tx_byte;
        end
      end
      if (uart_b_hs) begin
        uart_bvalid <= 0;
        uart_aw_seen <= 0;
        uart_w_count <= 0;
        uart_aw_error <= 0;
        uart_wlast_error <= 0;
      end

      // Snapshot read data on AR; a blocked RXDATA response owns its FIFO head
      // until R handshakes. Invalid reads never reserve or pop an RX entry.
      if (uart_ar_hs) begin
        uart_rvalid <= 1;
        uart_arid_latch <= s_axi_arid;
        uart_arlen_latch <= s_axi_arlen;
        uart_r_beat <= 0;
        read_error <= read_bad;
        uart_rx_pop_pending <= 0;
        uart_rdata <= 0;
        if (!read_bad) begin
          if (s_axi_araddr == UART_STATUS_ADDR)
            uart_rdata <= {29'b0, uart_rx_overrun_reg, !uart_rx_fifo_empty, uart_tx_ready};
          else if (s_axi_araddr == UART_RXDATA_ADDR) begin
            uart_rdata <= uart_rx_fifo_empty ? 32'b0 : {24'b0, uart_rx_fifo_rdata};
            uart_rx_pop_pending <= !uart_rx_fifo_empty;
          end
        end
      end
      if (uart_r_hs) begin
        uart_r_beat <= uart_r_beat + 1'b1;
        if (s_axi_rlast) begin
          uart_rvalid <= 0;
          uart_rx_pop_pending <= 0;
        end
      end
      if (uart_rx_push_drop) uart_rx_overrun_reg <= 1;
      if (uart_rx_pop) uart_rx_overrun_reg <= 0;
    end
  end
endmodule

`timescale 1ns / 1ns

// Minimal AXI4-Lite UART slave model:
// - TXDATA @ UART_BASE_ADDR       (write): enqueue one UART TX byte
// - STATUS @ UART_STATUS_ADDR     (read) : bit0=tx_ready, bit1=rx_valid(!empty), bit2=rx_overrun
// - RXDATA @ UART_RXDATA_ADDR     (read) : low8=rx_data, read handshake pops one FIFO entry
module axi_lite_uart_slave #(
    parameter integer UART_CLK_HZ = 50000000,
    parameter integer UART_BAUD = 115200,
    parameter integer RX_FIFO_DEPTH = 4
) (
    input clk,
    input rst,
    input       uart_rxd,
    output      uart_txd,

    // AXI-Lite write address channel
    input  [31:0] s_axi_awaddr,
    input  [ 2:0] s_axi_awprot,
    input         s_axi_awvalid,
    output        s_axi_awready,

    // AXI-Lite write data channel
    input  [31:0] s_axi_wdata,
    input  [ 3:0] s_axi_wstrb,
    input         s_axi_wvalid,
    output        s_axi_wready,

    // AXI-Lite write response channel
    output [ 1:0] s_axi_bresp,
    output        s_axi_bvalid,
    input         s_axi_bready,

    // AXI-Lite read address channel
    input  [31:0] s_axi_araddr,
    input  [ 2:0] s_axi_arprot,
    input         s_axi_arvalid,
    output        s_axi_arready,

    // AXI-Lite read data channel
    output [31:0] s_axi_rdata,
    output [ 1:0] s_axi_rresp,
    output        s_axi_rvalid,
    input         s_axi_rready
);

  localparam [31:0] UART_BASE_ADDR = 32'h1000_0000;
  localparam [31:0] UART_STATUS_ADDR = 32'h1000_0004;
  localparam [31:0] UART_RXDATA_ADDR = 32'h1000_0008;

  reg [31:0] uart_awaddr_latch;
  reg [31:0] uart_wdata_latch;
  reg [ 3:0] uart_wstrb_latch;
  reg [31:0] uart_araddr_latch;
  reg        uart_aw_seen;
  reg        uart_w_seen;
  reg        uart_bvalid;
  reg        uart_rvalid;
  reg [31:0] uart_rdata;
  reg        uart_rx_pop_pending;
  reg        uart_rx_overrun_reg;
  reg        uart_tx_valid;
  reg [ 7:0] uart_tx_data;

  wire uart_aw_hs = s_axi_awvalid && s_axi_awready;
  wire uart_w_hs = s_axi_wvalid && s_axi_wready;
  wire uart_b_hs = uart_bvalid && s_axi_bready;
  wire uart_ar_hs = s_axi_arvalid && s_axi_arready;
  wire uart_r_hs = uart_rvalid && s_axi_rready;
  wire [7:0] uart_rx_fifo_rdata;
  wire uart_rx_fifo_empty;
  wire uart_rx_fifo_full;
  wire [7:0] uart_rx_byte;
  wire uart_rx_byte_valid;
  wire uart_rx_frame_error;
  wire uart_rx_pop = uart_r_hs && uart_rx_pop_pending;
  // Allow push and pop in the same cycle, including full->full replacement.
  wire uart_rx_push_accept = uart_rx_byte_valid && (!uart_rx_fifo_full || uart_rx_pop);
  wire uart_rx_push_drop = uart_rx_byte_valid && !uart_rx_push_accept;

  // Unused in this minimal model, reserved for future protection checks.
  wire [2:0] uart_awprot_unused = s_axi_awprot;
  wire [2:0] uart_arprot_unused = s_axi_arprot;
  wire [31:0] uart_write_addr = uart_aw_hs ? s_axi_awaddr : uart_awaddr_latch;
  wire uart_write_is_tx = (uart_write_addr == UART_BASE_ADDR);
  wire [7:0] uart_tx_byte_now = s_axi_wstrb[0] ? s_axi_wdata[7:0] :
                                s_axi_wstrb[1] ? s_axi_wdata[15:8] :
                                s_axi_wstrb[2] ? s_axi_wdata[23:16] :
                                                 s_axi_wdata[31:24];
  wire [7:0] uart_tx_byte_latched = uart_wstrb_latch[0] ? uart_wdata_latch[7:0] :
                                    uart_wstrb_latch[1] ? uart_wdata_latch[15:8] :
                                    uart_wstrb_latch[2] ? uart_wdata_latch[23:16] :
                                                          uart_wdata_latch[31:24];
  wire [7:0] uart_write_tx_byte = uart_w_hs ? uart_tx_byte_now : uart_tx_byte_latched;
  wire uart_tx_ready;
  wire uart_write_can_commit = !uart_write_is_tx || uart_tx_ready;

  assign s_axi_awready = 1'b1;
  assign s_axi_wready = 1'b1;
  assign s_axi_arready = 1'b1;
  assign s_axi_bresp = 2'b00;  // OKAY
  assign s_axi_bvalid = uart_bvalid;
  assign s_axi_rresp = 2'b00;  // OKAY
  assign s_axi_rvalid = uart_rvalid;
  assign s_axi_rdata = uart_rdata;

  uart_tx #(
      .CLK_FREQ_HZ(UART_CLK_HZ),
      .BAUD_RATE(UART_BAUD)
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
      .BAUD_RATE(UART_BAUD)
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
      .DEPTH(RX_FIFO_DEPTH)
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
      uart_awaddr_latch <= 32'b0;
      uart_wdata_latch <= 32'b0;
      uart_wstrb_latch <= 4'b0;
      uart_araddr_latch <= 32'b0;
      uart_aw_seen <= 1'b0;
      uart_w_seen <= 1'b0;
      uart_bvalid <= 1'b0;
      uart_rvalid <= 1'b0;
      uart_rdata <= 32'b0;
      uart_rx_pop_pending <= 1'b0;
      uart_rx_overrun_reg <= 1'b0;
      uart_tx_valid <= 1'b0;
      uart_tx_data <= 8'b0;
    end else begin
      uart_tx_valid <= 1'b0;

      if (uart_aw_hs) begin
        uart_awaddr_latch <= s_axi_awaddr;
        uart_aw_seen <= 1'b1;
      end

      if (uart_w_hs) begin
        uart_wdata_latch <= s_axi_wdata;
        uart_wstrb_latch <= s_axi_wstrb;
        uart_w_seen <= 1'b1;
      end

      if (!uart_bvalid && (uart_aw_seen || uart_aw_hs) && (uart_w_seen || uart_w_hs) &&
          uart_write_can_commit) begin
        uart_bvalid <= 1'b1;
        uart_aw_seen <= 1'b0;
        uart_w_seen <= 1'b0;
        if (uart_write_is_tx) begin
          uart_tx_valid <= 1'b1;
          uart_tx_data <= uart_write_tx_byte;
        end
      end else if (uart_b_hs) begin
        uart_bvalid <= 1'b0;
      end

      if (!uart_rvalid && uart_ar_hs) begin
        uart_araddr_latch <= s_axi_araddr;
        uart_rvalid <= 1'b1;
        if (s_axi_araddr == UART_STATUS_ADDR) begin
          uart_rdata <= {29'b0, uart_rx_overrun_reg, !uart_rx_fifo_empty, uart_tx_ready};  // bit2=rx_overrun, bit1=rx_valid, bit0=tx_ready
          uart_rx_pop_pending <= 1'b0;
        end else if (s_axi_araddr == UART_RXDATA_ADDR) begin
          uart_rdata <= uart_rx_fifo_empty ? 32'h0 : {24'b0, uart_rx_fifo_rdata};
          uart_rx_pop_pending <= !uart_rx_fifo_empty;
        end else begin
          uart_rdata <= 32'h0;
          uart_rx_pop_pending <= 1'b0;
        end
      end else if (uart_r_hs) begin
        uart_rvalid <= 1'b0;
        uart_rx_pop_pending <= 1'b0;
      end

      // RX FIFO push path
      if (uart_rx_push_drop) begin
        uart_rx_overrun_reg <= 1'b1;
      end

      // RX FIFO pop path (on completed RXDATA read response)
      if (uart_rx_pop) begin
        uart_rx_overrun_reg <= 1'b0;
      end
    end
  end

endmodule

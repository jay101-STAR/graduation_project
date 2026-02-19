`timescale 1ns / 1ns

// Bridge mode:
// Keep CPU local memory interface unchanged, translate one request at a time
// into AXI4-Lite master transactions.
module mem_to_axi_lite_bridge (
    input clk,
    input rst,

    // ---------------- CPU-side local request interface ----------------
    input  [31:0] cpu_axi_addr,
    input  [31:0] cpu_axi_wdata,
    input  [ 3:0] cpu_axi_wstrb,
    input         cpu_axi_wen,
    input         cpu_axi_ren,
    output reg [31:0] axi_cpu_rdata,
    output            axi_cpu_stall,
    output reg        axi_cpu_error,

    // ---------------- AXI4-Lite master interface ----------------
    // Write address channel
    output reg [31:0] m_axi_awaddr,
    output reg [ 2:0] m_axi_awprot,
    output reg        m_axi_awvalid,
    input             m_axi_awready,

    // Write data channel
    output reg [31:0] m_axi_wdata,
    output reg [ 3:0] m_axi_wstrb,
    output reg        m_axi_wvalid,
    input             m_axi_wready,

    // Write response channel
    input      [ 1:0] m_axi_bresp,
    input             m_axi_bvalid,
    output reg        m_axi_bready,

    // Read address channel
    output reg [31:0] m_axi_araddr,
    output reg [ 2:0] m_axi_arprot,
    output reg        m_axi_arvalid,
    input             m_axi_arready,

    // Read data channel
    input      [31:0] m_axi_rdata,
    input      [ 1:0] m_axi_rresp,
    input             m_axi_rvalid,
    output reg        m_axi_rready
);

  localparam [2:0] ST_IDLE = 3'd0;
  localparam [2:0] ST_W_ADDR_DATA = 3'd1;
  localparam [2:0] ST_W_RESP = 3'd2;
  localparam [2:0] ST_R_ADDR = 3'd3;
  localparam [2:0] ST_R_DATA = 3'd4;
  localparam [1:0] AXI_RESP_OKAY = 2'b00;

  reg [2:0] bridge_state;
  reg write_aw_done;
  reg write_w_done;
  reg wait_req_release;

  wire aw_handshake = m_axi_awvalid && m_axi_awready;
  wire w_handshake = m_axi_wvalid && m_axi_wready;
  wire b_handshake = m_axi_bvalid && m_axi_bready;
  wire ar_handshake = m_axi_arvalid && m_axi_arready;
  wire r_handshake = m_axi_rvalid && m_axi_rready;
  wire req_present = cpu_axi_wen || cpu_axi_ren;
  wire req_fire = (bridge_state == ST_IDLE) && !wait_req_release && req_present;

  // During an MMIO request, stall the pipeline until AXI response returns.
  // Also stall on request fire cycle so EX/MEM request won't run ahead by one cycle.
  assign axi_cpu_stall = (bridge_state != ST_IDLE) || req_fire;

  always @(posedge clk) begin
    if (rst) begin
      bridge_state <= ST_IDLE;
      write_aw_done <= 1'b0;
      write_w_done <= 1'b0;
      wait_req_release <= 1'b0;

      axi_cpu_rdata <= 32'h0;
      axi_cpu_error <= 1'b0;

      m_axi_awaddr <= 32'h0;
      m_axi_awprot <= 3'b000;
      m_axi_awvalid <= 1'b0;

      m_axi_wdata <= 32'h0;
      m_axi_wstrb <= 4'h0;
      m_axi_wvalid <= 1'b0;

      m_axi_bready <= 1'b0;

      m_axi_araddr <= 32'h0;
      m_axi_arprot <= 3'b000;
      m_axi_arvalid <= 1'b0;

      m_axi_rready <= 1'b0;
    end else begin
      case (bridge_state)
        ST_IDLE: begin
          write_aw_done <= 1'b0;
          write_w_done <= 1'b0;

          // Wait until request level drops before accepting next transaction.
          if (wait_req_release) begin
            if (!req_present) begin
              wait_req_release <= 1'b0;
            end
          end else begin
            // Write has priority if both are asserted unexpectedly.
            if (cpu_axi_wen) begin
              axi_cpu_error <= 1'b0;
              m_axi_awaddr <= cpu_axi_addr;
              m_axi_awprot <= 3'b000;
              m_axi_awvalid <= 1'b1;

              m_axi_wdata <= cpu_axi_wdata;
              m_axi_wstrb <= cpu_axi_wstrb;
              m_axi_wvalid <= 1'b1;

              bridge_state <= ST_W_ADDR_DATA;
              wait_req_release <= 1'b1;
            end else if (cpu_axi_ren) begin
              axi_cpu_error <= 1'b0;
              m_axi_araddr <= cpu_axi_addr;
              m_axi_arprot <= 3'b000;
              m_axi_arvalid <= 1'b1;

              bridge_state <= ST_R_ADDR;
              wait_req_release <= 1'b1;
            end
          end
        end

        ST_W_ADDR_DATA: begin
          if (aw_handshake) begin
            m_axi_awvalid <= 1'b0;
            write_aw_done <= 1'b1;
          end

          if (w_handshake) begin
            m_axi_wvalid <= 1'b0;
            write_w_done <= 1'b1;
          end

          if ((write_aw_done || aw_handshake) && (write_w_done || w_handshake)) begin
            m_axi_bready <= 1'b1;
            bridge_state <= ST_W_RESP;
          end
        end

        ST_W_RESP: begin
          if (b_handshake) begin
            m_axi_bready <= 1'b0;
            axi_cpu_error <= (m_axi_bresp != AXI_RESP_OKAY);
            bridge_state <= ST_IDLE;
          end
        end

        ST_R_ADDR: begin
          if (ar_handshake) begin
            m_axi_arvalid <= 1'b0;
            m_axi_rready <= 1'b1;
            bridge_state <= ST_R_DATA;
          end
        end

        ST_R_DATA: begin
          if (r_handshake) begin
            axi_cpu_rdata <= m_axi_rdata;
            axi_cpu_error <= (m_axi_rresp != AXI_RESP_OKAY);
            m_axi_rready <= 1'b0;
            bridge_state <= ST_IDLE;
          end
        end

        default: begin
          bridge_state <= ST_IDLE;
        end
      endcase
    end
  end

endmodule

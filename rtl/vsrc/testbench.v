`timescale 1ns / 1ns

module testbench ();

  reg         clk;
  reg         rst;
  wire [31:0] tohost_value_register;
  wire [31:0] tohost_value_dataram;
  wire [31:0] bp_branch_total;
  wire [31:0] bp_mispredict_total;
  wire [31:0] bp_target_miss_total;
  reg         tb_uart_rxd_stim;
  wire        tb_uart_txd;
  wire        tb_uart_rxd;
  reg         uart_rx_smoke_en;
  reg         uart_rx_overrun_smoke_en;
  reg         uart_tx_smoke_en;
  reg         uart_tx_print_en;
  reg         uart_loopback_smoke_en = 1'b0;
  reg         debug_m_ext_en;
  reg         bp_pattern_test_en;

  localparam integer TB_UART_CLK_HZ = 50000000;
  localparam integer TB_UART_BAUD = 115200;
  localparam integer TB_UART_BAUD_DIV = TB_UART_CLK_HZ / TB_UART_BAUD;

  assign tb_uart_rxd = uart_loopback_smoke_en ? tb_uart_txd : tb_uart_rxd_stim;

  task automatic uart_wait_one_bit;
    begin
      repeat (TB_UART_BAUD_DIV) @(negedge clk);
    end
  endtask

  task automatic inject_uart_rx_byte(input [7:0] data);
    integer i;
    begin
      // Serial inject on RXD line: start(0), data[7:0] LSB-first, stop(1).
      @(negedge clk);
      tb_uart_rxd_stim = 1'b1;
      uart_wait_one_bit();

      tb_uart_rxd_stim = 1'b0;  // start bit
      uart_wait_one_bit();

      for (i = 0; i < 8; i = i + 1) begin
        tb_uart_rxd_stim = data[i];
        uart_wait_one_bit();
      end

      tb_uart_rxd_stim = 1'b1;  // stop bit
      uart_wait_one_bit();
    end
  endtask


  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = ~clk;
    end
  end

  initial begin
    rst              = 1'b1;  // 保持高有效复位，初始为复位状态
    tb_uart_rxd_stim = 1'b1;
    #200 rst = 1'b0;  // 释放复位
  end

  localparam longint unsigned TIMEOUT_NS_DEFAULT = 64'd4000000;
  localparam longint unsigned TIMEOUT_NS_UART_SMOKE = 64'd4000000;
  localparam [31:0] UART_TXDATA_ADDR = 32'h1000_0000;
  localparam [31:0] UART_STATUS_ADDR = 32'h1000_0004;
  localparam [31:0] UART_RXDATA_ADDR = 32'h1000_0008;
  longint unsigned timeout_ns_cfg;
  longint unsigned timeout_ns_plusarg;

  // Optional RX smoke stimulus:
  // +uart_rx_smoke         : serial inject one byte 0x41
  // +uart_rx_overrun_smoke : serial inject a burst (0x41..0x45) before first byte is consumed
  // +uart_tx_print         : print UART TX stream to sim.log
  initial begin
    uart_rx_smoke_en         = $test$plusargs("uart_rx_smoke");
    uart_rx_overrun_smoke_en = $test$plusargs("uart_rx_overrun_smoke");
    uart_tx_smoke_en         = $test$plusargs("uart_tx_smoke");
    uart_tx_print_en         = $test$plusargs("uart_tx_print");
    uart_loopback_smoke_en   = $test$plusargs("uart_loopback_smoke");
    debug_m_ext_en           = $test$plusargs("debug_m_ext");
    bp_pattern_test_en       = $test$plusargs("bp_pattern_test");
    if (uart_rx_smoke_en || uart_rx_overrun_smoke_en) begin
      wait (!rst);
      repeat (30) @(posedge clk);
      inject_uart_rx_byte(8'h41);  // 'A'
      $display("[UART-RX] inject byte=0x%02h", 8'h41);

      if (uart_rx_overrun_smoke_en) begin
        inject_uart_rx_byte(8'h42);  // 'B'
        $display("[UART-RX] inject byte=0x%02h (overrun)", 8'h42);

        inject_uart_rx_byte(8'h43);  // 'C'
        $display("[UART-RX] inject byte=0x%02h (overrun)", 8'h43);

        inject_uart_rx_byte(8'h44);  // 'D'
        $display("[UART-RX] inject byte=0x%02h (overrun)", 8'h44);

        inject_uart_rx_byte(8'h45);  // 'E'
        $display("[UART-RX] inject byte=0x%02h (overrun)", 8'h45);
      end
    end
  end

  top top (
      .clk                  (clk),
      .rst                  (rst),                    // 保持rst
      .tohost_value_register(tohost_value_register),
      .tohost_value_dataram (tohost_value_dataram),
      .bp_branch_total      (bp_branch_total),
      .bp_mispredict_total  (bp_mispredict_total),
      .bp_target_miss_total (bp_target_miss_total),
      .ext_top_uart_rxd     (tb_uart_rxd),
      .ext_top_uart_txd     (tb_uart_txd)
  );

  // initial begin
  //   $fsdbDumpfile("/home/jay/Desktop/graduation_project/rtl/testbench.fsdb");
  //   $fsdbDumpvars("+all");
  // end

  // Debug: Monitor PC and instructions (only first 20 cycles)
  integer cycle_count = 0;
  reg [31:0] last_pc;
  integer same_pc_count = 0;
  real bp_accuracy;
  real perf_cpi;
  reg [63:0] perf_mcycle;
  reg [63:0] perf_minstret;
  wire in_tohost_loop = (top.u_core.pc_if_pc >= 32'h8000_003c) &&
                        (top.u_core.pc_if_pc <= 32'h8000_004c);
  wire [31:0] observed_tohost_value = (tohost_value_dataram != 32'b0) ?
                                      tohost_value_dataram :
                                      (bp_pattern_test_en ?
                                       tohost_value_register :
                                      (((tohost_value_register != 32'b0) && in_tohost_loop) ?
                                       tohost_value_register : 32'b0));

  initial begin
    timeout_ns_cfg = ($test$plusargs("uart_rx_smoke") || $test$plusargs("uart_rx_overrun_smoke") ||
                      $test$plusargs("uart_tx_smoke") || $test$plusargs("uart_loopback_smoke")) ?
        TIMEOUT_NS_UART_SMOKE : TIMEOUT_NS_DEFAULT;
    // 可选覆盖：+timeout_ns=<N>
    if ($value$plusargs("timeout_ns=%d", timeout_ns_plusarg) && (timeout_ns_plusarg > 0)) begin
      timeout_ns_cfg = timeout_ns_plusarg;
    end
    $display("[TB] timeout_ns=%0d", timeout_ns_cfg);
    // 超时保护：避免仿真卡住
    #timeout_ns_cfg;
    if (observed_tohost_value == 0) begin
      $display("\033[1;33m*** TIMEOUT: no tohost write ***\033[0m");
      $finish;
    end else begin
      $display("\033[1;33m*** TIMEOUT: no tohost write ***\033[0m");
      $finish;
    end
  end

  // Periodic time-based PC print (avoid reliance on counters)
  // initial begin
  //   #1000;
  //   forever begin
  //     #1000;  // 每1000ns打印一次，更频繁
  //     $display("[DBG-T] t=%0t rst=%b pc=0x%08h", $time, rst, top.u_core.pc_if_pc);
  //   end
  // end

  // Monitor tohost for test results (RISC-V test convention)
  // tohost is at address 0x80001000

  // always @(posedge clk) begin
  //   if (!rst && tohost_value != 0) begin
  //     if (tohost_value == 1) begin
  //       $display("\033[1;32m*** TEST PASSED ***\033[0m");
  //     end else begin
  //       $display("\033[1;31m*** TEST FAILED *** (tohost = %d)\033[0m", tohost_value >> 1);
  //     end
  //     #100 $finish;
  //   end
  // end
  always @(posedge clk) begin
    if (!rst && uart_tx_print_en &&
        top.bridge_axi_awvalid && top.axi_bridge_awready &&
        top.bridge_axi_wvalid && top.axi_bridge_wready &&
        (top.bridge_axi_awaddr == UART_TXDATA_ADDR)) begin
      if (top.bridge_axi_wstrb[0]) begin
        $write("%c", top.bridge_axi_wdata[7:0]);
      end else if (top.bridge_axi_wstrb[1]) begin
        $write("%c", top.bridge_axi_wdata[15:8]);
      end else if (top.bridge_axi_wstrb[2]) begin
        $write("%c", top.bridge_axi_wdata[23:16]);
      end else if (top.bridge_axi_wstrb[3]) begin
        $write("%c", top.bridge_axi_wdata[31:24]);
      end
    end

    if (!rst && (uart_rx_smoke_en || uart_rx_overrun_smoke_en)) begin
      if (top.bridge_axi_arvalid && top.axi_bridge_arready &&
          ((top.bridge_axi_araddr == UART_STATUS_ADDR) ||
           (top.bridge_axi_araddr == UART_RXDATA_ADDR))) begin
        $display("[UART-RX] AR addr=0x%08h @t=%0t", top.bridge_axi_araddr, $time);
      end
      if (top.axi_bridge_rvalid && top.bridge_axi_rready) begin
        $display("[UART-RX] R data=0x%08h @t=%0t", top.axi_bridge_rdata, $time);
      end
    end

    if (rst) begin
      cycle_count   <= 0;
      last_pc       <= 32'b0;
      same_pc_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;

      if (top.u_core.pc_if_pc == last_pc) same_pc_count <= same_pc_count + 1;
      else same_pc_count <= 0;

      last_pc <= top.u_core.pc_if_pc;

      if (same_pc_count == 50000000) begin  // Increased for CoreMark
        $display("\033[1;33m*** STUCK PC: 0x%08h ***\033[0m", top.u_core.pc_if_pc);
        $finish;
      end
    end

    if (!rst && debug_m_ext_en) begin
      if ((top.u_core.pc_if_pc >= 32'h8000_0358) && (top.u_core.pc_if_pc <= 32'h8000_0370)) begin
        $display("[M-DBG] t=%0t IF pc=0x%08h", $time, top.u_core.pc_if_pc);
      end

      if (top.u_core.ex_is_mul_instruction || top.u_core.ex_is_div_instruction) begin
        $display(
            "[M-DBG] t=%0t EX pc=0x%08h alucex=0x%0h rs1=0x%08h rs2=0x%08h mul_busy=%b mul_done=%b div_busy=%b div_done=%b ex_rd=0x%08h rd=%0d wen=%b",
            $time, top.u_core.id_ex_pc, top.u_core.ex_alucex, top.u_core.ex_forwarded_rs1_data,
            top.u_core.ex_forwarded_rs2_data, top.u_core.ex_mul_busy, top.u_core.ex_mul_done,
            top.u_core.ex_div_busy, top.u_core.ex_div_done, top.u_core.ex_reg_rd_data,
            top.u_core.ex_reg_rd_addr, top.u_core.ex_reg_rd_wen);
      end

      if (top.u_core.ex_pc_pc_wen) begin
        $display(
            "[M-DBG] t=%0t REDIRECT ex_pc=0x%08h ex_alucex=0x%0h rs1=0x%08h rs2=0x%08h -> new_pc=0x%08h",
            $time, top.u_core.id_ex_pc, top.u_core.ex_alucex, top.u_core.ex_forwarded_rs1_data,
            top.u_core.ex_forwarded_rs2_data, top.u_core.ex_pc_pc_data);
      end

      if (top.u_core.wb_reg_rd_wen) begin
        $display("[M-DBG] t=%0t WB rd=%0d data=0x%08h", $time, top.u_core.wb_reg_rd_addr,
                 top.u_core.wb_reg_rd_data);
      end
    end

    // Prefer architectural tohost write when address decoder hits.
    // For some tests, tohost symbol address is not fixed; fallback to gp in write_tohost loop.
    if (!rst && observed_tohost_value != 0) begin
      perf_mcycle   = top.u_core.csr0.cycle_int;
      perf_minstret = top.u_core.csr0.instret_int;
      if (perf_minstret != 0) begin
        perf_cpi = perf_mcycle * 1.0 / perf_minstret;
      end else begin
        perf_cpi = 0.0;
      end

      if (bp_branch_total != 0) begin
        bp_accuracy = (1.0 - (bp_mispredict_total * 1.0 / bp_branch_total)) * 100.0;
        $display("[BP] branches=%0d mispredict=%0d target_miss=%0d accuracy=%0.2f%%",
                 bp_branch_total, bp_mispredict_total, bp_target_miss_total, bp_accuracy);
      end else begin
        $display("[BP] branches=0 mispredict=%0d target_miss=%0d accuracy=N/A",
                 bp_mispredict_total, bp_target_miss_total);
      end

      if (observed_tohost_value === 32'd1) begin
        $display("\033[1;32m*** TEST PASSED ***\033[0m");
      end else if (observed_tohost_value !== 32'bx) begin
        $display("\033[1;31m*** TEST FAILED *** (tohost = %d)\033[0m", observed_tohost_value);
      end else begin
        $display("\033[1;33m*** TOHOST UNKNOWN (X) ***\033[0m");
      end
      if (perf_minstret != 0) begin
        $display("[PERF] mcycle=%0d minstret=%0d cpi=%0.4f", perf_mcycle, perf_minstret, perf_cpi);
      end else begin
        $display("[PERF] mcycle=%0d minstret=%0d cpi=N/A", perf_mcycle, perf_minstret);
      end
      #100 $finish;
    end
  end


endmodule

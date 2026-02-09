`timescale 1ns / 1ns

module testbench ();

  reg clk;
  reg rst;
  reg [31:0] tohost_value_register;
  reg [31:0] tohost_value_dataram;
  reg test_complete;


  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = ~clk;
    end
  end

  initial begin
    rst           = 1'b1;  // 保持高有效复位，初始为复位状态
    test_complete = 1'b0;
    #200 rst = 1'b0;  // 释放复位
  end

  localparam integer TIMEOUT_NS = 200000000;  // 200ms for CoreMark

  initial begin
    // 超时保护：避免仿真卡住
    #TIMEOUT_NS;
    if (tohost_value_dataram == 0) begin
      $display("\033[1;33m*** TIMEOUT: no tohost write ***\033[0m");
      $finish;
    end
  end

  top top (
      .clk                  (clk),
      .rst                  (rst),                    // 保持rst
      .tohost_value_register(tohost_value_register),
      .tohost_value_dataram (tohost_value_dataram)
  );

  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/rtl/testbench.fsdb");
    $fsdbDumpvars("+all");
  end

  // Debug: Monitor PC and instructions (only first 20 cycles)
  integer cycle_count = 0;
  reg [31:0] last_pc;
  integer same_pc_count = 0;

  // Periodic time-based PC print (avoid reliance on counters)
  initial begin
    #1000;
    forever begin
      #1000;  // 每1000ns打印一次，更频繁
      $display("[DBG-T] t=%0t rst=%b pc=0x%08h", $time, rst, top.openmips0.pc_if_pc);
    end
  end

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
    if (rst) begin
      cycle_count   <= 0;
      last_pc       <= 32'b0;
      same_pc_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;

      if (top.openmips0.pc_if_pc == last_pc) same_pc_count <= same_pc_count + 1;
      else same_pc_count <= 0;

      last_pc <= top.openmips0.pc_if_pc;

      if (cycle_count % 1000000 == 0) begin
        $display("[DBG] cycle=%0d pc=0x%08h", cycle_count, top.openmips0.pc_if_pc);
      end

      if (same_pc_count == 50000000) begin  // Increased for CoreMark
        $display("\033[1;33m*** STUCK PC: 0x%08h ***\033[0m", top.openmips0.pc_if_pc);
        $finish;
      end
    end

    if (!rst && tohost_value_dataram != 0) begin
      if (tohost_value_dataram === 32'd1) begin
        $display("\033[1;32m*** TEST PASSED ***\033[0m");
      end else if (^tohost_value_dataram !== 1'bx) begin
        $display("\033[1;31m*** TEST FAILED *** (tohost = %d)\033[0m", tohost_value_dataram >> 1);
      end else begin
        $display("\033[1;33m*** TOHOST UNKNOWN (X) ***\033[0m");
      end
      #100 $finish;
    end
  end


endmodule

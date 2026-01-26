`timescale 1ns / 1ps
`define timeslice 100

module i2c_eeprom_tb;

  // Clock and reset
  reg         clk;
  reg         rst_n;

  // EEPROM controller interface
  reg  [10:0] mem_addr;
  reg  [ 7:0] wr_data;
  reg  [ 7:0] num_bytes;
  reg         cmd_valid;
  reg         cmd_rw;
  wire [ 7:0] rd_data;
  wire        busy;
  wire        done;

  // I2C bus
  wire        sda;
  wire        scl;

  // Pull-up resistors
  pullup (sda);
  pullup (scl);

  // Instantiate EEPROM controller
  i2c_eeprom_ctrl_simple ctrl (
      .clk       (clk),
      .rst_n     (rst_n),
      .mem_addr  (mem_addr),
      .wr_data   (wr_data),
      .num_bytes (num_bytes),
      .cmd_valid (cmd_valid),
      .cmd_rw    (cmd_rw),
      .rd_data   (rd_data),
      .busy      (busy),
      .done      (done),
      .sda       (sda),
      .scl       (scl)
  );

  // Instantiate EEPROM
  eeprom eeprom_inst (
      .scl(scl),
      .sda(sda)
  );

  // Clock generation (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize signals
    rst_n     = 0;
    mem_addr  = 11'd0;
    wr_data   = 8'd0;
    num_bytes = 8'd1;
    cmd_valid = 0;
    cmd_rw    = 0;

    // Reset
    #100;
    rst_n = 1;
    #100;

    $display("=== I2C EEPROM Test Started ===");
    $display("Time: %0t", $time);

    // Test 1: Single byte write
    $display("\n--- Test 1: Write 0xAA to address 0x000 ---");
    @(posedge clk);
    mem_addr  = 11'h000;
    wr_data   = 8'hAA;
    num_bytes = 8'd1;
    cmd_rw    = 0;  // Write
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Write completed at time %0t", $time);
    #1000;

    // Test 2: Single byte read
    $display("\n--- Test 2: Read from address 0x000 ---");
    @(posedge clk);
    mem_addr  = 11'h000;
    num_bytes = 8'd1;
    cmd_rw    = 1;  // Read
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Read completed at time %0t, data = 0x%02h", $time, rd_data);
    if (rd_data == 8'hAA) $display("SUCCESS: Read data matches written data");
    else $display("ERROR: Read data mismatch! Expected 0xAA, got 0x%02h", rd_data);
    #1000;

    // Test 3: Multiple byte write (5 bytes: 0x10, 0x11, 0x12, 0x13, 0x14)
    $display("\n--- Test 3: Write 5 bytes to addresses 0x100-0x104 ---");
    $display("Writing: 0x10, 0x11, 0x12, 0x13, 0x14");
    @(posedge clk);
    mem_addr  = 11'h100;
    wr_data   = 8'h10;
    num_bytes = 8'd5;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Multi-byte write completed at time %0t", $time);
    #1000;

    // Test 4: Multiple byte read (5 bytes from 0x100-0x104)
    $display("\n--- Test 4: Read 5 bytes from addresses 0x100-0x104 ---");
    @(posedge clk);
    mem_addr  = 11'h100;
    num_bytes = 8'd5;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Multi-byte read completed at time %0t", $time);
    $display("Last byte read = 0x%02h", rd_data);
    if (rd_data == 8'h14) $display("SUCCESS: Last byte matches expected value");
    else $display("ERROR: Expected last byte 0x14, got 0x%02h", rd_data);
    #1000;

    // Test 5: Verify single byte read from 0x100
    $display("\n--- Test 5: Verify first byte from 0x100 ---");
    @(posedge clk);
    mem_addr  = 11'h100;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Read from 0x100 = 0x%02h", rd_data);
    if (rd_data == 8'h10) $display("SUCCESS: First byte matches");
    else $display("ERROR: Expected 0x10, got 0x%02h", rd_data);
    #1000;

    $display("\n=== All Tests Completed ===");
    $display("Time: %0t", $time);
    #10000;
    $finish;
  end

  // Waveform dump
  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/i2c/i2c_eeprom_test.fsdb");
    $fsdbDumpvars("+all");
  end

  // Monitor
  initial begin
    $monitor(
        "Time=%0t | CMD_VALID=%b | CMD_RW=%b | NUM_BYTES=%0d | BUSY=%b | DONE=%b | ADDR=0x%03h | WR_DATA=0x%02h | RD_DATA=0x%02h | SDA=%b | SCL=%b",
        $time, cmd_valid, cmd_rw, num_bytes, busy, done, mem_addr, wr_data, rd_data, sda, scl);
  end

endmodule

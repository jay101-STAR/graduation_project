`timescale 1ns / 1ps

module i2c_tb;

  // Clock and reset
  reg         clk;
  reg         rst_n;

  // I2C master interface
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

  // Pull-up resistors for I2C bus
  pullup (sda);
  pullup (scl);

  // Instantiate I2C master
  i2c_master master (
      .clk      (clk),
      .rst_n    (rst_n),
      .mem_addr (mem_addr),
      .wr_data  (wr_data),
      .num_bytes(num_bytes),
      .cmd_valid(cmd_valid),
      .cmd_rw   (cmd_rw),
      .rd_data  (rd_data),
      .busy     (busy),
      .done     (done),
      .sda      (sda),
      .scl      (scl)
  );

  // Instantiate EEPROM slave
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

    $display("========================================");
    $display("=== I2C Master-Slave Test Started ===");
    $display("========================================");
    $display("Time: %0t ns", $time);
    $display("");

    // Test 1: Single byte write
    $display("--- Test 1: Single Byte Write ---");
    $display("Writing 0xAA to address 0x000");
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
    $display("Write completed at time %0t ns", $time);
    $display("");
    #2000;

    // Test 2: Single byte read
    $display("--- Test 2: Single Byte Read ---");
    $display("Reading from address 0x000");
    @(posedge clk);
    mem_addr  = 11'h000;
    num_bytes = 8'd1;
    cmd_rw    = 1;  // Read
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Read completed at time %0t ns", $time);
    $display("Read data = 0x%02h", rd_data);
    if (rd_data == 8'hAA) $display("✓ SUCCESS: Read data matches written data");
    else $display("✗ ERROR: Read data mismatch! Expected 0xAA, got 0x%02h", rd_data);
    $display("");
    #2000;

    // Test 3: Write multiple bytes to different addresses
    $display("--- Test 3: Multi-Byte Write ---");
    $display("Writing 5 bytes starting from address 0x100");
    $display("Data: 0x10, 0x11, 0x12, 0x13, 0x14");

    // Write first byte
    @(posedge clk);
    mem_addr  = 11'h100;
    wr_data   = 8'h10;
    num_bytes = 8'd1;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    #2000;

    // Write second byte
    @(posedge clk);
    mem_addr  = 11'h101;
    wr_data   = 8'h11;
    num_bytes = 8'd1;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    #2000;

    // Write third byte
    @(posedge clk);
    mem_addr  = 11'h102;
    wr_data   = 8'h12;
    num_bytes = 8'd1;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    #2000;

    // Write fourth byte
    @(posedge clk);
    mem_addr  = 11'h103;
    wr_data   = 8'h13;
    num_bytes = 8'd1;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    #2000;

    // Write fifth byte
    @(posedge clk);
    mem_addr  = 11'h104;
    wr_data   = 8'h14;
    num_bytes = 8'd1;
    cmd_rw    = 0;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Multi-byte write completed at time %0t ns", $time);
    $display("");
    #2000;

    // Test 4: Read multiple bytes from different addresses
    $display("--- Test 4: Multi-Byte Read ---");
    $display("Reading 5 bytes starting from address 0x100");

    // Read first byte
    @(posedge clk);
    mem_addr  = 11'h100;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Read from 0x100 = 0x%02h (expected 0x10)", rd_data);
    if (rd_data == 8'h10) $display("✓ Byte 1 correct");
    else $display("✗ Byte 1 incorrect");
    #2000;

    // Read second byte
    @(posedge clk);
    mem_addr  = 11'h101;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Read from 0x101 = 0x%02h (expected 0x11)", rd_data);
    if (rd_data == 8'h11) $display("✓ Byte 2 correct");
    else $display("✗ Byte 2 incorrect");
    #2000;

    // Read third byte
    @(posedge clk);
    mem_addr  = 11'h102;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Read from 0x102 = 0x%02h (expected 0x12)", rd_data);
    if (rd_data == 8'h12) $display("✓ Byte 3 correct");
    else $display("✗ Byte 3 incorrect");
    #2000;

    // Read fourth byte
    @(posedge clk);
    mem_addr  = 11'h103;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Read from 0x103 = 0x%02h (expected 0x13)", rd_data);
    if (rd_data == 8'h13) $display("✓ Byte 4 correct");
    else $display("✗ Byte 4 incorrect");
    #2000;

    // Read fifth byte
    @(posedge clk);
    mem_addr  = 11'h104;
    num_bytes = 8'd1;
    cmd_rw    = 1;
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;
    wait (done);
    @(posedge clk);
    $display("Read from 0x104 = 0x%02h (expected 0x14)", rd_data);
    if (rd_data == 8'h14) $display("✓ Byte 5 correct");
    else $display("✗ Byte 5 incorrect");
    $display("");
    #2000;

    // // Test 5: Write to different address regions
    // $display("--- Test 5: Different Address Regions ---");
    // $display("Writing to address 0x7FF (highest address)");
    // @(posedge clk);
    // mem_addr  = 11'h7FF;
    // wr_data   = 8'hFF;
    // num_bytes = 8'd1;
    // cmd_rw    = 0;
    // cmd_valid = 1;
    // @(posedge clk);
    // cmd_valid = 0;
    // wait (done);
    // #2000;
    //
    // $display("Reading from address 0x7FF");
    // @(posedge clk);
    // mem_addr  = 11'h7FF;
    // num_bytes = 8'd1;
    // cmd_rw    = 1;
    // cmd_valid = 1;
    // @(posedge clk);
    // cmd_valid = 0;
    // wait (done);
    // @(posedge clk);
    // $display("Read data = 0x%02h (expected 0xFF)", rd_data);
    // if (rd_data == 8'hFF) $display("✓ SUCCESS: High address test passed");
    // else $display("✗ ERROR: High address test failed");
    // $display("");
    // #2000;
    //
    // // Test 6: Overwrite test
    // $display("--- Test 6: Overwrite Test ---");
    // $display("Overwriting address 0x000 with 0x55");
    // @(posedge clk);
    // mem_addr  = 11'h000;
    // wr_data   = 8'h55;
    // num_bytes = 8'd1;
    // cmd_rw    = 0;
    // cmd_valid = 1;
    // @(posedge clk);
    // cmd_valid = 0;
    // wait (done);
    // #2000;
    //
    // $display("Reading from address 0x000");
    // @(posedge clk);
    // mem_addr  = 11'h000;
    // num_bytes = 8'd1;
    // cmd_rw    = 1;
    // cmd_valid = 1;
    // @(posedge clk);
    // cmd_valid = 0;
    // wait (done);
    // @(posedge clk);
    // $display("Read data = 0x%02h (expected 0x55)", rd_data);
    // if (rd_data == 8'h55) $display("✓ SUCCESS: Overwrite test passed");
    // else $display("✗ ERROR: Overwrite test failed");
    // $display("");
    // #2000;

    $display("========================================");
    $display("=== All Tests Completed ===");
    $display("========================================");
    $display("Final time: %0t ns", $time);
    #5000;
    $finish;
  end

  // Waveform dump
  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/i2c_final_backup/i2c_test.fsdb");
    $fsdbDumpvars("+all");
  end

  // Timeout watchdog
  initial begin
    #10_000_000;  // 10ms timeout
    $display("ERROR: Simulation timeout!");
    $finish;
  end

endmodule

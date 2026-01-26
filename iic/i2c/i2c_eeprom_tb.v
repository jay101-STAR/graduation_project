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

  // Memory buffer for multi-byte operations
  reg  [ 7:0] data_buffer [0:255];
  wire [ 7:0] buf_addr;
  wire [ 7:0] buf_wr_data;
  wire [ 7:0] buf_rd_data;
  wire        buf_wr_en;

  // Buffer read logic
  assign buf_rd_data = data_buffer[buf_addr];

  // Buffer write logic
  always @(posedge clk) begin
    if (buf_wr_en) begin
      data_buffer[buf_addr] <= buf_wr_data;
    end
  end

  // Pull-up resistors
  pullup (sda);
  pullup (scl);

  // Instantiate EEPROM controller
  i2c_eeprom_ctrl_simple ctrl (
      .clk        (clk),
      .rst_n      (rst_n),
      .mem_addr   (mem_addr),
      .wr_data    (wr_data),
      .num_bytes  (num_bytes),
      .cmd_valid  (cmd_valid),
      .cmd_rw     (cmd_rw),
      .rd_data    (rd_data),
      .busy       (busy),
      .done       (done),
      .sda        (sda),
      .scl        (scl),
      .buf_addr   (buf_addr),
      .buf_wr_data(buf_wr_data),
      .buf_rd_data(buf_rd_data),
      .buf_wr_en  (buf_wr_en)
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
  integer i;
  initial begin
    // Initialize signals
    rst_n     = 0;
    mem_addr  = 11'd0;
    wr_data   = 8'd0;
    num_bytes = 8'd1;
    cmd_valid = 0;
    cmd_rw    = 0;

    // Initialize buffer
    for (i = 0; i < 256; i = i + 1) begin
      data_buffer[i] = 8'd0;
    end

    // Reset
    #100;
    rst_n = 1;
    #100;

    $display("=== I2C EEPROM Multi-Byte Test Started ===");
    $display("Time: %0t", $time);

    // Test 1: Single byte write
    $display("\n--- Test 1: Write 0xAA to address 0x000 ---");
    data_buffer[0] = 8'hAA;
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

    // Test 3: Multi-byte write (4 bytes)
    $display("\n--- Test 3: Write 4 bytes (0x11, 0x22, 0x33, 0x44) to address 0x010 ---");
    data_buffer[0] = 8'h11;
    data_buffer[1] = 8'h22;
    data_buffer[2] = 8'h33;
    data_buffer[3] = 8'h44;
    @(posedge clk);
    mem_addr  = 11'h010;
    num_bytes = 8'd4;
    cmd_rw    = 0;  // Write
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Multi-byte write completed at time %0t", $time);
    #1000;

    // Test 4: Multi-byte read (4 bytes)
    $display("\n--- Test 4: Read 4 bytes from address 0x010 ---");
    // Clear buffer first
    for (i = 0; i < 4; i = i + 1) begin
      data_buffer[i] = 8'd0;
    end
    @(posedge clk);
    mem_addr  = 11'h010;
    num_bytes = 8'd4;
    cmd_rw    = 1;  // Read
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("Multi-byte read completed at time %0t", $time);
    $display("Read data: [0]=0x%02h, [1]=0x%02h, [2]=0x%02h, [3]=0x%02h", data_buffer[0],
             data_buffer[1], data_buffer[2], data_buffer[3]);
    if (data_buffer[0] == 8'h11 && data_buffer[1] == 8'h22 &&
        data_buffer[2] == 8'h33 && data_buffer[3] == 8'h44)
      $display("SUCCESS: All bytes match!");
    else $display("ERROR: Data mismatch!");
    #1000;

    // Test 5: Multi-byte write (8 bytes)
    $display("\n--- Test 5: Write 8 bytes (0x01-0x08) to address 0x100 ---");
    for (i = 0; i < 8; i = i + 1) begin
      data_buffer[i] = i + 1;
    end
    @(posedge clk);
    mem_addr  = 11'h100;
    num_bytes = 8'd8;
    cmd_rw    = 0;  // Write
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("8-byte write completed at time %0t", $time);
    #1000;

    // Test 6: Multi-byte read (8 bytes)
    $display("\n--- Test 6: Read 8 bytes from address 0x100 ---");
    // Clear buffer first
    for (i = 0; i < 8; i = i + 1) begin
      data_buffer[i] = 8'd0;
    end
    @(posedge clk);
    mem_addr  = 11'h100;
    num_bytes = 8'd8;
    cmd_rw    = 1;  // Read
    cmd_valid = 1;
    @(posedge clk);
    cmd_valid = 0;

    wait (done);
    @(posedge clk);
    $display("8-byte read completed at time %0t", $time);
    $display("Read data: 0x%02h 0x%02h 0x%02h 0x%02h 0x%02h 0x%02h 0x%02h 0x%02h", data_buffer[0],
             data_buffer[1], data_buffer[2], data_buffer[3], data_buffer[4], data_buffer[5],
             data_buffer[6], data_buffer[7]);
    if (data_buffer[0] == 8'h01 && data_buffer[1] == 8'h02 &&
        data_buffer[2] == 8'h03 && data_buffer[3] == 8'h04 &&
        data_buffer[4] == 8'h05 && data_buffer[5] == 8'h06 &&
        data_buffer[6] == 8'h07 && data_buffer[7] == 8'h08)
      $display("SUCCESS: All 8 bytes match!");
    else $display("ERROR: Data mismatch!");
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
        "Time=%0t | CMD_VALID=%b | CMD_RW=%b | BUSY=%b | DONE=%b | ADDR=0x%03h | WR_DATA=0x%02h | RD_DATA=0x%02h | SDA=%b | SCL=%b",
        $time, cmd_valid, cmd_rw, busy, done, mem_addr, wr_data, rd_data, sda, scl);
  end

endmodule

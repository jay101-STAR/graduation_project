`timescale 1ns / 1ps

module i2c_tb;

  // Clock and reset
  reg clk;
  reg rst_n;

  // I2C master interface
  reg [6:0] slave_addr;
  reg rw;
  reg [7:0] wr_data;
  reg [7:0] num_bytes;
  reg start;
  wire [7:0] rd_data;
  wire busy;
  wire done;
  wire ack_error;

  // I2C bus
  wire sda;
  wire scl;

  // Pull-up resistors simulation
  pullup (sda);
  pullup (scl);

  // Instantiate I2C master
  i2c_master master (
      .clk       (clk),
      .rst_n     (rst_n),
      .slave_addr(slave_addr),
      .rw        (rw),
      .wr_data   (wr_data),
      .num_bytes (num_bytes),
      .start     (start),
      .rd_data   (rd_data),
      .busy      (busy),
      .done      (done),
      .ack_error (ack_error),
      .sda       (sda),
      .scl       (scl)
  );

  // Instantiate I2C slave
  i2c_slave slave (
      .clk       (clk),
      .rst_n     (rst_n),
      .slave_addr(7'h7f),
      .sda       (sda),
      .scl       (scl)
  );

  // Clock generation (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize signals
    rst_n      = 0;
    slave_addr = 7'h7f;
    rw         = 0;
    wr_data    = 8'h00;
    num_bytes  = 1;
    start      = 0;

    // Reset
    #100;
    rst_n = 1;
    #100;

    $display("=== I2C Interface Test Started ===");
    $display("Time: %0t", $time);

    // Test 1: Single byte write
    $display("\n--- Test 1: Single Byte Write ---");
    $display("Writing 0xA5 to slave address 0x50");
    @(posedge clk);
    slave_addr = 7'h7f;
    rw         = 0;  // Write
    wr_data    = 8'hA5;
    num_bytes  = 1;
    start      = 1;
    @(posedge clk);
    start = 0;

    // Wait for transaction to complete
    wait (done);
    @(posedge clk);
    if (ack_error) $display("ERROR: ACK error detected!");
    else $display("SUCCESS: Single byte write completed");
    #10000;

    // Test 2: Multiple byte write
    $display("\n--- Test 2: Multiple Byte Write ---");
    $display("Writing 5 bytes: 0x11, 0x22, 0x33, 0x44, 0x55");
    @(posedge clk);
    slave_addr = 7'h7f;
    rw         = 0;  // Write
    num_bytes  = 5;
    start      = 1;
    @(posedge clk);
    start = 0;

    // Update wr_data at each byte boundary
    wait (master.state == ACK_WRITE && master.byte_cnt == 8'd0);
    wr_data = 8'h11;
    $display("Writing byte 1: 0x11");
    wait (master.state == ACK_WRITE && master.byte_cnt == 8'd1);
    wr_data = 8'h22;
    $display("Writing byte 2: 0x22");
    wait (master.state == ACK_WRITE && master.byte_cnt == 8'd2);
    wr_data = 8'h33;
    $display("Writing byte 3: 0x33");
    wait (master.state == ACK_WRITE && master.byte_cnt == 8'd3);
    wr_data = 8'h44;
    $display("Writing byte 4: 0x44");
    wait (master.state == ACK_WRITE && master.byte_cnt == 8'd4);
    wr_data = 8'h55;
    $display("Writing byte 5: 0x55");

    wait (done);
    @(posedge clk);
    if (ack_error) $display("ERROR: ACK error detected!");
    else $display("SUCCESS: Multiple byte write completed");
    #10000;

    // Test 3: Single byte read
    $display("\n--- Test 3: Single Byte Read ---");
    $display("Reading 1 byte from slave");
    @(posedge clk);
    slave_addr = 7'h7f;
    rw         = 1;  // Read
    num_bytes  = 1;
    start      = 1;
    @(posedge clk);
    start = 0;

    wait (done);
    @(posedge clk);
    if (ack_error) $display("ERROR: ACK error detected!");
    else $display("SUCCESS: Single byte read completed, data = 0x%02h", rd_data);
    #10000;

    // Test 4: Multiple byte read
    $display("\n--- Test 4: Multiple Byte Read ---");
    $display("Reading 5 bytes from slave");
    @(posedge clk);
    slave_addr = 7'h7f;
    rw         = 1;  // Read
    num_bytes  = 5;
    start      = 1;
    @(posedge clk);
    start = 0;

    // Record each byte read
    wait (master.state == READ_DATA && master.bit_cnt == 4'd7 && master.byte_cnt == 8'd0);
    @(posedge clk);
    $display("Read byte 1: 0x%02h", rd_data);

    wait (master.state == READ_DATA && master.bit_cnt == 4'd7 && master.byte_cnt == 8'd1);
    @(posedge clk);
    $display("Read byte 2: 0x%02h", rd_data);

    wait (master.state == READ_DATA && master.bit_cnt == 4'd7 && master.byte_cnt == 8'd2);
    @(posedge clk);
    $display("Read byte 3: 0x%02h", rd_data);

    wait (master.state == READ_DATA && master.bit_cnt == 4'd7 && master.byte_cnt == 8'd3);
    @(posedge clk);
    $display("Read byte 4: 0x%02h", rd_data);

    wait (master.state == READ_DATA && master.bit_cnt == 4'd7 && master.byte_cnt == 8'd4);
    @(posedge clk);
    $display("Read byte 5: 0x%02h", rd_data);

    wait (done);
    @(posedge clk);
    if (ack_error) $display("ERROR: ACK error detected!");
    else $display("SUCCESS: Multiple byte read completed, last data = 0x%02h", rd_data);
    #10000;

    $display("\n=== All Tests Completed ===");
    $display("Time: %0t", $time);
    #5000;
    $finish;
  end

  // Waveform dump for Verdi
  initial begin
    $fsdbDumpfile("/home/jay/Desktop/graduation_project/i2c_interface/i2c_test.fsdb");
    $fsdbDumpvars("+all");
  end

  // Monitor I2C transactions
  initial begin
    $monitor(
        "Time=%0t | START=%b | BUSY=%b | DONE=%b | RW=%b | SDA=%b | SCL=%b | RD_DATA=0x%02h | M_STATE=%0d | M_BYTE=%0d | S_STATE=%0d | S_BIT=%0d | S_SHIFT=0x%02h",
        $time, start, busy, done, rw, sda, scl, rd_data, master.state, master.byte_cnt,
        slave.state, slave.bit_cnt, slave.shift_reg);
  end

endmodule

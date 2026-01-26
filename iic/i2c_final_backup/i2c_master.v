`timescale 1ns / 1ps
`define timeslice 100

// Simple I2C Master Controller for EEPROM
// Supports single-byte and multi-byte read/write operations
module i2c_master (
    input  wire        clk,        // System clock
    input  wire        rst_n,      // Active low reset
    input  wire [10:0] mem_addr,   // EEPROM memory address (11 bits)
    input  wire [ 7:0] wr_data,    // Data to write
    input  wire [ 7:0] num_bytes,  // Number of bytes to read/write
    input  wire        cmd_valid,  // Command valid signal
    input  wire        cmd_rw,     // Command: 0=write, 1=read
    output reg  [ 7:0] rd_data,    // Read data output
    output reg         busy,       // Busy flag
    output reg         done,       // Done flag
    inout  wire        sda,        // I2C data line
    output reg         scl         // I2C clock line
);

  reg        sda_out;
  reg        sda_oe;
  reg [10:0] addr_reg;
  reg [ 7:0] data_reg;
  reg [ 7:0] byte_cnt;
  reg [ 7:0] num_bytes_reg;
  reg        rw_reg;
  reg        transaction_active;

  assign sda = sda_oe ? sda_out : 1'bz;

  // I2C transaction tasks
  task i2c_start;
    begin
      sda_oe  = 1;
      sda_out = 1;
      scl     = 1;
      #`timeslice;
      sda_out = 0;
      #`timeslice;
      scl = 0;
      #`timeslice;
    end
  endtask

  task i2c_stop;
    begin
      sda_oe  = 1;
      sda_out = 0;
      scl     = 0;
      #`timeslice;
      scl = 1;
      #`timeslice;
      sda_out = 1;
      #`timeslice;
    end
  endtask

  task i2c_write_byte;
    input [7:0] data;
    integer i;
    begin
      sda_oe = 1;
      for (i = 7; i >= 0; i = i - 1) begin
        sda_out = data[i];
        #`timeslice;
        scl = 1;
        #`timeslice;
        scl = 0;
        #`timeslice;
      end
      // Wait for ACK
      sda_oe = 0;
      #`timeslice;
      scl = 1;
      #`timeslice;
      scl = 0;
      #`timeslice;
    end
  endtask

  task i2c_read_byte;
    output [7:0] data;
    input send_ack;
    integer i;
    begin
      sda_oe = 0;
      data   = 0;
      for (i = 7; i >= 0; i = i - 1) begin
        #`timeslice;
        scl = 1;
        #`timeslice;
        data[i] = sda;
        scl     = 0;
        #`timeslice;
      end
      // Send ACK or NACK
      sda_oe  = 1;
      sda_out = send_ack ? 0 : 1;
      #`timeslice;
      scl = 1;
      #`timeslice;
      scl = 0;
      #`timeslice;
    end
  endtask

  // Main control process
  initial begin
    scl                = 1;
    sda_out            = 1;
    sda_oe             = 1;
    busy               = 0;
    done               = 0;
    rd_data            = 0;
    addr_reg           = 0;
    data_reg           = 0;
    num_bytes_reg      = 1;
    byte_cnt           = 0;
    rw_reg             = 0;
    transaction_active = 0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scl                <= 1;
      sda_out            <= 1;
      sda_oe             <= 1;
      busy               <= 0;
      done               <= 0;
      rd_data            <= 0;
      addr_reg           <= 0;
      data_reg           <= 0;
      num_bytes_reg      <= 1;
      byte_cnt           <= 0;
      rw_reg             <= 0;
      transaction_active <= 0;
    end else begin
      if (cmd_valid && !busy && !transaction_active) begin
        busy               <= 1;
        done               <= 0;
        addr_reg           <= mem_addr;
        data_reg           <= wr_data;
        num_bytes_reg      <= (num_bytes == 0) ? 8'd1 : num_bytes;
        byte_cnt           <= 0;
        rw_reg             <= cmd_rw;
        transaction_active <= 1;

        // Fork a separate process for I2C transaction
        fork
          begin
            // Execute I2C transaction
            if (cmd_rw == 0) begin
              // Write operation
              for (byte_cnt = 0; byte_cnt < num_bytes_reg; byte_cnt = byte_cnt + 1) begin
                i2c_start;
                i2c_write_byte({4'b1010, addr_reg[10:8], 1'b0});  // Device address + W
                i2c_write_byte((addr_reg[7:0] + byte_cnt));  // Memory address
                i2c_write_byte(data_reg + byte_cnt);  // Data
                i2c_stop;
                #1000;  // Wait between transactions
              end
            end else begin
              // Read operation
              for (byte_cnt = 0; byte_cnt < num_bytes_reg; byte_cnt = byte_cnt + 1) begin
                // Write address
                i2c_start;
                i2c_write_byte({4'b1010, addr_reg[10:8], 1'b0});  // Device address + W
                i2c_write_byte((addr_reg[7:0] + byte_cnt));  // Memory address

                // Repeated start and read
                i2c_start;
                i2c_write_byte({4'b1010, addr_reg[10:8], 1'b1});  // Device address + R
                i2c_read_byte(rd_data, 0);  // Read with NACK
                i2c_stop;
                #1000;  // Wait between transactions
              end
            end

            // Signal completion
            @(posedge clk);
            busy               = 0;
            done               = 1;
            transaction_active = 0;
            @(posedge clk);
            done = 0;
          end
        join_none
      end
    end
  end

endmodule

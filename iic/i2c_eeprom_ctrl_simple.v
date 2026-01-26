`timescale 1ns / 1ps

// Direct I2C EEPROM controller - supports multi-byte read/write
module i2c_eeprom_ctrl_simple (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [10:0] mem_addr,
    input  wire [ 7:0] wr_data,
    input  wire        cmd_valid,
    input  wire        cmd_rw,
    input  wire [ 7:0] num_bytes,  // Number of bytes to read/write
    output reg  [ 7:0] rd_data,
    output reg         busy,
    output reg         done,
    inout  wire        sda,
    output reg         scl
);

  reg [ 9:0] state;
  reg [ 3:0] bit_idx;
  reg [ 7:0] shift_reg;
  reg        sda_out;
  reg        sda_oe;
  reg [10:0] addr_reg;
  reg [ 7:0] data_reg;
  reg [ 7:0] num_bytes_reg;
  reg [ 7:0] byte_cnt;
  reg        rw_reg;
  reg [ 7:0] clk_cnt;
  reg [ 7:0] data_counter;  // For auto-increment in multi-byte write

  assign sda = sda_oe ? sda_out : 1'bz;

  // Clock divider for I2C timing
  wire tick = (clk_cnt == 8'd99);  // Divide by 100

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_cnt <= 0;
    else if (state == 0) clk_cnt <= 0;
    else if (tick) clk_cnt <= 0;
    else clk_cnt <= clk_cnt + 1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state         <= 0;
      scl           <= 1;
      sda_out       <= 1;
      sda_oe        <= 1;
      busy          <= 0;
      done          <= 0;
      bit_idx       <= 0;
      shift_reg     <= 0;
      rd_data       <= 0;
      addr_reg      <= 0;
      data_reg      <= 0;
      num_bytes_reg <= 1;
      byte_cnt      <= 0;
      rw_reg        <= 0;
    end else if (tick || state == 0) begin
      case (state)
        0: begin  // IDLE
          scl     <= 1;
          sda_out <= 1;
          sda_oe  <= 1;
          done    <= 0;
          if (cmd_valid) begin
            busy          <= 1;
            addr_reg      <= mem_addr;
            data_reg      <= wr_data;
            num_bytes_reg <= (num_bytes == 0) ? 8'd1 : num_bytes;  // Default to 1 if not specified
            byte_cnt      <= 0;
            rw_reg        <= cmd_rw;
            data_counter  <= 0;
            state         <= 1;
          end
        end

        1: begin  // START
          sda_out   <= 0;
          shift_reg <= {4'b1010, addr_reg[10:8], 1'b0};
          bit_idx   <= 0;
          state     <= 2;
        end

        // Send device address + W (8 bits)
        2: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= 3;
        end
        3: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? 4 : 2;
        end

        // ACK
        4: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= 5;
        end
        5: begin
          scl   <= 1;
          state <= 6;
        end
        6: begin
          scl       <= 0;
          sda_oe    <= 1;
          shift_reg <= addr_reg[7:0];
          bit_idx   <= 0;
          state     <= 7;
        end

        // Send memory address (8 bits)
        7: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= 8;
        end
        8: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? 9 : 7;
        end

        // ACK
        9: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= 10;
        end
        10: begin
          scl   <= 1;
          state <= 11;
        end
        11: begin
          scl    <= 0;
          sda_oe <= 1;
          state  <= rw_reg ? 50 : 12;
        end  // Branch for read/write

        // WRITE: Send data (8 bits) - Loop for multiple bytes
        12: begin
          shift_reg <= data_reg + byte_cnt;
          bit_idx   <= 0;
          state     <= 13;
        end
        13: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= 14;
        end
        14: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? 15 : 13;
        end

        // ACK after write
        15: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= 16;
        end
        16: begin
          scl   <= 1;
          state <= 17;
        end
        17: begin
          scl          <= 0;
          byte_cnt     <= byte_cnt + 1;
          sda_oe       <= 1;
          // Auto-increment data for next byte
          data_counter <= data_counter + 1;
          if (byte_cnt >= num_bytes_reg - 1) state <= 100;  // All bytes written
          else state <= 12;  // Continue writing next byte
        end

        // READ: Repeated START
        50: begin
          sda_out <= 1;
          scl     <= 1;
          state   <= 51;
        end
        51: begin
          sda_out   <= 0;
          shift_reg <= {4'b1010, addr_reg[10:8], 1'b1};
          bit_idx   <= 0;
          state     <= 52;
        end

        // Send device address + R (8 bits)
        52: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= 53;
        end
        53: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? 54 : 52;
        end

        // ACK
        54: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= 55;
        end
        55: begin
          scl   <= 1;
          state <= 56;
        end
        56: begin
          scl     <= 0;
          bit_idx <= 0;
          state   <= 57;
        end

        // Read data (8 bits) - Loop for multiple bytes
        57: begin
          scl   <= 0;
          state <= 58;
        end
        58: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], sda};
          bit_idx   <= bit_idx + 1;
          if (bit_idx == 7) rd_data <= {shift_reg[6:0], sda};
          state <= (bit_idx == 7) ? 59 : 57;
        end

        // ACK/NACK after read
        59: begin
          scl    <= 0;
          sda_oe <= 1;
          if (byte_cnt >= num_bytes_reg - 1) sda_out <= 1;  // NACK for last byte
          else sda_out <= 0;  // ACK for more bytes
          state <= 60;
        end
        60: begin
          scl   <= 1;
          state <= 61;
        end
        61: begin
          scl      <= 0;
          byte_cnt <= byte_cnt + 1;
          sda_oe   <= 0;
          if (byte_cnt >= num_bytes_reg - 1) state <= 100;  // All bytes read
          else state <= 57;  // Continue reading next byte
        end

        // STOP
        100: begin
          sda_out <= 0;
          scl     <= 1;
          state   <= 101;
        end
        101: begin
          sda_out <= 1;
          done    <= 1;
          busy    <= 0;
          state   <= 0;
        end

        default: state <= 0;
      endcase
    end
  end

endmodule

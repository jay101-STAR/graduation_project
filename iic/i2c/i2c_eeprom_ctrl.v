`timescale 1ns / 1ps

// Direct I2C EEPROM controller - supports multi-byte read/write
module i2c_eeprom_ctrl_simple (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [10:0] mem_addr,
    input  wire [ 7:0] wr_data,
    input  wire        cmd_valid,
    input  wire        cmd_rw,
    input  wire [ 7:0] num_bytes,    // Number of bytes to read/write
    output reg  [ 7:0] rd_data,
    output reg         busy,
    output reg         done,
    inout  wire        sda,
    output reg         scl,
    // Memory buffer interface for multi-byte operations
    output reg  [ 7:0] buf_addr,     // Address for buffer read/write
    output reg  [ 7:0] buf_wr_data,  // Data to write to buffer
    input  wire [ 7:0] buf_rd_data,  // Data read from buffer
    output reg         buf_wr_en     // Write enable for buffer
);

  // State definitions
  localparam IDLE = 10'd0;
  localparam START = 10'd1;
  localparam SEND_DEV_ADDR_W_0 = 10'd2;
  localparam SEND_DEV_ADDR_W_1 = 10'd3;
  localparam ACK_DEV_ADDR_W_0 = 10'd4;
  localparam ACK_DEV_ADDR_W_1 = 10'd5;
  localparam ACK_DEV_ADDR_W_2 = 10'd6;
  localparam SEND_MEM_ADDR_0 = 10'd7;
  localparam SEND_MEM_ADDR_1 = 10'd8;
  localparam ACK_MEM_ADDR_0 = 10'd9;
  localparam ACK_MEM_ADDR_1 = 10'd10;
  localparam ACK_MEM_ADDR_2 = 10'd11;
  localparam WR_LOAD_BYTE = 10'd12;
  localparam WR_SEND_DATA_0 = 10'd13;
  localparam WR_SEND_DATA_1 = 10'd14;
  localparam WR_ACK_0 = 10'd15;
  localparam WR_ACK_1 = 10'd16;
  localparam WR_ACK_2 = 10'd17;
  localparam RD_RESTART_0 = 10'd50;
  localparam RD_RESTART_1 = 10'd51;
  localparam SEND_DEV_ADDR_R_0 = 10'd52;
  localparam SEND_DEV_ADDR_R_1 = 10'd53;
  localparam ACK_DEV_ADDR_R_0 = 10'd54;
  localparam ACK_DEV_ADDR_R_1 = 10'd55;
  localparam ACK_DEV_ADDR_R_2 = 10'd56;
  localparam RD_RECV_DATA_0 = 10'd57;
  localparam RD_RECV_DATA_1 = 10'd58;
  localparam RD_ACK_NACK_0 = 10'd59;
  localparam RD_ACK_NACK_1 = 10'd60;
  localparam RD_ACK_NACK_2 = 10'd61;
  localparam STOP_0 = 10'd100;
  localparam STOP_1 = 10'd101;
  localparam WR_WAIT_BUF = 10'd120;

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

  assign sda = sda_oe ? sda_out : 1'bz;

  // Clock divider for I2C timing
  wire tick = (clk_cnt == 8'd99);  // Divide by 100

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_cnt <= 0;
    else if (state == IDLE) clk_cnt <= 0;
    else if (tick) clk_cnt <= 0;
    else clk_cnt <= clk_cnt + 1;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state         <= IDLE;
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
      buf_addr      <= 0;
      buf_wr_data   <= 0;
      buf_wr_en     <= 0;
    end else if (tick || state == IDLE) begin
      buf_wr_en <= 0;  // Default: disable buffer write
      case (state)
        IDLE: begin  // IDLE
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
            state         <= START;
          end
        end

        START: begin  // START
          sda_out   <= 0;
          shift_reg <= {4'b1010, addr_reg[10:8], 1'b0};
          bit_idx   <= 0;
          state     <= SEND_DEV_ADDR_W_0;
        end

        // Send device address + W (8 bits)
        SEND_DEV_ADDR_W_0: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= SEND_DEV_ADDR_W_1;
        end
        SEND_DEV_ADDR_W_1: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? ACK_DEV_ADDR_W_0 : SEND_DEV_ADDR_W_0;
        end

        // ACK
        ACK_DEV_ADDR_W_0: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= ACK_DEV_ADDR_W_1;
        end
        ACK_DEV_ADDR_W_1: begin
          scl   <= 1;
          state <= ACK_DEV_ADDR_W_2;
        end
        ACK_DEV_ADDR_W_2: begin
          scl       <= 0;
          sda_oe    <= 1;
          shift_reg <= addr_reg[7:0];
          bit_idx   <= 0;
          state     <= SEND_MEM_ADDR_0;
        end

        // Send memory address (8 bits)
        SEND_MEM_ADDR_0: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= SEND_MEM_ADDR_1;
        end
        SEND_MEM_ADDR_1: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? ACK_MEM_ADDR_0 : SEND_MEM_ADDR_0;
        end

        // ACK
        ACK_MEM_ADDR_0: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= ACK_MEM_ADDR_1;
        end
        ACK_MEM_ADDR_1: begin
          scl   <= 1;
          state <= ACK_MEM_ADDR_2;
        end
        ACK_MEM_ADDR_2: begin
          scl    <= 0;
          sda_oe <= 1;
          state  <= rw_reg ? RD_RESTART_0 : WR_LOAD_BYTE;
        end  // Branch for read/write

        // WRITE: Send data (8 bits) - Loop for multiple bytes
        WR_LOAD_BYTE: begin
          buf_addr <= byte_cnt;  // Read from buffer at current byte index
          state    <= WR_WAIT_BUF;
        end
        WR_WAIT_BUF: begin  // Wait one cycle for buffer read
          shift_reg <= buf_rd_data;
          bit_idx   <= 0;
          state     <= WR_SEND_DATA_0;
        end
        WR_SEND_DATA_0: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= WR_SEND_DATA_1;
        end
        WR_SEND_DATA_1: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? WR_ACK_0 : WR_SEND_DATA_0;
        end

        // ACK after write
        WR_ACK_0: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= WR_ACK_1;
        end
        WR_ACK_1: begin
          scl   <= 1;
          state <= WR_ACK_2;
        end
        WR_ACK_2: begin
          scl      <= 0;
          byte_cnt <= byte_cnt + 1;
          sda_oe   <= 1;
          if (byte_cnt >= num_bytes_reg - 1) state <= STOP_0;  // All bytes written
          else state <= WR_LOAD_BYTE;  // Continue writing next byte
        end

        // READ: Repeated START
        RD_RESTART_0: begin
          sda_out <= 1;
          scl     <= 1;
          state   <= RD_RESTART_1;
        end
        RD_RESTART_1: begin
          sda_out   <= 0;
          shift_reg <= {4'b1010, addr_reg[10:8], 1'b1};
          bit_idx   <= 0;
          state     <= SEND_DEV_ADDR_R_0;
        end

        // Send device address + R (8 bits)
        SEND_DEV_ADDR_R_0: begin
          scl     <= 0;
          sda_out <= shift_reg[7];
          state   <= SEND_DEV_ADDR_R_1;
        end
        SEND_DEV_ADDR_R_1: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], 1'b0};
          bit_idx   <= bit_idx + 1;
          state     <= (bit_idx == 7) ? ACK_DEV_ADDR_R_0 : SEND_DEV_ADDR_R_0;
        end

        // ACK
        ACK_DEV_ADDR_R_0: begin
          scl    <= 0;
          sda_oe <= 0;
          state  <= ACK_DEV_ADDR_R_1;
        end
        ACK_DEV_ADDR_R_1: begin
          scl   <= 1;
          state <= ACK_DEV_ADDR_R_2;
        end
        ACK_DEV_ADDR_R_2: begin
          scl     <= 0;
          bit_idx <= 0;
          state   <= RD_RECV_DATA_0;
        end

        // Read data (8 bits) - Loop for multiple bytes
        RD_RECV_DATA_0: begin
          scl   <= 0;
          state <= RD_RECV_DATA_1;
        end
        RD_RECV_DATA_1: begin
          scl       <= 1;
          shift_reg <= {shift_reg[6:0], sda};
          bit_idx   <= bit_idx + 1;
          if (bit_idx == 7) begin
            rd_data     <= {shift_reg[6:0], sda};
            buf_addr    <= byte_cnt;
            buf_wr_data <= {shift_reg[6:0], sda};
            buf_wr_en   <= 1;  // Write to buffer
          end
          state <= (bit_idx == 7) ? RD_ACK_NACK_0 : RD_RECV_DATA_0;
        end

        // ACK/NACK after read
        RD_ACK_NACK_0: begin
          scl    <= 0;
          sda_oe <= 1;
          if (byte_cnt >= num_bytes_reg - 1) sda_out <= 1;  // NACK for last byte
          else sda_out <= 0;  // ACK for more bytes
          state <= RD_ACK_NACK_1;
        end
        RD_ACK_NACK_1: begin
          scl   <= 1;
          state <= RD_ACK_NACK_2;
        end
        RD_ACK_NACK_2: begin
          scl      <= 0;
          byte_cnt <= byte_cnt + 1;
          sda_oe   <= 0;
          if (byte_cnt >= num_bytes_reg - 1) state <= STOP_0;  // All bytes read
          else state <= RD_RECV_DATA_0;  // Continue reading next byte
        end

        // STOP
        STOP_0: begin
          sda_out <= 0;
          scl     <= 1;
          state   <= STOP_1;
        end
        STOP_1: begin
          sda_out <= 1;
          done    <= 1;
          busy    <= 0;
          state   <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule

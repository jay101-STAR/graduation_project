module i2c_slave (
    input wire       clk,         // System clock
    input wire       rst_n,       // Active low reset
    input wire [6:0] slave_addr,  // 7-bit slave address
    inout wire       sda,         // I2C data line
    input wire       scl          // I2C clock line
);

  // State machine states
  localparam IDLE = 3'd0;
  localparam ADDR = 3'd1;
  localparam ACK_ADDR = 3'd2;
  localparam WRITE_DATA = 3'd3;
  localparam ACK_WRITE = 3'd4;
  localparam READ_DATA = 3'd5;
  localparam ACK_READ = 3'd6;

  reg [2:0] state, next_state;
  reg [7:0] shift_reg, shift_reg_next;
  reg [3:0] bit_cnt, bit_cnt_next;
  reg [7:0] memory[0:255];  // Simple memory for storing data
  reg [7:0] mem_addr, mem_addr_next;
  reg sda_out, sda_out_next;
  reg sda_oe, sda_oe_next;
  reg rw_bit, rw_bit_next;
  reg addr_match, addr_match_next;

  // SDA tri-state control
  assign sda = sda_oe ? sda_out : 1'bz;

  // Detect SCL edges
  reg scl_d1, scl_d2;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scl_d1 <= 1'b1;
      scl_d2 <= 1'b1;
    end else begin
      scl_d1 <= scl;
      scl_d2 <= scl_d1;
    end
  end

  wire scl_posedge = scl_d1 && !scl_d2;
  wire scl_negedge = !scl_d1 && scl_d2;

  // Detect SDA edges (for START and STOP conditions)
  reg sda_d1, sda_d2;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sda_d1 <= 1'b1;
      sda_d2 <= 1'b1;
    end else begin
      sda_d1 <= sda;
      sda_d2 <= sda_d1;
    end
  end

  wire start_cond = sda_d2 && !sda_d1 && scl_d2;
  wire stop_cond = !sda_d2 && sda_d1 && scl_d2;

  // Initialize memory with some test data
  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      memory[i] = i[7:0];
    end
  end

  // ========== Segment 1: State Register (Sequential Logic) ==========
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // ========== Segment 2: Next State Logic (Combinational Logic) ==========
  always @(*) begin
    next_state = state;

    // Detect START condition - highest priority
    if (start_cond) begin
      next_state = ADDR;
    end  // Detect STOP condition - second priority
    else if (stop_cond) begin
      next_state = IDLE;
    end else begin
      case (state)
        IDLE: begin
          next_state = IDLE;
        end

        ADDR: begin
          if (scl_posedge && bit_cnt == 4'd7) begin
            next_state = ACK_ADDR;
          end
        end

        ACK_ADDR: begin
          if (scl_posedge) begin
            if (addr_match) begin
              if (rw_bit) begin
                next_state = READ_DATA;
              end else begin
                next_state = WRITE_DATA;
              end
            end else begin
              next_state = IDLE;
            end
          end
        end

        WRITE_DATA: begin
          if (scl_posedge && bit_cnt == 4'd7) begin
            next_state = ACK_WRITE;
          end
        end

        ACK_WRITE: begin
          if (scl_posedge) begin
            next_state = WRITE_DATA;
          end
        end

        READ_DATA: begin
          if (scl_negedge && bit_cnt == 4'd7) begin
            next_state = ACK_READ;
          end
        end

        ACK_READ: begin
          if (scl_posedge) begin
            if (!sda) begin  // ACK received
              next_state = READ_DATA;
            end else begin  // NACK received
              next_state = IDLE;
            end
          end
        end

        default: next_state = IDLE;
      endcase
    end
  end

  // ========== Segment 3: Output Logic (Sequential Logic) ==========
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg  <= 8'd0;
      bit_cnt    <= 4'd0;
      sda_out    <= 1'b1;
      sda_oe     <= 1'b0;
      rw_bit     <= 1'b0;
      addr_match <= 1'b0;
      mem_addr   <= 8'd0;
    end else begin
      shift_reg  <= shift_reg_next;
      bit_cnt    <= bit_cnt_next;
      sda_out    <= sda_out_next;
      sda_oe     <= sda_oe_next;
      rw_bit     <= rw_bit_next;
      addr_match <= addr_match_next;
      mem_addr   <= mem_addr_next;
    end
  end

  // Output combinational logic
  always @(*) begin
    // Default: hold current values
    shift_reg_next  = shift_reg;
    bit_cnt_next    = bit_cnt;
    sda_out_next    = sda_out;
    sda_oe_next     = sda_oe;
    rw_bit_next     = rw_bit;
    addr_match_next = addr_match;
    mem_addr_next   = mem_addr;

    // Handle START condition
    if (start_cond) begin
      bit_cnt_next    = 4'd0;
      shift_reg_next  = 8'd0;
      sda_oe_next     = 1'b0;
      addr_match_next = 1'b0;
    end  // Handle STOP condition
    else if (stop_cond) begin
      sda_oe_next = 1'b0;
    end else begin
      case (state)
        IDLE: begin
          sda_oe_next  = 1'b0;
          bit_cnt_next = 4'd0;
        end

        ADDR: begin
          if (scl_posedge) begin
            shift_reg_next = {shift_reg[6:0], sda};
            bit_cnt_next   = bit_cnt + 1'b1;
            if (bit_cnt == 4'd7) begin
              // Check if address matches
              if (shift_reg[6:0] == slave_addr) begin
                addr_match_next = 1'b1;
                rw_bit_next     = sda;
              end else begin
                addr_match_next = 1'b0;
              end
            end
          end
        end

        ACK_ADDR: begin
          if (scl_negedge) begin
            if (addr_match) begin
              sda_out_next = 1'b0;  // Send ACK
              sda_oe_next  = 1'b1;
            end else begin
              sda_oe_next = 1'b0;  // Don't respond if address doesn't match
            end
          end else if (scl_posedge) begin
            if (addr_match) begin
              bit_cnt_next = 4'd0;
              if (rw_bit) begin
                shift_reg_next = memory[mem_addr];
              end
            end
          end
        end

        WRITE_DATA: begin
          if (scl_negedge) begin
            sda_oe_next = 1'b0;
          end else if (scl_posedge) begin
            shift_reg_next = {shift_reg[6:0], sda};
            bit_cnt_next   = bit_cnt + 1'b1;
            if (bit_cnt == 4'd7) begin
              mem_addr_next = mem_addr + 1'b1;
            end
          end
        end

        ACK_WRITE: begin
          if (scl_negedge) begin
            sda_out_next = 1'b0;  // Send ACK
            sda_oe_next  = 1'b1;
          end else if (scl_posedge) begin
            bit_cnt_next = 4'd0;
          end
        end

        READ_DATA: begin
          if (scl_negedge) begin
            sda_out_next   = shift_reg[7];
            sda_oe_next    = 1'b1;
            shift_reg_next = {shift_reg[6:0], 1'b0};
            bit_cnt_next   = bit_cnt + 1'b1;
          end
        end

        ACK_READ: begin
          if (scl_negedge) begin
            sda_oe_next = 1'b0;  // Release SDA to receive ACK/NACK
          end else if (scl_posedge) begin
            if (!sda) begin  // ACK received
              bit_cnt_next   = 4'd0;
              mem_addr_next  = mem_addr + 1'b1;
              shift_reg_next = memory[mem_addr+1'b1];
            end
          end
        end
      endcase
    end
  end

  // Memory write logic (separate always block for memory write)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Memory retains its initial values
    end else begin
      if (state == WRITE_DATA && scl_posedge && bit_cnt == 4'd7) begin
        memory[mem_addr] <= {shift_reg[6:0], sda};
      end
    end
  end

endmodule

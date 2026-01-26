module i2c_master (
    input  wire       clk,         // System clock
    input  wire       rst_n,       // Active low reset
    input  wire [6:0] slave_addr,  // 7-bit slave address
    input  wire       rw,          // 1: read, 0: write
    input  wire [7:0] wr_data,     // Data to write
    input  wire [7:0] num_bytes,   // Number of bytes to transfer
    input  wire       start,       // Start transaction
    output reg  [7:0] rd_data,     // Data read
    output reg        busy,        // Busy flag
    output reg        done,        // Transaction complete
    output reg        ack_error,   // ACK error flag
    inout  wire       sda,         // I2C data line
    output reg        scl          // I2C clock line
);

  // State machine states
  localparam IDLE = 4'd0;
  localparam START_COND = 4'd1;
  localparam ADDR = 4'd2;
  localparam ACK_ADDR = 4'd3;
  localparam WRITE_DATA = 4'd4;
  localparam ACK_WRITE = 4'd5;
  localparam READ_DATA = 4'd6;
  localparam ACK_READ = 4'd7;
  localparam STOP_COND = 4'd8;

  reg [3:0] state, next_state;
  reg [7:0] shift_reg, shift_reg_next;
  reg [3:0] bit_cnt, bit_cnt_next;
  reg [7:0] byte_cnt, byte_cnt_next;
  reg [7:0] clk_div;
  reg sda_out, sda_out_next;
  reg sda_oe, sda_oe_next;
  reg scl_next;
  reg busy_next, done_next, ack_error_next;
  reg [7:0] rd_data_next;
  reg rw_reg;
  reg start_reg;
  reg scl_d;

  // SDA tri-state control
  assign sda = (sda_oe ? sda_out : 1'bz);

  // assign sda = (state == ACK_WRITE && (scl == 0)) ? 1'bz : (sda_oe ? sda_out : 1'bz);
  // Clock divider for SCL generation (divide by 256)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clk_div <= 8'd0;
    else clk_div <= clk_div + 1'b1;
  end

  wire scl_tick = (clk_div == 8'd0);

  // ========== Segment 1: State Register (Sequential Logic) ==========
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else if (scl_tick || (state == WRITE_DATA && next_state == ACK_WRITE)) begin
      state <= next_state;
    end
  end

  // ========== Segment 2: Next State Logic (Combinational Logic) ==========
  always @(*) begin
    next_state = state;
    case (state)
      IDLE: begin
        if (start_reg) next_state = START_COND;
      end
      START_COND: next_state = ADDR;
      ADDR: begin
        if (bit_cnt == 4'd8 && scl) next_state = ACK_ADDR;
      end
      ACK_ADDR: begin
        if (scl) begin
          if (rw_reg) next_state = READ_DATA;
          else next_state = WRITE_DATA;
        end
      end
      WRITE_DATA: begin
        if (bit_cnt == 4'd8) next_state = ACK_WRITE;
      end
      ACK_WRITE: begin
        if (scl) begin
          if (byte_cnt + 1'b1 > num_bytes) next_state = STOP_COND;
          else next_state = WRITE_DATA;
        end
      end
      READ_DATA: begin
        if (bit_cnt == 4'd8) next_state = ACK_READ;
      end
      ACK_READ: begin
        if (scl) begin
          if (byte_cnt + 1'b1 > num_bytes) next_state = STOP_COND;
          else next_state = READ_DATA;
        end
      end
      STOP_COND:  if (scl) next_state = IDLE;
      default:    next_state = IDLE;
    endcase
  end

  // ========== Segment 3: Output Logic (Sequential Logic) ==========
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scl       <= 1'b1;
      sda_out   <= 1'b1;
      sda_oe    <= 1'b1;
      busy      <= 1'b0;
      done      <= 1'b0;
      ack_error <= 1'b0;
      bit_cnt   <= 4'd0;
      byte_cnt  <= 8'd0;
      shift_reg <= 8'd0;
      rd_data   <= 8'd0;
      rw_reg    <= 1'b0;
    end else if (scl_tick) begin
      scl       <= scl_next;
      sda_out   <= sda_out_next;
      sda_oe    <= sda_oe_next;
      busy      <= busy_next;
      done      <= done_next;
      ack_error <= ack_error_next;
      bit_cnt   <= bit_cnt_next;
      byte_cnt  <= byte_cnt_next;
      shift_reg <= shift_reg_next;
      rd_data   <= rd_data_next;
    end
  end

  // Output combinational logic
  always @(*) begin
    // Default: hold current values
    scl_next       = scl;
    sda_out_next   = sda_out;
    sda_oe_next    = sda_oe;
    busy_next      = busy;
    done_next      = done;
    ack_error_next = ack_error;
    bit_cnt_next   = bit_cnt;
    byte_cnt_next  = byte_cnt;
    shift_reg_next = shift_reg;
    rd_data_next   = rd_data;

    case (state)
      IDLE: begin
        scl_next       = 1'b1;
        sda_out_next   = 1'b1;
        sda_oe_next    = 1'b1;
        busy_next      = 1'b0;
        ack_error_next = 1'b0;
        if (start_reg) begin
          busy_next     = 1'b1;
          done_next     = 1'b0;
          byte_cnt_next = 8'd1;
        end
      end

      START_COND: begin
        sda_out_next   = 1'b0;
        scl_next       = 1'b1;
        shift_reg_next = {slave_addr, rw};
        bit_cnt_next   = 4'd0;
      end

      ADDR: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_out_next   = shift_reg[7];
          shift_reg_next = {shift_reg[6:0], 1'b0};
          bit_cnt_next   = bit_cnt + 1'b1;
        end
      end

      ACK_ADDR: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_oe_next = 1'b0;
        end else begin
          if (sda) ack_error_next = 1'b1;
          bit_cnt_next = 4'd0;
          if (!rw_reg) shift_reg_next = wr_data;
        end
      end

      WRITE_DATA: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_oe_next    = 1'b1;
          sda_out_next   = shift_reg[7];
          shift_reg_next = {shift_reg[6:0], 1'b0};
          bit_cnt_next   = bit_cnt + 1'b1;
        end
      end

      ACK_WRITE: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_oe_next = 1'b0;
        end else begin
          if (sda) ack_error_next = 1'b1;
          bit_cnt_next = 4'd0;
          if (byte_cnt + 1'b1 >= num_bytes) byte_cnt_next = byte_cnt + 1'b1;
          else byte_cnt_next = byte_cnt + 1'b1;
          if (byte_cnt < num_bytes) shift_reg_next = wr_data;
        end
      end

      READ_DATA: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_oe_next = 1'b0;
        end else begin
          shift_reg_next = {shift_reg[6:0], sda};
          bit_cnt_next   = bit_cnt + 1'b1;
          if (bit_cnt == 4'd7) rd_data_next = {shift_reg[6:0], sda};
        end
      end

      ACK_READ: begin
        scl_next = ~scl;
        if (!scl) begin
          sda_oe_next  = 1'b1;
          sda_out_next = (byte_cnt >= num_bytes) ? 1'b1 : 1'b0;
        end else begin
          bit_cnt_next  = 4'd0;
          byte_cnt_next = byte_cnt + 1'b1;
        end
      end

      STOP_COND: begin
        scl_next     = 1'b1;
        sda_oe_next  = 1'b1;
        sda_out_next = 1'b1;
        done_next    = 1'b1;
        busy_next    = 1'b0;
      end
    endcase
  end

  // Capture start signal
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) start_reg <= 1'b0;
    else if (start) start_reg <= 1'b1;
    else if (scl_tick && state == IDLE && start_reg) start_reg <= 1'b0;
  end

  // Capture rw signal at start
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) rw_reg <= 1'b0;
    else if (start) rw_reg <= rw;
  end

endmodule

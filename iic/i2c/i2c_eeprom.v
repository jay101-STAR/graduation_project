`timescale 1ns / 1ps
`define timeslice 100

module eeprom (
    input scl,
    inout sda
);
  reg              out_flag;
  reg     [ 7 : 0] memory     [2047 : 0];
  reg     [10 : 0] address;
  reg     [ 7 : 0] memory_buf;
  reg     [ 7 : 0] sda_buf;
  reg     [ 7 : 0] shift;
  reg     [ 7 : 0] addr_byte;
  reg     [ 7 : 0] ctrl_byte;
  reg     [ 1 : 0] State;
  integer          i;

  // -------------------------------------
  parameter r7 = 8'b10101111;
  parameter r6 = 8'b10101101;
  parameter r5 = 8'b10101011;
  parameter r4 = 8'b10101001;
  parameter r3 = 8'b10100111;
  parameter r2 = 8'b10100101;
  parameter r1 = 8'b10100011;
  parameter r0 = 8'b10100001;
  parameter w7 = 8'b10101110;
  parameter w6 = 8'b10101100;
  parameter w5 = 8'b10101010;
  parameter w4 = 8'b10101000;
  parameter w3 = 8'b10100110;
  parameter w2 = 8'b10100100;
  parameter w1 = 8'b10100010;
  parameter w0 = 8'b10100000;
  //--------------------------------------

  assign sda = (out_flag == 1) ? sda_buf[7] : 1'bz;

  //--------------寄存器和存储器初始化--------------
  initial begin
    addr_byte  = 0;
    ctrl_byte  = 0;
    out_flag   = 0;
    sda_buf    = 0;
    State      = 2'b00;
    memory_buf = 0;
    address    = 0;
    shift      = 0;
    for (i = 0; i <= 2047; i = i + 1) memory[i] = 0;
  end

  //--------------启动信号检测--------------
  always @(negedge sda)
    if (scl == 1) begin
      State = State + 1;
      if (State == 2'b11) disable write_to_eeprm;
    end
  //--------------主状态机--------------
  always @(posedge sda)
    if (scl == 1) stop_W_R;
    else begin
      casex (State)
        2'b01: begin
          read_in;
          if(ctrl_byte == w7||ctrl_byte == w6|| ctrl_byte == w5 || ctrl_byte == w4 || ctrl_byte == w3 || ctrl_byte == w2 ||ctrl_byte == w1 ||ctrl_byte == w0)begin
            State = 2'b10;
            write_to_eeprm;
          end else State = 2'b00;
        end
        2'b11:   read_from_eeprm;
        default: State = 2'b00;
      endcase
    end

  //--------------操作停止--------------
  task stop_W_R;
    begin
      State     = 2'b00;
      addr_byte = 0;
      ctrl_byte = 0;
      out_flag  = 0;
      sda_buf   = 0;
    end
  endtask

  //--------------读进控制字和存储单元地址--------------
  task read_in;
    begin
      shift_in(ctrl_byte);
      shift_in(addr_byte);
    end
  endtask

  //--------------EEPROM写操作--------------
  task write_to_eeprm;
    begin
      shift_in(memory_buf);
      address         = {ctrl_byte[3:1], addr_byte};
      memory[address] = memory_buf;
      $display("eeprm---memory[%0h]=%0h", address, memory[address]);
      State = 2'b00;
    end
  endtask

  //--------------EEPROM读操作--------------
  task read_from_eeprm;
    begin
      shift_in(ctrl_byte);
      if(ctrl_byte == r7 || ctrl_byte == r6 || ctrl_byte == r5 || ctrl_byte == r4 || ctrl_byte == r3 || ctrl_byte == r2 || ctrl_byte == r1 || ctrl_byte == r0)begin
        // Loop to handle multiple byte reads with address auto-increment
        forever begin
          address = {ctrl_byte[3:1], addr_byte};
          sda_buf = memory[address];
          shift_out;

          // Check for NACK (master doesn't want more bytes)
          // After shift_out, if SDA is 1 at ACK/NACK time, it's a NACK
          @(negedge scl);  // Wait for ACK/NACK setup
          @(posedge scl);  // Sample ACK/NACK bit
          if (sda == 1) begin  // NACK received
            break;  // Stop reading
          end else begin
            // ACK received, increment address for next byte
            addr_byte = addr_byte + 1;
          end
        end
        State = 2'b00;
      end
    end
  endtask

  //--------------SDA 数据线上的数据存入寄存器 ，数据在SCL的高电平有效--------------
  task shift_in;
    output [7:0] shift;
    begin
      @(posedge scl) shift[7] = sda;
      @(posedge scl) shift[6] = sda;
      @(posedge scl) shift[5] = sda;
      @(posedge scl) shift[4] = sda;
      @(posedge scl) shift[3] = sda;
      @(posedge scl) shift[2] = sda;
      @(posedge scl) shift[1] = sda;
      @(posedge scl) shift[0] = sda;
      @(negedge scl) begin
        #`timeslice;
        out_flag = 1;
        sda_buf  = 0;
      end
      @(negedge scl) #`timeslice out_flag = 0;
    end
  endtask
  //--------------EEPROM存储器中的数据通过SDA数据线输出，数据在SCL低电平时变化--------------
  task shift_out;
    begin
      out_flag = 1;
      for (i = 6; i >= 0; i = i - 1) begin
        @(negedge scl);
        #`timeslice;
        sda_buf = sda_buf << 1;
      end
      @(negedge scl) #`timeslice sda_buf[7] = 1;
      @(negedge scl) #`timeslice out_flag = 0;
    end
  endtask

endmodule

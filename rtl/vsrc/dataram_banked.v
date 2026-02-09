//============================================================================
// dataram.v - Bank ?????????
//============================================================================
// ??:
// - ?????? BRAM (Bank0: ???, Bank1: ???)
// - ?????????? (LB/LH/LW/LBU/LHU/SB/SH/SW)
// - ????(BRAM ??,????????)
// - ??? 32KB (?? Bank 16KB)
//============================================================================
// ????:
//   Word 0 -> Bank0[0]    Word 1 -> Bank1[0]
//   Word 2 -> Bank0[1]    Word 3 -> Bank1[1]
//   Word 4 -> Bank0[2]    Word 5 -> Bank1[2]
//   ...
//============================================================================

`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"
module dataram_banked (
    input clk,
    input rst,
    input stall,

    // CPU interface
    input [31:0] ex_dataram_addr,
    input [31:0] ex_dataram_wdata,
    input        ex_dataram_wen,
    input        ex_dataram_ren,
    input [ 7:0] ex_dataram_alucex,

    // outputs
    output reg [31:0] dataram_wb_rdata,
    output reg [31:0] tohost_value_dataram
);

  //==========================================================================
  // ????
  //==========================================================================
  localparam BANK_ADDR_WIDTH = 13;  // 每 Bank 8192 字 = 32KB，总 64KB
  localparam BANK_DEPTH = (1 << BANK_ADDR_WIDTH);

  // tohost ??: 0x80001000
  // word_addr = (0x80001000 - 0x80000000) / 4 = 0x400 = 1024
  // ????,? Bank0,inner_addr = 512
  localparam TOHOST_ADDR = 32'h8000_1000;

  //==========================================================================
  // ????
  //==========================================================================
  wire [31:0] addr_offset = ex_dataram_addr - `PC_BASE_ADDR;
  wire [17:0] word_addr = addr_offset[19:2];  // ???
  wire [1:0] byte_offset = addr_offset[1:0];  // ????
  wire bank_sel = word_addr[0];  // 0=???(Bank0), 1=???(Bank1)

  // Bank ???
  wire [BANK_ADDR_WIDTH-1:0] inner_addr = word_addr[BANK_ADDR_WIDTH:1];

  // Bank0 ? Bank1 ?????
  // ? bank_sel = 0: Bank0[inner_addr], Bank1[inner_addr]
  // ? bank_sel = 1: Bank1[inner_addr], Bank0[inner_addr + 1]
  // 修复：防止地址溢出（当inner_addr=8191时，加1会溢出到8192）
  wire [BANK_ADDR_WIDTH-1:0] addr_bank0 = bank_sel ?
      ((inner_addr == (BANK_DEPTH-1)) ? inner_addr : (inner_addr + 1'b1)) :
      inner_addr;
  wire [BANK_ADDR_WIDTH-1:0] addr_bank1 = inner_addr;

  //==========================================================================
  // ???????
  //==========================================================================
  wire is_load  = (ex_dataram_alucex == `LB_TYPE) || (ex_dataram_alucex == `LH_TYPE) || (ex_dataram_alucex == `LW_TYPE) ||
                    (ex_dataram_alucex == `LBU_TYPE) || (ex_dataram_alucex == `LHU_TYPE);
  wire is_store = (ex_dataram_alucex == `SB_TYPE) || (ex_dataram_alucex == `SH_TYPE) || (ex_dataram_alucex == `SW_TYPE);

  // SH ? offset=3 ????
  wire cross_sh = (ex_dataram_alucex == `SH_TYPE) && (byte_offset == 2'b11);
  // SW ? offset!=0 ????
  wire cross_sw = (ex_dataram_alucex == `SW_TYPE) && (byte_offset != 2'b00);
  // LH/LHU ? offset=3 ????
  wire cross_lh = ((ex_dataram_alucex == `LH_TYPE) || (ex_dataram_alucex == `LHU_TYPE)) && (byte_offset == 2'b11);
  // LW ? offset!=0 ????
  wire cross_lw = (ex_dataram_alucex == `LW_TYPE) && (byte_offset != 2'b00);

  wire cross_boundary = cross_sh || cross_sw || cross_lh || cross_lw;

  //==========================================================================
  // ??????????
  //==========================================================================
  reg [31:0] wdata_bank0, wdata_bank1;
  reg [3:0] we_bank0, we_bank1;

  always @(*) begin
    // ???
    wdata_bank0 = 32'b0;
    wdata_bank1 = 32'b0;
    we_bank0    = 4'b0000;
    we_bank1    = 4'b0000;

    if (ex_dataram_wen && is_store) begin
      case (ex_dataram_alucex)
        //--------------------------------------------------------------
        // SB: ?????,?????
        //--------------------------------------------------------------
        `SB_TYPE: begin
          if (!bank_sel) begin
            // ???? Bank0
            wdata_bank0 = ex_dataram_wdata[7:0] << (byte_offset * 8);
            we_bank0    = 4'b0001 << byte_offset;
          end else begin
            // ???? Bank1
            wdata_bank1 = ex_dataram_wdata[7:0] << (byte_offset * 8);
            we_bank1    = 4'b0001 << byte_offset;
          end
        end

        //--------------------------------------------------------------
        // SH: ????,offset=3 ????
        //--------------------------------------------------------------
        `SH_TYPE: begin
          if (!bank_sel) begin
            // ???? Bank0
            case (byte_offset)
              2'b00: begin
                wdata_bank0 = {16'b0, ex_dataram_wdata[15:0]};
                we_bank0    = 4'b0011;
              end
              2'b01: begin
                wdata_bank0 = {8'b0, ex_dataram_wdata[15:0], 8'b0};
                we_bank0    = 4'b0110;
              end
              2'b10: begin
                wdata_bank0 = {ex_dataram_wdata[15:0], 16'b0};
                we_bank0    = 4'b1100;
              end
              2'b11: begin
                // ???:Bank0[31:24] + Bank1[7:0]
                wdata_bank0 = {ex_dataram_wdata[7:0], 24'b0};
                we_bank0    = 4'b1000;
                wdata_bank1 = {24'b0, ex_dataram_wdata[15:8]};
                we_bank1    = 4'b0001;
              end
            endcase
          end else begin
            // ???? Bank1
            case (byte_offset)
              2'b00: begin
                wdata_bank1 = {16'b0, ex_dataram_wdata[15:0]};
                we_bank1    = 4'b0011;
              end
              2'b01: begin
                wdata_bank1 = {8'b0, ex_dataram_wdata[15:0], 8'b0};
                we_bank1    = 4'b0110;
              end
              2'b10: begin
                wdata_bank1 = {ex_dataram_wdata[15:0], 16'b0};
                we_bank1    = 4'b1100;
              end
              2'b11: begin
                // ???:Bank1[31:24] + Bank0[7:0]
                wdata_bank1 = {ex_dataram_wdata[7:0], 24'b0};
                we_bank1    = 4'b1000;
                wdata_bank0 = {24'b0, ex_dataram_wdata[15:8]};
                we_bank0    = 4'b0001;
              end
            endcase
          end
        end

        //--------------------------------------------------------------
        // SW: ???,offset!=0 ????
        //--------------------------------------------------------------
        `SW_TYPE: begin
          if (!bank_sel) begin
            // ???? Bank0
            case (byte_offset)
              2'b00: begin
                // ????
                wdata_bank0 = ex_dataram_wdata;
                we_bank0    = 4'b1111;
              end
              2'b01: begin
                // Bank0[31:8] = ex_dataram_wdata[23:0], Bank1[7:0] = ex_dataram_wdata[31:24]
                wdata_bank0 = {ex_dataram_wdata[23:0], 8'b0};
                we_bank0    = 4'b1110;
                wdata_bank1 = {24'b0, ex_dataram_wdata[31:24]};
                we_bank1    = 4'b0001;
              end
              2'b10: begin
                // Bank0[31:16] = ex_dataram_wdata[15:0], Bank1[15:0] = ex_dataram_wdata[31:16]
                wdata_bank0 = {ex_dataram_wdata[15:0], 16'b0};
                we_bank0    = 4'b1100;
                wdata_bank1 = {16'b0, ex_dataram_wdata[31:16]};
                we_bank1    = 4'b0011;
              end
              2'b11: begin
                // Bank0[31:24] = ex_dataram_wdata[7:0], Bank1[23:0] = ex_dataram_wdata[31:8]
                wdata_bank0 = {ex_dataram_wdata[7:0], 24'b0};
                we_bank0    = 4'b1000;
                wdata_bank1 = {8'b0, ex_dataram_wdata[31:8]};
                we_bank1    = 4'b0111;
              end
            endcase
          end else begin
            // ???? Bank1
            case (byte_offset)
              2'b00: begin
                // ????
                wdata_bank1 = ex_dataram_wdata;
                we_bank1    = 4'b1111;
              end
              2'b01: begin
                // Bank1[31:8] = ex_dataram_wdata[23:0], Bank0[7:0] = ex_dataram_wdata[31:24]
                wdata_bank1 = {ex_dataram_wdata[23:0], 8'b0};
                we_bank1    = 4'b1110;
                wdata_bank0 = {24'b0, ex_dataram_wdata[31:24]};
                we_bank0    = 4'b0001;
              end
              2'b10: begin
                // Bank1[31:16] = ex_dataram_wdata[15:0], Bank0[15:0] = ex_dataram_wdata[31:16]
                wdata_bank1 = {ex_dataram_wdata[15:0], 16'b0};
                we_bank1    = 4'b1100;
                wdata_bank0 = {16'b0, ex_dataram_wdata[31:16]};
                we_bank0    = 4'b0011;
              end
              2'b11: begin
                // Bank1[31:24] = ex_dataram_wdata[7:0], Bank0[23:0] = ex_dataram_wdata[31:8]
                wdata_bank1 = {ex_dataram_wdata[7:0], 24'b0};
                we_bank1    = 4'b1000;
                wdata_bank0 = {8'b0, ex_dataram_wdata[31:8]};
                we_bank0    = 4'b0111;
              end
            endcase
          end
        end

        default: begin
          we_bank0 = 4'b0000;
          we_bank1 = 4'b0000;
        end
      endcase
    end
  end

  //==========================================================================
  // BRAM ???
  //==========================================================================
  wire [31:0] rdata_bank0, rdata_bank1;

  std_bram #(
      .ADDR_WIDTH(BANK_ADDR_WIDTH),
      .DATA_WIDTH(32),
      .HEX_FILE  ("/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank0.hex")
  ) bank0 (
      .clk  (clk),
      .we   (we_bank0),
      .addr (addr_bank0),
      .wdata(wdata_bank0),
      .rdata(rdata_bank0)
  );

  std_bram #(
      .ADDR_WIDTH(BANK_ADDR_WIDTH),
      .DATA_WIDTH(32),
      .HEX_FILE  ("/home/jay/Desktop/graduation_project/rtl/vsrc/dataram/bank1.hex")
  ) bank1 (
      .clk  (clk),
      .we   (we_bank1),
      .addr (addr_bank1),
      .wdata(wdata_bank1),
      .rdata(rdata_bank1)
  );

  //==========================================================================
  // ??????(?? BRAM ????????)
  //==========================================================================
  reg       ren_d1;
  reg [7:0] alucex_d1;
  reg [1:0] byte_offset_d1;
  reg       bank_sel_d1;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ren_d1         <= 1'b0;
      alucex_d1      <= 8'b0;
      byte_offset_d1 <= 2'b0;
      bank_sel_d1    <= 1'b0;
    end else begin
      ren_d1         <= ex_dataram_ren;
      alucex_d1      <= ex_dataram_alucex;
      byte_offset_d1 <= byte_offset;
      bank_sel_d1    <= bank_sel;
    end
  end

  //==========================================================================
  // ??????????
  //==========================================================================
  // ?? bank_sel_d1 ????
  // bank_sel_d1 = 0: ??? = Bank0, ??? = Bank1
  // bank_sel_d1 = 1: ??? = Bank1, ??? = Bank0
  wire [31:0] word_lo = bank_sel_d1 ? rdata_bank1 : rdata_bank0;
  wire [31:0] word_hi = bank_sel_d1 ? rdata_bank0 : rdata_bank1;
  wire [63:0] combined_data = {word_hi, word_lo};
  wire [63:0] shifted_data = combined_data >> (byte_offset_d1 * 8);

  // ???????
  wire [ 7:0] byte_data = shifted_data[7:0];
  wire [15:0] half_data = shifted_data[15:0];
  wire [31:0] word_data = shifted_data[31:0];

  always @(*) begin
    if (ren_d1) begin
      case (alucex_d1)
        `LB_TYPE:  dataram_wb_rdata = {{24{byte_data[7]}}, byte_data};  // ?????
        `LBU_TYPE: dataram_wb_rdata = {24'b0, byte_data};  // ?????
        `LH_TYPE:  dataram_wb_rdata = {{16{half_data[15]}}, half_data};  // ?????
        `LHU_TYPE: dataram_wb_rdata = {16'b0, half_data};  // ?????
        `LW_TYPE:  dataram_wb_rdata = word_data;  // ?
        default:   dataram_wb_rdata = 32'b0;
      endcase
    end else begin
      dataram_wb_rdata = 32'b0;
    end
  end

  //==========================================================================
  // tohost ???(??????)
  //==========================================================================
  // ??????,??? RAM ??
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      tohost_value_dataram <= 32'b0;
    end else if (ex_dataram_wen && (ex_dataram_addr == TOHOST_ADDR)) begin
      tohost_value_dataram <= ex_dataram_wdata;
    end
  end

endmodule

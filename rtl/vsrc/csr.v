`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module csr (
    input wire clk,
    input wire rst,

    // ===== CSR instruction interface (from EX) =====
    input wire        ex_csr_wen,      // CSR write enable
    input wire        ex_csr_ren,      // CSR read enable
    input wire [ 7:0] ex_csr_alucex,
    input wire [11:0] ex_csr_addr,
    input wire [31:0] ex_csr_rs1_data,

    // ===== trap / mret =====
    input wire        ex_csr_trap_valid,
    input wire [31:0] ex_csr_trap_pc,
    input wire [31:0] ex_csr_trap_cause,

    // ===== outputs to EX =====
    output wire [31:0] csr_ex_data,
    output wire [31:0] csr_ex_trap_vector,
    output wire [31:0] csr_ex_mepc
);

  // =========================================================
  // CSR addresses
  // =========================================================
  localparam reg [11:0] CSR_MSTATUS = 12'h300;
  localparam reg [11:0] CSR_MIE = 12'h304;
  localparam reg [11:0] CSR_MTVEC = 12'h305;
  localparam reg [11:0] CSR_MEPC = 12'h341;
  localparam reg [11:0] CSR_MCAUSE = 12'h342;
  localparam reg [11:0] CSR_MCYCLE = 12'hB00;
  localparam reg [11:0] CSR_MCYCLEH = 12'hB80;
  localparam reg [11:0] CSR_MVENDORID = 12'hF11;
  localparam reg [11:0] CSR_MARCHID = 12'hF12;

  // =========================================================
  // Internal CSR registers
  // =========================================================
  // mstatus fields
  reg        mstatus_mie;  // bit 3
  reg        mstatus_mpie;  // bit 7
  reg [ 1:0] mstatus_mpp;  // bits 12:11

  // mie fields
  reg        mie_msie;  // bit 3
  reg        mie_mtie;  // bit 7
  reg        mie_meie;  // bit 11

  // others
  reg [31:0] mtvec;
  reg [31:0] mepc;
  reg [31:0] mcause;
  reg [31:0] mvendorid;
  reg [31:0] marchid;

  // cycle counter
  reg [63:0] cycle_int;

  // =========================================================
  // CSR read (combinational, gated by ren)
  // =========================================================
  reg [31:0] csr_read_val;

  always @(*) begin
    if (ex_csr_ren) begin
      csr_read_val = 32'b0;
      case (ex_csr_addr)
        CSR_MSTATUS: begin
          csr_read_val[3]     = mstatus_mie;
          csr_read_val[7]     = mstatus_mpie;
          csr_read_val[12:11] = mstatus_mpp;
        end
        CSR_MIE: begin
          csr_read_val[3]  = mie_msie;
          csr_read_val[7]  = mie_mtie;
          csr_read_val[11] = mie_meie;
        end
        CSR_MTVEC:     csr_read_val = mtvec;
        CSR_MEPC:      csr_read_val = mepc;
        CSR_MCAUSE:    csr_read_val = mcause;
        CSR_MCYCLE:    csr_read_val = cycle_int[31:0];
        CSR_MCYCLEH:   csr_read_val = cycle_int[63:32];
        CSR_MVENDORID: csr_read_val = mvendorid;
        CSR_MARCHID:   csr_read_val = marchid;
        default:       csr_read_val = 32'b0;
      endcase
    end else begin
      csr_read_val = 32'b0;
    end
  end

  assign csr_ex_data = csr_read_val;

  // =========================================================
  // CSR write calculation (read-modify-write)
  // =========================================================
  reg        csr_write;
  reg [31:0] csr_new_val;

  always @(*) begin
    csr_write   = 1'b0;
    csr_new_val = csr_read_val;

    case (ex_csr_alucex)
      `CSRRW_TYPE: begin
        csr_new_val = ex_csr_rs1_data;
        csr_write   = 1'b1;
      end

      `CSRRS_TYPE: begin
        if (ex_csr_wen != 0) begin
          csr_new_val = csr_read_val | ex_csr_rs1_data;
          csr_write   = 1'b1;
        end
      end

      `CSRRC_TYPE: begin
        if (ex_csr_wen != 0) begin
          csr_new_val = csr_read_val & ~ex_csr_rs1_data;
          csr_write   = 1'b1;
        end
      end

      `CSRRWI_TYPE: begin
        csr_new_val = ex_csr_rs1_data;
        csr_write   = 1'b1;
      end

      `CSRRSI_TYPE: begin
        if (ex_csr_wen != 0) begin
          csr_new_val = csr_read_val | ex_csr_rs1_data;
          csr_write   = 1'b1;
        end
      end

      `CSRRCI_TYPE: begin
        if (ex_csr_wen != 0) begin
          csr_new_val = csr_read_val & ~ex_csr_rs1_data;
          csr_write   = 1'b1;
        end
      end

      default: ;
    endcase
  end

  // =========================================================
  // Sequential CSR update
  // =========================================================
  always @(posedge clk) begin
    if (rst) begin
      mstatus_mie  <= 1'b0;
      mstatus_mpie <= 1'b0;
      mstatus_mpp  <= 2'b11;

      mie_msie     <= 1'b0;
      mie_mtie     <= 1'b0;
      mie_meie     <= 1'b0;

      mtvec        <= 32'b0;
      mepc         <= 32'b0;
      mcause       <= 32'b0;

      mvendorid    <= 32'h9737_978;
      marchid      <= 32'h16f9_59d;

      cycle_int    <= 64'b0;
    end else begin
      // cycle counter
      cycle_int <= cycle_int + 1;

      // ---------- trap ----------
      if (ex_csr_trap_valid) begin
        mepc         <= {ex_csr_trap_pc[31:2], 2'b00};
        mcause       <= ex_csr_trap_cause;
        mstatus_mpie <= mstatus_mie;
        mstatus_mie  <= 1'b0;
        mstatus_mpp  <= 2'b11;
      end  // ---------- mret ----------
      else if (ex_csr_alucex == `MRET_TYPE) begin
        mstatus_mie  <= mstatus_mpie;
        mstatus_mpie <= 1'b1;
        mstatus_mpp  <= 2'b00;
      end  // ---------- CSR write ----------
      else if (ex_csr_wen && csr_write) begin
        case (ex_csr_addr)
          CSR_MSTATUS: begin
            mstatus_mie <= csr_new_val[3];
            mstatus_mpie <= csr_new_val[7];
            mstatus_mpp  <= (csr_new_val[12:11] == 2'b11) ? 2'b11 :
                            (csr_new_val[12:11] == 2'b00) ? 2'b00 : mstatus_mpp;
          end
          CSR_MIE: begin
            mie_msie <= csr_new_val[3];
            mie_mtie <= csr_new_val[7];
            mie_meie <= csr_new_val[11];
          end
          CSR_MTVEC:  mtvec <= csr_new_val;
          CSR_MEPC:   mepc <= {csr_new_val[31:2], 2'b00};
          CSR_MCAUSE: mcause <= csr_new_val;
          default:    ;
        endcase
      end
    end
  end

  // =========================================================
  // Outputs
  // =========================================================
  assign csr_ex_trap_vector = {mtvec[31:2], 2'b00};
  assign csr_ex_mepc        = mepc;

endmodule




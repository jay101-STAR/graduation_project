`include "/home/jay/Desktop/graduation_project/rtl/vsrc/define.v"

module csr (
    input wire       clk,
    input wire       rst,
    input wire       retire_pulse,
    input wire [1:0] older_unretired,

    // ===== CSR instruction interface (from EX) =====
    input wire        ex_csr_wen,      // CSR write enable
    input wire        ex_csr_ren,      // CSR read enable
    input wire        ex_csr_is_csr,   // 当前 EX 指令是否为 CSR 指令
    input wire [ 7:0] ex_csr_alucex,
    input wire [11:0] ex_csr_addr,
    input wire [31:0] ex_csr_rs1_data,

    // ===== trap / mret =====
    input wire        ex_csr_trap_valid,
    input wire [31:0] ex_csr_trap_pc,
    input wire [31:0] ex_csr_trap_cause,
    input wire [31:0] ex_csr_trap_tval,

    // ===== outputs to EX =====
    output wire [31:0] csr_ex_data,
    output wire [31:0] csr_ex_trap_vector,
    output wire [31:0] csr_ex_mepc,
    output wire        csr_ex_illegal       // 非法指令（cause=2）：CSR 非法或 MRET 非法
);

  // =========================================================
  // CSR addresses
  // =========================================================
  localparam reg [11:0] CSR_MSTATUS = 12'h300;
  localparam reg [11:0] CSR_MIE = 12'h304;
  localparam reg [11:0] CSR_MTVEC = 12'h305;
  localparam reg [11:0] CSR_MSCRATCH = 12'h340;
  localparam reg [11:0] CSR_MEPC = 12'h341;
  localparam reg [11:0] CSR_MCAUSE = 12'h342;
  localparam reg [11:0] CSR_MTVAL = 12'h343;
  localparam reg [11:0] CSR_MCYCLE = 12'hB00;
  localparam reg [11:0] CSR_MCYCLEH = 12'hB80;
  localparam reg [11:0] CSR_MINSTRET = 12'hB02;
  localparam reg [11:0] CSR_MINSTRETH = 12'hB82;
  localparam reg [11:0] CSR_MVENDORID = 12'hF11;
  localparam reg [11:0] CSR_MARCHID = 12'hF12;
  localparam reg [11:0] CSR_MHARTID = 12'hF14;  // 只读，单核恒为 0；启动代码无保护地读取
  // Zicntr 用户级只读计数器，是 mcycle/minstret 的影子
  localparam reg [11:0] CSR_MCOUNTINHIBIT = 12'h320;
  localparam reg [11:0] CSR_CYCLE = 12'hC00;
  localparam reg [11:0] CSR_INSTRET = 12'hC02;
  localparam reg [11:0] CSR_CYCLEH = 12'hC80;
  localparam reg [11:0] CSR_INSTRETH = 12'hC82;
  // 调试触发器 CSR：未实现触发器，读 0、写忽略（tdata1.type=0 表示无触发器）
  localparam reg [11:0] CSR_TSELECT = 12'h7A0;
  localparam reg [11:0] CSR_TDATA1 = 12'h7A1;
  localparam reg [11:0] CSR_TDATA2 = 12'h7A2;

  //2’b10保留不做任何模式
  localparam reg [1:0] U_MODE = 2'b00;
  localparam reg [1:0] S_MODE = 2'b01;
  localparam reg [1:0] M_MODE = 2'b11;

  //用来记录此时cpu处于什么模式
  reg [1:0] priv_mode;
  // =========================================================
  // Internal CSR registers
  // =========================================================
  // mstatus fields
  reg mstatus_mie;  // bit 3
  reg mstatus_mpie;  // bit 7
  reg [1:0] mstatus_mpp;  // bits 12:11

  // mie fields
  reg mie_msie;  // bit 3
  reg mie_mtie;  // bit 7
  reg mie_meie;  // bit 11
  // mcountinhibit fileds 
  reg mcountinhibit_cy;  //为1时mcycle不会自增
  reg mcountinhibit_ir;  //为1时minstret不会自增

  // others
  reg [31:0] mtvec;
  reg [31:0] mepc;
  reg [31:0] mcause;
  reg [31:0] mtval;
  reg [31:0] mvendorid;
  reg [31:0] marchid;

  // cycle counter
  reg [63:0] cycle_int;
  // retired instruction counter
  reg [63:0] instret_int;
  // EX reads include older instructions still in MEM/WB, but never the CSR
  // instruction itself. The stored counter advances only on actual retirement.
  wire [63:0] instret_read = (mcountinhibit_ir==1'b0)?(instret_int + {62'b0, older_unretired}):instret_int;

  // =========================================================
  // CSR read (combinational, gated by ren)
  // =========================================================
  reg [31:0] csr_read_val;

  //检查异常
  wire csr_illegal;
  wire mret_illegal;
  reg csr_exists;
  assign mret_illegal = (ex_csr_alucex == `MRET_TYPE) && (priv_mode != M_MODE);

  // 已实现 CSR 地址清单：必须与下方读 case 保持一致，新增 CSR 时两处同时修改。
  always @(*) begin
    case (ex_csr_addr)
      CSR_MSTATUS,
      CSR_MIE,
      CSR_MTVEC,
      CSR_MEPC,
      CSR_MSCRATCH,
      CSR_MCAUSE,
      CSR_MTVAL,
      CSR_MCYCLE,
      CSR_MCYCLEH,
      CSR_MINSTRET,
      CSR_MINSTRETH,
      CSR_MVENDORID,
      CSR_MARCHID,
      CSR_MHARTID,
      CSR_CYCLE,
      CSR_INSTRET,
      CSR_CYCLEH,
      CSR_INSTRETH,
      CSR_TSELECT,
      CSR_TDATA1,
      CSR_TDATA2:
      csr_exists = 1'b1;
      default: csr_exists = 1'b0;
    endcase
  end
  // CSR 非法访问：仅对 CSR 指令判断。三种非法情况——
  //   目标 CSR 未实现 / 当前特权级低于地址编码要求 / 对只读 CSR 发起写入。
  // 写入意图由 ex_csr_wen 表示（rs1!=x0 或 uimm!=0），不依赖写入数据是否为 0。
  assign csr_illegal = ex_csr_is_csr &&
      (!csr_exists ||
       (priv_mode < ex_csr_addr[9:8]) ||
       (ex_csr_wen && ex_csr_addr[11:10] == 2'b11));

  // 对外汇总为一条非法指令标志，供 riscv_core 接入精确异常入口（mcause=2）。
  assign csr_ex_illegal = csr_illegal || mret_illegal;

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
        CSR_MTVAL:     csr_read_val = mtval;
        CSR_MCYCLE:    csr_read_val = cycle_int[31:0];
        CSR_MCYCLEH:   csr_read_val = cycle_int[63:32];
        CSR_MINSTRET:  csr_read_val = instret_read[31:0];
        CSR_MINSTRETH: csr_read_val = instret_read[63:32];
        CSR_MVENDORID: csr_read_val = mvendorid;
        CSR_MARCHID:   csr_read_val = marchid;
        CSR_MHARTID:   csr_read_val = 32'b0;  // 单核，hart ID 恒为 0
        CSR_CYCLE:     csr_read_val = cycle_int[31:0];
        CSR_CYCLEH:    csr_read_val = cycle_int[63:32];
        CSR_INSTRET:   csr_read_val = instret_read[31:0];
        CSR_INSTRETH:  csr_read_val = instret_read[63:32];
        // CSR_TSELECT/TDATA1/TDATA2 走 default，读 0
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
      priv_mode    <= 2'b11;  // 复位进入 M 模式（RISC-V 规范），否则访问 M 模式 CSR 会被判非法

      mstatus_mie <= 1'b0;
      mstatus_mpie <= 1'b0;
      mstatus_mpp <= 2'b11;

      mie_msie <= 1'b0;
      mie_mtie <= 1'b0;
      mie_meie <= 1'b0;

      mcountinhibit_cy <= 1'b0;
      mcountinhibit_ir <= 1'b0;

      mtvec <= 32'b0;
      mepc <= 32'b0;
      mcause <= 32'b0;
      mtval <= 32'b0;

      mvendorid <= 32'h9737_978;
      marchid <= 32'h16f9_59d;

      cycle_int <= 64'b0;
      instret_int <= 64'b0;
    end else begin
      // cycle counter
      cycle_int <= (mcountinhibit_cy == 1'b0) ? cycle_int + 1 : cycle_int;
      // retired instruction counter
      if (retire_pulse) begin
        instret_int <= instret_int + 1'b1;
      end
      // ---------- trap ----------
      if (ex_csr_trap_valid) begin
        mepc         <= {ex_csr_trap_pc[31:2], 2'b00};
        mcause       <= ex_csr_trap_cause;
        mtval        <= ex_csr_trap_tval;
        mstatus_mpie <= mstatus_mie;
        mstatus_mie  <= 1'b0;
        mstatus_mpp  <= priv_mode;
        priv_mode    <= 2'b11;
      end  // ---------- mret ----------
      else if (ex_csr_alucex == `MRET_TYPE) begin
        mstatus_mie  <= mstatus_mpie;
        mstatus_mpie <= 1'b1;
        mstatus_mpp  <= 2'b00;
        priv_mode    <= mstatus_mpp;
      end  // ---------- CSR write ----------
      else if (ex_csr_wen && csr_write) begin
        case (ex_csr_addr)
          CSR_MSTATUS: begin
            mstatus_mie  <= csr_new_val[3];
            mstatus_mpie <= csr_new_val[7];
            mstatus_mpp  <= (csr_new_val[12:11] == 2'b10) ? mstatus_mpp : csr_new_val[12:11];
          end
          CSR_MIE: begin
            mie_msie <= csr_new_val[3];
            mie_mtie <= csr_new_val[7];
            mie_meie <= csr_new_val[11];
          end
          CSR_MTVEC:   mtvec <= csr_new_val;
          CSR_MEPC:    mepc <= {csr_new_val[31:2], 2'b00};
          CSR_MCAUSE:  mcause <= csr_new_val;
          CSR_MTVAL:   mtval <= csr_new_val;
          CSR_MCYCLE:  cycle_int[31:0] <= csr_new_val;
          CSR_MCYCLEH: cycle_int[63:32] <= csr_new_val;
          CSR_MCOUNTINHIBIT: begin
            mcountinhibit_cy <= csr_new_val[0];
            mcountinhibit_ir <= csr_new_val[2];
          end
          default:     ;
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


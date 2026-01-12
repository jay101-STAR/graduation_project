`define PC_BASE_ADDR 32'h8000_0000

//jal,jalr,auipc,lui,fence这几条指令较为特殊，
//通过判断op7即可判断出来，因此其alucex的类型中多加一个字母来加以区分

`define R_TYPE 4'b0001
`define I_TYPE 4'b0010
`define S_TYPE 4'b0011
`define B_TYPE 4'b0100
`define JAL_TYPE 4'b0101
`define LUI_TYPE 4'b0110
`define AUIPC_TYPE 4'b0111
`define JALR_TYPE 4'b1000
`define E_TYPE_MRET_TYPE 4'b1001
`define L_TYPE 4'b1010
`define FENCE_TYPE 4'b1011
`define CSR_TYPE 4'b1100
`define NO_TYPE 4'b0000

`define R_ASA_TYPE 7'b0000000
`define R_SUA_TYPE 7'b0100000

`define ADD_TYPE 8'b00000000  //include ADD,ADDI
`define LUII_TYPE 8'b00000001  //delegate LUI
`define AUIPCC_TYPE 8'b00000010  //delegate AUIPC
`define JALRR_TYPE 8'b00000011  //delegate JALR
`define JALL_TYPE 8'b00000100  //delegate JAL
`define SLL_TYPE 8'b00000101  //delegate SLL,SLLI
`define SUB_TYPE 8'b00000110
`define SLT_TYPE 8'b00000111  //delegate SLT,SLTI
`define SLTU_TYPE 8'b00001000  //delegate SLTU,SLTIU
`define XOR_TYPE 8'b00001001  //delegate XOR,XORI
`define SRL_TYPE 8'b00001010  //delegate SRL,SRLI
`define SRA_TYPE 8'b00001011  //delegate SRA,SRAI
`define OR_TYPE 8'b00001100  //delegate OR,ORI
`define AND_TYPE 8'b00001101  //delegate AND,ANDI
`define FENCEE_TYPE 8'b00001110  //delegate  FENCE
`define BEQ_TYPE 8'b00010000
`define BNE_TYPE 8'b00010001
`define BLT_TYPE 8'b00010010
`define BGE_TYPE 8'b00010011
`define BLTU_TYPE 8'b00010100
`define BGEU_TYPE 8'b00010101
`define LB_TYPE 8'b00010110
`define LH_TYPE 8'b00010111
`define LW_TYPE 8'b00011000
`define LBU_TYPE 8'b00011001
`define LHU_TYPE 8'b00011010
`define SB_TYPE 8'b00011011
`define SH_TYPE 8'b00011100
`define SW_TYPE 8'b00011101
`define CSRRW_TYPE  8'b00011110
`define CSRRS_TYPE  8'b00011111
`define CSRRC_TYPE  8'b00001111
`define CSRRWI_TYPE 8'b00100000
`define CSRRSI_TYPE 8'b00100001
`define CSRRCI_TYPE 8'b00100010
`define EBREAK_TYPE 8'b00100100
`define ECALL_TYPE  8'b00100101
`define MRET_TYPE   8'b00100101

//func7
`define R_ASA_INST 7'b0000000 //R_TYPE except SUB and SRA
`define R_SUA_INST 7'b0100000 //SUB and SUA's func7



//func3
`define ADD_SUB_INST 3'b000
// 分支指令
`define BEQ_INST 3'b000
`define BNE_INST 3'b001
`define BLT_INST 3'b100
`define BGE_INST 3'b101
`define BLTU_INST 3'b110
`define BGEU_INST 3'b111

// 加载指令
`define LB_INST 3'b000
`define LH_INST 3'b001
`define LW_INST 3'b010
`define LBU_INST 3'b100
`define LHU_INST 3'b101

// 存储指令
`define SB_INST 3'b000
`define SH_INST 3'b001
`define SW_INST 3'b010

// ALU 立即数指令
`define ADDI_INST 3'b000
`define SLTI_INST 3'b010
`define SLTIU_INST 3'b011
`define XORI_INST 3'b100
`define ORI_INST 3'b110
`define ANDI_INST 3'b111

// 移位立即数指令
`define SLLI_INST 3'b001
`define SRLI_INST 3'b101
`define SRAI_INST 3'b101
`define SRLI_SRAI_INST 3'b101

// ALU 寄存器指令
`define ADD_INST 3'b000
`define SUB_INST 3'b000
`define SLL_INST 3'b001
`define SLT_INST 3'b010
`define SLTU_INST 3'b011
`define XOR_INST 3'b100
`define SRL_INST 3'b101
`define SRA_INST 3'b101
`define SRL_SRA_INST 3'b101
`define OR_INST 3'b110
`define AND_INST 3'b111

// Jump 指令
`define JALR_INST 3'b000

// 内存屏障指令
`define FENCE_INST 3'b000

// 系统调用指令
`define ECALL_EBREAK_INST 3'b000

// CSR 指令
`define CSRRW_INST 3'b001
`define CSRRS_INST 3'b010
`define CSRRC_INST 3'b011
`define CSRRWI_INST 3'b101
`define CSRRSI_INST 3'b110
`define CSRRCI_INST 3'b111




`define HIT_GOOD_TRAP 1
`define HIT_BAD_TRAP 2
`define HIT_TRAP 0
`define ABORT 3


//二维数组打包为一维数组
`define PACK_ARRAY(PK_WIDTH, PK_LEN, PK_SRC, PK_DEST) \
                generate \
                genvar pk_idx; \
                for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) \
                begin \
                        assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; \
                end \
                endgenerate

//一维数组展开为二维数组
`define UNPACK_ARRAY(PK_WIDTH, PK_LEN, PK_DEST, PK_SRC) \
                generate \
                genvar unpk_idx; \
                for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) \
                begin \
                        assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)]; \
                end \
                endgenerate

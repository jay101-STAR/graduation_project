`include "define.v"
module pc_reg(
  input rst,
  input clk,
  input [5:0]stall,

  input wire branch_flag_i,
  input wire[`RegBus] branch_target_address_i,

  input wire                    flush,
  input wire[`RegBus]           new_pc,

  output reg [`InstAddrBus] pc,
  output reg ce);
  always@(posedge clk)
    begin
    if(rst==`RstEnable)
	  ce <=  `ChipDisable;
	else begin
	  ce <=  `ChipEnable;
  end 
 end 

 always@(posedge clk)
   begin
     if(ce == `ChipDisable)begin
	   pc <= 32'h00000000;
	 end else begin
	if(flush == 1'b1) begin
	   pc <= new_pc;
	 end else if(stall[0] == `NoStop) begin
	  if(branch_flag_i == `Branch) begin
	    pc <= branch_target_address_i;
	  end else begin
	    pc <= pc+4'h4;
	 end 
	 end 
   end
  end
endmodule
   


module if_id(
  input rst,
  input clk,
  input [`InstAddrBus]if_pc,
  input [`InstAddrBus]if_inst,
  input [5:0] stall,
  input wire flush,
  output reg [`InstAddrBus]id_pc,
  output reg [`InstAddrBus]id_inst
);
  always@(posedge clk)
    begin
	  if(rst == `RstEnable)
	  begin
	    id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
	end else if(flush == 1'b1)begin
	    id_pc <= `ZeroWord;
		id_inst <= `ZeroWord;
   	end	else if(stall[1] == `Stop && stall[2] ==` NoStop) begin
	    id_pc <= `ZeroWord;
		id_inst <= `ZeroWord;
	end else if(stall[1] == `NoStop) begin
	  id_pc <= if_pc;
      id_inst <= if_inst;
    end
	end
endmodule

module regfile(
  input clk,
  input rst,

  input we,
  input [`RegAddrBus] waddr,
  input [`RegBus] wdata,

  input re1,
  input [`RegAddrBus] raddr1,
  output  reg [`RegBus] rdata1,

  input re2,
  input [`RegAddrBus] raddr2,
  output reg [`RegBus]rdata2);
    
  reg [31:0]regs[0:31];

 always @(posedge clk) begin
    if(rst == `RstDisable) begin
        if((we == `WriteEnable)&&(waddr != `RegNumLog2'h0)) begin
            regs[waddr] <= wdata;
        end
    end
end


 always @(*) begin
    if(rst == `RstEnable) begin
        rdata1 <= `ZeroWord;
    end else if (raddr1 == `RegNumLog2'h0) begin
        rdata1 <= `ZeroWord;
    end else if ((raddr1 == waddr)&&(we == `WriteEnable)&&(re1 == `ReadEnable)) begin
        rdata1 <= wdata;
    end else if (re1 == `ReadEnable) begin
        rdata1 <= regs[raddr1];
    end else begin
        rdata1 <= `ZeroWord;
    end
end
// read two 
 always @(*) begin
    if(rst == `RstEnable) begin
        rdata2 <= `ZeroWord;
    end else if (raddr2 == `RegNumLog2'h0) begin
        rdata2 <= `ZeroWord;
    end else if ((raddr2 == waddr)&&(we == `WriteEnable)&&(re2 == `ReadEnable)) begin
        rdata2 <= wdata;
    end else if (re2 == `ReadEnable) begin
        rdata2 <= regs[raddr2];
    end else begin
        rdata2 <= `ZeroWord;
    end
end
endmodule

 module id(
   input rst,

   input [`InstAddrBus] pc_i,
   input [`InstAddrBus] inst_i,

   input [`RegBus] reg1_data_i,
   input [`RegBus] reg2_data_i,
   
   input ex_wreg_i,
   input [`RegBus]ex_wdata_i,
   input [`RegAddrBus] ex_wd_i,

   input mem_wreg_i,
   input [`RegBus] mem_wdata_i,
   input [`RegAddrBus] mem_wd_i,

   input wire is_in_delayslot_i,

   input wire[`AluOpBus] ex_aluop_i,

   output reg reg1_read_o,
   output reg [`RegAddrBus]reg1_addr_o,
   
   output reg reg2_read_o,
   output reg [`RegAddrBus]reg2_addr_o,

   output reg[`AluOpBus] aluop_o,
   output reg[`AluSelBus] alusel_o,
   output reg[`RegBus]   reg1_o,
   output reg[`RegBus]   reg2_o,
   output reg[2:0]  sa2,
   output reg[`RegAddrBus] wd_o,
   output reg wreg_o,

   output reg next_inst_in_delayslot_o,

   output reg branch_flag_o,
   output reg [`RegBus] branch_target_address_o,
   output reg [`RegBus] link_addr_o,
   output reg           is_in_delayslot_o,

   output wire [`RegBus] inst_o,

   output wire [31:0]  excepttype_o,
   output wire[`RegBus] current_inst_address_o,

   output wire [`InstAddrBus] pc_o,

   output stallreq);
   //function code
   wire [5:0]op6 = inst_i[31:26];
   wire [1:0]op21 = inst_i[25:24];
   wire [1:0]op22 = inst_i[23:22];
   wire [1:0]op23 = inst_i[21:20];
   wire [1:0]op24  = inst_i[19:18];
   wire [2:0]op3  = inst_i[17:15];
   wire [4:0]op5  = inst_i[14:10];

   wire [`RegBus] pc_plus_8;
   wire [`RegBus] pc_plus_4; 

   reg compare_we,compare_sign;
   wire compare_result;
   compare compare1(.r1(reg1_o),.r2(reg2_o),.we(compare_we),.sign(compare_sign),.result(compare_result));

   wire [`RegBus]imm_sll2_signedext;

   reg stallreq_for_reg1_loadrelate;

   reg stallreq_for_reg2_loadrelate;

   wire pre_inst_is_load;
    
   assign inst_o = inst_i ;
   assign pc_plus_8 = pc_i + 8;
   assign pc_plus_4 = pc_i + 4;

   assign pc_o = pc_i;

   assign imm_sll2_signedext ={{21{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8]};
  
   reg [`RegBus] imm;
   reg instvalid;
   

   //reg excepttype_is_syscall;
   //reg excepttype_is_eret;

   //assign excepttype_o ={19'b0,excepttype_is_eret,2'b0,instvalid,excepttype_is_syscall,8'b0};
   
  // assign current_inst_address_o = pc_i;

   assign stallreq = `NoStop;

   assign pre_inst_is_load = ((ex_aluop_i == `EXE_LDB_OP) ||
                              (ex_aluop_i == `EXE_LDBU_OP) ||
							   (ex_aluop_i == `EXE_LDH_OP)  ||
							   (ex_aluop_i == `EXE_LDHU_OP) ||
							   (ex_aluop_i == `EXE_LDW_OP) ||
							   (ex_aluop_i == `EXE_LL_OP)||
							   (ex_aluop_i == `EXE_SC_OP) )? 1'b1:1'b0;
  
   always @(*) begin
    if(rst ==`RstEnable) begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o   <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstVaild;
        reg1_read_o <= 1'b0;
        reg2_addr_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
		link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;
		next_inst_in_delayslot_o <= `NotInDelaySlot;	
		sa2 <= 3'b00;
    end else begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o   <= inst_i[4:0];
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvaild;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[9:5];//default read from regfile pole one
        reg2_addr_o <= inst_i[14:10];//default read from regfile pole two
        imm <= `ZeroWord; 
		link_addr_o <= `ZeroWord;
		branch_target_address_o <= `ZeroWord;
		branch_flag_o <= `NotBranch;	
		next_inst_in_delayslot_o <= `NotInDelaySlot; 
		sa2 <= 3'b00;
	//	excepttype_is_syscall <= `False_v;
	//	excepttype_is_eret <= `False_v;

	case(op6)
	  6'b000000:begin
	    case(op21)
		   2'b00:begin
            case(op22)
		      2'b00:begin
                case(op23)
				 2'b00 :begin
                   case(op24)
                     2'b00:begin 
					   case(op3) 
					   3'b000 :begin
                       case(op5)
                         `EXE_CLO:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_CLO_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_CLZ:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_CLZ_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_CTO:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_CTO_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_CTZ:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_CTZ_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end       
						 `EXE_EXTWB:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_EXTWB_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_EXTWH:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_EXTWH_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_REVB:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_REVB_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_BITREV4B:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_BITREV4B_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_BITREVW:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_BITREVW_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b0;
		  				   instvalid <= `InstValid;
						 end 
					   default:begin
					   end
					   endcase//op5  
					  end //op3 3'b000
					  default:begin
					  end 
					  endcase //op3
					 end //op24 2'b00 
				   default:begin
				   end
				   endcase//op24
				end//op23 2'b00 
                 2'b01 :begin
                   case(op24) 
				     2'b00:begin
                       case(op3)
                         `EXE_ADD:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_ADD_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_SUB:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_SUB_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_SLT:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_SLT_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
                         `EXE_SLTU:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_SLTU_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_MASKEQZ:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_MASKEQZ_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_MASKNEZ:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_MASKNEZ_OP;
		  				   alusel_o <= `EXE_RES_ARITHMETIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;
		  				   instvalid <= `InstValid;
						 end 
					   default:begin
					   end 
					   endcase//op3 
					 end//op24 2'b00 
                     2'b01:begin
	                   case(op3)
                         `EXE_NOR:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_NOR_OP;	
						   alusel_o <= `EXE_RES_LOGIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;	
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_AND:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_AND_OP;	
						   alusel_o <= `EXE_RES_LOGIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;	
		  				   instvalid <= `InstValid;
						 end 
						 `EXE_XOR:begin
                           wreg_o <= `WriteEnable;		
						   aluop_o <= `EXE_XOR_OP;
		  				   alusel_o <= `EXE_RES_LOGIC;		
						   reg1_read_o <= 1'b1;	
						   reg2_read_o <= 1'b1;	
		  				   instvalid <= `InstValid;	 
						 end 
						 `EXE_OR:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_OR_OP;
		  				  alusel_o <= `EXE_RES_LOGIC; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end 
						 `EXE_ANDN:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_ANDN_OP;
		  				  alusel_o <= `EXE_RES_LOGIC; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end 
						 `EXE_ORN:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_ORN_OP;
		  				  alusel_o <= `EXE_RES_LOGIC; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end 
						 `EXE_SLLW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SLL_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end
						 `EXE_SRLW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SRL_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end 
					   default:begin
					   end 
					   endcase//op3
					end//op24 2'b01 
                     2'b10 :begin
                       case(op3) 
						 `EXE_SRAW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SRA_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b1;
		  				  instvalid <= `InstValid;
						 end 
						 `EXE_ROTRW:begin
                          wreg_o <= `WriteEnable;
						  aluop_o <= `EXE_ROTR_OP;
						  alusel_o <= `EXE_RES_SHIFT;
						  reg1_read_o <= 1'b1;
						  reg2_read_o <= 1'b1;
						  instvalid <= `InstValid;
						 end 
					   default:begin
					   end 
					   endcase//op3 
					 end //op24 2'b10 
					 2'b11 :begin
                       case(op3)
					     `EXE_MULW:begin
                          wreg_o <= `WriteEnable;
						  aluop_o <= `EXE_MULW_OP;
						  alusel_o <= `EXE_RES_ARITHMETIC;
						  reg1_read_o <= 1'b1;
						  reg2_read_o <= 1'b1;
						  instvalid <= `InstValid;
						 end
					     `EXE_MULHW:begin
                          wreg_o <= `WriteEnable;
						  aluop_o <= `EXE_MULHW_OP;
						  alusel_o <= `EXE_RES_ARITHMETIC;
						  reg1_read_o <= 1'b1;
						  reg2_read_o <= 1'b1;
						  instvalid <= `InstValid;
						 end
					     `EXE_MULHWU:begin
                          wreg_o <= `WriteEnable;
						  aluop_o <= `EXE_MULHWU_OP;
						  alusel_o <= `EXE_RES_ARITHMETIC;
						  reg1_read_o <= 1'b1;
						  reg2_read_o <= 1'b1;
						  instvalid <= `InstValid;
						 end
					   default:begin
					   end 
					   endcase //op3 
					 end  //op24 2'b11
				   default:begin
				   end 
				   endcase//op23
				 end  //op24 2'b11
				   2'b10:begin
                    case(op24)
                      2'b00:begin
                        case(op3)
                          `EXE_DIVW:begin
                            wreg_o <= `WriteEnable;
							aluop_o <= `EXE_DIVW_OP;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid   <= `InstValid;
						  end 
                          `EXE_DIVWU:begin
                            wreg_o <= `WriteEnable;
							aluop_o <= `EXE_DIVWU_OP;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid   <= `InstValid;
						  end 
                          `EXE_MODW:begin
                            wreg_o <= `WriteEnable;
							aluop_o <= `EXE_MODW_OP;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid   <= `InstValid;
						  end 
                          `EXE_MODWU:begin
                            wreg_o <= `WriteEnable;
							aluop_o <= `EXE_MODWU_OP;
							reg1_read_o <= 1'b1;
							reg2_read_o <= 1'b1;
							alusel_o <= `EXE_RES_ARITHMETIC;
							instvalid   <= `InstValid;
						  end 
						default:begin
						end 
						endcase //op3
					  end //op24 2'b00
					default:begin
					end 
					endcase //op24
				 end //op23 2'b01
				default:begin
				end 
				endcase//op23
			  end //op22 2'b00 
			   2'b01:begin
                 case(op23)
				   2'b00 :begin
                     case(op24)
                       2'b00:begin
                          case(op3)
						 `EXE_SLLIW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SLL_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b0;
						  imm[4:0] <= inst_i[14:10];
		  				  instvalid <= `InstValid;
						 end 
						  default:begin
						  end
						  endcase//op3 
					   end//op24 2'b00 
                       2'b01:begin
                          case(op3)
						 `EXE_SRLIW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SRL_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b0;
						  imm[4:0] <= inst_i[14:10]; 
		  				  instvalid <= `InstValid;
						 end 
						  default:begin
						  end
						  endcase//op3 
					   end//op24 2'b01
                       2'b10:begin
                          case(op3)
						 `EXE_SRAIW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_SRA_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b0;
						  imm[4:0] <= inst_i[14:10];
		  				  instvalid <= `InstValid;
						 end 
						  default:begin
						  end
						  endcase//op3 
					   end//op24 2'b10 
                       2'b11:begin
                          case(op3)
						 `EXE_SRAIW:begin
                          wreg_o <= `WriteEnable;	
						  aluop_o <= `EXE_ROTR_OP;
		  				  alusel_o <= `EXE_RES_SHIFT; 	
						  reg1_read_o <= 1'b1;	
						  reg2_read_o <= 1'b0;
						  imm[4:0] <= inst_i[14:10];
		  				  instvalid <= `InstValid;
						 end 
						  default:begin
						  end
						  endcase//op3 
					   end//op24 2'b10 
					 default:begin
					 end 
					 endcase//op23 
				   end //op23 2'b00 
				 default:begin
				 end 
				 endcase//op23 
			   end //op22 2'b01 
			  default:begin
			  end 
			  endcase//op22
		   end//op21 2'b00 
		   2'b10:begin
            case(op22)
              `EXE_ADDI:begin
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_ADDI_OP;
				alusel_o <= `EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {{20{inst_i[21]}},inst_i[21:10]};
                instvalid <= `InstVaild;
			  end 
              `EXE_SLTI:begin
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_SLT_OP;
				alusel_o <= `EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {{20{inst_i[21]}},inst_i[21:10]};
                instvalid <= `InstVaild;
			  end 
              `EXE_SLTUI:begin
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_SLTU_OP;
				alusel_o <= `EXE_RES_ARITHMETIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {{20{inst_i[21]}},inst_i[21:10]};
                instvalid <= `InstVaild;
			  end 
			default:begin
			end 
			endcase//op22 
		   end //op21 2'b10 
           2'b11:begin
		    case(op22)
			  `EXE_ORI:begin 
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_OR_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {20'h0,inst_i[21:10]};
                instvalid <= `InstVaild;
		        end	 
		        `EXE_ANDI:begin 
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_AND_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {20'h0,inst_i[21:10]};
                instvalid <= `InstVaild;
	            end
		        `EXE_XORI:begin 
			    wreg_o <= `WriteEnable;
				aluop_o <= `EXE_XOR_OP;
				alusel_o <= `EXE_RES_LOGIC;
				reg1_read_o <= 1'b1;
				reg2_read_o <= 1'b0;
				imm <= {20'h0,inst_i[21:10]};
                instvalid <= `InstVaild;
				end 
			  default:begin
			  end 
			  endcase//op22 
	      end //`EXE_AOX_TYPE
		default:begin
		end 
		endcase//`op21
	    end //op6 6'b000000 
		 6'b001010:begin
            case(op21)
			  2'b00:begin
                case(op22)
				  `EXE_LDB:begin
                  wreg_o <= `WriteEnable;
				  aluop_o <= `EXE_LDB_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b0;
				  instvalid <= `InstValid;
				  end 
				  `EXE_LDH:begin 
				  wreg_o <= `WriteEnable;
				  aluop_o <= `EXE_LDH_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b0;
				  instvalid <= `InstValid;
				  end 
				  `EXE_LDW:begin
                  wreg_o <= `WriteEnable;
				  aluop_o <= `EXE_LDW_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b0;
				  instvalid <= `InstValid;
				  end 

				
				 
				default:begin
				end 
				endcase//op22 
			  end  //op21 2'b00 
			  2'b01:begin
                case(op22)
				  
				  `EXE_STB:begin
                  wreg_o <= `WriteDisable;
				  aluop_o <= `EXE_STB_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b1;
				  reg2_addr_o <= inst_i[4:0];
				  instvalid <= `InstValid;
				  end 
				  `EXE_STH:begin
				  wreg_o <= `WriteDisable;
				  aluop_o <= `EXE_STH_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b1;
				  reg2_addr_o <= inst_i[4:0];
				  instvalid <= `InstValid;
				  end 
				  `EXE_STW:begin
                  wreg_o <= `WriteDisable;
				  aluop_o <= `EXE_STW_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b1;
				  reg2_addr_o <= inst_i[4:0];
				  instvalid <= `InstValid;
				  end 
				default:begin
				end 
				endcase//op22
			  end //op21 2'b01
            2'b10:begin
              case(op22)
				  `EXE_LDBU:begin 
				  wreg_o <= `WriteEnable;
				  aluop_o <= `EXE_LDBU_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b0;
				  instvalid <= `InstValid;
				  end 
				  `EXE_LDHU:begin
                  wreg_o <= `WriteEnable;
				  aluop_o <= `EXE_LDHU_OP;
				  alusel_o <= `EXE_RES_LOAD_STORE;
				  reg1_read_o <= 1'b1;
				  reg2_read_o <= 1'b0;
				  instvalid <= `InstValid;
				  end 
			  default:begin
			  end 
			  endcase //op22
			end//op21 2'b10 
			default:begin
			end 
			endcase//op21
		 end//op6 6'b001010 
		 6'b001000 :begin 
		   case(op21)
             `EXE_LL :begin
               wreg_o <= `WriteEnable;
			   aluop_o <= `EXE_LL_OP;
			   alusel_o <= `EXE_RES_LOAD_STORE;
			   reg1_read_o <= 1'b1;
			   reg2_read_o <= 1'b0;
			   instvalid  <= `InstValid;
			 end 
             `EXE_SC:begin
               wreg_o <= `WriteEnable;
			   aluop_o <= `EXE_SC_OP;
			   alusel_o <= `EXE_RES_LOAD_STORE;
			   reg1_read_o <= 1'b1;
			   reg2_read_o <= 1'b1;
			   reg2_addr_o <= inst_i[4:0];
			   instvalid  <= `InstValid;
			 end 
		   default:begin
		   end 
		   endcase //op21

		 end  //op6 6'b001000
		`EXE_B:begin
          wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_B_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b0;
		  reg2_read_o <= 1'b0;
		  link_addr_o <= `ZeroWord;
		  branch_flag_o <= `Branch;
		  next_inst_in_delayslot_o <= `InDelaySlot;
		  instvalid <= `InstValid;
		  branch_target_address_o <= pc_i + {{8{inst_i[7]}},inst_i[7:0],inst_i[25:10],2'b00};
		end 
		`EXE_BL:begin
          wreg_o <= `WriteEnable;
		  aluop_o <= `EXE_BL_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b0;
		  reg2_read_o <= 1'b0;
		  wd_o <= 5'b00001;
		  link_addr_o <= pc_plus_4;
		  branch_flag_o <= `Branch;
		  next_inst_in_delayslot_o <= `InDelaySlot;
		  instvalid <= `InstValid;
		  branch_target_address_o <= pc_i + {{8{inst_i[7]}},inst_i[7:0],inst_i[25:10],2'b00};
		end 
		`EXE_JIRL:begin
          wreg_o <= `WriteEnable;
		  aluop_o <= `EXE_JIRL_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b0;
		  link_addr_o <= pc_plus_4;
		  branch_flag_o <= `Branch;
		  next_inst_in_delayslot_o <= `InDelaySlot;
		  instvalid <= `InstValid;
		  branch_target_address_o <= reg1_o + {{16{inst_i[23]}},inst_i[23:10],2'b00};
		end 
		`EXE_BEQ:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BEQ_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild;
		  if(reg1_o == reg2_o)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BNE:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BNE_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild;
		  if(reg1_o != reg2_o)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BLT:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BLT_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild; 
		  compare_we <= 1'b1;
		  compare_sign <= 1'b1;
		  if(compare_result == 1)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BGE:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BGE_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild; 
		  compare_we <= 1'b1;
		  compare_sign <= 1'b1;
		  if(compare_result == 1'b0)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BLTU:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BLTU_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild; 
		  compare_we <= 1'b1;
		  compare_sign <= 1'b0;
		  if(compare_result == 1'b1)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BGEU:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BGEU_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b1;
		  reg2_addr_o <= inst_i[4:0];
		  instvalid   <= `InstVaild; 
		  compare_we <= 1'b1;
		  compare_sign <= 1'b0;
		  if(compare_result == 1'b0)begin
            branch_target_address_o <= pc_i + {{16{inst_i[23]}},inst_i[23:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BEQZ:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BEQZ_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b0;
		  instvalid   <= `InstVaild;
		  if(reg1_o == 1'b0)begin
            branch_target_address_o <= pc_i + {{11{inst_i[2]}},inst_i[2:0],inst_i[25:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 
		`EXE_BNEZ:begin
		  wreg_o <= `WriteDisable;
		  aluop_o <= `EXE_BNEZ_OP;
		  alusel_o <= `EXE_RES_JUMP_BRANCH;
		  reg1_read_o <= 1'b1;
		  reg2_read_o <= 1'b0;
		  instvalid   <= `InstVaild;
		  if(reg1_o != 1'b0)begin
            branch_target_address_o <= pc_i + {{11{inst_i[2]}},inst_i[2:0],inst_i[25:10],2'b00};
			branch_flag_o <= `Branch;
			next_inst_in_delayslot_o <= `InDelaySlot;
		  end 
		end 

	  
	default:begin
	end 
	endcase//op6  

	  if(inst_i[31:25] == 7'b0001010)begin
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_LUI_OP;
		alusel_o <= `EXE_RES_SHIFT;
		reg1_read_o <= 1'b0;
		reg2_read_o <= 1'b1;
		imm <= inst_i[24:5];
		instvalid <= `InstValid;
	  end else if(inst_i[31:17] == 15'b000000000000010)begin 
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_ALSL_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b1; 
		sa2[1:0]   <= inst_i[16:15];
		instvalid <= `InstValid;
	  end else if(inst_i[31:25] == 7'b0001100)begin
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_PCADDI_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b0; 
		imm    <= {{10{inst_i[24]}},inst_i[24:5],2'b0};
		instvalid <= `InstValid;
	  end else if(inst_i[31:25] == 7'b0001101)begin
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_PCALAU_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b0; 
		imm    <= {inst_i[24:5],12'b0};
		instvalid <= `InstValid;
	  end else if(inst_i[31:25] == 7'b0001110)begin
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_PCADDU_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b0; 
		imm    <= {inst_i[24:5],12'b0};
		instvalid <= `InstValid;
	  end else if(inst_i[31:18] == 14'b00000000000010) begin
        wreg_o <= `WriteEnable;
		aluop_o <=`EXE_BYTEPICK_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_read_o <= 1'b1;
		sa2 <= {1'b0,inst_i[16:15]};
		instvalid <= `InstValid;
	  end else if(inst_i[31:21] == 11'b00000000011 & inst_i[15] == 0) begin
        wreg_o <= `WriteEnable;
		aluop_o <= `EXE_BSTRINSW_OP;
		alusel_o <= `EXE_RES_ARITHMETIC;
		reg1_read_o <= 1'b1;
		reg2_addr_o <= inst_i[4:0];
		reg2_read_o <= 1'b1;
		instvalid <= `InstValid;
	  end else if(inst_i[31:21] == 11'b00000000011 & inst_i[15] == 1) begin
        wreg_o = `WriteEnable;
		aluop_o = `EXE_BSTRPICKW_OP;
		alusel_o = `EXE_RES_ARITHMETIC;
		reg1_read_o = 1'b1;
		reg2_read_o = 1'b0;
		instvalid = `InstValid;
	  end 
	  
	end //if 
end//always
 
 always @(*) begin
   stallreq_for_reg1_loadrelate <=`NoStop;
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o 	&& reg1_read_o == 1'b1 ) begin
		  stallreq_for_reg1_loadrelate <= `Stop;	 
    end	else if((reg1_read_o==1)&&(ex_wreg_i==1)&&(reg1_addr_o==ex_wd_i))begin
	    reg1_o <= ex_wdata_i;
    end else if((reg1_read_o==1)&&(mem_wreg_i==1)&&(reg1_addr_o==mem_wd_i))begin
	    reg1_o <= mem_wdata_i;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i; // Regfile Readone as input
    end else if (reg1_read_o == 1'b0) begin
        reg1_o <= imm; //imediate num
    end else begin
        reg1_read_o <=`ZeroWord;
    end
end
//stage three : confirm source data two
always @(*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
	end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o 	&& reg2_read_o == 1'b1 ) begin
		stallreq_for_reg2_loadrelate <= `Stop;				
    end else if((reg2_read_o==1)&&(ex_wreg_i==1)&&(reg2_addr_o==ex_wd_i))begin
	    reg2_o <= ex_wdata_i;
    end else if((reg2_read_o==1)&&(mem_wreg_i==1)&&(reg2_addr_o==mem_wd_i))begin
	    reg2_o <= mem_wdata_i;
	end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i; // Regfile Readone as input
    end else if (reg2_read_o == 1'b0) begin
        reg2_o <= imm; //imediate num
    end else begin
        reg2_read_o <=`ZeroWord;
    end
end 

assign stallreq = stallreq_for_reg1_loadrelate ||stallreq_for_reg2_loadrelate;
  always@(*) begin
    if(rst == `RstEnable) begin
	    is_in_delayslot_o <= `NotInDelaySlot;
	end else begin
	  is_in_delayslot_o <=is_in_delayslot_i;
	end 
  end 
endmodule
   
module id_ex (
    input wire   clk,
    input wire   rst,
    //message from decode
    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
	input wire[2:0] id_sa2,
	input wire[`InstAddrBus]id_pc,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
	input wire[5:0]     stall,
	input wire[`RegBus]           id_link_address,
	input wire                    id_is_in_delayslot,
	input wire                    next_inst_in_delayslot_i,	

	input wire [`RegBus] id_inst,

	input wire flush,

	input wire [`RegBus] id_current_inst_address,
	input wire [31:0]    id_excepttype,
	
    //output to execute stage
    
	

	output reg[`RegBus] ex_current_inst_address,
	output reg[`RegBus] ex_excepttype,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
	output reg[2:0] ex_sa2,
	output reg[`InstAddrBus]ex_pc,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`RegBus]           ex_link_address,
    output reg                    ex_is_in_delayslot,
	output reg                    is_in_delayslot_o,

	output reg [`RegBus] ex_inst
);
    	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_link_address <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	        is_in_delayslot_o <= `NotInDelaySlot;
		    ex_excepttype <= `ZeroWord;
			ex_current_inst_address <=`ZeroWord;
			ex_sa2[1:0] <= 2'b00;
			ex_pc <= `ZeroWord;
       end else if(flush == 1'b1 ) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
			ex_excepttype <= `ZeroWord;
			ex_link_address <= `ZeroWord;
			ex_inst <= `ZeroWord;
			ex_is_in_delayslot <= `NotInDelaySlot;
	        ex_current_inst_address <= `ZeroWord;	
	        is_in_delayslot_o <= `NotInDelaySlot;	
			ex_sa2[1:0]<= 2'b00;
			ex_pc <= `ZeroWord;
		end else if(stall[2] == `Stop && stall[3] == `NoStop) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wd <= `NOPRegAddr;
			ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
	        ex_is_in_delayslot <= `NotInDelaySlot;			
			ex_excepttype <= `ZeroWord;
			ex_current_inst_address <= `ZeroWord;
			ex_sa2[1:0] <= 2'b00;
			ex_pc <= `ZeroWord;
		end else if(stall[2] == `NoStop) begin		
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wd <= id_wd;
			ex_wreg <= id_wreg;		
			ex_link_address <= id_link_address;
			ex_is_in_delayslot <= id_is_in_delayslot;
	        is_in_delayslot_o <= next_inst_in_delayslot_i;
			ex_inst <= id_inst;
			ex_excepttype <= id_excepttype;
			ex_current_inst_address <= id_current_inst_address;
			ex_sa2[2:0] <=  id_sa2[2:0];
			ex_pc <= id_pc;
		end
	end
    
endmodule

  module ex(
    input wire rst,
	
	input [`AluOpBus] aluop_i,
	input [`AluSelBus]alusel_i,
	input [`RegBus] reg1_i,
	input [`RegBus] reg2_i,
	input [`RegAddrBus] wd_i,
	input wreg_i, 
	input [2:0]sa2_i,
	input [`InstAddrBus]pc_i,

	input [31:0]cl_i, 

	output reg cl_start_o,
	output reg [31:0]cl_o,

	input wire[`DoubleRegBus]     div_result_i,
	input wire                    div_ready_i,

	input wire[`RegBus]           link_address_i,
	input wire                    is_in_delayslot_i,
		
	input wire[`RegBus] inst_i,

		input wire                    mem_cp0_reg_we,
		input wire[4:0]               mem_cp0_reg_write_addr,
		input wire[`RegBus]           mem_cp0_reg_data,

		input wire                    wb_cp0_reg_we,
		input wire[4:0]               wb_cp0_reg_write_addr,
		input wire[`RegBus]           wb_cp0_reg_data,
		
		input wire[31:0]              excepttype_i,
		input wire[`RegBus]          current_inst_address_i,
		
		input wire[`RegBus]           cp0_reg_data_i,
		output reg[4:0]               cp0_reg_read_addr_o,

		output reg                    cp0_reg_we_o,
		output reg[4:0]               cp0_reg_write_addr_o,
		output reg[`RegBus]           cp0_reg_data_o,


		output reg [`RegAddrBus]wd_o,
		output reg wreg_o,
		output reg [`RegBus] wdata_o,

		output reg[`RegBus]           div_opdata1_o,
		output reg[`RegBus]           div_opdata2_o,
		output reg                    div_start_o,
		output reg                    signed_div_o,

		output wire[`AluOpBus] aluop_o,
		output wire[`RegBus]   mem_addr_o,
		output wire[`RegBus]   reg2_o,

		output wire[31:0]             excepttype_o,
		output wire                   is_in_delayslot_o,
		output wire[`RegBus]          current_inst_address_o,

		output reg					stallreq     		
		
		);

		reg [`RegBus] logicout;
		reg [`RegBus] shiftres;
		reg [`RegBus] moveres;
		reg [`RegBus] HI;
		reg [`RegBus] LO;
        
		wire [4:0]msbw,lsbw; 
    
		wire ov_sum;
		wire reg1_eg_reg2;
		wire reg1_lt_reg2;
		reg [`RegBus] arithmeticres;
		wire [`RegBus] reg2_i_mux;
		wire [`RegBus] reg1_i_not;
		wire [`RegBus] reg1_i_mux;
		wire [`RegBus]  result_sum;
		wire [`RegBus] opdata1_mult;
		wire [`RegBus] opdata2_mult;
		wire [`DoubleRegBus] hilo_temp;
		reg  [`DoubleRegBus] mulres;
		//bytepick
		wire [`DoubleRegBus] reg1_i_reg2_i;

		reg stallreq_for_div;

		reg trapassert;
		reg ovassert; 

		reg mul_we_o,mul_sign_o;
		wire [67:0]mul_result_i;
		mul mul1(.mul_a_i(reg1_i),.mul_b_i(reg2_i),.mul_we(mul_we_o),.mul_sign(mul_sign_o),.mul_result_o(mul_result_i));

        assign   lsbw = inst_i[14:10];
		assign   msbw = inst_i[20:16];

		assign inst_o = inst_i;

		assign reg1_i_reg2_i = {reg2_i,reg1_i};

		assign excepttype_o = {excepttype_i[31:12],ovassert,trapassert,excepttype_i[9:8],8'h00};
		
		assign is_in_delayslot_o = is_in_delayslot_i;

		assign current_inst_address_o = current_inst_address_i;
	   
		assign reg1_i_mux = ((aluop_i == `EXE_PCALAU_OP)||(aluop_i == `EXE_PCADDU_OP)||(aluop_i == `EXE_PCADDI_OP))?
							  pc_i:((aluop_i == `EXE_ALSL_OP) ? (reg1_i << (sa2_i + 3'b01)) :reg1_i);

		assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP)||
							 (aluop_i == `EXE_SLT_OP)||
							 (aluop_i == `EXE_TLT_OP)||
							 (aluop_i == `EXE_TGE_OP )) ?
							 (~reg2_i)+1 : reg2_i;
		
		assign result_sum = reg1_i_mux+reg2_i_mux;
		
		assign ov_sum = ((!reg1_i[31]&&!reg2_i_mux[31])&&result_sum[31])||
				   ((reg1_i[31] && reg2_i_mux[31])&& (!result_sum[31]));

		assign reg1_lt_reg2 = ( (aluop_i == `EXE_SLT_OP)||
								(aluop_i == `EXE_TLT_OP)||
								(aluop_i == `EXE_TGE_OP)) ?
													( (reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum) || (reg1_i[31] && reg2_i[31] && result_sum)  ) :
													( reg1_i < reg2_i );
		assign reg1_i_not = ~ reg1_i;
		
		assign aluop_o = aluop_i;
		assign reg2_o = reg2_i;
		assign mem_addr_o =( (alusel_i == `EXE_LL_OP) || 
		                     (alusel_i == `EXE_SC_OP)) ? (reg1_i + {{8{inst_i[23]}},inst_i[23:12],2'b00}): (reg1_i + {{20{inst_i[21]}},inst_i[21:10]});

		always @(*)begin
		  if(rst == `RstEnable)begin
		  trapassert <=`TrapNotAssert;
		end else begin
		  trapassert <= `TrapNotAssert; 
		case(aluop_i)
		  `EXE_TEQ_OP:begin
			 if(reg1_i == reg2_i)begin
				trapassert <= `TrapAssert;
			 end
		  end 

		  `EXE_TGE_OP,`EXE_TGEU_OP:begin
			 if(~reg1_lt_reg2)begin
				trapassert <= `TrapAssert;
			 end 
		  end 
		  `EXE_TLT_OP,`EXE_TLTU_OP:begin
			 if(reg1_lt_reg2) begin
				trapassert <= `TrapAssert;
			 end 
		  end 
		  `EXE_TNE_OP:begin
			 if(reg1_i != reg2_i)begin
				trapassert <= `TrapAssert;
			 end 
		  end 
		default:begin
		  trapassert <= `TrapNotAssert;
		end 
		endcase
	 end  
	end 


		always @ (*) begin
			if(rst == `RstEnable) begin
			  moveres <= `ZeroWord;
		  end else begin
			 moveres <= `ZeroWord;
		   case (aluop_i)
			`EXE_MFC0_OP:		begin
			  cp0_reg_read_addr_o <= inst_i[15:11];
				moveres <= cp0_reg_data_i;
				if( mem_cp0_reg_we == `WriteEnable &&
					mem_cp0_reg_write_addr == inst_i[15:11] ) begin
					moveres <= mem_cp0_reg_data;
				end else if( wb_cp0_reg_we == `WriteEnable &&
							wb_cp0_reg_write_addr == inst_i[15:11] ) begin
					moveres <= wb_cp0_reg_data;
				end
			end	   	
			default : begin
			end
		   endcase
		  end
		end	 



		always@(*)begin
		  if(rst == `RstEnable)begin
			cl_start_o <= 1'b0;
			cl_o <= `ZeroWord;
		  end else begin
			cl_start_o <= 1'b0;
			cl_o <= `ZeroWord;
		  case(aluop_i)
			`EXE_CLZ_OP,`EXE_CLO_OP,`EXE_CTO_OP,`EXE_CTZ_OP:begin
			cl_o <= reg1_i;
			cl_start_o <= 1'b1;
			end 
		  default:begin
		  end
		  endcase
		 end 
		end 
		always@(*) begin
		if(rst == `RstEnable)begin
		  stallreq_for_div <= `NoStop;
		  div_opdata1_o <= `ZeroWord;
		  div_opdata2_o <=`ZeroWord;
		  div_start_o <= `DivStop;
		  signed_div_o <= 1'b0;
		end else begin
		  stallreq_for_div <= `NoStop;
		  div_opdata1_o <= `ZeroWord;
		  div_opdata2_o <=`ZeroWord;
		  div_start_o <= `DivStop;
		  signed_div_o <= 1'b0;
		  case(aluop_i)
			`EXE_DIVW_OP,`EXE_MODW_OP: begin
			  if(div_ready_i == `DivResultNoReady) begin
				div_opdata1_o <= reg1_i;
				div_opdata2_o <= reg2_i;
				div_start_o <= `DivStart;
				signed_div_o <=1'b1;
				stallreq_for_div <=`Stop;
			  end else if(div_ready_i == `DivResultReady) begin
				div_opdata1_o <= reg1_i;
				div_opdata2_o <= reg2_i;
				div_start_o <= `DivStop;
				signed_div_o <= 1'b1;
				stallreq_for_div <= `NoStop;
			  end else begin
				div_opdata1_o <= `ZeroWord;
				div_opdata2_o <= `ZeroWord;
				div_start_o <= `DivStop;
				signed_div_o <= 1'b0;
				stallreq_for_div <= `NoStop;
			 end
			end
			 `EXE_DIVWU_OP,`EXE_MODWU_OP:		begin
				if(div_ready_i == `DivResultNoReady) begin
					div_opdata1_o <= reg1_i;
					div_opdata2_o <= reg2_i;
					div_start_o <= `DivStart;
					signed_div_o <= 1'b0;
					stallreq_for_div <= `Stop;
				end else if(div_ready_i == `DivResultReady) begin
					div_opdata1_o <= reg1_i;
					div_opdata2_o <= reg2_i;
					div_start_o <= `DivStop;
					signed_div_o <= 1'b0;
					stallreq_for_div <= `NoStop;
				end else begin						
					div_opdata1_o <= `ZeroWord;
					div_opdata2_o <= `ZeroWord;
					div_start_o <= `DivStop;
					signed_div_o <= 1'b0;
					stallreq_for_div <= `NoStop;
				end					
			end
			default: begin
					 end
		endcase
	end
		end	
				
			
		always@(*) begin
		  if(rst == `RstEnable) begin
			arithmeticres <= 0;
		end else begin
		  case(aluop_i)
			`EXE_SLT_OP,`EXE_SLTU_OP :begin
			  arithmeticres <= reg1_lt_reg2;
			end
			`EXE_ADD_OP,`EXE_ADDI_OP :begin
			  arithmeticres <= result_sum ;
			end
			`EXE_SUB_OP   :begin
			  arithmeticres <= result_sum ;
			end 
			`EXE_ALSL_OP :begin
			  arithmeticres <= result_sum;
			end 
			`EXE_PCADDI_OP: begin
			  arithmeticres <= result_sum;
			end 
			`EXE_PCADDU_OP:begin
			  arithmeticres <= result_sum;
			end 
			`EXE_PCALAU_OP:begin
			  arithmeticres <= {result_sum[31:12],12'b0};
			end 
			`EXE_CLO_OP :begin
			  arithmeticres <= (reg1_i == 32'b11111111111111111111111111111111) ? {26'b00,1'b1,5'b00}:cl_i; 
			end
			`EXE_CLZ_OP :begin 
			  arithmeticres <= (reg1_i == 32'b00000000000000000000000000000000) ? {26'b00,1'b1,5'b00}:cl_i; 
									end
			`EXE_CTO_OP :begin
			  arithmeticres <= (reg1_i == 32'b11111111111111111111111111111111) ? {26'b00,1'b1,5'b00}:cl_i; 
			end
			`EXE_CTZ_OP :begin 
			  arithmeticres <= (reg1_i == 32'b00000000000000000000000000000000) ? {26'b00,1'b1,5'b00}:cl_i; 
			end
			`EXE_EXTWB_OP  :begin
			  arithmeticres <= {{24{reg1_i[7]}},reg1_i[7:0]};
			end 
			`EXE_EXTWH_OP  :begin
			  arithmeticres <= {{16{reg1_i[15]}},reg1_i[15:0]};
			end 
			`EXE_BYTEPICK_OP:begin
			  arithmeticres <= (sa2_i == 3'b000)? reg1_i_reg2_i[63:32] : (sa2_i == 3'b01)? reg1_i_reg2_i[55:24] : 
							   (sa2_i == 3'b010)? reg1_i_reg2_i [47:16] : (sa2_i == 3'b011) ? reg1_i_reg2_i[39:8] : `ZeroWord;
			end 
			`EXE_REVB_OP   :begin
			  arithmeticres = {reg1_i[23:16],reg1_i[31:24],reg1_i[7:0],reg1_i[15:8]};
			end 
			`EXE_BITREV4B_OP:begin
			  arithmeticres = {reg1_i[24],reg1_i[25],reg1_i[26],reg1_i[27],reg1_i[28],reg1_i[29],reg1_i[30],reg1_i[31],
								reg1_i[16],reg1_i[17],reg1_i[18],reg1_i[19],reg1_i[20],reg1_i[21],reg1_i[22],reg1_i[23],
								reg1_i[8],reg1_i[9],reg1_i[10],reg1_i[11],reg1_i[12],reg1_i[13],reg1_i[14],reg1_i[15],
								reg1_i[0],reg1_i[1],reg1_i[2],reg1_i[3],reg1_i[4],reg1_i[5],reg1_i[6],reg1_i[7]}; 
			end 
			`EXE_BITREVW_OP:begin
			  arithmeticres = 	{reg1_i[0],reg1_i[1],reg1_i[2],reg1_i[3],reg1_i[4],reg1_i[5],reg1_i[6],reg1_i[7], 
								reg1_i[8],reg1_i[9],reg1_i[10],reg1_i[11],reg1_i[12],reg1_i[13],reg1_i[14],reg1_i[15],
								reg1_i[16],reg1_i[17],reg1_i[18],reg1_i[19],reg1_i[20],reg1_i[21],reg1_i[22],reg1_i[23],
								reg1_i[24],reg1_i[25],reg1_i[26],reg1_i[27],reg1_i[28],reg1_i[29],reg1_i[30],reg1_i[31]};
			end 
			`EXE_MASKEQZ_OP:begin
			  arithmeticres = (reg2_i == 0)? 0 : reg1_i;
			end
			`EXE_MASKNEZ_OP:begin
			  arithmeticres = (reg2_i != 0)? 0 : reg1_i;
			end 
			`EXE_BSTRPICKW_OP:begin
			  arithmeticres = (reg1_i << (5'b11111 - msbw))>> (5'b11111 - msbw + lsbw) ;
			end 
			`EXE_BSTRINSW_OP:begin
              arithmeticres = ((reg1_i << (5'b11111 - (msbw - lsbw))) >> (5'b11111 - msbw)) |
			                  (( (reg2_i >> (msbw+1)) << (msbw+1)) | ((reg2_i << (5'b11111 - lsbw + 1)) >> (5'b11111 - lsbw+1)));
			end
			`EXE_MULW_OP :begin
              mul_we_o <= 1'b1;
			  mul_sign_o <= 1'b1;
			  arithmeticres <= mul_result_i[31:0];
			end
			`EXE_MULHW_OP :begin
              mul_we_o <= 1'b1;
			  mul_sign_o <= 1'b1;
			  arithmeticres <= mul_result_i[63:32];
			end
			`EXE_MULHWU_OP :begin
              mul_we_o <= 1'b1;
			  mul_sign_o <= 1'b0;
			  arithmeticres <= mul_result_i[63:32];
			end 
			`EXE_DIVW_OP:begin
              arithmeticres <= div_result_i[31:0];
			end 
			`EXE_DIVWU_OP:begin
              arithmeticres <= div_result_i[31:0];
			end 
			`EXE_MODW_OP:begin
              arithmeticres <= div_result_i[63:32];
			end 
			`EXE_MODWU_OP:begin
              arithmeticres <= div_result_i[63:32];
			end 
		  default :begin
		  end
		  endcase
		end
		end
		always @(*)begin
		  stallreq = stallreq_for_div;
		end
		
		always@(*)
		  begin
			if(rst == 1)
			  begin
				logicout <= 0;
			  end
			else
			  begin
				case(aluop_i)
				  `EXE_OR_OP: begin
					logicout <= reg1_i|reg2_i;
							  end
				  `EXE_XOR_OP: begin
					logicout <= reg1_i^reg2_i;
							  end
				  `EXE_AND_OP: begin
					logicout <= reg1_i&reg2_i;
							  end 
				  `EXE_NOR_OP:begin
					logicout <= ~(reg1_i|reg2_i);
							  end 
				  `EXE_ANDN_OP:begin
					logicout <= reg1_i&(~reg2_i);
							  end 
				  `EXE_ORN_OP:begin
					logicout <= reg1_i|(~reg2_i);
				  end
				  default:begin
					logicout <= 0;
							end 
				endcase
			  end
		 end
		always@(*)
		  begin
			if(rst == 1)
			  begin
				logicout <= 0;
			  end
			else
			  begin
				case(aluop_i)
				  `EXE_SLL_OP: begin
					shiftres <= reg1_i<<reg2_i[4:0];
							  end
				  `EXE_SRL_OP: begin
					shiftres <= reg1_i>>reg2_i[4:0];
							  end
				  `EXE_SRA_OP: begin
					shiftres <= ({32{reg1_i[31]}}<<(6'd32-{1'b0,reg2_i[4:0]}))|reg1_i>>reg2_i[4:0];
							  end
				  `EXE_LUI_OP: begin
					shiftres <= {reg1_i,12'b0};
							   end 
				  `EXE_ROTR_OP:begin
					shiftres <= ((reg1_i << (6'd32-{1'b0,reg2_i[4:0]}))|(reg1_i >> reg2_i[4:0]));
				  end 
				  default:begin
					shiftres <= 0;
							end 
				endcase
			  end
		 end


		always@(*)
		  begin
			wd_o <= wd_i;
			wreg_o <=wreg_i;
		if(((aluop_i == `EXE_ADD_OP)||(aluop_i == `EXE_ADDI_OP)||(aluop_i  == `EXE_SUB_OP))&&(ov_sum == 1'b1))
		  begin
		  wreg_o = 0;
		  ovassert <= 1'b1;
		  end
		else begin
		wreg_o <= wreg_i;
		ovassert <= 1'b0;
		end
			case (alusel_i)
			  `EXE_RES_LOGIC:
				 begin
				   wdata_o <= logicout;
					 end 
			  `EXE_RES_SHIFT:
				 begin
				   wdata_o <= shiftres;
				 end
			  `EXE_RES_MOVE:begin
				   wdata_o <= moveres;
			  end 
			  `EXE_RES_ARITHMETIC :
				 begin
				   wdata_o <= arithmeticres;
				 end
			  `EXE_RES_MUL:begin
				wdata_o <= mulres[31:0];
				end
			  `EXE_RES_JUMP_BRANCH :begin
				wdata_o <= link_address_i;
				end
			  default: begin
				wdata_o <= `ZeroWord;
					   end
			endcase
		  end
		
		always @ (*) begin
			if(rst == `RstEnable) begin
				cp0_reg_write_addr_o <= 5'b00000;
				cp0_reg_we_o <= `WriteDisable;
				cp0_reg_data_o <= `ZeroWord;
			end else if(aluop_i == `EXE_MTC0_OP) begin
				cp0_reg_write_addr_o <= inst_i[15:11];
				cp0_reg_we_o <= `WriteEnable;
				cp0_reg_data_o <= reg1_i;
		  end else begin
				cp0_reg_write_addr_o <= 5'b00000;
				cp0_reg_we_o <= `WriteDisable;
				cp0_reg_data_o <= `ZeroWord;
			end				
		end	
		endmodule
	  	module div(

		input	wire										clk,
		input wire										rst,
		
		input wire                    signed_div_i,
		input wire[31:0]              opdata1_i,
		input wire[31:0]		   				opdata2_i,
		input wire                    start_i,
		input wire                    annul_i,
		
		output reg[63:0]             result_o,
		output reg			             ready_o
	);

		wire[32:0] div_temp;
		reg[5:0] cnt;
		reg[64:0] dividend;
		reg[1:0] state;
		reg[31:0] divisor;	 
		reg[31:0] temp_op1;
		reg[31:0] temp_op2;

		
		assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};
		
		always@(posedge clk) begin
		  if(rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNoReady;
			result_o <= {`ZeroWord,`ZeroWord};
		  end else begin
			case(state)
			 `DivFree: begin
			   if(start_i == `DivStart && annul_i == 1'b0) begin
				 if(opdata2_i == `ZeroWord) begin
				   state <= `DivByZero;
				 end else begin
				   state <= `DivOn;
				  cnt <= 6'b000000;
				   if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
					 temp_op1 = ~opdata1_i + 1;
				end else begin
				  temp_op1 = opdata1_i;
				end 
				if(signed_div_i == 1'b1 && opdata2_i[31] ==1'b1) begin
				  temp_op2 = ~opdata2_i +1;
				end else begin
				  temp_op2 = opdata2_i;
				end 
				dividend <= {`ZeroWord,`ZeroWord};
				dividend[32:1] <= temp_op1;
				divisor <= temp_op2;
			end 
		end  else begin
		  ready_o <= `DivResultNoReady;
		  result_o <= {`ZeroWord,`ZeroWord};
		  end 
	end 
	 `DivByZero : begin
	   dividend <= {`ZeroWord ,`ZeroWord};
	   state <= `DivEnd;
	 end 
	 
	 `DivOn : begin
	   if(annul_i == 1'b0)begin
		 if(cnt != 6'b100000) begin
		   if(div_temp[32] == 1'b1) begin
			 dividend <= {dividend[63:0],1'b0};
		   end else begin
			 dividend <= {div_temp[31:0],dividend[31:0],1'b1};
		   end 
		   cnt <= cnt + 1;
		 end else begin
		   if((signed_div_i == 1'b1)&&
			 ((opdata1_i[31]^ opdata2_i[31]) == 1'b1)) begin
			 dividend <= (~dividend[31:0] + 1);
		  end 
		  if((signed_div_i == 1'b1) &&
			( (opdata1_i[31] ^opdata2_i[31])== 1'b1 ))begin
			dividend[64:33] <= (~dividend[64:33] + 1);
		end 
		state <= `DivEnd;
		cnt <= 6'b000000;
	  end 
	 end else begin
	   state <= `DivFree;
	 end 
	 end

	 
	 `DivEnd :begin
	   result_o <= {dividend[64:33],dividend[31:0]};
	   ready_o <= `DivResultReady;
	   if(start_i == `DivStop)begin
		 state <= `DivFree;
		 ready_o <= `DivResultNoReady;
		 result_o <= {`ZeroWord,`ZeroWord};
	   end 
	  end 
	 endcase
	 end 
	 end 
	endmodule


	  module ex_mem (
		input wire clk,
		input wire rst,
		input wire flush,
		//from exe
		input wire[`RegAddrBus] ex_wd,
		input wire ex_wreg,
		input wire[`RegBus] ex_wdata,

		input [5:0] stall,

		input wire[`AluOpBus]        ex_aluop,
		input wire[`RegBus]          ex_mem_addr,
		input wire[`RegBus]          ex_reg2,

		input wire                   ex_cp0_reg_we,
		input wire[4:0]              ex_cp0_reg_write_addr,
		input wire[`RegBus]          ex_cp0_reg_data,

		input wire[31:0]             ex_excepttype,
		input wire                   ex_is_in_delayslot,
		input wire[`RegBus]          ex_current_inst_address,

		output reg[31:0]            mem_excepttype,
		output reg                  mem_is_in_delayslot,
		output reg[`RegBus]         mem_current_inst_address,

		output reg                   mem_cp0_reg_we,
		output reg[4:0]              mem_cp0_reg_write_addr,
		output reg[`RegBus]          mem_cp0_reg_data,
			

	   //output to mem_wd
		output reg[`AluOpBus]        mem_aluop,
		output reg[`RegBus]          mem_mem_addr,
		output reg[`RegBus]          mem_reg2,
		output reg[`RegAddrBus] mem_wd,
		output reg mem_wreg,
		output reg[`RegBus] mem_wdata
	);
		always @(posedge clk) begin
				if(rst == `RstEnable) begin
					mem_wd <= `NOPRegAddr;
					mem_wreg <= `WriteDisable;
					mem_wdata <= `ZeroWord;
					mem_cp0_reg_we <= `WriteDisable;
					mem_cp0_reg_write_addr <= 5'b00000;
					mem_cp0_reg_data <= `ZeroWord;
					mem_excepttype <= `ZeroWord;
					mem_is_in_delayslot <= `NotInDelaySlot;
					mem_current_inst_address <= `ZeroWord;
					end else if(flush == 1'b1 ) begin
					mem_wd <= `NOPRegAddr;
					mem_wreg <= `WriteDisable;
					mem_wdata <= `ZeroWord;
					mem_aluop <= `EXE_NOP_OP;
					mem_mem_addr <= `ZeroWord;
					mem_reg2 <= `ZeroWord;
					mem_cp0_reg_we <= `WriteDisable;
					mem_cp0_reg_write_addr <= 5'b00000;
					mem_cp0_reg_data <= `ZeroWord;
					mem_excepttype <= `ZeroWord;
					mem_is_in_delayslot <= `NotInDelaySlot;
					mem_current_inst_address <= `ZeroWord;   	    			
					end else if(stall[3] == `Stop && stall[4] == `NoStop)begin
					mem_wd <= `NOPRegAddr;
					mem_wreg <=`WriteDisable;
					mem_wdata <= `ZeroWord;
					mem_cp0_reg_we <= `WriteDisable;
					mem_cp0_reg_write_addr <= 5'b00000;
					mem_cp0_reg_data <= `ZeroWord;
					mem_excepttype <= `ZeroWord;
					mem_is_in_delayslot <= `NotInDelaySlot;
					mem_current_inst_address <= `ZeroWord;
				end  else if(stall[3] == `NoStop) begin
				  mem_wd <= ex_wd;
				  mem_wreg <= ex_wreg;
				  mem_wdata <= ex_wdata;
				  mem_aluop <= ex_aluop;
				  mem_mem_addr <= ex_mem_addr;
				  mem_reg2 <= ex_reg2;	
				  mem_cp0_reg_we <= ex_cp0_reg_we;
				  mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
				  mem_cp0_reg_data <= ex_cp0_reg_data;
				  mem_excepttype <= ex_excepttype;
				  mem_is_in_delayslot <= ex_is_in_delayslot;
				  mem_current_inst_address <= ex_current_inst_address;
				end
			end//always

	endmodule

	module mem (
		input wire rst,
		//come from execiton
		input wire[`RegAddrBus] wd_i,
		input wire wreg_i,
		input wire[`RegBus] wdata_i,

		input wire[`AluOpBus]        aluop_i,
		input wire[`RegBus]          mem_addr_i,
		input wire[`RegBus]          reg2_i,

		input wire[`RegBus]          mem_data_i,

		input wire                  LLbit_i,
		input wire                  wb_LLbit_we_i,
		input wire                  wb_LLbit_value_i,

		input wire                   cp0_reg_we_i,
		input wire[4:0]              cp0_reg_write_addr_i,
		input wire[`RegBus]          cp0_reg_data_i,

		input wire[31:0]             excepttype_i,
		input wire                   is_in_delayslot_i,
		input wire[`RegBus]          current_inst_address_i,

		input wire[`RegBus]          cp0_status_i,
		input wire[`RegBus]          cp0_cause_i,
		input wire[`RegBus]          cp0_epc_i,

		input wire                    wb_cp0_reg_we,
		input wire[4:0]               wb_cp0_reg_write_addr,
		input wire[`RegBus]           wb_cp0_reg_data,
		
		output reg[31:0]             excepttype_o,
		output wire[`RegBus]          cp0_epc_o,
		output wire                  is_in_delayslot_o,
		
		output reg                   cp0_reg_we_o,
		output reg[4:0]              cp0_reg_write_addr_o,
		output reg[`RegBus]          cp0_reg_data_o,
		//output result
		output reg[`RegAddrBus] wd_o,
		output reg wreg_o,
		output reg[`RegBus] wdata_o,

		output reg[`RegBus]          mem_addr_o,
		output wire					 mem_we_o,
		output reg[3:0]              mem_sel_o,
		output reg[`RegBus]          mem_data_o,
		output reg                   mem_ce_o,

		output reg                   LLbit_we_o,
		output reg                   LLbit_value_o,
		
		output wire[`RegBus]         current_inst_address_o		
		
	);

		wire[`RegBus] zero32;
		reg    mem_we;

		reg[`RegBus] cp0_status;
		reg[`RegBus] cp0_cause;
		reg[`RegBus] cp0_epc;

		assign is_in_delayslot_o = is_in_delayslot_i;
		assign current_inst_address_o = current_inst_address_i;

		assign mem_we_o = mem_we ;
		assign zero32 = `ZeroWord;

		reg LLbit;

		always @ (*) begin
			if(rst == `RstEnable) begin
				cp0_status <= `ZeroWord;
			end else if((wb_cp0_reg_we == `WriteEnable) && 
									(wb_cp0_reg_write_addr == `CP0_REG_STATUS ))begin
				cp0_status <= wb_cp0_reg_data;
			end else begin
			  cp0_status <= cp0_status_i;
			end
		end
		
		always @ (*) begin
			if(rst == `RstEnable) begin
				cp0_epc <= `ZeroWord;
			end else if((wb_cp0_reg_we == `WriteEnable) && 
									(wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
				cp0_epc <= wb_cp0_reg_data;
			end else begin
			  cp0_epc <= cp0_epc_i;
			end
		end
		
		assign cp0_epc_o = cp0_epc;

		always @ (*) begin
			if(rst == `RstEnable) begin
				cp0_cause <= `ZeroWord;
			end else if((wb_cp0_reg_we == `WriteEnable) && 
									(wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
				cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
				cp0_cause[22] <= wb_cp0_reg_data[22];
				cp0_cause[23] <= wb_cp0_reg_data[23];
			end else begin
			  cp0_cause <= cp0_cause_i;
			end
		end

		always@(*)begin
		  if(rst == `RstEnable)begin
			  LLbit <= 1'b0;
		  end else begin
			 if(wb_LLbit_we_i == 1'b1)begin
			  LLbit <= wb_LLbit_value_i;
			 end else begin
			   LLbit <= LLbit_i;
			 end
		  end
		end
		
	always @(*) begin
		if(rst == `RstEnable) begin
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteEnable;
			wdata_o <= `ZeroWord;
			mem_addr_o <= `ZeroWord;
			mem_we <= `WriteDisable;
			mem_sel_o <= 4'b0000;
			mem_data_o <= `ZeroWord;
			mem_ce_o <= `ChipDisable;	
			LLbit_we_o <= 1'b0;
			LLbit_value_o <= 1'b0;
			cp0_reg_we_o <= `WriteDisable;
			cp0_reg_write_addr_o <= 5'b00000;
			cp0_reg_data_o <= `ZeroWord;	
		end else begin
			wd_o <= wd_i;
			wreg_o <= wreg_i;
			wdata_o <= wdata_i;
			mem_we <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_sel_o <= 4'b1111;
			mem_ce_o <= `ChipDisable;
			LLbit_we_o <= 1'b0;
			LLbit_value_o <= 1'b0;
			cp0_reg_we_o <= cp0_reg_we_i;
			cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
			cp0_reg_data_o <= cp0_reg_data_i;		 
			case (aluop_i)
			  `EXE_LDB_OP:		begin
				mem_addr_o <= mem_addr_i;
				mem_we <= `WriteDisable;
				mem_ce_o <= `ChipEnable;
				  case (mem_addr_i[1:0])
					2'b00:	begin
						wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
						mem_sel_o <= 4'b1000;
					end
					2'b01:	begin
					wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
					mem_sel_o <= 4'b0100;
					end
					2'b10:	begin
					wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
					mem_sel_o <= 4'b0010;
					end
					2'b11:	begin
					wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
					mem_sel_o <= 4'b0001;
					end
					default:	begin
					wdata_o <= `ZeroWord;
					end
						endcase
					end	
			  `EXE_LDBU_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteDisable;
						mem_ce_o <= `ChipEnable;
						case (mem_addr_i[1:0])
							2'b00:	begin
								wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
								mem_sel_o <= 4'b1000;
							end
							2'b01:	begin
								wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
								mem_sel_o <= 4'b0100;
							end
							2'b10:	begin
								wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
								mem_sel_o <= 4'b0010;
							end
							2'b11:	begin
								wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
								mem_sel_o <= 4'b0001;
							end
							default:	begin
								wdata_o <= `ZeroWord;
							end
						endcase				
					end
					`EXE_LDH_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteDisable;
						mem_ce_o <= `ChipEnable;
						case (mem_addr_i[1:0])
							2'b00:	begin
								wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
								mem_sel_o <= 4'b1100;
							end
							2'b10:	begin
								wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
								mem_sel_o <= 4'b0011;
							end
							default:	begin
								wdata_o <= `ZeroWord;
							end
						endcase					
					end
					`EXE_LDHU_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteDisable;
						mem_ce_o <= `ChipEnable;
						case (mem_addr_i[1:0])
							2'b00:	begin
								wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
								mem_sel_o <= 4'b1100;
							end
							2'b10:	begin
								wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
								mem_sel_o <= 4'b0011;
							end
							default:	begin
								wdata_o <= `ZeroWord;
							end
						endcase				
					end
					`EXE_LDW_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteDisable;
						wdata_o <= mem_data_i;
						mem_sel_o <= 4'b1111;
						mem_ce_o <= `ChipEnable;		
					end
		  
					`EXE_STB_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
						mem_ce_o <= `ChipEnable;
						case (mem_addr_i[1:0])
							2'b00:	begin
								mem_sel_o <= 4'b1000;
							end
							2'b01:	begin
								mem_sel_o <= 4'b0100;
							end
							2'b10:	begin
								mem_sel_o <= 4'b0010;
							end
							2'b11:	begin
								mem_sel_o <= 4'b0001;	
							end
							default:	begin
								mem_sel_o <= 4'b0000;
							end
						endcase				
					end
					`EXE_STH_OP:		begin
						mem_addr_o <= mem_addr_i;
						mem_we <= `WriteEnable;
						mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
						mem_ce_o <= `ChipEnable;
						case (mem_addr_i[1:0])
							2'b00:	begin
								mem_sel_o <= 4'b1100;
							end
							2'b10:	begin
								mem_sel_o <= 4'b0011;
							end
							default:	begin
								mem_sel_o <= 4'b0000;
							end
						endcase						
					end
					`EXE_STW_OP:		begin
						mem_addr_o<= mem_addr_i;
						mem_we<= `WriteEnable;
						mem_data_o <= reg2_i;
						mem_sel_o <= 4'b1111;	
						mem_ce_o <= `ChipEnable;		
					end
				`EXE_SC_OP:  begin
				    if(LLbit == 1'b1)begin
                    mem_addr_o <=mem_addr_i;
					mem_we<= `WriteEnable;
					mem_data_o <= reg2_i;
					wdata_o <= 32'b1;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;
					LLbit_we_o <=1'b1; 
					LLbit_value_o <= 1'b0;
				end else begin
                    wdata_o <= 32'b0;
				end
				end 
				`EXE_LL_OP: begin
                    mem_addr_o <=mem_addr_i;
					mem_we<= `WriteDisable;
					wdata_o <= mem_data_i;
					mem_sel_o <= 4'b1111;
					mem_ce_o <= `ChipEnable;
					LLbit_we_o <=1'b1; 
					LLbit_value_o <= 1'b1;
             
				end
				default:begin
				end
				endcase
				end
	
end 

  	always @ (*) begin
		if(rst == `RstEnable) begin
			excepttype_o <= `ZeroWord;
		end else begin
			excepttype_o <= `ZeroWord;
			
			if(current_inst_address_i != `ZeroWord) begin
				if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && 
							(cp0_status[0] == 1'b1)) begin
					excepttype_o <= 32'h00000001;        //interrupt
				end else if(excepttype_i[8] == 1'b1) begin
			  	excepttype_o <= 32'h00000008;        //syscall
				end else if(excepttype_i[9] == 1'b1) begin
					excepttype_o <= 32'h0000000a;        //inst_invalid
				end else if(excepttype_i[10] ==1'b1) begin
					excepttype_o <= 32'h0000000d;        //trap
				end else if(excepttype_i[11] == 1'b1) begin  //ov
					excepttype_o <= 32'h0000000c;
				end else if(excepttype_i[12] == 1'b1) begin  //    ָ  
					excepttype_o <= 32'h0000000e;
				end
			end
				
		end
	end 
	assign mem_we_o = mem_we &(~(|excepttype_o));

endmodule

module mem_wb (
    input wire clk,
    input wire rst,
    //come from execiton
    input wire[`RegAddrBus] mem_wd,
    input wire mem_wreg,
    input wire[`RegBus] mem_wdata,

	input [5:0] stall,

	input wire                  mem_LLbit_we,
	input wire                  mem_LLbit_value,

	input wire                   mem_cp0_reg_we,
	input wire[4:0]              mem_cp0_reg_write_addr,
	input wire[`RegBus]          mem_cp0_reg_data,

	input wire flush,
    //output result
    output reg[`RegAddrBus] wb_wd,
    output reg wb_wreg,
    output reg[`RegBus] wb_wdata,

	output reg                  wb_LLbit_we,
	output reg                  wb_LLbit_value,

	output reg                   wb_cp0_reg_we,
	output reg[4:0]              wb_cp0_reg_write_addr,
	output reg[`RegBus]          wb_cp0_reg_data
);
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteEnable;
        wb_wdata <= `ZeroWord;
		wb_cp0_reg_we <= `WriteDisable;
		wb_cp0_reg_write_addr <= 5'b00000;
		wb_cp0_reg_data <= `ZeroWord;
		end else if(flush == 1'b1 ) begin
		wb_wd <= `NOPRegAddr;
		wb_wreg <= `WriteDisable;
	    wb_wdata <= `ZeroWord;
		wb_cp0_reg_we <= `WriteDisable;
		wb_cp0_reg_write_addr <= 5'b00000;
		wb_cp0_reg_data <= `ZeroWord;	
	end else if(stall[4] == `Stop && stall[5] == `NoStop) begin
        wb_wd <= `NOPRegAddr;
        wb_wreg <= `WriteEnable;
        wb_wdata <= `ZeroWord;
		wb_LLbit_we <= 1'b0;
		wb_LLbit_value <= 1'b0;
		wb_cp0_reg_we <= `WriteDisable;
		wb_cp0_reg_write_addr <= 5'b00000;
		wb_cp0_reg_data <= `ZeroWord;	
    end else if(stall [4] == `NoStop) begin
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
		wb_LLbit_we <= mem_LLbit_we;
		wb_LLbit_value <=mem_LLbit_value;
		wb_cp0_reg_we <= mem_cp0_reg_we;
		wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
		wb_cp0_reg_data <= mem_cp0_reg_data;			
    end
end
    
endmodule

  module ctrl(
    input rst,
	input stallreq_from_id,
	input stallreq_from_ex,

	input wire[31:0]             excepttype_i,
	input wire[`RegBus]          cp0_epc_i,

	output reg[`RegBus] new_pc,
	output reg flush,
	output reg[5:0] stall
  );

    always@(*) begin
	  if(rst == `RstEnable)begin
	    stall <= 6'b000000;
		flush <= 1'b0;
		new_pc <= `ZeroWord;
	end else if(excepttype_i != `ZeroWord)begin
	    flush <= 1'b1;
		stall <= 6'b000000;
		case(excepttype_i)
		 32'h00000001:begin
           new_pc <= 32'h00000020;
		 end 
		 32'h00000008:begin
           new_pc <= 32'h00000040;
		 end 
		 32'h0000000a:begin
           new_pc <= 32'h00000040;
		 end 
		 32'h0000000d:begin
           new_pc <= 32'h00000040;
		 end 
		 32'h0000000c:begin
           new_pc <= 32'h00000040;
		 end 
		 32'h0000000e:begin
           new_pc <= cp0_epc_i;
		 end 
		default:begin
		end 
		endcase
	end else if(stallreq_from_ex ==`Stop)begin
	  stall <= 6'b001111;
	  flush <= 1'b0;
	end else if(stallreq_from_id == `Stop)begin
	  stall <= 6'b000000;
	  flush <= 1'b0;
	end else begin
	  stall <= 6'b000000;
	  flush <= 1'b0;
	  new_pc <= `ZeroWord;
	end
 end
 endmodule
 module LLbit_reg(
   input wire clk,
   input wire rst,

   input wire flush,

   input wire LLbit_i,
   input wire we,

   output reg LLbit_o
 );
   always@(posedge clk)begin
     if(rst == `RstEnable) begin
	   LLbit_o <= 1'b0;
   end else if((flush == 1'b1))begin
       LLbit_o <= 1'b0;
   end else if((we == `WriteEnable))begin
     LLbit_o <= LLbit_i;
	 end 
	 end 
 endmodule

  module openmips(
    input clk,
	input rst,
	
    input wire[`RegBus]           rom_data_i,
	output wire[`RegBus]           rom_addr_o,
	output wire                    rom_ce_o,

    input wire[5:0]                int_i,
	output wire                    timer_int_o,
    
	
	input wire[`RegBus]           ram_data_i,
	output wire[`RegBus]           ram_addr_o,
	output wire[`RegBus]           ram_data_o,
	output wire                    ram_we_o,
	output wire[3:0]               ram_sel_o,
	output wire               ram_ce_o);

	//connect if/id to id
wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
//connect id to id/ex
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire[2:0] id_sa2_o;
wire [`InstAddrBus]id_pc_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire id_is_in_delayslot_o;
wire[`RegBus] id_link_address_o;
wire[`RegBus] id_inst_o;
wire[31:0] id_excepttype_o;
wire[`RegBus] id_current_inst_address_o;
//id/ex to ex
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire[2:0] ex_sa2_i;
wire [`InstAddrBus]ex_pc_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;	
wire[`RegBus] ex_link_address_i;
wire [31:0] ex_inst_i;
wire[31:0] ex_excepttype_i;	
wire[`RegBus] ex_current_inst_address_i;	
//ex to ex_mem or ex to id
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire [`AluOpBus] ex_aluop_o;
wire [`RegBus] ex_mem_addr_o;
wire [`RegBus] ex_reg2_o;
wire [`RegBus] ex_reg1_o;
wire ex_cp0_reg_we_o;
wire[4:0] ex_cp0_reg_write_addr_o;
wire[`RegBus] ex_cp0_reg_data_o; 
wire[31:0] ex_excepttype_o;
wire[`RegBus] ex_current_inst_address_o;
wire ex_is_in_delayslot_o;
//ex_mem to mem
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire [`AluOpBus] mem_aluop_i;
wire [`RegBus] mem_mem_addr_i;
wire [`RegBus] mem_reg2_i;
wire [`RegBus] mem_reg1_i;
wire mem_cp0_reg_we_i;
wire[4:0] mem_cp0_reg_write_addr_i;
wire[`RegBus] mem_cp0_reg_data_i;	
wire[31:0] mem_excepttype_i;	
wire mem_is_in_delayslot_i;
wire[`RegBus] mem_current_inst_address_i;	
//_mem to mem/wb
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire mem_LLbit_value_o;
wire mem_LLbit_we_o;
wire mem_cp0_reg_we_o;
wire[4:0] mem_cp0_reg_write_addr_o;
wire[`RegBus] mem_cp0_reg_data_o;	
wire[31:0] mem_excepttype_o;
wire mem_is_in_delayslot_o;
wire[`RegBus] mem_current_inst_address_o;
//mem/wb to regfile or mem/wb to HILO
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;
wire wb_LLbit_value_i;
wire wb_LLbit_we_i;
wire wb_cp0_reg_we_i;
wire[4:0] wb_cp0_reg_write_addr_i;
wire[`RegBus] wb_cp0_reg_data_i;	
wire[31:0] wb_excepttype_i;
wire wb_is_in_delayslot_i;
wire[`RegBus] wb_current_inst_address_i;
//id to regfile
wire reg1_read;
wire reg2_read;
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;
wire[5:0] stall;
wire stallreq_from_id;	
wire stallreq_from_ex;
//ex to div or div to ex
wire signed_div;
wire [`RegBus]div_opdata1;
wire [`RegBus]div_opdata2;
wire          div_start;
wire annul_i;
wire [`DoubleRegBus]div_result;
wire          div_ready;
//ex to cl 
wire [31:0]cl_data_i;
wire [31:0]cl_data_o;
wire cl_start;

wire is_in_delayslot_i;
wire is_in_delayslot_o;
wire next_inst_in_delayslot_o;
wire id_branch_flag_o;
wire[`RegBus] branch_target_address;

wire LLbit_o;

wire[`RegBus] cp0_data_o;
wire[4:0] cp0_raddr_i;

wire flush;
wire[`RegBus] new_pc;
wire[`RegBus] cp0_count;
wire[`RegBus]	cp0_compare;
wire[`RegBus]	cp0_status;
wire[`RegBus]	cp0_cause;
wire[`RegBus]	cp0_epc;
wire[`RegBus]	cp0_config;
wire[`RegBus]	cp0_prid; 

wire[`RegBus] latest_epc;

//pc_reg
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .ce(rom_ce_o),
	.stall(stall),
	.branch_flag_i(id_branch_flag_o),
	.branch_target_address_i(branch_target_address),
	.flush(flush),
	.new_pc(new_pc)
);
assign rom_addr_o = pc;
//if/id
if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_data_i),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i),
	.stall(stall),
	.flush(flush)
);
//id module
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

	.ex_aluop_i(ex_aluop_o),
    //from regfile input
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),
	//from ex
	.ex_wreg_i(ex_wreg_o),
	.ex_wd_i(ex_wd_o),
	.ex_wdata_i(ex_wdata_o),
	//from mem
	.mem_wreg_i(mem_wreg_o),
	.mem_wd_i(mem_wd_o),
	.mem_wdata_i(mem_wdata_o),

    .is_in_delayslot_i(is_in_delayslot_i),
	
    // output to regfile
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr),
    //output to id/ex
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
	.sa2(id_sa2_o),
	.pc_o(id_pc_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
	.inst_o(id_inst_o),

    .next_inst_in_delayslot_o(next_inst_in_delayslot_o),	
	.branch_flag_o(id_branch_flag_o),
	.branch_target_address_o(branch_target_address),       
	.link_addr_o(id_link_address_o),	
	.is_in_delayslot_o(id_is_in_delayslot_o),

	.excepttype_o(id_excepttype_o),
	.current_inst_address_o(id_current_inst_address_o),
    
	.stallreq(stallreq_from_id)
    );
regfile regfile1(
    .clk(clk),
    .rst(rst),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .rdata1(reg1_data),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .rdata2(reg2_data)
);
//id/ex
id_ex id_ex0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
	.flush(flush),
    //message from id
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
	.id_sa2(id_sa2_o),
	.id_pc(id_pc_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
	.id_link_address(id_link_address_o),
	.id_is_in_delayslot(id_is_in_delayslot_o),
	.next_inst_in_delayslot_i(next_inst_in_delayslot_o),
	.id_inst(id_inst_o),
	.id_excepttype(id_excepttype_o),
	.id_current_inst_address(id_current_inst_address_o),
    //message to ex
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
	.ex_sa2(ex_sa2_i),
	.ex_pc(ex_pc_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
	.ex_link_address(ex_link_address_i),
  	.ex_is_in_delayslot(ex_is_in_delayslot_i),
	.is_in_delayslot_o(is_in_delayslot_i),
	.ex_inst(ex_inst_i),
	.ex_excepttype(ex_excepttype_i),
	.ex_current_inst_address(ex_current_inst_address_i)	
);
//ex model
ex ex0(
    .rst(rst),
    // message from if/ex
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
	.sa2_i(ex_sa2_i),
	.pc_i(ex_pc_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
	.inst_i(ex_inst_i),
    // output to ex/mem
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),

	.cl_o(cl_data_i),
	.cl_start_o(cl_start),
	.cl_i(cl_data_o),
    
	.div_opdata1_o(div_opdata1),
	.div_opdata2_o(div_opdata2),
	.div_start_o(div_start),
	.signed_div_o(signed_div),	
	.stallreq(stallreq_from_ex),

	.div_result_i(div_result),
    .div_ready_i(div_ready),

	
	.link_address_i(ex_link_address_i),
	.is_in_delayslot_i(ex_is_in_delayslot_i),

	.excepttype_i(ex_excepttype_i),
	.current_inst_address_i(ex_current_inst_address_i),

	.mem_cp0_reg_we(mem_cp0_reg_we_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),

  	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),	

	.cp0_reg_data_i(cp0_data_o),
	.cp0_reg_read_addr_o(cp0_raddr_i),	

	.cp0_reg_we_o(ex_cp0_reg_we_o),
	.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
	.cp0_reg_data_o(ex_cp0_reg_data_o),	 	

	.aluop_o(ex_aluop_o),
	.mem_addr_o(ex_mem_addr_o),
	.reg2_o(ex_reg2_o),

	.excepttype_o(ex_excepttype_o),
	.is_in_delayslot_o(ex_is_in_delayslot_o),
	.current_inst_address_o(ex_current_inst_address_o)
);
//ex to cl 
cl cl1(
  .clk(clk),
  .rst(rst),
  .start_i(cl_start),
  .data_i(cl_data_i),
  .cl_aluop_i(ex_aluop_o),
  .result_o(cl_data_o)
);
//ex/mem
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
	.flush(flush),
    //from ex
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),

	.ex_aluop(ex_aluop_o),
	.ex_mem_addr(ex_mem_addr_o),
	.ex_reg2(ex_reg2_o),

	.ex_cp0_reg_we(ex_cp0_reg_we_o),
    .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
	.ex_cp0_reg_data(ex_cp0_reg_data_o),	

	.ex_excepttype(ex_excepttype_o),
	.ex_is_in_delayslot(ex_is_in_delayslot_o),
	.ex_current_inst_address(ex_current_inst_address_o),	
     //to mem
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),

	.mem_cp0_reg_we(mem_cp0_reg_we_i),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
	.mem_cp0_reg_data(mem_cp0_reg_data_i),

	.mem_aluop(mem_aluop_i),
	.mem_mem_addr(mem_mem_addr_i),
	.mem_reg2(mem_reg2_i),

	.mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
	.mem_current_inst_address(mem_current_inst_address_i)
);
//mem
mem mem0(
    .rst(rst),
    //from ex/mem
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),

	.aluop_i(mem_aluop_i),
	.mem_addr_i(mem_mem_addr_i),
	.reg2_i(mem_reg2_i),
	
	.mem_data_i(ram_data_i),
     //to mem
    .wd_o(mem_wd_o),
	.wreg_o(mem_wreg_o),
	.wdata_o(mem_wdata_o),

	.LLbit_i(LLbit_o),
	.wb_LLbit_we_i(wb_LLbit_we_i),
	.wb_LLbit_value_i(wb_LLbit_value_i),

	.excepttype_i(mem_excepttype_i),
    .is_in_delayslot_i(mem_is_in_delayslot_i),
	.current_inst_address_i(mem_current_inst_address_i),	

   	.cp0_status_i(cp0_status),
	.cp0_cause_i(cp0_cause),
	.cp0_epc_i(cp0_epc),

	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),
		
	.cp0_reg_we_i(mem_cp0_reg_we_i),
    .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
	.cp0_reg_data_i(mem_cp0_reg_data_i),

	.cp0_reg_we_o(mem_cp0_reg_we_o),
	.cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
	.cp0_reg_data_o(mem_cp0_reg_data_o),	

	.LLbit_we_o(mem_LLbit_we_o),
	.LLbit_value_o(mem_LLbit_value_o),

    .mem_addr_o(ram_addr_o),
	.mem_we_o(ram_we_o),
	.mem_sel_o(ram_sel_o),
	.mem_data_o(ram_data_o),
	.mem_ce_o(ram_ce_o),

	.excepttype_o(mem_excepttype_o),
	.cp0_epc_o(latest_epc),
	.is_in_delayslot_o(mem_is_in_delayslot_o),
	.current_inst_address_o(mem_current_inst_address_o)	


);
//mem/wb
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
	.stall(stall),
	.flush(flush),
    //from mem
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

	.mem_LLbit_we(mem_LLbit_we_o),
	.mem_LLbit_value(mem_LLbit_value_o),

	.mem_cp0_reg_we(mem_cp0_reg_we_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
	.mem_cp0_reg_data(mem_cp0_reg_data_o),	
     //to mem
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),

	.wb_LLbit_we(wb_LLbit_we_i),
	.wb_LLbit_value(wb_LLbit_value_i),

	.wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i)
);


ctrl ctr0(
      .rst(rst),
	  .excepttype_i(mem_excepttype_o),
	  .cp0_epc_i(latest_epc),    
	  .stallreq_from_ex(stallreq_from_ex),
	  .stallreq_from_id(stallreq_from_id),
	  .new_pc(new_pc),
	  .flush(flush),
	  .stall(stall)	
	);
	div div0(
		.clk(clk),
		.rst(rst),
	
		.signed_div_i(signed_div),
		.opdata1_i(div_opdata1),
		.opdata2_i(div_opdata2),
		.start_i(div_start),
		.annul_i(1'b0),
	
		.result_o(div_result),
		.ready_o(div_ready)
	);

	LLbit_reg LLbit_reg0(
		.clk(clk),
		.rst(rst),
	    .flush(flush),
	  
		.LLbit_i(wb_LLbit_value_i),
		.we(wb_LLbit_we_i),
	
		.LLbit_o(LLbit_o)
	
	);
	cp0_reg cp0_reg0(
		.clk(clk),
		.rst(rst),
		
		.we_i(wb_cp0_reg_we_i),
		.waddr_i(wb_cp0_reg_write_addr_i),
		.raddr_i(cp0_raddr_i),
		.data_i(wb_cp0_reg_data_i),
		
		.excepttype_i(mem_excepttype_o),
		.int_i(int_i),
		.current_inst_addr_i(mem_current_inst_address_o),
		.is_in_delayslot_i(mem_is_in_delayslot_o),
	
		.data_o(cp0_data_o),
		.count_o(cp0_count),
		.compare_o(cp0_compare),
		.status_o(cp0_status),
		.cause_o(cp0_cause),
		.epc_o(cp0_epc),
		.config_o(cp0_config),
		.prid_o(cp0_prid),
		
		
		.timer_int_o(timer_int_o)  			
	);	

endmodule
  
  module inst_rom(
    input wire ce,
	input wire [`InstAddrBus] addr,
	output reg[`InstBus] inst);
	
	reg  [`InstBus] inst_mem [0:`InstMemNum-1];

	initial $readmemh("/home/host/data/cpu3/rtl/test.data",inst_mem);

	always@(*)
	  begin
	    if(ce == 0)
		  begin
		    inst <= 0;
		  end
        else
		  begin
		    inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
	   	  end
	   end
  endmodule

module data_ram(
  input wire clk,
  input wire ce,
  input wire we,
  input wire [`DataAddrBus] addr,
  input wire [3:0] sel,
  input wire[`DataBus]  data_i,
  output reg[`DataBus] data_o
);
  
  reg[`ByteWidth] data_mem0[0:`DataMemNum-1];
  reg[`ByteWidth] data_mem1[0:`DataMemNum-1];
  reg[`ByteWidth] data_mem2[0:`DataMemNum-1];
  reg[`ByteWidth] data_mem3[0:`DataMemNum-1];

// write 
  always@(posedge clk) begin
    if(ce == `ChipDisable) begin
	 // data_o <=ZeroWord;
	end else if(we == `WriteEnable)begin
	  if(sel[3] == 1'b1)begin
	    data_mem3[addr[`DataMemNumLog2+1:2]] <= data_i[31:24];
	  end
	  if(sel[2] == 1'b1)begin
	    data_mem2[addr[`DataMemNumLog2+1:2]] <= data_i[23:16];
	  end
	  if(sel[1] == 1'b1)begin
        data_mem1[addr[`DataMemNumLog2+1:2]] <= data_i[15:8];
	  end
	  if(sel[0] == 1'b1)begin
	    data_mem0[addr[`DataMemNumLog2+1:2]] <= data_i[7:0]; 
	  end
	end
  end 
  //read
  always@(*) begin
    if(ce == `ChipDisable)begin
	  data_o <= `ZeroWord;
  end else if(we == `WriteDisable)begin
    data_o <= {data_mem3[addr[`DataMemNumLog2+1:2]],
	           data_mem2[addr[`DataMemNumLog2+1:2]],
			   data_mem1[addr[`DataMemNumLog2+1:2]],
			   data_mem0[addr[`DataMemNumLog2+1:2]]
	};
  end else begin
    data_o <= `ZeroWord;
	end 
	end 
endmodule

//CP0
module cp0_reg(
  input wire clk,
  input wire rst,

  input wire             we_i,
  input wire[4:0]        waddr_i,
  input wire[4:0]        raddr_i,
  input wire[`RegBus]    data_i,

  input wire[5:0]        int_i,

  input wire[31:0]              excepttype_i,
  input wire[`RegBus]           current_inst_addr_i,
  input wire                    is_in_delayslot_i,

  output reg[`RegBus]           data_o,
  output reg[`RegBus]           count_o,
  output reg[`RegBus]           compare_o,
  output reg[`RegBus]           status_o,
  output reg[`RegBus]           cause_o,
  output reg[`RegBus]           epc_o,
  output reg[`RegBus]           config_o,
  output reg[`RegBus]           prid_o,
	
  output reg                   timer_int_o    
);
  always@(posedge clk)begin
  if(rst == `RstEnable)begin
   	count_o <= `ZeroWord;
	compare_o <= `ZeroWord;    
	status_o <= 32'b00010000000000000000000000000000;
	cause_o <= `ZeroWord;
	epc_o <= `ZeroWord;
	config_o <= 32'b00000000000000001000000000000000;
	prid_o <= 32'b00000000010011000000000100000010;
    timer_int_o <= `InterruptNotAssert;
  end else begin
    count_o <= count_o + 1;
	cause_o[15:10] <= int_i;

    if(compare_o!= `ZeroWord && count_o == compare_o)begin
      timer_int_o <= `InterruptAssert;
	end
	if(we_i == `WriteEnable)begin
      case(waddr_i)
	    `CP0_REG_COUNT:begin
          count_o <= data_i;
		end 
		`CP0_REG_COMPARE:begin
          compare_o <= data_i;
		  timer_int_o <=`InterruptNotAssert;
		end
		`CP0_REG_STATUS:begin
          status_o <= data_i;
		end 
		`CP0_REG_EPC:begin
          epc_o <= data_i;
		end 
		`CP0_REG_CAUSE:begin
          cause_o[9:8] <= data_i[9:8];
		  cause_o[23]  <= data_i[23];
		  cause_o[22]  <= data_i[22];
		end 
	  default:begin
	  end 
	  endcase
	  end 
       case (excepttype_i)
				32'h00000001:		begin
					if(is_in_delayslot_i == `InDelaySlot ) begin
						epc_o <= current_inst_addr_i - 4 ;
						cause_o[31] <= 1'b1;
					end else begin
					  epc_o <= current_inst_addr_i;
					  cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00000;
					
				end
				32'h00000008:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;			
				end
				32'h0000000a:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;					
				end
				32'h0000000d:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01101;					
				end
				32'h0000000c:		begin
					if(status_o[1] == 1'b0) begin
						if(is_in_delayslot_i == `InDelaySlot ) begin
							epc_o <= current_inst_addr_i - 4 ;
							cause_o[31] <= 1'b1;
						end else begin
					  	epc_o <= current_inst_addr_i;
					  	cause_o[31] <= 1'b0;
						end
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;					
				end				
				32'h0000000e:   begin
					status_o[1] <= 1'b0;
				end
				default:				begin
				end
			endcase			
    end 
  end 
  always@(*)begin
   if(rst == `RstEnable)begin
     data_o <= `ZeroWord;
   end else begin
        case (raddr_i) 
		  `CP0_REG_COUNT:		begin
			  data_o <= count_o ;
			end
		  `CP0_REG_COMPARE:	begin
			  data_o <= compare_o ;
			end
		  `CP0_REG_STATUS:	begin
			  data_o <= status_o ;
			end
		  `CP0_REG_CAUSE:	begin
			  data_o <= cause_o ;
			end
		  `CP0_REG_EPC:	begin
			  data_o <= epc_o ;
			end
		  `CP0_REG_PrId:	begin
			  data_o <= prid_o ;
			end
		  `CP0_REG_CONFIG:	begin
			  data_o <= config_o ;
			end	
			default: 	begin
					end			
				endcase  //case addr_i			
     
   end 

  end 
endmodule
module openmips_min_sopc (
    input wire rst,
    input wire clk
);
//connect reg
wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;
wire mem_we_i;
wire[`RegBus] mem_addr_i;
wire[`RegBus] mem_data_i;
wire[`RegBus] mem_data_o;
wire[3:0] mem_sel_i;  
wire mem_ce_i;  
wire [5:0]int;
wire timer_int;

assign int = {5'b00000,timer_int};
//example openmips
openmips openmips0(
    .clk(clk),
    .rst(rst),
    .rom_addr_o(inst_addr),
    .rom_data_i(inst),
    .rom_ce_o(rom_ce),
	.int_i(int),
	.ram_we_o(mem_we_i),
	.ram_addr_o(mem_addr_i),
	.ram_sel_o(mem_sel_i),
	.ram_data_o(mem_data_i),
	.ram_data_i(mem_data_o),
	.ram_ce_o(mem_ce_i),

	.timer_int_o(timer_int)
	
);
//example rom
inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),
    .inst(inst)
);

data_ram data_ram0(
	.clk(clk),
	.we(mem_we_i),
	.addr(mem_addr_i),
	.sel(mem_sel_i),
	.data_i(mem_data_i),
	.data_o(mem_data_o),
	.ce(mem_ce_i)		
	);

endmodule


`timescale 1ns/1ns
module access_faults_tb #(
  parameter integer ICACHE_ENABLE=1,
  parameter integer DCACHE_ENABLE=1
);
  reg clk=0, rst=1;
  always #5 clk=~clk;
  wire  mem_rd_req_valid;
  reg  mem_rd_req_ready=0;
  wire [31:0] mem_rd_req_addr;
  wire [ 7:0] mem_rd_req_len;
  reg  mem_rd_rsp_valid=0;
  wire  mem_rd_rsp_ready;
  reg [31:0] mem_rd_rsp_rdata=0;
  reg  mem_rd_rsp_error=0;
  reg  mem_rd_rsp_last=0;
  wire  mem_wr_req_valid;
  reg  mem_wr_req_ready=0;
  wire [31:0] mem_wr_req_addr;
  wire [ 7:0] mem_wr_req_len;
  wire [31:0] mem_wr_req_wdata;
  wire [ 3:0] mem_wr_req_wstrb;
  wire  mem_wr_req_wlast;
  reg  mem_wr_rsp_valid=0;
  wire  mem_wr_rsp_ready;
  reg  mem_wr_rsp_error=0;
  wire [31:0] tohost_value_register, core_bp_branch_total, core_bp_mispredict_total, core_bp_target_miss_total;
  riscv_core #(.ICACHE_ENABLE(ICACHE_ENABLE),.DCACHE_ENABLE(DCACHE_ENABLE)) dut(.*);
  reg [31:0] words[0:16383];
  reg [31:0] uart_words[0:3];
  reg rd_pending=0, wr_pending=0, wr_input_done=0;
  reg [31:0] rd_addr=0, wr_addr=0;
  int rd_len=0, rd_index=0, wr_len=0, wr_index=0;
  int read_wait=0, write_wait=0, delay=0, seed=493, case_id=0, fault_beat=7;
  reg [15:0] random_state=16'h91ed;
  reg [31:0] wrong_path_pc=0;
  int traps=0, error_reads=0, error_writes=0, killed_errors=0, retired=0;
  int load_traps=0, store_traps=0, fetch_traps=0;
  reg [31:0] tohost=0;
  reg [31:0] expected_cause=0, expected_pc=0, expected_tval=0;
  reg check_trap_csr=0;
  reg [31:0] shadow_wb_pc=0;
  string image_path, wave;
  function automatic bit data_read_fault(input [31:0] addr);
    return (case_id==22 && DCACHE_ENABLE==0 && addr[31:6]==(32'h8000a000>>6)) ||
           ((case_id==3 || case_id==5 || case_id==6 || case_id==7 || case_id==8 ||
            case_id==9 || case_id==10 || case_id==13 || case_id==14 || case_id==15) &&
           addr[31:6]==(32'h80003000>>6));
  endfunction
  function automatic bit read_failure(input [31:0] addr,input int index,input int len);
    bit enabled;
    enabled=data_read_fault(addr) || (case_id==12 && addr[31:6]==(32'h8000d000>>6)) ||
            (case_id==11 && addr[31:6]==wrong_path_pc[31:6]) ||
            (case_id==18 && addr[31:6]==(32'h8000e040>>6));
    return enabled && (len==0 || index==fault_beat);
  endfunction
  function automatic bit write_failure(input [31:0] addr);
    return (case_id==4 && addr==32'h10000004) ||
           ((case_id==5 || case_id==7) && addr[31:6]==(32'h80003000>>6)) ||
           ((case_id==22 || case_id==23) && DCACHE_ENABLE!=0 &&
            (addr[31:6]==(32'h80002000>>6) || addr[31:6]==(32'h80004000>>6) ||
             addr[31:6]==(32'h80006000>>6) || addr[31:6]==(32'h80008000>>6))) ||
           (case_id==23 && DCACHE_ENABLE==0 && addr[31:6]==(32'h8000a000>>6));
  endfunction
  function automatic [31:0] read_word(input [31:0] addr);
    return addr[31:16]==16'h8000 ? words[addr[15:2]] : uart_words[addr[3:2]];
  endfunction
  always_comb begin
    mem_rd_req_ready=!rst&&!rd_pending&&(delay==0 || random_state[0]);
    mem_wr_req_ready=!rst&&(!wr_pending||!wr_input_done)&&(delay==0 || random_state[3]);
    mem_rd_rsp_valid=!rst&&rd_pending&&read_wait==0;
    mem_rd_rsp_error=read_failure(rd_addr,rd_index,rd_len);
    mem_rd_rsp_rdata=mem_rd_rsp_error ? 32'h305f9073 : read_word(rd_addr+32'(rd_index*4));
    mem_rd_rsp_last=rd_index==rd_len;
    mem_wr_rsp_valid=!rst&&wr_pending&&wr_input_done&&write_wait==0;
    mem_wr_rsp_error=write_failure(wr_addr);
  end
  always @(posedge clk) begin
    if(rst) begin
      rd_pending<=0; wr_pending<=0; wr_input_done<=0;
      random_state<=16'(seed); read_wait<=0; write_wait<=0;
      check_trap_csr<=0; shadow_wb_pc<=0;
    end else begin
      random_state<={random_state[14:0],random_state[15]^random_state[13]^random_state[12]^random_state[10]};
      if(read_wait>0) read_wait<=read_wait-1;
      if(write_wait>0) write_wait<=write_wait-1;
      if(mem_rd_req_valid&&mem_rd_req_ready) begin
        if(rd_pending) $fatal(1,"overlapping reads");
        rd_pending<=1; rd_addr<=mem_rd_req_addr; rd_len<=int'(mem_rd_req_len); rd_index<=0;
        read_wait<=delay==0 ? 0:int'(random_state[3:0])%(delay+1);
      end
      if(mem_rd_rsp_valid&&mem_rd_rsp_ready) begin
        if(mem_rd_rsp_error) error_reads++;
        if(mem_rd_rsp_last) rd_pending<=0;
        else begin
          rd_index<=rd_index+1;
          read_wait<=delay==0 ? 0:int'(random_state[7:4])%(delay+1);
        end
      end
      if(mem_wr_req_valid&&mem_wr_req_ready) begin
        int index;
        reg [31:0] addr;
        index=wr_pending ? wr_index:0;
        addr=mem_wr_req_addr+32'(index*4);
        if(mem_wr_req_wlast!==(index==int'(mem_wr_req_len))) $fatal(1,"write LAST");
        if(!wr_pending) begin wr_pending<=1; wr_addr<=mem_wr_req_addr; wr_len<=int'(mem_wr_req_len); end
        else if(mem_wr_req_addr!=wr_addr||int'(mem_wr_req_len)!=wr_len) $fatal(1,"write header changed");
        wr_index<=index+1; wr_input_done<=mem_wr_req_wlast;
        // Failed writes do not alter this model. Split stores may already have
        // committed an earlier successful beat; the test checks that behavior.
        if(!write_failure(addr)) for(int lane=0;lane<4;lane++) if(mem_wr_req_wstrb[lane]) begin
          if(addr[31:16]==16'h8000) words[addr[15:2]][lane*8+:8]<=mem_wr_req_wdata[lane*8+:8];
          else uart_words[addr[3:2]][lane*8+:8]<=mem_wr_req_wdata[lane*8+:8];
        end
        if(addr==32'h80001000) tohost<=mem_wr_req_wdata;
        write_wait<=case_id==18 && addr==32'h80001004 ? 70 : delay;
      end
      if(mem_wr_rsp_valid&&mem_wr_rsp_ready) begin
        if(mem_wr_rsp_error) error_writes++;
        wr_pending<=0; wr_input_done<=0;
      end
      if(dut.if_rsp_fire&&dut.if_rsp_error&&(dut.if_request_killed||dut.frontend_flush)) killed_errors++;
      if(dut.retire_pulse) begin
        retired++;
        if(traps>0 && shadow_wb_pc==expected_pc) $fatal(1,"faulting instruction retired");
      end
      if(dut.flush_dataram_wb) shadow_wb_pc<=0;
      else if(!dut.stall_dataram_wb) shadow_wb_pc<=dut.mem_instruction_pc;
      if(check_trap_csr) begin
        if(dut.csr0.mcause!==expected_cause || dut.csr0.mepc!==expected_pc || dut.csr0.mtval!==expected_tval)
          $fatal(1,"trap CSR mismatch cause=%h pc=%h tval=%h",dut.csr0.mcause,dut.csr0.mepc,dut.csr0.mtval);
        if(dut.csr0.mstatus_mie || !dut.csr0.mstatus_mpie) $fatal(1,"trap status");
      end
      check_trap_csr<=dut.trap_fire;
      if(dut.trap_fire) begin
        if(case_id==11||case_id==17||traps!=0) $fatal(1,"unexpected/duplicate trap case=%0d",case_id);
        traps++; expected_cause<=dut.trap_cause; expected_pc<=dut.trap_pc; expected_tval<=dut.trap_tval;
        case(dut.trap_cause)
          0:begin end // Separately classified instruction-target alignment.
          1:fetch_traps++;
          5:load_traps++;
          7:store_traps++;
          default:$fatal(1,"wrong trap cause %0d",dut.trap_cause);
        endcase
        if(dut.mem_trap_fire && (dut.ex_fire||dut.bp_update_valid)) $fatal(1,"younger EX escaped data trap");
        $display("[FAULT-TRAP] cause=%0d mepc=%h mtval=%h retired=%0d",dut.trap_cause,dut.trap_pc,dut.trap_tval,retired);
      end
      if(tohost!=0) begin
        if(tohost!=1) $fatal(1,"program failed case=%0d cause=%h pc=%h tval=%h a2=%h s4=%h",case_id,dut.csr0.mcause,dut.csr0.mepc,dut.csr0.mtval,dut.registerfile0.i0.rf[12],dut.registerfile0.i0.rf[20]);
        if(traps!=((case_id==11||case_id==17)?0:1)) $fatal(1,"missing trap");
        if((case_id==11||case_id==17)&&killed_errors==0) $fatal(1,"wrong-path error not exercised");
        $display("[ACCESS-FAULTS] PASS case=%0d I=%0d D=%0d delay=%0d beat=%0d traps=%0d Rerrors=%0d Werrors=%0d killed_errors=%0d retired=%0d",case_id,ICACHE_ENABLE,DCACHE_ENABLE,delay,fault_beat,traps,error_reads,error_writes,killed_errors,retired);
        $finish;
      end
    end
  end
  initial begin
    if(!$value$plusargs("image=%s",image_path)) $fatal(1,"missing image");
    if($value$plusargs("case=%d",case_id)) begin end
    if($value$plusargs("delay=%d",delay)) begin end
    if($value$plusargs("seed=%d",seed)) begin end
    if($value$plusargs("fault_beat=%d",fault_beat)) begin end
    if($value$plusargs("wrong_path_pc=%h",wrong_path_pc)) begin end
    if($value$plusargs("wave=%s",wave)) begin $dumpfile(wave); $dumpvars(0,access_faults_tb); end
    for(int k=0;k<16384;k++) words[k]=0;
    for(int k=0;k<4;k++) uart_words[k]=0;
    $readmemh(image_path,words); words[32'hff00>>2]=32'(case_id);
    repeat(4) @(negedge clk); rst=0;
  end
  initial begin #2000000; $fatal(1,"timeout case=%0d",case_id); end
endmodule

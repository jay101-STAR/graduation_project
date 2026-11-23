`timescale 1ns / 1ns
// External channel scoreboards: no comparisons against DUT internal counters.
module axi4_parallel_tb;
  reg clk=0, rst=1;
  always #5 clk=~clk;
  reg [1:0] s_req_valid=0, s_req_write=0, s_rsp_ready=0;
  reg [63:0] s_req_addr=0, s_req_wdata=0;
  reg [15:0] s_req_len=0;
  reg [7:0] s_req_wstrb=0;
  reg s_req_wlast=0;
  wire [1:0] s_req_ready, s_rsp_valid, s_rsp_error, s_rsp_last;
  wire [63:0] s_rsp_rdata;
  wire rd_req_valid, rd_req_ready, rd_rsp_valid, rd_rsp_ready, rd_rsp_error, rd_rsp_last;
  wire [31:0] rd_req_addr, rd_rsp_rdata;
  wire [7:0] rd_req_len;
  wire wr_req_valid, wr_req_ready, wr_rsp_valid, wr_rsp_ready, wr_rsp_error, wr_req_wlast;
  wire [31:0] wr_req_addr, wr_req_wdata;
  wire [7:0] wr_req_len;
  wire [3:0] wr_req_wstrb;
  wire  m_axi_awid;
  wire [31:0] m_axi_awaddr;
  wire [ 7:0] m_axi_awlen;
  wire [ 2:0] m_axi_awsize;
  wire [ 1:0] m_axi_awburst;
  wire  m_axi_awlock;
  wire [ 3:0] m_axi_awcache;
  wire [ 2:0] m_axi_awprot;
  wire [ 3:0] m_axi_awqos;
  wire [ 3:0] m_axi_awregion;
  wire  m_axi_awvalid;
  reg  m_axi_awready=0;
  wire  m_axi_arid;
  wire [31:0] m_axi_araddr;
  wire [ 7:0] m_axi_arlen;
  wire [ 2:0] m_axi_arsize;
  wire [ 1:0] m_axi_arburst;
  wire  m_axi_arlock;
  wire [ 3:0] m_axi_arcache;
  wire [ 2:0] m_axi_arprot;
  wire [ 3:0] m_axi_arqos;
  wire [ 3:0] m_axi_arregion;
  wire  m_axi_arvalid;
  reg  m_axi_arready=0;
  wire [31:0] m_axi_wdata;
  wire [ 3:0] m_axi_wstrb;
  wire  m_axi_wlast;
  wire  m_axi_wvalid;
  reg  m_axi_wready=0;
  reg  m_axi_bid=0;
  reg [ 1:0] m_axi_bresp=0;
  reg  m_axi_bvalid=0;
  wire  m_axi_bready;
  reg  m_axi_rid=0;
  reg [31:0] m_axi_rdata=0;
  reg [ 1:0] m_axi_rresp=0;
  reg  m_axi_rlast=0;
  reg  m_axi_rvalid=0;
  wire  m_axi_rready;
  mem_burst_arbiter arbiter(.*);
  axi4_master master(.*);
  reg rd_pending=0, aw_pending=0, b_consumed=0;
  reg [31:0] read_addr=0, write_addr=32'h80004000;
  int read_len=0, read_index=0, write_len=15, write_index=0;
  int aw_seen=0, ar_seen=0, b_seen=0, r_seen=0;
  reg hold_ar=0, hold_aw=0, hold_w=0, hold_r=0, hold_b=0;
  reg random_waits=0, read_error=0, write_error=0;
  reg [15:0] random_state=16'h91ed;
  int overlap=0, simultaneous_rw=0, simultaneous_rb=0, checks=0, seed=493;
  reg ar_blocked=0, aw_blocked=0, w_blocked=0;
  reg [39:0] held_ar, held_aw;
  reg [36:0] held_w;
  string wave, label;
  function automatic [31:0] data_word(input [31:0] addr,input int index);
    return addr ^ (32'(index)*32'h13251749);
  endfunction
  function automatic [3:0] mask(input int index);
    return index%4==0 ? 4'hf : index%4==1 ? 4'h3 : index%4==2 ? 4'h0 : 4'h8;
  endfunction
  always_comb begin
    m_axi_arready=!rst && !hold_ar && (!rd_pending || (m_axi_rvalid && m_axi_rready && m_axi_rlast)) && (!random_waits || random_state[0]);
    m_axi_awready=!rst && !hold_aw && !aw_pending && (!random_waits || random_state[3]);
    m_axi_wready=!rst && !hold_w && write_index<=write_len && (!random_waits || random_state[6]);
    m_axi_rvalid=!rst && rd_pending && !hold_r;
    m_axi_rdata=data_word(read_addr,read_index);
    m_axi_rlast=read_index==read_len;
    m_axi_rresp=read_error && read_index==read_len/2 ? 2'b10:0;
    m_axi_bvalid=!rst && aw_pending && write_index==write_len+1 && !b_consumed && !hold_b;
    m_axi_bresp=write_error ? 2'b11:0;
  end
  always @(negedge clk) random_state={random_state[14:0],random_state[15]^random_state[13]^random_state[12]^random_state[10]};
  always @(posedge clk) begin
    if(rst) begin
      rd_pending<=0; aw_pending<=0; b_consumed<=0;
      read_index<=0; write_index<=0; aw_seen<=0; ar_seen<=0; b_seen<=0; r_seen<=0;
      ar_blocked<=0; aw_blocked<=0; w_blocked<=0;
    end else begin
      if(ar_blocked && (!m_axi_arvalid || {m_axi_araddr,m_axi_arlen}!==held_ar)) $fatal(1,"AR unstable");
      if(aw_blocked && (!m_axi_awvalid || {m_axi_awaddr,m_axi_awlen}!==held_aw)) $fatal(1,"AW unstable");
      if(w_blocked && (!m_axi_wvalid || {m_axi_wdata,m_axi_wstrb,m_axi_wlast}!==held_w)) $fatal(1,"W unstable");
      ar_blocked<=m_axi_arvalid&&!m_axi_arready; held_ar<={m_axi_araddr,m_axi_arlen};
      aw_blocked<=m_axi_awvalid&&!m_axi_awready; held_aw<={m_axi_awaddr,m_axi_awlen};
      w_blocked<=m_axi_wvalid&&!m_axi_wready; held_w<={m_axi_wdata,m_axi_wstrb,m_axi_wlast};
      if(rd_pending && (aw_pending || write_index>0) && !b_consumed) overlap++;
      if(m_axi_rvalid&&m_axi_rready&&m_axi_wvalid&&m_axi_wready) simultaneous_rw++;
      if(m_axi_rvalid&&m_axi_rready&&m_axi_bvalid&&m_axi_bready) simultaneous_rb++;
      if(m_axi_rvalid&&m_axi_rready) begin
        read_index<=read_index+1; r_seen <= r_seen+1;
        if(m_axi_rlast) rd_pending<=0;
      end
      if(m_axi_arvalid&&m_axi_arready) begin
        if(rd_pending && !(m_axi_rvalid&&m_axi_rready&&m_axi_rlast)) $fatal(1,"two reads in flight");
        rd_pending<=1; read_addr<=m_axi_araddr; read_len<=int'(m_axi_arlen); read_index<=0; ar_seen <= ar_seen+1;
      end
      if(m_axi_awvalid&&m_axi_awready) begin
        if(aw_seen!=0 || m_axi_awaddr!=write_addr || int'(m_axi_awlen)!=write_len) $fatal(1,"AW header/duplicate");
        aw_pending<=1; aw_seen <= aw_seen+1;
      end
      if(m_axi_wvalid&&m_axi_wready) begin
        if(m_axi_wdata!==data_word(write_addr,write_index) || m_axi_wstrb!==mask(write_index) ||
           m_axi_wlast!==(write_index==write_len)) $fatal(1,"W beat mismatch %0d",write_index);
        write_index<=write_index+1;
      end
      if(m_axi_bvalid&&m_axi_bready) begin b_consumed<=1; b_seen <= b_seen+1; end
    end
  end
  task automatic reset_case(input string name,input int len=15);
    @(negedge clk); rst=1; s_req_valid=0; s_rsp_ready=0; label=name; write_len=len;
    hold_ar=0; hold_aw=0; hold_w=0; hold_r=0; hold_b=0;
    read_error=0; write_error=0; random_waits=0;
    repeat(3) @(negedge clk); rst=0;
  endtask
  task automatic read_txn(input int lane,input int len,input int stalls=0,input bit invalid=0);
    reg [31:0] addr;
    int n;
    addr=invalid ? 32'h80002001 : 32'h80002000;
    @(negedge clk); s_req_addr[lane*32+:32]=addr; s_req_len[lane*8+:8]=8'(len);
    s_req_write[lane]=0; s_req_valid[lane]=1;
    do @(posedge clk); while(!s_req_ready[lane]);
    @(negedge clk); s_req_valid[lane]=0;
    n=invalid ? 1:len+1;
    for(int k=0;k<n;k++) begin
      repeat(stalls) @(negedge clk);
      s_rsp_ready[lane]=1;
      do @(posedge clk); while(!s_rsp_valid[lane]);
      if(s_rsp_rdata[lane*32+:32] !== (invalid ? 32'b0:data_word(addr,k)) ||
         s_rsp_error[lane] !== (invalid || (read_error&&k==len/2)) || s_rsp_last[lane] !== (k==n-1))
        $fatal(1,"%s read routing lane=%0d beat=%0d",label,lane,k);
      @(negedge clk); s_rsp_ready[lane]=0;
    end
  endtask
  task automatic write_txn(input int len,input int stalls=0,input bit invalid=0);
    @(negedge clk);
    s_req_addr[63:32]=invalid ? 32'h80004001:write_addr; s_req_len[15:8]=8'(len); s_req_write[1]=1;
    for(int k=0;k<=len;k++) begin
      s_req_wdata[63:32]=data_word(write_addr,k); s_req_wstrb[7:4]=mask(k); s_req_wlast=k==len; s_req_valid[1]=1;
      do @(posedge clk); while(!s_req_ready[1]);
      @(negedge clk); s_req_valid[1]=0;
      repeat(k%3) @(negedge clk);
    end
    repeat(stalls) @(negedge clk); s_rsp_ready[1]=1;
    do @(posedge clk); while(!s_rsp_valid[1]);
    if(s_rsp_rdata[63:32]!==0 || s_rsp_error[1] !== (invalid||write_error) || !s_rsp_last[1])
      $fatal(1,"%s write response routing",label);
    @(negedge clk); s_rsp_ready[1]=0;
  endtask
  task automatic passed;
    if(aw_seen!=1 || write_index!=write_len+1 || b_seen!=1 || ar_seen!=1 || r_seen!=read_len+1)
      $fatal(1,"%s lost/duplicate transfers AW=%0d W=%0d B=%0d AR=%0d R=%0d",label,aw_seen,write_index,b_seen,ar_seen,r_seen);
    checks++; $display("[PARALLEL-CASE] PASS %s",label);
  endtask
  initial begin
    if($value$plusargs("wave=%s",wave)) begin $dumpfile(wave); $dumpvars(0,axi4_parallel_tb); end
    if($value$plusargs("seed=%d",seed)) begin end
    random_state=16'(seed);
    reset_case("concurrent bursts");
    fork read_txn(0,15,1); write_txn(15,3); join
    passed();
    reset_case("W stalled, read completes"); hold_w=1;
    fork
      write_txn(15);
      begin read_txn(0,15); if(write_index!=0) $fatal(1,"W was not held"); hold_w=0; end
    join
    passed();
    reset_case("AW stalled, read completes and W proceeds"); hold_aw=1;
    fork
      write_txn(15);
      begin read_txn(0,15,2); if(aw_seen!=0) $fatal(1,"AW was not held"); hold_aw=0; end
    join
    passed();
    reset_case("AR stalled, write completes"); hold_ar=1;
    fork
      read_txn(0,15);
      begin write_txn(15); if(ar_seen!=0) $fatal(1,"AR was not held"); hold_ar=0; end
    join
    passed();
    reset_case("R stalled, write completes"); hold_r=1;
    fork
      read_txn(0,15);
      begin write_txn(15,4); if(r_seen!=0) $fatal(1,"R was not held"); hold_r=0; end
    join
    passed();
    reset_case("B stalled, read completes"); hold_b=1;
    fork
      write_txn(15);
      begin read_txn(0,15,3); if(b_seen!=0) $fatal(1,"B was not held"); hold_b=0; end
    join
    passed();
    for(int k=0;k<4;k++) begin
      reset_case($sformatf("independent errors %0d",k)); random_waits=1;
      read_error=1'(k&1); write_error=1'((k>>1)&1);
      fork read_txn(0,15,2); write_txn(15,6); join
      passed();
    end
    // Hold a single R and B, then consume both with opposite error values.
    for(int k=0;k<2;k++) begin
      reset_case($sformatf("simultaneous R/B errors %0d",k),0); hold_r=1; hold_b=1;
      read_error=1'(k); write_error=!1'(k);
      fork
        read_txn(0,0,1);
        write_txn(0,1);
        begin
          wait(rd_pending && aw_pending && write_index==1);
          repeat(4) @(negedge clk); hold_r=0; hold_b=0;
        end
      join
      passed();
    end
    reset_case("invalid read does not block write");
    fork read_txn(0,15,2,1); write_txn(15); join
    if(ar_seen!=0 || aw_seen!=1 || b_seen!=1) $fatal(1,"bad read isolation"); checks++;
    reset_case("invalid write drains while read proceeds");
    fork read_txn(0,15,1); write_txn(15,2,1); join
    if(aw_seen!=0 || write_index!=0 || b_seen!=0 || r_seen!=16) $fatal(1,"bad write isolation"); checks++;
    // Reset both transactions with all address/data channels blocked.
    reset_case("reset cancels both"); hold_ar=1; hold_aw=1; hold_w=1;
    @(negedge clk); s_req_valid=3; s_req_write=2; s_req_len=16'h0f0f;
    s_req_addr={write_addr,32'h80002000}; s_req_wlast=0;
    @(posedge clk); if(s_req_ready!=3) $fatal(1,"reset setup acceptance");
    @(negedge clk); s_req_valid=0; rst=1;
    repeat(3) @(negedge clk);
    if(m_axi_awvalid||m_axi_arvalid||m_axi_wvalid||s_rsp_valid) $fatal(1,"reset retained work"); checks++;
    reset_case("reset cancels held R and B",0); hold_r=1; hold_b=1;
    @(negedge clk); s_req_valid=3; s_req_write=2; s_req_len=0;
    s_req_addr={write_addr,32'h80002000}; s_req_wlast=1;
    s_req_wdata[63:32]=data_word(write_addr,0); s_req_wstrb[7:4]=mask(0);
    @(posedge clk); if(s_req_ready!=3) $fatal(1,"response reset setup acceptance");
    @(negedge clk); s_req_valid=0;
    wait(rd_pending && aw_pending && write_index==1);
    @(negedge clk); rst=1;
    repeat(3) @(negedge clk);
    if(m_axi_rready||m_axi_bready||s_rsp_valid) $fatal(1,"reset retained responses"); checks++;
    reset_case("after reset"); fork read_txn(0,15); write_txn(15); join passed();
    if(overlap==0 || simultaneous_rw==0 || simultaneous_rb<2) $fatal(1,"missing concurrency coverage");
    $display("[AXI4-PARALLEL] PASS checks=%0d overlap_cycles=%0d simultaneous_RW=%0d simultaneous_RB=%0d",checks,overlap,simultaneous_rw,simultaneous_rb);
    $finish;
  end
  initial begin #1000000; $fatal(1,"parallel timeout %s",label); end
endmodule

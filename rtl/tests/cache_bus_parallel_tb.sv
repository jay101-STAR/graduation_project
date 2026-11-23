`timescale 1ns / 1ns
// External channel scoreboards: no comparisons against DUT internal counters.
module cache_bus_parallel_tb;
  reg clk=0, rst=1;
  always #5 clk=~clk;
  wire [1:0] s_req_valid, s_req_write, s_rsp_ready;
  wire [63:0] s_req_addr, s_req_wdata;
  wire [15:0] s_req_len;
  wire [7:0] s_req_wstrb;
  wire s_req_wlast;
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
  wire  m_axi_awready;
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
  wire  m_axi_arready;
  wire [31:0] m_axi_wdata;
  wire [ 3:0] m_axi_wstrb;
  wire  m_axi_wlast;
  wire  m_axi_wvalid;
  wire  m_axi_wready;
  wire  m_axi_bid;
  wire [ 1:0] m_axi_bresp;
  wire  m_axi_bvalid;
  wire  m_axi_bready;
  wire  m_axi_rid;
  wire [31:0] m_axi_rdata;
  wire [ 1:0] m_axi_rresp;
  wire  m_axi_rlast;
  wire  m_axi_rvalid;
  wire  m_axi_rready;
  reg [1:0] cpu_req_valid=0, cpu_req_write=0, cpu_rsp_ready=0, cpu_cacheable=3;
  wire [1:0] cpu_req_ready, cpu_rsp_valid, cpu_rsp_error;
  reg [67:0] cpu_req_addr=0;
  reg [63:0] cpu_req_wdata=0;
  reg [7:0] cpu_req_wstrb=0;
  wire [63:0] cpu_rsp_rdata;
  wire [3:0] cpu_rsp_source;
  reg [1:0] maint_req_valid=0;
  wire [1:0] maint_req_ready, maint_done_valid;
  wire maint_error;
  reg [31:0] expected [0:16383];
  int checks=0, overlap_cycles=0, parallel_rw=0, aw_count=0, b_count=0;
  int wb_index=0;
  reg read_pending=0, write_pending=0, read_owner=0;
  reg [31:0] wb_addr=0;
  string wave;
  icache_phys_word #(.ICACHE_ENABLE(1)) icache_adapter (
    .clk(clk), .rst(rst), .req_valid(cpu_req_valid[0]), .req_ready(cpu_req_ready[0]),
    .req_addr(cpu_req_addr[33:0]), .req_write(cpu_req_write[0]),
    .req_wdata(cpu_req_wdata[31:0]), .req_wstrb(cpu_req_wstrb[3:0]),
    .req_access_ok(1'b1), .req_cacheable(cpu_cacheable[0]),
    .rsp_valid(cpu_rsp_valid[0]), .rsp_ready(cpu_rsp_ready[0]),
    .rsp_rdata(cpu_rsp_rdata[31:0]), .rsp_error(cpu_rsp_error[0]), .rsp_source(cpu_rsp_source[1:0]),
    .mem_req_valid(s_req_valid[0]), .mem_req_ready(s_req_ready[0]),
    .mem_req_addr(s_req_addr[31:0]), .mem_req_len(s_req_len[7:0]),
    .mem_req_write(s_req_write[0]), .mem_req_wdata(s_req_wdata[31:0]), .mem_req_wstrb(s_req_wstrb[3:0]),
    .mem_rsp_valid(s_rsp_valid[0]), .mem_rsp_ready(s_rsp_ready[0]),
    .mem_rsp_rdata(s_rsp_rdata[31:0]), .mem_rsp_error(s_rsp_error[0]),
    .mem_rsp_last(s_rsp_last[0]),
    .maint_req_valid(maint_req_valid[0]), .maint_req_ready(maint_req_ready[0]),
    .maint_done_valid(maint_done_valid[0]), .maint_done_ready(1'b1)
  );
  dcache_phys_word #(.DCACHE_ENABLE(1)) dcache_adapter (
    .clk(clk), .rst(rst), .req_valid(cpu_req_valid[1]), .req_ready(cpu_req_ready[1]),
    .req_addr(cpu_req_addr[67:34]), .req_write(cpu_req_write[1]),
    .req_wdata(cpu_req_wdata[63:32]), .req_wstrb(cpu_req_wstrb[7:4]),
    .req_access_ok(1'b1), .req_cacheable(cpu_cacheable[1]),
    .rsp_valid(cpu_rsp_valid[1]), .rsp_ready(cpu_rsp_ready[1]),
    .rsp_rdata(cpu_rsp_rdata[63:32]), .rsp_error(cpu_rsp_error[1]), .rsp_source(cpu_rsp_source[3:2]),
    .mem_req_valid(s_req_valid[1]), .mem_req_ready(s_req_ready[1]),
    .mem_req_addr(s_req_addr[63:32]), .mem_req_len(s_req_len[15:8]),
    .mem_req_write(s_req_write[1]), .mem_req_wdata(s_req_wdata[63:32]), .mem_req_wstrb(s_req_wstrb[7:4]),
    .mem_rsp_valid(s_rsp_valid[1]), .mem_rsp_ready(s_rsp_ready[1]),
    .mem_rsp_rdata(s_rsp_rdata[63:32]), .mem_rsp_error(s_rsp_error[1]),
    .mem_rsp_rlast(s_rsp_last[1]),
    .mem_req_wlast(s_req_wlast), .maint_error(maint_error),
    .maint_req_valid(maint_req_valid[1]), .maint_req_ready(maint_req_ready[1]),
    .maint_done_valid(maint_done_valid[1]), .maint_done_ready(1'b1)
  );
  mem_burst_arbiter arbiter(.*);
  axi4_master master(.*);
  axi4_subsystem #(.RAM_BANK0_HEX(""), .RAM_BANK1_HEX("")) subsystem (
    .clk(clk), .rst(rst), .uart_rxd(1'b1), .uart_txd(), .tohost_value(),
    .s_axi_awid(m_axi_awid),
    .s_axi_awaddr(m_axi_awaddr),
    .s_axi_awlen(m_axi_awlen),
    .s_axi_awsize(m_axi_awsize),
    .s_axi_awburst(m_axi_awburst),
    .s_axi_awlock(m_axi_awlock),
    .s_axi_awcache(m_axi_awcache),
    .s_axi_awprot(m_axi_awprot),
    .s_axi_awqos(m_axi_awqos),
    .s_axi_awregion(m_axi_awregion),
    .s_axi_awvalid(m_axi_awvalid),
    .s_axi_awready(m_axi_awready),
    .s_axi_arid(m_axi_arid),
    .s_axi_araddr(m_axi_araddr),
    .s_axi_arlen(m_axi_arlen),
    .s_axi_arsize(m_axi_arsize),
    .s_axi_arburst(m_axi_arburst),
    .s_axi_arlock(m_axi_arlock),
    .s_axi_arcache(m_axi_arcache),
    .s_axi_arprot(m_axi_arprot),
    .s_axi_arqos(m_axi_arqos),
    .s_axi_arregion(m_axi_arregion),
    .s_axi_arvalid(m_axi_arvalid),
    .s_axi_arready(m_axi_arready),
    .s_axi_wdata(m_axi_wdata),
    .s_axi_wstrb(m_axi_wstrb),
    .s_axi_wlast(m_axi_wlast),
    .s_axi_wvalid(m_axi_wvalid),
    .s_axi_wready(m_axi_wready),
    .s_axi_bid(m_axi_bid),
    .s_axi_bresp(m_axi_bresp),
    .s_axi_bvalid(m_axi_bvalid),
    .s_axi_bready(m_axi_bready),
    .s_axi_rid(m_axi_rid),
    .s_axi_rdata(m_axi_rdata),
    .s_axi_rresp(m_axi_rresp),
    .s_axi_rlast(m_axi_rlast),
    .s_axi_rvalid(m_axi_rvalid),
    .s_axi_rready(m_axi_rready)
  );
  function automatic [31:0] initial_word(input int index);
    return 32'ha5a50000 ^ (32'(index)*32'h00010001);
  endfunction
  always @(posedge clk) if(!rst) begin
    if(read_pending && !read_owner && write_pending) overlap_cycles++;
    if(m_axi_rvalid&&m_axi_rready&&m_axi_wvalid&&m_axi_wready) parallel_rw++;
    if(m_axi_rvalid&&m_axi_rready&&m_axi_rlast) read_pending<=0;
    if(m_axi_arvalid&&m_axi_arready) begin
      read_pending<=1; read_owner<=arbiter.rd_owner;
      if(rd_req_valid&&rd_req_ready) read_owner<=arbiter.rd_grant;
    end
    if(m_axi_bvalid&&m_axi_bready) begin
      if(!write_pending || wb_index!=16 || m_axi_bresp!=0) $fatal(1,"writeback B/count");
      write_pending<=0; b_count++;
    end
    if(m_axi_awvalid&&m_axi_awready) begin
      if(write_pending || m_axi_awlen!=15) $fatal(1,"writeback AW");
      write_pending<=1; wb_addr<=m_axi_awaddr; wb_index<=0; aw_count++;
    end
    if(m_axi_wvalid&&m_axi_wready) begin
      // The production interconnect holds W until AW has selected the slave.
      if(!write_pending || m_axi_wstrb!=15 || m_axi_wlast!==(wb_index==15) ||
         m_axi_wdata!==expected[(wb_addr[15:0]>>2)+wb_index])
        $fatal(1,"writeback payload mismatch addr=%h beat=%0d",wb_addr,wb_index);
      wb_index<=wb_index+1;
    end
    if(rd_req_valid&&rd_req_ready&&arbiter.rd_grant&&write_pending)
      $fatal(1,"DCache refill started before its writeback completed");
  end
  task automatic cpu_word(input int lane,input bit wr,input [31:0] addr,input [31:0] data=0,input [3:0] mask=15);
    @(negedge clk);
    cpu_req_addr[lane*34+:34]={2'b0,addr}; cpu_req_write[lane]=wr;
    cpu_req_wdata[lane*32+:32]=data; cpu_req_wstrb[lane*4+:4]=wr ? mask:4'b0;
    cpu_req_valid[lane]=1;
    do @(posedge clk); while(!cpu_req_ready[lane]);
    @(negedge clk); cpu_req_valid[lane]=0;
    repeat(3) @(negedge clk); cpu_rsp_ready[lane]=1;
    do @(posedge clk); while(!cpu_rsp_valid[lane]);
    if(cpu_rsp_error[lane] || (!wr && cpu_rsp_rdata[lane*32+:32]!==expected[addr[15:2]]))
      $fatal(1,"cache result lane=%0d wr=%b addr=%h actual=%h expected=%h",lane,wr,addr,cpu_rsp_rdata[lane*32+:32],expected[addr[15:2]]);
    @(negedge clk); cpu_rsp_ready[lane]=0;
    if(wr) for(int byte_index=0;byte_index<4;byte_index++)
      if(mask[byte_index]) expected[addr[15:2]][byte_index*8+:8]=data[byte_index*8+:8];
    checks++;
  endtask
  task automatic maintain(input int lane);
    @(negedge clk); maint_req_valid[lane]=1;
    do @(posedge clk); while(!maint_req_ready[lane]);
    @(negedge clk); maint_req_valid[lane]=0;
    do @(posedge clk); while(!maint_done_valid[lane]);
    if(lane==1 && maint_error) $fatal(1,"DCache clean failed");
    @(negedge clk); checks++;
  endtask
  initial begin
    if($value$plusargs("wave=%s",wave)) begin $dumpfile(wave); $dumpvars(0,cache_bus_parallel_tb); end
    #1;
    for(int k=0;k<16384;k++) begin
      expected[k]=initial_word(k);
      if(k%2==0) subsystem.ram.bank0.mem[k/2]=expected[k];
      else subsystem.ram.bank1.mem[k/2]=expected[k];
    end
    repeat(4) @(negedge clk); rst=0;
    // Four dirty ways share a set. The fifth allocation evicts one full line.
    for(int k=0;k<4;k++) cpu_word(1,1,32'h80002008+32'(k*8192),32'h12345678+32'(k),4'hf);
    fork
      cpu_word(1,1,32'h8000a008,32'h87654321,4'hf);
      begin wait(wr_req_valid); cpu_word(0,0,32'h8000c00c); end
    join
    // Overlap real clean writebacks with instruction misses in other sets.
    fork
      maintain(1);
      begin
        wait(wr_req_valid);
        for(int k=0;k<8;k++) cpu_word(0,0,32'h8000c04c+32'(k*64));
      end
    join
    if(aw_count!=5 || b_count!=5 || overlap_cycles==0 || parallel_rw==0)
      $fatal(1,"real cache overlap missing AW=%0d B=%0d overlap=%0d RW=%0d",aw_count,b_count,overlap_cycles,parallel_rw);
    cpu_cacheable[1]=0;
    for(int k=0;k<5;k++) cpu_word(1,0,32'h80002008+32'(k*8192));
    // FENCE.I ordering: completed D clean, then I invalidate, then fetch code.
    maintain(0); cpu_word(0,0,32'h80002008);
    $display("[CACHE-BUS-PARALLEL] PASS checks=%0d writebacks=%0d overlap_cycles=%0d simultaneous_RW=%0d",checks,aw_count,overlap_cycles,parallel_rw);
    $finish;
  end
  initial begin #2000000; $fatal(1,"cache parallel timeout"); end
endmodule

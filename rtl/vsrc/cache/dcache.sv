// cache 总大小为32KB , 有512个cache line,128 个 set, 每个set 4个line
module dcache (
    // 时钟与复位
    input logic clk,
    input logic rst_n,

    // 上游：接收 LSU 字请求
    input  logic        cpu_req_valid,
    input  logic [33:0] cpu_req_addr,
    input  logic [31:0] cpu_req_wdata,
    input  logic [ 3:0] cpu_req_wstrb,
    input  logic        cpu_req_write,
    output logic        cpu_req_ready,

    // 上游：返回读数据或写完成响应
    input  logic        cpu_rsp_ready,
    output logic        cpu_rsp_valid,
    output logic [31:0] cpu_rsp_rdata,
    output logic        cpu_rsp_error,

    // 下游：发出读或写请求
    input  logic        mem_req_ready,
    output logic        mem_req_valid,
    output logic [33:0] mem_req_addr,
    output logic [ 7:0] mem_req_len,
    output logic        mem_req_wlast,
    output logic        mem_req_write,
    output logic [31:0] mem_req_wdata,

    // 下游：接收单字读取结果
    input  logic        mem_rsp_valid,
    input  logic [31:0] mem_rsp_rdata,
    input  logic        mem_rsp_error,
    input  logic        mem_rsp_rlast,
    output logic        mem_rsp_ready,

    // 整 Cache clean：逐行写回有效脏行，失败保留脏数据并报告错误。
    input  logic maint_req_valid,
    input  logic maint_done_ready,
    output logic maint_req_ready,
    output logic maint_done_valid,
    output logic maint_error
);

  // 缓存阵列内部接口
  logic         ren;
  logic         wen;
  logic [511:0] block_data;
  logic [ 31:0] data;
  logic         hit;
  logic         cpu_req_fire;
  logic         cpu_rsp_fire;
  logic         mem_req_fire;
  logic         mem_rsp_fire;

  typedef enum logic [3:0] {
    IDLE,
    CHECK,
    WRITE_CACHE,
    WRITE_MEM_REQ,
    WRITE_MEM_RSP,
    READ_MEM_REQ,
    READ_MEM_RSP,
    FILL,
    RESP,
    MAINT_SCAN,
    MAINT_NEXT,
    MAINT_DONE
  } state_t;
  state_t curr_state;
  state_t next_state;

  typedef struct packed {
    logic valid;
    logic dirty;
    logic [20:0] tag;
  } cache_entry_t;
  cache_entry_t tag_mem[128][4];
  logic [511:0] data_mem[128][4];

  logic [3:0] way_valid;
  logic [2:0] empty_way;

  logic [4:0] cnt;
  // saved_：已握手接收、正在处理的请求。saved_req_* 在接收时锁存；
  // saved_tag/index/block_offset 由保存地址组合解码，用于控制、替换、写回、补行和 store。
  logic [33:0] saved_req_addr;
  logic [31:0] saved_req_wdata;
  logic [3:0] saved_req_wstrb;
  logic saved_req_write;
  logic [20:0] saved_tag;
  logic [6:0] saved_index;
  logic [5:0] saved_block_offset;

  // array_：送给阵列查询端的组合地址选择器输出，本身不保存请求。
  logic [33:0] array_addr;
  // lookup_：本拍阵列查询使用的地址字段；接收新请求时可与 saved_ 属于不同请求。
  logic [20:0] lookup_tag;
  logic [6:0] lookup_index;
  logic [5:0] lookup_block_offset;

  // 接收当拍直接查询输入地址，后续补行和阵列写入使用保存地址。
  assign array_addr = cpu_req_fire ? cpu_req_addr : saved_req_addr;
  assign lookup_tag = array_addr[33:13];
  assign lookup_index = array_addr[12:6];
  assign lookup_block_offset = array_addr[5:0];
  assign saved_tag = saved_req_addr[33:13];
  assign saved_index = saved_req_addr[12:6];
  assign saved_block_offset = saved_req_addr[5:0];

  // 替换候选属于当前已保存请求，不能跟随下一条请求的查询地址切换。
  assign way_valid = {
    tag_mem[saved_index][3].valid,
    tag_mem[saved_index][2].valid,
    tag_mem[saved_index][1].valid,
    tag_mem[saved_index][0].valid
  };

  // plur_state[2]==1 表示 第2，3组line没有使用过，plur_state[1]==1 表示第3组
  // line没有使用过，plur_state[0]==1表示第1组line没有使用过
  logic [2:0] plur_state[128];
  logic [1:0] used_line;  //被使用的那一行
  logic [1:0] victim_line;  //被替换的那一行
  logic [1:0] hit_line;  //如果hit的话，表示被hit的那一行
  logic response_error;
  // maint_：独立于 CPU 请求的 clean 扫描位置；wb_：当前实际写回的阵列位置。
  logic maint_active;
  logic [6:0] maint_index;
  logic [1:0] maint_line;
  logic [6:0] wb_index;
  logic [1:0] wb_line;
  logic maint_req_fire;
  assign wb_index         = maint_active ? maint_index : saved_index;
  assign wb_line          = maint_active ? maint_line : used_line;
  assign maint_req_ready  = rst_n && (curr_state == IDLE);
  assign maint_req_fire   = maint_req_valid && maint_req_ready;
  assign maint_done_valid = rst_n && (curr_state == MAINT_DONE);
  assign maint_error      = response_error;
  // 判断哪个line是empty, empty_way ==4 判定4个Line都有效
  always_comb begin
    empty_way = 3'd4;
    casez (way_valid)
      4'b???0: empty_way = 3'd0;
      4'b??01: empty_way = 3'd1;
      4'b?011: empty_way = 3'd2;
      4'b0111: empty_way = 3'd3;
      default: empty_way = 3'd4;
    endcase
  end
  // CHECK 当拍用组合候选路判断 dirty，不能读取同拍才更新的 used_line。
  always_comb begin
    victim_line = 2'b00;
    if (empty_way != 3'd4) begin
      victim_line = empty_way[1:0];
    end else begin
      casez (plur_state[saved_index])
        3'b0?0:  victim_line = 2'b00;
        3'b0?1:  victim_line = 2'b01;
        3'b10?:  victim_line = 2'b10;
        3'b11?:  victim_line = 2'b11;
        default: victim_line = 2'b00;
      endcase
    end
  end

  // 本次查询结果在 CHECK 已有效；锁存路号供后续写回、补行和写入使用。
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      used_line <= 2'b00;
    end else if (curr_state == CHECK) begin
      used_line <= hit ? hit_line : victim_line;
    end
  end

  // 命中结果出队时可在同一边沿查询下一地址；背压时保持 inst/hit。
  assign cpu_req_ready = rst_n && !maint_req_valid && ((curr_state == IDLE) ||
                                  ((curr_state == CHECK) && hit && cpu_rsp_ready && !saved_req_write));
  assign cpu_req_fire = cpu_req_valid && cpu_req_ready;
  assign cpu_rsp_fire = cpu_rsp_valid && cpu_rsp_ready;
  assign mem_req_fire = mem_req_valid && mem_req_ready;
  assign mem_rsp_fire = mem_rsp_valid && mem_rsp_ready;
  assign ren = cpu_req_fire || (cnt == 5'd17 && !saved_req_write);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      response_error <= 1'b0;
      maint_active   <= 1'b0;
      maint_index    <= 7'b0;
      maint_line     <= 2'b0;
    end else begin
      if (cpu_req_fire) response_error <= 1'b0;
      if (maint_req_fire) begin
        response_error <= 1'b0;
        maint_active   <= 1'b1;
        maint_index    <= 7'b0;
        maint_line     <= 2'b0;
      end
      if (curr_state == MAINT_NEXT) begin
        if (maint_line == 2'd3) begin
          maint_line  <= 2'b0;
          maint_index <= maint_index + 7'd1;
        end else begin
          maint_line <= maint_line + 2'd1;
        end
      end
      if (mem_rsp_fire && mem_rsp_error &&
          ((curr_state == WRITE_MEM_RSP) || (curr_state == READ_MEM_RSP)))
        response_error <= 1'b1;
      if (maint_done_valid && maint_done_ready) maint_active <= 1'b0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      saved_req_addr  <= 34'b0;
      saved_req_write <= 1'b0;
      saved_req_wdata <= 32'b0;
      saved_req_wstrb <= 4'b0;
    end else begin
      saved_req_addr  <= saved_req_addr;
      saved_req_write <= saved_req_write;
      saved_req_wdata <= saved_req_wdata;
      saved_req_wstrb <= saved_req_wstrb;
      if (cpu_req_fire) begin
        saved_req_addr  <= cpu_req_addr;
        saved_req_write <= cpu_req_write;
        saved_req_wdata <= cpu_req_wdata;
        saved_req_wstrb <= cpu_req_wstrb;
      end
    end
  end

  //三段式状态机
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      curr_state <= IDLE;
    end else begin
      curr_state <= next_state;
    end
  end

  always_comb begin
    next_state = curr_state;
    case (curr_state)
      IDLE: begin
        if (maint_req_fire) begin
          next_state = MAINT_SCAN;
        end else if (cpu_req_fire) begin
          next_state = CHECK;
        end else begin
          next_state = IDLE;
        end
      end
      CHECK: begin
        if (hit) begin
          if (!saved_req_write) begin
            if (cpu_rsp_ready) begin
              next_state = cpu_req_fire ? CHECK : IDLE;
            end else begin
              next_state = CHECK;
            end
          end else begin
            next_state = WRITE_CACHE;
          end
        end else begin
          if (tag_mem[saved_index][victim_line].valid &&
              tag_mem[saved_index][victim_line].dirty) begin
            next_state = WRITE_MEM_REQ;
          end else begin
            next_state = READ_MEM_REQ;
          end
        end
      end
      WRITE_CACHE: begin
        next_state = cpu_rsp_fire ? IDLE : WRITE_CACHE;
      end
      WRITE_MEM_REQ: begin
        if (mem_req_fire && cnt == 5'd15) begin
          next_state = WRITE_MEM_RSP;
        end else begin
          next_state = WRITE_MEM_REQ;
        end
      end
      WRITE_MEM_RSP: begin
        if (mem_rsp_fire) begin
          if (mem_rsp_error) begin
            next_state = maint_active ? MAINT_DONE : RESP;
          end else if (cnt == 5'd16) begin
            next_state = maint_active ? MAINT_NEXT : READ_MEM_REQ;
          end else begin
            next_state = WRITE_MEM_RSP;
          end
        end else begin
          next_state = WRITE_MEM_RSP;
        end
      end
      READ_MEM_REQ: begin
        if (mem_req_fire) begin
          next_state = READ_MEM_RSP;
        end else begin
          next_state = READ_MEM_REQ;
        end
      end
      READ_MEM_RSP: begin
        if (mem_rsp_fire) begin
          if (mem_rsp_rlast) begin
            next_state = (response_error || mem_rsp_error) ? RESP : FILL;
          end
        end else begin
          next_state = READ_MEM_RSP;
        end
      end
      FILL: begin
        if (cnt == 5'd17) begin
          next_state = saved_req_write ? WRITE_CACHE : RESP;
        end
      end
      RESP: begin
        if (cpu_rsp_ready) begin
          next_state = IDLE;
        end
      end
      MAINT_SCAN: begin
        next_state = (tag_mem[maint_index][maint_line].valid &&
                      tag_mem[maint_index][maint_line].dirty) ? WRITE_MEM_REQ : MAINT_NEXT;
      end
      MAINT_NEXT: begin
        next_state = ((maint_index == 7'd127) && (maint_line == 2'd3)) ? MAINT_DONE : MAINT_SCAN;
      end
      MAINT_DONE: begin
        if (maint_done_ready) next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  always_comb begin
    cpu_rsp_valid = 1'b0;
    cpu_rsp_rdata = 32'b0;
    cpu_rsp_error = 1'b0;
    mem_req_valid = 1'b0;
    // 64 字节行首地址加上当前字的字节偏移，完整保留 34 位物理地址。
    mem_req_addr  = {saved_req_addr[33:6], 6'b0} + {27'b0, cnt, 2'b0};
    mem_rsp_ready = 1'b0;
    mem_req_wlast = 1'b0;
    mem_req_write = 1'b0;
    mem_req_wdata = 32'b0;
    mem_req_len   = 7'b0;
    case (curr_state)
      IDLE: begin
      end
      CHECK: begin
        if (hit && !saved_req_write) begin
          cpu_rsp_valid = 1'b1;
          cpu_rsp_rdata = data;
        end
      end
      WRITE_CACHE: begin
        cpu_rsp_valid = 1'b1;
      end
      WRITE_MEM_REQ: begin
        mem_req_write = 1'b1;
        mem_req_addr  = {tag_mem[wb_index][wb_line].tag, wb_index, 6'b0};
        mem_req_wdata = data_mem[wb_index][wb_line][{cnt[3:0], 5'b0}+:32];
        mem_req_valid = 1'b1;
        mem_req_len   = 7'd15;
        if (cnt == 5'd15) begin
          mem_req_wlast = 1'b1;
        end
      end
      WRITE_MEM_RSP: begin
        if (mem_rsp_valid == 1'b1) begin
          mem_rsp_ready = 1'b1;
        end
      end
      READ_MEM_REQ: begin
        mem_req_valid = 1'b1;
        mem_req_len   = 7'd15;
      end
      READ_MEM_RSP: begin
        mem_rsp_ready = 1'b1;
      end
      FILL: begin
      end
      RESP: begin
        cpu_rsp_valid = 1'b1;
        cpu_rsp_rdata = (response_error || saved_req_write) ? 32'b0 : data;
        cpu_rsp_error = response_error;
      end
      default: begin
      end
    endcase
  end

  //更新cnt和wen信号
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt        <= 0;
      block_data <= 0;
      wen        <= 0;
    end else begin
      cnt        <= cnt;
      block_data <= block_data;
      wen        <= 0;
      // Count every accepted response, including errors, until the burst ends.
      if (curr_state == READ_MEM_RSP && mem_rsp_fire) begin
        cnt                              <= cnt + 1;
        block_data[{cnt[3:0], 5'b0}+:32] <= mem_rsp_rdata;
        if (mem_rsp_rlast) begin
          wen <= !(response_error || mem_rsp_error);
        end
      end
      // Count accepted write data beats, then hold until the write response.
      if (curr_state == WRITE_MEM_REQ && mem_req_fire) begin
        cnt <= cnt + 5'd1;
      end else if (curr_state == WRITE_MEM_RSP && mem_rsp_fire) begin
        cnt <= 5'd0;
      end
      if (cnt == 5'd16 && curr_state == FILL) begin
        cnt <= cnt + 1'b1;
      end
      if (curr_state == RESP || curr_state == WRITE_CACHE) begin
        cnt <= 0;
      end
      if (maint_req_fire || curr_state == MAINT_NEXT) begin
        cnt <= 5'd0;
      end
    end
  end

  // dcache 读取
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      data     <= 32'b0;
      hit      <= 1'b0;
      hit_line <= 2'b0;
      for (int i = 0; i < 128; i++) begin
        plur_state[i] <= 3'b0;
      end
    end else begin
      if (ren) begin
        data <= 32'b0;
        hit  <= 0;
        for (int i = 0; i < 4; i++) begin
          if (lookup_tag == tag_mem[lookup_index][i].tag && tag_mem[lookup_index][i].valid) begin
            data     <= data_mem[lookup_index][i][{lookup_block_offset[5:0], 3'b0}+:32];
            hit      <= 1'b1;
            hit_line <= i[1:0];
            case (i)
              0:       plur_state[lookup_index] <= {1'b1, plur_state[lookup_index][1], 1'b1};
              1:       plur_state[lookup_index] <= {1'b1, plur_state[lookup_index][1], 1'b0};
              2:       plur_state[lookup_index][2:1] <= 2'b01;
              3:       plur_state[lookup_index][2:1] <= 2'b00;
              default: plur_state[lookup_index] <= 3'b0;
            endcase
          end
        end
      end else begin
        data     <= data;
        hit      <= cpu_req_fire ? 1'b0 : hit;
        hit_line <= hit_line;
      end
      if (curr_state == WRITE_CACHE) begin
        case (used_line)
          0:       plur_state[saved_index] <= {1'b1, plur_state[saved_index][1], 1'b1};
          1:       plur_state[saved_index] <= {1'b1, plur_state[saved_index][1], 1'b0};
          2:       plur_state[saved_index][2:1] <= 2'b01;
          3:       plur_state[saved_index][2:1] <= 2'b00;
          default: plur_state[saved_index] <= 3'b0;
        endcase
      end
    end
  end

  // dcache 补行
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 128; i++) begin
        for (int j = 0; j < 4; j++) begin
          tag_mem[i][j].valid <= 1'b0;
          tag_mem[i][j].dirty <= 1'b0;
        end
      end
    end else begin
      if (wen) begin
        data_mem[saved_index][used_line]      <= block_data;
        tag_mem[saved_index][used_line].valid <= 1'b1;
        tag_mem[saved_index][used_line].tag   <= saved_tag;
        tag_mem[saved_index][used_line].dirty <= 1'b0;
      end
      //dcache 写入
      if (curr_state == WRITE_CACHE) begin
        for (int b = 0; b < 4; b++) begin
          if (saved_req_wstrb[b]) begin
            data_mem[saved_index][used_line][({saved_block_offset[5:2], 5'b0} + b*8) +: 8]<= saved_req_wdata[b*8 +: 8];
          end
        end
        tag_mem[saved_index][used_line].dirty <= 1'b1;
      end
      // 整行成功写回后才清 dirty；任一写回失败均保留原阵列，允许重试。
      if (curr_state == WRITE_MEM_RSP && mem_rsp_fire && !mem_rsp_error && cnt == 5'd16)
        tag_mem[wb_index][wb_line].dirty <= 1'b0;
    end
  end

endmodule


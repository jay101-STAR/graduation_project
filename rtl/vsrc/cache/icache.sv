// cache 总大小为32KB , 有512个cache line,128 个 set, 每个set 4个line
module icache (
    // 时钟与复位
    input logic clk,
    input logic rst_n,

    // 上游：接收取指请求
    input  logic        cpu_req_valid,
    output logic        cpu_req_ready,
    input  logic [33:0] cpu_req_addr,

    // 上游：返回取指结果
    output logic        cpu_rsp_valid,
    input  logic        cpu_rsp_ready,
    output logic [31:0] cpu_rsp_rdata,
    output logic        cpu_rsp_error,

    // 下游：一笔 16 拍 INCR 补行请求，响应逐拍握手
    output logic        mem_req_valid,
    output logic [33:0] mem_req_addr,
    output logic [ 7:0] mem_req_len,
    input  logic        mem_req_ready,

    // 下游：接收补行数据；错误突发仍排空到 LAST
    input  logic        mem_rsp_valid,
    output logic        mem_rsp_ready,
    input  logic [31:0] mem_rsp_rdata,
    input  logic        mem_rsp_error,
    input  logic        mem_rsp_last
);

  // 缓存阵列内部接口
  logic         ren;
  logic         wen;
  logic [511:0] block_data;
  logic [ 31:0] inst;
  logic         hit;
  logic         cpu_req_fire;
  logic         mem_req_fire;
  logic         mem_rsp_fire;

  typedef enum logic [2:0] {
    IDLE,
    CHECK,
    READ_MEM_REQ,
    READ_MEM_RSP,
    FILL,
    RESP
  } state_t;
  state_t curr_state;
  state_t next_state;

  typedef struct packed {
    logic valid;
    logic [18:0] tag;
  } cache_entry_t;
  cache_entry_t tag_mem[128][4];
  logic [511:0] data_mem[128][4];

  logic [18:0] address_tag;
  logic [6:0] address_index;
  logic [5:0] address_block_offset;
  logic [3:0] way_valid;
  logic [2:0] empty_way;

  logic [4:0] cnt;
  logic refill_error;
  logic [33:0] saved_req_addr;
  logic [33:0] array_addr;

  // 接收当拍直接查询输入地址，后续补行和阵列写入使用保存地址。
  assign array_addr = cpu_req_fire ? cpu_req_addr : saved_req_addr;

  assign address_tag = array_addr[31:13];
  assign address_index = array_addr[12:6];
  assign address_block_offset = array_addr[5:0];
  assign way_valid = {
    tag_mem[address_index][3].valid,
    tag_mem[address_index][2].valid,
    tag_mem[address_index][1].valid,
    tag_mem[address_index][0].valid
  };

  // plur_state[2]==1 表示 第2，3组line没有使用过，plur_state[1]==1 表示第3组
  // line没有使用过，plur_state[0]==1表示第1组line没有使用过
  logic [2:0] plur_state[128];

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

  // 命中结果出队时可在同一边沿查询下一地址；背压时保持 inst/hit。
  assign cpu_req_ready = rst_n && ((curr_state == IDLE) ||
                                  ((curr_state == CHECK) && hit && cpu_rsp_ready));
  assign cpu_req_fire = cpu_req_valid && cpu_req_ready;
  assign mem_req_fire = mem_req_valid && mem_req_ready;
  assign mem_rsp_fire = mem_rsp_valid && mem_rsp_ready;
  assign ren = cpu_req_fire || (cnt == 5'd17);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      saved_req_addr <= 34'b0;
    end else if (cpu_req_fire) begin
      saved_req_addr <= cpu_req_addr;
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
        if (cpu_req_fire) begin
          next_state = CHECK;
        end else begin
          next_state = IDLE;
        end
      end
      CHECK: begin
        if (hit) begin
          if (cpu_rsp_ready) begin
            next_state = cpu_req_fire ? CHECK : IDLE;
          end else begin
            next_state = CHECK;
          end
        end else begin
          next_state = READ_MEM_REQ;
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
          if (mem_rsp_last) begin
            next_state = (refill_error || mem_rsp_error) ? RESP : FILL;
          end
        end else begin
          next_state = READ_MEM_RSP;
        end
      end
      FILL: begin
        if (cnt == 5'd17) begin
          next_state = RESP;
        end
      end
      RESP: begin
        if (cpu_rsp_ready) begin
          next_state = IDLE;
        end
      end
      default: next_state = IDLE;
    endcase
  end

  always_comb begin
    cpu_rsp_valid = 1'b0;
    cpu_rsp_rdata = 32'b0;
    mem_req_valid = 1'b0;
    // 64 字节行首地址，完整保留 34 位物理地址。
    mem_req_addr  = {saved_req_addr[33:6], 6'b0};
    mem_req_len   = 8'd15;
    cpu_rsp_error = refill_error;
    mem_rsp_ready = 1'b0;
    case (curr_state)
      IDLE: begin
      end
      CHECK: begin
        if (hit) begin
          cpu_rsp_valid = 1'b1;
          cpu_rsp_rdata = inst;
        end
      end
      READ_MEM_REQ: begin
        mem_req_valid = 1'b1;
      end
      READ_MEM_RSP: begin
        if (mem_rsp_valid == 1'b1) begin
          mem_rsp_ready = 1'b1;
        end
      end
      FILL: begin
      end
      RESP: begin
        cpu_rsp_valid = 1'b1;
        cpu_rsp_rdata = refill_error ? 32'b0 : inst;
      end
      default: begin
      end
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      refill_error <= 0;
      cnt          <= 0;
      block_data   <= 0;
      wen          <= 0;
    end else begin
      cnt        <= cnt;
      block_data <= block_data;
      wen        <= 0;
      if (curr_state == READ_MEM_RSP && mem_rsp_fire) begin
        refill_error                     <= refill_error || mem_rsp_error;
        cnt                              <= cnt + 1;
        block_data[{cnt[3:0], 5'b0}+:32] <= mem_rsp_rdata;
        if (mem_rsp_last) begin
          wen <= !(refill_error || mem_rsp_error);
          cnt <= cnt + 1'b1;
        end
      end
      if (cnt == 5'd16) begin
        cnt <= cnt + 1'b1;
      end
      if (curr_state == RESP) cnt <= 0;
      if (cpu_req_fire) begin
        cnt          <= 0;
        refill_error <= 0;
      end
    end
  end

  // synthesis translate_off
  always @(posedge clk)
    if (rst_n && mem_rsp_fire && mem_rsp_last != (cnt == 15))
      $fatal(1, "ICache refill LAST/count mismatch");
  // synthesis translate_on

  // icache 读取
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      inst <= 32'b0;
      hit  <= 1'b0;
      for (int i = 0; i < 128; i++) begin
        plur_state[i] <= 3'b0;
      end
    end else begin
      if (ren) begin
        inst <= 32'b0;
        hit  <= 0;
        for (int i = 0; i < 4; i++) begin
          if (address_tag == tag_mem[address_index][i].tag && tag_mem[address_index][i].valid) begin
            inst <= data_mem[address_index][i][{address_block_offset[5:0], 3'b0}+:32];
            hit  <= 1'b1;
            case (i)
              0:       plur_state[address_index] <= {1'b1, plur_state[address_index][1], 1'b1};
              1:       plur_state[address_index] <= {1'b1, plur_state[address_index][1], 1'b0};
              2:       plur_state[address_index][2:1] <= 2'b01;
              3:       plur_state[address_index][2:1] <= 2'b00;
              default: plur_state[address_index] <= 3'b0;
            endcase
          end
        end
      end else begin
        inst <= inst;
        hit  <= hit;
      end
    end
  end

  // icache 写入
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < 128; i++) begin
        for (int j = 0; j < 4; j++) begin
          tag_mem[i][j].valid <= 1'b0;
        end
      end
    end else begin
      if (wen) begin
        if (empty_way != 3'd4) begin
          data_mem[address_index][empty_way[1:0]]      <= block_data;
          tag_mem[address_index][empty_way[1:0]].valid <= 1'b1;
          tag_mem[address_index][empty_way[1:0]].tag   <= address_tag;
        end else begin
          casez (plur_state[address_index])
            3'b0?0: begin
              data_mem[address_index][0]      <= block_data;
              tag_mem[address_index][0].valid <= 1'b1;
              tag_mem[address_index][0].tag   <= address_tag;
            end
            3'b0?1: begin
              data_mem[address_index][1]      <= block_data;
              tag_mem[address_index][1].valid <= 1'b1;
              tag_mem[address_index][1].tag   <= address_tag;
            end

            3'b10?: begin
              data_mem[address_index][2]      <= block_data;
              tag_mem[address_index][2].valid <= 1'b1;
              tag_mem[address_index][2].tag   <= address_tag;
            end
            3'b11?: begin
              data_mem[address_index][3]      <= block_data;
              tag_mem[address_index][3].valid <= 1'b1;
              tag_mem[address_index][3].tag   <= address_tag;
            end
            default: begin
              data_mem[address_index][0]      <= 512'b0;
              tag_mem[address_index][0].valid <= 1'b1;
              tag_mem[address_index][0].tag   <= address_tag;
            end
          endcase
        end
      end
    end
  end

endmodule


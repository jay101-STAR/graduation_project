//============================================================================
// tb_dataram.v - Bank 交织数据内存测试平台
//============================================================================

`timescale 1ns / 1ps

module tb_dataram;

    reg         clk;
    reg         rst;
    reg  [31:0] addr;
    reg  [31:0] wdata;
    reg         wen;
    reg         ren;
    reg  [ 7:0] alucex;
    wire [31:0] rdata;
    wire [31:0] tohost_val;

    // 实例化被测模块
    dataram uut (
        .clk        (clk),
        .rst        (rst),
        .addr       (addr),
        .wdata      (wdata),
        .wen        (wen),
        .ren        (ren),
        .alucex     (alucex),
        .rdata      (rdata),
        .tohost_val (tohost_val)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Load/Store 类型定义
    localparam LB_TYPE  = 8'h16;
    localparam LH_TYPE  = 8'h17;
    localparam LW_TYPE  = 8'h18;
    localparam LBU_TYPE = 8'h19;
    localparam LHU_TYPE = 8'h1A;
    localparam SB_TYPE  = 8'h1B;
    localparam SH_TYPE  = 8'h1C;
    localparam SW_TYPE  = 8'h1D;

    // 基地址
    localparam BASE_ADDR = 32'h8000_2000;

    // 测试任务：写入一个字
    task write_word;
        input [31:0] address;
        input [31:0] data;
        begin
            @(posedge clk);
            addr   <= address;
            wdata  <= data;
            wen    <= 1'b1;
            ren    <= 1'b0;
            alucex <= SW_TYPE;
            @(posedge clk);
            wen    <= 1'b0;
        end
    endtask

    // 测试任务：读取一个字
    task read_word;
        input [31:0] address;
        begin
            @(posedge clk);
            addr   <= address;
            wen    <= 1'b0;
            ren    <= 1'b1;
            alucex <= LW_TYPE;
            @(posedge clk);
            ren    <= 1'b0;
            @(posedge clk);  // 等待 BRAM 输出
        end
    endtask

    // 测试过程
    initial begin
        // 初始化
        rst    = 1;
        addr   = 0;
        wdata  = 0;
        wen    = 0;
        ren    = 0;
        alucex = 0;

        #100;
        rst = 0;
        #20;

        $display("========================================");
        $display("开始 Bank 交织数据内存测试");
        $display("========================================");

        //----------------------------------------------------------------------
        // 测试 1: 对齐字写入/读取
        //----------------------------------------------------------------------
        $display("\n[测试 1] 对齐字写入/读取 (offset=0)");

        write_word(BASE_ADDR + 32'h00, 32'hDEADBEEF);
        write_word(BASE_ADDR + 32'h04, 32'hCAFEBABE);
        write_word(BASE_ADDR + 32'h08, 32'h12345678);
        write_word(BASE_ADDR + 32'h0C, 32'h87654321);

        read_word(BASE_ADDR + 32'h00);
        $display("  读取 0x%08X: 期望 0xDEADBEEF, 实际 0x%08X %s",
                 BASE_ADDR, rdata, (rdata == 32'hDEADBEEF) ? "PASS" : "FAIL");

        read_word(BASE_ADDR + 32'h04);
        $display("  读取 0x%08X: 期望 0xCAFEBABE, 实际 0x%08X %s",
                 BASE_ADDR + 4, rdata, (rdata == 32'hCAFEBABE) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 2: 非对齐字写入/读取 (offset=1)
        //----------------------------------------------------------------------
        $display("\n[测试 2] 非对齐字写入/读取 (offset=1)");

        write_word(BASE_ADDR + 32'h21, 32'hAABBCCDD);
        read_word(BASE_ADDR + 32'h21);
        $display("  读取 0x%08X: 期望 0xAABBCCDD, 实际 0x%08X %s",
                 BASE_ADDR + 32'h21, rdata, (rdata == 32'hAABBCCDD) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 3: 非对齐字写入/读取 (offset=2)
        //----------------------------------------------------------------------
        $display("\n[测试 3] 非对齐字写入/读取 (offset=2)");

        write_word(BASE_ADDR + 32'h42, 32'h11223344);
        read_word(BASE_ADDR + 32'h42);
        $display("  读取 0x%08X: 期望 0x11223344, 实际 0x%08X %s",
                 BASE_ADDR + 32'h42, rdata, (rdata == 32'h11223344) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 4: 非对齐字写入/读取 (offset=3)
        //----------------------------------------------------------------------
        $display("\n[测试 4] 非对齐字写入/读取 (offset=3)");

        write_word(BASE_ADDR + 32'h63, 32'h55667788);
        read_word(BASE_ADDR + 32'h63);
        $display("  读取 0x%08X: 期望 0x55667788, 实际 0x%08X %s",
                 BASE_ADDR + 32'h63, rdata, (rdata == 32'h55667788) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 5: 半字写入/读取
        //----------------------------------------------------------------------
        $display("\n[测试 5] 半字写入/读取");

        // 对齐半字
        @(posedge clk);
        addr <= BASE_ADDR + 32'h80;
        wdata <= 32'h0000ABCD;
        wen <= 1;
        alucex <= SH_TYPE;
        @(posedge clk);
        wen <= 0;

        @(posedge clk);
        addr <= BASE_ADDR + 32'h80;
        ren <= 1;
        alucex <= LH_TYPE;
        @(posedge clk);
        ren <= 0;
        @(posedge clk);
        $display("  LH  0x%08X: 期望 0xFFFFABCD, 实际 0x%08X %s",
                 BASE_ADDR + 32'h80, rdata, (rdata == 32'hFFFFABCD) ? "PASS" : "FAIL");

        // 非对齐半字 (offset=3，跨边界)
        @(posedge clk);
        addr <= BASE_ADDR + 32'h8B;
        wdata <= 32'h0000EF01;
        wen <= 1;
        alucex <= SH_TYPE;
        @(posedge clk);
        wen <= 0;

        @(posedge clk);
        addr <= BASE_ADDR + 32'h8B;
        ren <= 1;
        alucex <= LHU_TYPE;
        @(posedge clk);
        ren <= 0;
        @(posedge clk);
        $display("  LHU 0x%08X: 期望 0x0000EF01, 实际 0x%08X %s",
                 BASE_ADDR + 32'h8B, rdata, (rdata == 32'h0000EF01) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 6: 字节写入/读取
        //----------------------------------------------------------------------
        $display("\n[测试 6] 字节写入/读取");

        @(posedge clk);
        addr <= BASE_ADDR + 32'hA0;
        wdata <= 32'h000000FE;
        wen <= 1;
        alucex <= SB_TYPE;
        @(posedge clk);
        wen <= 0;

        @(posedge clk);
        addr <= BASE_ADDR + 32'hA0;
        ren <= 1;
        alucex <= LB_TYPE;
        @(posedge clk);
        ren <= 0;
        @(posedge clk);
        $display("  LB  0x%08X: 期望 0xFFFFFFFE, 实际 0x%08X %s",
                 BASE_ADDR + 32'hA0, rdata, (rdata == 32'hFFFFFFFE) ? "PASS" : "FAIL");

        @(posedge clk);
        addr <= BASE_ADDR + 32'hA0;
        ren <= 1;
        alucex <= LBU_TYPE;
        @(posedge clk);
        ren <= 0;
        @(posedge clk);
        $display("  LBU 0x%08X: 期望 0x000000FE, 实际 0x%08X %s",
                 BASE_ADDR + 32'hA0, rdata, (rdata == 32'h000000FE) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试 7: tohost 写入
        //----------------------------------------------------------------------
        $display("\n[测试 7] tohost 写入");

        @(posedge clk);
        addr <= 32'h8000_1000;
        wdata <= 32'h00000001;
        wen <= 1;
        alucex <= SW_TYPE;
        @(posedge clk);
        wen <= 0;
        @(posedge clk);
        $display("  tohost_val: 期望 0x00000001, 实际 0x%08X %s",
                 tohost_val, (tohost_val == 32'h00000001) ? "PASS" : "FAIL");

        //----------------------------------------------------------------------
        // 测试完成
        //----------------------------------------------------------------------
        $display("\n========================================");
        $display("测试完成");
        $display("========================================");

        #100;
        $finish;
    end

    // 波形输出
    initial begin
        $dumpfile("tb_dataram.vcd");
        $dumpvars(0, tb_dataram);
    end

endmodule

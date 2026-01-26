module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input                   clk,
    input                   rst,

    input                   wen,
    input [DATA_WIDTH-1:0]  wdata,

    input                   ren,
    output [DATA_WIDTH-1:0] rdata,

    output reg              full,
    output reg              empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [ADDR_WIDTH-1:0] w_ptr;
    reg [ADDR_WIDTH-1:0] r_ptr;

    // 预计算“下一拍”的指针位置
    wire [ADDR_WIDTH-1:0] w_ptr_next = w_ptr + 1'b1;
    wire [ADDR_WIDTH-1:0] r_ptr_next = r_ptr + 1'b1;

    wire do_write = wen && !full;
    wire do_read  = ren && !empty;

    always @(posedge clk) begin
        if (rst) begin
            w_ptr <= 0;
            r_ptr <= 0;
            full  <= 0;
            empty <= 1; // 复位时认为是空
        end else begin
            case ({do_write, do_read})
                // Case 1: 只写不读 
                2'b10: begin
                    w_ptr <= w_ptr_next; 
                    empty <= 0;         
                    if (w_ptr_next == r_ptr) begin
                        full <= 1;
                    end
                end

                // Case 2: 只读不写 (Read Only)
                2'b01: begin
                    r_ptr <= r_ptr_next; 
                    full  <= 0;          

                    if (r_ptr_next == w_ptr) begin
                        empty <= 1;
                    end
                end

                // Case 3: 同时读写 (Read & Write),假设DEPTH > 1
                2'b11: begin
                    w_ptr <= w_ptr_next;
                    r_ptr <= r_ptr_next;
                end
                // Case 4: 无操作 -> 保持原值
                default: ; 
            endcase
        end
    end

    ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH     (DEPTH)
    ) u_ram (
        .clk   (clk),
        .wen   (do_write),       
        .waddr (w_ptr),          
        .wdata (wdata),          
        
        .ren   (do_read),        
        .raddr (r_ptr),          
        .rdata (rdata)           
    );

endmodule

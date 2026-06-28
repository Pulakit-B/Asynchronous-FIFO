`timescale 1ns / 1ps

module FIFO_mem #(
    parameter DATA_WIDTH = 8, DEPTH = 8, PTR_WIDTH = 3
) (
    input wr_clk, rd_clk, 
    input wr_en, rd_en,
    input [PTR_WIDTH:0]b_wrptr, b_rdptr,
    input [DATA_WIDTH-1:0]data_in,
    input full_flag, empty_flag,
    output reg [DATA_WIDTH-1:0]data_out
);
    
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

    always @(posedge wr_clk)
    begin
        if(!full_flag && wr_en)
            fifo_mem[b_wrptr[PTR_WIDTH-1:0]] <= data_in; 
    end

    always @(posedge rd_clk)
    begin
        if(!empty_flag && rd_en)
            data_out <= fifo_mem[b_rdptr[PTR_WIDTH-1:0]];
    end

endmodule

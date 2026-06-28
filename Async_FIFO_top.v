`timescale 1ns / 1ps

module FIFO_async_top #(
    parameter DATA_WIDTH = 8, DEPTH = 8, PTR_WIDTH = 3
) (
    input wr_clk, rd_clk, 
    input wr_en, rd_en,
    input wr_rst_en, rd_rst_en,
    input [DATA_WIDTH-1:0]data_in,
    output full_flag, empty_flag,
    output [DATA_WIDTH-1:0]data_out
);

    wire [PTR_WIDTH:0]g_rdptr_synczr; // gray code vaue of read pointer after passing through synchronizer
    wire [PTR_WIDTH:0]g_wrptr_synczr; //gray code value of write pointer after passing through synchronizer
    wire [PTR_WIDTH:0]g_wrptr, b_wrptr;
    wire [PTR_WIDTH:0]g_rdptr, b_rdptr;

//------------------Two flop synchronizers Connections---------------

//----------Write domain ----------->> Read domain----------
    two_ff_synczr #(.WIDTH(PTR_WIDTH)) wrptr_synczr (.clk(rd_clk), 
                                                    .rst_en(rd_rst_en), 
                                                    .d_in(g_wrptr), 
                                                    .qout_synczr(g_wrptr_synczr));

//----------Read domain ------------>> Write domain---------
    two_ff_synczr #(.WIDTH(PTR_WIDTH)) rdptr_synczr (.clk(wr_clk), 
                                                    .rst_en(wr_rst_en), 
                                                    .d_in(g_rdptr), 
                                                    .qout_synczr(g_rdptr_synczr));


//----------------------write pointer connections---------------------
    write_pointer #(.PTR_WIDTH(PTR_WIDTH)) write_module (.wr_clk(wr_clk), 
                                                        .wr_en(wr_en), 
                                                        .wr_rst_en(wr_rst_en),
                                                        .g_rdptr_synczr(g_rdptr_synczr), 
                                                        .b_wrptr(b_wrptr), 
                                                        .g_wrptr(g_wrptr), 
                                                        .full_flag(full_flag));

    read_pointer #(.PTR_WIDTH(PTR_WIDTH)) read_module ( .rd_clk(rd_clk), 
                                                        .rd_en(rd_en), 
                                                        .rd_rst_en(rd_rst_en),
                                                        .g_wrptr_synczr(g_wrptr_synczr), 
                                                        .b_rdptr(b_rdptr), 
                                                        .g_rdptr(g_rdptr), 
                                                        .empty_flag(empty_flag));

//----------------------FIFO memory connections-----------------------

    FIFO_mem #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH))memory (.wr_clk(wr_clk), 
                                                                                    .rd_clk(rd_clk), 
                                                                                    .wr_en(wr_en), 
                                                                                    .rd_en(rd_en), 
                                                                                    .b_wrptr(b_wrptr), 
                                                                                    .b_rdptr(b_rdptr), 
                                                                                    .data_in(data_in), 
                                                                                    .full_flag(full_flag), 
                                                                                    .empty_flag(empty_flag), 
                                                                                    .data_out(data_out));
endmodule

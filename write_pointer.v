`timescale 1ns / 1ps

module write_pointer #(
    parameter PTR_WIDTH = 3
) (
    input wr_clk, wr_en, wr_rst_en,             // write domain clk, write enable signal, reset signal (active low)
    input [PTR_WIDTH:0]g_rdptr_synczr,          // The read pointer value after passed through the syncronizer
    output reg [PTR_WIDTH:0]b_wrptr, g_wrptr,   //binary and gray code value of the write pointer/ address
    output reg full_flag                        // Full flag acivated when the write pointer reaches at the end of the memory block
);

//------------------------Extra reg and wire declaration--------------------

    wire [PTR_WIDTH:0] b_wrptr_next,g_wrptr_next;
    wire wfull;

//-------------------Binary and gray pointer increementation----------------

    assign b_wrptr_next = b_wrptr + (wr_en & !full_flag);// Binary value increementation
    assign g_wrptr_next = b_wrptr_next ^ (b_wrptr_next >> 1); // Gray value increementation

//----------------Reset logic and pointer increement assination-------------
    always @(posedge wr_clk or negedge wr_rst_en)
    begin

//------------------------------Reset Block---------------------------------
        if(!wr_rst_en)
        begin
            b_wrptr <= {(PTR_WIDTH+1){1'b0}};
            g_wrptr <= {(PTR_WIDTH+1){1'b0}};
        end

//----------------------Increemented value assign block---------------------
        else
        begin
            b_wrptr <= b_wrptr_next;
            g_wrptr <= g_wrptr_next;
        end
    end

//-----------------Look ahead generationn of the full flag------------------

    assign wfull = (g_rdptr_synczr == {(~g_wrptr_next[PTR_WIDTH:PTR_WIDTH-1]), g_wrptr_next[PTR_WIDTH-2:0]}); //Full flag using gray coded read pointer and write pointer


    always @(posedge wr_clk or negedge wr_rst_en)
    begin
        
        if(!wr_rst_en)                  
            full_flag <= 1'b0;          //reset full flag under reset condition

        else
            full_flag <= wfull; 
    end

endmodule

`timescale 1ns / 1ps

module read_pointer #(
    parameter PTR_WIDTH = 3
) (
    input rd_clk, rd_en, rd_rst_en,             //read clock. read enable, reset active low
    input [PTR_WIDTH:0]g_wrptr_synczr,          // The write pointer value after passed through the syncronizer
    output reg[PTR_WIDTH:0]b_rdptr, g_rdptr,    //binary and gray code value of the read pointer
    output reg empty_flag                       // empty flg becomes 1 when read pointer catches upto write pointer
);

//------------------------Extra reg and wire declaration--------------------

    wire [PTR_WIDTH:0]b_rdptr_next, g_rdptr_next;       // next binary and gray code values of read pointer
    wire rempty;                                        // look ahead empty flag generated

//-------------------Binary and gray pointer increementation----------------

    assign b_rdptr_next = b_rdptr + (rd_en & !empty_flag);  //binary value increementation
    assign g_rdptr_next = b_rdptr_next ^ (b_rdptr_next >> 1); //gray code value increementation

//----------------Reset logic and pointer increement assination-------------

    always @(posedge rd_clk or negedge rd_rst_en)
    begin

//------------------------------Reset Block---------------------------------
        if(!rd_rst_en)
        begin
            b_rdptr <= {(PTR_WIDTH+1){1'b0}};
            g_rdptr <= {(PTR_WIDTH+1){1'b0}};
        end

//----------------------Increemented value assign block---------------------
        else 
        begin
            b_rdptr <= b_rdptr_next;
            g_rdptr <= g_rdptr_next;
        end
    end

//-----------------Look ahead generationn of the empty flag------------------
    assign rempty = (g_wrptr_synczr == g_rdptr_next);   // Empty flag using gray coded read pointer and write pointer

    always @(posedge rd_clk or negedge rd_rst_en)
    begin
        if(!rd_rst_en)
            empty_flag <= 1'b1;                         //reset empty flag under reset condition

        else
            empty_flag <=  rempty; 
    end

endmodule

`timescale 1ns / 1ps

module two_ff_synczr#(parameter WIDTH = 3)(         // WIDTH can be customized according to adress/pointer bus size
    input clk, rst_en,                              // active low reset signal
    input [WIDTH:0]d_in,                            //actual adress data that needs to be synchronized
    output reg [WIDTH:0]qout_synczr                 // output of the synczr in clock domain of clk
);
    reg [WIDTH:0]q_inter;                           // intermediate wire between 2 D ffs or the output of 1st flip flop

    always @(posedge clk or negedge rst_en)
    begin
        if(!rst_en) 
        begin
            q_inter <= {(WIDTH+1){1'b0}};           // we can have written here 4'b0000 
            qout_synczr <= {(WIDTH+1){1'b0}};       // but if the width has changed to let 8 bits then
        end                                         // the lower 4 bits maybe made 0 but the upper 3 bits becomes dont care
                                                    //this method is full proof for any bit width
        else
        begin
            q_inter <= d_in;                        //alternative {qout_synczr,q_inter} <= {q_inter,d_in}
            qout_synczr <= q_inter;                 //but to handle the signals more cleraly we went by the current style
        end
    end
endmodule

module FIFO_async_tb();

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;
    parameter PTR_WIDTH = 3;

    reg wr_clk, rd_clk, wr_en, rd_en, wr_rst_en, rd_rst_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire full_flag, empty_flag;
    wire [DATA_WIDTH-1:0] data_out;

    FIFO_async_top #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(DEPTH),
                    .PTR_WIDTH(PTR_WIDTH)
    ) dut (.wr_clk(wr_clk), 
            .rd_clk(rd_clk), 
            .wr_en(wr_en), 
            .rd_en(rd_en), 
            .wr_rst_en(wr_rst_en), 
            .rd_rst_en(rd_rst_en),
            .data_in(data_in), 
            .full_flag(full_flag), 
            .empty_flag(empty_flag), 
            .data_out(data_out));

    integer i;

    always #5 wr_clk = ~wr_clk;
    always #10 rd_clk = ~rd_clk;

    initial 
    begin
        wr_clk = 0;rd_clk = 0;
        wr_en = 0; rd_en = 0;
        wr_rst_en = 1; rd_rst_en = 1;
        data_in = 8'b0;

        #40;
        wr_rst_en = 0 ; rd_rst_en =0;

        #40;
        wr_rst_en = 1; rd_rst_en = 1;

        #40;
//---------------Write until full------------
        $display("Filling the FIFO");
        rd_en <= 0;

        for(i = 0; i < DEPTH + 3 ; i = i+1)
        begin
            @(posedge wr_clk)
            begin
                if(!full_flag)
                begin
                    wr_en <= 1'b1;
                    data_in <= $random % 256;
                end

                else
                begin
                    wr_en <= 0;
                    $display("Time %0t: FIFO is full, nothing to write", $time);
                end
            end
        end

        @(posedge wr_clk)
            wr_en <= 0;

//--------------------Read until empty-------------
        for(i = 0; i < DEPTH + 3; i = i+1)
        begin
            @(posedge rd_clk )
            begin
                if(!empty_flag)
                begin
                    rd_en <= 1'b1;
                end

                else
                begin
                    rd_en <= 0;
                    $display("Time %0t: FIFO empty, nothing to read", $time);
                end
            end
        end

        @(posedge rd_clk)
            rd_en <= 0;
        
        #100;
        $display("Simulation Complete");
        $finish;

    end

endmodule
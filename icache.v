module icache(clk, rst, MetaDataIn, MetaWrite, BlockEnable, MetaDataOut, DataIn, DataWrite);
    input clk, rst;
    input [7:0] MetaDataIn;
    input MetaWrite;
    input [127:0] BlockEnable;
    output [7:0] MetaDataOut;
    input [15:0] DataIn;
    input DataWrite;
    input [7:0] WordEnable;
    output [15:0] DataOut;


    MetaDataArray(.clk(clk), .rst(rst), .DataIn(MetaDataIn), .Write(MetaWrite), .BlockEnable(BlockEnable), .DataOut(MetaDataOut));

    DataArray(.clk(clk), .rst(rst), .DataIn(DataIn), .Write(DataWrite), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut));

endmodule
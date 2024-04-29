module cache_controller(clk, rst, ins_addr, mem_addr, dataIn, ,  );
    input [15:0] mem_addr;

    
    wire [5:0] set_index;
    wire [2:0] b_offset;
    wire [7:0] tag;



    // Data Cache input variables
    wire [7:0] D_MetaDataIn;
    wire D_MetaWrite;
    wire [127:0] D_BlockEnable;
    wire [7:0] D_MetaDataOut;
    wire [15:0] D_DataIn;
    wire D_DataWrite;
    wire [7:0] D_WordEnable;
    wire [15:0] D_DataOut;

    // Instruction Cache input variables
    wire [7:0] I_MetaDataIn;
    wire I_MetaWrite;
    wire [127:0] I_BlockEnable;
    wire [7:0] I_MetaDataOut;
    wire [15:0] I_DataIn;
    wire I_DataWrite;
    wire [7:0] I_WordEnable;
    wire [15:0] I_DataOut;
    

    //Data cache
    assign b_offset = mem_addr[2:0];
    assign set_index = mem_addr[8:3];
    assign tag = mem_addr[15:9];


    //Find set
    wire [63:0] shift_32, shift_16, shift_8, shift_4, shift_2;
    assign shift_32 = (set_index[5]) ? {{63{1'b0}}, 1'b1} << 32 : {{63{1'b0}}, 1'b1};
    assign shift_16 = (set_index[4]) ? shift_32 << 16 : shift_32;
    assign shift_8 = (set_index[3]) ? shift_16 << 8 : shift_16;
    assign shift_4 = (set_index[2]) ? shift_8 << 4 : shift_8;
    assign shift_2 = (set_index[1]) ? shift_4 << 2 : shift_4;
    assign D_BlockEnable = (set_index[0]) ? shift_2 << 1: shift_2;

    //Find block offset
    wire [7:0] b_shift_4, b_shift_2;
    assign b_shift_4 = (b_offset[2]) ? {{7{1'b0}}, 1'b1} << 4 : {{7{1'b0}}, 1'b1};
    assign b_shift_2 = (b_offset[1]) ? b_shift_4 << 2 : b_shift_4;
    assign D_WordEnable = (b_offset[0]) ? b_shift_2 << 1: b_shift_2;

    dcache dche(clk, rst, .MetaDataIn(dataIn), .MetaWrite(D_MetaWrite), .BlockEnable(D_BlockEnable), .MetaDataOut(D_MetaDataOut), DataIn(dataIn), DataWrite, WordEnable, DataOut);

    
endmodule
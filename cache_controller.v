module cache_controller(clk, rst, memRead, memWrite, ins_addr, mem_addr, dataIn, cacheStall, iOut, dOut);
    input clk, rst;
    input memRead, memWrite;
    input [15:0] mem_addr, ins_addr;
    input [15:0] dataIn;
    output [15:0] iOut, dOut;

    // Data Cache input variables
    wire [7:0] D_MetaDataIn;
    wire D_MetaWrite1, D_MetaWrite2;
    wire [63:0] D_BlockEnable;
    wire [7:0] D_MetaDataOut1, D_MetaDataOut2;
    wire D_DataWrite1, D_DataWrite2;
    wire [7:0] D_WordEnable;
    wire [15:0] D_DataOut1, D_DataOut2;

    wire [5:0] set_index;
    wire [2:0] b_offset;
    wire [7:0] tag;
    wire LRU;

    wire [63:0] shift_32, shift_16, shift_8, shift_4, shift_2;
    wire [7:0] b_shift_4, b_shift_2;

    wire miss;

    wire fsm_busy;
    wire [15:0] memToRead;
    wire [15:0] memReadFSM;
    wire memValidFSM;

    wire dataHit1, dataHit2;
    wire FSMMetaEn, FSMDataEn;

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
    assign shift_32 = (set_index[5]) ? {{63{1'b0}}, 1'b1} << 32 : {{63{1'b0}}, 1'b1};
    assign shift_16 = (set_index[4]) ? shift_32 << 16 : shift_32;
    assign shift_8 = (set_index[3]) ? shift_16 << 8 : shift_16;
    assign shift_4 = (set_index[2]) ? shift_8 << 4 : shift_8;
    assign shift_2 = (set_index[1]) ? shift_4 << 2 : shift_4;
    assign D_BlockEnable = (set_index[0]) ? shift_2 << 1: shift_2;

    //Find block offset
    assign b_shift_4 = (b_offset[2]) ? {{7{1'b0}}, 1'b1} << 4 : {{7{1'b0}}, 1'b1};
    assign b_shift_2 = (b_offset[1]) ? b_shift_4 << 2 : b_shift_4;
    assign D_WordEnable = (b_offset[0]) ? b_shift_2 << 1: b_shift_2;

    assign D_MetaDataIn = {tag, LRU, 1'b1};
    assign miss_detected = ~((tag == D_MetaDataOut[7:2]) & D_MetaDataOut[0]); // First check, missing 2nd-way check

    //check for hits
    assign dataHit1 = (tag == D_MetaDataOut1[7:2]) & D_MetaDataOut1[0];
    assign dataHit2 = (tag == D_MetaDataOut2[7:2]) & D_MetaDataOut2[0];
    assign miss = ~datahit1 & ~datahit2 & (memRead | memWrite);
    
    assign D_MetaDataIn = {tag, ~dataHit1, 1'b1};
    assign D_MetaWrite1 = FSMMetaEn & ; //enable write to LRU
    assign D_MetaWrite2 = FSMMetaEn & ;


    dcache dataCache(.clk(clk), .rst(rst), .MetaDataIn(D_MetaDataIn), .MetaWrite1(D_MetaWrite1), .MetaWrite2(D_MetaWrite2), 
                    .BlockEnable(D_BlockEnable), .MetaDataOut1(D_MetaDataOut1), .MetaDataOut2(D_MetaDataOut2), .DataIn(dataIn), 
                    .DataWrite1(D_DataWrite1), .DataWrite2(D_DataWrite2), .WordEnable(D_WordEnable), .DataOut1(D_DataOut1), .DataOut2(D_DataOut2));

    cache_fill_FSM cacheFSM(.clk(clk), .rst_n(~rst), .miss_detected(miss_detected), .miss_address(mem_addr), .fsm_busy(fsm_busy), 
                    .write_data_array(FSMDataEn), .write_tag_array(FSMMetaEn), .memory_address(memToRead), .memory_data(memReadFSM), .memory_data_valid(memValidFSM));

    memory4c dmem(.data_out(memReadFSM), .data_in(dataIn), .addr(memToRead), .enable(1'b1), .wr(miss_detected), .clk(clk), .rst(rst), .data_valid(memValidFSM));

endmodule
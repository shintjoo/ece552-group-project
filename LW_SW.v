module LW_SW_inside(
    input [15:0] rs,
    inout [15:0] rt,
    input [15:0] imme,
    input clk,
    input rst,
    input read_enable, //be true for both read and write - for opcode purposes op[3]
    input write_enable, //only for sw, for opcode op[0]
    output reg [15:0] data_out
);
    RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, .WriteReg(read_enable), .DstData(rt), .SrcData1, SrcData2);
    memory1c memcall (.data_out(rt), data_in(rt), .addr(address), .enable(read_enable), .wr(write_enable), .clk(clk), .rst(rst));
    wire [31:0] address;
    wire [15:0] immediate;
    assign immediate = {11{imm[0]}, imm, 1'b0}
    addsub_16bit ADDRESS(.Sum(address), .A(immediate), .B(rs), .sub(0));

endmodule

module LW_SW_outside(
    input enable_LW_SW;
    inout RegDst;
    inout Branch;
    inout [15:0] imm;
    inout ALU_control;
    inout zero;
    inout MemWrite;
    inout ALUSrc;
    inout RegWrite;
);
    assign Branch = (enable_LW_SW) ? 0 : Branch;
    assign RegDst = (enable_LW_SW) ? 0 : RegDst;
    wire [31:0] address;
    wire [15:0] imm;
    assign imm = {11{imm[0]}, imm, 1'b0}
    //addsub_16bit ADDRESS(.Sum(address), .A(immediate), .B(rs), .sub(0)); this would be ALU outside of file

endmodule

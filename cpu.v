/*
 * cpu.v
 * Shawn Zhu
 * ECE552
 */
module cpu (clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;

//control signals
wire RegWrite, MemRead, MemWrite, Branch, MemtoReg, RegDst, ALUSrc; //control signals
wire [3:0] ALUOp; //ALU Control signal

//intermediate signals
wire [15:0] pc_in, instruction, mem_out;
wire [15:0] pc_increment, pc_branch;
wire [15:0] datain, dataout1, dataout2;
wire [2:0] Flags;
wire [15:0] aluin2, aluout;
wire error;


//Fetch Stage
//instruction memory
memory1c imem(.data_out(instruction), .data_in(16'b0), .addr(pc_in), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));

//PC Calculation
adder_16bit increment(.Sum(pc_increment), .A(pc_in), .B(16'h0002), .sub(1'b0), .sat());
adder_16bit branch(.Sum(pc_branch), .A(pc_increment), .B({6'h0, instruction[8:0], 1'b0}), .sub(1'b0), .sat());

//Decode Stage
//possibilities for opcode
//Opcode rd, rs, rt
//Opcode rd, rs, imm
//Opcode rt, rs, offset
//Opcode ccci iiii iiii
//Opcode cccx ssss xxxx
//Opcode dddd xxxx xxxx
//Opcode xxxx xxxx xxxx
//
//SrcReg1 is rs for logic and memory instructions
RegisterFile regfile (.clk(clk), .rst(rst), .SrcReg1(instruction[7:0]), .SrcReg2(instruction[3:0]), .DstReg(instruction[11:8]), .WriteReg(RegWrite), .DstData(datain), .SrcData1(dataout1), .SrcData2(dataout2));

//execute stage
assign aluin2 = (ALUSrc)? {{12{instruction[3]}},instruction[3:0]} : dataout2;
ALU ex(.ALU_out(aluout), .Error(error), .ALU_In1(dataout1), .ALU_In2(aluin2), .ALUOp(instruction[15:12]));


//memory stage
memory1c dmem(.data_out(mem_out), .data_in(dataout2), .addr(aluout), .enable(MemRead), .wr(MemWrite), .clk(clk), .rst(rst));


//writeback stage

endmodule
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
wire RegWrite, MemRead, MemWrite, Branch, MemtoReg, ALUSrc; //control signals
wire pcs_select, hlt_select, ALUSrc8bit;

//intermediate signals
wire [15:0] pc_in, instruction, mem_out;
wire [15:0] pc_increment, pc_branch;
wire [15:0] datain, dataout1, dataout2;
wire [2:0] Flags;
wire [15:0] aluin2, aluout;
wire error;

//instruction signals
wire [3:0] Opcode, rs, rd, imm;
wire [7:0] imm8bit;
wire [8:0] imm9bit;
wire [2:0] ccc;


dff pc_reg [15:0](.q(pc_in), .d(pc_branch), .wen(~hlt_select), .clk(clk), .rst(~rst_n));

//Fetch Stage
//instruction memory
memory1c imem(.data_out(instruction), .data_in(16'b0), .addr(pc_in), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));
assign Opcode = instruction[15:12];
assign rs = instruction[7:4];
assign rd = instruction[11:8];
assign imm = instruction[3:0];
assign imm8bit = instruction[7:0];
assign imm9bit = instruction[8:0];
assign ccc = instruction[11:9];

//PC Calculation
addsub_16bit increment(.Sum(pc_increment), .A(pc_in), .B(16'h0002), .sub(1'b0), .sat());
PC_control pccontrol(.C(ccc), .I(imm9bit), .F(Flags), .branch(Branch), .PC_in(pc_increment), .PC_out(pc_branch));

//Control signals
Control controlunit(
    .instruction(instruction[15:12]), 
    .RegWrite(RegWrite),       
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .MemtoReg(MemtoReg),
    .ALUSrc(ALUSrc),
    .pcs_select(pcs_select),
    .hlt_select(hlt_select),
    .ALUSrc8bit(ALUSrc8bit)
);

//possibilities for opcode
//Opcode rd, rs, rt
//Opcode rd, rs, imm
//Opcode rt, rs, offset
//Opcode ccci iiii iiii
//Opcode cccx ssss xxxx
//Opcode dddd xxxx xxxx
//Opcode xxxx xxxx xxxx
RegisterFile regfile (.clk(clk), .rst(~rst_n), .SrcReg1(rs), .SrcReg2(imm), .DstReg(rd), .WriteReg(RegWrite), .DstData(datain), .SrcData1(dataout1), .SrcData2(dataout2));

//execute stage
assign aluin2 = (ALUSrc8bit == 1) ? ({8'h00, imm8bit}) : ((ALUSrc) ? {{12{imm[3]}},imm} : dataout2);
ALU ex(.ALU_Out(aluout), .Error(error), .ALU_In1(dataout1), .ALU_In2(aluin2), .ALUOp(Opcode), .Flags(Flags), .clk(clk), .rst(~rst_n));


//memory stage
memory1c dmem(.data_out(mem_out), .data_in(dataout2), .addr(aluout), .enable(MemRead), .wr(MemWrite), .clk(clk), .rst(~rst_n));


//writeback stage
assign datain = (pcs_select) ? pc_increment : ((MemtoReg) ? mem_out : aluout);




assign pc = (hlt_select) ? pc_in : pc_branch;


assign hlt = hlt_select;

endmodule
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
wire pcs_select, hlt_select, ALUSrc8bit, LoadByte, BranchReg;

//intermediate signals
//Fetch
wire [15:0] pc_in, inst, pc_incr

//Decode
wire [15:0] instruction, pc_increment, pc_branch, datain, dataout1, dataout2;
wire [3:0] Opcode, rs, rd, imm;
wire [7:0] imm8bit;
wire [8:0] imm9bit;
wire [2:0] ccc;
wire [3:0] reg1, reg2;

//Execute
wire [15:0] EX_dataout1, EX_dataout2, EX_sextimm;
wire [3:0] EX_rs, EX_rd, EX_imm, EX_ALUop;

wire [2:0] Flags;
wire [15:0] aluin2, aluout;
wire [3:0] destReg;

//Memory
wire [15:0] MEM_aluout;
wire [3:0] MEM_destReg;
wire [15:0] mem_out;


//Writeback
wire [15:0] WB_mem_out, WB_aluout;
wire [3:0] WB_destReg;

wire error;

//Fetch Stage
dff pc_reg [15:0](.q(pc_in), .d(pc_branch), .wen(~hlt_select && clk), .clk(clk), .rst(~rst_n));
imemory1c imem(.data_out(inst), .data_in(16'b0), .addr(pc_in), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));
addsub_16bit increment(.Sum(pc_incr), .A(pc_in), .B(16'h0002), .sub(1'b0), .sat());

//IF/ID Registers
dff IF/ID.Instruction [15:0](.q(instruction), .d(inst), .wen(), .clk(clk), .rst(~rst_n));
dff IF/ID.PCIncrement [15:0](.q(pc_increment), .d(pc_incr), .wen(), .clk(clk), .rst(~rst_n));


//Decode Stage
PC_control pccontrol(.C(ccc), .I(imm9bit), .F(Flags), .branch(Branch), .branch_reg(BranchReg), .PC_in(pc_increment), .regAddr(dataout1), .PC_out(pc_branch)); //PC Calculation

assign Opcode = instruction[15:12];
assign rs = instruction[7:4];
assign rd = instruction[11:8];
assign imm = instruction[3:0];
assign imm8bit = instruction[7:0];
assign imm9bit = instruction[8:0];
assign ccc = instruction[11:9];

//TODO: Need to have IF.Flush!
//Control signals
Control controlunit(
    .instruction(Opcode), 
    .RegWrite(RegWrite),       
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .BranchReg(BranchReg),
    .MemtoReg(MemtoReg),
    .ALUSrc(ALUSrc),
    .pcs_select(pcs_select),
    .hlt_select(hlt_select),
    .ALUSrc8bit(ALUSrc8bit),
    .LoadByte(LoadByte)
);

//possibilities for opcode
//Opcode rd, rs, rt
//Opcode rd, rs, imm
//Opcode rt, rs, offset (LW,SW)
//Opcode rd, uuuu uuuu  (LLB, LHB)
//Opcode ccci iiii iiii (B)
//Opcode cccx ssss xxxx (BR)
//Opcode dddd xxxx xxxx (PCS)
//Opcode xxxx xxxx xxxx (HLT)
assign reg1 = (LoadByte) ? rd : rs;
assign reg2 = (MemRead || MemWrite) ? rd : imm;
RegisterFile regfile (.clk(clk), .rst(~rst_n), .SrcReg1(reg1), .SrcReg2(reg2), .DstReg(WB_destReg), .WriteReg(RegWrite), .DstData(datain), .SrcData1(dataout1), .SrcData2(dataout2));
assign sextimm = (ALUSrc8bit == 1) ? ({8'h00, imm8bit}) : {{11{imm[3]}}, imm, 1'b0};

//ID/EX Registers
dff ID/EX.WB [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.M [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.EX [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.DataOut1 [15:0](.q(EX_dataout1), .d(dataout1), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.DataOut2 [15:0](.q(EX_dataout2), .d(dataout2), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.SEXTimm [15:0](.q(EX_sextimm), .d(sextimm), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRS [3:0](.q(EX_rs), .d(rs), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRT [3:0](.q(EX_imm), .d(imm), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRD [3:0](.q(EX_rd), .d(rd), .wen(), .clk(clk), .rst(~rst_n));
dff ID/EX.ALUop [](.q(EX_ALUop), .d(Opcode), .wen(), .clk(clk), .rst(~rst_n));

//Execute Stage
assign aluin2 = (ALUSrc) ? EX_sextimm : EX_dataout2;
ALU ex(.ALU_Out(aluout), .Error(error), .ALU_In1(EX_dataout1), .ALU_In2(aluin2), .ALUOp(EX_ALUop), .Flags(Flags), .clk(clk), .rst(~rst_n));
assign destReg = (MemRead || MemWrite) ? rd : imm;

//EX/MEM Registers
dff EX/MEM.WB [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff EX/MEM.M [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff EX/MEM.ALUOut [](.q(MEM_aluout), .d(aluout), .wen(), .clk(clk), .rst(~rst_n));
dff EX/MEM.MemData [](.q(), .d(dataout2), .wen(), .clk(clk), .rst(~rst_n)); //dataout2 will need to go through a mux
dff EX/MEM.DestReg [](.q(MEM_destReg), .d(destReg), .wen(), .clk(clk), .rst(~rst_n));


//Memory Stage
dmemory1c dmem(.data_out(mem_out), .data_in(dataout2), .addr(aluout), .enable(MemRead), .wr(MemWrite), .clk(clk), .rst(~rst_n));

//MEM/WB Registers
dff MEM/WB.WB [](.q(), .d(), .wen(), .clk(clk), .rst(~rst_n));
dff MEM/WB.MemOut [](.q(WB_mem_out), .d(mem_out), .wen(), .clk(clk), .rst(~rst_n));
dff MEM/WB.ALUOut [](.q(WB_aluout), .d(MEM_aluout), .wen(), .clk(clk), .rst(~rst_n));
dff MEM/WB.DestReg [](.q(WB_destReg), .d(MEM_destReg), .wen(), .clk(clk), .rst(~rst_n));


//Writeback Stage
assign datain = (pcs_select) ? pc_increment : ((MemtoReg) ? WB_mem_out : WB_aluout); //PC_increment doesn't exist here

assign pc = pc_in;

assign hlt = hlt_select;

endmodule
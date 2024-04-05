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
wire [15:0] IF_pc_out, IF_instruction, IF_pc_increment;

//Decode
wire [15:0] ID_instruction, ID_instruction_or_nop, ID_pc_increment, ID_pc_branch, ID_reg_datain, ID_dataout1, ID_dataout2;
wire [3:0] Opcode, ID_rs, ID_rd, ID_rt;
wire [7:0] imm8bit;
wire [8:0] imm9bit;
wire [2:0] ccc;
wire [3:0] reg1, reg2;
wire Stall;

//Execute
wire [15:0] EX_dataout1, EX_dataout2, EX_sextimm;
wire [3:0] EX_rs, EX_rd, EX_rt, EX_ALUop;
wire EX_ALUSrc, EX_MemRead, EX_MemWrite, EX_pcs_select, EX_MemtoReg, EX_RegWrite; //control signals
wire [2:0] Flags;
wire [15:0] aluin2, EX_aluout;
wire [3:0] destReg;

//Memory
wire [15:0] MEM_aluout, MEM_dmem_in;
wire [3:0] MEM_destReg;
wire [15:0] MEM_mem_out;
wire MEM_MemRead, MEM_MemWrite, MEM_pcs_select, MEM_MemtoReg, MEM_RegWrite; //control signals

//Writeback
wire [15:0] WB_mem_out, WB_aluout;
wire [3:0] WB_destReg;
wire WB_pcs_select, WB_MemtoReg, WB_RegWrite; //control signals

wire error;

//Fetch Stage
dff pc_reg [15:0](.q(IF_pc_out), .d(ID_pc_branch), .wen((~hlt_select & ~Stall) & clk), .clk(clk), .rst(~rst_n)); //double check hlt_select and Flush
imemory1c imem(.data_out(IF_instruction), .data_in(16'b0), .addr(IF_pc_out), .enable(~Stall & ~hlt_select), .wr(1'b0), .clk(clk), .rst(~rst_n));
addsub_16bit increment(.Sum(IF_pc_increment), .A(IF_pc_out), .B(16'h0002), .sub(1'b0), .sat());

//IF/ID Registers
dff IF/ID.Instruction [15:0](.q(ID_instruction), .d(IF_instruction), .wen(~hlt_select & ~Stall), .clk(clk), .rst((~rst_n) || Flush));
dff IF/ID.PCIncrement [15:0](.q(ID_pc_increment), .d(IF_pc_increment), .wen(~hlt_select & ~Stall), .clk(clk), .rst((~rst_n) || Flush));


//Decode Stage
PC_control pccontrol(.C(ccc), .I(imm9bit), .F(Flags), .branch(Branch), .branch_reg(BranchReg), .PC_in(ID_pc_increment), .regAddr(ID_dataout1), .PC_out(ID_pc_branch)); //PC Calculation
hazard hazard_unit(.ID_rs(ID_rs), .ID_rt(ID_rt), .destReg(destReg), .MEM_destReg(MEM_destReg), .Branch(Branch), .BranchReg(BranchReg), .EX_MemRead(EX_MemRead), .MemWrite(MemWrite), .Stall(Stall));

assign ID_instruction_or_nop = (Stall) ? 16'h0000 : ID_instruction;
assign Opcode = ID_instruction_or_nop[15:12];
assign ID_rs = ID_instruction_or_nop[7:4];
assign ID_rd = ID_instruction_or_nop[11:8];
assign ID_rt = ID_instruction_or_nop[3:0];
assign imm8bit = ID_instruction_or_nop[7:0];
assign imm9bit = ID_instruction_or_nop[8:0];
assign ccc = ID_instruction_or_nop[11:9];


//Control signals
Control controlunit(
    .instruction(Opcode),       //Input Decode
    .ID_pc_increment(ID_pc_increment),
    .ID_pc_branch(ID_pc_branch),
    .RegWrite(RegWrite),        //WB: Register File
    .MemRead(MemRead),          //MEM: Data Memory
    .MemWrite(MemWrite),        //MEM: Data Memory
    .Branch(Branch),            //ID: PC Control
    .BranchReg(BranchReg),      //ID: PC Control
    .MemtoReg(MemtoReg),        //WB: Mux before RegFile
    .ALUSrc(ALUSrc),            //EX: Mux before ALU
    .pcs_select(pcs_select),    //WB: Mux before RegFile
    .hlt_select(hlt_select),    //IF: Stops the PC
    .ALUSrc8bit(ALUSrc8bit),    //ID: Picks length of SEXTimm
    .LoadByte(LoadByte)         //ID: Chooses input of regfile
    .Flush(Flush)
);

//possibilities for opcode
//Opcode rd, rs, rt     (ADD, PADDSB, SUB, XOR, RED)
//Opcode rd, rs, imm    (SLL, SRA, ROR)
//Opcode rt, rs, offset (LW, SW)
//Opcode rd, uuuu uuuu  (LLB, LHB)
//Opcode ccci iiii iiii (B)
//Opcode cccx, rs, xxxx (BR)
//Opcode dddd xxxx xxxx (PCS)
//Opcode xxxx xxxx xxxx (HLT)
assign reg1 = (LoadByte) ? ID_rd : ID_rs;
assign reg2 = (MemRead || MemWrite) ? ID_rd : ID_rt;
RegisterFile regfile (.clk(clk), .rst(~rst_n), .SrcReg1(reg1), .SrcReg2(reg2), .DstReg(WB_destReg), .WriteReg(WB_RegWrite), .DstData(ID_reg_datain), .SrcData1(ID_dataout1), .SrcData2(ID_dataout2));
assign sextimm = (ALUSrc8bit == 1) ? ({8'h00, imm8bit}) : {{11{ID_rt[3]}}, ID_rt, 1'b0};

//ID/EX Registers
dff ID/EX.WB_RegWrite (.q(EX_RegWrite), .d(RegWrite), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.WB_MemtoReg (.q(EX_MemtoReg), .d(MemtoReg), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.WB_pcs_select (.q(EX_pcs_select), .d(pcs_select), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.M_MemRead (.q(EX_MemRead), .d(MemRead), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.M_MemWrite (.q(EX_MemWrite), .d(MemWrite), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.EX_ALUSrc (.q(EX_ALUSrc), .d(ALUSrc), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.DataOut1 [15:0](.q(EX_dataout1), .d(ID_dataout1), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.DataOut2 [15:0](.q(EX_dataout2), .d(ID_dataout2), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.SEXTimm [15:0](.q(EX_sextimm), .d(sextimm), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRS [3:0](.q(EX_rs), .d(ID_rs), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRT [3:0](.q(EX_rt), .d(ID_rt), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.RegisterRD [3:0](.q(EX_rd), .d(ID_rd), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff ID/EX.ALUop [3:0](.q(EX_ALUop), .d(Opcode), .wen(~hlt_select), .clk(clk), .rst(~rst_n));

//Execute Stage
assign aluin2 = (EX_ALUSrc) ? EX_sextimm : EX_dataout2;
ALU ex(.ALU_Out(EX_aluout), .Error(error), .ALU_In1(EX_dataout1), .ALU_In2(aluin2), .ALUOp(EX_ALUop), .Flags(Flags), .clk(clk), .rst(~rst_n));
assign destReg = EX_rd;

//EX/MEM Registers
dff EX/MEM.WB_RegWrite (.q(MEM_RegWrite), .d(EX_RegWrite), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.WB_MemtoReg (.q(MEM_MemtoReg), .d(EX_MemtoReg), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.WB_pcs_select (.q(MEM_pcs_select), .d(EX_pcs_select), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.M_MemRead (.q(MEM_MemRead), .d(EX_MemRead), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.M_MemWrite (.q(MEM_MemWrite), .d(EX_MemWrite), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.ALUOut [15:0](.q(MEM_aluout), .d(EX_aluout), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff EX/MEM.MemData [15:0](.q(MEM_dmem_in), .d(EX_dataout2), .wen(~hlt_select), .clk(clk), .rst(~rst_n)); //dataout2 will need to go through a mux
dff EX/MEM.DestReg [3:0](.q(MEM_destReg), .d(destReg), .wen(~hlt_select), .clk(clk), .rst(~rst_n));


//Memory Stage
dmemory1c dmem(.data_out(MEM_mem_out), .data_in(MEM_dmem_in), .addr(MEM_aluout), .enable(MEM_MemRead), .wr(MEM_MemWrite), .clk(clk), .rst(~rst_n));

//MEM/WB Registers
dff MEM/WB.WB_RegWrite (.q(WB_RegWrite), .d(MEM_RegWrite), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff MEM/WB.WB_MemtoReg (.q(WB_MemtoReg), .d(MEM_MemtoReg), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff MEM/WB.WB_pcs_select (.q(WB_pcs_select), .d(MEM_pcs_select), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff MEM/WB.MemOut [15:0](.q(WB_mem_out), .d(MEM_mem_out), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff MEM/WB.ALUOut [15:0](.q(WB_aluout), .d(MEM_aluout), .wen(~hlt_select), .clk(clk), .rst(~rst_n));
dff MEM/WB.DestReg [3:0](.q(WB_destReg), .d(MEM_destReg), .wen(~hlt_select), .clk(clk), .rst(~rst_n));


//Writeback Stage
assign ID_reg_datain = (WB_pcs_select) ? ID_pc_increment : ((WB_MemtoReg) ? WB_mem_out : WB_aluout); //PC_increment doesn't exist here

assign pc = IF_pc_out;

assign hlt = hlt_select;

endmodule
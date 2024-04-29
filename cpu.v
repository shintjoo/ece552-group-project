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
wire pcs_select, hlt_select, ALUSrc8bit, LoadByte, BranchReg, Flush;


//intermediate signals
//Fetch
wire [15:0] IF_pc_out, IF_instruction, IF_pc_increment, IF_pc_choose;

//Decode
wire [15:0] ID_instruction, ID_instruction_or_nop, ID_pc_increment, ID_pc_branch, ID_reg_datain, ID_dataout1, ID_dataout2;
wire [3:0] Opcode, ID_rs, ID_rd, ID_rt;
wire [7:0] imm8bit;
wire [8:0] imm9bit;
wire [15:0] sextimm;
wire [2:0] ccc;
wire [3:0] reg1, reg2;
wire Stall;
wire RegWrite_NOP, MemtoReg_NOP, pcs_select_NOP, MemRead_NOP, MemWrite_NOP, ALUSrc_NOP, ALUSrc8bit_NOP, hlt_select_NOP;
wire [15:0] ID_dataout1_NOP, ID_dataout2_NOP, sextimm_NOP;
wire [3:0] ID_rs_NOP, ID_rt_NOP, ID_rd_NOP, Opcode_NOP;

//Execute
wire [15:0] EX_dataout1, EX_dataout2, EX_sextimm;
wire [3:0] EX_rs, EX_rd, EX_rt, EX_ALUop;
wire EX_ALUSrc, EX_ALUSrc8bit, EX_MemRead, EX_MemWrite, EX_pcs_select, EX_MemtoReg, EX_RegWrite, EX_hlt_select; //control signals
wire [2:0] Flags;
wire [15:0] aluin2, EX_aluout, ALUFwdIn1, ALUFwdIn2, ALUFwdReg, EX_pc_increment;
wire [3:0] destReg;
wire [1:0] ALUFwd1, ALUFwd2;

//Memory
wire [15:0] MEM_aluout, MEM_dmem_in;
wire [3:0] MEM_destReg;
wire [15:0] MEM_mem_out, MEMFwdIn, MEM_pc_increment;
wire MEM_MemRead, MEM_MemWrite, MEM_pcs_select, MEM_MemtoReg, MEM_RegWrite, MEM_hlt_select; //control signals
wire MEMFwd;

//Writeback
wire [15:0] WB_mem_out, WB_aluout, WB_pc_increment;
wire [3:0] WB_destReg;
wire WB_pcs_select, WB_MemtoReg, WB_RegWrite, WB_hlt_select; //control signals

wire error;

//Fetch Stage
assign IF_pc_choose = ((Branch || BranchReg) & Flush) ? ID_pc_branch : IF_pc_increment;
dff pc_reg [15:0](.q(IF_pc_out), .d(IF_pc_choose), .wen((~hlt_select & ~Stall) & clk), .clk(clk), .rst(~rst_n)); //double check hlt_select and Flush
imemory1c imem(.data_out(IF_instruction), .data_in(16'b0), .addr(IF_pc_out), .enable(~Stall & ~hlt_select), .wr(1'b0), .clk(clk), .rst(~rst_n));
addsub_16bit increment(.Sum(IF_pc_increment), .A(IF_pc_out), .B(16'h0002), .sub(1'b0), .sat());

//IF/ID Registers
dff IFID_Instruction [15:0](.q(ID_instruction), .d(IF_instruction), .wen(~hlt_select & ~Stall), .clk(clk), .rst((~rst_n) || Flush));
dff IFID_PCIncrement [15:0](.q(ID_pc_increment), .d(IF_pc_increment), .wen(~hlt_select & ~Stall), .clk(clk), .rst((~rst_n) || Flush));


//Decode Stage // I changed MEM_DesReg to be desReg.
PC_control pccontrol(.C(ccc), .I(imm9bit), .F(Flags), .branch(Branch), .branch_reg(BranchReg), .PC_in(ID_pc_increment), .regAddr(ID_dataout1), .PC_out(ID_pc_branch)); //PC Calculation
hazard hazard_unit(.ID_rs(reg1), .ID_rt(reg2), .MEM_destReg(MEM_destReg), .destReg(destReg), .Branch(Branch), .BranchReg(BranchReg), .EX_MemRead(EX_MemRead), .MemWrite(MemWrite), .Stall(Stall));
 
assign ID_instruction_or_nop = ID_instruction; //(Stall) ? 16'h0000 :
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
    .LoadByte(LoadByte),        //ID: Chooses input of regfile
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
assign sextimm = (ALUSrc8bit) ? ({8'h00, imm8bit}) : (MemRead || MemWrite) ? ({{11{ID_rt[3]}}, ID_rt, 1'b0}) : {{12{1'b0}}, ID_rt};

assign RegWrite_NOP = (Stall) ? 1'b0 : RegWrite;
assign MemtoReg_NOP = (Stall) ? 1'b0 : MemtoReg;
assign pcs_select_NOP = (Stall) ? 1'b0 : pcs_select;
assign MemRead_NOP = (Stall) ? 1'b0 : MemRead;
assign MemWrite_NOP = (Stall) ? 1'b0 : MemWrite;
assign ALUSrc_NOP = (Stall) ? 1'b0 : ALUSrc;
assign ALUSrc8bit_NOP = (Stall) ? 1'b0 : ALUSrc8bit;
assign ID_dataout1_NOP = (Stall) ? 16'h0000 : ID_dataout1;
assign ID_dataout2_NOP = (Stall) ? 16'h0000 : ID_dataout2;
assign sextimm_NOP = (Stall) ? 16'h0000 : sextimm;
assign ID_rs_NOP = (Stall) ? 4'b0000 : ID_rs;
assign ID_rt_NOP = (Stall) ? 4'b0000 : ID_rt;
assign ID_rd_NOP = (Stall) ? 4'b0000 : ID_rd;
assign Opcode_NOP = (Stall) ? 4'b0000 : Opcode;
assign hlt_select_NOP = (Stall) ? 1'b0 : hlt_select;

//ID/EX Registers
dff IDEX_WB_RegWrite (.q(EX_RegWrite), .d(RegWrite_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_WB_MemtoReg (.q(EX_MemtoReg), .d(MemtoReg_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_WB_pcs_select (.q(EX_pcs_select), .d(pcs_select_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_M_MemRead (.q(EX_MemRead), .d(MemRead_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_M_MemWrite (.q(EX_MemWrite), .d(MemWrite_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_EX_ALUSrc (.q(EX_ALUSrc), .d(ALUSrc_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_EX_ALUSrc8bit (.q(EX_ALUSrc8bit), .d(ALUSrc8bit_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_DataOut1 [15:0](.q(EX_dataout1), .d(ID_dataout1_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_DataOut2 [15:0](.q(EX_dataout2), .d(ID_dataout2_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_SEXTimm [15:0](.q(EX_sextimm), .d(sextimm_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_RegisterRS [3:0](.q(EX_rs), .d(ID_rs_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_RegisterRT [3:0](.q(EX_rt), .d(ID_rt_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_RegisterRD [3:0](.q(EX_rd), .d(ID_rd_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_ALUop [3:0](.q(EX_ALUop), .d(Opcode_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_hlt_select (.q(EX_hlt_select), .d(hlt_select_NOP), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));
dff IDEX_pc_increment [15:0](.q(EX_pc_increment), .d(ID_pc_increment), .wen(~EX_hlt_select), .clk(clk), .rst(~rst_n));

//Execute Stage
assign aluin2 = (EX_ALUSrc || EX_ALUSrc8bit) ? EX_sextimm : EX_dataout2;
assign ALUFwdIn1 = (ALUFwd1[1]) ? MEM_aluout : ((ALUFwd1[0]) ? ID_reg_datain : EX_dataout1);
assign ALUFwdIn2 = (ALUFwd2[1]) ? MEM_aluout : ((ALUFwd2[0]) ? ID_reg_datain : aluin2);
ALU ex(.ALU_Out(EX_aluout), .Error(error), .ALU_In1(ALUFwdIn1), .ALU_In2(ALUFwdIn2), .ALUOp(EX_ALUop), .Flags(Flags), .clk(clk), .rst(~rst_n));
assign destReg = EX_rd;
assign ALUFwdReg = (ALUFwd2[1]) ? MEM_aluout : ((ALUFwd2[0]) ? ID_reg_datain : EX_dataout2);
ForwardingUnit fwd_unit(
    .EX_rd(EX_rd),
    .EX_rs(EX_rs), 
    .EX_rt(EX_rt), 
    .MEM_destReg(MEM_destReg), 
    .WB_destReg(WB_destReg), 
    .MEM_MemRead(MEM_MemRead), 
    .MEM_RegWrite(MEM_RegWrite), 
    .WB_RegWrite(WB_RegWrite),
    .EX_ALUSrc8bit(EX_ALUSrc8bit),
    .ALUFwd1(ALUFwd1), 
    .ALUFwd2(ALUFwd2), 
    .MEMFwd(MEMFwd)
    );

//EX/MEM Registers
dff EXMEM_WB_RegWrite (.q(MEM_RegWrite), .d(EX_RegWrite), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_WB_MemtoReg (.q(MEM_MemtoReg), .d(EX_MemtoReg), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_WB_pcs_select (.q(MEM_pcs_select), .d(EX_pcs_select), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_M_MemRead (.q(MEM_MemRead), .d(EX_MemRead), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_M_MemWrite (.q(MEM_MemWrite), .d(EX_MemWrite), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_ALUOut [15:0](.q(MEM_aluout), .d(EX_aluout), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_MemData [15:0](.q(MEM_dmem_in), .d(ALUFwdReg), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n)); //dataout2 will need to go through a mux
dff EXMEM_DestReg [3:0](.q(MEM_destReg), .d(destReg), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_hlt_select (.q(MEM_hlt_select), .d(EX_hlt_select), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));
dff EXMEM_pc_increment [15:0](.q(MEM_pc_increment), .d(EX_pc_increment), .wen(~MEM_hlt_select), .clk(clk), .rst(~rst_n));


//Memory Stage
assign MEMFwdIn = (MEMFwd) ? ID_reg_datain : MEM_dmem_in;
dmemory1c dmem(.data_out(MEM_mem_out), .data_in(MEMFwdIn), .addr(MEM_aluout), .enable(1'b1), .wr(MEM_MemWrite), .clk(clk), .rst(~rst_n));

//MEM/WB Registers
dff MEMWB_WB_RegWrite (.q(WB_RegWrite), .d(MEM_RegWrite), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_WB_MemtoReg (.q(WB_MemtoReg), .d(MEM_MemtoReg), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_WB_pcs_select (.q(WB_pcs_select), .d(MEM_pcs_select), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_MemOut [15:0](.q(WB_mem_out), .d(MEM_mem_out), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_ALUOut [15:0](.q(WB_aluout), .d(MEM_aluout), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_DestReg [3:0](.q(WB_destReg), .d(MEM_destReg), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_hlt_select (.q(WB_hlt_select), .d(MEM_hlt_select), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));
dff MEMWB_pc_increment [15:0](.q(WB_pc_increment), .d(MEM_pc_increment), .wen(~WB_hlt_select), .clk(clk), .rst(~rst_n));

//Writeback Stage
assign ID_reg_datain = (WB_pcs_select) ? WB_pc_increment : ((WB_MemtoReg) ? WB_mem_out : WB_aluout); //PC_increment doesn't exist here

assign pc = IF_pc_out;

assign hlt = WB_hlt_select;

endmodule
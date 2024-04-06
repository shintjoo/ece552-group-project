module ForwardingUnit(EX_rd, EX_rs, EX_rt, MEM_destReg, WB_destReg, MEM_MemRead, MEM_RegWrite, WB_RegWrite, EX_ALUSrc8bit, ALUFwd1, ALUFwd2, MEMFwd);
input [3:0] EX_rd, EX_rs, EX_rt, MEM_destReg, WB_destReg;
input MEM_MemRead, MEM_RegWrite, WB_RegWrite, EX_ALUSrc8bit;

output [1:0] ALUFwd1, ALUFwd2;
output MEMFwd;

wire ALU_EX_EX1, ALU_MEM_EX1, ALU_EX_EX2, ALU_MEM_EX2, ALU_MEM_MEM;

//EX-EX
assign ALU_EX_EX1 = ((MEM_RegWrite & (MEM_destReg != 4'b0000) & (EX_rs == MEM_destReg)) || (EX_ALUSrc8bit & (EX_rd == MEM_destReg))) ? 1'b1 : 1'b0;
assign ALU_EX_EX2 = (MEM_RegWrite & (MEM_destReg != 4'b0000) & (EX_rt == MEM_destReg)) ? 1'b1 : 1'b0;

//MEM-EX
assign ALU_MEM_EX1 = (WB_RegWrite & (WB_destReg != 4'b0000) & (EX_rs == WB_destReg) & !ALU_EX_EX1) ? 1'b1 : 1'b0;
assign ALU_MEM_EX2 = (WB_RegWrite & (WB_destReg != 4'b0000) & (EX_rt == WB_destReg) & !ALU_EX_EX2) ? 1'b1 : 1'b0;

//MEM-MEM
assign ALU_MEM_MEM = (WB_RegWrite & (WB_destReg != 4'b0000) & (MEM_destReg == WB_destReg)) ? 1'b1 : 1'b0;

//assign mux control
assign ALUFwd1 = (ALU_EX_EX1) ? 2'b10 : (ALU_MEM_EX1) ? 2'b01 : 2'b00;
assign ALUFwd2 = (ALU_EX_EX2) ? 2'b10 : (ALU_MEM_EX2) ? 2'b01 : 2'b00;
assign MEMFwd = ALU_MEM_MEM;

endmodule
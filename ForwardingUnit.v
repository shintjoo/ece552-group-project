module ForwardingUnit(EX_rs, EX_rd, MEM_destReg, WB_destReg, MEM_MemRead, WB_RegWrite, ALUFwd1, ALUFwd2);
input [3:0] EX_rs, EX_rd, MEM_destReg, WB_destReg;
input MEM_MemRead, WB_RegWrite;

output [1:0] ALUFwd1, ALUFwd2;


assign ALUFwd1 = ((MEM_destReg != EX_rs) & (WB_destReg != EX_rs)) ? 2'b10 : ((WB_destReg == EX_rs) & MEM_MemRead) ? 2'b01 : 2'b00;


endmodule
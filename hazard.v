module hazard(ID_rs, ID_rt, MEM_destReg, destReg, Branch, BranchReg, EX_MemRead, MemWrite, Stall);
input [3:0] ID_rs, ID_rt; 
input [3:0] MEM_destReg, destReg; 
input EX_MemRead, MemWrite, Branch, BranchReg;
output Stall;

wire stall1, stall2, stall3;

//Load to use stalls.
assign stall1 = (EX_MemRead & (destReg != 4'b0000) & ((ID_rs == destReg) || ((ID_rt == destReg) & !MemWrite)));        //Load to use
assign stall2 = (((MEM_destReg == ID_rs) || (destReg == ID_rs)) & (BranchReg));     //Branch Register
assign stall3 = ((MEM_destReg == ID_rs) & (BranchReg));      //Branch
assign Stall = stall1 ^ stall2 ^ stall3;

endmodule
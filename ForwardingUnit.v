module ForwardingUnit(C, I, F, branch, branch_reg, PC_in, regAddr, PC_out);
input [15:0] control; //conditions from instruction
input [3:0] ID/EX.RT; //9 bit signed offset
input MEM.mem;
input PC;

output [15:0] IF/ID.DFF; //Goes into the IF/ID
output [15:0] NOP; //Goes into the IF/ID
output stall;

//Load to use stalls.

//Branch

//Register Bypassing.

endmodule
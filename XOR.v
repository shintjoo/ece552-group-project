/*
 * XOR.v
 * Shawn Zhu
 * ECE552
 */
module XOR(Res, A, B);
input [16:0] A, B; //Inputs to be XOR'ed
output [16:0] Res;

assign Res = A ^ B;

endmodule

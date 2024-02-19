/*
 * PADDSB.v
 * Shawn Zhu
 * ECE552
 */
module PADDSB (Sum, A, B);
input [15:0] A, B; 	// Input data values
output [15:0] Sum; 	// Sum output

wire[3:0] b15to12, b11to8, b7to4, b3to0; //Intermediate signals for the results of the 4 bit adds
wire ov15to12,ov11to8,ov7to4, ov3to0;	//Intermediate signals for the overflow


//4 bit addition
addsub_4bit add15to12(.Sum(b15to12), .A(A[15:12]), .B(B[15:12]), .sub(1'b0));
addsub_4bit add11to8(.Sum(b11to8), .A(A[11:8]), .B(B[11:8]), .sub(1'b0));
addsub_4bit add7to4(.Sum(b7to4), .A(A[7:4]), .B(B[7:4]), .sub(1'b0));
addsub_4bit add3to0(.Sum(b3to0), .A(A[3:0]), .B(B[3:0]), .sub(1'b0));

//logic to assign the 4x4bit sums to the 16 bit output
assign Sum = {b15to12, b11to8, b7to4, b3to0};


endmodule

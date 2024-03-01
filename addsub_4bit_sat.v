/*
 * adder_4bit_sat.v
 * Shawn Zhu
 * ECE552
 */
module adder_4bit_sat (Sum, A, B, Cin);
input [3:0] A, B; 	//Input values
output [3:0] Sum; 	//sum output
input Cin;



wire [3:0] C;
wire [3:0] sum_res;
wire ovfl_pos;
wire ovfl_neg; //To indicate overflow
wire [3:0] P, G; //to store propogate and generate signals


//Generate and Propogate signals
assign G = A & B;
assign P = A ^ B;

//Carry look ahead logic
assign C[0] = Cin; 
assign C[1] = G[0] | (P[0] & C[0]);
assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);

//calculate sum
assign sum_res = P ^ C;

//check if both inputs are positive
assign ovfl_pos = ~A[3] & ~B[3] & sum_res[3]; 

//check if both inputs are negative
assign ovfl_neg = A[3] & B[3] & ~sum_res[3]; 

//deal with saturation
assign Sum = (ovfl_pos) ? 4'b0111 : ((ovfl_neg) ?  4'b1000 : sum_res);



endmodule

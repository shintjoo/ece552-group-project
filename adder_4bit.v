/*
 * adder_4bit.v
 * Shawn Zhu
 * ECE552
 */
module adder_4bit (Sum, A, B, Cin, Cout);
input [3:0] A, B; 	//Input values
output [3:0] Sum; 	//sum output
input Cin;
output Cout;


wire [3:0] C;
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
assign Sum = P ^ C;

//check if both inputs are positive
assign ovfl_pos = ~A[3] & ~B[3] & Sum[3]; 

//check if both inputs are negative
assign ovfl_neg = A[3] & B[3] & ~Sum[3]; 

//set a carry out value (will be necessary for 16 bit adder)
assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);


endmodule

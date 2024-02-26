/*
 * sub_4bit.v
 * Shawn Zhu
 * ECE552
 */
module sub_4bit (Sum, A, B, Cin, Cout);
input [3:0] A, B; 	//Input values
output [3:0] Sum; 	//sum output
input Cin;
output Cout;

wire [3:0] B_comp;
wire CoutB; 

//Flip the bits in B
assign B_comp = ~B;

//Add one to finish negation
adder_4bit addB(.Sum(B_comp), .A(B_comp), .B(4'h1), .Cin(4'h0), .Cout(CoutB));

//Add the negated B to A
adder_4bit adder(.Sum(Sum), .A(A), .B(B_comp), .Cin(Cin), .Cout(Cout));

endmodule
/*
 * addsub_4bit.v
 * Shawn Zhu
 * ECE552
 */
module full_adder_1bit( A, B, Cin, S, Cout);
  input A,B,Cin;		// three input bits to be added
  output S,Cout;		// Sum and carry out

  assign S = A ^ B ^ Cin;
  assign Cout = (A & B) | (A & Cin) | (B & Cin);
  
endmodule

module addsub_4bit (Sum, Ovfl, A, B, sub);
input [3:0] A, B; 	//Input values
input sub; 			//add-sub indicator
output [3:0] Sum; 	//sum output
output Ovfl; 		//To indicate overflow

wire [3:0] B_comp;
wire [3:0] Cin;
wire [3:0] Cout;
wire both_pos,both_neg;

assign B_comp = (sub == 1) ? ~B : B;	//Check whether B needs to be negated or not
assign Cin[3:0] = {Cout[2:0], sub};		//Create a vector for Cin with sub being the initial carry in

full_adder_1bit FA1[3:0](.A(A), .B(B_comp), .Cin(Cin), .S(Sum), .Cout(Cout)); //Example of using the one bit full adder (which you must also design)

//check if both inputs are positive
assign both_pos = ~A[3] & ~B_comp[3]; 

//check if both inputs are negative
assign both_neg = A[3] & B_comp[3]; 

//check overflow
assign Ovfl = both_pos & Sum[3] | both_neg & ~Sum[3];


endmodule

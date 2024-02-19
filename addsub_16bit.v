/*
 * addsub_16bit.v
 * Shawn Zhu
 * ECE552
 */
module addsub_16bit (Sum, A, B, sub);
input [15:0] A, B; 	//Input values
input sub; 		//add-sub indicator
output [15:0] Sum; 	//sum output


wire [15:0] B_comp;
wire [15:0] Cin;
wire [15:0] Cout;
wire [15:0] sum_res;
wire ovfl_pos, ovfl_neg; //To indicate overflow

assign B_comp = (sub == 1) ? ~B : B;	//Check whether B needs to be negated or not
assign Cin[15:0] = {Cout[14:0], sub};	//Create a vector for Cin with sub being the initial carry in

full_adder_1bit FA1[15:0](.A(A), .B(B_comp), .Cin(Cin), .S(Sum), .Cout(Cout)); //Example of using the one bit full adder (which you must also design)

//check if both inputs are positive
assign ovfl_pos = ~A[15] & ~B_comp[15] & Sum[15]; 

//check if both inputs are negative
assign ovfl_neg = A[15] & B_comp[15] & ~Sum[15]; 

//deal with saturation
assign Sum = (ovfl_pos) ? 16'h7FFF : ((ovfl_neg) ?  16'h8000 : sum_res);


endmodule

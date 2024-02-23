/*
 * addsub_4bit.v
 * Shawn Zhu
 * ECE552
 */
module addsub_4bit (Sum, A, B, sub);
input [3:0] A, B; 	//Input values
input sub; 		//add-sub indicator
output [3:0] Sum; 	//sum output


wire [3:0] B_comp;
wire [3:0] Cin;
wire [3:0] Cout;
wire [3:0] sum_res;
wire ovfl_pos;
wire ovfl_neg; //To indicate overflow

assign B_comp = (sub == 1) ? ~B : B;	//Check whether B needs to be negated or not
assign Cin[3:0] = {Cout[2:0], sub};	//Create a vector for Cin with sub being the initial carry in

full_adder_1bit FA1[3:0](.A(A), .B(B_comp), .Cin(Cin), .S(sum_res), .Cout(Cout)); //Example of using the one bit full adder (which you must also design)

//check if both inputs are positive
assign ovfl_pos = ~A[3] & ~B_comp[3] & sum_res[3]; 

//check if both inputs are negative
assign ovfl_neg = A[3] & B_comp[3] & ~sum_res[3]; 

//deal with saturation
assign Sum = (ovfl_pos) ? 4'b0111 : ((ovfl_neg) ?  4'b1000 : sum_res);


endmodule

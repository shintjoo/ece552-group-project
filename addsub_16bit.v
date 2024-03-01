/*
 * addsub_16bit.v
 * Shawn Zhu
 * ECE552
 */
module addsub_16bit (Sum, A, B, sub, sat);
input [15:0] A, B; 	//Input values
input sub; 		//add-sub indicator
output [15:0] Sum; 	//sum output'
output sat;


wire [15:0] B_comp;
wire [3:0] C;
wire [15:0] sum_res;
wire ovfl_pos, ovfl_neg; //To indicate overflow

assign B_comp = (sub == 1) ? ~B : B;	//Check whether B needs to be negated or not

//Generate and Propogate signals
assign G = A & B;
assign P = A ^ B;


adder_4bit lsb (.Sum(sum_res[3:0]), .A(A[3:0]), .B(B_comp[3:0]), .Cin(sub), .Cout(C[0]));
adder_4bit mb1 (.Sum(sum_res[7:4]), .A(A[7:4]), .B(B_comp[7:4]), .Cin(C[0]), .Cout(C[1]));
adder_4bit mb2 (.Sum(sum_res[11:8]), .A(A[11:8]), .B(B_comp[11:8]), .Cin(C[1]), .Cout(C[2]));
adder_4bit msb (.Sum(sum_res[15:12]), .A(A[15:12]), .B(B_comp[15:12]), .Cin(C[2]), .Cout(C[3]));

//check if both inputs are positive
assign ovfl_pos = ~A[15] & ~B_comp[15] & sum_res[15]; 

//check if both inputs are negative
assign ovfl_neg = A[15] & B_comp[15] & ~sum_res[15]; 

//deal with saturation
assign Sum = (ovfl_pos) ? 16'h7FFF : ((ovfl_neg) ?  16'h8000 : sum_res);

assign sat = ovfl_pos | ovfl_neg;

endmodule

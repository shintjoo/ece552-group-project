/*
 * RED.v
 * Shawn Zhu
 * ECE552
 */
module RED(Sum, In1, In2);
input [15:0] In1, In2;
output [15:0] Sum;

wire [3:0] ac1, ac2, acc;
wire [3:0] bd1, bd2, bdc;
wire [1:0] accarry, bdcarry, rescarry;
wire out;
wire [3:0] sum1, sum2, sum3;

//Add A and C
adder_4bit AClsb(.Sum(ac1), .A(In1[11:8]), .B(In2[11:8]), .Cin(1'b0), .Cout(accarry[0]));
adder_4bit ACmsb(.Sum(ac2), .A(In1[15:12]), .B(In2[15:12]), .Cin(accarry[0]), .Cout(accarry[1]));

//Add B and D
adder_4bit BDlsb(.Sum(bd1), .A(In1[3:0]), .B(In2[3:0]), .Cin(1'b0), .Cout(bdcarry[0]));
adder_4bit BDmsb(.Sum(bd2), .A(In1[7:4]), .B(In2[7:4]), .Cin(bdcarry[0]), .Cout(bdcarry[1]));

//calculate result
adder_4bit reslsb(.Sum(sum1), .A(ac1), .B(bd1), .Cin(1'b0), .Cout(rescarry[0]));
adder_4bit resmsb(.Sum(sum2), .A(ac2), .B(bd2), .Cin(rescarry[0]), .Cout(rescarry[1]));
adder_4bit rescarry1(.Sum(sum3), .A({3'b0, accarry[1]}), .B({3'b0, bdcarry[1]}), .Cin(rescarry[1]), .Cout(out));

assign Sum = {{6{sum3[1]}}, sum3[1:0], sum2, sum1};

endmodule
/*
 * RED.v
 * Shawn Zhu
 * ECE552
 */
module RED(Sum, In1, In2);
input [15:0] In1, In2;
output [15:0] Sum;

wire [15:0] a, b, c, d;
wire [15:0] ac_res, bd_res;

//assign sign extended temp values split up into the bytes
assign a = {{8{In1[15]}}, In1[15:8]};
assign b = {{8{In1[7]}}, In1[7:0]};
assign c = {{8{In2[15]}}, In2[15:8]};
assign d = {{8{In2[7]}}, In2[7:0]};

//Add the temp values
addsub_16bit add1(.Sum(ac_res), .A(a), .B(c), .sub(1'b0));
addsub_16bit add2(.Sum(bd_res), .A(b), .B(d), .sub(1'b0));

//Set the output
addsub_16bit add3(.Sum(Sum), .A(ac_res), .B(bd_res), .sub(1'b0));

endmodule
/*
* PSA_16bit_tb.sv
* Shawn Zhu
* ECE552
*/
module PSA_16bit_tb();
reg signed [15:0] A,B; 	//operands for addition and subtraction
wire [15:0] Sum; 	//operation result
wire Error; 		//overflow indicator

////// Instantiate the device////////
PSA_16bit DUT(.Sum(Sum), .Error(Error), .A(A), .B(B));

logic signed [3:0] sum1, sum2, sum3, sum4 = 0;
logic [15:0] sum_check = 0;
logic ovfl_check = 0;
initial begin
	$randomize;
	repeat(50) begin
		// set inputs to be random
		A = $random;
		B = $random;
	
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b", A, B);

		// variable longer than 4 bits to check overflow later
		sum1 = A[3:0] + B[3:0];
		sum2 = A[7:4] + B[7:4];
		sum3 = A[11:8] + B[11:8];
		sum4 = A[15:12] + B[15:12];
		sum_check = {sum4, sum3, sum2, sum1};
	
		//if the result cannot be representable in 4 bits then set overflow check
		if((A[3] && B[3] && ~sum1[3]) || (~A[3] && ~B[3] && sum1[3])) ovfl_check = 1;
		else if((A[7] && B[7] && ~sum2[3]) || (~A[7] && ~B[7] && sum2[3])) ovfl_check = 1;
		else if((A[11] && B[11] && ~sum3[3]) || (~A[11] && ~B[11] && sum3[3])) ovfl_check = 1;
		else if((A[15] && B[15] && ~sum4[3]) || (~A[15] && ~B[15] && sum4[3])) ovfl_check = 1;
		else ovfl_check = 0;


		#1
		$display("Sum: %b, Error: %b", Sum, Error);

		//Adder worked if the 4 bit result matches and the overflow was checked correctly
		if(sum_check != Sum || Error != ovfl_check) $error("TEST FAILED");
		else $display("TEST PASSED");
	end
end
endmodule

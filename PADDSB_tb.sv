/*
 * PADDSB_tb.sv
 * Shawn Zhu
 * ECE552
 */
module PADDSB_tb ();
reg signed [15:0] A, B;
wire [15:0] Sum;

PADDSB DUT(.Sum(Sum), .A(A), .B(B));

logic signed [4:0] sum1, sum2, sum3, sum4 = 0;
logic [15:0] sum_check = 0;
logic ovfl_pos, ovfl_neg = 0;
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
		if(sum1 < -8 || sum2 < -8 || sum3 < -8 || sum4 < -8) begin
			ovfl_neg = 1;
			ovfl_pos = 0;
		end
		else if(sum1 > 7 || sum2 > 7 || sum3 > 7 || sum4 > 7) begin 
			ovfl_neg = 0;
			ovfl_pos = 1;
		else begin
			ovfl_neg = 0;
			ovfl_pos = 0;
		end

		#1
		$display("Sum: %b", Sum);

		//Adder worked if the 4 bit result matches and the overflow was checked correctly
		if(sum_check != Sum || Error != ovfl_check) $error("TEST FAILED");
		else $display("TEST PASSED");
		if(ovfl_pos) begin
		
		end
		else if(ovfl_neg) begin
		
		end
		else begin
		
		end
	end
end
endmodule

endmodule
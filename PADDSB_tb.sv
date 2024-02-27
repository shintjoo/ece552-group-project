/*
 * PADDSB_tb.sv
 * Shawn Zhu
 * ECE552
 */
module PADDSB_tb ();
reg signed [15:0] A, B;
wire [15:0] Sum;

PADDSB DUT(.Sum(Sum), .A(A), .B(B));

logic signed [3:0] sum1, sum2, sum3, sum4 = 0;
logic signed [3:0] sum1_res, sum2_res, sum3_res, sum4_res = 0;
logic [15:0] sum_check = 0;
logic [3:0] ovfl_pos, ovfl_neg;

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
		sum_check = {sum4[3:0], sum3[3:0], sum2[3:0], sum1[3:0]};


	
		//if the result cannot be representable in 4 bits then set overflow check
		//sum1
		if(~A[3] && ~B[3] && sum1[3]) begin
			ovfl_pos[0] = 1;
			ovfl_neg[0] = 0;
		end
		else if(A[3] && B[3] && ~sum1[3]) begin
			ovfl_pos[0] = 0;
			ovfl_neg[0] = 1;	
		end
		else begin
			ovfl_pos[0] = 0;
			ovfl_neg[0] = 0;	
		end

		//sum2
		if(~A[7] && ~B[7] && sum2[3]) begin
			ovfl_pos[1] = 1;
			ovfl_neg[1] = 0;
		end
		else if(A[7] && B[7] && ~sum2[3]) begin
			ovfl_pos[1] = 0;
			ovfl_neg[1] = 1;	
		end
		else begin
			ovfl_pos[1] = 0;
			ovfl_neg[1] = 0;	
		end
		
		//sum3
		if(~A[11] && ~B[11] && sum3[3]) begin
			ovfl_pos[2] = 1;
			ovfl_neg[2] = 0;
		end
		else if(A[11] && B[11] && ~sum3[3]) begin
			ovfl_pos[2] = 0;
			ovfl_neg[2] = 1;	
		end
		else begin
			ovfl_pos[2] = 0;
			ovfl_neg[2] = 0;	
		end
		
		//sum4
		if(~A[15] && ~B[15] && sum4[3]) begin
			ovfl_pos[3] = 1;
			ovfl_neg[3] = 0;
		end
		else if(A[15] && B[15] && ~sum4[3]) begin
			ovfl_pos[3] = 0;
			ovfl_neg[3] = 1;	
		end
		else begin
			ovfl_pos[3] = 0;
			ovfl_neg[3] = 0;	
		end

		#1
		$display("Sum: %b", Sum);
		sum1_res = Sum[3:0];
		sum2_res = Sum[7:4];
		sum3_res = Sum[11:8];
		sum4_res = Sum[15:12];

		//Adder worked if the 4 bit result matches and the overflow was checked correctly
		//check for positive overflow
		if(|ovfl_pos)begin
			if(ovfl_pos[0]) begin
				if(sum1_res != 7) $error("TEST FAILED: sum1 != 7");
			end
			if(ovfl_pos[1]) begin
				if(sum2_res != 7) $error("TEST FAILED: sum2 != 7");
			end
			if(ovfl_pos[2]) begin
				if(sum3_res != 7) $error("TEST FAILED: sum3 != 7");
			end
			if(ovfl_pos[3]) begin
				if(sum4_res != 7) $error("TEST FAILED: sum4 != 7");
			end
		end
		else if (|ovfl_neg) begin
			if(ovfl_neg[0]) begin
				if(sum1_res != -8) $error("TEST FAILED: sum1 != -8");
			end
			if(ovfl_neg[1]) begin
				if(sum2_res != -8) $error("TEST FAILED: sum2 != -8");
			end
			if(ovfl_neg[2]) begin
				if(sum3_res != -8) $error("TEST FAILED: sum3 != -8");
			end
			if(ovfl_neg[3]) begin
				if(sum4_res != -8) $error("TEST FAILED: sum4 != -8");
			end
		end
		else begin
			if(sum_check != Sum) $error("TEST FAILED: sums are not equal");
		end

	end
	$display("ALL TEST PASSED");
end
endmodule

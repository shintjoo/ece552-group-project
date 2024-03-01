/*
 * RED_tb.sv
 * Shawn Zhu
 * ECE552
 */
module RED_tb();
reg signed [15:0] In1, In2;
wire [15:0] Sum;

RED DUT(.Sum(Sum), .In1(In1), .In2(In2));

logic signed [15:0] sum_res = 0;
logic signed [15:0] sum_check = 0;

initial begin
	$randomize;
	repeat(50) begin
		In1 = $random;
		In2 = $random;
		
		sum_res = In1[15:8] + In2[15:8] + In1[7:0] + In2[7:0];
		sum_check = {{7{sum_res[9]}}, sum_res[8:0]};
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b", In1, In2);
		
		#1
		$display("Sum: %b", Sum);

		if(sum_check != Sum) $error("TEST FAILED: Results not equal");
		else $display("ALL TEST PASSED");
	
	end
end

endmodule

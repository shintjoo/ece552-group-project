/*
 * addsub_4bit_tb.sv
 * Shawn Zhu
 * ECE552
 */
 module addsub_4bit_tb();

reg signed [3:0] A,B;		//operands for addition and subtraction
reg sub;			//0 for addition, 1 for subtraction

wire [3:0] Sum;			//operation result
wire Ovfl;			//overflow indicator

////// Instantiate the device////////
addsub_4bit iDUT(.Sum(Sum), .Ovfl(Ovfl), .A(A), .B(B), .sub(sub));

int sum_check = 0;
int ovfl_check = 0;
initial begin
	repeat(20) begin
		// set inputs to be random
		A = $random;
		B = $random;
		sub = $random;
		
		ovfl_check = 0;
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b, sub: %b", A, B, sub);

		// variable longer than 4 bits to check overflow later
		sum_check = sub ? (A-B): (A+B);
		
		//if the result cannot be representable in 4 bits then set overflow check
		if(sum_check > 7 || sum_check < -8) ovfl_check = 1;
		else ovfl_check = 0;
		
		#1
		$display("Sum: %b, Ovfl: %b", Sum, Ovfl);

		//Adder worked if the 4 bit result matches and the overflow was checked correctly
		if(sum_check[3:0] != Sum || Ovfl != ovfl_check) $error("TEST %0d FAILED", $time);
		else $display("TEST PASSED");

	end
end

endmodule


module XOR_tb;
reg [15:0] A, B;
wire [15:0] Res;


XOR DUT (.A(A), .B(B), .Res(Res));

logic [15:0] xor_test;

initial begin
	$randomize;
	repeat(50) begin
		//set inputs to be random
		A = $random;
		B = $random;
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b", A, B);
		
		//generate the XOR result
		xor_test = A ^ B;
		
		#1
		$display("Result: %b", Res);
		
		//check if the shifter worked
		if(Res != xor_test) $error("TEST FAILED");
		else $display("TEST PASSED");
	end
end

endmodule
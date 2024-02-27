module addsub_4bit_tb();

reg signed [3:0] stm_a,stm_b; // used as stimulus for a,b
reg signed stm_cin;
wire signed [3:0] add_mon, sub_mon; // used to monitor sum
wire stm_cout_add, stm_cout_sub;


adder_4bit_sub DUT1(.Sum(add_mon), .A(stm_a), .B(stm_b), .Cin(stm_cin), .Cout(stm_cout_add));

int signed sum = 0;
bit pos_overflow = 0;
bit neg_overflow = 0;

initial begin
	//test add block
	repeat(20) begin
		// set inputs to be random
		stm_a = $random;
		stm_b = $random;
		stm_cin = $random;
	
		pos_overflow = 0;
		neg_overflow = 0; 
       
		sum = stm_a + stm_b - stm_cin;
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b, Cin: %b", stm_a, stm_b, stm_cin);

		//if the result cannot be representable in 4 bits then set overflow check
		if (~stm_a[3] && ~stm_b[3] && sum[3]) 
			pos_overflow = 1;
		else if (stm_a[3] && stm_b[3] && ~sum[3]) // check if overflow considering decimal output not actual signed binary
			neg_overflow = 1;
		
		#1
		$display("Sum: %b", add_mon);

		//Adder worked if the 4 bit result matches and the overflow was checked correctly
		if (pos_overflow) begin 
			if (add_mon != 7)
				$error("Failed for pos_ovfl at time %t: A=%h, B=%h", $time, stm_a, stm_b);
		end 
		else if (neg_overflow) begin
			if (add_mon != -8) 
				$error("Failed for neg_ovfl at time %t: A=%h, B=%h", $time, stm_a, stm_b);
		end 
		else if (add_mon != sum[3:0])
			$error("Failed at time %t: A=%h, B=%h", $time, stm_a, stm_b);
			
		

	end
	$display("All tests passed!");
end


endmodule

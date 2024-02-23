module adder_4bit_tb();

reg signed [3:0] stm_a,stm_b; // used as stimulus for a,b
reg stm_cin; // used as stimulus for cin
wire signed [3:0] sum_mon; // used to monitor sum


addsub_4bit UUD(.Sum(sum_mon), .A(stm_a), .B(stm_b), .sub(stm_cin));
int sum = 0;
bit pos_overflow = 0;
bit neg_overflow = 0;
	initial begin
	$randomize; 
    repeat (15) begin
	
	  // Random stim
      stm_a = $random;
      stm_b = $random;
      stm_cin = $random;
	
	  pos_overflow = 0;
	  neg_overflow = 0;
      if (stm_cin) 
        sum = stm_a - stm_b; 
      else 
        sum = stm_a + stm_b;
      
      if (sum < -8) 
		neg_overflow = 1;
	  else if (sum > 7) // check if overflow considering decimal output not actual signed binary
        pos_overflow = 1;
		
	  #5;
      if (pos_overflow) begin 
		if (sum_mon != 7)
        $error("Failed at time %t: A=%h, B=%h", $time, stm_a, stm_b);
		end 
		else if (neg_overflow) begin
		if (sum_mon != -8) 
		$error("Failed at time %t: A=%h, B=%h", $time, stm_a, stm_b);
		end 
		else if (sum_mon != sum)
		$error("Failed at time %t: A=%h, B=%h", $time, stm_a, stm_b);
	  #5;
    end
    $display("All tests passed!");
  end

endmodule

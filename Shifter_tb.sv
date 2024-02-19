/*
 * Shifter_tb.sv
 * Shawn Zhu
 * ECE552
 */
module Shifter_tb();
reg signed [15:0] Shift_In; 	// This is the input data to perform shift operation on
reg [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
reg  Mode; 				// To indicate 0=SLL or 1=SRA 
wire [15:0] Shift_Out; 	// Shifted output data

Shifter DUT(.Shift_Out(Shift_Out), .Shift_In(Shift_In), .Shift_Val(Shift_Val), .Mode(Mode));

logic [15:0] shift_check = 0;
initial begin
	$randomize;
	repeat(50) begin
		//set inputs to be random
		Shift_In = $random;
		Shift_Val = $random;
		Mode = $random;
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("Input: %b, Shift Amount: %b, Mode: %b", Shift_In, Shift_Val, Mode);
		
		//generate the shift results
		if(Mode) shift_check = Shift_In >>> Shift_Val;
		else shift_check = Shift_In << Shift_Val;
		
		#1
		$display("Result: %b", Shift_Out);
		
		//check if the shifter worked
		if(shift_check != Shift_Out) $error("TEST FAILED");
		else $display("TEST PASSED");
	end
end

endmodule

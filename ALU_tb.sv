/*
 * ALU_tb.sv
 * Shawn Zhu
 * ECE552
 */
module ALU_tb();

reg signed [3:0] ALU_In1, ALU_In2;
reg [1:0] Opcode;
wire [3:0] ALU_Out;
wire Error; 	

////// Instantiate the device////////
ALU iDUT(.ALU_Out(ALU_Out), .Error(Error), .ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(Opcode));

int out_check = 0;
int error_check = 0;
initial begin
	//Initialize RNG
	$randomize;
	
	repeat(20) begin
		// set inputs to be random
		ALU_In1 = $random;
		ALU_In2 = $random;
		Opcode = $random;
		
		// display inputs
		$display("Test Case %0d:", $time);
		$display("A: %b, B: %b, Opcode: %b", ALU_In1, ALU_In2, Opcode);
		
		// operation is add/sub if op[1] = 0
		if(Opcode[1] == 0) begin
			//set the output to add or sub based on output
			if(Opcode[0] == 0) out_check = ALU_In1 + ALU_In2;
			else out_check = ALU_In1 - ALU_In2;

			//check for overflow
			if(out_check < -8 || out_check > 7) error_check = 1;
			else error_check = 0;
		end
		else begin
			//set the output to add or dub based on output
			if(Opcode[0] == 0) out_check = ALU_In1 ^ ALU_In2;
			else out_check = ~(ALU_In1 & ALU_In2);

			//error check is 0 for XOR and NAND
			error_check = 0;
		end
		#1
		$display("Result: %b, Error: %b", ALU_Out, Error);
		if(out_check[3:0] != ALU_Out || error_check != Error) $error("TEST %0d FAILED", $time);
		else $display("TEST PASSED");

		
	end
end

endmodule


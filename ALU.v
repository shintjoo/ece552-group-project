/*
 * ALU.v
 * Shawn Zhu
 * ECE552
 */
module ALU (ALU_Out, Error, ALU_In1, ALU_In2, Opcode);
input [3:0] ALU_In1, ALU_In2;
input [1:0] Opcode;
output reg [3:0] ALU_Out;
output reg Error; 	// Just to show overflow

wire[3:0] addsub_res;
wire ovfl_res;

//instantiate add/sub
addsub_4bit addsub(.Sum(addsub_res), .Ovfl(ovfl_res), .A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]));


always @ (ALU_In1, ALU_In2, Opcode) begin
	case (Opcode)
		2'b00: begin ALU_Out = addsub_res;
			Error = ovfl_res;
			end
		2'b01: begin ALU_Out = addsub_res;
			Error = ovfl_res;
			end
		2'b10: begin ALU_Out = ALU_In1 ^ ALU_In2;
			Error = 0;
			end
		2'b11: begin ALU_Out = ~(ALU_In1 & ALU_In2);
			Error = 0;
			end
		default: Error = 1;
	endcase
end


endmodule

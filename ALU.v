/*
 * ALU.v
 * Shawn Zhu, Diego Navarro
 * ECE552
 */
module ALU (ALU_Out, Error, ALU_In1, ALU_In2, ALUOp, Flags);
input [15:0] ALU_In1, ALU_In2;
input [3:0] ALUOp;
output reg [15:0] ALU_Out;
output reg [2:0] Flags;
output reg Error; 	// Just to show default

wire[15:0] addsub_res, Shift_Out, RedSum, PaddSum;
wire ovfl_res;

//instantiate add/sub
addsub_16bit UUD(.Sum(addsub_res), .A(ALU_In1), .B(ALU_In2), .sub(ALUOp[0]), .sat(sat));
Shifter shifter(.Shift_Out(Shift_Out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(ALUOp[1:0])); //ALU_In2 is the immediate as well.
RED red(.Sum(RedSum), .In1(ALU_In1), .In2(ALU_In2));
PADDSB padd(.Sum(PaddSum), .A(ALU_In1), .B(ALU_In2));

always @ (ALU_In1, ALU_In2, ALUOp) begin
	casex (ALUOp)
		4'bx00x: begin ALU_Out = addsub_res; //SUM SUB LW SW
			Flags[0] = ALU_Out[15];
			Flags[1] = ~(|ALU_Out);
			Flags[2] = ovfl_res;
			Error = 0;
			end
		4'b010x: begin ALU_Out = Shift_Out; //SLL and SRA and ROR
			Flags[1] = ~(|ALU_Out);
			Error = 0;
			end
		4'b0011: begin ALU_Out = RedSum; //RED reduction
			Flags[0] = 0;
			Flags[1] = 0;
			Flags[2] = 0;
			Error = 0;
			end
		4'b0010: begin ALU_Out = ALU_In1 ^ ALU_In2; //XOR
			Flags[1] = ~(|ALU_Out);
			Error = 0;
			end
		4'b0111: begin ALU_Out = PaddSum; //PADDSUM
			Error = 0;
			end
		4'b100x: begin ALU_Out = addsub_res; //SUM SUB LW SW
			Error = 0;
			end
		4'b101x: begin ALU_Out = (ALUOp[0]) ? ((ALU_In1 & 16'hFF00) | ALU_In2[7:0]) : ((ALU_In1 & 16'h00FF) | (ALU_In2[7:0]<<8)); //LLB LHB
			Error = 0;
			end
		4'b11xx: begin ALU_Out = ALU_In1; //Branch and PCS and HLT
			Error = 0;
			end
		default: Error =1;
		
	endcase
end


endmodule

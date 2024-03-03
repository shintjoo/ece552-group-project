/*
 * ALU.v
 * Shawn Zhu, Diego Navarro
 * ECE552
 */
module ALU (ALU_Out, Error, ALU_In1, ALU_In2, ALUOp, Flags, clk, rst);
input clk, rst;
input [15:0] ALU_In1, ALU_In2;
input [3:0] ALUOp;
output [15:0] ALU_Out;
output [2:0] Flags; //2, 1, 0 : V, Z, N
output reg Error; 	// Just to show default

wire[15:0] addsub_res, Shift_Out, RedSum, PaddSum;
wire ovfl_res;

reg N_en, Z_en, V_en, N, Z, V;
reg sub;
reg [15:0] ALU_res;

dff N_flag(.q(Flags[0]), .d(N), .wen(N_en), .clk(clk), .rst(rst));
dff Z_flag(.q(Flags[1]), .d(Z), .wen(Z_en), .clk(clk), .rst(rst));
dff V_flag(.q(Flags[2]), .d(V), .wen(V_en), .clk(clk), .rst(rst));

//instantiate add/sub
addsub_16bit UUD(.Sum(addsub_res), .A(ALU_In1), .B(ALU_In2), .sub(sub), .sat(ovfl_res));
Shifter shifter(.Shift_Out(Shift_Out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(ALUOp[1:0])); //ALU_In2 is the immediate as well.
RED red(.Sum(RedSum), .In1(ALU_In1), .In2(ALU_In2));
PADDSB padd(.Sum(PaddSum), .A(ALU_In1), .B(ALU_In2));

assign ALU_Out = ALU_res;

always @ (*) begin
	//default signals
	N = 1'b0;
	Z = 1'b0;
	V = 1'b0;
	N_en = 1'b1;
	Z_en = 1'b1;
	V_en = 1'b1;
	sub = 1'b0;
	Error = 0;
	casex (ALUOp)
		4'b0000: begin  //ADD
			ALU_res = addsub_res;
			N = addsub_res[15];
			Z = ~(|addsub_res);
			V = ovfl_res;
			N_en = 1'b1;
			Z_en = 1'b1;
			V_en = 1'b1;
			end
		4'b0001: begin  //SUB
			ALU_res = addsub_res;
			N = addsub_res[15];
			Z = ~(|addsub_res);
			V = ovfl_res;
			N_en = 1'b1;
			Z_en = 1'b1;
			V_en = 1'b1;
			sub = 1'b1;
			end
		4'b0011: begin  //RED reduction
			ALU_res = RedSum;
			end
		4'b0010: begin //XOR
		 	ALU_res = ALU_In1 ^ ALU_In2;
			Z = ~(|ALU_Out);
			end
		4'b010x: begin  //SLL and SRA
			ALU_res = Shift_Out;
			Z = ~(|ALU_Out);
			Z_en = 1'b1;
			end
		4'b0110: begin  //ROR
			ALU_res = Shift_Out;
			Z = ~(|ALU_Out);
			Z_en = 1'b1;
			end
		4'b0111: begin //PADDSUM
			ALU_res = PaddSum; 
			end
		4'b100x: begin //LW SW
			ALU_res = addsub_res; 
			Error = 0;
			end
		4'b101x: begin //LLB LHB 
			//ALUOp[0] = 1 for LHB, 0 for LLB
			ALU_res = (ALUOp[0]) ? ((ALU_In1 & 16'h00FF) | (ALU_In2[7:0]<<8)) : ((ALU_In1 & 16'hFF00) | ALU_In2[7:0]); 
			end
		4'b11xx: begin  //Branch and PCS and HLT
			ALU_res = ALU_In1;
			end
		default: Error =1;
		
	endcase
end


endmodule

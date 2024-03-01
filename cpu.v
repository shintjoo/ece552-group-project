/*
 * cpu.v
 * Shawn Zhu
 * ECE552
 */
module cpu (clk, rst_n, hlt, pc);
input clk, rst_n;
output hlt;
output [15:0] pc;

//control signals
wire RegWrite, MemRead, MemWrite, Branch, MemtoReg, RegDst, ALUSrc; //control signals
wire [3:0] ALUOp; //ALU Control signal
wire pcs_select, hlt_select, ALUSrc8bit;

//intermediate signals
wire [15:0] pc_in, instruction, mem_out;
wire [15:0] pc_increment, pc_branch, pc_choose;
wire [15:0] datain, dataout1, dataout2;
wire [2:0] Flags;
wire [15:0] aluin2, aluout;
wire error;


//Fetch Stage
//instruction memory
memory1c imem(.data_out(instruction), .data_in(16'b0), .addr(pc_in), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));

//PC Calculation
addsub_16bit increment(.Sum(pc_increment), .A(pc_in), .B(16'h0002), .sub(1'b0), .sat());
addsub_16bit branch(.Sum(pc_branch), .A(pc_increment), .B({6'h0, instruction[8:0], 1'b0}), .sub(1'b0), .sat());

//Decode Stage
//assign control signals
// operate on 2 registers ADD 0000, SUB 0001, XOR 0010, RED 0011
// operate on 2 registers part 2 PADDSB 0111
// operate on one register and 4 bit imm SLL 0100, SRA 0101
// operate on one register and 4 bit imm part 2 ROR 0110
// operate on one register and 8 bit imm LLB 1010, LHB 1011
// load LW 1000
// store SW 1001
// branch B 1100
// branch register BR 1101
// pcstore PCS 1110
// halt HLT 1111
always @ (instruction) begin
    RegWrite  = 1'b0;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    Branch = 1'b0;
    MemtoReg = 1'b0;
    RegDst = 1'b0;
    ALUSrc = 1'b0;
    pcs_select = 1'b0;
    hlt_select = 1'b0; 
    ALUSrc8bit = 1'b0;  
    error = 1'b0;
	casex (instruction [3:0])
    	4'b00xx: begin      // operate on 2 registers ADD 0000, SUB 0001, XOR 0010, RED 0011
            RegWrite  = 1'b1;
        end
        4'b010x: begin      // operate on one register and 4 bit imm SLL 0100, SRA 0101
            RegWrite  = 1'b1;
            ALUSrc 1'b1;
        end
         4'b0110: begin      // operate on one register and 4 bit imm part 2 ROR 0110
            RegWrite  = 1'b1;
            ALUSrc 1'b1;
        end
        4'b0111: begin      // operate on 2 registers part 2 PADDSB 0111
            RegWrite  = 1'b1;
        end
        4'b101x: begin      // operate on one register and 8 bit imm LLB 1010, LHB 1011
            RegWrite  = 1'b1;
            ALUSrc8bit = 1'b1;
        end
        4'b1000: begin      //lw
            RegWrite  = 1'b1;
            MemRead = 1'b1;
            ALUSrc 1'b1;
        end
        4'b1001: begin      //sw
            RegWrite  = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            MemtoReg 1'b0;
            RegDst 1'b0;
            ALUSrc 1'b0;
            pcs_select 1'b0;
            hlt_select 1'b0;  
            ALUSrc8bit = 1'b0;  
            error = 0; 
        end
        4'b1100: begin      // branch B 1100
            RegWrite  = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            MemtoReg 1'b0;
            RegDst 1'b0;
            ALUSrc 1'b0;
            pcs_select 1'b0;
            hlt_select 1'b0;  
            ALUSrc8bit = 1'b0;   
            error = 0;
        end
        4'b1101: begin      // branch register BR 1101
            RegWrite  = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            MemtoReg 1'b0;
            RegDst 1'b0;
            ALUSrc 1'b0;
            pcs_select 1'b0;
            hlt_select 1'b0;  
            ALUSrc8bit = 1'b0;   
            error = 0;
        end
        4'b1110: begin     // pcstore PCS 1110
            RegWrite  = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            MemtoReg 1'b0;
            RegDst 1'b0;
            ALUSrc 1'b0;
            pcs_select 1'b0;
            hlt_select 1'b0;  
            ALUSrc8bit = 1'b0;   
            error = 0;
        end
        4'b111: begin      // halt HLT 1111
            RegWrite  = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            Branch = 1'b0;
            MemtoReg 1'b0;
            RegDst 1'b0;
            ALUSrc 1'b0;
            pcs_select 1'b0;
            hlt_select 1'b0;  
            ALUSrc8bit = 1'b0; 
            error = 0;  
        end
        default: begin
            error = 1;
        end

    endcase
end

//possibilities for opcode
//Opcode rd, rs, rt
//Opcode rd, rs, imm
//Opcode rt, rs, offset
//Opcode ccci iiii iiii
//Opcode cccx ssss xxxx
//Opcode dddd xxxx xxxx
//Opcode xxxx xxxx xxxx
RegisterFile regfile (.clk(clk), .rst(rst), .SrcReg1(instruction[7:0]), .SrcReg2(instruction[3:0]), .DstReg(instruction[11:8]), .WriteReg(RegWrite), .DstData(datain), .SrcData1(dataout1), .SrcData2(dataout2));

//execute stage
assign aluin2 = (ALUSrc8bit == 1) ? {{8{instruction[7]}},instruction[7:0]}: ((ALUSrc)? {{12{instruction[3]}},instruction[3:0]} : dataout2);
ALU ex(.ALU_Out(aluout), .Error(error), .ALU_In1(dataout1), .ALU_In2(aluin2), .ALUOp(instruction[15:12]));


//memory stage
memory1c dmem(.data_out(mem_out), .data_in(dataout2), .addr(aluout), .enable(MemRead), .wr(MemWrite), .clk(clk), .rst(rst));

assign pc_choose = (Branch && ) pc_branch : pc_increment;

//writeback stage
assign datain = hlt(MemtoReg) ? mem_out : aluout;

assign pc =

endmodule
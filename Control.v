module Control(
    input [3:0] instruction,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg pcs_select,
    output reg hlt_select,
    output reg ALUSrc8bit
);

reg error;

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
    // Default values
    RegWrite  = 1'b0;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    Branch = 1'b0;
    MemtoReg = 1'b0;
    ALUSrc = 1'b0;
    pcs_select = 1'b0;
    hlt_select = 1'b0;
    ALUSrc8bit = 1'b0;
    error = 1'b0;

    // Decode the instruction
    casex (instruction)
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
            MemWrite = 1'b1;
            ALUSrc 1'b1;
        end
        4'b1100: begin      // branch B 1100
            Branch = 1'b1;
        end
        4'b1101: begin      // branch register BR 1101
            Branch = 1'b0;
        end
        4'b1110: begin     // pcstore PCS 1110
            pcs_select 1'b1;
        end
        4'b1111: begin      // halt HLT 1111
            hlt_select 1'b1;  
        end
        default: begin
            error = 1;
        end
    endcase
end

endmodule
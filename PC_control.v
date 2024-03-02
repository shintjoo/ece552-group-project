module PC_control(C, I, F, branch, PC_in, PC_out);
input [2:0] C; //conditions from instruction
input [8:0] I; //9 bit signed offset
input [2:0] F; //flags from ALU
input branch; //control signal for branch
input [15:0] PC_in; //un-incremented PC
output reg [15:0] PC_out; //PC out

wire [15:0] pc_branch;
reg [15:0] pc_choose, branch_imm;
reg error;

addsub_16bit branch_add(.Sum(pc_branch), .A(PC_in), .B(branch_imm), .sub(1'b0), .sat());

assign PC_out = pc_choose;

always @ (C, I, F, PC_in) begin
    //default out
    branch_imm = 16'h0000;
    pc_choose = 16'h0000;
    error = 0;
    case(C) 
        3'b000: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = (~F[1] && branch) ?  pc_branch : PC_in ;
            //pc_choose = (branch) ?  PC_in : PC_in ;
        end
        3'b001: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = (~F[0] && F[1] && ~F[2] && branch) ?  pc_branch : PC_in;
        end
        3'b010: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = (~F[0] && ~F[1] && branch) ?  pc_branch : PC_in;
        end
        3'b011: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = (F[0] && ~F[1] && branch) ?  pc_branch : PC_in;
        end
        3'b100: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = ((F[1] || (~F[0] && ~F[1])) && branch) ?  pc_branch : PC_in;
        end
        3'b101: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = ((F[0] || F[1]) && branch) ?  pc_branch : PC_in;
        end
        3'b110: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose = (F[2] && branch) ?  pc_branch : PC_in;
        end
        3'b111: begin
            branch_imm = 16'h0000 | (I << 1);
            pc_choose =  pc_branch;
        end
        default: begin
            error = 1; 
        end
    endcase
end

endmodule
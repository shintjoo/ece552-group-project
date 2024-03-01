module PC_control(C, I, F, PC_in, PC_out);
input [2:0] C; //conditions from instruction
input [8:0] I; //9 bit signed offset
input [2:0] F; //flags from ALU
input [15:0] PC_in; //un-incremented PC
output reg [15:0] PC_out; //PC out

wire [15:0] pc_branch;
reg error;

addsub_16bit branch(.Sum(pc_branch), .A(PC_in), .B({6'h0, I[8:0], 1'b0}), .sub(1'b0), .sat());

always @ (C) begin
    case(C) 
        3'b000: begin
            PC_out = (~F[1]) ?  pc_branch : PC_in;
        end
        3'b001: begin
            PC_out = (~F[0] & F[1] & ~F[2]) ?  pc_branch : PC_in;
        end
        3'b010: begin
            PC_out = (~F[0] & ~F[1]) ?  pc_branch : PC_in;
        end
        3'b011: begin
            PC_out = (F[0] & ~F[1]) ?  pc_branch : PC_in;
        end
        3'b100: begin
            PC_out = (F[1] || (~F[0] & ~F[1] )) ?  pc_branch : PC_in;
        end
        3'b101: begin
            PC_out = (F[0] || F[1]) ?  pc_branch : PC_in;
        end
        3'b110: begin
            PC_out = (F[2]) ?  pc_branch : PC_in;
        end
        3'b111: begin
            PC_out =  pc_branch;
        end
        default: begin
            error = 1; 
        end
    endcase
end

endmodule
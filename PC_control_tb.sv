module PC_control_tb();
reg [2:0] C; //conditions from instruction
reg [8:0] I; //9 bit signed offset
reg [2:0] F; //flags from ALU
reg [15:0] PC_in; //un-incremented PC
wire [15:0] PC_out; //PC out



PC_control DUT(.C(C), .I(I), .F(F), .PC_in(PC_in), .PC_out(PC_out));

logic [15:0] pc_check = 0;
logic [15:0] imm = 0;
initial begin
	$randomize;
	repeat(100) begin
        C = $random;
        I = $random;
        F = $random;
        PC_in = $random;
        imm = I << 1;
        if(C == F) pc_check = PC_in + imm;
        else pc_check = PC_in;
        #5;
        if(pc_check != PC_out) $error("TEST FAILED: PC_out = %h; pc_check = %h", PC_out, pc_check);
        else $display("TEST PASSED");



    end
end


endmodule
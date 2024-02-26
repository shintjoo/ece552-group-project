module LW_SW_Testbench;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in simulation ticks

    // Signals
    reg [15:0] rs;
    reg [15:0] rt;
    reg [15:0] imme;
    reg clk;
    reg rst;
    reg read_enable;
    reg write_enable;
    wire [15:0] data_out;

    // Instantiate LW_SW module
    LW_SW UUD (
        .rs(rs),
        .rt(rt),
        .imme(imme),
        .clk(clk),
        .rst(rst),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .data_out(data_out)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Reset generation
    initial begin
        rst = 1'b1;
        #10;
        rst = 1'b0;
    end

    // Test stimulus
    initial begin
        // Initialize inputs to write 
        rs = 16'hA;
        rt = 16'hB;
        imme = 16'h3;
        read_enable = 1'b1; 
        write_enable = 1'b1; //write 

        // Read that value back 
        #20;
        write_enable = 1'b0;
        read_enable = 1'b1;
        #20;
        read_enable = 1'b1;
        rs = 16'hA;
        rt = 16'hB;
        imme = 16'h3;
        #20;
        assert (data_out === 16'h0000) else $error("Assertion failed: data_out mismatch at PC = 16'hABCD");
        
        #20;

        // Finish simulation
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        $display("At time %0t: rs = %h, rt = %h, PC = %h, imme = %h, data_out = %h", $time, rs, rt, PC, imme, data_out);
    end

endmodule

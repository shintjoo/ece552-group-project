module XOR_tb;
    reg [16:0] A, B; //Inputs to DUT are regsbe XOR'ed
    wire [16:0] Res;


    XOR uut (
        .A(A), 
        .B(B), 
        .Res(Res)
    );

    // Test stimulus
    initial begin
        // Initialize Inputs
        A = 0; B = 0;
        #10; // Wait for 10ns
        
        A = 0; B = 1;
        #10; // Wait for 10ns

        A = 1; B = 0;
        #10; // Wait for 10ns

        A = 1; B = 1;
        #10; // Wait for 10ns

        // Add more tests if needed
        
        $finish; // End simulation
    end

    // Optional: Monitor changes
    initial begin
        $monitor("Time = %t, a = %b, b = %b, result = %b", $time, A, B, Res);
    end
endmodule
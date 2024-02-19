/*
 * FA.v
 * Shawn Zhu
 * ECE552
 */
module full_adder_1bit( A, B, Cin, S, Cout);
  input A,B,Cin;		// three input bits to be added
  output S,Cout;		// Sum and carry out

  assign S = A ^ B ^ Cin;
  assign Cout = (A & B) | (A & Cin) | (B & Cin);
  
endmodule

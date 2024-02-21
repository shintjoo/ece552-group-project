/*
 * Shifter.v
 * Shawn Zhu
 * ECE552
 */
module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; 	// This is the input data to perform shift operation on
input [3:0] Shift_Val; 	// Shift amount (used to shift the input data)
input  [1:0] Mode; 		// To indicate 00=SLL, 01=SRA, and 10 for ROR
output [15:0] Shift_Out; 	// Shifted output data

wire[15:0] shift8, shift4, shift2; //Intermediate signals for the barrel shifter

//Implement the barrel shifter
// more legible logic:
// if (shift)
//	if (ROR) do ROR
//	else
//		if (SRA) do SRA
//		else do SLL
// else don't shift
assign shift8 = (Shift_Val[3]) ? ((Mode[1]) ? {Shift_In[7:0], Shift_In[15:8]} : ((Mode[0])? {{8{Shift_In[15]}}, Shift_In[15:8]} : {Shift_In[7:0], 8'b0})) : Shift_In;
assign shift4 = (Shift_Val[2]) ? ((Mode[1]) ? {shift8[3:0], shift8[15:4]} : ((Mode[0]) ? {{4{shift8[15]}}, shift8[15:4]} : {shift8[11:0], 4'b0})) : shift8;
assign shift2 = (Shift_Val[1]) ? ((Mode[1]) ? {shift4[1:0], shift4[15:2]} : ((Mode[0]) ? {{2{shift4[15]}}, shift4[15:2]} : {shift4[13:0], 2'b0})) : shift4;
assign Shift_Out = (Shift_Val[0]) ? ((Mode[1]) ? {shift2[0], shift2[15:1]} : ((Mode[0]) ? {{1{shift2[15]}}, shift2[15:1]} : {shift2[14:0], 1'b0})) : shift2;  //The final shift should be set to the output


endmodule


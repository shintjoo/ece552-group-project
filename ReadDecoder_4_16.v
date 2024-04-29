/*
 * ReadDecoder_4_16.v
 * Shawn Zhu
 * ECE552
 */
module ReadDecoder_4_16(RegId, Wordline);
input [3:0] RegId;
output [15:0] Wordline;

wire[15:0] shift1, shift2, shift4; //Intermediate signals for the barrel shifter

//Implement the barrel shifter
assign shift1 = (RegId[0]) ? 16'h0002 : 16'h0001;  //one of the signals always has to be 1
assign shift2 = (RegId[1]) ? shift1 << 2 : shift1;
assign shift4 = (RegId[2]) ? shift2 << 4 : shift2;
assign Wordline = (RegId[3]) ? shift4 << 8 : shift4;

endmodule

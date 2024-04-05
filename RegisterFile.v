/*
 * RegisterFile.v
 * Shawn Zhu
 * ECE552
 */
module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
input clk, rst; 
input [3:0] SrcReg1, SrcReg2; 
input [3:0] DstReg;
input WriteReg;
input [15:0] DstData;
inout [15:0] SrcData1,SrcData2;

wire[15:0] read_en1, read_en2;
wire[15:0] write_en;
wire[15:0] data1, data2;

ReadDecoder_4_16 regdec1(.RegId(SrcReg1), .Wordline(read_en1));
ReadDecoder_4_16 regdec2(.RegId(SrcReg2), .Wordline(read_en2));
WriteDecoder_4_16 writedec(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_en));


Register regs[15:0](.clk(clk), .rst(rst), .D(DstData),  .WriteReg(write_en), .ReadEnable1(read_en1), .ReadEnable2(read_en2), .Bitline1(data1), .Bitline2(data2));

//for bypassing
assign SrcData1 = (SrcReg1 == 4'b0000) ? 16'h0000 : (((DstReg == SrcReg1) && WriteReg) ? DstData : data1);
assign SrcData2 = (SrcReg2 == 4'b0000) ? 16'h0000 :(((DstReg == SrcReg2) && WriteReg) ? DstData : data2);

//no bypassing
//assign SrcData1 = data1;
//assign SrcData2 = data2;
endmodule

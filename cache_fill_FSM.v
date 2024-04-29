module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);
input clk, rst_n;
input miss_detected;            // active high when tag match logic detects a miss
input [15:0] miss_address;      // address that missed the cache
output fsm_busy;                // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output write_data_array;        // write enable to cache data array to signal when filling with memory_data
output write_tag_array;         // write enable to cache tag array to signal when all words are filled in to data array
output [15:0] memory_address;   // address to read from memory
input [15:0] memory_data;       // data returned by memory (after  delay)
input memory_data_valid;        // active high indicates valid data returning on memory bus

wire state, next_state;
wire [3:0] count, next_count, inc_count, addr, next_addr, inc_addr;

// State
// Idle: state = 0
// Wait: state = 1
dff state_flop(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(~rst_n));    

// Set next state
// state should go to wait state when a miss is detected
// state should stay in wait until whole block is returned 
assign next_state = ((~state & miss_detected) | (state & (count != 4'h8))) ? 1'b1 : 1'b0; 

// load all 8 chunks
adder_4bit chunk_adder(.Sum(inc_count), .A(count), .B(4'h1), .Cin(1'b0), .Cout());
assign next_count = (state) ? inc_count : 4'h0;     // we should only be counting if the we are in the WAIT state
dff count_ff[3:0](.q(count), .d(next_count), .wen(memory_data_valid), .clk(clk), .rst(~rst_n | (next_count == 4'h9)));

// load from memory
adder_4bit inc_mem_adder(.Sum(inc_addr), .A(addr), .B(4'h2), .Cin(1'b0), .Cout());
assign next_addr = (state) ? inc_addr : 4'h0;
dff addr_ff[3:0](.q(addr), .d(next_addr), .wen(state), .clk(clk), .rst(~rst_n | (~state & next_state)));
adder_16bit out_mem_adder(.Sum(memory_address), .A(addr), .B({miss_address[15:4],4'h0}), .Cin(1'b0), .Cout());

// outputs
assign fsm_busy = ((~state & miss_detected) | (state)) ? 1'b1 : 1'b0;
assign write_data_array = (memory_data_valid & next_state) ? 1'b1 : 1'b0;
assign write_tag_array = ((count == 4'h8) & state) ? 1'b1 : 1'b0;

endmodule

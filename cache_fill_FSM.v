module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);
input clk, rst_n;
input miss_detected; 		    // active high when tag match logic detects a miss
input [15:0] miss_address; 	    // address that missed the cache
output fsm_busy; 		        // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output write_data_array; 	    // write enable to cache data array to signal when filling with memory_data
output write_tag_array; 	    // write enable to cache tag array to signal when all words are filled in to data array
output [15:0] memory_address; 	// address to read from memory
input [15:0] memory_data; 	    // data returned by memory (after  delay)
input memory_data_valid; 	    // active high indicates valid data returning on memory bus

dff state_flop(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(~rst_n));

reg state, next_state;

always @ (*) begin

    case(miss_detected) 
        1'b0: begin //Idle State 
            
        end
        1'b1: begin //Wait State

        end
        default: begin
                
        end

    endcase
end


endmodule;
`timescale 1ns/100ps
module instruction_cache (
    clock,
    reset,
    address,
    readins,
	busywait,
    mem_read,
    mem_address,
    mem_readins,
	mem_busywait
);
    // Ports declaration
    input				clock;
    input				reset;
    input[9:0]      	address;
    output reg [31:0]	readins;
    output reg      	busywait;
    output reg       	mem_read;
    output reg [5:0]    mem_address;
    input[127:0]	    mem_readins;
    input            	mem_busywait;

    // Internal registers for cache
    reg valid_bit_array [7:0];
    reg [2:0] addresstag_array [7:0];
    reg [127:0] instruction_block_array [7:0];
    reg hit, hitflag, writefrommem;

    integer j,k;
    initial
        begin
            for (j = 0; j < 8; j = j + 1) begin
            valid_bit_array[j] = 0;
            end
    end

    //Combinational part for indexing, tag comparison for hit deciding, etc.
    always @(*)
        begin
            k <= address[6:4]; // Calculate index (block number)
            hit <= #1.9 (address[9:7] == addresstag_array[k] && valid_bit_array[k] == 1)? 1 : 0; // Determine hit or miss by comparing tags and checking valid bit
            hitflag <= #1.9 1;
            // If it's a read access, read the data from cache block
            case(address[3:2])
                2'b00: readins <= #1.9 instruction_block_array[k][31:0];
                2'b01: readins <= #1.9 instruction_block_array[k][63:32];
                2'b10: readins <= #1.9 instruction_block_array[k][95:64];
                2'b11: readins <= #1.9 instruction_block_array[k][127:96];
                default: readins <= #1.9 32'dx;
                endcase          
        end
    // Handle the busywait signal based on hit/miss
    always @(hitflag) begin
        busywait = ~hit;
        hitflag = 0;
    end

    /* Cache Controller FSM Start */
    parameter IDLE = 2'b00, MEM_READ = 2'b01;
    reg [1:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if (!hit)
                    next_state = MEM_READ; // If miss, go to MEM_READ
                else
                    next_state = IDLE; // Otherwise, stay in IDLE

            MEM_READ:
                if (!mem_busywait)
                    next_state = IDLE; // If memory read complete, go to IDLE
                else    
                    next_state = MEM_READ; // Otherwise, stay in MEM_READ
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_address = 6'dx;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = {address[9:4]}; // Set memory address for read
                busywait = 1;
                writefrommem = ~mem_busywait; // Flag to write data from memory to cache
            end
        endcase
        
    end
    // Sequential logic for cache write operations and memory to cache write-back
    always @(posedge clock)
    begin
        if(writefrommem)
        begin
            instruction_block_array[k] <= #1 mem_readins; //write block into cache
            valid_bit_array[k] <= #1 1; //set valid bit to 0
            addresstag_array[k] <= #1 address[9:7]; //set new tag for given index
            writefrommem <= #1 0;
        end
    end
    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;  // Reset state to IDLE
        else
            state = next_state;  // Transition to next state
    end
    /* Cache Controller FSM End */
endmodule
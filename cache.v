`timescale 1ns/100ps
module dcache (
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
	busywait,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
	mem_busywait
);
    // Ports declaration
    input				clock;
    input				reset;
    input           	read;
    input           	write;
    input[7:0]      	address;
    input[7:0]     	    writedata;
    output reg [7:0]	readdata;
    output reg      	busywait;
    output reg       	mem_read;
    output reg         	mem_write;
    output reg [5:0]    mem_address;
    output reg [31:0]   mem_writedata;
    input[31:0]	        mem_readdata;
    input            	mem_busywait;

    // Internal registers for cache
    reg valid_bit_array [7:0];
    reg dirty_bit_array [7:0];
    reg [2:0] tag_array [7:0];
    reg [31:0] data_block_array [7:0];
    reg dirty, hit, hitflag, readaccess, writeaccess, writefrommem;

    integer j,k;

    initial
    begin
        for (j = 0; j < 8; j = j + 1) begin
            valid_bit_array[j] = 0;
            dirty_bit_array[j] = 0;
        end
    end

    //Combinational part for indexing, tag comparison for hit deciding, etc.
    always @(*)
        begin
            busywait <= (read || write)? 1 : 0;  // Set busywait if either read or write is active
            readaccess <= (read && !write)? 1 : 0;  // Determine if the operation is read or write
            writeaccess <= (!read && write)? 1 : 0;  // Determine if the operation is read or write
            k <= address[4:2]; // Calculate index (block number)
            hit <= #1.9 (address[7:5] == tag_array[k] && valid_bit_array[k] == 1)? 1 : 0; // Determine hit or miss by comparing tags and checking valid bit
            hitflag <= #1.9 1;
            dirty <= #1.9 dirty_bit_array[k]; // Read dirty bit of the cache block
            // If it's a read access, read the data from cache block
            if(readaccess)
                begin
                    case(address[1:0])
                        2'b00: readdata <= #1.9 data_block_array[k][7:0];
                        2'b01: readdata <= #1.9 data_block_array[k][15:8];
                        2'b10: readdata <= #1.9 data_block_array[k][23:16];
                        2'b11: readdata <= #1.9 data_block_array[k][31:24];
                        default: readdata <= #1.9 8'bxxxx_xxxx;
                    endcase
                end               
        end
    // Handle the busywait signal based on hit/miss
    always @(hitflag)
        begin
        if(read || write) begin
            busywait = ~hit;
        end
        hitflag = 0;
    end

    /* Cache Controller FSM Start */
    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)
                    next_state = MEM_READ; // If miss and not dirty, go to MEM_READ
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE; // If miss and dirty, go to MEM_WRITE
                else
                    next_state = IDLE; // Otherwise, stay in IDLE
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = IDLE; // If memory read complete, go to IDLE
                else    
                    next_state = MEM_READ; // Otherwise, stay in MEM_READ
            
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;  // If memory write complete, go to MEM_READ
                else    
                    next_state = MEM_WRITE; // Otherwise, stay in MEM_WRITE
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {address[7:2]}; // Set memory address for read
                mem_writedata = 32'dx;
                busywait = 1;
                writefrommem = ~mem_busywait; // Flag to write data from memory to cache
            end

            MEM_WRITE: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag_array[k],address[4:2]}; // Set memory address for write
                mem_writedata = data_block_array[k]; // Write cache block to memory
                busywait = 1;
                dirty_bit_array[k] = 0;  // Clear dirty bit after write
            end
            
        endcase
    end

    // Sequential logic for cache write operations and memory to cache write-back
    always @(posedge clock)
    begin
        if(hit && writeaccess)
        begin
            case(address[1:0])
                2'b00: data_block_array[k][7:0] <= #1 writedata[7:0];
                2'b01: data_block_array[k][15:8] <= #1 writedata[7:0];
                2'b10: data_block_array[k][23:16] <= #1 writedata[7:0];
                2'b11: data_block_array[k][31:24] <= #1 writedata[7:0];
            endcase
                valid_bit_array[k] <= #1 1;
                dirty_bit_array[k] <= #1 1;
        end
        if(writefrommem)
        begin
            data_block_array[k][31:0] <= #1 mem_readdata;
            valid_bit_array[k] <= #1 1;
            dirty_bit_array[k] <= #1 0;
            tag_array[k] <= #1 address[7:5];
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
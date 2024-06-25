`include "cpu.v"
`include "mem_module.v"
`include "cache.v"
`timescale 1ns/100ps
`include "instruction_cache.v"
`include "instruction_memory.v"
module Testbench;
    reg CLK, RESET;
    wire [31:0] PC, MEM_WRITEDATA, MEM_READDATA;
    wire [31:0] INSTRUCTION;
    wire READ, WRITE, BUSYWAIT, MEM_READ, MEM_WRITE, MEM_BUSYWAIT, INS_READ, INS_BUSYWAIT, INCACHE_BUSYWAIT, DATACACHE_BUSYWAIT, BUSYWAIT1;
    wire [7:0] WRITEDATA, ADDRESS, READDATA;
    wire [5:0] MEM_ADDRESS, INS_ADDRESS;
    wire [127:0] MEM_READINS;

    integer i;

    cpu CPU(PC, INSTRUCTION, CLK, RESET, READ, WRITE, WRITEDATA, ADDRESS, READDATA, BUSYWAIT);
    data_memory DATAMEM(CLK, RESET, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT); //data memory
    dcache CACHE(CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, DATACACHE_BUSYWAIT, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT); //data cache
    instruction_cache INCACHE(CLK, RESET, PC[9:0], INSTRUCTION, INCACHE_BUSYWAIT, INS_READ, INS_ADDRESS, MEM_READINS, INS_BUSYWAIT); //instruction cache
    instruction_memory INMEM(CLK, INS_READ, INS_ADDRESS, MEM_READINS, INS_BUSYWAIT); //instruction memory
    or or_gate(BUSYWAIT, DATACACHE_BUSYWAIT, INCACHE_BUSYWAIT); //or gate to handle data cache and instruction cache busywait

    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0,CPU);
        $dumpvars(0,DATAMEM);
        $dumpvars(0,CACHE);
        $dumpvars(0,INCACHE);
        $dumpvars(0,INMEM);
    
        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(1, CPU.REG_FILE.regArray[i]);
            $dumpvars(1, DATAMEM.memory_array[i]);
            $dumpvars(1, CACHE.data_block_array[i]);
            $dumpvars(1, INMEM.memory_array[i]);
            $dumpvars(1, INCACHE.instruction_block_array[i]);
        end

        CLK = 1'b0;
        RESET = 1;
        #10
        RESET = 0;
        // finish simulation after some time
        #2800;
        $finish;
    end
    // clock signal generation
    always
        #8 CLK = ~CLK;
    
endmodule
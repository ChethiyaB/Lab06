`include "cpu.v"
`include "mem_module.v"
`include "cache.v"
`timescale 1ns/100ps
module Testbench;
    reg CLK, RESET;
    wire [31:0] PC, MEM_WRITEDATA, MEM_READDATA;
    reg [31:0] INSTRUCTION;
    wire READ, WRITE, BUSYWAIT, MEM_READ, MEM_WRITE, MEM_BUSYWAIT;
    wire [7:0] WRITEDATA, ADDRESS, READDATA;
    wire [5:0] MEM_ADDRESS;

    integer i;

    cpu CPU(PC, INSTRUCTION, CLK, RESET, READ, WRITE, WRITEDATA, ADDRESS, READDATA, BUSYWAIT);
    data_memory DATAMEM(CLK, RESET, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);
    dcache CACHE(CLK, RESET, READ, WRITE, ADDRESS, WRITEDATA, READDATA, BUSYWAIT, MEM_READ, MEM_WRITE, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);

    always @ (PC)
    begin
        # 2 // Latency for instruction register
        // Manually written opcodes
        case (PC)
            32'b0000_0000_0000_0000_0000_0000_0000_0000: INSTRUCTION = 32'b00000000_00000000_00000000_00001001; // loadi 0 0x09
            
            32'b0000_0000_0000_0000_0000_0000_0000_0100: INSTRUCTION = 32'b00000000_00000001_00000000_00000001; // loadi 1 0x01

            32'b0000_0000_0000_0000_0000_0000_0000_1000: INSTRUCTION = 32'b00010000_00000000_00000000_00000001; // swd 0 1

            32'b0000_0000_0000_0000_0000_0000_0000_1100: INSTRUCTION = 32'b00010001_00000000_00000001_00000000; // swi 1 0x00

            32'b0000_0000_0000_0000_0000_0000_0001_0000: INSTRUCTION = 32'b00001110_00000010_00000000_00000001; // lwd 2 1
            
            32'b0000_0000_0000_0000_0000_0000_0001_0100: INSTRUCTION = 32'b00001110_00000011_00000000_00000001; // lwd 3 1
            
            32'b0000_0000_0000_0000_0000_0000_0001_1000: INSTRUCTION = 32'b00000011_00000100_00000000_00000001; // sub 4 0 1

            32'b0000_0000_0000_0000_0000_0000_0001_1100: INSTRUCTION = 32'b00010001_00000000_00000100_00000010; // swi 4 0x02

            32'b0000_0000_0000_0000_0000_0000_0010_0000: INSTRUCTION = 32'b00001111_00000101_00000000_00000010; // lwi 5 0x02

            32'b0000_0000_0000_0000_0000_0000_0010_0100: INSTRUCTION = 32'b00010001_00000000_00000100_00010100; // swi 4 0x20

            32'b0000_0000_0000_0000_0000_0000_0010_1000: INSTRUCTION = 32'b00001111_00000110_00000000_00010100; // lwi 6 0x20

            //32'b0000_0000_0000_0000_0000_0000_0010_1100: INSTRUCTION = 32'b00010001_00000000_00000100_00110100; // swi 4 0x52

        endcase
    end

    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0,CPU);

        for (i = 0; i < 8; i = i + 1) begin
            $dumpvars(1, CPU.REG_FILE.regArray[i]);
        end

        CLK = 1'b0;
        RESET = 1;
        #10
        RESET = 0;
        // finish simulation after some time
        #600
        $finish;
    end
    // clock signal generation
    always
        #8 CLK = ~CLK;
    
endmodule
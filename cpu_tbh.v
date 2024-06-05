`include "cpu.v"

module Testbench;
    reg CLK, RESET;
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;

    integer i;

    cpu CPU(PC, INSTRUCTION, CLK, RESET);

    always @ (PC)
    begin
        # 2 // Latency for instruction register
        // Manually written opcodes
        case (PC)
            32'b0000_0000_0000_0000_0000_0000_0000_0000: INSTRUCTION = 32'b00000000_00000110_00000000_00001011; // loadi 6 0x0B
            
            32'b0000_0000_0000_0000_0000_0000_0000_0100: INSTRUCTION = 32'b00000000_00000011_00000000_00000110; // loadi 3 0x06

            32'b0000_0000_0000_0000_0000_0000_0000_1000: INSTRUCTION = 32'b00000000_00000001_00000000_00000100; // loadi 1 0x04

            32'b0000_0000_0000_0000_0000_0000_0000_1100: INSTRUCTION = 32'b00010000_00000000_00000110_00000011; // swd 6 3

            32'b0000_0000_0000_0000_0000_0000_0001_0000: INSTRUCTION = 32'b00001111_00000000_00000000_00000110; // lwi 0 0x06
            
            32'b0000_0000_0000_0000_0000_0000_0001_0100: INSTRUCTION = 32'b00010001_00000000_00000001_00000010; // swi 1 0x02
            
            32'b0000_0000_0000_0000_0000_0000_0001_1000: INSTRUCTION = 32'b00001110_00000101_00000000_00000001; // lwd 5 1
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
        #500
        $finish;
    end
    // clock signal generation
    always
        #8 CLK = ~CLK;
    
endmodule
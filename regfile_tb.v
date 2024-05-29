module regfile_tb;

    // Inputs
    reg [7:0] IN;
    reg [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    reg WRITE, CLK, RESET;

    // Outputs
    wire [7:0] OUT1, OUT2;

    // Instantiate the regfile module
    regfile uut (IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);

    // Clock generation
    always begin
        #5 CLK = ~CLK; // Toggle clock every 5 time units
    end

    initial begin
        $dumpfile("reg_file_wavedata.vcd");
		$dumpvars(0, regfile_tb);
        // Initialize Inputs
        IN = 8'b00000000;
        INADDRESS = 3'b000;
        OUT1ADDRESS = 3'b000;
        OUT2ADDRESS = 3'b000;
        WRITE = 0;
        CLK = 0;
        RESET = 0;

        // Wait for global reset to finish
        #10;

        // Reset the register file
        RESET = 1;
        #10;
        RESET = 0;
        #10;

        // Write data to register 3
        IN = 8'b10101010;
        INADDRESS = 3'b011;
        WRITE = 1;
        #10;
        WRITE = 0;
        #10;

        // Read data from register 3 to OUT1
        OUT1ADDRESS = 3'b011;
        #10;
        $display("OUT1 (from reg 3): %b", OUT1);

        // Write data to register 5
        IN = 8'b01010101;
        INADDRESS = 3'b101;
        WRITE = 1;
        #10;
        WRITE = 0;
        #10;

        // Read data from register 5 to OUT2
        OUT2ADDRESS = 3'b101;
        #10;
        $display("OUT2 (from reg 5): %b", OUT2);

        // Reset the register file again
        RESET = 1;
        #10;
        RESET = 0;
        #10;

        // Read data from register 3 and 5 after reset
        #10;
        $display("OUT1 (after reset): %b", OUT1);
        $display("OUT2 (after reset): %b", OUT2);

        // Finish the test
        $finish;
    end

endmodule
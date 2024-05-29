module alu_tb;

    // Inputs
    reg [7:0] DATA1;
    reg [7:0] DATA2;
    reg [2:0] SELECT;
    wire ZERO;

    // Output
    wire [7:0] RESULT;

    // Instantiate the ALU module
    alu uut(DATA1,DATA2,RESULT,SELECT,ZERO);

    initial begin
        $dumpfile("alu_wavedata.vcd");
		$dumpvars(0,uut);
    end

    initial begin
        // Initialize Inputs

        DATA1 = 8'b00000000;
        DATA2 = 8'b00000000;
        SELECT = 3'b000;

        // Wait for global reset to finish
        #5;

        // Test FORWARD operation
        DATA1 = 8'b10101010;
        DATA2 = 8'b00000001;
        SELECT = 3'b100;
        #5;
        $display("FORWARD: %b", RESULT);

        // Test ADD operation
        SELECT = 3'b001;
        #5;
        $display("ADD: %b", RESULT);

        // Test AND operation
        SELECT = 3'b010;
        #5;
        $display("AND: %b", RESULT);

        // Test OR operation
        SELECT = 3'b011;
        #5;
        $display("OR: %b", RESULT);

        // Test default case
        SELECT = 3'b100;
        #5;
        $display("DEFAULT: %b", RESULT);

        // Finish the test
        $finish;
    end

endmodule
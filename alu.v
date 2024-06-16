//Alu 
`timescale 1ns/100ps
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);
    input [7:0] DATA1,DATA2;
    input [2:0] SELECT;
    output [7:0] RESULT;
    output ZERO;
    wire [7:0] ADDRESULT, ANDRESULT, ORRESULT, FORWARDRESULT, MULTRESULT, SHIFTRESULT, ASHIFTRESULT, ROTATERESULT;
    addmodule addmodule(DATA1, DATA2, ADDRESULT);
    andmodule andmodule(DATA1, DATA2, ANDRESULT);
    ormodule ormodule(DATA1, DATA2, ORRESULT);
    forwardmodule forwardmodule(DATA1, DATA2, FORWARDRESULT);
    multmodule multmodule(DATA1,DATA2,MULTRESULT);
    shifter shiftmodule(DATA1,DATA2,SHIFTRESULT);
    arithmetic_shifter arithmetic_shifter_module(DATA1, DATA2, ASHIFTRESULT);
    rotatemodule rotate_module(DATA1, DATA2, ROTATERESULT);
    alu_mux alumux(ADDRESULT, ANDRESULT, ORRESULT, FORWARDRESULT, MULTRESULT, SHIFTRESULT, ASHIFTRESULT, ROTATERESULT, SELECT, RESULT, ZERO);
endmodule

module addmodule(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;
    output [7:0] RESULT;
    assign #2 RESULT = (DATA1 + DATA2);
endmodule

module andmodule(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;
    output [7:0] RESULT;
    assign #1 RESULT = (DATA1 & DATA2);
endmodule

module ormodule(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;
    output [7:0] RESULT;
    assign #1 RESULT = (DATA1 | DATA2);
endmodule

module forwardmodule(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;
    output [7:0] RESULT;
    assign #1 RESULT = DATA2;
endmodule

module mux8bit(IN0,SELECT,MUXOUT);
    input [7:0] IN0;
    input SELECT; 
    output reg [7:0] MUXOUT;
    always @(*) begin
        case(SELECT)
            0: MUXOUT = 8'h00;
            1: MUXOUT = IN0;
        endcase
    end
endmodule

module add8bit(A,B,C,D,OUT);
    input [7:0] A, B, C, D;
    output reg [7:0] OUT;
    always @(*) begin
        OUT = #2 A+B+C+D;
    end
endmodule

module multmodule(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;
    output [7:0] RESULT;
    reg [7:0] array1 [0:3];
    wire [7:0] array2 [0:3];
    mux8bit mux1(array1[0],DATA2[0],array2[0]);
    mux8bit mux2(array1[1],DATA2[1],array2[1]);
    mux8bit mux3(array1[2],DATA2[2],array2[2]);
    mux8bit mux4(array1[3],DATA2[3],array2[3]);
    add8bit adder8bit(array2[0],array2[1],array2[2],array2[3],RESULT);

    always @(*) begin
        array1[0] <= #1 {4'b0000, DATA1[3:0]};
        array1[1] <= #1 {3'b000, DATA1[3:0], 1'b0};
        array1[2] <= #1 {2'b00, DATA1[3:0], 2'b00};
        array1[3] <= #1 {1'b0, DATA1[3:0], 3'b000};
    end
endmodule

module shifter(DATA1, SHIFTMT, RESULT);
    input [7:0] DATA1, SHIFTMT;
    output reg [7:0] RESULT;

    always @(*) begin
        case(SHIFTMT)
            8'h00: RESULT = DATA1;
            8'h01: RESULT = {DATA1[6:0], 1'b0};
            8'h02: RESULT = {DATA1[5:0], 2'b00};
            8'h03: RESULT = {DATA1[4:0], 3'b000};
            8'h04: RESULT = {DATA1[3:0], 4'b0000};
            8'h05: RESULT = {DATA1[2:0], 5'b00000};
            8'h06: RESULT = {DATA1[1:0], 6'b000000};
            8'h07: RESULT = {DATA1[0], 7'b0000000};
            8'hFF: RESULT = {1'b0, DATA1[7:1]};
            8'hFE: RESULT = {2'b00, DATA1[7:2]};
            8'hFD: RESULT = {3'b000, DATA1[7:3]};
            8'hFC: RESULT = {4'b0000, DATA1[7:4]};
            8'hFB: RESULT = {5'b00000, DATA1[7:5]};
            8'hFA: RESULT = {6'b000000, DATA1[7:6]};
            8'hF9: RESULT = {7'b0000000, DATA1[7]};
            default: RESULT = 8'b00000000;
        endcase
    end
endmodule

module arithmetic_shifter(DATA1, SHIFTMT, RESULT);
    input [7:0] DATA1, SHIFTMT;
    output reg [7:0] RESULT;

    always @(*) begin
        case(SHIFTMT)
            8'h00: RESULT = DATA1;
            8'h01: RESULT = {DATA1[7], DATA1[7:1]};
            8'h02: RESULT = {{2{DATA1[7]}}, DATA1[7:2]};
            8'h03: RESULT = {{3{DATA1[7]}}, DATA1[7:3]};
            8'h04: RESULT = {{4{DATA1[7]}}, DATA1[7:4]};
            8'h05: RESULT = {{5{DATA1[7]}}, DATA1[7:5]};
            8'h06: RESULT = {{6{DATA1[7]}}, DATA1[7:6]};
            default: RESULT = {8{DATA1[7]}};
        endcase
    end
endmodule

module rotatemodule(DATA1, RORAMT, RESULT);
    input [7:0] DATA1, RORAMT;
    output reg [7:0] RESULT;

    always @(*) begin
        case(RORAMT[2:0])
            3'b000: RESULT = DATA1;
            3'b001: RESULT = {DATA1[0], DATA1[7:1]};
            3'b010: RESULT = {DATA1[1:0], DATA1[7:2]};
            3'b011: RESULT = {DATA1[2:0], DATA1[7:3]};
            3'b100: RESULT = {DATA1[3:0], DATA1[7:4]};
            3'b101: RESULT = {DATA1[4:0], DATA1[7:5]};
            3'b110: RESULT = {DATA1[5:0], DATA1[7:6]};
            3'b111: RESULT = {DATA1[6:0], DATA1[7]};
        endcase
    end
endmodule


module alu_mux(ADDRESULT, ANDRESULT, ORRESULT, FORWARDRESULT, MULTRESULT, SHIFTRESULT, ASHIFTRESULT, ROTATERESULT, MUXSELECT, MUXOUT, ZERO);
    input [7:0] ADDRESULT, ANDRESULT, ORRESULT, FORWARDRESULT, MULTRESULT, SHIFTRESULT, ASHIFTRESULT, ROTATERESULT;
    input [0:2] MUXSELECT;
    output reg [7:0] MUXOUT;
    output reg ZERO;

    always @(*)
    begin
        case(MUXSELECT)
            3'b000: MUXOUT = FORWARDRESULT;
            3'b001: MUXOUT = ADDRESULT;
            3'b010: MUXOUT = ANDRESULT;
            3'b011: MUXOUT = ORRESULT;
            3'b100: MUXOUT = MULTRESULT;
            3'b101: MUXOUT = SHIFTRESULT;
            3'b110: MUXOUT = ASHIFTRESULT;
            3'b111: MUXOUT = ROTATERESULT;
            default: MUXOUT = 8'b00000000;
        endcase
    ZERO = (ADDRESULT == 8'h00) ? 1 : 0;
    end
endmodule

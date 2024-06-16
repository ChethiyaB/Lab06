`timescale 1ns/100ps
module regfile(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLK, RESET);
    input [7:0] IN;
    input [2:0] INADDRESS, OUT1ADDRESS, OUT2ADDRESS;
    input WRITE, CLK, RESET;
    output reg [7:0] OUT1, OUT2;
    integer i;
    reg [7:0] regArray [0:7];
    
    always @(*) begin

        case(OUT1ADDRESS)
            3'b000: OUT1<= #2 regArray[0];
            3'b001: OUT1<= #2 regArray[1];
            3'b010: OUT1<= #2 regArray[2];
            3'b011: OUT1<= #2 regArray[3];
            3'b100: OUT1<= #2 regArray[4];
            3'b101: OUT1<= #2 regArray[5];
            3'b110: OUT1<= #2 regArray[6];
            3'b111: OUT1<= #2 regArray[7];
        endcase

        case(OUT2ADDRESS)
            3'b000: OUT2<= #2 regArray[0];
            3'b001: OUT2<= #2 regArray[1];
            3'b010: OUT2<= #2 regArray[2];
            3'b011: OUT2<= #2 regArray[3];
            3'b100: OUT2<= #2 regArray[4];
            3'b101: OUT2<= #2 regArray[5];
            3'b110: OUT2<= #2 regArray[6];
            3'b111: OUT2<= #2 regArray[7];
        endcase
    end

    always @ (posedge CLK)
    begin
        if(WRITE)begin
            case(INADDRESS)
                3'b000: regArray[0]<= #1 IN;
                3'b001: regArray[1]<= #1 IN;
                3'b010: regArray[2]<= #1 IN;
                3'b011: regArray[3]<= #1 IN;
                3'b100: regArray[4]<= #1 IN;
                3'b101: regArray[5]<= #1 IN;
                3'b110: regArray[6]<= #1 IN;
                3'b111: regArray[7]<= #1 IN;
            endcase
        end
        if(RESET)begin
            for (i = 0; i < 8; i = i + 1) begin
                regArray[i] <= #1 8'h00;
            end
        end
    end
endmodule
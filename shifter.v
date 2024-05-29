module left_shift_mux(
    input [7:0] SHIFTIN,
    input [7:0] shift_amount,
    output reg [7:0] SHIFTOUT;
);

    always @(*) begin
        case (shift_amount)
            8'b0000_0000: SHIFTOUT = SHIFTIN;                       
            8'b0000_0001: SHIFTOUT = {SHIFTIN[6:0], 1'b0};          
            8'b0000_0010: SHIFTOUT = {SHIFTIN[5:0], 2'b00};         
            8'b0000_0011: SHIFTOUT = {SHIFTIN[4:0], 3'b000};        
            8'b0000_0100: SHIFTOUT = {SHIFTIN[3:0], 4'b0000};      
            8'b0000_0101: SHIFTOUT = {SHIFTIN[2:0], 5'b00000};     
            8'b0000_0110: SHIFTOUT = {SHIFTIN[1:0], 6'b000000};    
            8'b0000_0111: SHIFTOUT = {SHIFTIN[0], 7'b0000000};     
            default: SHIFTOUT = 0;                
        endcase
    end
endmodule
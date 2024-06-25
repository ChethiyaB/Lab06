`timescale 1ns/100ps
module instruction_memory(
	clock,
	read,
    address,
    readinst,
	busywait
);
input				clock;
input				read;
input[5:0]			address;
output reg [127:0]	readinst;
output	reg			busywait;

reg readaccess;

//Declare memory array 1024x8-bits 
reg [7:0] memory_array [1023:0];

//Initialize instruction memory
initial
begin
	busywait = 0;
	readaccess = 0;
	
    {memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  = 32'b00000000_00000000_00000000_00001001; // loadi 0 0x09

    {memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  = 32'b00000000_00000001_00000000_00000001; // loadi 1 0x01

    {memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  = 32'b00010000_00000000_00000000_00000001; // swd 0 1

    {memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00010001_00000000_00000001_00000000; // swi 1 0x00

    {memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00001110_00000010_00000000_00000001; // lwd 2 1

	{memory_array[10'd23], memory_array[10'd22], memory_array[10'd21], memory_array[10'd20]} = 32'b00001110_00000011_00000000_00000001; // lwd 3 1

	{memory_array[10'd27], memory_array[10'd26], memory_array[10'd25], memory_array[10'd24]} = 32'b00000011_00000100_00000000_00000001; // sub 4 0 1

	{memory_array[10'd31], memory_array[10'd30], memory_array[10'd29], memory_array[10'd28]} = 32'b00010001_00000000_00000100_00000010; // swi 4 0x02

	{memory_array[10'd35], memory_array[10'd34], memory_array[10'd33], memory_array[10'd32]} = 32'b00001111_00000101_00000000_00000010; // lwi 5 0x02

	{memory_array[10'd39], memory_array[10'd38], memory_array[10'd37], memory_array[10'd36]} = 32'b00010001_00000000_00000100_00100000; // swi 4 0x20
	
	{memory_array[10'd43], memory_array[10'd42], memory_array[10'd41], memory_array[10'd40]} = 32'b00001111_00000110_00000000_00100000; // lwi 6 0x20
end

//Detecting an incoming memory access
always @(read)
begin
    busywait = (read)? 1 : 0;
    readaccess = (read)? 1 : 0;
end

//Reading
always @(posedge clock)
begin
	if(readaccess)
	begin
		readinst[7:0]     = #40 memory_array[{address,4'b0000}];
		readinst[15:8]    = #40 memory_array[{address,4'b0001}];
		readinst[23:16]   = #40 memory_array[{address,4'b0010}];
		readinst[31:24]   = #40 memory_array[{address,4'b0011}];
		readinst[39:32]   = #40 memory_array[{address,4'b0100}];
		readinst[47:40]   = #40 memory_array[{address,4'b0101}];
		readinst[55:48]   = #40 memory_array[{address,4'b0110}];
		readinst[63:56]   = #40 memory_array[{address,4'b0111}];
		readinst[71:64]   = #40 memory_array[{address,4'b1000}];
		readinst[79:72]   = #40 memory_array[{address,4'b1001}];
		readinst[87:80]   = #40 memory_array[{address,4'b1010}];
		readinst[95:88]   = #40 memory_array[{address,4'b1011}];
		readinst[103:96]  = #40 memory_array[{address,4'b1100}];
		readinst[111:104] = #40 memory_array[{address,4'b1101}];
		readinst[119:112] = #40 memory_array[{address,4'b1110}];
		readinst[127:120] = #40 memory_array[{address,4'b1111}];
		busywait = 0;
		readaccess = 0;
	end
end
 
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module DDS(          input CLK,
                     input RST,
                     input [31:0] fcw, // Frequency Controlled Word to control the frequency of the DDS output
                     output [15 : 0] sine, // output will use a 16-bit Reg to contain sin val
                     output [15 : 0] sine_2, // output will use a 16-bit Reg to contain sin val
                     output [15 : 0] sine_3, // output will use a 16-bit Reg to contain sin val
                     output [3 : 0] triangleWave,
                     output [31 : 0] sawtoothWave,
                     output [44 : 0] chordWave             
                     );
parameter N = 1024; // values of sine will be spread out among N (2 ^ 10)

// Declare Memory Arrays
reg [15 : 0] rom_memory [N - 1: 0]; // Declare a 16 bit array for rom_sine
reg [15 : 0] rom_memory_2 [N - 1: 0]; // Declare a 16 bit rom_squareWave

reg [31:0] accumulator_val; // reg to store current value of accumulator
reg [31:0] accumulator_val_2; // reg to store current value of accumulator
reg [31:0] accumulator_val_3; // reg to store current value of accumulator


reg [31 : 0] sawtooth_reg; // reg to store value for sawtooth wave

wire [9:0] lut_index; // Define a wire to hold the current index of the look up table
wire [9:0] lut_index_2; // Define a wire to hold the current index of the look up table
wire [9:0] lut_index_3; // Define a wire to hold the current index of the look up table

wire [44 : 0] chordWave_wire; // Define a wire to hold the value of the chordWave


initial begin
    $readmemh("sine.mem", rom_memory);
    $readmemh("squareWave.mem", rom_memory_2);
end

always@(posedge CLK) begin 
    // Initilize Count Values to 0 when RST = 1
    if (RST) begin
    accumulator_val <= 0;
    accumulator_val_2 <= 0;
    accumulator_val_3 <= 0;
    sawtooth_reg <= 0;
    end
    
    else begin
    // Incremenet acumulator value with fcw
    sawtooth_reg <= sawtooth_reg + fcw; // Increment counter by FCW to create a Sawtooth Graph
   
    accumulator_val <= accumulator_val + fcw; // Increment first sine graph
    accumulator_val_2 <= accumulator_val_2 + (fcw + (fcw * 0.5)); // Increment second sine graph
    accumulator_val_3 <= accumulator_val_3 + (fcw + (fcw * 0.25)); // increment 3rd sine graph
    end


end

// index sine lookup tables with accumulator values
assign lut_index = accumulator_val[31 : 22];
assign lut_index_2 = accumulator_val_2[31 : 22];
assign lut_index_3 = accumulator_val_3[31 : 22];

// assign current index in lut to sin outs
assign sine = rom_memory[lut_index];
assign sine_2 = rom_memory[lut_index_2];
assign sine_3 = rom_memory[lut_index_3];

// combine the output of all 3 sine waves to create a chord
assign chordWave_wire = (sine) + (sine_2) + (sine_3);

// assign wave outputs to correct wires
assign chordWave = chordWave_wire;
assign sawtoothWave = sawtooth_reg;
assign triangleWave = rom_memory_2[lut_index];

endmodule

// Immediate Generator. 4 for opcode, 3 + 3 for registers, 6 bits left for immediate
module Immediate_Generator(instruction, immediate_out);
    input [15:0] instruction;
    output [15:0] immediate_out;

    assign immediate_out = {{10{instruction[5]}}, instruction[5:0]}; // Sign-extend the 6-bit immediate

endmodule

// Read the memory for instructions or reset it all to zero
module Instruction_Memory(read_address, instruction_out);
    input clk, reset;
    input [15:0] read_address;
    output [15:0] instruction_out;
    integer i;

    reg [15:0] I_mem [63:0];

    initial begin
        for(i = 0; i < 64; i = i + 1)
            I_mem[i] = 16'b0;
        
        $readmemb("program2.mem", I_mem);
        end

    assign instruction_out = I_mem[read_address[5:0]]; // 64 blocks = 6 bits
endmodule

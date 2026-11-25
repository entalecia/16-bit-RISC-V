// Either resets PC or updates it with the input value
module Program_Counter(clk, reset, PC_in, PC_out);
    input clk, reset;
    input [15:0] PC_in;
    output reg [15:0] PC_out;

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            PC_out <= 16'b0;
        else
            PC_out <= PC_in;
    end
endmodule

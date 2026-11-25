// Register file with 8 registers, each 16-bit wide
// 3 bits for registers, 4 bits for opcode

module Register_File(clk, reset, read_reg1, read_reg2, write_reg3, reg_write, write_data, read_data1, read_data2);
    input clk, reset, reg_write;
    input [2:0] read_reg1, read_reg2, write_reg3;
    input [15:0] write_data;
    output [15:0] read_data1, read_data2;

    reg [15:0] registers [7:0];
    integer i;
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'b0;
        end
        else if (reg_write)
        begin
            registers[write_reg3] <= write_data;
        end
    end

    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

endmodule
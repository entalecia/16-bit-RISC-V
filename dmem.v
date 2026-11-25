module Data_Memory(clk, reset, mem_write, mem_read, read_address, write_data, memdata_out);
    input clk, reset, mem_write, mem_read;
    input [15:0] read_address, write_data;
    output [15:0] memdata_out;

    reg [15:0] D_mem[63:0];
    integer i;

    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 64; i = i + 1)
                D_mem[i] <= 16'b0;
        end
        else if (mem_write)
            D_mem[read_address[5:0]] <= write_data; 
    end

    assign memdata_out = (mem_read) ? D_mem[read_address[5:0]] : 16'b0;
endmodule
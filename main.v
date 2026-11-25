module top(clk, reset, halted);
    input clk, reset;
    output halted;

    wire [15:0] PC_out, pc_plus_one, PC_in;
    wire [15:0] instruction_out;
    wire [15:0] read_data1, read_data2, dmem_mux;
    wire [15:0] immediate_out;
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, jump, zero, halt;
    wire [2:0] alu_op, read_reg2_mux;
    wire [15:0] alu_result, alu_mux1;
    wire [15:0] branch_adder, branch_mux, jump_adder, jump_mux;
    wire [15:0] memdata_out;


    
    Program_Counter PC( .clk(clk), .reset(reset), .PC_in(PC_in), .PC_out(PC_out));

    assign pc_plus_one = PC_out + 16'd1;

    Instruction_Memory IM(.read_address(PC_out), .instruction_out(instruction_out));

    assign dmem_mux = mem_to_reg ? memdata_out : alu_result;
    assign read_reg2_mux = (mem_write || branch) ? instruction_out[11:9] : instruction_out[5:3]; // if branching or writing to memory, read_reg2 is destination register
    Register_File RF( .clk(clk), .reset(reset), .read_reg1(instruction_out[8:6]), .read_reg2(read_reg2_mux), .write_reg3(instruction_out[11:9]), .reg_write(reg_write), .write_data(dmem_mux), .read_data1(read_data1), .read_data2(read_data2));

    Immediate_Generator IG( .instruction(instruction_out), .immediate_out(immediate_out));

    Control_Unit CU( .opcode(instruction_out[15:12]), .branch(branch), .mem_read(mem_read), .mem_to_reg(mem_to_reg), .alu_op(alu_op), .mem_write(mem_write), .alu_src(alu_src), .reg_write(reg_write), .jump(jump), .halt(halt));

    assign alu_mux1 = alu_src ? immediate_out : read_data2;

    ALU alu_instance( .A(read_data1), .B(alu_mux1), .alu_op(alu_op), .zero(zero), .alu_result(alu_result));

    assign branch_adder = PC_out + immediate_out;
    assign branch_mux = branch & zero ? branch_adder : pc_plus_one;
    assign jump_adder = {PC_out[15:12], instruction_out[11:0]}; // JMP has 12 bit + 4 for opcode
    assign jump_mux = jump ? jump_adder : branch_mux;
    
    assign PC_in = halt ? PC_out : jump_mux;
    assign halted = halt;

    Data_Memory DM( .clk(clk), .reset(reset), .mem_write(mem_write), .mem_read(mem_read), .read_address(alu_result), .write_data(read_data2), .memdata_out(memdata_out));

endmodule
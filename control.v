module Control_Unit(opcode, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write, jump, halt);
    input [3:0] opcode;
    output reg branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, jump, halt;
    output reg [2:0] alu_op;

    always @(*)
    begin
        case (opcode)
            4'b0000: begin // NOP
                reg_write = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b000;
            end
            4'b0001: begin // ADD
                reg_write = 1;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b000;
            end
            4'b0010: begin // SUB
                reg_write = 1;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b001;
            end
            4'b0011: begin // AND
                reg_write = 1;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b010;
            end
            4'b0100: begin // OR
                reg_write = 1;
                halt = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b011;
            end
            4'b0101: begin // SLT
                reg_write = 1;
                halt = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b100;
            end
            4'b0110: begin // ADDI
                reg_write = 1;
                halt = 0;
                alu_src = 1;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b000; // We are just adding them in the ALU
            end
            4'b0111: begin // LW
                reg_write = 1;
                halt = 0;
                alu_src = 1;
                mem_read = 1;
                mem_write = 0;
                mem_to_reg = 1;
                branch = 0;
                jump = 0;
                alu_op = 3'b000;
            end
            4'b1000: begin // SW
                reg_write = 0;
                halt = 0;
                alu_src = 1;
                mem_read = 0;
                mem_write = 1;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                alu_op = 3'b000;
            end
            4'b1001: begin // BEQ
                reg_write = 0;
                halt = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 1;
                jump = 0;
                alu_op = 3'b001;
            end
            4'b1010: begin // JMP
                reg_write = 0;
                halt = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 1;
                alu_op = 3'b000;
            end
            4'b1111: begin // HLT
                reg_write = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                halt = 1;
                alu_op = 3'b000;
            end
            default: begin
                reg_write = 0;
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                mem_to_reg = 0;
                branch = 0;
                jump = 0;
                halt = 0;
                alu_op = 3'b000;
            end
        endcase
    end
endmodule
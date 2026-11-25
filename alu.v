module ALU(A, B, alu_op, zero, alu_result);
    input [15:0] A, B;
    input [2:0] alu_op;
    output reg zero;
    output reg [15:0] alu_result;

    always @(*)
    begin
        case (alu_op)
            3'b000: alu_result = A + B; // ADD, ADDI, LW, SW
            3'b001: alu_result = A - B; // SUB, BEQ
            3'b010: alu_result = A & B; // AND
            3'b011: alu_result = A | B; // OR
            3'b100: alu_result = (A < B) ? 16'b1 : 16'b0; // SLT
            default: alu_result = 16'b0;
        endcase
        zero = (alu_result == 16'b0) ? 1 : 0; // Used for branching
    end

endmodule
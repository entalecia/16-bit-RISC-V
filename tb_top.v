`timescale 1ns / 1ps

module tb_top;
    reg clk;
    reg reset;
    wire halted;

    top uut (.clk(clk), .reset (reset), .halted(halted));

    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period (100 MHz)

    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, tb_top);

        $dumpvars(0, uut.RF.registers[0]);
        $dumpvars(0, uut.RF.registers[1]);
        $dumpvars(0, uut.RF.registers[2]);
        $dumpvars(0, uut.RF.registers[3]);
        $dumpvars(0, uut.RF.registers[4]);
        $dumpvars(0, uut.RF.registers[5]);
        $dumpvars(0, uut.RF.registers[6]);
        $dumpvars(0, uut.RF.registers[7]);

        reset = 1;
        #12;
        reset = 0;

        wait (halted == 1'b1);
        #20;
        $finish;
    end

    initial begin
        #1000; // 100 clock cycle
        $display("WARNING: Simulation timed out before HLT!");
        $finish;
    end
endmodule
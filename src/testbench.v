`timescale 1ns/1ps

module testbench;

    reg clock;
    reg reset;

    cpu uut (
        .clock(clock),
        .reset(reset)
    );

    integer errors;

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, uut);

        
        clock = 0;
        reset = 1;
        errors = 0;

        #10;
        reset = 0;

        #50;

        $display("=== Resultado do Testbench: ===");

        

        $display("x2 = %d", uut.registradores.registradores[2]);
        $display("x3 = %d", uut.registradores.registradores[3]);
        $display("x4 = %d", uut.registradores.registradores[4]);
        $display("x7 = %d", uut.registradores.registradores[7]);
        $display("x7 = %d", uut.registradores.registradores[7]);
        $display("Data Memory[0] =%d", uut.dataMem.memoria[2]);

        $finish;
    end

   always begin
        #5 clock = ~clock; // Toggle clock every 5 time units
    end
endmodule

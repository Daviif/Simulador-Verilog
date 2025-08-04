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

        #100;

        $display("=== Resultado do Testbench: ===");

        

        $display("x1 = %d (deve ser 0)", uut.registradores.registradores[1]);
        $display("x4 = %d (deve ser 20)", uut.registradores.registradores[4]);
        $display("x5 = %d (deve ser 16)", uut.registradores.registradores[5]);
        $display("x6 = %d (deve ser 20)", uut.registradores.registradores[6]);
        $display("x7 = %d (deve ser 8)", uut.registradores.registradores[7]);
        $display("Data Memory[1] =%d (deve ser 20)", uut.dataMem.memoria[1]);

        $finish;
    end

   always begin
        #5 clock = ~clock; // Toggle clock every 5 time units
    end
endmodule

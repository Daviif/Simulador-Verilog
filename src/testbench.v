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

        

        $display("x3 = %d (deve ser 5)", uut.registradores.registradores[3]);
        $display("x4 = %d (deve ser 5)", uut.registradores.registradores[4]);
        $display("x5 = %d (deve ser 0 instruçõa pulada)", uut.registradores.registradores[5]);
        $display("x6 = %d (deve ser 0 x5+x5)", uut.registradores.registradores[6]);
        $display("Data Memory[1] =%d (deve ser 5)", uut.dataMem.memoria[1]);

        $finish;
    end

   always begin
        #5 clock = ~clock; // Toggle clock every 5 time units
    end
endmodule

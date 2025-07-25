// ================================
// Testbench para o processador RISC-V
// ================================

`timescale 1ns/1ps

module testbench;

    logic clock;
    logic reset;

    // Instancia o módulo top-level da CPU
    cpu uut (
        .clock(clock),
        .reset(reset)
    );

    // Geração do clock: período de 10ns (100MHz)
    always #5 clock = ~clock;

    // Sequência de teste
    initial begin
        $display("Iniciando simulação...");

        // Inicialização
        clock = 0;
        reset = 1;

        // Espera duas bordas de clock
        #10;
        reset = 0;

        // Executa por um tempo suficiente para várias instruções
        #500;

        $display("Finalizando simulação.");
        $finish;
    end

    // Dump para visualização de sinais (opcional para GTKWave)
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end

endmodule

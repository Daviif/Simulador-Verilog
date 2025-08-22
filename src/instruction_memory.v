module instruction_memory(
    input wire [31:0]endereco,
    output wire [31:0] instrucao
);
    reg [31:0] memoria [0:12];

    integer i;
    initial begin
         // Carregar programa
        $readmemb("programa.bin", memoria, 0, 12);
        
        // Debug: mostrar instruções carregadas
        $display("=== INSTRUÇÕES CARREGADAS ===");
        for (i = 0; i < 13; i = i + 1) begin
            $display("memoria[%0d] = %b", i, memoria[i]);
        end
    end

    assign instrucao = memoria[endereco[9:2]];
endmodule
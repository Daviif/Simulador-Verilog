module instruction_memory(
    input wire [31:0]endereco,
    output wire [31:0] instrucao
);
    reg [31:0] memoria [0:63];

    initial begin
        for (integer i = 0; i < 64; i = i + 1) begin
            memoria[i] = 32'b00000000000000000000000000010011; // Instrução NOP (No Operation)
        end
         // Carregar programa
        $readmemb("programa.bin", memoria);
        
        // Debug: mostrar instruções carregadas
        $display("=== INSTRUÇÕES CARREGADAS ===");
        $display("memoria[0] = %b", memoria[0]);
        $display("memoria[1] = %b", memoria[1]); 
        $display("memoria[2] = %b", memoria[2]);
        $display("memoria[3] = %b", memoria[3]);
        $display("memoria[4] = %b", memoria[4]);
    end

    assign instrucao = memoria[endereco[9:2]];
endmodule
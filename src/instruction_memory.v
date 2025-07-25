module instrucao_memory(
    input logic [31:0]endereco,
    output logic [31:0] instrucao
);
    logic [31:0] memory [0:255];

    initial $readmemb("program.bin", memory);

    assign instrucao = memory[endereco[9:2]];
endmodule
module instruction_memory(
    input wire [31:0]endereco,
    output reg [31:0] instrucao
);
    reg [31:0] memoria [0:7];

    initial $readmemb("program.bin", memoria);

    assign instrucao = memoria[endereco[9:2]];
endmodule
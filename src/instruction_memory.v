module instruction_memory(
    input wire [31:0]endereco,
    output wire [31:0] instrucao
);
    reg [31:0] memoria [0:8];

    initial begin
        $readmemb("programa.bin", memoria);
    end

    assign instrucao = memoria[endereco[9:2]];
endmodule
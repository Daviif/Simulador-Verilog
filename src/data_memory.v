module data_memory(
    input wire clock,
    input wire MemRead, MemWrite,
    input wire [31:0] endereco,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] memoria [0:255];

    // Inicializar memória com zeros para debug
    initial begin
        for (integer i = 0; i < 256; i = i + 1) begin
            memoria[i] = 32'h00000000;
        end
    end

    // Leitura (word-aligned, divide por 4)
    assign read_data = MemRead ? memoria[endereco[9:2]] : 32'b0;

    // Escrita
    always @(posedge clock) begin
        if (MemWrite) begin
            memoria[endereco[9:2]] <= write_data;
            // Debug da escrita
            $display("DEBUG: Escrevendo endereco[%0d] = %0d (addr_original=%0d)", 
                    endereco[9:2], write_data, endereco);
        end
    end

endmodule
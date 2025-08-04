module mux3_1 #(parameter WIDTH = 32) (
    input wire [1:0] seletor,
    input wire [WIDTH-1:0] entrada0,
    input wire [WIDTH-1:0] entrada1,
    input wire [WIDTH-1:0] entrada2,
    output reg [WIDTH-1:0] saida
);
    always_comb begin
        case(seletor)
            2'b00: saida = entrada0;
            2'b01: saida = entrada1;
            2'b10: saida = entrada2;
            default: saida = {WIDTH{1'bx}}; // Saída indefinida para seletores inválidos
        endcase
    end
endmodule
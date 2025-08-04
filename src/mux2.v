module mux2 #(parameter WIDTH = 32)(
    input wire seletor,
    input wire [WIDTH-1:0] entrada1,
    input wire [WIDTH-1:0] entrada2,
    output wire [WIDTH-1:0] saida
);
    assign saida = (seletor) ? entrada2 : entrada1;

endmodule
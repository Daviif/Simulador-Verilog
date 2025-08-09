module alu(
    input wire [31:0] entrada1,
    input wire [31:0] entrada2,
    input wire [3:0] alu_control,
    output reg [31:0] resultado,
    output wire zero
);

    assign zero = (resultado == 32'b0);

    always @(*) begin
        case (alu_control)
            4'b0000: resultado = entrada1 + entrada2;                               // ADD
            4'b0001: resultado = entrada1 - entrada2;                               // SUB
            4'b0010: resultado = entrada1 & entrada2;                               // AND
            4'b0011: resultado = entrada1 | entrada2;                               // OR
            4'b0100: resultado = entrada1 ^ entrada2;                               // XOR
            4'b0101: resultado = ~(entrada1 | entrada2);                            // NOR
            4'b0110: resultado = ($signed(entrada1) < $signed(entrada2)) ? 32'd1 : 32'd0; // SLT signed
            4'b0111: resultado = (entrada1 < entrada2) ? 32'd1 : 32'd0;              // SLT unsigned
            4'b1000: resultado = entrada1 << entrada2[4:0];                         // SLL
            4'b1001: resultado = entrada1 >> entrada2[4:0];                         // SRL
            4'b1010: resultado = $signed(entrada1) >>> entrada2[4:0];               // SRA
            default: resultado = 32'b0;
        endcase
    end

endmodule

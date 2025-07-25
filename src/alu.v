module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [2:0] alu_control,
    output logic [31:0] resultado,
    output logic zero
);
    assign resultado = (alu_control == 3'b000) ? a + b : // ADD
                  (alu_control == 3'b001) ? a - b : // SUB
                  (alu_control == 3'b010) ? a & b : // AND
                  (alu_control == 3'b011) ? a | b : // OR
                  (alu_control == 3'b100) ? a ^ b : // XOR
                  (alu_control == 3'b101) ? ~(a | b) : // NOR
                  (alu_control == 3'b110) ? a << b[4:0] : // SLL
                  (alu_control == 3'b111) ? a >> b[4:0] : 32'b0; // SRL

endmodule
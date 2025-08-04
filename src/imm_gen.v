module imm_gen(
    input wire [31:0] instrucao,
    output reg [31:0] immediate
);

wire [6:0] opcode = instrucao[6:0];
wire [2:0] funct3 = instrucao[14:12];

always @(*) begin
    case (opcode)
        7'b0000011: immediate = {{20{instrucao[31]}}, instrucao[31:20]}; // Load
        7'b0010011: immediate = {{20{instrucao[31]}}, instrucao[31:20]}; // Immediate arithmetic
        7'b0100011: immediate = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]}; // Store
        7'b1100011: immediate = {{19{instrucao[31]}}, instrucao[7], instrucao[30:25], instrucao[11:8], 1'b0}; // Branch
        7'b0110111: immediate = {instrucao[31:12], 12'b0}; // LUI
        7'b0010111: immediate = {instrucao[31:12], 12'b0}; // AUIPC
        default: immediate = 32'b0; // Default case
    endcase
end

endmodule
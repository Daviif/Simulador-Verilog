module imm_gen(
    input wire [31:0] instrucao,
    output reg [31:0] immediate
);

wire [6:0] opcode = instrucao[6:0];
wire [2:0] funct3 = instrucao[14:12];

always @(*) begin
        case (opcode)
            7'b0000011, // LW
            7'b0010011: // I-type
                immediate = {{20{instrucao[31]}}, instrucao[31:20]};
            7'b0100011: // SW
                immediate = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};

            7'b1100011: // BEQ
                immediate = {{19{instrucao[31]}}, instrucao[31], instrucao[7],
                             instrucao[30:25], instrucao[11:8], 1'b0};

            default:
                immediate = 0;
        endcase
    end

endmodule
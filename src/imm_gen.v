module imm_gen (
    input  wire [31:0] instrucao,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instrucao[6:0];

    always @(*) begin
        case (opcode)
            // I-type (ex.: addi, lw, jalr)
            7'b0000011, // LW
            7'b0010011, // ADDI
            7'b1100111: // JALR
                imm_out = {{20{instrucao[31]}}, instrucao[31:20]};

            // S-type (ex.: sw)
            7'b0100011:
                imm_out = {{20{instrucao[31]}}, instrucao[31:25], instrucao[11:7]};

            // B-type (ex.: beq, bne)
            7'b1100011:
                imm_out = {{19{instrucao[31]}}, instrucao[31], instrucao[7],
                           instrucao[30:25], instrucao[11:8], opcode};

            // U-type (ex.: lui, auipc)
            7'b0110111, // LUI
            7'b0010111: // AUIPC
                imm_out = {instrucao[31:12], 12'b0};

            // J-type (ex.: jal)
            7'b1101111:
                imm_out = {{11{instrucao[31]}}, instrucao[31],
                           instrucao[19:12], instrucao[20],
                           instrucao[30:21], 1'b0};

            // Default (R-type ou instrução inválida)
            default:
                imm_out = 32'b0;
        endcase
    end

endmodule

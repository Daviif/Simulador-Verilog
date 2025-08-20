module alu_control(
    input  wire [1:0] ALUOp,      // vem do control unit
    input  wire [2:0] funct3,     // instrução
    input  wire [6:0] funct7,     // instrução (usamos bit[5] para distinguir SRL/SRA e ADD/SUB)
    output reg  [3:0] alu_control // código para a ALU
);

    always @(*) begin
        // default
        alu_control = 4'b0000; // ADD por padrão

        case (ALUOp)
            2'b00: begin
                // ALUOp=00: Para loads, stores, e instruções I-type imediatas
                // NOTA: funct3=010 em loads/stores deve usar ADD, não SLT!
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADD / ADDI / LW / SW
                    3'b001: alu_control = 4'b0000; // SLLI
                    3'b010: alu_control = 4'b0000; // LW/SW (usa ADD) / SLTI - CORRIGIDO!
                    3'b011: alu_control = 4'b0111; // SLTIU (unsigned)
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b101: begin                   // SRLI / SRAI (depende de funct7[5])
                        if (funct7[5]) alu_control = 4'b1010; // SRAI
                        else           alu_control = 4'b1001; // SRLI
                    end
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b111: alu_control = 4'b0010; // ANDI
                    default: alu_control = 4'b0000;
                endcase
            end

            2'b01: begin
                // Branches — normalmente comparam usando SUB (BEQ/BNE) e outros sinais externos interpretam resultado
                alu_control = 4'b0001; // SUB
            end

            2'b10: begin
                // R-type: usar funct3 e funct7
                case (funct3)
                    3'b000: begin
                        // ADD or SUB (funct7 = 0100000 indica SUB em RV32)
                        if (funct7 == 7'b0100000) alu_control = 4'b0001; // SUB
                        else                      alu_control = 4'b0000; // ADD
                    end
                    3'b001: alu_control = 4'b1000; // SLL
                    3'b010: alu_control = 4'b0110; // SLT (signed)
                    3'b011: alu_control = 4'b0111; // SLTU (unsigned)
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b101: begin
                        // SRL or SRA (funct7[5] == 1 -> SRA)
                        if (funct7[5]) alu_control = 4'b1010; // SRA
                        else           alu_control = 4'b1001; // SRL
                    end
                    3'b110: alu_control = 4'b0011; // OR
                    3'b111: alu_control = 4'b0010; // AND
                    default: alu_control = 4'b0000;
                endcase
            end

            default: begin
                // segurança: ADD por padrão
                alu_control = 4'b0000;
            end
        endcase
    end

endmodule
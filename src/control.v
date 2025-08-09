module control(
    input wire [6:0] opcode,
    output reg Branch, MemRead, MemWrite, ALUSrc, RegWrite,
    output reg MemtoReg,
    output reg [1:0] ALUOp    
);

    always @(*) begin
        // Inicializar todos os sinais com 0
        Branch = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        MemtoReg = 1'b0;
        ALUOp = 2'b00;
        
        case(opcode)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUOp = 2'b10;  // R-type precisa usar funct3/funct7
                ALUSrc = 1'b0;  // usa rs2
            end
            
            7'b0100011: begin // S-type (SW, SH, SB)
                MemWrite = 1'b1;
                ALUSrc = 1'b1;  // usa immediate
                ALUOp = 2'b00;  // FORÇA ADD para calcular endereço
            end
            
            7'b1100011: begin // B-type (BEQ, BNE, etc)
                Branch = 1'b1;
                ALUOp = 2'b01;  // branch usa SUB
                ALUSrc = 1'b0;  // compara rs1 com rs2
            end
            
            7'b0110111: begin // U-type - LUI
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                ALUOp = 2'b00;
            end
            
            7'b1101111: begin // J-type - JAL
                RegWrite = 1'b1;
                Branch = 1'b1;
                MemtoReg = 1'b0;
                ALUOp = 2'b00;
            end
            
            7'b0000011: begin // I-type - load (LW, LH, LB)
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemtoReg = 1'b1;  // write back vem da memória
                ALUSrc = 1'b1;    // usa immediate
                ALUOp = 2'b00;    // FORÇA ADD para calcular endereço
            end
            
            7'b0010011: begin // I-type - immediate arithmetic (ADDI, SLTI, etc)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;    // usa immediate
                ALUOp = 2'b00;    // usa funct3 para determinar operação
            end
            
            default: begin
                // Todos os sinais já estão em 0
            end
        endcase
    end

endmodule
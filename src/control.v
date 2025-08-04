module control(
    input wire [6:0] opcode,
    output reg Branch, MemRead, MemWrite, ALUSrc, RegWrite,
    output reg MemtoReg[1:0],
    output logic [1:0] ALUOp    
);

    always @(*) begin
        Branch = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        MemtoReg = 2'b00;
        ALUOp = 2'b00;
        
        case(opcode)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUOp = 2'b10;
                ALUSrc = 1'b0;
            end
            7'b0100011: begin // S-type
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 2'b00;
            end
            7'b1100011: begin // B-type
                Branch = 1'b1;
                ALUOp = 2'b01;
                ALUSrc = 1'b0;
            end
            7'b0110111: begin // U-type - LUI
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
            end
            7'b1101111: begin // J-type - JAL
                RegWrite = 1'b1;
                Branch = 1'b1;
                MemtoReg = 1'b0;
            end
            7'b1100111: begin // J-type - JALR
            RegWrite = 1'b1;
            Branch   = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 2'b10;
        end
            7'b0000011: begin // I-type - load
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemtoReg = 2'b01;
                ALUSrc = 1'b1;
                ALUOp = 2'b00;
            end
            7'b0010011: begin // I-type - immediate arithmetic
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 2'b00;
            end
            7'b1101111: begin //SYS-type
                
            end
           default: begin
           end
        endcase
    end

endmodule
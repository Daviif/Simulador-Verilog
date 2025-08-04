module control(
    input wire [6:0] opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output logic [1:0] ALUOp    
);

    always @(*) begin
        Branch = 1'b0;
        MemRead = 1'b0;
        MemtoReg = 1'b0;
        MemWrite = 1'b0;
        ALUSrc = 1'b0;
        RegWrite = 1'b0;
        ALUOp = 2'b00;
        
        case(opcode)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUOp = 2'b10;
                ALUSrc = 1'b0;
                MemtoReg = 1'b0;
            end
            7'b0000011: begin // Load
                MemRead = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 2'b00;
            end
            7'b0100011: begin // Store
                MemWrite = 1'b1;
                ALUSrc = 1'b1;
                ALUOp = 2'b00;
            end
            7'b1100011: begin // Branch
                Branch = 1'b1;
                ALUOp = 2'b01;
                ALUSrc = 1'b0;
            end
           default: begin
           end
        endcase
    end

endmodule
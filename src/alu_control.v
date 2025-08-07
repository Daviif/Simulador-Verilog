module alu_control(
    input wire [1:0] aluOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_control
);
    
    always @(*) begin
        case (aluOp)
            2'b00: alu_control = 4'b0010; // Load/Store
            2'b01: alu_control = 4'b0110; // Branch
            2'b10: begin // R-type
                case ({funct7, funct3})
                    4'b0000: alu_control = 4'b0010; // ADD
                    4'b1000: alu_control = 4'b0110; // SUB
                    4'b0001: alu_control = 4'b0000; // SLL
                    4'b0010: alu_control = 4'b0001; // SLT
                    4'b0100: alu_control = 4'b0001; // XOR
                    4'b0110: alu_control = 4'b0000; // OR
                    default: alu_control = 4'b1111; // Invalid operation
                endcase
            end
            default: alu_control = 4'b1111; // Invalid operation
        endcase
    end
endmodule
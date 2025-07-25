module pc(
    input logic clock,
    input logic reset,
    input logic [31:0] pc_prox,
    output logic [31:0] pc_out
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0; // Reset the program counter to 0
        end else begin
            pc_out <= pc_prox; // Update the program counter with the next endereco
        end
    end

endmodule
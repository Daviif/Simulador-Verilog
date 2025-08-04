module pc(
    input wire clock,
    input wire reset,
    input wire [31:0] pc_prox,
    output reg [31:0] pc
);

    always @(posedge clock or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_prox;
    end

endmodule
module pc(
    input wire clock,
    input wire reset, pc_write,
    input wire [31:0] pc_prox, 
    output reg [31:0] pc
);

    always @(posedge clock or posedge reset) begin
        if (reset)
            pc <= 0;
        else if (pc_write)
            pc <= pc_prox;
    end

endmodule
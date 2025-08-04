module fowarding(
    input wire [4:0] entrada1EX, entrada2EX,
    input wire [4:0] rd_memoria, 
    input wire RegWrite_memoria,
    input wire [4:0] rd_WB,
    input wire RegWrite_WB,

    output logic [1:0] fowardA, forwardB
);

    always_comb begin

        fowardA = 2'b00;
        fowardB = 2'b00;

        if (RegWrite_memoria && (rd_memoria != 5'd0) && (rd_memoria == entrada1EX)) begin
            fowardA = 2'b01;
        end else if (RegWrite_WB && (rd_WB != 5'd0) && (rd_WB == entrada1EX)) begin
            fowardA = 2'b10;
        end

        if (RegWrite_memoria && (rd_memoria != 5'd0) && (rd_memoria == entrada2EX)) begin
            fowardB = 2'b01;
        end else if (RegWrite_WB && (rd_WB != 5'd0) && (rd_WB == entrada2EX)) begin
            fowardB = 2'b10;
        end
    end
endmodule
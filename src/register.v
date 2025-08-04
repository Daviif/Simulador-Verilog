module register(
    input logic clock,
    input logic RegWrite,
    input logic [4:0] rs1, rs2, rd,
    input logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2
);
    reg [31:0] registradores [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registradores[i] = 32'b0;
    end

    assign read_data1 = (rs1 == 5'd0) ? 32'b0 : registradores[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'b0 : registradores[rs2];

    always_ff @(posedge clock) begin
        if (RegWrite && rd != 5'd0) begin
            registradores[rd] <= write_data;
        end
    end

endmodule
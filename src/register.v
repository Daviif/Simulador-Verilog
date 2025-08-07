module register(
    input wire clock, RegWrite,
    input wire [4:0] rs1, rs2, rd,
    input wire [31:0] write_data,
    output wire [31:0] read_data1, read_data2
);
    reg [31:0] registradores [0:31];

    assign read_data1 = (rs1 == 5'd0) ? 32'b0 : registradores[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'b0 : registradores[rs2];

    always @(posedge clock) begin
        if (RegWrite && rd != 0) begin
            registradores[rd] <= write_data;
        end
    end

endmodule
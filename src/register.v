module register(
    input wire clock, RegWrite,
    input wire [4:0] rs1, rs2, rd,
    input wire [31:0] write_data,
    output reg [31:0] read_data1, read_data2
);
    reg [31:0] registradores [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registradores[i] = 32'b0;
        end
    end

    always @(posedge clock) begin
        if (RegWrite && rd != 0) begin
            registradores[rd] = write_data;
        end
    end

    always @(*) begin
        read_data1 = (rs1 == 0) ? 0 : registradores[rs1];
        read_data2 = (rs2 == 0) ? 0 : registradores[rs2];
    end

endmodule
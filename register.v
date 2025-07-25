module register(
    input logic clock,
    input logic RegWrite,
    input logic [4:0] rs1, rs2, rd,
    input logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2
);
    logic [31:0] registers [0:31];

    assign read_data1 = registers[rs1]; // Read data from rs1
    assign read_data2 = registers[rs2]; // Read data from rs2

    always_ff @(posedge clock) begin
        if (RegWrite && rd != 5'b0) begin
            registers[rd] <= write_data; // Write data to the register if RegWrite is high and rd is not zero
        end
    end

endmodule
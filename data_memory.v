module data_memory(
    input logic clock,
    input logic MemRead, MemWrite,
    input logic [31:0] endereco,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    logic [31:0] memory [0:255];

    assign read_data = (MemRead) ? memory[endereco[9:2]] : 0; // Read data from the specified endereco

    always_ff @(posedge clock) begin
        if (MemWrite) begin
            memory[endereco[9:2]] <= write_data; // Write data to the specified endereco
        end
    end

endmodule
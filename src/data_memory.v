module data_memory(
    input wire clock,
    input wire MemRead, MemWrite,
    input wire [31:0] endereco,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] memoria [0:255];

    assign read_data = MemRead ? memoria[endereco[9:2]] : 32'b0;

    always @(posedge clock) begin
        if (MemWrite) begin
            memoria[endereco[9:2]] <= write_data; 
        end
    end


endmodule
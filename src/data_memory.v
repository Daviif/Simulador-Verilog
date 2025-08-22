module data_memory(
    input wire clock,
    input wire MemRead, MemWrite,
    input wire [2:0] funct3,
    input wire [31:0] endereco,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [7:0] memoria [0:1023];
    reg [31:0] read_data_reg;

    // Inicializar memória com zeros para debug
    initial begin
        for (integer i = 0; i < 256; i = i + 1) begin
            memoria[i] = 32'b00000000;
        end
    end


    //leitura
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b010: begin // LW - Load Word (32-bit)
                    read_data_reg = {memoria[endereco+3], memoria[endereco+2], 
                               memoria[endereco+1], memoria[endereco]};
                end
                3'b001: begin // LH - Load Halfword unsigned (16-bit)
                    read_data_reg = {16'b0, memoria[endereco+1], memoria[endereco]};
                    //$display("DEBUG: LH endereco=%0d, dados=%b", endereco, {memoria[endereco+1], memoria[endereco]});
                end
                3'b000: begin // LB - Load Byte unsigned (8-bit) 
                    read_data_reg = {24'b0, memoria[endereco]};
                end
                default: begin
                    read_data_reg = 32'b0;
                end
            endcase
        end else begin
            read_data_reg = 32'b0; // Se não for leitura, retorna zero
        end
    end

    assign read_data = read_data_reg;

     always @(*) begin
        if (MemWrite) begin
            case (funct3)
                3'b010: begin // SW - Store Word (32-bit)
                    memoria[endereco]   <= write_data[7:0];
                    memoria[endereco+1] <= write_data[15:8];
                    memoria[endereco+2] <= write_data[23:16];
                    memoria[endereco+3] <= write_data[31:24];
                    //$display("DEBUG: SW endereco=%0d, dados=%h", endereco, write_data);
                end
                3'b001: begin // SH - Store Halfword (16-bit)
                    memoria[endereco]   <= write_data[7:0];
                    memoria[endereco+1] <= write_data[15:8];
                   // $display("DEBUG: SH endereco=%0d, dados=%b", endereco, write_data[15:0]);
                end
                3'b000: begin // SB - Store Byte (8-bit)
                    memoria[endereco] <= write_data[7:0];
                    //$display("DEBUG: SB endereco=%0d, dados=%h", endereco, write_data[7:0]);
                end
                default: begin
                    $display("DEBUG: Operação de store desconhecida funct3=%b", funct3);
                end
            endcase
        end
    end

endmodule
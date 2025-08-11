module hazard(
    input wire [4:0] rs1, rs2, rd_EX, rd_MEM,
    input wire RegWrite_EX, RegWrite_MEM, MemRead_EX, 
    output reg pc_write, if_id_write, control_mux
);
    always @(*) begin

        pc_write = 1'b1;
        if_id_write = 1'b1;
        control_mux = 1'b0;

        if (MemRead_EX && ((rd_EX == rs1 && rs1 != 5'b0) || (rd_EX == rs2 && rs2 != 5'b0))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            control_mux = 1'b1;
        end else if (RegWrite_EX && rd_EX != 5'b0 && ((rd_EX == rs1 || rd_EX == rs2))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            control_mux = 1'b1;
        end else if (RegWrite_MEM && rd_MEM != 5'b0 && ((rd_MEM == rs1 || rd_MEM == rs2))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            control_mux = 1'b1;
        end
    end
endmodule
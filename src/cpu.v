module cpu (
    input wire clock,
    input wire reset
);

    // PC e Instrução
    wire [31:0] pc, pc_prox, pc_plus4;
    wire [31:0] instrucao;
    wire pc_write;

    assign pc_plus4 = pc + 32'd4;

    pc pc_reg(
        .clock(clock),
        .reset(reset),
        .pc_prox(pc_prox),
        .pc(pc),
        .pc_write(pc_write)
    );

    instruction_memory InstMem (
        .endereco(pc),
        .instrucao(instrucao)
    );

    // Decodificação
    wire [6:0] opcode = instrucao[6:0];
    wire [4:0] rd     = instrucao[11:7];
    wire [2:0] funct3 = instrucao[14:12];
    wire [4:0] rs1    = instrucao[19:15];
    wire [4:0] rs2    = instrucao[24:20];
    wire [6:0] funct7 = instrucao[31:25];

    // Registradores da instrução anterior (pipeline simples de 1 estágio)
    reg [4:0] prev_rd;
    reg prev_RegWrite;
    reg stall_cycle;

    wire [31:0] read_data1, read_data2;
    wire [31:0] immediate;

    wire Branch, MemRead, MemWrite, ALUSrc, RegWrite;
    wire MemtoReg;
    wire [1:0] ALUOp; 
    
    // Detecção de hazard simplificada - só 1 ciclo de stall
    wire raw_hazard = prev_RegWrite && prev_rd != 5'b0 && 
                      ((prev_rd == rs1 && rs1 != 5'b0) || 
                       (prev_rd == rs2 && rs2 != 5'b0));
    
    // Se há hazard, insere um stall
    assign pc_write = ~raw_hazard;
    
    // Durante stall, desabilita TODOS os controles de escrita
    wire RegWrite_safe = RegWrite & ~raw_hazard;
    wire MemWrite_safe = MemWrite & ~raw_hazard;

    control ctrl(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );

    register registradores(
        .clock(clock),
        .RegWrite(RegWrite_safe),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen immGen(
        .instrucao(instrucao),
        .imm_out(immediate)
    );
    
    wire [31:0] read_data1_fwd = (prev_RegWrite && prev_rd != 5'b0 && prev_rd == rs1) ? write_back_data : read_data1;
    wire [31:0] read_data2_fwd = (prev_RegWrite && prev_rd != 5'b0 && prev_rd == rs2) ? write_back_data : read_data2;

    // ALU
    wire [3:0] alu_control;
    wire [31:0] alu_entrada2 = ALUSrc ? immediate : read_data2_fwd;
    wire [31:0] alu_result;
    wire zero;

    alu_control aluCtrl(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    alu alu(
        .entrada1(read_data1_fwd),
        .entrada2(alu_entrada2),
        .alu_control(alu_control),
        .resultado(alu_result),
        .zero(zero)
    );

    // Memória de Dados
    wire [31:0] MemRead_data;

    data_memory dataMem(
        .clock(clock),
        .MemRead(MemRead & ~raw_hazard),
        .MemWrite(MemWrite_safe),
        .funct3(funct3),
        .endereco(alu_result),
        .write_data(read_data2),
        .read_data(MemRead_data)
    );

    // Write Back
    wire [31:0] write_back_data;

    mux2 #(.WIDTH(32)) write_back_mux(
        .seletor(MemtoReg),
        .entrada1(alu_result),
        .entrada2(MemRead_data),
        .saida(write_back_data)
    );

    // Controle de Desvio (Branch)
    wire [31:0] branch_alvo = pc + immediate;
    wire branch_taken = Branch & zero;

    mux2 #(.WIDTH(32)) pc_mux(
        .seletor(branch_taken),
        .entrada1(pc_plus4),
        .entrada2(branch_alvo),
        .saida(pc_prox)
    );
    
    // Pipeline tracking corrigido
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            prev_rd <= 5'b0;
            prev_RegWrite <= 1'b0;
            stall_cycle <= 1'b0;
        end else begin
            // Sempre atualiza, mas durante stall desabilita prev_RegWrite
            // para que no próximo ciclo não detecte hazard novamente
            if (raw_hazard) begin
                // Durante stall, mantém prev_rd mas desabilita prev_RegWrite
                prev_RegWrite <= 1'b0;
                stall_cycle <= 1'b1;
            end else begin
                // Operação normal
                prev_rd <= rd;
                prev_RegWrite <= RegWrite;
                stall_cycle <= 1'b0;
            end
        end
    end

endmodule
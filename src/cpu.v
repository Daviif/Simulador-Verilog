module cpu (
    input wire clock,
    input wire reset
);

    // PC e Instrução
    wire [31:0] pc, pc_prox, pc_plus4;
    wire [31:0] instrucao;

    assign pc_plus4 = pc + 32'd4;

    pc pc_reg(
        .clock(clock),
        .reset(reset),
        .pc_prox(pc_prox),
        .pc(pc)
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

    wire [31:0] read_data1, read_data2;
    wire [31:0] immediate;

    wire Branch, MemRead, MemWrite, ALUSrc, RegWrite;
    wire MemtoReg;
    wire [1:0] ALUOp; 

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
        .RegWrite(RegWrite),
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

    // ALU
    wire [3:0] alu_control;
    wire [31:0] alu_entrada2 = ALUSrc ? immediate : read_data2;
    wire [31:0] alu_result;
    wire zero;

    alu_control aluCtrl(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    alu alu(
        .entrada1(read_data1),
        .entrada2(alu_entrada2),
        .alu_control(alu_control),
        .resultado(alu_result),
        .zero(zero)
    );

    // Memória de Dados
    wire [31:0] MemRead_data;

    data_memory dataMem(
        .clock(clock),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
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

endmodule

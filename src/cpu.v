// ================================
// Top-Level RISC-V CPU
// Caminho de dados baseado no datapath fornecido
// ================================

module cpu (
    input logic clock,
    input logic reset
);

    // ================================
    // Sinais principais
    // ================================
    logic [31:0] pc, pc_next, pc_plus4, branch_target;
    logic [31:0] instrucao;

    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic funct7;
    logic [31:0] imm_out;

    logic [31:0] read_data1, read_data2;
    logic [31:0] alu_input_b, alu_result;
    logic zero;

    logic [31:0] mem_read_data, write_back_data;

    logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    logic [1:0] ALUOp;
    logic [2:0] alu_control_signal;

    // ================================
    // PC Register
    // ================================
    pc pc_reg(
        .clock(clock),
        .reset(reset),
        .pc_prox(pc_next),
        .pc_out(pc)
    );

    // ================================
    // instrucao Memory
    // ================================
    instrucao_memory imem(
        .endereco(pc),
        .instrucao(instrucao)
    );

    // ================================
    // Field Extraction
    // ================================
    assign opcode = instrucao[6:0];
    assign rd     = instrucao[11:7];
    assign funct3 = instrucao[14:12];
    assign rs1    = instrucao[19:15];
    assign rs2    = instrucao[24:20];
    assign funct7 = instrucao[30]; // apenas bit mais significativo

    // ================================
    // Control Unit
    // ================================
    control control_unit(
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );

    // ================================
    // Register File
    // ================================
    register regs(
        .clock(clock),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ================================
    // Immediate Generator
    // ================================
    imm_gen imm_generator(
        .instrucao(instrucao),
        .immediate(imm_out)
    );

    // ================================
    // ALU Control
    // ================================
    alu_control alu_ctrl(
        .aluOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control_signal)
    );

    // ================================
    // MUX: ALUSrc (Escolhe entre read_data2 ou imediato)
    // ================================
    mux2 alu_src_mux(
        .sel(ALUSrc),
        .a(read_data2),
        .b(imm_out),
        .y(alu_input_b)
    );

    // ================================
    // ALU
    // ================================
    alu alu_unit(
        .a(read_data1),
        .b(alu_input_b),
        .alu_control(alu_control_signal),
        .resultado(alu_result),
        .zero(zero)
    );

    // ================================
    // Data Memory
    // ================================
    data_memory dmem(
        .clock(clock),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .endereco(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // ================================
    // MUX: MemtoReg (Escolhe entre ALU ou Memória)
    // ================================
    mux2 write_back_mux(
        .sel(MemtoReg),
        .a(alu_result),
        .b(mem_read_data),
        .y(write_back_data)
    );

    // ================================
    // Branch Target Calculation
    // ================================
    assign pc_plus4 = pc + 4;
    assign branch_target = pc + imm_out;

    // MUX: Escolha do próximo PC (Branch ou PC+4)
    assign pc_next = (Branch && zero) ? branch_target : pc_plus4;

endmodule

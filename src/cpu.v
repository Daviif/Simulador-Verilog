module cpu (
    input wire clock,
    input wire reset
);

    //IF
    wire [31:0] pc_IF;
    wire [31:0] pc_plus4_IF = pc + 32'd4;
    wire [31:0] instrucao_IF;

    //ID
    wire [31:0] pc_ID;
    wire [31:0] instrucao_ID;

    wire Branch_ID, memRead_ID, MemWrite_ID, ALUSrc_ID, RegWrite_ID;
    wire [1:0] ALUOp_ID;
    wire [1:0] MemtoReg_ID;

    wire [6:0] opcode_ID = instrucao_ID[6:0];
    //wire [2:0] funct3 = instrucao_ID[14:12];
    wire [4:0] rd_ID = instrucao_ID[11:7];
    wire [4:0] rs1_ID = instrucao_ID[19:15];
    wire [4:0] rs2_ID = instrucao_ID[24:20];
    //wire [6:0] funct7 = instrucao_ID[31:25];
    wire [31:0] read_data1_ID, read_data2_ID;
    wire [31:0] immediate_ID;


    //EXE
    wire [31:0] pc_EXE;
    wire [31:0] read_data1_EXE, read_data2_EXE;
    wire [31:0] immediate_EXE;
    wire [4:0] rs1_EXE, rs2_EXE, rd_EXE;

    wire Branch_EXE, MemRead_EXE, MemWrite_EXE, ALUSrc_EXE, RegWrite_EXE;
    wire [1:0] ALUOp_EXE;
    wire [1:0] MemtoReg_EXE;

    wire [31:0] alu_result_EXE;
    wire zero_EXE;
    wire [31:0] branch_alvo_EXE = pc_EXE + immediate_EXE;


    //MEM
    wire [31:0] alu_result_MEM;
    wire [31:0] read_data2_MEM;
    wire [4:0] rd_MEM;

    wire [31:0] MemRead_MEM, MemWrite_MEM, RegWrite_MEM;
    wire [1:0] MemtoReg_MEM;

    wire [31:0] MemRead_data_MEM;

    //WB
    wire [31:0] alu_result_WB;
    wire [31:0] read_data2_WB;
    wire [4:0] rd_WB;

    wire RegWrite_WB;
    wire [1:0] MemtoReg_WB;
    wire [31:0] MemRead_data_WB;

    wire [1:0] fowardA, forwardB;
    unidade_fowarding fwd(
        .entrada1EX(rs1_EXE),
        .entrada2EX(rs2_EXE),
        .rd_memoria(rd_MEM),
        .RegWrite_memoria(RegWrite_MEM),
        .rd_WB(rd_WB),
        .RegWrite_WB(RegWrite_WB),
        .fowardA(fowardA),
        .forwardB(forwardB)
    );

    wire load_hazard = MemRead_EXE && ((rd_EXE == rs1_ID) || (rd_EXE == rs2_ID));

    
    wire branch_taken = Branch_EXE & zero_EXE;

    mux2 #(.WIDTH(32)) pc_mux(
        .seletor(branch_taken),
        .entrada1(pc_plus4_IF),
        .entrada2(branch_alvo_EXE),
        .saida(pc_prox)
    );


    pc pc_reg(
        .clock(clock),
        .reset(reset),
        .pc_prox(load_hazard ? pc_IF : pc_prox),
        .pc(pc_IF)
    );

    instruction_memory InstMem (
        .endereco(pc_IF),
        .instrucao(instrucao_IF)
    );

    wire [31:0] instrucao_ID_entrada = load_hazard ? 32'b0 : instrucao_IF;

    assign pc_ID = pc_IF;
    assign instrucao_ID = instrucao_ID_entrada; 

    control ctrl(
        .opcode(opcode_ID),
        .Branch(Branch_ID),
        .MemRead(MemRead_ID),
        .MemtoReg(MemtoReg_ID),
        .MemWrite(MemWrite_ID),
        .ALUSrc(ALUSrc_ID),
        .RegWrite(RegWrite_ID),
        .ALUOp(ALUOp_ID)
    );

    register registradores(
        .clock(clock),
        .RegWrite(RegWrite_WB),
        .rs1(rs1_ID),
        .rs2(rs2_ID),
        .rd(rd_WB),
        .write_data(write_back_data_WB),
        .read_data1(read_data1_ID),
        .read_data2(read_data2_ID)
    );

    imm_gen immGen(
        .instrucao(instrucao_ID),
        .immediate(immediate_ID)
    );

    assign pc_EXE = pc_ID;
    assign read_data1_EXE = read_data1_ID;
    assign read_data2_EXE = read_data2_ID;
    assign immediate_EXE = immediate_ID;
    assign rs1_EXE = rs1_ID;
    assign rs2_EXE = rs2_ID;
    assign rd_EXE = rd_ID;

    assign Branch_EXE = Branch_ID;
    assign MemRead_EXE = MemRead_ID;
    assign MemWrite_EXE = MemWrite_ID;
    assign ALUSrc_EXE = ALUSrc_ID;
    assign RegWrite_EXE = RegWrite_ID;
    assign ALUOp_EXE = ALUOp_ID;
    assign MemtoReg_EXE = MemtoReg_ID;

    wire [3:0] alu_control_EXE;
    wire [31:0] alu_entrada1, alu_entrada2;

    mux3_1 #(.WIDTH(32)) fwd_mux1(
        .seletor(fowardA),
        .entrada0(read_data1_EXE),
        .entrada1(alu_result_MEM),
        .entrada2(write_back_data_WB),
        .saida(alu_entrada1)
    );

    mux3_1 #(.WIDTH(32)) fwd_mux2(
        .seletor(fowardB),
        .entrada0(read_data2_EXE),
        .entrada1(alu_result_MEM),
        .entrada2(write_back_data_WB),
        .saida(alu_entrada2)
    );

    wire [31:0] alu_src2 = (ALUSrc_EXE) ? immediate_EXE : alu_entrada2;

    alu_control aluCtrl(
        .aluOp(ALUOp_EXE),
        .funct3(instrucao_ID[14:12]),
        .funct7(instrucao_ID[31:25]),
        .alu_control(alu_control_EXE)
    );

    alu alu(
        .entrada1(alu_entrada1),
        .entrada2(alu_src2),
        .alu_control(alu_control_EXE),
        .resultado(alu_result_EXE),
        .zero(zero_EXE)
    );


    assign alu_result_MEM = alu_result_EXE;
    assign read_data2_mem = alu_entrada2;
    assign rd_MEM = rd_EXE;

    assign MemRead_MEM = MemRead_EXE;
    assign MemWrite_MEM = MemWrite_EXE;
    assign RegWrite_MEM = RegWrite_EXE;
    assign MemtoReg_MEM = MemtoReg_EXE;


    data_memory dataMem(
        .clock(clock),
        .MemRead(MemRead_MEM),
        .MemWrite(MemWrite_MEM),
        .endereco(alu_result_MEM),
        .write_data(read_data2_MEM),
        .read_data(MemRead_data_MEM)
    );

    assign alu_result_WB = alu_result_MEM;
    assign MemRead_data_WB = MemRead_data_MEM;
    assign rd_WB = rd_MEM;

    assign RegWrite_WB = RegWrite_MEM;
    assign MemtoReg_WB = MemtoReg_MEM;

    mux2 #(.WIDTH(32)) write_back_mux(
        .seletor(MemtoReg-WB[0]),
        .entrada1(alu_result_WB),
        .entrada2(MemRead_data_WB),
        .saida(write_back_data_WB)
    );

    
    
endmodule

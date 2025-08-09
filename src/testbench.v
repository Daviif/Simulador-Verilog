`timescale 1ns/1ps

module debug_detalhado;

    reg clock;
    reg reset;
    integer cycle_count;

    cpu uut (
        .clock(clock),
        .reset(reset)
    );

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, uut);

        clock = 0;
        reset = 1;
        cycle_count = 0;

        #10;
        reset = 0;

        // Aguardar execução
        #100;

        $display("\n=== ANÁLISE DETALHADA CORRIGIDA ===");
        
        // Decodificação manual das instruções
        $display("\n--- DECODIFICAÇÃO CORRETA ---");
        decode_instructions();
        
        // Estado final
        show_detailed_state();
        
        // Validação do Teste 1
        validate_arithmetic_test();

        $finish;
    end

    // Decodificação correta das instruções
    task decode_instructions;
        reg [31:0] instr;
        reg [6:0] opcode;
        reg [4:0] rd, rs1, rs2;
        reg [2:0] funct3;
        reg [6:0] funct7;
        reg signed [11:0] imm_i;
        begin
            // Instrução 0
            instr = uut.InstMem.memoria[0]; // 00a00093
            opcode = instr[6:0];
            rd = instr[11:7];
            rs1 = instr[19:15];
            imm_i = instr[31:20];
            $display("Instr[0]: %h → ADDI x%0d, x%0d, %0d", instr, rd, rs1, imm_i);
            
            // Instrução 1  
            instr = uut.InstMem.memoria[1]; // 00300213
            rd = instr[11:7];
            rs1 = instr[19:15];
            imm_i = instr[31:20];
            $display("Instr[1]: %h → ADDI x%0d, x%0d, %0d", instr, rd, rs1, imm_i);
            
            // Instrução 2 (R-type)
            instr = uut.InstMem.memoria[2]; // 002081b3
            opcode = instr[6:0];
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
            funct3 = instr[14:12];
            funct7 = instr[31:25];
            $display("Instr[2]: %h → ADD x%0d, x%0d, x%0d (funct3=%b, funct7=%b)", 
                    instr, rd, rs1, rs2, funct3, funct7);
            
            // Instrução 3 (R-type)  
            instr = uut.InstMem.memoria[3]; // 40208233
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
            funct3 = instr[14:12];
            funct7 = instr[31:25];
            $display("Instr[3]: %h → SUB x%0d, x%0d, x%0d (funct3=%b, funct7=%b)", 
                    instr, rd, rs1, rs2, funct3, funct7);
            
            // Instrução 4
            instr = uut.InstMem.memoria[4]; // ffb08293
            rd = instr[11:7];
            rs1 = instr[19:15];
            imm_i = instr[31:20];
            $display("Instr[4]: %h → ADDI x%0d, x%0d, %0d", instr, rd, rs1, imm_i);
        end
    endtask

    // Estado detalhado
    task show_detailed_state;
        begin
            $display("\n--- REGISTRADORES DETALHADOS ---");
            $display("x0 = %0d (sempre zero)", uut.registradores.registradores[0]);
            $display("x1 = %0d (deveria ser 10)", uut.registradores.registradores[1]);
            $display("x2 = %0d (deveria ser 3)", uut.registradores.registradores[2]);
            $display("x3 = %0d (deveria ser 13)", uut.registradores.registradores[3]);
            $display("x4 = %0d (deveria ser 7)", uut.registradores.registradores[4]);
            $display("x5 = %0d (deveria ser 5)", uut.registradores.registradores[5]);
            
            $display("\n--- ANÁLISE DOS PROBLEMAS ---");
            if (uut.registradores.registradores[2] != 3) begin
                $display("❌ PROBLEMA: x2 = %0d, mas deveria ser 3", uut.registradores.registradores[2]);
                $display("   → Verifique se ADDI x2, x0, 3 está escrevendo em x2 corretamente");
            end
            
            if (uut.registradores.registradores[3] != 13) begin
                $display("❌ PROBLEMA: x3 = %0d, mas deveria ser 13", uut.registradores.registradores[3]);
                $display("   → ADD x3, x1, x2 não está funcionando corretamente");
                $display("   → read_data1 deveria ser 10, read_data2 deveria ser 3");
            end
            
            if (uut.registradores.registradores[4] != 7) begin
                $display("❌ PROBLEMA: x4 = %0d, mas deveria ser 7", uut.registradores.registradores[4]);
                $display("   → SUB x4, x1, x2 não está funcionando corretamente");
            end
        end
    endtask

    // Validação específica
    task validate_arithmetic_test;
        integer errors;
        begin
            errors = 0;
            $display("\n--- VALIDAÇÃO TESTE ARITMÉTICA ---");
            
            if (uut.registradores.registradores[1] == 10) 
                $display("✓ x1 = 10 (ADDI correto)");
            else begin
                $display("✗ x1 = %0d (esperado: 10)", uut.registradores.registradores[1]);
                errors = errors + 1;
            end
            
            if (uut.registradores.registradores[2] == 3) 
                $display("✓ x2 = 3 (ADDI correto)");
            else begin
                $display("✗ x2 = %0d (esperado: 3)", uut.registradores.registradores[2]);
                errors = errors + 1;
            end
            
            if (uut.registradores.registradores[3] == 13) 
                $display("✓ x3 = 13 (ADD correto)");
            else begin
                $display("✗ x3 = %0d (esperado: 13)", uut.registradores.registradores[3]);
                errors = errors + 1;
            end
            
            if (uut.registradores.registradores[4] == 7) 
                $display("✓ x4 = 7 (SUB correto)");
            else begin
                $display("✗ x4 = %0d (esperado: 7)", uut.registradores.registradores[4]);
                errors = errors + 1;
            end
            
            if (uut.registradores.registradores[5] == 5) 
                $display("✓ x5 = 5 (ADDI negativo correto)");
            else begin
                $display("✗ x5 = %0d (esperado: 5)", uut.registradores.registradores[5]);
                errors = errors + 1;
            end
            
            $display("\nRESULTADO: %0d/5 testes passaram", 5-errors);
            
            if (errors == 0)
                $display("🎉 TODOS OS TESTES PASSARAM!");
            else
                $display("❌ %0d TESTES FALHARAM", errors);
        end
    endtask

    // Monitor ciclo por ciclo com mais detalhes
    always @(posedge clock) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            $display("\n=== Ciclo %0d ===", cycle_count);
            $display("PC=%0d Instrucao=%h", uut.pc, uut.instrucao);
            
            // Mostrar campos da instrução
            $display("rd=%0d rs1=%0d rs2=%0d funct3=%b", 
                    uut.rd, uut.rs1, uut.rs2, uut.funct3);
            
            // Mostrar dados dos registradores ANTES da operação
            $display("read_data1=%0d (x%0d) read_data2=%0d (x%0d)", 
                    uut.read_data1, uut.rs1, uut.read_data2, uut.rs2);
            
            // Mostrar operação ALU
            $display("ALU: %0d %s %0d = %0d", 
                    uut.read_data1, 
                    (uut.alu_control == 4'b0000) ? "ADD" :
                    (uut.alu_control == 4'b0001) ? "SUB" : "OP", 
                    (uut.ALUSrc) ? uut.immediate : uut.read_data2, 
                    uut.alu_result);
            
            // Mostrar se vai escrever no registrador
            if (uut.RegWrite) begin
                $display("→ Escrevendo x%0d = %0d", uut.rd, uut.write_back_data);
            end
        end
    end

    always begin
        #5 clock = ~clock;
    end

endmodule
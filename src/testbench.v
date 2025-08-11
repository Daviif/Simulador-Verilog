`timescale 1ns/1ps

module testbench_simple;
    reg clock, reset;
    integer cycle_count;
    integer errors;

    cpu uut (
        .clock(clock),
        .reset(reset)
    );

    initial begin
        $dumpfile("simple_hazard.vcd");
        $dumpvars(0, uut);

        // Primeiro decodificar as instruções manualmente
        $display("\n=== ANÁLISE MANUAL DAS INSTRUÇÕES ===");
        decode_manual();

        clock = 0;
        reset = 1;
        cycle_count = 0;

        #10;
        reset = 0;

        // Executar por mais ciclos
        #200;

        $display("\n=== RESULTADO FINAL ===");
        $display("x0 = %0d", uut.registradores.registradores[0]);
        $display("x1 = %0d (esperado: 10)", uut.registradores.registradores[1]);
        $display("x2 = %0d (esperado: 3)", uut.registradores.registradores[2]);
        $display("x3 = %0d (esperado: 13)", uut.registradores.registradores[3]);
        $display("x4 = %0d (esperado: 7)", uut.registradores.registradores[4]);
        $display("x5 = %0d (esperado: 5)", uut.registradores.registradores[5]);

        // Verificação
        errors = 0;
        if (uut.registradores.registradores[1] != 10) errors = errors + 1;
        if (uut.registradores.registradores[2] != 3) errors = errors + 1;
        if (uut.registradores.registradores[3] != 13) errors = errors + 1;
        if (uut.registradores.registradores[4] != 7) errors = errors + 1;
        if (uut.registradores.registradores[5] != 5) errors = errors + 1;

        if (errors == 0) begin
            $display("\n🎉 SUCESSO! Stalls resolveram os hazards!");
        end else begin
            $display("\n❌ %0d erros restantes", errors);
        end

        $finish;
    end

    // Task para decodificar instruções manualmente
    task decode_manual;
        reg [31:0] instr;
        begin
            // Instrução 0: 00a00093
            instr = 32'h00a00093;
            $display("Instr[0]: %b → ADDI x%0d, x%0d, %0d", 
                     instr, instr[11:7], instr[19:15], $signed(instr[31:20]));
            
            // Instrução 1: 00300213  
            instr = 32'h00300213;
            $display("Instr[1]: %b → ADDI x%0d, x%0d, %0d", 
                     instr, instr[11:7], instr[19:15], $signed(instr[31:20]));
            
            // Instrução 2: 002081b3
            instr = 32'h002081b3;
            $display("Instr[2]: %b → ADD x%0d, x%0d, x%0d", 
                     instr, instr[11:7], instr[19:15], instr[24:20]);
            
            // Instrução 3: 40208233
            instr = 32'h40208233;
            $display("Instr[3]: %b → SUB x%0d, x%0d, x%0d", 
                     instr, instr[11:7], instr[19:15], instr[24:20]);
            
            // Instrução 4: ffb08293
            instr = 32'hffb08293;
            $display("Instr[4]: %b → ADDI x%0d, x%0d, %0d", 
                     instr, instr[11:7], instr[19:15], $signed(instr[31:20]));
        end
    endtask

    // Monitor com informações de hazard
    always @(posedge clock) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            if (cycle_count <= 20) begin // Mais ciclos para ver stalls
                $display("\n=== Ciclo %0d ===", cycle_count);
                
                if (uut.pc_write) begin
                    $display("PC=%0d → Instr: %h", uut.pc, uut.instrucao);
                    $display("Decodificado: rd=%0d, rs1=%0d, rs2=%0d", 
                            uut.rd, uut.rs1, uut.rs2);
                    $display("read_data1=%0d (x%0d), read_data2=%0d (x%0d)", 
                            uut.read_data1, uut.rs1, uut.read_data2, uut.rs2);
                    $display("prev_rd=%0d, prev_RegWrite=%b", uut.prev_rd, uut.prev_RegWrite);
                end else begin
                    $display("⏸️  STALL: PC=%0d (hazard detectado)", uut.pc);
                    $display("   prev_rd=%0d conflita com rs1=%0d ou rs2=%0d", 
                            uut.prev_rd, uut.rs1, uut.rs2);
                    $display("   raw_hazard=%b (rs1_hazard=%b, rs2_hazard=%b)", 
                            uut.raw_hazard,
                            (uut.prev_RegWrite && uut.prev_rd != 5'b0 && uut.prev_rd == uut.rs1 && uut.rs1 != 5'b0),
                            (uut.prev_RegWrite && uut.prev_rd != 5'b0 && uut.prev_rd == uut.rs2 && uut.rs2 != 5'b0));
                end
                
                if (uut.RegWrite_safe && uut.rd != 0) begin
                    $display("✅ Escrevendo x%0d = %0d", uut.rd, uut.write_back_data);
                end
                
                // Mostrar estado dos registradores importantes
                $display("Registradores: x1=%0d, x2=%0d, x3=%0d, x4=%0d, x5=%0d",
                        uut.registradores.registradores[1],
                        uut.registradores.registradores[2], 
                        uut.registradores.registradores[3],
                        uut.registradores.registradores[4],
                        uut.registradores.registradores[5]);
            end
        end
    end

    always begin
        #5 clock = ~clock;
    end

endmodule
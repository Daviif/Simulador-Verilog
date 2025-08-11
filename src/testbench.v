`timescale 1ns/1ps

module testbench_simple;
    reg clock, reset;
    integer cycle_count;
    integer i;
    integer errors;

    cpu uut (
        .clock(clock),
        .reset(reset)
    );

    initial begin
        $dumpfile("simple_hazard.vcd");
        $dumpvars(0, uut);

        clock = 0;
        reset = 1;
        cycle_count = 0;

        #10;
        reset = 0;

        
        $display("\n=== REGISTRADORES INICIAIS ===");
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d", i, uut.registradores.registradores[i]);
        end

        // Executar por mais ciclos
        #300;

        $display("\n=== RESULTADO FINAL ===");
        // Adicionado para mostrar os registradores no final
        for (i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %0d", i, uut.registradores.registradores[i]);
        end


        if (errors == 0) begin
            $display("\n🎉 SUCESSO! Stalls resolveram os hazards!");
        end else begin
            $display("\n❌ %0d erros restantes", errors);
        end

        $finish;
    end

    // Monitor com informações de hazard
    always @(posedge clock) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            
            if (cycle_count <= 20) begin // Mais ciclos para ver stalls
                $display("\n=== Ciclo %0d ===", cycle_count);
                
                if (uut.pc_write) begin
                    $display("PC=%0d → Instr: %b", uut.pc, uut.instrucao);
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
            end
        end
    end

    always begin
        #5 clock = ~clock;
    end

endmodule
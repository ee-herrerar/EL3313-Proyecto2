`timescale 1ns / 1ps
module Lfsr_tb;

    // Parametros
    localparam CLK_PERIOD = 10;  // 10 ns
    localparam OUTPUT_BITS = 6;
    
    // Senales del testbench
    logic clk;
    logic rst;
    logic [OUTPUT_BITS-1:0] op;
    
    // Instancia del modulo a probar
    Lfsr #(.OUTPUT_BITS(6)) dut (
        .clk(clk),
        .rst(rst),
        .op(op)
    );
    
    // Generacion de reloj
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Proceso de prueba
    initial begin
        // Declaracion de variables locales al inicio del bloque (evita errores sintacticos)
        logic [5:0] valores_vistos [63:0];
        int ciclos_unicos;
        bit repetido;

        $display("==========================================");
        $display("    TESTBENCH: LFSR de %0d bits", OUTPUT_BITS);
        $display("==========================================");
        $display("Tiempo\t\tLFSR_out\tEstado");
        $display("------------------------------------------");
        
        // Inicializacion
        clk = 0;
        rst = 0;
        ciclos_unicos = 0;
        repetido = 0;
        
        // Test 1: Reset
        $display("\n[TEST 1] Verificando RESET...");
        rst = 1;
        #10;
        $display("%0t\t%h\t\tRESET activado", $time, op);
        
        rst = 0;
        #10;
        $display("%0t\t%h\t\tRESET desactivado", $time, op);
        
        // Test 2: Verificar que no esta en 0
        if (op == 6'd0) begin
            $error("ERROR: LFSR en estado 0 despues del reset");
        end else begin
            $display("OK: LFSR inicio en %h (distinto de 0)", op);
        end
        
        // Test 3: Generar 20 valores
        $display("\n[TEST 2] Generando 20 valores...");
        for (int i = 0; i < 20; i++) begin
            #10;
            $display("%0t\t%h\t\tValor %0d", $time, op, i+1);
            
            // Verificar que nunca sea 0
            if (op == 6'd0) begin
                $error("ERROR: LFSR en estado 0 en ciclo %0d", i+1);
            end
        end
        
        // Test 4: Verificar secuencia maxima (2^6 - 1 = 63)
        $display("\n[TEST 3] Verificando que no se repite en 63 ciclos..."); 
        
        // Reiniciar LFSR
        rst = 1;
        #10;
        rst = 0;
        #10;
        
        // Reiniciar variables para la prueba de repetidos
        ciclos_unicos = 0;
        repetido = 0;

        // Capturar 63 valores
        for (int i = 0; i < 63; i++) begin
            #10;
            // Verificar si el valor ya fue visto
            for (int j = 0; j < ciclos_unicos; j++) begin
                if (valores_vistos[j] == op) begin
                    $display("%0t\t%h\t\tREPETIDO en ciclo %0d (ya visto en %0d)", 
                             $time, op, i+1, j+1);
                    repetido = 1;
                end
            end
            if (!repetido) begin
                valores_vistos[ciclos_unicos] = op;
                ciclos_unicos++;
                $display("%0t\t%h\t\tNuevo valor %0d/%0d", $time, op, ciclos_unicos, i+1);
            end
        end
        
        if (ciclos_unicos == 63) begin
            $display("OK: LFSR genero %0d valores unicos (maximo posible)", ciclos_unicos);
        end else begin
            $error("ERROR: LFSR solo genero %0d valores unicos de 63 posibles", ciclos_unicos);
        end
        
        // Test 5: Reset en medio de la secuencia
        $display("\n[TEST 4] Reset en medio de la secuencia...");
        #30;  // Avanzar algunos ciclos
        $display("%0t\t%h\t\tAntes del reset", $time, op);
        
        rst = 1;
        #10;
        $display("%0t\t%h\t\tRESET activado", $time, op);
        
        rst = 0;
        #10;
        $display("%0t\t%h\t\tRESET desactivado - Nuevo inicio", $time, op);
        
        if (op == {{OUTPUT_BITS-1{1'b0}}, 1'b1}) begin
            $display("OK: Reset reinicio correctamente a 0x01");
        end
        
        // Finalizar
        #20;
        $display("\n==========================================");
        $display("    SIMULACION COMPLETADA");
        $display("==========================================");
        $finish;
    end
    
    // Monitor de cobertura
    initial begin
        $monitor("%0t: LFSR_out = %h (bin: %b)", $time, op, op);
    end

endmodule

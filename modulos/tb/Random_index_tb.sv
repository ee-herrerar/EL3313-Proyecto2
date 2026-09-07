module Random_index_tb;

    // Parámetros
    localparam CLK_PERIOD = 10;  // 10 ns
    localparam NUM_WORDS = 50;
    
    // Señales del testbench
    logic clk;
    logic rst;
    logic enable;
    logic [5:0] word_index;
    logic valid;
    
    // Instancia del módulo a probar
    Random_index #(.NUM_WORDS(NUM_WORDS)) dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .word_index(word_index),
        .valid(valid)
    );
    
    // Generación de reloj
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Proceso de prueba
    initial begin
        $display("==========================================");
        $display("    TESTBENCH: Random Index");
        $display("    Palabras: %0d", NUM_WORDS);
        $display("==========================================");
        $display("Tiempo\tEnable\tWord_Index\tValid\tEstado");
        $display("------------------------------------------");
        
        // Inicialización
        clk = 0;
        rst = 0;
        enable = 0;
        
        // Test 1: Reset
        $display("\n[TEST 1] Verificando RESET...");
        rst = 1;
        #10;
        $display("%0t\t%s\t%0d\t\t%s\tRESET activado", 
                 $time, enable ? "1" : "0", word_index, valid ? "1" : "0");
        
        rst = 0;
        #10;
        $display("%0t\t%s\t%0d\t\t%s\tRESET desactivado", 
                 $time, enable ? "1" : "0", word_index, valid ? "1" : "0");
        
        if (word_index != 0 || valid != 0) begin
            $error("ERROR: Reset no dejó word_index=0 y valid=0");
        end else begin
            $display("OK: Reset funcionó correctamente");
        end
        
        // Test 2: Activar enable y verificar valores
        $display("\n[TEST 2] Activating enable para generar índices...");
        
        // Generar 10 valores con enable
        for (int i = 0; i < 10; i++) begin
            enable = 1;
            #10;
            $display("%0t\t%s\t%0d\t\t%s\tValor generado %0d", 
                     $time, enable ? "1" : "0", word_index, valid ? "1" : "0", i+1);
            
            // Verificar que el índice esté en rango
            if (valid && word_index >= NUM_WORDS) begin
                $error("ERROR: Índice %0d fuera de rango (máx %0d)", word_index, NUM_WORDS-1);
            end
            
            enable = 0;
            #10;
            $display("%0t\t%s\t%0d\t\t%s\tEnable desactivado", 
                     $time, enable ? "1" : "0", word_index, valid ? "1" : "0");
        end
        
        // Test 3: Verificar que sin enable no cambia
        $display("\n[TEST 3] Verificando que sin enable no cambia...");
        #30;
        $display("%0t\t%s\t%0d\t\t%s\tEsperando sin enable", 
                 $time, enable ? "1" : "0", word_index, valid ? "1" : "0");
        
        // Guardar valor actual
        logic [5:0] valor_actual = word_index;
        logic valid_actual = valid;
        
        #20;
        if (word_index == valor_actual && valid == valid_actual) begin
            $display("OK: Sin enable, word_index y valid se mantienen estables");
        end else begin
            $error("ERROR: Sin enable, los valores cambiaron (word_index: %0d→%0d, valid: %0d→%0d)", 
                   valor_actual, word_index, valid_actual, valid);
        end
        
        // Test 4: Verificar que los índices están dentro del rango
        $display("\n[TEST 4] Verificando rango de índices (0-%0d)...", NUM_WORDS-1);
        int valores_validos = 0;
        int valores_invalidos = 0;
        
        for (int i = 0; i < 20; i++) begin
            enable = 1;
            #10;
            
            if (valid) begin
                valores_validos++;
                if (word_index < NUM_WORDS) begin
                    $display("%0t\tIndex %0d es VÁLIDO (0-%0d)", 
                             $time, word_index, NUM_WORDS-1);
                end else begin
                    $error("ERROR: Index %0d fuera de rango", word_index);
                end
            end else begin
                valores_invalidos++;
                $display("%0t\tIndex %0d es INVÁLIDO (>= %0d)", 
                         $time, word_index, NUM_WORDS);
            end
            
            enable = 0;
            #10;
        end
        
        $display("\nEstadísticas:");
        $display("  - Valores válidos: %0d", valores_validos);
        $display("  - Valores inválidos: %0d", valores_invalidos);
        $display("  - Porcentaje de aciertos: %0d%%", (valores_validos * 100) / (valores_validos + valores_invalidos));
        
        // Test 5: Secuencia con enable repetido
        $display("\n[TEST 5] Secuencia rápida de enables...");
        for (int i = 0; i < 5; i++) begin
            enable = 1;
            #5;  // Enable corto
            enable = 0;
            #15;
            $display("%0t\tIndice generado: %0d (valid=%0d)", 
                     $time, word_index, valid);
        end
        
        // Test 6: Reset en medio de la operación
        $display("\n[TEST 6] Reset en medio de la operación...");
        enable = 1;
        #10;
        $display("%0t\tAntes del reset: word_index=%0d, valid=%0d", 
                 $time, word_index, valid);
        
        rst = 1;
        #10;
        $display("%0t\tRESET activado: word_index=%0d, valid=%0d", 
                 $time, word_index, valid);
        
        rst = 0;
        enable = 0;
        #10;
        $display("%0t\tRESET desactivado: word_index=%0d, valid=%0d", 
                 $time, word_index, valid);
        
        if (word_index == 0 && valid == 0) begin
            $display("OK: Reset reinició correctamente");
        end
        
        // Finalizar
        #30;
        $display("\n==========================================");
        $display("    SIMULACIÓN COMPLETADA");
        $display("==========================================");
        $display("Resumen:");
        $display("  - Valores válidos generados: %0d", valores_validos);
        $display("  - Valores inválidos generados: %0d", valores_invalidos);
        $display("  - Rango correcto: %s", (valores_validos > 0) ? "✓" : "✗");
        $finish;
    end
    
    // Monitoreo continuo
    initial begin
        $monitor("%0t: enable=%0d, word_index=%0d, valid=%0d", 
                 $time, enable, word_index, valid);
    end

endmodule
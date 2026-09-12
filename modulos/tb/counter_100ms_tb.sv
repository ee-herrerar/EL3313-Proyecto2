`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2026 17:55:55
// Design Name: 
// Module Name: counter_100ms_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter_100ms_tb(
    );
    // 1. Parámetros y reloj (100 MHz -> periodo de 10 ns)
    localparam int TEST_COUNT = 10; 
    localparam time CLK_PERIOD = 10ns;

    // 2. Señales del DUT
    logic clk;
    logic reset;
    logic active;
    logic flag_100ms;

    // 3. Instanciación del DUT con parámetro reducido
    counter_100ms #(
        .COUNT_100MS(TEST_COUNT)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .active     (active),
        .flag_100ms (flag_100ms)
    );

    // 4. Generación de reloj constante
    always #(CLK_PERIOD / 2) clk = ~clk;

    // 5. Secuencia de prueba
    initial begin
        // Configuración inicial
        $display("\n=======================================================");
        $display("        INICIANDO TESTBENCH DE counter_100ms           ");
        $display("=======================================================\n");

        // Inicializar señales
        clk    = 0;
        reset  = 1;
        active = 0;

        // --- PRUEBA 1: Reset asíncrono ---
        #(CLK_PERIOD * 2);
        reset = 0;
        #(CLK_PERIOD);
        assert (flag_100ms == 0) else $error("Error: flag_100ms debia ser 0 tras reset");

        // --- PRUEBA 2: Conteo normal y generación de pulso ---
        $display("[INFO] Habilitando contador (active = 1)...");
        active = 1;

        // Esperar TEST_COUNT-1 ciclos para llegar al pulso
        repeat (TEST_COUNT - 1) @(posedge clk);
        
        // Verificar que flag_100ms sea 1 en el ciclo límite
        #1; // Margen de asentamiento tras el flanco de subida
        assert (flag_100ms == 1) begin
            $display("[OK] Pulso flag_100ms detectado correctamente en la cuenta limite.");
        end else begin
            $error("Error: flag_100ms debia ser 1 en el limite de conteo");
        end

        // Avanzar 1 ciclo para verificar que vuelva a 0
        @(posedge clk);
        #1;
        assert (flag_100ms == 0) begin
            $display("[OK] flag_100ms se apago correctamente tras 1 ciclo.");
        end else begin
            $error("Error: flag_100ms debia volver a 0 tras 1 ciclo de reloj");
        end

        // --- PRUEBA 3: Desactivar 'active' a mitad del conteo ---
        $display("[INFO] Probando pausa/reset por 'active = 0'...");
        repeat (4) @(posedge clk); // Contar 4 ciclos
        
        active = 0; // Deshabilitar
        @(posedge clk);
        #1;
        assert (flag_100ms == 0) else $error("Error: flag_100ms no debia encenderse");

        // Reactivar y verificar que empiece a contar desde 0
        active = 1;
        repeat (TEST_COUNT - 1) @(posedge clk);
        #1;
        assert (flag_100ms == 1) begin
            $display("[OK] El contador se reinicio desde 0 tras reactivar 'active'.");
        end else begin
            $error("Error: El conteo no se reinicio desde 0 al reactivar active");
        end

        // --- PRUEBA 4: Reset durante conteo ---
        $display("[INFO] Probando reset asincrono durante conteo...");
        repeat (5) @(posedge clk);
        reset = 1;
        #1;
        assert (flag_100ms == 0) else $error("Error: reset no limpio flag_100ms");
        
        #(CLK_PERIOD * 2);
        reset = 0;

        $display("\n=======================================================");
        $display("          PRUEBAS FINALIZADAS CON EXITO                ");
        $display("=======================================================\n");
        $finish;
    end

endmodule

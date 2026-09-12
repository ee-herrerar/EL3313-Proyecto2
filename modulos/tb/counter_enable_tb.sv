`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 18:34:28
// Design Name: 
// Module Name: counter_enable_tb
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


module counter_enable_tb(
    );

    // 1. Declaración de señales
    logic clk;
    logic reset;
    logic active;
    logic enable;
    logic flag_60us;

    // Parámetros reducidos para simulación rápida
    localparam int TB_COUNT_1US    = 5;
    localparam int TB_COUNT_ENABLE = 10;
    localparam int TB_COUNT_60US   = 20;

    // Período de reloj: 10ns (100 MHz)
    localparam time CLK_PERIOD = 10ns;

    // 2. Instancia del Módulo Bajo Prueba (DUT)
    counter_enable #(
        .COUNT_1US(TB_COUNT_1US),
        .COUNT_ENABLE(TB_COUNT_ENABLE),
        .COUNT_60US(TB_COUNT_60US)
    ) dut (
        .clk(clk),
        .reset(reset),
        .active(active),
        .enable(enable),
        .flag_60us(flag_60us)
    );

    // 3. Generación del Reloj
    always #(CLK_PERIOD / 2) clk = ~clk;

    // 4. Estímulos de prueba
    initial begin
        // Inicialización de señales
        clk    = 0;
        reset  = 1;
        active = 0;

        // Esperar unos ciclos y liberar el Reset
        #(CLK_PERIOD * 2);
        reset = 0;
        #(CLK_PERIOD);

        // --- PRUEBA 1: Funcionamiento normal con active = 1 ---
        $display("[%0t] Iniciando Prueba 1: Activar módulo", $time);
        active = 1;

        // Esperar a que complete un ciclo completo de conteo (TB_COUNT_60US)
        #(CLK_PERIOD * (TB_COUNT_60US + 2));

        // --- PRUEBA 2: Desactivación por medio de active = 0 ---
        $display("[%0t] Iniciando Prueba 2: Desactivar señal active a mitad de conteo", $time);
        #(CLK_PERIOD * 3); // Dejar contar un poco
        active = 0;        // Al poner en 0, el contador debe reiniciarse inmediatamente
        #(CLK_PERIOD * 3);

        // --- PRUEBA 3: Reiniciar funcionamiento y verificar Reset Asíncrono ---
        $display("[%0t] Iniciando Prueba 3: Verificación de Reset Asíncrono", $time);
        active = 1;
        #(CLK_PERIOD * 7);
        reset = 1;         // Aplicar reset en medio del conteo
        #(CLK_PERIOD * 2);
        reset = 0;

        // Dejar correr un último ciclo completo
        #(CLK_PERIOD * TB_COUNT_60US);

        $display("[%0t] Pruebas finalizadas con éxito.", $time);
        $finish;
    end

    // 5. Monitoreo de salidas en la consola
    initial begin
        $monitor("Tiempo: %0t | reset: %b | active: %b | counter: %0d | enable: %b | flag_60us: %b", 
                 $time, reset, active, dut.counter, enable, flag_60us);
    end

endmodule
    

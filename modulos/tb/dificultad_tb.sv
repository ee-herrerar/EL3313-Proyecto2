`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 21:24:38
// Design Name: 
// Module Name: dificultad_tb
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


module dificultad_tb(
);

    // 1. Parámetro reducido para acelerar la simulación
    localparam int TB_N = 10;

    // 2. Entradas del DUT
    logic clk;
    logic reset;
    logic inicio_seleccion;
    logic stop;

    // 3. Salida del DUT
    logic dificulty_signal;

    // 4. Instancia del Módulo (Sobrescribiendo el parámetro N)
    dificultad #(
        .N(TB_N)
    ) dut (
        .clk              (clk),
        .reset            (reset),
        .inicio_seleccion (inicio_seleccion),
        .stop             (stop),
        .dificulty_signal (dificulty_signal)
    );

    // Generación de reloj de 100 MHz (Periodo = 10ns)
    always #5 clk = ~clk;

    // 5. Secuencia de prueba (Stimulus)
    initial begin
        // Inicialización de señales
        clk              = 1'b0;
        reset            = 1'b1;
        inicio_seleccion = 1'b0;
        stop             = 1'b0;

        $display("=== INICIO DE SIMULACION (tb_dificultad) ===");

        // Liberar Reset tras 30 ns
        #30;
        reset = 1'b0;
        $display("[%0t ns] Reset liberado.", $time);
        #20;

        // --- PRUEBA 1: Iniciar el conteo ---
        $display("[%0t ns] Pulsando inicio_seleccion...", $time);
        inicio_seleccion = 1'b1;
        #10;
        inicio_seleccion = 1'b0;

        // Esperar a que el contador llegue a N (TB_N=10) y alterne la dificultad a 1 (DIFICIL)
        wait(dificulty_signal == 1'b1);
        $display("[%0t ns] EXITO: dificulty_signal cambio a 1 (DIFICIL).", $time);

        // Esperar a que el contador vuelva a llegar a N y regrese a 0 (FACIL)
        wait(dificulty_signal == 1'b0);
        $display("[%0t ns] EXITO: dificulty_signal regreso a 0 (FACIL).", $time);

        #50;

        // --- PRUEBA 2: Verificar la señal de STOP ---
        $display("[%0t ns] Aplicando señal de STOP...", $time);
        stop = 1'b1;
        #20;
        stop = 1'b0;

        // Verificar que el contador y la cuenta_activa se hayan detenido
        if (dut.cuenta_activa == 1'b0 && dut.counter == '0) begin
            $display("[%0t ns] EXITO: El contador se detuvo y reinicio a 0 por STOP.", $time);
        end else begin
            $display("[%0t ns] ERROR: El contador no se detuvo correctamente.", $time);
        end

        #50;
        $display("=== FIN DE LA SIMULACION ===");
        $finish;
    end

endmodule



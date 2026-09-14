`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 00:57:01
// Design Name: 
// Module Name: mux_lcd_tb
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


module mux_lcd_tb(
    );

    // Señales de entrada (estímulos)
    logic [1:0] sel;
    
    // Canal 0 (Dificultad)
    logic [7:0] data_0;
    logic       start_0;
    logic       clear_write_0;
    logic       mode_0;

    // Canal 1 (Guiones)
    logic [7:0] data_1;
    logic       start_1;
    logic       mode_1;

    // Canal 2 (Letras del juego)
    logic [7:0] data_2;
    logic       start_2;
    logic       mode_2;

    // Canal 3 (Resultado)
    logic [7:0] data_3;
    logic       start_3;
    logic       clear_write_3;
    logic       mode_3;

    // Entradas generales del mux que actúan como salidas en los case (puertos de salida del multiplexor)
    logic       clear_write;
    logic       mode;

    // Salidas del DUT (Multiplexor)
    logic [7:0] data;
    logic       start;

    // Instancia del Módulo (DUT)
    mux_lcd dut (
        .sel(sel),
        .data_0(data_0), .start_0(start_0), .clear_write_0(clear_write_0), .mode_0(mode_0),
        .data_1(data_1), .start_1(start_1), .mode_1(mode_1),
        .data_2(data_2), .start_2(start_2), .mode_2(mode_2),
        .data_3(data_3), .start_3(start_3), .clear_write_3(clear_write_3), .mode_3(mode_3),
        .data(data),
        .start(start),
        .clear_write(clear_write),
        .mode(mode)
    );

    initial begin
        // 1. Inicializar todas las entradas con valores únicos y reconocibles
        sel = 2'b00;
        
        data_0 = 8'hA0; start_0 = 1'b1; clear_write_0 = 1'b1; mode_0 = 1'b0;
        data_1 = 8'hB1; start_1 = 1'b0;                       mode_1 = 1'b1;
        data_2 = 8'hC2; start_2 = 1'b1;                       mode_2 = 1'b0;
        data_3 = 8'hD3; start_3 = 1'b0; clear_write_3 = 1'b1; mode_3 = 1'b1;

        #10;
        
        // --- PRUEBA 1: Seleccionar Canal 0 ---
        sel = 2'b00;
        #10;
        if (data === data_0 && start === start_0 && clear_write === clear_write_0 && mode === mode_0)
            $display("[%0t ns] PASO 1 OK: Canal 0 enrutado correctamente", $time);
        else
            $error("[%0t ns] ERROR 1: Falla en canal 0", $time);

        // --- PRUEBA 2: Seleccionar Canal 1 ---
        sel = 2'b01;
        #10;
        if (data === data_1 && start === start_1 && mode === mode_1)
            $display("[%0t ns] PASO 2 OK: Canal 1 enrutado correctamente", $time);
        else
            $error("[%0t ns] ERROR 2: Falla en canal 1", $time);

        // --- PRUEBA 3: Seleccionar Canal 2 ---
        sel = 2'b10;
        #10;
        if (data === data_2 && start === start_2 && mode === mode_2)
            $display("[%0t ns] PASO 3 OK: Canal 2 enrutado correctamente", $time);
        else
            $error("[%0t ns] ERROR 3: Falla en canal 2", $time);

        // --- PRUEBA 4: Seleccionar Canal 3 ---
        sel = 2'b11;
        #10;
        if (data === data_3 && start === start_3 && clear_write === clear_write_3 && mode === mode_3)
            $display("[%0t ns] PASO 4 OK: Canal 3 enrutado correctamente", $time);
        else
            $error("[%0t ns] ERROR 4: Falla en canal 3", $time);

        #20;
        $display("\n[%0t ns] *** PRUEBAS DE MUX COMPLETADAS ***\n", $time);
        $finish;
    end

endmodule

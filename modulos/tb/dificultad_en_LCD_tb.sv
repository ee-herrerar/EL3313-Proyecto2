`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 19:43:44
// Design Name: 
// Module Name: dificultad_en_LCD_tb
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

module dificultad_en_LCD_tb (
);

    // 1. Entradas del DUT (reg o logic)
    logic clk;
    logic reset;
    logic dificultad;
    logic btn_select;
    logic busy;

    // 2. Salidas del DUT (wire o logic)
    logic       start;
    logic [7:0] data_byte;
    logic       mode;
    logic [3:0] clear_write;

    // 3. Instancia del Módulo bajo Prueba (DUT)
    dificultad_en_LCD dut (
        .clk        (clk),
        .reset      (reset),
        .dificultad (dificultad),
        .btn_select (btn_select),
        .busy       (busy),
        .start      (start),
        .data_byte  (data_byte),
        .mode       (mode),
        .clear_write(clear_write)
    );

    // Generación de reloj de 100 MHz (periodo = 10ns)
    always #5 clk = ~clk;

    // Emulación de la respuesta de la FSM_LCD (Handshake de 'busy')
    // Cuando el DUT levanta 'start', 'busy' responde poniéndose a 1 por unos ciclos.
    initial begin
        busy = 1'b1; // Inicialmente ocupado (emulando inicialización de pantalla)
    end

    always @(posedge clk) begin
        if (start) begin
            // Simula el procesamiento del caracter en el controlador LCD
            #20 busy <= 1'b1; 
            #60 busy <= 1'b0; 
        end
    end

    // 4. Secuencia de prueba (Stimulus)
    initial begin
        // Inicialización de señales
        clk        = 1'b0;
        reset      = 1'b1;
        dificultad = 1'b0; // 0: FACIL
        btn_select = 1'b0;

        $display("=== INICIO DE SIMULACION ===");

        // Liberar Reset tras 50 ns
        #50;
        reset = 1'b0;
        $display("[%0t ns] Reset liberado", $time);

        // Termina la inicialización del controlador LCD externo
        #40;
        busy = 1'b0;
        $display("[%0t ns] FSM LCD lista (busy = 0)", $time);

        // --- PRUEBA 1: Secuencia inicial (FACIL) ---
        // Esperamos a que la FSM envíe todos los caracteres de "FACIL"
        wait(dut.state == dut.IDLE);
        $display("[%0t ns] Palabra 'FACIL' enviada exitosamente. FSM en IDLE.", $time);

        #100;

        // --- PRUEBA 2: Cambio de dificultad a DIFICIL ---
        $display("[%0t ns] Cambiando señal de dificultad a 1 (DIFICIL)...", $time);
        dificultad = 1'b1;

        // Esperamos a que complete la escritura de "DIFICIL" y vuelva a IDLE
        wait(dut.state == dut.IDLE);
        $display("[%0t ns] Palabra 'DIFICIL' enviada exitosamente. FSM en IDLE.", $time);

        #100;

        // --- PRUEBA 3: Presión del botón de selección (Interrupción -> LOCKED) ---
        $display("[%0t ns] Presionando botón de selección (btn_select)...", $time);
        btn_select = 1'b1;
        #20;
        btn_select = 1'b0;

        // Esperamos a que la FSM pase al estado LOCKED
        wait(dut.state == dut.LOCKED);
        $display("[%0t ns] FSM alcanzó el estado LOCKED correctamente.", $time);

        #100;
        $display("=== FIN DE LA SIMULACION ===");
        $finish;
    end
    
endmodule


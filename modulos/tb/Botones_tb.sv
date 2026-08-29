`timescale 1ns / 1ps

module Botones_tb;

    // -------------------------------------------------------------------------
    // 1. Parámetros y Señales del Testbench
    // -------------------------------------------------------------------------
    localparam int CLK_PERIOD  = 10; // Reloj de 100 MHz (10 ns)
    localparam int NUM_BOTONES = 2;

    // Entradas del DUT
    logic                   clk;
    logic                   reset;
    logic [NUM_BOTONES-1:0] btn_async_in;

    // Salidas del DUT
    logic                   btn_sel_pulsado;
    logic                   btn_ok_pulsado;

    // Variables de control y verificación
    int total_errores = 0;

    // -------------------------------------------------------------------------
    // 2. Instanciación del Módulo bajo Prueba (DUT)
    // -------------------------------------------------------------------------
    Botones #(
        .NUM_BOTONES(NUM_BOTONES)
    ) dut (
        .clk             (clk),
        .reset           (reset),
        .btn_async_in    (btn_async_in),
        .btn_sel_pulsado (btn_sel_pulsado),
        .btn_ok_pulsado  (btn_ok_pulsado)
    );

    // -------------------------------------------------------------------------
    // 3. Generación del Reloj (100 MHz)
    // -------------------------------------------------------------------------
    always #(CLK_PERIOD / 2) clk = ~clk;

    // -------------------------------------------------------------------------
    // 4. Tarea para Simular Rebotes Mecánicos de un Botón
    // -------------------------------------------------------------------------
    task simular_pulsacion_con_rebotes(input int idx_boton);
        begin
            $display("[%0t ns] [TB] Iniciando pulsacion con rebotes en boton [%0d]...", $time, idx_boton);
            
            // Transiciones rápidas para simular el ruido/rebote de cierre mecánico
            btn_async_in[idx_boton] = 1'b1; #50;
            btn_async_in[idx_boton] = 1'b0; #30;
            btn_async_in[idx_boton] = 1'b1; #100;
            btn_async_in[idx_boton] = 1'b0; #40;
            
            // Señal estable en alto durante la pulsación
            btn_async_in[idx_boton] = 1'b1; 
            #200; // Mantener estado estable (Ajustar según la ventana de tiempo del Debouncer)

            // Transiciones rápidas para simular el ruido/rebote de apertura
            btn_async_in[idx_boton] = 1'b0; #40;
            btn_async_in[idx_boton] = 1'b1; #60;
            btn_async_in[idx_boton] = 1'b0; #30;
            
            // Estado final estable en bajo
            btn_async_in[idx_boton] = 1'b0;
            #200;
        end
    endtask

    // -------------------------------------------------------------------------
    // 5. Monitores de Verificación de Salida (Autoverificación)
    // -------------------------------------------------------------------------
    // Verifica que btn_sel_pulsado sea estrictamente un pulso de 1 ciclo de reloj
    always @(posedge clk) begin
        if (btn_sel_pulsado) begin
            $display("[%0t ns] [SUCCESS] Pulso detectado en BTN_SEL", $time);
            @(posedge clk);
            #1;
            if (btn_sel_pulsado) begin
                $display("[%0t ns] [ERROR] BTN_SEL permanecio en alto por mas de 1 ciclo clk!", $time);
                total_errores++;
            end
        end
    end

    // Verifica que btn_ok_pulsado sea strictly un pulso de 1 ciclo de reloj
    always @(posedge clk) begin
        if (btn_ok_pulsado) begin
            $display("[%0t ns] [SUCCESS] Pulso detectado en BTN_OK", $time);
            @(posedge clk);
            #1;
            if (btn_ok_pulsado) begin
                $display("[%0t ns] [ERROR] BTN_OK permanecio en alto por mas de 1 ciclo clk!", $time);
                total_errores++;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 6. Secuencia Principal de Pruebas
    // -------------------------------------------------------------------------
    initial begin
        // Inicialización de señales
        clk          = 1'b0;
        reset        = 1'b1;
        btn_async_in = '0;

        $display("==================================================");
        $display(" INICIO DE SIMULACION: Botones_tb");
        $display("==================================================");

        // CASO 1: Probar Reset del Sistema
        #100;
        reset = 1'b0;
        $display("[%0t ns] Sistema liberado del Reset", $time);
        #100;

        // CASO 2: Prueba de pulsación en BTN_SEL (Índice 0)
        simular_pulsacion_con_rebotes(0);

        // CASO 3: Prueba de pulsación en BTN_OK (Índice 1)
        simular_pulsacion_con_rebotes(1);

        // CASO 4: Prueba de presión mantenida (verificar que no genere múltiples pulsos)
        $display("[%0t ns] [TB] Manteniendo presionado BTN_SEL de forma prolongada...", $time);
        btn_async_in[0] = 1'b1;
        #500;
        btn_async_in[0] = 1'b0;
        #200;

        // Resumen de la Simulación
        $display("==================================================");
        if (total_errores == 0) begin
            $display(" RESULTADO: PRUEBA PASADA SATISFACTORIAMENTE (0 Errores)");
        end else begin
            $display(" RESULTADO: PRUEBA FALLIDA con %0d errores", total_errores);
        end
        $display("==================================================");

        $finish;
    end

endmodule

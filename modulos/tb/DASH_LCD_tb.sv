`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 22:24:24
// Design Name: 
// Module Name: DASH_LCD_tb
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


module DASH_LCD_tb(
    );
    
// 1. Entradas del DUT
    logic       clk;
    logic       reset;
    logic       start_write;
    logic [3:0] longitud;
    logic       busy;
    
    // Señales de comprobacion 
    integer start_count = 0; 
    logic data_error = 1'b0;

    // 2. Salidas del DUT
    logic       start;
    logic [7:0] data_byte;
    logic       mode;

    // 3. Instancia del Módulo bajo Prueba (DUT)
    Dash_LCD dut (
        .clk        (clk),
        .reset      (reset),
        .start_write(start_write),
        .longitud   (longitud),
        .busy       (busy),
        .start      (start),
        .data_byte  (data_byte),
        .mode       (mode)
    );

    // Generación de reloj de 100 MHz (Periodo = 10 ns)
    always #5 clk = ~clk;

    // Emulación Handshake de la FSM_LCD: Cuando ve 'start = 1', activa 'busy' por unos ciclos
    always @(posedge clk) begin
        if (start) begin
        // cuenta cuántas veces se generó start
        start_count <= start_count + 1;

        // Verifica que se esté enviando '-'
        if (data_byte != 8'h2D) begin
            data_error <= 1'b1;

            $display(
                "[%0t ns] ERROR: data_byte = %h, se esperaba 2D.",
                $time,
                data_byte
            );
        end
        else begin
            $display(
                "[%0t ns] OK: Se envio '-' correctamente.",
                $time
            );
        end            

        
            #15 busy <= 1'b1; // FSM LCD toma la orden y se ocupa
            #50 busy <= 1'b0; // FSM LCD termina de procesar el carácter
        end
    end

    // 4. Secuencia de Pruebas
    initial begin
        // Inicialización de señales
        clk         = 1'b0;
        reset       = 1'b1;
        start_write = 1'b0;
        longitud    = 4'd0;
        busy        = 1'b0;

        $display("=== INICIO DE SIMULACION (tb_Dash_LCD) ===");

        // Liberar Reset tras 30 ns
        #30;
        reset = 1'b0;
        $display("[%0t ns] Reset liberado.", $time);
        #20;

        // --- PRUEBA 1: Enviar 5 guiones ('-') ---
        $display("[%0t ns] Solicitando la escritura de 5 guiones...", $time);
        start_count = 0;
        data_error  = 1'b0;
        longitud    = 4'd5;
        start_write = 1'b1;
        #10;
        start_write = 1'b0; // Pulso de 1 ciclo

        // Esperar a que alcance el estado DONE
        wait(dut.state == dut.DONE);
        $display("[%0t ns] EXITO: Se terminaron de enviar los 5 guiones.", $time);
        $display("[%0t ns] Contador de guiones final: %0d / %0d", $time, dut.dash_count, dut.length);
        
        if (start_count == 5) begin
            $display("[%0t ns] EXITO: Se generaron exactamente 5 pulsos de start.", $time);
        end
        else begin
             $display("[%0t ns] ERROR: Se generaron %0d pulsos de start. Se esperaban 5.", 
             $time, start_count);
        end

        if (data_error == 1'b0) begin
            $display("[%0t ns] EXITO: Todos los data_byte fueron '-'.", $time);
        end
        else begin
            $display("[%0t ns] ERROR: Se detecto un data_byte incorrecto.", $time);
        end
        #100;

        // --- PRUEBA 2: Intento de reinicio en estado DONE (Debe ser ignorado) ---
        $display("[%0t ns] Intentando enviar 3 guiones mas sin aplicar Reset...", $time);
        longitud    = 4'd3;
        start_write = 1'b1;
        #10;
        start_write = 1'b0;
        #50;

        if (dut.state == dut.DONE) begin
            $display("[%0t ns] EXITO: El modulo permanece en DONE (Ignoro start_write como se esperaba).", $time);
        end else begin
            $display("[%0t ns] ERROR: El modulo salio del estado DONE sin Reset.", $time);
        end

        // --- PRUEBA 3: Reset y prueba de longitud = 3 ---
        #20;
        $display("[%0t ns] Aplicando Reset para liberar el modulo...", $time);
        reset = 1'b1;
        #20;
        reset = 1'b0;
        #20;
        

        $display("[%0t ns] Solicitando la escritura de 3 guiones...", $time);
        start_count = 0;
        data_error  = 1'b0;
        longitud    = 4'd3;
        start_write = 1'b1;
        #10;
        start_write = 1'b0;

        wait(dut.state == dut.DONE);
        $display("[%0t ns] EXITO: Se terminaron de enviar los 3 guiones tras el Reset.", $time);
        
        if (start_count == 3) begin
             $display("[%0t ns] EXITO: Se generaron exactamente 3 pulsos de start.", $time);
        end
        else begin
             $display("[%0t ns] ERROR: Se generaron %0d pulsos de start. Se esperaban 3.",
             $time, start_count);
        end

        if (data_error == 1'b0) begin
            $display("[%0t ns] EXITO: Todos los data_byte fueron '-'.", $time);
        end
        else begin
            $display("[%0t ns] ERROR: Se detecto un data_byte incorrecto.", $time);
        end
        #100;
        $display("=== FIN DE LA SIMULACION ===");
        $finish;
    end

endmodule

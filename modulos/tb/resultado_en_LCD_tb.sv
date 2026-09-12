`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 22:30:02
// Design Name: 
// Module Name: resultado_en_LCD_tb
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


module resultado_en_LCD_tb(
    );
    // 1. Entradas y Salidas del DUT (Device Under Test)
    logic       clk;
    logic       reset;
    logic       start_write;
    logic       gano;
    logic       busy;

    logic       start;
    logic [7:0] data_byte;
    logic       mode;
    logic [3:0] clear_write;

    // Instanciación del módulo a probar
    resultado_en_LCD dut (
        .clk(clk),
        .reset(reset),
        .start_write(start_write),
        .gano(gano),
        .busy(busy),
        .start(start),
        .data_byte(data_byte),
        .mode(mode),
        .clear_write(clear_write)
    );

    // 2. Generación del reloj (Reloj de 50 MHz -> Periodo de 20ns)
    always #10 clk = ~clk;

    // 3. Emulación de la FSM_LCD (Simula la respuesta de la señal 'busy')
    // Cuando el DUT envía 'start' o 'clear_write', 'busy' se activa por 4 ciclos de reloj
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            busy <= 1'b0;
        end else begin
            if (start || clear_write[0]) begin
                busy <= 1'b1; // El LCD se pone ocupado al recibir un comando
            end else if (busy) begin
                // Mantiene 'busy' durante un tiempo aleatorio/fijo para simular el procesamiento
                repeat (3) @(posedge clk);
                busy <= 1'b0; // El LCD vuelve a estar libre
            end
        end
    end

    // 4. Proceso del Test (Secuencia de prueba)
    initial begin
        // Configuración de formato de tiempo para las alertas
        $timeformat(-9, 1, " ns", 8);

        // Inicialización de señales
        clk         = 0;
        reset       = 1;
        start_write = 0;
        gano        = 0;

        $display("\n==================================================");
        $display("   INICIO DE SIMULACION: Módulo Resultado LCD");
        $display("==================================================\n");

        // Liberar Reset después de 50ns
        #50;
        reset = 0;
        $display("[%0t] Reset liberado. Esperando inicialización...", $time);

        // Espera a que termine la etapa WAIT_INIT
        #100;

        //-----------------------------------------------------------------
        // PRUEBA 1: Probar caso de Victoria ("GANO")
        //-----------------------------------------------------------------
        $display("\n[%0t] ---> PRUEBA 1: Enviando resultado 'GANO' (gano = 1)...", $time);
        
        @(posedge clk);
        gano        = 1'b1;
        start_write = 1'b1; // Pulso de inicio
        
        @(posedge clk);
        start_write = 1'b0; // Apagamos el disparo

        // Monitoreo de caracteres impresos
        $display("[%0t] Esperando a que se transmitan las letras...", $time);

        // Esperar hasta que el módulo llegue al estado LOCKED
        wait (dut.state == dut.LOCKED);
        #100;
        $display("[%0t] ===> RESULTADO 'GANO' ESCRITO CON EXITO!\n", $time);


        //-----------------------------------------------------------------
        // PRUEBA 2: Reinicio y prueba de Derrota ("PERDIO")
        //-----------------------------------------------------------------
        $display("[%0t] Aplicando Reset para probar el segundo caso...", $time);
        reset = 1;
        #40;
        reset = 0;
        #100;

        $display("\n[%0t] ---> PRUEBA 2: Enviando resultado 'PERDIO' (gano = 0)...", $time);
        
        @(posedge clk);
        gano        = 1'b0;
        start_write = 1'b1; // Pulso de inicio
        
        @(posedge clk);
        start_write = 1'b0;

        // Esperar hasta que vuelva a quedar en LOCKED
        wait (dut.state == dut.LOCKED);
        #100;
        $display("[%0t] ===> RESULTADO 'PERDIO' ESCRITO CON EXITO!\n", $time);

        $display("==================================================");
        $display("   SIMULACION FINALIZADA CORRECTAMENTE");
        $display("==================================================\n");
        $finish;
    end

    // 5. Monitor en consola de cada caracter enviado al LCD
    always @(posedge clk) begin
        if (start) begin
            $display("[%0t] Envia Caracter ASCII: 0x%h ('%c')", $time, data_byte, data_byte);
        end
        if (clear_write[0]) begin
            $display("[%0t] Envia comando CLEAR_WRITE", $time);
        end
    end

endmodule    


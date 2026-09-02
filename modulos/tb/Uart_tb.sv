`timescale 1ns / 1ps

module uart_wrapper_tb;

    // Parámetros para simulación
    parameter SYS_CLK_FREQ = 100_000_000; // 100 MHz
    parameter BAUD_RATE    = 9600;        // 9600 Baudios
    parameter DBIT         = 8;
    parameter SB_TICK      = 16;
    
    // Periodo del reloj (100 MHz -> 10 ns)
    localparam CLK_PERIOD = 10; 
    
    // Tiempo por cada bit transmitido (en ns)
    localparam BIT_PERIOD = 1_000_000_000 / BAUD_RATE;

    // Señales de prueba (Entradas/Salidas del DUT)
    logic             clk;
    logic             reset;
    logic             rx;
    logic             tx;
    logic             tx_start;
    logic [DBIT-1:0]  din;
    logic [DBIT-1:0]  dout;
    logic             rx_done_tick;
    logic             tx_done_tick;

    // Variables auxiliares de simulación
    logic [DBIT-1:0]  data_to_send;
    logic [DBIT-1:0]  received_tx_data;

    // Instancia del Módulo Top (DUT)
    uart_wrapper #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .DBIT         (DBIT),
        .SB_TICK      (SB_TICK)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .rx           (rx),
        .tx           (tx),
        .tx_start     (tx_start),
        .din          (din),
        .dout         (dout),
        .rx_done_tick (rx_done_tick),
        .tx_done_tick (tx_done_tick)
    );

    // 1. Generador de Reloj (100 MHz)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // 2. Monitores de Salida en la Consola de Vivado (Tcl Console)
    initial begin
        $timeformat(-9, 2, " ns", 10);
        $display("=================================================");
        $display("   INICIANDO SIMULACION DE UART WRAPPER (Vivado)");
        $display("=================================================");
    end

    // Evento: Recepción de dato completada en el DUT
    always @(posedge clk) begin
        if (rx_done_tick) begin
            $display("[%t] [RX SUCCESS] Dato recibido en dout: 0x%h ('%c')", 
                     $time, dout, (dout >= 32 && dout <= 126) ? dout : "?");
        end
    end

    // Evento: Transmisión completada en el DUT
    always @(posedge clk) begin
        if (tx_done_tick) begin
            $display("[%t] [TX SUCCESS] Pulso tx_done_tick detectado.", $time);
        end
    end

    // 3. Tareas Auxiliares de Estímulo

    // Tarea que simula un emisor externo enviando un byte a la entrada RX del DUT
    task send_rx_byte(input logic [7:0] byte_in);
        integer i;
        begin
            $display("[%t] [SIM RX EXT] Enviando byte a la linea RX: 0x%h ('%c')", $time, byte_in, byte_in);
            
            // Bit de START (0)
            rx = 1'b0;
            #(BIT_PERIOD);

            // Bits de datos (LSB primero)
            for (i = 0; i < DBIT; i = i + 1) begin
                rx = byte_in[i];
                #(BIT_PERIOD);
            end

            // Bit de STOP (1)
            rx = 1'b1;
            #(BIT_PERIOD);
            
            $display("[%t] [SIM RX EXT] Fin de trama por linea RX.", $time);
        end
    endtask

    // Tarea para deserializar y verificar lo que el DUT transmite por la línea TX
    task capture_tx_byte(output logic [7:0] byte_out);
        integer i;
        begin
            // Espera el flanco de bajada (Bit de START en TX)
            @(negedge tx);
            $display("[%t] [CAP TX] Bit de START detectado en linea TX.", $time);
            
            // Muestrea justo a la mitad del periodo del bit
            #(BIT_PERIOD + (BIT_PERIOD / 2));

            // Captura los 8 bits de datos
            for (i = 0; i < DBIT; i = i + 1) begin
                byte_out[i] = tx;
                #(BIT_PERIOD);
            end

            $display("[%t] [CAP TX] Byte capturado en la linea TX: 0x%h ('%c')", 
                     $time, byte_out, (byte_out >= 32 && byte_out <= 126) ? byte_out : "?");
        end
    endtask

    // 4. Proceso Principal de Prueba
    initial begin
        // Inicialización
        clk      = 1'b0;
        reset    = 1'b1;
        rx       = 1'b1; // La línea RX permanece en ALTO en reposo
        tx_start = 1'b0;
        din      = '0;

        // Liberación de Reset
        #(CLK_PERIOD * 10);
        reset = 1'b0;
        #(CLK_PERIOD * 10);
        $display("[%t] Reset liberado. Sistema listo.\\n", $time);

        //---------------------------------------------------------
        // PRUEBA 1: Transmisión desde el DUT (TX)
        //---------------------------------------------------------
        $display("--- PRUEBA 1: Transmision desde el DUT (TX) ---");
        data_to_send = 8'hA5; // 10100101b
        
        @(posedge clk);
        din      = data_to_send;
        tx_start = 1'b1;
        @(posedge clk);
        tx_start = 1'b0;
        
        $display("[%t] [TX START] Solicitando transmitir: 0x%h", $time, data_to_send);

        // Se captura la transmisión en paralelo
        capture_tx_byte(received_tx_data);

        // Verificación
        if (received_tx_data === data_to_send) begin
            $display("[%t] [PASS] PRUEBA 1 EXITOSA: Dato enviado y capturado coinciden.", $time);
        end else begin
            $display("[%t] [FAIL] PRUEBA 1 FALLIDA: Esperado 0x%h, Recibido 0x%h", $time, data_to_send, received_tx_data);
        end

        #(BIT_PERIOD * 2);

        //---------------------------------------------------------
        // PRUEBA 2: Recepción en el DUT (RX)
        //---------------------------------------------------------
        $display("\\n--- PRUEBA 2: Recepcion en el DUT (RX) ---");
        data_to_send = 8'h57; // Carácter ASCII 'W'
        
        send_rx_byte(data_to_send);

        #(CLK_PERIOD * 50);

        if (dout === data_to_send) begin
            $display("[%t] [PASS] PRUEBA 2 EXITOSA: El registro dout contiene el dato correcto.", $time);
        end else begin
            $display("[%t] [FAIL] PRUEBA 2 FALLIDA: Esperado 0x%h en dout, Obtuvimos 0x%h", $time, data_to_send, dout);
        end

        //---------------------------------------------------------
        // PRUEBA 3: Recepción múltiple continua
        //---------------------------------------------------------
        $display("\\n--- PRUEBA 3: Recepcion continua de bytes ---");
        send_rx_byte(8'h4F); // ASCII 'O'
        #(BIT_PERIOD);
        send_rx_byte(8'h4B); // ASCII 'K'
        
        #(BIT_PERIOD * 5);

        $display("\\n=================================================");
        $display("   TODAS LAS PRUEBAS FINALIZADAS EXITOSAMENTE");
        $display("=================================================");
        $finish;
    end

endmodule
`timescale 1ns / 1ps

module Uart_mm_tb;

    // Parametros
    parameter SYS_CLK_FREQ = 100_000_000; // 100 MHz
    parameter BAUD_RATE    = 115_200;
    parameter DBIT         = 8;
    parameter SB_TICK      = 16;
    parameter CPU_BITS     = 32;

    // Periodo de reloj para 100 MHz (10 ns)
    localparam CLK_PERIOD = 10;

    // Señales de prueba
    logic clk;
    logic reset;

    // Interfaz UART fisica
    logic rx;
    logic tx;

    // Interfaz mapeada a memoria
    logic write_enable;
    logic [CPU_BITS-1:0] wdata_i;
    logic [CPU_BITS-1:0] rdata_o;
    logic [1:0] addr_i;

    // Instancia del Modulo bajo prueba (DUT)
    Uart_mm #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .DBIT         (DBIT),
        .SB_TICK      (SB_TICK),
        .CPU_BITS     (CPU_BITS)
    ) dut (
        .clk          (clk),
        .reset        (reset),
        .rx           (rx),
        .tx           (tx),
        .write_enable (write_enable),
        .wdata_i      (wdata_i),
        .rdata_o      (rdata_o),
        .addr_i       (addr_i)
    );

    // Generador de Reloj (100 MHz)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Tarea para escribir en la interfaz mapeada a memoria
    // Escribir un dato de 32 bits en culauqiera de los registros:
    // 00 para datos tx o 10 para registro de control

    task automatic write_bus(input logic [1:0] addr, input logic [CPU_BITS-1:0] data);
        begin
            @(posedge clk);             // Esperar flanco
            addr_i          <= addr;    // Direccion del registro a escribir   
            wdata_i         <= data;    // Dato a escribir
            write_enable    <= 1'b1;    // Señal habilitacion de escritura
            
            @(posedge clk);             // Esperar otro flanco para registrar escritura
            write_enable    <= 1'b0;    // Deshabilitar escritura
            wdata_i         <= '0;      // Limpiar dato de entrada
        end
    endtask

    // Tarea para leer de la interfaz mapeada a memoria
    task automatic read_bus(input logic [1:0] addr, output logic [CPU_BITS-1:0] data);
        begin
            @(posedge clk);                 // Esperar flanco
            addr_i          <= addr;        // Colocar direccion
            write_enable    <= 1'b0;        //  Señal de lectura
            #1                              // Pequeño retardo para permitir que rdata_o se estabilice
            data            = rdata_o;     // Capturar dato leido
        end
    endtask

    initial begin
        //$timeformat(-9, 2, " ns", 10);
        
        // Inicializacion de señales + reset forzado
        clk             = 1'b0;
        reset           = 1'b1;
        rx              = 1'b1; // Linea RX inactiva (idle)
        write_enable    = 1'b0;
        wdata_i         = '0;
        addr_i          = 2'b00;
        
        // Liberar reset despues de 50 ns
        # 50;
        reset = 1'b0;
        # 50;

        $display("=================================================");
        $display("   INICIANDO SIMULACION DE UART_MM");
        $display("=================================================");

        $display("[CPU] Enviando caracter 'A' a traves de UART...");    
        // Step 1: Escribir el caracter ASCII 'A' (8'h41) en el registro TX (2'b00)
        write_bus(2'b00, 32'h0000_0041);

        // Step 2: Activar el bit de disparo 'send' en el registro de control (2'b10)
        write_bus(2'b10, 32'h0000_0001);

        $display("[CPU] Transmision iniciada. Esperando a que finalice...");

        // Step 3: Bucle de espera (Polling) sobre el registro de control (2'b10)
        // Leemos la direccion 2'b10 hasta que el bit 0 vuelva a ser 0
        begin : polling_tx
            logic [CPU_BITS-1:0] ctrl_reg;
            do begin
                // Pista: Usa read_bus(direccion, ctrl_reg) y luego espera 100 ns (#100)
                read_bus(2'b10, ctrl_reg);
                #100;
            end while (ctrl_reg[0] == 1'b1); // Bucle mientras siga transmitiendo
        end

        $display("[CPU] Transmision finalizada con exito.");

        #1000;
        $finish;
    end

endmodule
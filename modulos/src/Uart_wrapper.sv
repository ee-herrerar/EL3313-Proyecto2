// Módulo Top Wrapper que conecta Generador de Baudios, RX y TX
module Uart_wrapper #(
    parameter SYS_CLK_FREQ = 100_000_000,   // Frecuencia del reloj del sistema (ej. 100 MHz Basys 3)
    parameter BAUD_RATE    = 115_200,       // Tasa de baudios deseada
    parameter DBIT         = 8,             // Cantidad de bits de datos (8)
    parameter SB_TICK      = 16             // Ticks para bit de parada (16 = 1 stop bit)
)(
    input  logic clk, reset,
    
    // Interfaz Física de la UART
    input  logic rx,
    output logic tx,
    
    // Interfaz de Control / Usuario
    input  logic tx_start,      // Pulso para iniciar transmisión externa
    input  logic [DBIT-1:0]  din,           // Dato a transmitir externamente
    output logic [DBIT-1:0]  dout,          // Dato recibido
    output logic rx_done_tick,  // Pulso que indica que se recibió un dato
    output logic tx_done_tick   // Pulso que indica que se terminó de transmitir
);

    // Señal interna de reloj/sampling
    logic s_tick;

    // 1. Instancia del Generador de Baudios
    generador_baudios #(
        .SYS_CLK_FREQ (SYS_CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .OVERSAMPLE   (SB_TICK)
    ) baud_gen_inst (
        .clk    (clk),
        .reset  (reset),
        .s_tick (s_tick)
    );

    // 2. Instancia del Receptor UART (RX)
    uart_rx #(
        .DBIT    (DBIT),
        .SB_TICK (SB_TICK)
    ) uart_rx_inst (
        .clk          (clk),
        .reset        (reset),
        .rx           (rx),
        .s_tick       (s_tick),
        .rx_done_tick (rx_done_tick),
        .dout         (dout)
    );

    // 3. Instancia del Transmisor UART (TX)
    uart_tx #(
        .DBIT    (DBIT),
        .SB_TICK (SB_TICK)
    ) uart_tx_inst (
        .clk          (clk),
        .reset        (reset),
        .tx_start     (tx_start),
        .s_tick       (s_tick),
        .din          (din),
        .tx_done_tick (tx_done_tick),
        .tx           (tx)
    );

endmodule
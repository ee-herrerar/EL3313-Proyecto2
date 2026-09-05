// Etapa Top con Mapeo de Memoria (MM) para UART
module Uart_mm #(
    parameter SYS_CLK_FREQ  = 100_000_000,   // Frecuencia del reloj del sistema (ej. 100 MHz Basys 3)
    parameter BAUD_RATE     = 115_200,       // Tasa de baudios deseada
    parameter DBIT          = 8,             // Cantidad de bits de datos (8)
    parameter SB_TICK       = 16,             // Ticks para bit de parada (16 = 1 stop bit)
    parameter CPU_BITS      = 32
)(
    input  logic clk, reset,
    
    // Interfaz UART / FPGA
    input  logic rx,
    output logic tx,
    
    // Interfaz mapeada a memoria (MM)
    input logic write_enable,  // Señal de habilitación de escritura
    input logic [CPU_BITS-1:0]  wdata_i,        // Dato de entrada para escribir en la UART
    output logic [CPU_BITS-1:0] rdata_o,       // Dato de salida leído desde la UART
    input logic [1:0] addr_i,          // Dirección de la UART (0 para TX, 1 para RX)
);

    // 1. Cables de interconexión con el módulo uart_wrapper
    logic       rx_done_tick_int; // Pulso que indica llegada de un byte por RX
    logic       tx_done_tick_int; // Pulso que indica fin de transmisión por TX
    logic [7:0] dout_int;         // Byte recibido directamente desde el wrapper

    // 2. Registros de estado internos (Mapeados a los registros de 32 bits)
    logic [7:0] reg_tx_data;      // Registro 0 (addr = 2'b00): Dato a enviar
    logic [7:0] reg_rx_data;      // Registro 1 (addr = 2'b01): Dato recibido
    logic       reg_send;         // Registro Control (addr = 2'b10, bit 0): Disparo / Estado TX
    logic       reg_new_rx;       // Registro Control (addr = 2'b10, bit 1): Estado RX

    uart_wrapper #(
    .SYS_CLK_FREQ (SYS_CLK_FREQ),
    .BAUD_RATE    (BAUD_RATE),
    .DBIT         (DBIT),
    .SB_TICK      (SB_TICK)
) uart_wrapper_inst (
    .clk          (clk),
    .reset        (reset),
    .rx           (rx),
    .tx           (tx),
    .tx_start     (reg_send),          // El bit send activa directamente la transmisión
    .din          (reg_tx_data),       // Byte almacenado previamente en Registro 0
    .dout         (dout_int),          // Byte que entrega el receptor
    .rx_done_tick (rx_done_tick_int),  // Evento para activar reg_new_rx y guardar dout_int
    .tx_done_tick (tx_done_tick_int)   // Evento para borrar reg_send (reg_send <= 0)
);

    /*
        Mapa de registros internos
        addr_i == 2'b00: Registro de transmisión (TX)
        addr_i == 2'b01: Registro de recepción (RX)
        addr_i == 2'b10: Registro de control
            bit 0: reg_send (disparo de transmisión)
            bit 1: reg_new_rx (indica que hay un nuevo dato recibido)
    */

    always_comb begin
    case (addr_i)
            2'b00:   rdata_o = {24'b0, reg_tx_data};
            2'b01:   rdata_o = {24'b0, reg_rx_data};
            2'b10:   rdata_o = {30'b0, reg_new_rx, reg_send};
            default: rdata_o = '0;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_tx_data <= '0;
            reg_rx_data <= '0;
            reg_send    <= 1'b0;
            reg_new_rx  <= 1'b0;
        end else begin
            // 1. Escritura de datos a transmitir (Registro 0: 2'b00)
            if (write_enable && (addr_i == 2'b00)) begin
                reg_tx_data <= wdata_i[7:0];
            end

            // 2. Control de disparo de transmisión (reg_send)
            if (tx_done_tick_int) begin
                reg_send <= 1'b0; // El hardware limpia el bit al terminar la transmisión
            end else if (write_enable && (addr_i == 2'b10)) begin
                reg_send <= wdata_i[0]; // El software escribe el bit de disparo
            end

            // 3. Recepción de datos y control de bandera (reg_new_rx)
            if (rx_done_tick_int) begin
                reg_rx_data <= dout_int; // El hardware guarda el byte recibido
                reg_new_rx  <= 1'b1;     // El hardware notifica que hay nuevo dato
            end else if (write_enable && (addr_i == 2'b10)) begin
                reg_new_rx  <= wdata_i[1]; // El software actualiza/limpia la bandera
            end
        end
    end
endmodule
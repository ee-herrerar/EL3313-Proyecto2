// Módulo del Transmisor UART (SystemVerilog)
module uart_tx #(
    parameter DBIT    = 8,   // Cantidad de bits de datos
    parameter SB_TICK = 16   // Ticks para bit de parada (16 = 1 stop bit)
)(
    input  logic             clk, reset,
    input  logic             tx_start, s_tick,
    input  logic [DBIT-1:0]  din,
    output logic             tx_done_tick,
    output logic             tx
);

    // Enumeración de estados
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state_reg, state_next;

    // Registros internos
    logic [3:0] s_reg, s_next;                              // Contador de ticks
    logic [$clog2(DBIT)-1:0] n_reg, n_next;                // Contador de bits enviados
    logic [DBIT-1:0] b_reg, b_next;                        // Registro de desplazamiento
    logic tx_reg, tx_next;

    // Bloque secuencial
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg     <= '0;
            n_reg     <= '0;
            b_reg     <= '0;
            tx_reg    <= 1'b1; // Línea en ALTO en reposo
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx_reg    <= tx_next;
        end
    end

    // Lógica combinacional de estado siguiente
    always_comb begin
        state_next   = state_reg;
        tx_done_tick = 1'b0;
        s_next       = s_reg;
        n_next       = n_reg;
        b_next       = b_reg;
        tx_next      = tx_reg;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = START;
                    s_next     = '0;
                    b_next     = din;
                end
            end

            START: begin
                tx_next = 1'b0; // Bit de Start (0)
                if (s_tick) begin
                    if (s_reg == 15) begin
                        state_next = DATA;
                        s_next     = '0;
                        n_next     = '0;
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0]; // Envía el bit LSB
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = '0;
                        b_next = b_reg >> 1; // Desplazamiento a la derecha
                        if (n_reg == (DBIT - 1)) begin
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1'b1;
                        end
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; // Bit de Stop (1)
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next   = IDLE;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1'b1;
                    end
                end
            end

            default: state_next = IDLE;
        endcase
    end

    // Asignación continua de salida
    assign tx = tx_reg;

endmodule
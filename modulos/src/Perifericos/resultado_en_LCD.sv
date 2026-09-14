`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 22:27:43
// Design Name: 
// Module Name: resultado_en_LCD
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


module resultado_en_LCD(
    input  logic       clk,
    input  logic       reset,
    input  logic       start_write, // Disparo para empezar a escribir
    input  logic       gano,        // 1: GANO, 0: PERDIO
    input  logic       busy,        // Viene de la FSM_LCD
    
    output logic       start,
    output logic [7:0] data_byte,
    output logic       mode,        // 1: Incremental
    output logic       clear_write,
    output logic       done
    );



    assign mode = 1'b1; // Modo incremental

    typedef enum logic [2:0] {
        WAIT_INIT,   // Espera inicial a que el LCD esté listo
        IDLE,        // Espera el pulso start_write
        SEND_CLEAR,  // Espera a que la FSM procese el limpiado de pantalla
        SEND_CHAR,   // Envía el carácter a la FSM
        WAIT_FSM,    // Espera a que busy pase a '1'
        LOCKED       // Estado final congelado tras escribir
    } state_t;

    state_t state;

    logic [2:0] char_index;
    logic [7:0] palabra_gano   [0:3];
    logic [7:0] palabra_perdio [0:5];
    logic       gano_reg;

    // Arreglos ASCII de las palabras
    assign palabra_gano   = '{8'h47, 8'h41, 8'h4E, 8'h4F};         // "GANO" (4 caracteres)
    assign palabra_perdio = '{8'h50, 8'h45, 8'h52, 8'h44, 8'h49, 8'h4F}; // "PERDIO" (6 caracteres)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= WAIT_INIT;
            char_index  <= '0;
            start       <= 1'b0;
            clear_write <= 1'b0;
            data_byte   <= 8'h00;
            gano_reg    <= 1'b0;
            done        <= 1'b0
        end else begin
            start       <= 1'b0;
            clear_write <= 1'b0;
            done        <= 1'b0

            case (state)
                // Espera inicial a que el LCD termine su inicialización por hardware
                WAIT_INIT: begin
                    if (!busy) begin
                        state <= IDLE;
                    end
                end

                // Espera a que la señal externa ordene escribir
                IDLE: begin
                    if (start_write) begin
                        gano_reg    <= gano;
                        clear_write <= 1'b1; // Ordena limpiar la pantalla
                        char_index  <= '0;
                        state       <= SEND_CLEAR;
                    end
                end

                // Aguarda a que la FSM empiece a procesar la orden de clear (busy == 0 significa libre para avanzar)
                SEND_CLEAR: begin
                    if (!busy) begin
                        state <= SEND_CHAR;
                    end
                end

                // Envío caracter por caracter a la FSM principal
                SEND_CHAR: begin
                    if (!busy) begin
                        if (gano_reg) begin
                            data_byte <= palabra_gano[char_index];
                            start     <= 1'b1;
                            
                            if (char_index == 3'd3) begin // Fin de "GANO" (0 a 3)
                                state <= LOCKED;
                            end else begin
                                char_index <= char_index + 1'b1;
                                state      <= WAIT_FSM;
                            end
                        end else begin
                            data_byte <= palabra_perdio[char_index];
                            start     <= 1'b1;

                            if (char_index == 3'd5) begin // Fin de "PERDIO" (0 a 5)
                                done  <= 1'b1;
                                state <= LOCKED;
                            end else begin
                                char_index <= char_index + 1'b1;
                                state      <= WAIT_FSM;
                            end
                        end
                    end
                end

                // Espera a que la FSM tome el comando (detecta busy = 1)
                WAIT_FSM: begin
                    if (busy) begin
                        state <= SEND_CHAR;
                    end
                end

                // Estado final: permanece bloqueado hasta el próximo reset
                LOCKED: begin
                    start       <= 1'b0;
                    clear_write <= 1'b0;
                    done        <= 1'b0
                end

                default: state <= IDLE;
            endcase
        end
    end   
 
endmodule

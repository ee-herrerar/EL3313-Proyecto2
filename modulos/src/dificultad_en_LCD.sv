`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 19:35:13
// Design Name: 
// Module Name: dificultad_en_LCD
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


module dificultad_en_LCD(
    input clk,
    input reset,
    input dificultad,
    input btn_select,
    input busy,
    output logic start,
    output logic [7:0] data_byte,
    output logic mode,
    output logic [3:0] clear_write,
    output logic done
    );

    assign mode = 1'b1;

    typedef enum logic [2:0] {
        WAIT_INIT,
        IDLE,
        SEND_CLEAR,
        SEND_CHAR,
        WAIT_FSM,
        LAST_CLEAN,
        LOCKED
    } state_t;

    state_t state;

    logic [2:0] char_index;
    logic [7:0] palabra_facil   [0:4];
    logic [7:0] palabra_dificil [0:6];
    logic       dificultad_reg;

    assign palabra_facil   = '{8'h46, 8'h41, 8'h43, 8'h49, 8'h4C};         // "FACIL"
    assign palabra_dificil = '{8'h44, 8'h49, 8'h46, 8'h49, 8'h43, 8'h49, 8'h4C}; // "DIFICIL"

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state          <= WAIT_INIT;
            char_index     <= '0;
            start          <= 1'b0;
            clear_write    <= 4'b0;
            data_byte      <= 8'h00;
            dificultad_reg <= 1'b0;
            done           <= 1'b0;
        end else begin
            start       <= 1'b0;
            clear_write <= 4'b0;
            done        <= 1'b0;

            // Interrupción por botón de selección
            if (btn_select && state != LOCKED) begin
                clear_write <= 4'b0001;
                state       <= LAST_CLEAN;
            end else begin
                case (state)
                    // Espera inicial a que la FSM del LCD termine de inicializarse al encender
                    WAIT_INIT: begin
                        if (!busy) begin
                            dificultad_reg <= dificultad;
                            clear_write    <= 4'b0001;
                            char_index     <= '0;
                            state          <= SEND_CLEAR;
                        end
                    end

                    IDLE: begin
                        // Espera a que la señal de 5s cambie el valor de dificultad
                        if (dificultad != dificultad_reg) begin
                            dificultad_reg <= dificultad;
                            clear_write    <= 4'b0001;
                            char_index     <= '0;
                            state          <= SEND_CLEAR;
                        end
                    end

                    SEND_CLEAR: begin
                        if (!busy) begin
                            state <= SEND_CHAR;
                        end
                    end

                    SEND_CHAR: begin
                        if (!busy) begin
                            if (!dificultad_reg) begin
                                data_byte <= palabra_facil[char_index];
                                start     <= 1'b1;
                                
                                if (char_index == 3'd4) begin
                                    state <= IDLE; // Termina y se queda congelado en IDLE
                                end else begin
                                    char_index <= char_index + 1'b1;
                                    state      <= WAIT_FSM;
                                end
                            end else begin
                                data_byte <= palabra_dificil[char_index];
                                start     <= 1'b1;

                                if (char_index == 3'd6) begin
                                    state <= WAIT_FSM; // Termina 
                                end else begin
                                    char_index <= char_index + 1'b1;
                                    state      <= WAIT_FSM;
                                end
                            end
                        end
                    end

                    WAIT_FSM: begin
                        if (busy) begin
                            state <= SEND_CHAR;
                        end
                    end

                    LAST_CLEAN: begin
                        if (!busy) begin
                            done  <= 1'b1;
                            state <= LOCKED;      
                        end
                    end

                    LOCKED: begin
                        start       <= 1'b0;
                        clear_write <= 4'b0;
                        done        <= 1'b0;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule

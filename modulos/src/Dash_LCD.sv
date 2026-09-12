`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 21:38:30
// Design Name: 
// Module Name: Dash_LCD
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


module Dash_LCD(
    input clk,
    input reset,
    input start_write,
    input [3:0] longitud,
    input busy,
    
    output logic start,
    output logic [7:0] data_byte,
    output logic mode,
    output logic done
    );
    


    // Carácter ASCII para el guion '-'
    localparam logic [7:0] ASCII_DASH = 8'h2D;

    assign mode        = 1'b1; // Siempre en modo incremental

    typedef enum logic [1:0] {
        IDLE,       // Espera la orden de inicio
        SEND_DASH,  // Envía el carácter '-' a la FSM
        WAIT_FSM,   // Espera a que la FSM tome la orden (busy = 1)
        DONE        // Estado final: se detiene y no escribe más
    } state_t;

    state_t state;
    logic [3:0] dash_count;
    logic [3:0] length;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            dash_count    <= 4'd0;
            length        <= 4'd0;
            start         <= 1'b0;
            data_byte     <= 8'h00;
            done          <= 1'b0;
            
        end else begin
            // Pulso de 1 ciclo por defecto para la FSM
            start <= 1'b0;
            done  <= 1'b1;
            case (state)
                IDLE: begin
                    if (start_write) begin
                            length <= longitud;
                            dash_count    <= 4'd0;
                            data_byte     <= ASCII_DASH;
                            state         <= SEND_DASH;
                       
                    end
                end

                SEND_DASH: begin
                    // Espera a que la FSM esté libre antes de solicitar el envío
                    if (!busy) begin
                        start <= 1'b1; // Pulso de inicio a la FSM
                        state <= WAIT_FSM;
                    end
                end

                WAIT_FSM: begin
                    // Espera a que la FSM procese la orden (detecta busy = 1)
                    if (busy) begin
                        dash_count <= dash_count + 1'b1;
                        
                        // Verifica si ya se alcanzó la cantidad solicitada
                        if (dash_count + 1'b1 == length) begin
                            state <= DONE;                      // Terminó de escribir todos los guiones
                            done  <= 1'b1;
                        end else begin
                            state <= SEND_DASH; // Pasa al siguiente guion
                        end
                    end
                end

                DONE: begin
                    // Se queda congelado aquí permanentemente hasta recibir un reset
                    start     <= 1'b0;
                    data_byte <= 8'h00;
                    done      <= 1'b0;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule


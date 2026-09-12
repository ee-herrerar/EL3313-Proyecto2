`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 22:42:34
// Design Name: 
// Module Name: FSM_LCD_HD44780
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


module FSM_LCD_HD44780(
    input clk,
    input reset,

    input flag_100ms, 
    input flag_5ms, 
    input flag_200us, 
    input flag_60us,

    input start,
    input [7:0] data_byte,
    input [6:0] direccion [0:11],
    input [3:0] coincidencias,
    input mode, // 1: Incremental, 0: Random
    input clear_write,

    output logic done,
    output logic busy,
    output logic rs,
    output logic rw,
    output str_60us, 
    output str_5ms, 
    output str_200us, 
    output str_100ms,
    output reg [7:0] temp_reg
    );

// STATE DECLARATION -----------------------------------------------------------------

typedef enum logic [3:0] {
           POWER_ON = 4'b0000,
           FUNCTION_SET_I = 4'b0001,
           FUNCTION_SET_II = 4'b0010,
           FUNCTION_SET_III = 4'b0011,
           FUNCTION_SET_CONFIGURATION = 4'b0100,
           DISPLAY_OFF = 4'b0101,
           CLEAR = 4'b0110,
           ENTRY_MODE_SET = 4'b0111,
           DISPLAY_ON = 4'b1000,
           WAIT_ = 4'b1001,
           INC_RAN = 4'b1010,
           WRITE_INC = 4'b1011,
           SET_ADDRESS = 4'b1100,
           WRITE_RAN = 4'b1101,
           CLEAR_WRITE = 4'b1110
} state_t;      


// PORT/SIGNAL DECLARATION -----------------------------------------------------------

state_t current_state, next_state;


logic [3:0] coincount; // Contador de coincidencias para la escritura en modo aleatorio.

assign rw = 1'b0; // se mantiene en modo write

// MODULE BODY
// FSM
// 1 - STATE REGISTER ----------------------------------------------------------------
 
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        current_state <= POWER_ON; 
        coincount  <= 4'd0;
    end
    else begin
        current_state <= next_state;
    end
    if (current_state == WAIT_ && start) begin
        coincount <= coincidencias;
    end
    else if (current_state == WRITE_RAN && flag_60us && coincount > 4'd1) begin
        coincount <= coincount - 1'b1;
    end
end


// 2 - NEXT STATE LOGIC --------------------------------------------------------------
        
 always @* begin
    next_state = current_state; // Por defecto

    busy = 1'b1;
    done = 1'b0;
    rs = 1'b0;
    temp_reg = 8'b0; 

    case (current_state)

    // ETAPA DE INICIALIZACIÓN DEL LCD................................................
    // Tiempo de espera de 100ms para que el LCD se estabilice después del encendido.
        POWER_ON:  begin
        busy = 1'b1;                                    // Indica que el módulo está ocupado durante la inicialización.
        done = 1'b0;                                    // La inicialización no ha terminado.                                  
            if (flag_100ms)
                next_state = FUNCTION_SET_I;
            else
                next_state = POWER_ON;
        end
    // Inicialización del LCD por instrucciones según el datasheet del HD44780.
        FUNCTION_SET_I: begin
            rs = 1'b0;
            temp_reg = 8'b00110000;
            if (flag_5ms)
                next_state = FUNCTION_SET_II;
        end
        FUNCTION_SET_II: begin
            rs = 1'b0;
            temp_reg = 8'b00110000;
            if (flag_200us)
                next_state = FUNCTION_SET_III;
        end
        FUNCTION_SET_III: begin
            rs = 1'b0;
            temp_reg = 8'b00110000;
            if (flag_200us)
                next_state = FUNCTION_SET_CONFIGURATION;
        end
    // Configuracion del LCD: 8 bits, 2 líneas, fuente 5x8.
        FUNCTION_SET_CONFIGURATION: begin
            rs = 1'b0; 
            temp_reg = 8'b00111000;
            if (flag_60us)
                next_state = DISPLAY_OFF;
        end
        DISPLAY_OFF: begin
            rs = 1'b0;
            temp_reg = 8'b00001000;
            if (flag_60us)
                next_state = CLEAR;
        end
        CLEAR: begin
            rs = 1'b0;
            temp_reg = 8'b00000001;
            if (flag_5ms)
                next_state = ENTRY_MODE_SET;
        end
    // Configuración del modo de entrada: incremento, sin desplazamiento de pantalla.            
        ENTRY_MODE_SET: begin
            rs = 1'b0;
            temp_reg = 8'b00000110;
            if (flag_60us)
                next_state = DISPLAY_ON;
        end
        DISPLAY_ON: begin
            rs = 1'b0;
            temp_reg = 8'b00001100;
            if (flag_60us)
                next_state = WAIT_;
        end

    // FIN DE LA ETAPA DE INICIALIZACIÓN DEL LCD......................................
    // Espera de comandos del módulo externo.
        WAIT_: begin                          
        busy = 1'b0;                            // Indica que el módulo está listo para recibir comandos.
            if (start)
                next_state = INC_RAN;
            else if (clear_write)
                next_state = CLEAR_WRITE;
            else
                next_state = WAIT_;
        end

    // Se decide si la escritura sera en modo incremento o en modo direccionamiento aleatorio.
        INC_RAN: begin
            if (mode)
                next_state = WRITE_INC;
            else
                next_state = SET_ADDRESS;
        end

    // Escritura de datos en modo incremento.
        WRITE_INC: begin
        rs = 1'b1;
        temp_reg = data_byte;
            if (flag_60us)
                next_state = WAIT_;
        end

    // Escritura de datos en modo direccionamiento aleatorio.
        SET_ADDRESS: begin
        rs = 1'b0;
        temp_reg = (coincount > 0) ? (8'h80 | direccion[coincount - 1]) : 8'h80;
            if (flag_60us)
                next_state = WRITE_RAN;
        end

        WRITE_RAN: begin
        rs = 1'b1;
        temp_reg = data_byte;
            if (flag_60us)
                if (coincount > 4'b1) 
                    next_state = SET_ADDRESS;
                else
                next_state = WAIT_;
        end
        CLEAR_WRITE: begin
        rs = 1'b0;
        temp_reg = 8'b00000001;
            if (flag_5ms)
                next_state = WAIT_;
        end       

        default: 
            next_state = WAIT_;
    endcase
  end

// 3 - OUTPUT LOGIC -----------------------------------------------------------------
assign str_60us = (current_state == WRITE_INC) || 
                  (current_state == WRITE_RAN) || 
                  (current_state == FUNCTION_SET_CONFIGURATION) || 
                  (current_state == DISPLAY_OFF) || 
                  (current_state == DISPLAY_ON) || 
                  (current_state == ENTRY_MODE_SET)||
                  (current_state == SET_ADDRESS);

assign str_5ms = (current_state == CLEAR) || 
                 (current_state == FUNCTION_SET_I)||
                 (current_state == CLEAR_WRITE);

assign str_200us = (current_state == FUNCTION_SET_II) || 
                    (current_state == FUNCTION_SET_III);

assign str_100ms = (current_state == POWER_ON);    
    

endmodule

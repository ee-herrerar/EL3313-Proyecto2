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
    output logic rw,
    
    output str_60us, 
    output str_5ms, 
    output str_200us, 
    output str_100ms,
    
    // Salidas hacia la interfaz del periférico
    output logic [1:0]  addr_o,
    output logic write_enable_o,
    output logic [31:0] wdata_o

    );

// STATE DECLARATION -----------------------------------------------------------------

typedef enum logic [4:0] {
           POWER_ON = 5'b00000,
           FUNCTION_SET_I = 5'b00001,
           FUNCTION_SET_II = 5'b00010,
           FUNCTION_SET_III = 5'b00011,
           FUNCTION_SET_CONFIGURATION = 5'b00100,
           DISPLAY_OFF = 5'b00101,
           CLEAR = 5'b00110,
           ENTRY_MODE_SET = 5'b00111,
           DISPLAY_ON = 5'b01000,
           WAIT_ = 5'b01001,
           INC_RAN = 5'b01010,
           WRITE_INC = 5'b01011,
           SET_ADDRESS = 5'b01100,
           WRITE_RAN = 5'b01101,
           CLEAR_WRITE = 5'b01110,
           CONTROL_REG_1 = 5'b01111,
           CONTROL_REG_2 = 5'b10000,
           CONTROL_REG_3 = 5'b10001,
           CONTROL_REG_4 = 5'b10010,
           BUSY_CLEAR    = 5'b10011
} state_t;      


// PORT/SIGNAL DECLARATION -----------------------------------------------------------

state_t current_state, next_state;

logic [31:0] data_reg;
logic [31:0] control_reg;

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

    control_reg = 32'd0;
    data_reg = 32'd0;
    
    // Valores por defecto para evitar latches
    write_enable_o = 1'b0;
    addr_o = 2'b00;
    wdata_o = 32'd0;

    case (current_state)

    // ETAPA DE INICIALIZACIÓN DEL LCD................................................
    // Tiempo de espera de 100ms para que el LCD se estabilice después del encendido.
        POWER_ON:  begin
        control_reg [8]= 1'b1;                   // Indica que el módulo está ocupado durante la inicialización.                                                 // La inicialización no ha terminado.                                                 
            if (flag_100ms)
                next_state = CONTROL_REG_1;
            else
                next_state = POWER_ON;
        end
        CONTROL_REG_1: begin
            control_reg [1]= 1'b0; // Modo de escritura
            control_reg [8]= 1'b0; 
            addr_o = 2'b00;
            wdata_o = control_reg;
            write_enable_o = 1'b1;
            next_state = FUNCTION_SET_I;
        end
    // Inicialización del LCD por instrucciones según el datasheet del HD44780.
        FUNCTION_SET_I: begin
            data_reg [7:0]= 8'b00110000;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_5ms)
                next_state = FUNCTION_SET_II;
        end
        FUNCTION_SET_II: begin
            data_reg [7:0] = 8'b00110000;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_200us)
                next_state = FUNCTION_SET_III;
        end
        FUNCTION_SET_III: begin
            data_reg [7:0] = 8'b00110000;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_200us)
                next_state = FUNCTION_SET_CONFIGURATION;
        end
    // Configuracion del LCD: 8 bits, 2 líneas, fuente 5x8.
        FUNCTION_SET_CONFIGURATION: begin
            data_reg [7:0] = 8'b00111000;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = DISPLAY_OFF;
        end
        DISPLAY_OFF: begin
            data_reg [7:0] = 8'b00001000;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = CLEAR;
        end
        CLEAR: begin
            data_reg [7:0] = 8'b00000001;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_5ms)
                next_state = ENTRY_MODE_SET;
        end
    // Configuración del modo de entrada: incremento, sin desplazamiento de pantalla.            
        ENTRY_MODE_SET: begin
            data_reg [7:0] = 8'b00000110;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = DISPLAY_ON;
        end
        DISPLAY_ON: begin
            data_reg [7:0] = 8'b00001100;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = WAIT_;
        end

    // FIN DE LA ETAPA DE INICIALIZACIÓN DEL LCD......................................
    // Espera de comandos del módulo externo.
        WAIT_: begin                          
            control_reg [8]= 1'b0;                            // Indica que el módulo está listo para recibir comandos.
            control_reg [0]= start;               
            control_reg [2]= clear_write;                  
            addr_o = 2'b00;
            wdata_o = control_reg;                                    // Indica que la operación ha terminado.
            done = 1'b1;
            if (start)
                next_state = INC_RAN;
            else if (clear_write)
                next_state = CLEAR_WRITE;
            else
                next_state = WAIT_;
        end

    // Se decide si la escritura sera en modo incremento o en modo direccionamiento aleatorio.
        INC_RAN: begin
            control_reg [8]= 1'b1;
            addr_o = 2'b00;
            wdata_o = control_reg; 
            if (mode)
                next_state = CONTROL_REG_2;
            else
                next_state = CONTROL_REG_3;
        end
        CONTROL_REG_2: begin
            control_reg [1]= 1'b1; 
            addr_o = 2'b00;
            wdata_o = control_reg;
            write_enable_o = 1'b1;
            next_state = WRITE_INC;
        end
    // Escritura de datos en modo incremento.
        WRITE_INC: begin
            data_reg [7:0] = data_byte;
            addr_o = 2'b01;
            wdata_o  = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = WAIT_;
        end

        CONTROL_REG_3: begin
            control_reg [1]= 1'b0;
            addr_o = 2'b00;
            wdata_o = control_reg;
            write_enable_o = 1'b1;
            next_state = SET_ADDRESS;    
        end   
    // Escritura de datos en modo direccionamiento aleatorio.
        SET_ADDRESS: begin
            data_reg [7:0] = (coincount > 0) ? (8'h80 | direccion[coincount - 1]) : 8'h80;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                next_state = CONTROL_REG_4;
        end

        CONTROL_REG_4: begin
            control_reg [1]= 1'b1;
            addr_o = 2'b00;
            wdata_o = control_reg;
            write_enable_o = 1'b1;
            next_state = WRITE_RAN;   
        end

        WRITE_RAN: begin
            data_reg [7:0] = data_byte;
            addr_o = 2'b01;
            wdata_o = data_reg;
            write_enable_o = 1'b1;
            if (flag_60us)
                if (coincount > 4'b1) 
                    next_state = SET_ADDRESS;
                else
                    next_state = WAIT_;
        end
        
        BUSY_CLEAR: begin
            control_reg [8]= 1'b1;
            addr_o = 2'b00;
            wdata_o = control_reg; 
        end

        CLEAR_WRITE: begin        
            data_reg [7:0] = 8'b00000001;
            addr_o = 2'b01;
            wdata_o  = data_reg;
            write_enable_o = 1'b1;
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

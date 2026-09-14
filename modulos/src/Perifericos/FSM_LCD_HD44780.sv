`timescale 1ns / 1ps

module FSM_LCD_HD44780(
    input  logic clk,
    input  logic reset,

    input  logic flag_100ms,
    input  logic flag_5ms,
    input  logic flag_200us,
    input  logic flag_60us,

    input  logic start,
    input  logic [7:0] data_byte,
    input  logic [11:0] coincidencias,
    input  logic mode,          // 1: Incremental, 0: Direccionamiento por coincidencias
    input  logic clear_write,

    output logic done,
    output logic busy,
    output logic rs,
    output logic rw,
    output logic str_60us,
    output logic str_5ms,
    output logic str_200us,
    output logic str_100ms,
    output logic [7:0] temp_reg
);

typedef enum logic [3:0] {
    POWER_ON                   = 4'b0000,
    FUNCTION_SET_I             = 4'b0001,
    FUNCTION_SET_II            = 4'b0010,
    FUNCTION_SET_III           = 4'b0011,
    FUNCTION_SET_CONFIGURATION = 4'b0100,
    DISPLAY_OFF                = 4'b0101,
    CLEAR                      = 4'b0110,
    ENTRY_MODE_SET             = 4'b0111,
    DISPLAY_ON                 = 4'b1000,
    WAIT_                      = 4'b1001,
    INC_RAN                    = 4'b1010,
    WRITE_INC                  = 4'b1011,
    SET_ADDRESS                = 4'b1100,
    WRITE_RAN                  = 4'b1101,
    CLEAR_WRITE                = 4'b1110
} state_t;

state_t current_state, next_state;

localparam logic [6:0] LCD_BASE_ADDR = 7'h00;

logic [11:0] coincidencias_reg;
logic [3:0] posicion_reg;
logic [3:0] posicion_sel;
logic [7:0] data_reg;
logic mode_reg;
logic posicion_valida;
logic [11:0] mascara_restante;

assign rw = 1'b0;

always_comb begin
    posicion_sel = 4'd0;
    posicion_valida = 1'b0;

    for (int i = 0; i < 12; i++) begin
        if (coincidencias_reg[i] && !posicion_valida) begin
            posicion_sel = i[3:0];
            posicion_valida = 1'b1;
        end
    end
end

always_comb begin
    mascara_restante = coincidencias_reg;

    if (posicion_reg < 12)
        mascara_restante[posicion_reg] = 1'b0;
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state      <= POWER_ON;
        coincidencias_reg  <= 12'b0;
        posicion_reg       <= 4'd0;
        data_reg           <= 8'b0;
        mode_reg           <= 1'b0;
    end
    else begin
        current_state <= next_state;

        if (current_state == WAIT_ && start) begin
            coincidencias_reg <= coincidencias;
            data_reg          <= data_byte;
            mode_reg          <= mode;
        end

        if (current_state == SET_ADDRESS && flag_60us)
            posicion_reg <= posicion_sel;

        if (current_state == WRITE_RAN && flag_60us)
            coincidencias_reg[posicion_reg] <= 1'b0;
    end
end

always_comb begin
    next_state = current_state;

    busy = 1'b1;
    done = 1'b0;
    rs = 1'b0;
    temp_reg = 8'b0;

    case (current_state)

        POWER_ON: begin
            if (flag_100ms)
                next_state = FUNCTION_SET_I;
        end

        FUNCTION_SET_I: begin
            temp_reg = 8'b00110000;
            if (flag_5ms)
                next_state = FUNCTION_SET_II;
        end

        FUNCTION_SET_II: begin
            temp_reg = 8'b00110000;
            if (flag_200us)
                next_state = FUNCTION_SET_III;
        end

        FUNCTION_SET_III: begin
            temp_reg = 8'b00110000;
            if (flag_200us)
                next_state = FUNCTION_SET_CONFIGURATION;
        end

        FUNCTION_SET_CONFIGURATION: begin
            temp_reg = 8'b00111000;
            if (flag_60us)
                next_state = DISPLAY_OFF;
        end

        DISPLAY_OFF: begin
            temp_reg = 8'b00001000;
            if (flag_60us)
                next_state = CLEAR;
        end

        CLEAR: begin
            temp_reg = 8'b00000001;
            if (flag_5ms)
                next_state = ENTRY_MODE_SET;
        end

        ENTRY_MODE_SET: begin
            temp_reg = 8'b00000110;
            if (flag_60us)
                next_state = DISPLAY_ON;
        end

        DISPLAY_ON: begin
            temp_reg = 8'b00001100;
            if (flag_60us)
                next_state = WAIT_;
        end

        WAIT_: begin
            busy = 1'b0;

            if (clear_write)
                next_state = CLEAR_WRITE;
            else if (start)
                next_state = INC_RAN;
        end

        INC_RAN: begin
            if (mode_reg)
                next_state = WRITE_INC;
            else if (|coincidencias_reg)
                next_state = SET_ADDRESS;
            else begin
                done = 1'b1;
                next_state = WAIT_;
            end
        end

        WRITE_INC: begin
            rs = 1'b1;
            temp_reg = data_reg;

            if (flag_60us) begin
                done = 1'b1;
                next_state = WAIT_;
            end
        end

        SET_ADDRESS: begin
            rs = 1'b0;
            temp_reg = {1'b1, LCD_BASE_ADDR + posicion_sel};

            if (flag_60us)
                next_state = WRITE_RAN;
        end

        WRITE_RAN: begin
            rs = 1'b1;
            temp_reg = data_reg;

            if (flag_60us) begin
                if (|mascara_restante)
                    next_state = SET_ADDRESS;
                else begin
                    done = 1'b1;
                    next_state = WAIT_;
                end
            end
        end

        CLEAR_WRITE: begin
            rs = 1'b0;
            temp_reg = 8'b00000001;

            if (flag_5ms) begin
                done = 1'b1;
                next_state = WAIT_;
            end
        end

        default: begin
            next_state = POWER_ON;
        end
    endcase
end

assign str_60us =
    (current_state == WRITE_INC)                  ||
    (current_state == WRITE_RAN)                  ||
    (current_state == FUNCTION_SET_CONFIGURATION) ||
    (current_state == DISPLAY_OFF)                ||
    (current_state == DISPLAY_ON)                 ||
    (current_state == ENTRY_MODE_SET)             ||
    (current_state == SET_ADDRESS);

assign str_5ms =
    (current_state == CLEAR)          ||
    (current_state == FUNCTION_SET_I) ||
    (current_state == CLEAR_WRITE);

assign str_200us =
    (current_state == FUNCTION_SET_II) ||
    (current_state == FUNCTION_SET_III);

assign str_100ms = (current_state == POWER_ON);

endmodule
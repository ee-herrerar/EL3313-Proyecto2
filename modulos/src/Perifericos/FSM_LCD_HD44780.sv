`timescale 1ns / 1ps

module FSM_LCD_HD44780 (
    input  logic       clk,
    input  logic       reset,

    input  logic       flag_100ms,
    input  logic       flag_5ms,
    input  logic       flag_200us,
    input  logic       flag_60us,

    input  logic       start,
    input  logic       rs_write,
    input  logic       clear_write,
    input  logic       home_write,
    input  logic [7:0] data_byte,

    output logic       done,
    output logic       busy,
    output logic       rs,
    output logic       rw,

    output logic       str_100ms,
    output logic       str_5ms,
    output logic       str_200us,
    output logic       str_60us,

    output logic [7:0] temp_reg
);

typedef enum logic [4:0] {
    POWER_ON,
    FUNCTION_SET_I,
    WAIT_5MS_I,
    FUNCTION_SET_II,
    WAIT_200US_II,
    FUNCTION_SET_III,
    WAIT_200US_III,
    FUNCTION_SET_CONFIGURATION,
    DISPLAY_OFF,
    CLEAR_INIT,
    WAIT_CLEAR_INIT,
    ENTRY_MODE_SET,
    DISPLAY_ON,
    WAIT_,
    USER_WRITE,
    CLEAR_WRITE,
    WAIT_CLEAR_WRITE,
    HOME_WRITE,
    WAIT_HOME_WRITE,
    DONE_
} state_t;

state_t state;

logic [7:0] data_reg;
logic rs_reg;

always_comb begin
    done      = 1'b0;
    busy      = 1'b1;
    rs        = 1'b0;
    rw        = 1'b0;

    str_100ms = 1'b0;
    str_5ms   = 1'b0;
    str_200us = 1'b0;
    str_60us  = 1'b0;

    temp_reg  = 8'h00;

    case (state)

        POWER_ON:
            str_100ms = 1'b1;

        FUNCTION_SET_I: begin
            temp_reg = 8'h38;
            str_60us = 1'b1;
        end

        WAIT_5MS_I:
            str_5ms = 1'b1;

        FUNCTION_SET_II: begin
            temp_reg = 8'h38;
            str_60us = 1'b1;
        end

        WAIT_200US_II:
            str_200us = 1'b1;

        FUNCTION_SET_III: begin
            temp_reg = 8'h38;
            str_60us = 1'b1;
        end

        WAIT_200US_III:
            str_200us = 1'b1;

        FUNCTION_SET_CONFIGURATION: begin
            temp_reg = 8'h38;
            str_60us = 1'b1;
        end

        DISPLAY_OFF: begin
            temp_reg = 8'h08;
            str_60us = 1'b1;
        end

        CLEAR_INIT: begin
            temp_reg = 8'h01;
            str_60us = 1'b1;
        end

        WAIT_CLEAR_INIT:
            str_5ms = 1'b1;

        ENTRY_MODE_SET: begin
            temp_reg = 8'h06;
            str_60us = 1'b1;
        end

        DISPLAY_ON: begin
            temp_reg = 8'h0C;
            str_60us = 1'b1;
        end

        WAIT_: begin
            busy = 1'b0;
        end

        USER_WRITE: begin
            rs       = rs_reg;
            temp_reg = data_reg;
            str_60us = 1'b1;
        end

        CLEAR_WRITE: begin
            rs       = 1'b0;
            temp_reg = 8'h01;
            str_60us = 1'b1;
        end

        WAIT_CLEAR_WRITE:
            str_5ms = 1'b1;

        HOME_WRITE: begin
            rs       = 1'b0;
            temp_reg = 8'h02;
            str_60us = 1'b1;
        end

        WAIT_HOME_WRITE:
            str_5ms = 1'b1;

        DONE_: begin
            busy = 1'b0;
            done = 1'b1;
        end

        default:
            busy = 1'b1;

    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state    <= POWER_ON;
        data_reg <= 8'h00;
        rs_reg   <= 1'b0;
    end
    else begin
        case (state)

            POWER_ON:
                if (flag_100ms)
                    state <= FUNCTION_SET_I;

            FUNCTION_SET_I:
                if (flag_60us)
                    state <= WAIT_5MS_I;

            WAIT_5MS_I:
                if (flag_5ms)
                    state <= FUNCTION_SET_II;

            FUNCTION_SET_II:
                if (flag_60us)
                    state <= WAIT_200US_II;

            WAIT_200US_II:
                if (flag_200us)
                    state <= FUNCTION_SET_III;

            FUNCTION_SET_III:
                if (flag_60us)
                    state <= WAIT_200US_III;

            WAIT_200US_III:
                if (flag_200us)
                    state <= FUNCTION_SET_CONFIGURATION;

            FUNCTION_SET_CONFIGURATION:
                if (flag_60us)
                    state <= DISPLAY_OFF;

            DISPLAY_OFF:
                if (flag_60us)
                    state <= CLEAR_INIT;

            CLEAR_INIT:
                if (flag_60us)
                    state <= WAIT_CLEAR_INIT;

            WAIT_CLEAR_INIT:
                if (flag_5ms)
                    state <= ENTRY_MODE_SET;

            ENTRY_MODE_SET:
                if (flag_60us)
                    state <= DISPLAY_ON;

            DISPLAY_ON:
                if (flag_60us)
                    state <= WAIT_;

            WAIT_: begin
                if (clear_write)
                    state <= CLEAR_WRITE;

                else if (home_write)
                    state <= HOME_WRITE;

                else if (start) begin
                    data_reg <= data_byte;
                    rs_reg   <= rs_write;
                    state    <= USER_WRITE;
                end
            end

            USER_WRITE:
                if (flag_60us)
                    state <= DONE_;

            CLEAR_WRITE:
                if (flag_60us)
                    state <= WAIT_CLEAR_WRITE;

            WAIT_CLEAR_WRITE:
                if (flag_5ms)
                    state <= DONE_;

            HOME_WRITE:
                if (flag_60us)
                    state <= WAIT_HOME_WRITE;

            WAIT_HOME_WRITE:
                if (flag_5ms)
                    state <= DONE_;

            DONE_:
                state <= WAIT_;

            default:
                state <= POWER_ON;

        endcase
    end
end

endmodule
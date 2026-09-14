`timescale 1ns / 1ps

module RESULTADO_LCD (
    input  logic       clk,
    input  logic       reset,
    input  logic       start_write,
    input  logic       GameWin,
    input  logic       GameLose,
    input  logic       busy,

    output logic       start,
    output logic [7:0] data_byte,
    output logic       mode,
    output logic       clear_write,
    output logic       done
);

typedef enum logic [2:0] {
    IDLE,
    SEND_CLEAR,
    WAIT_CLEAR_BUSY,
    WAIT_CLEAR_DONE,
    SEND_CHAR,
    WAIT_CHAR_BUSY,
    WAIT_CHAR_DONE,
    FINISH
} state_t;

state_t state;

logic resultado_win;
logic [3:0] char_index;
logic [3:0] message_length;

assign mode = 1'b1;

always_comb begin
    if (resultado_win)
        message_length = 4'd7;
    else
        message_length = 4'd8;

    if (resultado_win) begin
        case (char_index)
            4'd0: data_byte = "G";
            4'd1: data_byte = "A";
            4'd2: data_byte = "N";
            4'd3: data_byte = "A";
            4'd4: data_byte = "S";
            4'd5: data_byte = "T";
            4'd6: data_byte = "E";
            default: data_byte = 8'h20;
        endcase
    end
    else begin
        case (char_index)
            4'd0: data_byte = "P";
            4'd1: data_byte = "E";
            4'd2: data_byte = "R";
            4'd3: data_byte = "D";
            4'd4: data_byte = "I";
            4'd5: data_byte = "S";
            4'd6: data_byte = "T";
            4'd7: data_byte = "E";
            default: data_byte = 8'h20;
        endcase
    end
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state         <= IDLE;
        resultado_win <= 1'b0;
        char_index    <= 4'd0;
        start         <= 1'b0;
        clear_write   <= 1'b0;
        done          <= 1'b0;
    end
    else begin
        start       <= 1'b0;
        clear_write <= 1'b0;
        done        <= 1'b0;

        case (state)

            IDLE: begin
                if (start_write && (GameWin || GameLose)) begin
                    resultado_win <= GameWin;
                    char_index    <= 4'd0;
                    state         <= SEND_CLEAR;
                end
            end

            SEND_CLEAR: begin
                if (!busy) begin
                    clear_write <= 1'b1;
                    state       <= WAIT_CLEAR_BUSY;
                end
            end

            WAIT_CLEAR_BUSY: begin
                if (busy)
                    state <= WAIT_CLEAR_DONE;
            end

            WAIT_CLEAR_DONE: begin
                if (!busy)
                    state <= SEND_CHAR;
            end

            SEND_CHAR: begin
                if (!busy) begin
                    start <= 1'b1;
                    state <= WAIT_CHAR_BUSY;
                end
            end

            WAIT_CHAR_BUSY: begin
                if (busy)
                    state <= WAIT_CHAR_DONE;
            end

            WAIT_CHAR_DONE: begin
                if (!busy) begin
                    if (char_index == message_length - 1'b1)
                        state <= FINISH;
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= SEND_CHAR;
                    end
                end
            end

            FINISH: begin
                done  <= 1'b1;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule
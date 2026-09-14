`timescale 1ns / 1ps

module DIFICULTAD_LCD (
    input  logic       clk,
    input  logic       reset,
    input  logic       start_write,
    input  logic       hardmode,
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

logic       hardmode_reg;
logic [2:0] char_index;
logic [2:0] message_length;

assign mode = 1'b1;

always_comb begin
    if (hardmode_reg)
        message_length = 3'd7;
    else
        message_length = 3'd5;

    if (!hardmode_reg) begin
        case (char_index)
            3'd0: data_byte = "F";
            3'd1: data_byte = "A";
            3'd2: data_byte = "C";
            3'd3: data_byte = "I";
            3'd4: data_byte = "L";
            default: data_byte = 8'h20;
        endcase
    end
    else begin
        case (char_index)
            3'd0: data_byte = "D";
            3'd1: data_byte = "I";
            3'd2: data_byte = "F";
            3'd3: data_byte = "I";
            3'd4: data_byte = "C";
            3'd5: data_byte = "I";
            3'd6: data_byte = "L";
            default: data_byte = 8'h20;
        endcase
    end
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state        <= IDLE;
        hardmode_reg <= 1'b0;
        char_index   <= 3'd0;
        start        <= 1'b0;
        clear_write  <= 1'b0;
        done         <= 1'b0;
    end
    else begin
        start       <= 1'b0;
        clear_write <= 1'b0;
        done        <= 1'b0;

        case (state)

            IDLE: begin
                if (start_write) begin
                    hardmode_reg <= hardmode;
                    char_index   <= 3'd0;
                    state        <= SEND_CLEAR;
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
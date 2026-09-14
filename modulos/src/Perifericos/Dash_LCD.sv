`timescale 1ns / 1ps

module Dash_LCD(
    input  logic       clk,
    input  logic       reset,
    input  logic       start_write,
    input  logic [3:0] longitud,
    input  logic       busy,

    output logic       start,
    output logic [7:0] data_byte,
    output logic       mode,
    output logic       done
);

localparam logic [7:0] ASCII_DASH = 8'h2D;

typedef enum logic [2:0] {
    IDLE,
    SEND_DASH,
    WAIT_BUSY,
    WAIT_DONE,
    FINISH
} state_t;

state_t state;

logic [3:0] dash_count;
logic [3:0] length;

assign mode = 1'b1;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state      <= IDLE;
        dash_count <= 4'd0;
        length     <= 4'd0;
        start      <= 1'b0;
        data_byte  <= ASCII_DASH;
        done       <= 1'b0;
    end
    else begin
        start <= 1'b0;
        done  <= 1'b0;

        case (state)

            IDLE: begin
                if (start_write) begin
                    length     <= longitud;
                    dash_count <= 4'd0;
                    data_byte  <= ASCII_DASH;

                    if (longitud == 4'd0)
                        state <= FINISH;
                    else
                        state <= SEND_DASH;
                end
            end

            SEND_DASH: begin
                if (!busy) begin
                    start <= 1'b1;
                    state <= WAIT_BUSY;
                end
            end

            WAIT_BUSY: begin
                if (busy)
                    state <= WAIT_DONE;
            end

            WAIT_DONE: begin
                if (!busy) begin
                    dash_count <= dash_count + 1'b1;

                    if (dash_count + 1'b1 >= length)
                        state <= FINISH;
                    else
                        state <= SEND_DASH;
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
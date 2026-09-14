module UART_MENSAJE (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic [2:0] mensaje_id,

    input  logic       tx_busy,
    input  logic       tx_done,

    output logic       tx_start,
    output logic [7:0] tx_data,
    output logic       busy,
    output logic       done
);

typedef enum logic [1:0] {
    IDLE,
    SEND,
    WAIT_TX,
    FINISH
} state_t;

state_t state;

logic [2:0] mensaje_reg;
logic [3:0] char_index;
logic [3:0] mensaje_length;

function automatic logic [3:0] largo_mensaje(input logic [2:0] id);
    begin
        case (id)
            3'd0: largo_mensaje = 4'd7;
            3'd1: largo_mensaje = 4'd9;
            3'd2: largo_mensaje = 4'd10;
            3'd3: largo_mensaje = 4'd12;
            3'd4: largo_mensaje = 4'd9;
            3'd5: largo_mensaje = 4'd10;
            default: largo_mensaje = 4'd0;
        endcase
    end
endfunction

function automatic logic [7:0] caracter_mensaje(
    input logic [2:0] id,
    input logic [3:0] index
);
    begin
        caracter_mensaje = 8'h00;

        case (id)

            3'd0: begin
                case (index)
                    0: caracter_mensaje = "F";
                    1: caracter_mensaje = "A";
                    2: caracter_mensaje = "C";
                    3: caracter_mensaje = "I";
                    4: caracter_mensaje = "L";
                    5: caracter_mensaje = 8'h0D;
                    6: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            3'd1: begin
                case (index)
                    0: caracter_mensaje = "D";
                    1: caracter_mensaje = "I";
                    2: caracter_mensaje = "F";
                    3: caracter_mensaje = "I";
                    4: caracter_mensaje = "C";
                    5: caracter_mensaje = "I";
                    6: caracter_mensaje = "L";
                    7: caracter_mensaje = 8'h0D;
                    8: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            3'd2: begin
                case (index)
                    0: caracter_mensaje = "C";
                    1: caracter_mensaje = "O";
                    2: caracter_mensaje = "R";
                    3: caracter_mensaje = "R";
                    4: caracter_mensaje = "E";
                    5: caracter_mensaje = "C";
                    6: caracter_mensaje = "T";
                    7: caracter_mensaje = "A";
                    8: caracter_mensaje = 8'h0D;
                    9: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            3'd3: begin
                case (index)
                    0:  caracter_mensaje = "I";
                    1:  caracter_mensaje = "N";
                    2:  caracter_mensaje = "C";
                    3:  caracter_mensaje = "O";
                    4:  caracter_mensaje = "R";
                    5:  caracter_mensaje = "R";
                    6:  caracter_mensaje = "E";
                    7:  caracter_mensaje = "C";
                    8:  caracter_mensaje = "T";
                    9:  caracter_mensaje = "A";
                    10: caracter_mensaje = 8'h0D;
                    11: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            3'd4: begin
                case (index)
                    0: caracter_mensaje = "G";
                    1: caracter_mensaje = "A";
                    2: caracter_mensaje = "N";
                    3: caracter_mensaje = "A";
                    4: caracter_mensaje = "S";
                    5: caracter_mensaje = "T";
                    6: caracter_mensaje = "E";
                    7: caracter_mensaje = 8'h0D;
                    8: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            3'd5: begin
                case (index)
                    0: caracter_mensaje = "P";
                    1: caracter_mensaje = "E";
                    2: caracter_mensaje = "R";
                    3: caracter_mensaje = "D";
                    4: caracter_mensaje = "I";
                    5: caracter_mensaje = "S";
                    6: caracter_mensaje = "T";
                    7: caracter_mensaje = "E";
                    8: caracter_mensaje = 8'h0D;
                    9: caracter_mensaje = 8'h0A;
                    default: caracter_mensaje = 8'h00;
                endcase
            end

            default: caracter_mensaje = 8'h00;
        endcase
    end
endfunction

assign mensaje_length = largo_mensaje(mensaje_reg);
assign tx_data = caracter_mensaje(mensaje_reg, char_index);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state       <= IDLE;
        mensaje_reg <= 3'd0;
        char_index  <= 4'd0;
        tx_start    <= 1'b0;
        busy        <= 1'b0;
        done        <= 1'b0;
    end
    else begin
        tx_start <= 1'b0;
        done     <= 1'b0;

        case (state)

            IDLE: begin
                busy <= 1'b0;

                if (start) begin
                    mensaje_reg <= mensaje_id;
                    char_index  <= 4'd0;
                    busy        <= 1'b1;
                    state       <= SEND;
                end
            end

            SEND: begin
                busy <= 1'b1;

                if (!tx_busy) begin
                    tx_start <= 1'b1;
                    state    <= WAIT_TX;
                end
            end

            WAIT_TX: begin
                busy <= 1'b1;

                if (tx_done) begin
                    if (char_index + 1'b1 >= mensaje_length)
                        state <= FINISH;
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= SEND;
                    end
                end
            end

            FINISH: begin
                busy <= 1'b0;
                done <= 1'b1;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule
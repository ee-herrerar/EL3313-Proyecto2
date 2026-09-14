`timescale 1ns / 1ps

module LETRAS_LCD (
    input  logic        clk,
    input  logic        reset,
    input  logic [95:0] PalabraActual,
    input  logic [11:0] LetrasReveladas,
    input  logic        busy,

    output logic        start,
    output logic [7:0]  data_byte,
    output logic [11:0] coincidencias,
    output logic        mode,
    output logic        done
);

typedef enum logic [1:0] {
    IDLE,
    WAIT_BUSY,
    WAIT_DONE,
    FINISH
} state_t;

state_t state;

logic [11:0] reveladas_prev;
logic [11:0] nuevas_posiciones;
logic [11:0] mascara_sel;
logic [7:0]  letra_sel;
logic        letra_valida;

assign mode = 1'b0;

always_comb begin
    nuevas_posiciones = LetrasReveladas & ~reveladas_prev;

    letra_sel    = 8'h00;
    letra_valida = 1'b0;
    mascara_sel  = 12'b0;

    for (int i = 0; i < 12; i = i + 1) begin
        if (nuevas_posiciones[i] && !letra_valida) begin
            letra_sel    = PalabraActual[95 - i*8 -: 8];
            letra_valida = 1'b1;
        end
    end

    if (letra_valida) begin
        for (int i = 0; i < 12; i = i + 1) begin
            if (nuevas_posiciones[i] &&
                (PalabraActual[95 - i*8 -: 8] == letra_sel))
                mascara_sel[i] = 1'b1;
        end
    end
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state           <= IDLE;
        reveladas_prev  <= 12'b0;
        start           <= 1'b0;
        data_byte       <= 8'h00;
        coincidencias   <= 12'b0;
        done            <= 1'b0;
    end
    else begin
        start <= 1'b0;
        done  <= 1'b0;

        case (state)

            IDLE: begin
                if (LetrasReveladas == 12'b0)
                    reveladas_prev <= 12'b0;

                else if ((|nuevas_posiciones) && !busy) begin
                    data_byte      <= letra_sel;
                    coincidencias  <= mascara_sel;
                    reveladas_prev <= reveladas_prev | mascara_sel;
                    start          <= 1'b1;
                    state          <= WAIT_BUSY;
                end
            end

            WAIT_BUSY: begin
                if (busy)
                    state <= WAIT_DONE;
            end

            WAIT_DONE: begin
                if (!busy)
                    state <= FINISH;
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
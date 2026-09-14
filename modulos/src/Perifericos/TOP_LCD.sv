`timescale 1ns / 1ps

module TOP_LCD (
    input  logic        clk,
    input  logic        reset,
    input  logic        hardmode,
    input  logic        GameOn,
    input  logic        GameWin,
    input  logic        GameLose,
    input  logic [95:0] PalabraActual,
    input  logic [4:0]  LargoPalabra,
    input  logic [11:0] LetrasReveladas,

    output logic        lcd_rs,
    output logic        lcd_rw,
    output logic        lcd_e,
    output logic [7:0]  lcd_data
);

typedef enum logic [3:0] {
    WAIT_INIT,
    START_DIFICULTAD,
    DIFICULTAD,
    ESPERA_JUEGO,
    CLEAR_JUEGO,
    WAIT_CLEAR_BUSY,
    WAIT_CLEAR_DONE,
    START_DASH,
    DASH,
    JUEGO,
    START_RESULTADO,
    RESULTADO,
    WAIT_FIN_JUEGO
} state_t;

state_t state;

logic flag_100ms, flag_5ms, flag_200us, flag_60us;
logic str_100ms, str_5ms, str_200us, str_60us;

logic lcd_start;
logic [7:0] lcd_data_in;
logic [11:0] lcd_coincidencias;
logic lcd_mode;
logic lcd_clear;
logic lcd_busy;
logic lcd_done;
logic [7:0] temp_reg;

logic dif_start_write, dif_start, dif_mode, dif_clear, dif_done;
logic [7:0] dif_data;

logic dash_start_write, dash_start, dash_mode, dash_done;
logic [7:0] dash_data;

logic letras_start, letras_mode, letras_done;
logic [7:0] letras_data;
logic [11:0] letras_coincidencias;

logic resultado_start_write, resultado_start;
logic resultado_mode, resultado_clear, resultado_done;
logic [7:0] resultado_data;

logic hardmode_prev;
logic dificultad_pending;
logic game_pending;
logic result_pending;
logic result_win;
logic result_lose;

counter_100ms c100 (
    .clk(clk),
    .reset(reset),
    .active(str_100ms),
    .flag_100ms(flag_100ms)
);

counter_5ms c5 (
    .clk(clk),
    .reset(reset),
    .active(str_5ms),
    .flag_5ms(flag_5ms)
);

counter_200us c200 (
    .clk(clk),
    .reset(reset),
    .active(str_200us),
    .flag_200us(flag_200us)
);

counter_enable cen (
    .clk(clk),
    .reset(reset),
    .active(str_60us),
    .enable(lcd_e),
    .flag_60us(flag_60us)
);

DIFICULTAD_LCD dificultad_inst (
    .clk(clk),
    .reset(reset),
    .start_write(dif_start_write),
    .hardmode(hardmode),
    .busy((state == DIFICULTAD) ? lcd_busy : 1'b1),
    .start(dif_start),
    .data_byte(dif_data),
    .mode(dif_mode),
    .clear_write(dif_clear),
    .done(dif_done)
);

Dash_LCD dash_inst (
    .clk(clk),
    .reset(reset),
    .start_write(dash_start_write),
    .longitud(LargoPalabra),
    .busy((state == DASH) ? lcd_busy : 1'b1),
    .start(dash_start),
    .data_byte(dash_data),
    .mode(dash_mode),
    .done(dash_done)
);

LETRAS_LCD letras_inst (
    .clk(clk),
    .reset(reset),
    .PalabraActual(PalabraActual),
    .LetrasReveladas(LetrasReveladas),
    .busy((state == JUEGO) ? lcd_busy : 1'b1),
    .start(letras_start),
    .data_byte(letras_data),
    .coincidencias(letras_coincidencias),
    .mode(letras_mode),
    .done(letras_done)
);

RESULTADO_LCD resultado_inst (
    .clk(clk),
    .reset(reset),
    .start_write(resultado_start_write),
    .GameWin(result_win),
    .GameLose(result_lose),
    .busy((state == RESULTADO) ? lcd_busy : 1'b1),
    .start(resultado_start),
    .data_byte(resultado_data),
    .mode(resultado_mode),
    .clear_write(resultado_clear),
    .done(resultado_done)
);

FSM_LCD_HD44780 lcd_inst (
    .clk(clk),
    .reset(reset),
    .flag_100ms(flag_100ms),
    .flag_5ms(flag_5ms),
    .flag_200us(flag_200us),
    .flag_60us(flag_60us),
    .start(lcd_start),
    .data_byte(lcd_data_in),
    .coincidencias(lcd_coincidencias),
    .mode(lcd_mode),
    .clear_write(lcd_clear),
    .done(lcd_done),
    .busy(lcd_busy),
    .rs(lcd_rs),
    .rw(lcd_rw),
    .str_100ms(str_100ms),
    .str_5ms(str_5ms),
    .str_200us(str_200us),
    .str_60us(str_60us),
    .temp_reg(temp_reg)
);

assign lcd_data = temp_reg;

always_comb begin
    lcd_start         = 1'b0;
    lcd_data_in       = 8'h00;
    lcd_coincidencias = 12'b0;
    lcd_mode          = 1'b1;
    lcd_clear         = 1'b0;

    case (state)
        DIFICULTAD: begin
            lcd_start   = dif_start;
            lcd_data_in = dif_data;
            lcd_mode    = dif_mode;
            lcd_clear   = dif_clear;
        end

        CLEAR_JUEGO:
            lcd_clear = 1'b1;

        DASH: begin
            lcd_start   = dash_start;
            lcd_data_in = dash_data;
            lcd_mode    = dash_mode;
        end

        JUEGO: begin
            lcd_start         = letras_start;
            lcd_data_in       = letras_data;
            lcd_coincidencias = letras_coincidencias;
            lcd_mode          = letras_mode;
        end

        RESULTADO: begin
            lcd_start   = resultado_start;
            lcd_data_in = resultado_data;
            lcd_mode    = resultado_mode;
            lcd_clear   = resultado_clear;
        end

        default: begin
            lcd_start         = 1'b0;
            lcd_data_in       = 8'h00;
            lcd_coincidencias = 12'b0;
            lcd_mode          = 1'b1;
            lcd_clear         = 1'b0;
        end
    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state                 <= WAIT_INIT;
        dif_start_write       <= 1'b0;
        dash_start_write      <= 1'b0;
        resultado_start_write <= 1'b0;
        hardmode_prev         <= 1'b0;
        dificultad_pending    <= 1'b0;
        game_pending          <= 1'b0;
        result_pending        <= 1'b0;
        result_win            <= 1'b0;
        result_lose           <= 1'b0;
    end
    else begin
        dif_start_write       <= 1'b0;
        dash_start_write      <= 1'b0;
        resultado_start_write <= 1'b0;

        if (hardmode != hardmode_prev) begin
            hardmode_prev      <= hardmode;
            dificultad_pending <= 1'b1;
        end

        if (GameOn)
            game_pending <= 1'b1;

        if (GameWin || GameLose) begin
            result_pending <= 1'b1;
            result_win     <= GameWin;
            result_lose    <= GameLose;
        end

        case (state)

            WAIT_INIT: begin
                if (!lcd_busy)
                    state <= START_DIFICULTAD;
            end

            START_DIFICULTAD: begin
                dif_start_write    <= 1'b1;
                dificultad_pending <= 1'b0;
                state              <= DIFICULTAD;
            end

            DIFICULTAD: begin
                if (dif_done) begin
                    if (game_pending)
                        state <= CLEAR_JUEGO;
                    else if (dificultad_pending)
                        state <= START_DIFICULTAD;
                    else
                        state <= ESPERA_JUEGO;
                end
            end

            ESPERA_JUEGO: begin
                if (game_pending)
                    state <= CLEAR_JUEGO;
                else if (dificultad_pending)
                    state <= START_DIFICULTAD;
            end

            CLEAR_JUEGO: begin
                if (!lcd_busy)
                    state <= WAIT_CLEAR_BUSY;
            end

            WAIT_CLEAR_BUSY: begin
                if (lcd_busy)
                    state <= WAIT_CLEAR_DONE;
            end

            WAIT_CLEAR_DONE: begin
                if (!lcd_busy)
                    state <= START_DASH;
            end

            START_DASH: begin
                dash_start_write <= 1'b1;
                game_pending     <= 1'b0;
                state            <= DASH;
            end

            DASH: begin
                if (dash_done)
                    state <= JUEGO;
            end

            JUEGO: begin
                if (result_pending && !lcd_busy)
                    state <= START_RESULTADO;
            end

            START_RESULTADO: begin
                resultado_start_write <= 1'b1;
                result_pending        <= 1'b0;
                state                 <= RESULTADO;
            end

            RESULTADO: begin
                if (resultado_done)
                    state <= WAIT_FIN_JUEGO;
            end

            WAIT_FIN_JUEGO: begin
                if (!GameWin && !GameLose) begin
                    result_win  <= 1'b0;
                    result_lose <= 1'b0;
                    state       <= START_DIFICULTAD;
                end
            end

            default:
                state <= WAIT_INIT;

        endcase
    end
end

endmodule
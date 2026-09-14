`timescale 1ns / 1ps

module TOP_LCD (
    input  logic        clk,
    input  logic        reset,

    input  logic        hardmode,
    input  logic        GameOn,
    input  logic        GameWin,
    input  logic        GameLose,
    input  logic [2:0]  Fallos,
    input  logic [95:0] PalabraActual,
    input  logic [4:0]  LargoPalabra,
    input  logic [11:0] LetrasReveladas,

    output logic        lcd_rs,
    output logic        lcd_rw,
    output logic        lcd_e,
    output logic [7:0]  lcd_data
);

typedef enum logic [4:0] {
    WAIT_INIT,

    DIFF_CLEAR_SEND,
    DIFF_CLEAR_WAIT,
    DIFF_CHAR_SEND,
    DIFF_CHAR_WAIT,
    SELECT_WAIT,

    GAME_CLEAR_SEND,
    GAME_CLEAR_WAIT,

    WORD_ADDR_SEND,
    WORD_ADDR_WAIT,
    WORD_CHAR_SEND,
    WORD_CHAR_WAIT,

    ATT_ADDR_SEND,
    ATT_ADDR_WAIT,
    ATT_CHAR_SEND,
    ATT_CHAR_WAIT,

    PLAY_WAIT,

    RESULT_CLEAR_SEND,
    RESULT_CLEAR_WAIT,
    RESULT_CHAR_SEND,
    RESULT_CHAR_WAIT,
    RESULT_WAIT
} state_t;

state_t state;

logic flag_100ms, flag_5ms, flag_200us, flag_60us;
logic str_100ms, str_5ms, str_200us, str_60us;

logic op_start, op_rs, op_clear, op_home;
logic [7:0] op_data;
logic op_busy, op_done;

logic write_enable;
logic [1:0] addr;
logic [31:0] wdata;
logic [31:0] rdata;

logic fsm_start, fsm_rs_write, fsm_clear, fsm_home;
logic [7:0] fsm_data;
logic fsm_busy, fsm_done;
logic [7:0] temp_reg;

logic game_pending;
logic result_pending;
logic result_win_reg;

logic GameWinPrev;
logic GameLosePrev;

logic diff_mode_reg;
logic displayed_hardmode;

logic [95:0] word_reg;
logic [4:0] word_len_reg;
logic [11:0] revealed_reg;
logic [2:0] fallos_reg;

logic [11:0] displayed_revealed;
logic [2:0] displayed_fallos;

logic [3:0] char_index;

function automatic logic [7:0] diff_char(
    input logic mode,
    input integer index
);
begin
    if (!mode) begin
        case (index)
            0: diff_char = "F";
            1: diff_char = "A";
            2: diff_char = "C";
            3: diff_char = "I";
            4: diff_char = "L";
            default: diff_char = 8'h20;
        endcase
    end
    else begin
        case (index)
            0: diff_char = "D";
            1: diff_char = "I";
            2: diff_char = "F";
            3: diff_char = "I";
            4: diff_char = "C";
            5: diff_char = "I";
            6: diff_char = "L";
            default: diff_char = 8'h20;
        endcase
    end
end
endfunction

function automatic logic [7:0] game_char(
    input logic [95:0] word,
    input logic [11:0] revealed,
    input integer index
);
begin
    if (revealed[index])
        game_char = word[95 - index*8 -: 8];
    else
        game_char = "-";
end
endfunction

function automatic logic [7:0] attempts_char(
    input logic [2:0] fallos,
    input integer index
);
logic [3:0] restantes;
begin
    if (fallos >= 3'd6)
        restantes = 4'd0;
    else
        restantes = 4'd6 - fallos;

    case (index)
        0: attempts_char = "I";
        1: attempts_char = "N";
        2: attempts_char = "T";
        3: attempts_char = "E";
        4: attempts_char = "N";
        5: attempts_char = "T";
        6: attempts_char = "O";
        7: attempts_char = "S";
        8: attempts_char = ":";
        9: attempts_char = 8'h30 + restantes;
        default: attempts_char = 8'h20;
    endcase
end
endfunction

function automatic logic [7:0] result_char(
    input logic win,
    input integer index
);
begin
    if (win) begin
        case (index)
            0: result_char = "G";
            1: result_char = "A";
            2: result_char = "N";
            3: result_char = "A";
            4: result_char = "S";
            5: result_char = "T";
            6: result_char = "E";
            default: result_char = 8'h20;
        endcase
    end
    else begin
        case (index)
            0: result_char = "P";
            1: result_char = "E";
            2: result_char = "R";
            3: result_char = "D";
            4: result_char = "I";
            5: result_char = "S";
            6: result_char = "T";
            7: result_char = "E";
            default: result_char = 8'h20;
        endcase
    end
end
endfunction

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

LCD_CONTROL control_inst (
    .clk(clk),
    .rst(reset),
    .op_start(op_start),
    .op_rs(op_rs),
    .op_clear(op_clear),
    .op_home(op_home),
    .op_data(op_data),
    .op_busy(op_busy),
    .op_done(op_done),
    .write_enable(write_enable),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata)
);

LCD_PERIPH periph_inst (
    .clk(clk),
    .rst(reset),
    .write_enable(write_enable),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .lcd_busy(fsm_busy),
    .lcd_done(fsm_done),
    .start(fsm_start),
    .rs(fsm_rs_write),
    .clear(fsm_clear),
    .home(fsm_home),
    .data_byte(fsm_data)
);

FSM_LCD_HD44780 fsm_inst (
    .clk(clk),
    .reset(reset),
    .flag_100ms(flag_100ms),
    .flag_5ms(flag_5ms),
    .flag_200us(flag_200us),
    .flag_60us(flag_60us),
    .start(fsm_start),
    .rs_write(fsm_rs_write),
    .clear_write(fsm_clear),
    .home_write(fsm_home),
    .data_byte(fsm_data),
    .done(fsm_done),
    .busy(fsm_busy),
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
    op_start = 1'b0;
    op_rs    = 1'b0;
    op_clear = 1'b0;
    op_home  = 1'b0;
    op_data  = 8'h00;

    case (state)

        DIFF_CLEAR_SEND,
        GAME_CLEAR_SEND,
        RESULT_CLEAR_SEND: begin
            op_start = 1'b1;
            op_clear = 1'b1;
        end

        DIFF_CHAR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b1;
            op_data  = diff_char(diff_mode_reg, char_index);
        end

        WORD_ADDR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b0;
            op_data  = 8'h80;
        end

        WORD_CHAR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b1;
            op_data  = game_char(word_reg, revealed_reg, char_index);
        end

        ATT_ADDR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b0;
            op_data  = 8'hC0;
        end

        ATT_CHAR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b1;
            op_data  = attempts_char(fallos_reg, char_index);
        end

        RESULT_CHAR_SEND: begin
            op_start = 1'b1;
            op_rs    = 1'b1;
            op_data  = result_char(result_win_reg, char_index);
        end

        default: begin
        end

    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state               <= WAIT_INIT;
        game_pending        <= 1'b0;
        result_pending      <= 1'b0;
        result_win_reg      <= 1'b0;

        GameWinPrev         <= 1'b0;
        GameLosePrev        <= 1'b0;

        diff_mode_reg       <= 1'b0;
        displayed_hardmode  <= 1'b0;

        word_reg            <= 96'd0;
        word_len_reg        <= 5'd0;
        revealed_reg        <= 12'd0;
        fallos_reg          <= 3'd0;

        displayed_revealed  <= 12'd0;
        displayed_fallos    <= 3'd0;

        char_index          <= 4'd0;
    end
    else begin
        GameWinPrev  <= GameWin;
        GameLosePrev <= GameLose;

        if (GameOn)
            game_pending <= 1'b1;

        if (GameWin && !GameWinPrev) begin
            result_pending <= 1'b1;
            result_win_reg <= 1'b1;
        end
        else if (GameLose && !GameLosePrev) begin
            result_pending <= 1'b1;
            result_win_reg <= 1'b0;
        end

        case (state)

            WAIT_INIT: begin
                if (!fsm_busy) begin
                    diff_mode_reg <= hardmode;
                    state <= DIFF_CLEAR_SEND;
                end
            end

            DIFF_CLEAR_SEND: begin
                if (!op_busy)
                    state <= DIFF_CLEAR_WAIT;
            end

            DIFF_CLEAR_WAIT: begin
                if (op_done) begin
                    char_index <= 4'd0;
                    state <= DIFF_CHAR_SEND;
                end
            end

            DIFF_CHAR_SEND: begin
                if (!op_busy)
                    state <= DIFF_CHAR_WAIT;
            end

            DIFF_CHAR_WAIT: begin
                if (op_done) begin
                    if ((!diff_mode_reg && char_index == 4'd4) ||
                        ( diff_mode_reg && char_index == 4'd6)) begin
                        displayed_hardmode <= diff_mode_reg;
                        state <= SELECT_WAIT;
                    end
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= DIFF_CHAR_SEND;
                    end
                end
            end

            SELECT_WAIT: begin
                if (game_pending) begin
                    game_pending <= 1'b0;

                    word_reg     <= PalabraActual;
                    word_len_reg <= LargoPalabra;
                    revealed_reg <= LetrasReveladas;
                    fallos_reg   <= Fallos;

                    state <= GAME_CLEAR_SEND;
                end
                else if (hardmode != displayed_hardmode) begin
                    diff_mode_reg <= hardmode;
                    state <= DIFF_CLEAR_SEND;
                end
            end

            GAME_CLEAR_SEND: begin
                if (!op_busy)
                    state <= GAME_CLEAR_WAIT;
            end

            GAME_CLEAR_WAIT: begin
                if (op_done)
                    state <= WORD_ADDR_SEND;
            end

            WORD_ADDR_SEND: begin
                if (!op_busy)
                    state <= WORD_ADDR_WAIT;
            end

            WORD_ADDR_WAIT: begin
                if (op_done) begin
                    char_index <= 4'd0;
                    state <= WORD_CHAR_SEND;
                end
            end

            WORD_CHAR_SEND: begin
                if (!op_busy)
                    state <= WORD_CHAR_WAIT;
            end

            WORD_CHAR_WAIT: begin
                if (op_done) begin
                    if (char_index == word_len_reg - 1'b1) begin
                        state <= ATT_ADDR_SEND;
                    end
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= WORD_CHAR_SEND;
                    end
                end
            end

            ATT_ADDR_SEND: begin
                if (!op_busy)
                    state <= ATT_ADDR_WAIT;
            end

            ATT_ADDR_WAIT: begin
                if (op_done) begin
                    char_index <= 4'd0;
                    state <= ATT_CHAR_SEND;
                end
            end

            ATT_CHAR_SEND: begin
                if (!op_busy)
                    state <= ATT_CHAR_WAIT;
            end

            ATT_CHAR_WAIT: begin
                if (op_done) begin
                    if (char_index == 4'd9) begin
                        displayed_revealed <= revealed_reg;
                        displayed_fallos   <= fallos_reg;

                        if (result_pending)
                            state <= RESULT_CLEAR_SEND;
                        else
                            state <= PLAY_WAIT;
                    end
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= ATT_CHAR_SEND;
                    end
                end
            end

            PLAY_WAIT: begin
                if (result_pending) begin
                    state <= RESULT_CLEAR_SEND;
                end
                else if ((LetrasReveladas != displayed_revealed) ||
                         (Fallos != displayed_fallos)) begin

                    word_reg     <= PalabraActual;
                    word_len_reg <= LargoPalabra;
                    revealed_reg <= LetrasReveladas;
                    fallos_reg   <= Fallos;

                    state <= WORD_ADDR_SEND;
                end
            end

            RESULT_CLEAR_SEND: begin
                if (!op_busy) begin
                    result_pending <= 1'b0;
                    state <= RESULT_CLEAR_WAIT;
                end
            end

            RESULT_CLEAR_WAIT: begin
                if (op_done) begin
                    char_index <= 4'd0;
                    state <= RESULT_CHAR_SEND;
                end
            end

            RESULT_CHAR_SEND: begin
                if (!op_busy)
                    state <= RESULT_CHAR_WAIT;
            end

            RESULT_CHAR_WAIT: begin
                if (op_done) begin
                    if ((result_win_reg && char_index == 4'd6) ||
                        (!result_win_reg && char_index == 4'd7)) begin
                        state <= RESULT_WAIT;
                    end
                    else begin
                        char_index <= char_index + 1'b1;
                        state <= RESULT_CHAR_SEND;
                    end
                end
            end

            RESULT_WAIT: begin
                if (!GameWin && !GameLose) begin
                    diff_mode_reg <= hardmode;
                    state <= DIFF_CLEAR_SEND;
                end
            end

            default:
                state <= WAIT_INIT;

        endcase
    end
end

endmodule
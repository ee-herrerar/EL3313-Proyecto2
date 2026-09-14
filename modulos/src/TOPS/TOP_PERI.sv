`timescale 1ns / 1ps

module TOP_PERI (
    input  logic        clk,
    input  logic        reset,

    input  logic        BTN_SEL_RAW,
    input  logic        BTN_OK_RAW,

    input  logic [5:0]  TimerS,
    input  logic [2:0]  Fallos,
    input  logic        hardmode,
    input  logic        GameOn,
    input  logic        GameWin,
    input  logic        GameLose,
    input  logic [95:0] PalabraActual,
    input  logic [4:0]  LargoPalabra,
    input  logic [11:0] LetrasReveladas,

    output logic        BTN_SEL,
    output logic        BTN_OK,

    output logic        lcd_rs,
    output logic        lcd_rw,
    output logic        lcd_e,
    output logic [7:0]  lcd_data,

    output logic [6:0]  seg,
    output logic        dp,
    output logic [3:0]  an,

    output logic [15:0] led,
    output logic        buzzer
);

logic [1:0] botones_raw;

logic [3:0] time_tens;
logic [3:0] time_ones;
logic [3:0] wins_tens;
logic [3:0] wins_ones;

logic [2:0] FallosPrev;
logic [11:0] LetrasReveladasPrev;
logic GameWinPrev;
logic GameLosePrev;

logic correct_pulse;
logic incorrect_pulse;
logic win_pulse;
logic lose_pulse;

logic win_event;
logic lose_event;
logic correct_event;
logic incorrect_event;

logic [1:0] game_state;
logic juego_activo;

assign botones_raw = {BTN_OK_RAW, BTN_SEL_RAW};

Botones #(
    .NUM_BOTONES(2)
) botones_inst (
    .clk(clk),
    .reset(reset),
    .btn_async_in(botones_raw),
    .btn_sel_pulsado(BTN_SEL),
    .btn_ok_pulsado(BTN_OK)
);

TOP_LCD lcd_inst (
    .clk(clk),
    .reset(reset),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),
    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_e(lcd_e),
    .lcd_data(lcd_data)
);

CONTADOR_VICTORIAS victorias_inst (
    .clk(clk),
    .reset(reset),
    .GameWin(GameWin),
    .wins_tens(wins_tens),
    .wins_ones(wins_ones)
);

Display7seg display_inst (
    .clk(clk),
    .rst(reset),
    .time_tens(time_tens),
    .time_ones(time_ones),
    .wins_tens(wins_tens),
    .wins_ones(wins_ones),
    .seg(seg),
    .dp(dp),
    .an(an)
);

buzzer_driver buzzer_inst (
    .clk(clk),
    .rst(reset),
    .correct_pulse(correct_pulse),
    .incorrect_pulse(incorrect_pulse),
    .win_pulse(win_pulse),
    .lose_pulse(lose_pulse),
    .buzzer_pwm(buzzer)
);

status_led led_inst (
    .game_state(game_state),
    .led(led)
);

always_comb begin
    if (TimerS >= 6'd60) begin
        time_tens = 4'd6;
        time_ones = TimerS - 6'd60;
    end
    else if (TimerS >= 6'd50) begin
        time_tens = 4'd5;
        time_ones = TimerS - 6'd50;
    end
    else if (TimerS >= 6'd40) begin
        time_tens = 4'd4;
        time_ones = TimerS - 6'd40;
    end
    else if (TimerS >= 6'd30) begin
        time_tens = 4'd3;
        time_ones = TimerS - 6'd30;
    end
    else if (TimerS >= 6'd20) begin
        time_tens = 4'd2;
        time_ones = TimerS - 6'd20;
    end
    else if (TimerS >= 6'd10) begin
        time_tens = 4'd1;
        time_ones = TimerS - 6'd10;
    end
    else begin
        time_tens = 4'd0;
        time_ones = TimerS[3:0];
    end
end

always_comb begin
    win_event       = GameWin && !GameWinPrev;
    lose_event      = GameLose && !GameLosePrev;
    correct_event   = |(LetrasReveladas & ~LetrasReveladasPrev);
    incorrect_event = Fallos > FallosPrev;

    win_pulse       = win_event;
    lose_pulse      = lose_event;
    correct_pulse   = correct_event && !win_event && !lose_event;
    incorrect_pulse = incorrect_event && !win_event && !lose_event;
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        FallosPrev          <= 3'd0;
        LetrasReveladasPrev <= 12'd0;
        GameWinPrev         <= 1'b0;
        GameLosePrev        <= 1'b0;
        juego_activo        <= 1'b0;
    end
    else begin
        FallosPrev          <= Fallos;
        LetrasReveladasPrev <= LetrasReveladas;
        GameWinPrev         <= GameWin;
        GameLosePrev        <= GameLose;

        if (GameOn)
            juego_activo <= 1'b1;

        if (GameWin || GameLose)
            juego_activo <= 1'b0;
    end
end

always_comb begin
    if (GameWin || GameLose)
        game_state = 2'd2;
    else if (juego_activo)
        game_state = 2'd1;
    else
        game_state = 2'd0;
end

endmodule
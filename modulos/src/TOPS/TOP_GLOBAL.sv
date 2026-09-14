`timescale 1ns / 1ps

module TOP_GLOBAL #(
    parameter integer SYS_CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE    = 115_200
)(
    input  logic        clk,
    input  logic        reset,

    input  logic        BTN_SEL_RAW,
    input  logic        BTN_OK_RAW,

    input  logic        uart_rx,
    output logic        uart_tx,

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

logic BTN_SEL;
logic BTN_OK;

logic [7:0] LetraUART;
logic NuevaLetra;

logic [5:0] TimerS;
logic [2:0] Fallos;
logic hardmode;
logic GameOn;
logic GameWin;
logic GameLose;
logic [95:0] PalabraActual;
logic [4:0] LargoPalabra;
logic [11:0] LetrasReveladas;
logic [4:0] LetrasRestantes;

logic mensaje_start;
logic [2:0] mensaje_id;
logic mensaje_busy;
logic mensaje_done;

Top_Juego game_inst (
    .clk(clk),
    .RESET(reset),
    .BTN_SEL(BTN_SEL),
    .BTN_OK(BTN_OK),
    .NuevaLetra(NuevaLetra),
    .LetraUART(LetraUART),
    .TimerS(TimerS),
    .Fallos(Fallos),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),
    .LetrasRestantes(LetrasRestantes)
);

UART_EVENTOS eventos_inst (
    .clk(clk),
    .reset(reset),
    .GameOn(GameOn),
    .hardmode(hardmode),
    .Fallos(Fallos),
    .LetrasReveladas(LetrasReveladas),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .mensaje_busy(mensaje_busy),
    .mensaje_start(mensaje_start),
    .mensaje_id(mensaje_id)
);

UART_CONTROL #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) uart_inst (
    .clk(clk),
    .reset(reset),
    .rx(uart_rx),
    .tx(uart_tx),
    .LetraUART(LetraUART),
    .NuevaLetra(NuevaLetra),
    .mensaje_start(mensaje_start),
    .mensaje_id(mensaje_id),
    .mensaje_busy(mensaje_busy),
    .mensaje_done(mensaje_done)
);

TOP_PERI peri_inst (
    .clk(clk),
    .reset(reset),

    .BTN_SEL_RAW(BTN_SEL_RAW),
    .BTN_OK_RAW(BTN_OK_RAW),

    .TimerS(TimerS),
    .Fallos(Fallos),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),

    .BTN_SEL(BTN_SEL),
    .BTN_OK(BTN_OK),

    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_e(lcd_e),
    .lcd_data(lcd_data),

    .seg(seg),
    .dp(dp),
    .an(an),

    .led(led),
    .buzzer(buzzer)
);

endmodule
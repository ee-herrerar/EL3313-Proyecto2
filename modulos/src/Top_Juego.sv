module Top_Juego (
    input logic clk,
    input logic RESET,
    input logic BTN_SEL,
    input logic BTN_OK,
    input logic NuevaLetra,
    input logic [7:0] LetraUART,
    output logic [5:0] TimerS,
    output logic [2:0] Fallos,
    output logic hardmode,
    output logic GameWin,
    output logic GameLose,
    output logic [95:0] PalabraActual,
    output logic [4:0] LargoPalabra,
    output logic [11:0] LetrasReveladas,
    output logic [4:0] LetrasRestantes
);

logic [5:0] word_index;
logic SeleccionarPalabra;
logic GameOn;
logic [7:0] LetraActual;
logic Acierto;
logic [11:0] Coincidencias;
logic TimeOut;

Random_index #(
    .NUM_WORDS(50)
) random_inst (
    .clk(clk),
    .rst(RESET),
    .enable(SeleccionarPalabra),
    .word_index(word_index)
);

ROM rom_inst (
    .word_index(word_index),
    .palabra(PalabraActual),
    .largo(LargoPalabra)
);

LetraVali letra_inst (
    .palabra(PalabraActual),
    .largo(LargoPalabra),
    .letra(LetraActual),
    .acierto(Acierto),
    .coincidencias(Coincidencias)
);

Timer timer_inst (
    .clk(clk),
    .rst(RESET),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .TimerS(TimerS),
    .TimeOut(TimeOut)
);

FSM_Juego fsm_inst (
    .clk(clk),
    .RESET(RESET),
    .BTN_SEL(BTN_SEL),
    .BTN_OK(BTN_OK),
    .NuevaLetra(NuevaLetra),
    .LetraUART(LetraUART),
    .LargoPalabra(LargoPalabra),
    .Acierto(Acierto),
    .Coincidencias(Coincidencias),
    .TimeOut(TimeOut),
    .hardmode(hardmode),
    .SeleccionarPalabra(SeleccionarPalabra),
    .GameOn(GameOn),
    .LetraActual(LetraActual),
    .Fallos(Fallos),
    .LetrasRestantes(LetrasRestantes),
    .LetrasReveladas(LetrasReveladas),
    .GameWin(GameWin),
    .GameLose(GameLose)
);

endmodule
module FSM_Juego (
    input  logic        clk,
    input  logic        rst,
    input  logic        BTN_SEL,
    input  logic        BTN_OK,
    input  logic        NuevaLetra,
    input  logic [7:0]  LetraUART,
    input  logic [4:0]  LargoPalabra,
    input  logic        AciertoLetra,
    input  logic [11:0] Coincidencias,
    input  logic        TimeOut,

    output logic        hardmode,
    output logic        GameOn,
    output logic        SeleccionarPalabra,
    output logic [11:0] LetrasReveladas,
    output logic [2:0]  Fallos,
    output logic        GameWin,
    output logic        GameLose
);

typedef enum logic [3:0] {

    SeleccionDificultad,
    LlamadaPalabra,
    PalabraActiva,
    SeleccionLetra,
    LetraCorrecta,
    LetraIncorrecta,
    ComprobarLetras,
    GameOverWin,
    GameOverLose

} estado_t;

endmodule
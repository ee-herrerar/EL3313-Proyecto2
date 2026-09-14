module FSM_Juego #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer GAMEOVER_SECONDS = 3
)(
    input  logic        clk,
    input  logic        RESET,
    input  logic        BTN_SEL,
    input  logic        BTN_OK,
    input  logic        NuevaLetra,
    input  logic [7:0]  LetraUART,
    input  logic [4:0]  LargoPalabra,
    input  logic        Acierto,
    input  logic [11:0] Coincidencias,
    input  logic        TimeOut,

    output logic        hardmode,
    output logic        SeleccionarPalabra,
    output logic        GameOn,
    output logic        Active,
    output logic [7:0]  LetraActual,
    output logic [2:0]  Fallos,
    output logic [4:0]  LetrasRestantes,
    output logic [11:0] LetrasReveladas,
    output logic        GameWin,
    output logic        GameLose
);

typedef enum logic [3:0] {
    SELECCION_DIFICULTAD,
    LLAMADA_PALABRA,
    PALABRA_ACTIVA,
    COMPROBAR_LETRAS,
    SELECCION_LETRA,
    LETRA_CORRECTA,
    LETRA_INCORRECTA,
    GAME_OVER_LOSE,
    GAME_OVER_WIN
} estado_t;

estado_t estado_actual, estado_siguiente;

logic [25:0] LetrasUsadas;
logic PalabraSolicitada;

localparam integer GAMEOVER_CYCLES = CLK_FREQ * GAMEOVER_SECONDS;
localparam integer GAMEOVER_BITS = $clog2(GAMEOVER_CYCLES);

logic [GAMEOVER_BITS-1:0] ContadorGameOver;
logic FinGameOver;

assign FinGameOver = (ContadorGameOver == GAMEOVER_CYCLES - 1);

function automatic logic [4:0] ContarCoincidencias(
    input logic [11:0] vector
);
    integer i;
    begin
        ContarCoincidencias = 5'd0;
        for (i = 0; i < 12; i = i + 1)
            ContarCoincidencias = ContarCoincidencias + vector[i];
    end
endfunction

always_ff @(posedge clk or posedge RESET) begin
    if (RESET)
        estado_actual <= SELECCION_DIFICULTAD;
    else
        estado_actual <= estado_siguiente;
end

always_ff @(posedge clk or posedge RESET) begin
    if (RESET) begin
        hardmode          <= 1'b0;
        Fallos            <= 3'd0;
        LetrasRestantes   <= 5'd0;
        LetrasReveladas   <= 12'd0;
        LetrasUsadas      <= 26'd0;
        LetraActual       <= 8'd0;
        PalabraSolicitada <= 1'b0;
        ContadorGameOver  <= '0;
    end
    else begin
        if ((estado_actual == GAME_OVER_WIN) ||
            (estado_actual == GAME_OVER_LOSE)) begin
            if (!FinGameOver)
                ContadorGameOver <= ContadorGameOver + 1'b1;
        end
        else begin
            ContadorGameOver <= '0;
        end

        if (estado_actual != LLAMADA_PALABRA)
            PalabraSolicitada <= 1'b0;
        else if (!PalabraSolicitada)
            PalabraSolicitada <= 1'b1;

        case (estado_actual)

            SELECCION_DIFICULTAD: begin
                if (BTN_SEL)
                    hardmode <= ~hardmode;
            end

            LLAMADA_PALABRA: begin
                if (PalabraSolicitada) begin
                    Fallos            <= 3'd0;
                    LetrasUsadas      <= 26'd0;
                    LetrasReveladas   <= 12'd0;
                    LetraActual       <= 8'd0;
                    LetrasRestantes   <= LargoPalabra;
                end
            end

            PALABRA_ACTIVA: begin
                if (NuevaLetra)
                    LetraActual <= LetraUART;
            end

            SELECCION_LETRA: begin
                if ((LetraActual >= 8'h41) &&
                    (LetraActual <= 8'h5A)) begin
                    if (!LetrasUsadas[LetraActual - 8'h41])
                        LetrasUsadas[LetraActual - 8'h41] <= 1'b1;
                end
            end

            LETRA_CORRECTA: begin
                LetrasReveladas <= LetrasReveladas | Coincidencias;

                if (LetrasRestantes >= ContarCoincidencias(Coincidencias))
                    LetrasRestantes <= LetrasRestantes -
                                       ContarCoincidencias(Coincidencias);
                else
                    LetrasRestantes <= 5'd0;
            end

            LETRA_INCORRECTA: begin
                if (Fallos < 3'd6)
                    Fallos <= Fallos + 3'd1;
            end

            default: begin
            end
        endcase
    end
end

always_comb begin
    estado_siguiente   = estado_actual;
    SeleccionarPalabra = 1'b0;
    GameOn             = 1'b0;
    GameWin            = 1'b0;
    GameLose           = 1'b0;

    Active = (estado_actual == PALABRA_ACTIVA)   ||
             (estado_actual == COMPROBAR_LETRAS) ||
             (estado_actual == SELECCION_LETRA)  ||
             (estado_actual == LETRA_CORRECTA)   ||
             (estado_actual == LETRA_INCORRECTA);

    case (estado_actual)

        SELECCION_DIFICULTAD: begin
            if (BTN_OK)
                estado_siguiente = LLAMADA_PALABRA;
        end

        LLAMADA_PALABRA: begin
            if (!PalabraSolicitada) begin
                SeleccionarPalabra = 1'b1;
                estado_siguiente = LLAMADA_PALABRA;
            end
            else begin
                GameOn = 1'b1;
                estado_siguiente = PALABRA_ACTIVA;
            end
        end

        PALABRA_ACTIVA: begin
            if (TimeOut)
                estado_siguiente = GAME_OVER_LOSE;
            else if (NuevaLetra)
                estado_siguiente = COMPROBAR_LETRAS;
        end

        COMPROBAR_LETRAS: begin
            if (TimeOut)
                estado_siguiente = GAME_OVER_LOSE;
            else if (LetrasRestantes == 5'd0)
                estado_siguiente = GAME_OVER_WIN;
            else if (Fallos >= 3'd6)
                estado_siguiente = GAME_OVER_LOSE;
            else
                estado_siguiente = SELECCION_LETRA;
        end

        SELECCION_LETRA: begin
            if (TimeOut)
                estado_siguiente = GAME_OVER_LOSE;
            else if ((LetraActual < 8'h41) ||
                     (LetraActual > 8'h5A))
                estado_siguiente = PALABRA_ACTIVA;
            else if (LetrasUsadas[LetraActual - 8'h41])
                estado_siguiente = PALABRA_ACTIVA;
            else if (Acierto)
                estado_siguiente = LETRA_CORRECTA;
            else
                estado_siguiente = LETRA_INCORRECTA;
        end

        LETRA_CORRECTA: begin
            if (TimeOut)
                estado_siguiente = GAME_OVER_LOSE;
            else
                estado_siguiente = COMPROBAR_LETRAS;
        end

        LETRA_INCORRECTA: begin
            if (TimeOut)
                estado_siguiente = GAME_OVER_LOSE;
            else
                estado_siguiente = COMPROBAR_LETRAS;
        end

        GAME_OVER_LOSE: begin
            GameLose = 1'b1;
            if (FinGameOver)
                estado_siguiente = SELECCION_DIFICULTAD;
        end

        GAME_OVER_WIN: begin
            GameWin = 1'b1;
            if (FinGameOver)
                estado_siguiente = SELECCION_DIFICULTAD;
        end

        default: begin
            estado_siguiente = SELECCION_DIFICULTAD;
        end
    endcase
end

endmodule
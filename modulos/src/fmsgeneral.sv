module FSM_Juego #(
    parameter integer CLK_FREQ         = 100_000_000,
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
    
    // Comunicacion con LCD
    output logic        start_fsm,
    output logic        start_end,
    output logic        start_dashes,
    input  logic        lcd_busy,
    input  logic        done_dif,
    input  logic        done_dash,
    input  logic        done_end,
    output logic        win_or_lose,


    // Modulo seleccion de dificultad
    output logic        inicio_seleccion,
    input  logic        dificulty_signal,
    output logic        stop_seleccion,

    output logic [1:0]  mux_sel,

    output logic        SeleccionarPalabra,
    output logic        GameOn,
    output logic [7:0]  LetraActual,
    output logic [2:0]  Fallos,
    output logic [4:0]  LetrasRestantes,
    output logic [11:0] LetrasReveladas,
    output logic        GameWin,
    output logic        GameLose
);


    // =====================================================
    // ESTADOS
    // =====================================================

    typedef enum logic [3:0] {

        WAIT_INIT,
        SELECCION_DIFICULTAD,
        LCD_DASHES_START,
        LCD_DASHES,
        LLAMADA_PALABRA,
        PALABRA_ACTIVA,
        COMPROBAR_LETRAS,
        SELECCION_LETRA,
        LETRA_CORRECTA_START,
        LETRA_CORRECTA,
        LETRA_INCORRECTA,
        GAME_OVER_LOSE,
        GAME_OVER_WIN,
        WAIT_END

    } estado_t;


    estado_t estado_actual;
    estado_t estado_siguiente;


    // =====================================================
    // REGISTROS INTERNOS
    // =====================================================

    // Un bit para cada letra de A-Z
    logic [25:0] LetrasUsadas;

    // Permite dar un ciclo para seleccionar la palabra
    logic PalabraSolicitada;


    // =====================================================
    // CONTADOR DE 3 SEGUNDOS PARA GAME OVER
    // =====================================================

    localparam integer GAMEOVER_CYCLES =
        CLK_FREQ * GAMEOVER_SECONDS;

    localparam integer GAMEOVER_BITS =
        $clog2(GAMEOVER_CYCLES);

    logic [GAMEOVER_BITS-1:0] ContadorGameOver;
    logic                     FinGameOver;


    assign FinGameOver =
        (ContadorGameOver == GAMEOVER_CYCLES - 1);


    // =====================================================
    // FUNCION PARA CONTAR COINCIDENCIAS
    // =====================================================

    function automatic logic [4:0] ContarCoincidencias(
        input logic [11:0] vector
    );

        integer i;

        begin

            ContarCoincidencias = 5'd0;

            for (i = 0; i < 12; i = i + 1) begin

                ContarCoincidencias =
                    ContarCoincidencias + vector[i];

            end

        end

    endfunction


    // =====================================================
    // REGISTRO DE ESTADO
    // =====================================================

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin
            estado_actual <= WAIT_INIT;
        end

        else begin
            estado_actual <= estado_siguiente;
        end

    end


    // =====================================================
    // REGISTROS DE DATOS DEL JUEGO
    // =====================================================

    always_ff @(posedge clk or posedge RESET) begin

        if (RESET) begin

            stop_seleccion <= 1'b0;
            inicio_seleccion <= 1'b0;
            Fallos            <= 3'd0;
            LetrasRestantes   <= 5'd0;
            LetrasReveladas   <= 12'd0;
            LetrasUsadas      <= 26'd0;
            LetraActual       <= 8'd0;

            PalabraSolicitada <= 1'b0;

            ContadorGameOver  <= '0;

        end

        else begin

            inicio_seleccion <= 1'b0;
            // =================================================
            // CONTADOR GAME OVER
            // =================================================

            if ((estado_actual == GAME_OVER_WIN) ||
                (estado_actual == GAME_OVER_LOSE)) begin

                if (!FinGameOver) begin

                    ContadorGameOver <=
                        ContadorGameOver + 1'b1;

                end

            end

            else begin

                ContadorGameOver <= '0;

            end


            // =================================================
            // CONTROL DE SOLICITUD DE PALABRA
            // =================================================

            if (estado_actual != LLAMADA_PALABRA) begin

                PalabraSolicitada <= 1'b0;

            end

            else if (!PalabraSolicitada) begin

                PalabraSolicitada <= 1'b1;

            end


            // =================================================
            // ACCIONES DE LOS ESTADOS
            // =================================================

            case (estado_actual)


                WAIT_INIT: begin

                    inicio_seleccion <= 1'b0;
                    
                end
                // ---------------------------------------------
                // SELECCION DE DIFICULTAD
                // ---------------------------------------------

                SELECCION_DIFICULTAD: begin
                    if (BTN_SEL) begin
                        inicio_seleccion <= 1'b1;
                    end

                end


                // ---------------------------------------------
                // LLAMADA DE PALABRA
                // ---------------------------------------------

                LLAMADA_PALABRA: begin

                    if (PalabraSolicitada) begin

                        Fallos          <= 3'd0;
                        LetrasUsadas    <= 26'd0;
                        LetrasReveladas <= 12'd0;
                        LetraActual     <= 8'd0;

                        LetrasRestantes <= LargoPalabra;

                    end

                end

                // ---------------------------------------------
                // PALABRA ACTIVA
                // ---------------------------------------------

                PALABRA_ACTIVA: begin

                    // Guardar la letra recibida
                    if (NuevaLetra) begin

                        LetraActual <= LetraUART;

                    end

                end


                // ---------------------------------------------
                // SELECCION DE LETRA
                // ---------------------------------------------

                SELECCION_LETRA: begin

                    // Registrar la letra solamente si:
                    // 1. Es A-Z
                    // 2. No habia sido utilizada

                    if ((LetraActual >= 8'h41) &&
                        (LetraActual <= 8'h5A)) begin

                        if (!LetrasUsadas[
                            LetraActual - 8'h41
                        ]) begin

                            LetrasUsadas[
                                LetraActual - 8'h41
                            ] <= 1'b1;

                        end

                    end

                end


                // ---------------------------------------------
                // LETRA CORRECTA
                // ---------------------------------------------

                LETRA_CORRECTA: begin

                    LetrasReveladas <=
                        LetrasReveladas | Coincidencias;

                 
                    // Una letra puede aparecer varias veces
                    if (LetrasRestantes >=
                        ContarCoincidencias(Coincidencias)) begin

                        LetrasRestantes <=
                            LetrasRestantes -
                            ContarCoincidencias(Coincidencias);

                    end

                    else begin

                        LetrasRestantes <= 5'd0;

                    end

                end


                // ---------------------------------------------
                // LETRA INCORRECTA
                // ---------------------------------------------

                LETRA_INCORRECTA: begin

                    if (Fallos < 3'd6) begin

                        Fallos <= Fallos + 3'd1;

                    end

                end

                default: begin
                end

            endcase

        end

    end


    // =====================================================
    // LOGICA DE SIGUIENTE ESTADO
    // =====================================================

    always_comb begin

        // Valores por defecto
        estado_siguiente   = estado_actual;

        SeleccionarPalabra = 1'b0;
        GameOn             = 1'b0;
        stop_seleccion     = 1'b0;
        start_dashes       = 1'b0;
        start_fsm          = 1'b0;
        start_end          = 1'b0;

        GameWin            = 1'b0;
        GameLose           = 1'b0;
        win_or_lose        = 1'b0;
        mux_sel = 2'b00;


        case (estado_actual)

        // =================================================
        // ESPERA A LA LCD
        // =================================================
            WAIT_INIT: begin

                if (!lcd_busy) begin
                    // Esperar a que el LCD este listo para iniciar la seleccion de dificultad
                    estado_siguiente =
                        SELECCION_DIFICULTAD;

                end

            end
            // =================================================
            // SELECCION DIFICULTAD
            // =================================================

            SELECCION_DIFICULTAD: begin
                mux_sel = 2'b00;
                if (BTN_OK) begin
                    stop_seleccion = 1'b1;
                end
                if (done_dif) begin
                    estado_siguiente = LLAMADA_PALABRA;
                end
            end


            // =================================================
            // LLAMADA PALABRA
            // =================================================

            LLAMADA_PALABRA: begin

                // Primer ciclo:
                // solicitar nueva palabra
                if (!PalabraSolicitada) begin

                    SeleccionarPalabra = 1'b1;

                    estado_siguiente =
                        LLAMADA_PALABRA;

                end

                // Segundo ciclo:
                // palabra ya disponible
                else begin

                    // Pulso para iniciar el Timer
                    GameOn = 1'b1;

                    estado_siguiente =
                        LCD_DASHES_START;

                end

            end

            LCD_DASHES_START: begin
                mux_sel = 2'b01;
                start_dashes = 1'b1;
                estado_siguiente = LCD_DASHES;
            end

            LCD_DASHES: begin
                mux_sel = 2'b01;
                if (done_dash) begin
                    estado_siguiente = PALABRA_ACTIVA;
                end
            end
            // =================================================
            // PALABRA ACTIVA
            // =================================================

            PALABRA_ACTIVA: begin

                // Tiempo agotado
                if (TimeOut) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                // Se recibio una letra
                else if (NuevaLetra) begin

                    // Segun el diagrama:
                    // primero pasar por ComprobarLetras
                    estado_siguiente =
                        COMPROBAR_LETRAS;

                end

            end


            // =================================================
            // COMPROBAR LETRAS
            // =================================================

            COMPROBAR_LETRAS: begin

                // Tiempo agotado
                if (TimeOut) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                // Palabra completada
                else if (LetrasRestantes == 5'd0) begin

                    estado_siguiente =
                        GAME_OVER_WIN;

                end

                // Se alcanzaron los 6 fallos
                else if (Fallos >= 3'd6) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                // Todavia se puede continuar
                else begin

                    estado_siguiente =
                        SELECCION_LETRA;

                end

            end


            // =================================================
            // SELECCION LETRA
            // =================================================

            SELECCION_LETRA: begin

                // Tiempo agotado
                if (TimeOut) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                // Entrada invalida
                else if ((LetraActual < 8'h41) ||
                         (LetraActual > 8'h5A)) begin

                    estado_siguiente =
                        PALABRA_ACTIVA;

                end

                // Letra repetida
                else if (
                    LetrasUsadas[
                        LetraActual - 8'h41
                    ]
                ) begin

                    estado_siguiente =
                        PALABRA_ACTIVA;

                end

                // Letra correcta
                else if (Acierto) begin

                    estado_siguiente =
                        LETRA_CORRECTA_START;

                end

                // Letra incorrecta
                else begin

                    estado_siguiente =
                        LETRA_INCORRECTA;

                end

            end

            LETRA_CORRECTA_START: begin
                mux_sel = 2'b10;
                start_fsm = 1'b1;
                estado_siguiente = LETRA_CORRECTA;
            end

            // =================================================
            // LETRA CORRECTA
            // =================================================

            LETRA_CORRECTA: begin

                if (TimeOut) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                else begin
                // Logica que inicia la escritura 
                mux_sel = 2'b10;
                    if (!lcd_busy) begin
                    // Segun el diagrama:
                    // regresar a ComprobarLetras  
                    estado_siguiente =
                        COMPROBAR_LETRAS;
                    end

                end

            end


            // =================================================
            // LETRA INCORRECTA
            // =================================================

            LETRA_INCORRECTA: begin

                if (TimeOut) begin

                    estado_siguiente =
                        GAME_OVER_LOSE;

                end

                else begin

                    // Segun el diagrama:
                    // regresar a ComprobarLetras
                    estado_siguiente =
                        COMPROBAR_LETRAS;

                end

            end


            // =================================================
            // GAME OVER LOSE
            // =================================================

            GAME_OVER_LOSE: begin
                mux_sel = 2'b11;
                GameLose = 1'b1;
                win_or_lose = 1'b0;
                start_end =   1'b1;

                if (FinGameOver) begin

                    estado_siguiente =
                        WAIT_END;

                end

            end


            // =================================================
            // GAME OVER WIN
            // =================================================

            GAME_OVER_WIN: begin
                mux_sel = 2'b11;
                GameWin = 1'b1;
                win_or_lose = 1'b1;
                start_end =   1'b1;

                if (FinGameOver) begin

                    estado_siguiente =
                        WAIT_END;

                end

            end

            WAIT_END: begin
                    if (done_end) begin
                        estado_siguiente =
                        SELECCION_DIFICULTAD;
                    end
            end

            // =================================================
            // SEGURIDAD
            // =================================================

            default: begin

                estado_siguiente =
                    SELECCION_DIFICULTAD;

            end

        endcase

    end

endmodule
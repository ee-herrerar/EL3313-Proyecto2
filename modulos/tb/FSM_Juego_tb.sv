`timescale 1ns / 1ps

module FSM_Juego_tb;

    // =====================================================
    // ENTRADAS
    // =====================================================

    logic        clk;
    logic        RESET;

    logic        BTN_SEL;
    logic        BTN_OK;

    logic        NuevaLetra;
    logic [7:0]  LetraUART;

    logic [4:0]  LargoPalabra;

    logic        Acierto;
    logic [11:0] Coincidencias;

    logic        TimeOut;


    // =====================================================
    // SALIDAS
    // =====================================================

    logic        hardmode;

    logic        SeleccionarPalabra;
    logic        GameOn;

    logic [7:0]  LetraActual;

    logic [2:0]  Fallos;
    logic [4:0]  LetrasRestantes;
    logic [11:0] LetrasReveladas;

    logic        GameWin;
    logic        GameLose;


    integer errores;


    // =====================================================
    // ESTADOS
    // Deben coincidir con el orden del enum del DUT
    // =====================================================

    localparam logic [3:0] ST_SELECCION = 4'd0;
    localparam logic [3:0] ST_LLAMADA   = 4'd1;
    localparam logic [3:0] ST_ACTIVA    = 4'd2;
    localparam logic [3:0] ST_COMPROBAR = 4'd3;
    localparam logic [3:0] ST_SEL_LETRA = 4'd4;
    localparam logic [3:0] ST_CORRECTA  = 4'd5;
    localparam logic [3:0] ST_INCORRECTA = 4'd6;
    localparam logic [3:0] ST_LOSE      = 4'd7;
    localparam logic [3:0] ST_WIN       = 4'd8;


    // =====================================================
    // DUT
    // =====================================================

    FSM_Juego #(
        .CLK_FREQ(10),
        .GAMEOVER_SECONDS(3)
    ) dut (
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


    // =====================================================
    // CLOCK 100 MHz
    // Periodo = 10 ns
    // =====================================================

    always #5 clk = ~clk;


    // =====================================================
    // COMPROBAR ESTADO
    // =====================================================

    task automatic comprobar_estado(
        input logic [3:0] esperado
    );
    begin

        if (dut.estado_actual === esperado) begin
            $display(
                "PASS - Estado = %0d",
                dut.estado_actual
            );
        end

        else begin
            $display(
                "ERROR - Estado obtenido = %0d, esperado = %0d",
                dut.estado_actual,
                esperado
            );

            errores = errores + 1;
        end

    end
    endtask


    // =====================================================
    // PULSO BTN_SEL
    // =====================================================

    task automatic pulsar_SEL;
    begin

        @(negedge clk);
        BTN_SEL = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);
        BTN_SEL = 1'b0;

    end
    endtask


    // =====================================================
    // PULSO BTN_OK
    // =====================================================

    task automatic pulsar_OK;
    begin

        @(negedge clk);
        BTN_OK = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);
        BTN_OK = 1'b0;

    end
    endtask


    // =====================================================
    // ENVIAR LETRA
    // =====================================================

    task automatic enviar_letra(
        input logic [7:0]  letra,
        input logic        resultado_acierto,
        input logic [11:0] posiciones
    );
    begin

        @(negedge clk);

        LetraUART     = letra;
        Acierto       = resultado_acierto;
        Coincidencias = posiciones;
        NuevaLetra    = 1'b1;

        @(posedge clk);
        #1;

        @(negedge clk);

        NuevaLetra = 1'b0;

    end
    endtask


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        clk            = 1'b0;
        RESET          = 1'b1;

        BTN_SEL        = 1'b0;
        BTN_OK         = 1'b0;

        NuevaLetra     = 1'b0;
        LetraUART      = 8'd0;

        LargoPalabra   = 5'd4;

        Acierto        = 1'b0;
        Coincidencias  = 12'd0;

        TimeOut        = 1'b0;

        errores        = 0;


        // =================================================
        // PRUEBA 1 - RESET
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA RESET");

        #20;
        RESET = 1'b0;

        @(posedge clk);
        #1;

        comprobar_estado(ST_SELECCION);

        if (Fallos == 3'd0 &&
            LetrasRestantes == 5'd0 &&
            GameWin == 1'b0 &&
            GameLose == 1'b0) begin

            $display("PASS - Registros inicializados");

        end
        else begin

            $display("ERROR - Reset incorrecto");
            errores = errores + 1;

        end


        // =================================================
        // PRUEBA 2 - SELECCION DIFICULTAD
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA SELECCION DIFICULTAD");

        pulsar_SEL();

        if (hardmode == 1'b1)
            $display("PASS - hardmode = 1");
        else begin
            $display("ERROR - hardmode deberia ser 1");
            errores = errores + 1;
        end


        // Volver a modo facil
        pulsar_SEL();

        if (hardmode == 1'b0)
            $display("PASS - hardmode = 0");
        else begin
            $display("ERROR - hardmode deberia ser 0");
            errores = errores + 1;
        end


        // =================================================
        // PRUEBA 3 - INICIAR PARTIDA
        // Palabra simulada: CASA
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA INICIO DE PARTIDA");

        LargoPalabra = 5'd4;

        pulsar_OK();

        comprobar_estado(ST_LLAMADA);


        // Primer ciclo de LLAMADA_PALABRA
        @(posedge clk);
        #1;

        if (GameOn == 1'b1)
            $display("PASS - GameOn generado");
        else begin
            $display("ERROR - GameOn no fue generado");
            errores = errores + 1;
        end


        // Entrar a PALABRA_ACTIVA
        @(posedge clk);
        #1;

        comprobar_estado(ST_ACTIVA);

        if (LetrasRestantes == 5'd4)
            $display("PASS - LetrasRestantes = 4");
        else begin
            $display(
                "ERROR - LetrasRestantes = %0d",
                LetrasRestantes
            );

            errores = errores + 1;
        end


        // =================================================
        // PRUEBA 4 - LETRA CORRECTA
        // CASA + A
        // posiciones 1 y 3
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA LETRA CORRECTA: A");

        enviar_letra(
            8'h41,                 // A
            1'b1,
            12'b000000001010
        );


        // PALABRA_ACTIVA -> COMPROBAR
        comprobar_estado(ST_COMPROBAR);


        // COMPROBAR -> SELECCION_LETRA
        @(posedge clk);
        #1;

        comprobar_estado(ST_SEL_LETRA);


        // SELECCION_LETRA -> LETRA_CORRECTA
        @(posedge clk);
        #1;

        comprobar_estado(ST_CORRECTA);


        // LETRA_CORRECTA -> COMPROBAR
        @(posedge clk);
        #1;

        comprobar_estado(ST_COMPROBAR);


        // Debe haber revelado las dos A
        if (LetrasRestantes == 5'd2 &&
            LetrasReveladas == 12'b000000001010) begin

            $display(
                "PASS - A revelo dos posiciones"
            );

        end

        else begin

            $display(
                "ERROR - LetrasRestantes=%0d Reveladas=%b",
                LetrasRestantes,
                LetrasReveladas
            );

            errores = errores + 1;

        end


        // La FSM pasa nuevamente por SeleccionLetra
        // y detecta que A ya estaba utilizada
        @(posedge clk);
        #1;

        comprobar_estado(ST_SEL_LETRA);

        @(posedge clk);
        #1;

        comprobar_estado(ST_ACTIVA);


        // =================================================
        // PRUEBA 5 - LETRA REPETIDA
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA LETRA REPETIDA: A");

        enviar_letra(
            8'h41,
            1'b1,
            12'b000000001010
        );

        comprobar_estado(ST_COMPROBAR);

        @(posedge clk);
        #1;

        comprobar_estado(ST_SEL_LETRA);

        @(posedge clk);
        #1;

        // Debe ignorarla
        comprobar_estado(ST_ACTIVA);


        if (LetrasRestantes == 5'd2 &&
            Fallos == 3'd0) begin

            $display("PASS - Letra repetida ignorada");

        end

        else begin

            $display("ERROR - Letra repetida modifico el juego");
            errores = errores + 1;

        end


        // =================================================
        // PRUEBA 6 - LETRA INCORRECTA
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA LETRA INCORRECTA: Z");

        enviar_letra(
            8'h5A,                 // Z
            1'b0,
            12'b000000000000
        );


        comprobar_estado(ST_COMPROBAR);


        @(posedge clk);
        #1;

        comprobar_estado(ST_SEL_LETRA);


        @(posedge clk);
        #1;

        comprobar_estado(ST_INCORRECTA);


        @(posedge clk);
        #1;

        comprobar_estado(ST_COMPROBAR);


        if (Fallos == 3'd1)
            $display("PASS - Fallos = 1");
        else begin

            $display(
                "ERROR - Fallos obtenido = %0d",
                Fallos
            );

            errores = errores + 1;

        end


        // Volver a PALABRA_ACTIVA
        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        comprobar_estado(ST_ACTIVA);


        // =================================================
        // PRUEBA 7 - COMPLETAR PALABRA
        // Falta C y S
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA VICTORIA");


        // ---------------------------------------------
        // C
        // ---------------------------------------------

        enviar_letra(
            8'h43,                 // C
            1'b1,
            12'b000000000001
        );

        // COMPROBAR
        @(posedge clk);
        #1;

        // SELECCION_LETRA
        @(posedge clk);
        #1;

        // LETRA_CORRECTA
        @(posedge clk);
        #1;

        // COMPROBAR ya actualizo LetrasRestantes
        if (LetrasRestantes == 5'd1)
            $display("PASS - Solo queda una letra");
        else begin

            $display(
                "ERROR - LetrasRestantes deberia ser 1, es %0d",
                LetrasRestantes
            );

            errores = errores + 1;

        end


        // Volver a PALABRA_ACTIVA
        @(posedge clk);
        @(posedge clk);
        #1;


        // ---------------------------------------------
        // S
        // ---------------------------------------------

        enviar_letra(
            8'h53,                 // S
            1'b1,
            12'b000000000100
        );

        // COMPROBAR -> SELECCION
        @(posedge clk);
        #1;

        // SELECCION -> CORRECTA
        @(posedge clk);
        #1;

        // CORRECTA -> COMPROBAR
        @(posedge clk);
        #1;


        if (LetrasRestantes == 5'd0)
            $display("PASS - LetrasRestantes = 0");
        else begin

            $display(
                "ERROR - LetrasRestantes = %0d",
                LetrasRestantes
            );

            errores = errores + 1;

        end


        // COMPROBAR -> GAME_OVER_WIN
        @(posedge clk);
        #1;

        comprobar_estado(ST_WIN);


        if (GameWin == 1'b1)
            $display("PASS - GameWin activado");
        else begin

            $display("ERROR - GameWin no se activo");
            errores = errores + 1;

        end


        // =================================================
        // PRUEBA 8 - ESPERA GAME OVER
        // CLK_FREQ reducido a 10
        // 3 s = 30 clocks
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA ESPERA GAME OVER");

        repeat (35) begin
            @(posedge clk);
            #1;
        end

        comprobar_estado(ST_SELECCION);


        // =================================================
        // PRUEBA 9 - DERROTA POR TIMEOUT
        // =================================================

        $display("----------------------------------");
        $display("PRUEBA TIMEOUT");


        LargoPalabra = 5'd4;

        pulsar_OK();

        // Procesar LLAMADA_PALABRA
        @(posedge clk);
        #1;

        @(posedge clk);
        #1;

        comprobar_estado(ST_ACTIVA);


        // Simular timeout
        @(negedge clk);
        TimeOut = 1'b1;

        @(posedge clk);
        #1;

        comprobar_estado(ST_LOSE);


        if (GameLose == 1'b1)
            $display("PASS - GameLose activado por TimeOut");
        else begin

            $display("ERROR - GameLose no se activo");
            errores = errores + 1;

        end

        TimeOut = 1'b0;


        // =================================================
        // RESULTADO FINAL
        // =================================================

        $display("----------------------------------");

        if (errores == 0) begin

            $display("==================================");
            $display("TODAS LAS PRUEBAS PASARON");
            $display("==================================");

        end

        else begin

            $display("==================================");
            $display("PRUEBAS FALLIDAS: %0d", errores);
            $display("==================================");

        end

        $finish;

    end

endmodule
`timescale 1ns / 1ps

module UART_EVENTOS_tb;

logic clk;
logic reset;

logic GameOn;
logic hardmode;
logic [2:0] Fallos;
logic [11:0] LetrasReveladas;
logic GameWin;
logic GameLose;

logic mensaje_busy;
logic mensaje_start;
logic [2:0] mensaje_id;

integer errores;

UART_EVENTOS dut (
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

always #5 clk = ~clk;

task automatic esperar_mensaje(input logic [2:0] esperado);
begin
    @(posedge mensaje_start);

    if (mensaje_id === esperado)
        $display("PASS - mensaje_id = %0d", mensaje_id);
    else begin
        $display(
            "FAIL - mensaje_id = %0d, esperado = %0d",
            mensaje_id,
            esperado
        );
        errores = errores + 1;
    end

    @(posedge clk);
end
endtask

initial begin
    clk              = 1'b0;
    reset            = 1'b1;
    GameOn           = 1'b0;
    hardmode         = 1'b0;
    Fallos           = 3'd0;
    LetrasReveladas  = 12'd0;
    GameWin          = 1'b0;
    GameLose         = 1'b0;
    mensaje_busy     = 1'b0;
    errores          = 0;

    repeat (5) @(posedge clk);
    reset = 1'b0;

    repeat (3) @(posedge clk);

    // =====================================================
    // FACIL
    // =====================================================

    $display("PRUEBA MODO FACIL");

    hardmode = 1'b0;
    GameOn = 1'b1;
    @(posedge clk);
    GameOn = 1'b0;

    esperar_mensaje(3'd0);

    // =====================================================
    // DIFICIL
    // =====================================================

    $display("PRUEBA MODO DIFICIL");

    hardmode = 1'b1;
    GameOn = 1'b1;
    @(posedge clk);
    GameOn = 1'b0;

    esperar_mensaje(3'd1);

    // =====================================================
    // LETRA CORRECTA
    // =====================================================

    $display("PRUEBA LETRA CORRECTA");

    LetrasReveladas = 12'b000000000101;

    esperar_mensaje(3'd2);

    // =====================================================
    // LETRA INCORRECTA
    // =====================================================

    $display("PRUEBA LETRA INCORRECTA");

    Fallos = 3'd1;

    esperar_mensaje(3'd3);

    // =====================================================
    // GANASTE
    // =====================================================

    $display("PRUEBA GANASTE");

    GameWin = 1'b1;
    @(posedge clk);
    GameWin = 1'b0;

    esperar_mensaje(3'd4);

    // =====================================================
    // PERDISTE
    // =====================================================

    $display("PRUEBA PERDISTE");

    GameLose = 1'b1;
    @(posedge clk);
    GameLose = 1'b0;

    esperar_mensaje(3'd5);

    // =====================================================
    // EVENTO MIENTRAS UART ESTA OCUPADA
    // =====================================================

    $display("PRUEBA EVENTO PENDIENTE");

    mensaje_busy = 1'b1;

    Fallos = 3'd2;

    repeat (5) @(posedge clk);

    if (mensaje_start === 1'b0)
        $display("PASS - No transmite mientras mensaje_busy = 1");
    else begin
        $display("FAIL - Transmitio mientras UART estaba ocupada");
        errores = errores + 1;
    end

    mensaje_busy = 1'b0;

    esperar_mensaje(3'd3);

    // =====================================================
    // PRIORIDAD WIN SOBRE OTROS EVENTOS
    // =====================================================

    $display("PRUEBA PRIORIDAD WIN");

    mensaje_busy = 1'b1;

    LetrasReveladas = 12'b000000001111;
    GameWin = 1'b1;

    @(posedge clk);

    GameWin = 1'b0;

    repeat (3) @(posedge clk);

    mensaje_busy = 1'b0;

    esperar_mensaje(3'd4);
    esperar_mensaje(3'd2);

    // =====================================================
    // RESULTADO
    // =====================================================

    repeat (5) @(posedge clk);

    if (errores == 0)
        $display("TODAS LAS PRUEBAS UART_EVENTOS PASARON");
    else
        $display(
            "PRUEBAS UART_EVENTOS FINALIZADAS CON %0d ERRORES",
            errores
        );

    $finish;
end

endmodule
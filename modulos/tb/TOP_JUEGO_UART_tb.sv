`timescale 1ns / 1ps

module TOP_JUEGO_UART_tb;

localparam integer SYS_CLK_FREQ = 100_000_000;
localparam integer BAUD_RATE    = 115_200;

localparam time CLK_PERIOD = 10ns;
localparam time BIT_TIME   = 8680ns;

logic clk;
logic reset;

logic BTN_SEL;
logic BTN_OK;

logic uart_rx;
logic uart_tx;

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

integer errores;

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

always #(CLK_PERIOD/2) clk = ~clk;

task automatic reset_system;
begin
    reset   = 1'b1;
    BTN_SEL = 1'b0;
    BTN_OK  = 1'b0;
    uart_rx = 1'b1;

    repeat (10) @(posedge clk);

    @(negedge clk);
    reset = 1'b0;

    repeat (10) @(posedge clk);
end
endtask

task automatic press_sel;
begin
    @(negedge clk);
    BTN_SEL = 1'b1;

    @(negedge clk);
    BTN_SEL = 1'b0;
end
endtask

task automatic press_ok;
begin
    @(negedge clk);
    BTN_OK = 1'b1;

    @(negedge clk);
    BTN_OK = 1'b0;
end
endtask

task automatic uart_send_byte(input logic [7:0] data);
    integer i;
begin
    uart_rx = 1'b0;
    #(BIT_TIME);

    for (i = 0; i < 8; i = i + 1) begin
        uart_rx = data[i];
        #(BIT_TIME);
    end

    uart_rx = 1'b1;
    #(BIT_TIME);
end
endtask

task automatic uart_receive_byte(output logic [7:0] data);
    integer i;
begin
    @(negedge uart_tx);

    #(BIT_TIME + BIT_TIME/2);

    for (i = 0; i < 8; i = i + 1) begin
        data[i] = uart_tx;
        #(BIT_TIME);
    end

    if (uart_tx !== 1'b1) begin
        $display("FAIL - Bit de parada UART incorrecto");
        errores = errores + 1;
    end
end
endtask

function automatic integer message_length(input logic [2:0] id);
begin
    case (id)
        3'd0: message_length = 7;
        3'd1: message_length = 9;
        3'd2: message_length = 10;
        3'd3: message_length = 12;
        3'd4: message_length = 9;
        3'd5: message_length = 10;
        default: message_length = 0;
    endcase
end
endfunction

function automatic logic [7:0] expected_byte(
    input logic [2:0] id,
    input integer index
);
begin
    expected_byte = 8'h00;

    case (id)

        3'd0: begin
            case (index)
                0: expected_byte = "F";
                1: expected_byte = "A";
                2: expected_byte = "C";
                3: expected_byte = "I";
                4: expected_byte = "L";
                5: expected_byte = 8'h0D;
                6: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        3'd1: begin
            case (index)
                0: expected_byte = "D";
                1: expected_byte = "I";
                2: expected_byte = "F";
                3: expected_byte = "I";
                4: expected_byte = "C";
                5: expected_byte = "I";
                6: expected_byte = "L";
                7: expected_byte = 8'h0D;
                8: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        3'd2: begin
            case (index)
                0: expected_byte = "C";
                1: expected_byte = "O";
                2: expected_byte = "R";
                3: expected_byte = "R";
                4: expected_byte = "E";
                5: expected_byte = "C";
                6: expected_byte = "T";
                7: expected_byte = "A";
                8: expected_byte = 8'h0D;
                9: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        3'd3: begin
            case (index)
                0:  expected_byte = "I";
                1:  expected_byte = "N";
                2:  expected_byte = "C";
                3:  expected_byte = "O";
                4:  expected_byte = "R";
                5:  expected_byte = "R";
                6:  expected_byte = "E";
                7:  expected_byte = "C";
                8:  expected_byte = "T";
                9:  expected_byte = "A";
                10: expected_byte = 8'h0D;
                11: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        3'd4: begin
            case (index)
                0: expected_byte = "G";
                1: expected_byte = "A";
                2: expected_byte = "N";
                3: expected_byte = "A";
                4: expected_byte = "S";
                5: expected_byte = "T";
                6: expected_byte = "E";
                7: expected_byte = 8'h0D;
                8: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        3'd5: begin
            case (index)
                0: expected_byte = "P";
                1: expected_byte = "E";
                2: expected_byte = "R";
                3: expected_byte = "D";
                4: expected_byte = "I";
                5: expected_byte = "S";
                6: expected_byte = "T";
                7: expected_byte = "E";
                8: expected_byte = 8'h0D;
                9: expected_byte = 8'h0A;
                default: expected_byte = 8'h00;
            endcase
        end

        default: expected_byte = 8'h00;

    endcase
end
endfunction

task automatic expect_message(input logic [2:0] id);
    integer i;
    integer largo;
    integer errores_inicio;
    logic [7:0] recibido;
begin
    largo = message_length(id);
    errores_inicio = errores;

    for (i = 0; i < largo; i = i + 1) begin
        uart_receive_byte(recibido);

        if (recibido !== expected_byte(id, i)) begin
            $display(
                "FAIL - Mensaje %0d byte %0d: recibido %02h esperado %02h",
                id,
                i,
                recibido,
                expected_byte(id, i)
            );
            errores = errores + 1;
        end
    end

    if (errores == errores_inicio)
        $display("PASS - Mensaje UART ID %0d correcto", id);
end
endtask

initial begin
    clk      = 1'b0;
    reset    = 1'b1;
    BTN_SEL  = 1'b0;
    BTN_OK   = 1'b0;
    uart_rx  = 1'b1;
    errores  = 0;

    $display("========================================");
    $display("PRUEBA PARTIDA FACIL");
    $display("========================================");

    reset_system();

    force game_inst.word_index = 6'd1;

    fork
        expect_message(3'd0);
        press_ok();
    join

    repeat (10) @(posedge clk);

    if (hardmode == 1'b0)
        $display("PASS - Modo facil activo");
    else begin
        $display("FAIL - hardmode deberia ser 0");
        errores = errores + 1;
    end

    if (LargoPalabra == 5'd4)
        $display("PASS - Largo CASA = 4");
    else begin
        $display("FAIL - Largo esperado 4, obtenido %0d", LargoPalabra);
        errores = errores + 1;
    end

    if (TimerS == 6'd60)
        $display("PASS - Timer facil = 60");
    else begin
        $display("FAIL - Timer esperado 60, obtenido %0d", TimerS);
        errores = errores + 1;
    end

    $display("PRUEBA LETRA A");

    fork
        expect_message(3'd2);
        uart_send_byte(8'h41);
    join

    repeat (10) @(posedge clk);

    if (LetrasRestantes == 5'd2)
        $display("PASS - A revela dos posiciones");
    else begin
        $display(
            "FAIL - LetrasRestantes esperado 2, obtenido %0d",
            LetrasRestantes
        );
        errores = errores + 1;
    end

    if ((LetrasReveladas[1] == 1'b1) &&
        (LetrasReveladas[3] == 1'b1))
        $display("PASS - Ambas A fueron reveladas");
    else begin
        $display("FAIL - Posiciones de A incorrectas");
        errores = errores + 1;
    end

    $display("PRUEBA LETRA Z");

    fork
        expect_message(3'd3);
        uart_send_byte(8'h5A);
    join

    repeat (10) @(posedge clk);

    if (Fallos == 3'd1)
        $display("PASS - Fallos = 1");
    else begin
        $display("FAIL - Fallos esperado 1, obtenido %0d", Fallos);
        errores = errores + 1;
    end

    $display("PRUEBA LETRA C");

    fork
        expect_message(3'd2);
        uart_send_byte(8'h43);
    join

    repeat (10) @(posedge clk);

    if (LetrasRestantes == 5'd1)
        $display("PASS - Queda una letra");
    else begin
        $display(
            "FAIL - LetrasRestantes esperado 1, obtenido %0d",
            LetrasRestantes
        );
        errores = errores + 1;
    end

    $display("PRUEBA VICTORIA");

    fork
        begin
            expect_message(3'd2);
            expect_message(3'd4);
        end

        uart_send_byte(8'h53);
    join

    repeat (10) @(posedge clk);

    if (LetrasRestantes == 5'd0)
        $display("PASS - CASA completada");
    else begin
        $display("FAIL - La palabra no fue completada");
        errores = errores + 1;
    end

    if (GameWin)
        $display("PASS - GameWin activo");
    else begin
        $display("FAIL - GameWin no se activo");
        errores = errores + 1;
    end

    release game_inst.word_index;

    $display("========================================");
    $display("PRUEBA MODO DIFICIL");
    $display("========================================");

    reset_system();

    press_sel();

    repeat (5) @(posedge clk);

    if (hardmode)
        $display("PASS - Hardmode seleccionado");
    else begin
        $display("FAIL - Hardmode no fue seleccionado");
        errores = errores + 1;
    end

    fork
        expect_message(3'd1);
        press_ok();
    join

    repeat (10) @(posedge clk);

    if (LargoPalabra > 5)
        $display(
            "PASS - Palabra dificil tiene %0d letras",
            LargoPalabra
        );
    else begin
        $display(
            "FAIL - Palabra dificil tiene solo %0d letras",
            LargoPalabra
        );
        errores = errores + 1;
    end

    if (TimerS == 6'd45)
        $display("PASS - Timer dificil = 45");
    else begin
        $display(
            "FAIL - Timer dificil esperado 45, obtenido %0d",
            TimerS
        );
        errores = errores + 1;
    end

    $display("========================================");
    $display("PRUEBA DERROTA POR 6 FALLOS");
    $display("========================================");

    reset_system();

    force game_inst.word_index = 6'd1;

    fork
        expect_message(3'd0);
        press_ok();
    join

    fork
        expect_message(3'd3);
        uart_send_byte(8'h42);
    join

    fork
        expect_message(3'd3);
        uart_send_byte(8'h44);
    join

    fork
        expect_message(3'd3);
        uart_send_byte(8'h45);
    join

    fork
        expect_message(3'd3);
        uart_send_byte(8'h46);
    join

    fork
        expect_message(3'd3);
        uart_send_byte(8'h47);
    join

    fork
        begin
            expect_message(3'd3);
            expect_message(3'd5);
        end

        uart_send_byte(8'h48);
    join

    repeat (10) @(posedge clk);

    if (Fallos == 3'd6)
        $display("PASS - Fallos = 6");
    else begin
        $display("FAIL - Fallos esperado 6, obtenido %0d", Fallos);
        errores = errores + 1;
    end

    if (GameLose)
        $display("PASS - GameLose activo");
    else begin
        $display("FAIL - GameLose no se activo");
        errores = errores + 1;
    end

    release game_inst.word_index;

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS JUEGO + UART PASARON");
    else
        $display(
            "PRUEBAS FINALIZADAS CON %0d ERRORES",
            errores
        );

    $display("========================================");

    $finish;
end

initial begin
    #50_000_000;

    $display("FAIL - TIMEOUT DE SIMULACION");
    $finish;
end

endmodule
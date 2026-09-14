`timescale 1ns / 1ps

module TOP_GLOBAL_tb;

localparam integer SYS_CLK_FREQ = 100_000_000;
localparam integer BAUD_RATE    = 115_200;
localparam time CLK_PERIOD      = 10ns;
localparam time BIT_TIME        = 8680ns;

localparam logic [2:0] MSG_FACIL      = 3'd0;
localparam logic [2:0] MSG_DIFICIL    = 3'd1;
localparam logic [2:0] MSG_CORRECTA   = 3'd2;
localparam logic [2:0] MSG_INCORRECTA = 3'd3;
localparam logic [2:0] MSG_GANASTE    = 3'd4;
localparam logic [2:0] MSG_PERDISTE   = 3'd5;

logic clk;
logic reset;

logic BTN_SEL_RAW;
logic BTN_OK_RAW;

logic uart_rx;
logic uart_tx;

logic lcd_rs;
logic lcd_rw;
logic lcd_e;
logic [7:0] lcd_data;

logic [6:0] seg;
logic dp;
logic [3:0] an;

logic [15:0] led;
logic buzzer;

integer errores;

TOP_GLOBAL #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) dut (
    .clk(clk),
    .reset(reset),
    .BTN_SEL_RAW(BTN_SEL_RAW),
    .BTN_OK_RAW(BTN_OK_RAW),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
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

always #(CLK_PERIOD/2) clk = ~clk;

function automatic integer uart_length(input logic [2:0] id);
begin
    case (id)
        MSG_FACIL:      uart_length = 7;
        MSG_DIFICIL:    uart_length = 9;
        MSG_CORRECTA:   uart_length = 10;
        MSG_INCORRECTA: uart_length = 12;
        MSG_GANASTE:    uart_length = 9;
        MSG_PERDISTE:   uart_length = 10;
        default:        uart_length = 0;
    endcase
end
endfunction

function automatic logic [7:0] uart_byte(
    input logic [2:0] id,
    input integer index
);
begin
    uart_byte = 8'h00;

    case (id)
        MSG_FACIL: begin
            case (index)
                0: uart_byte = "F";
                1: uart_byte = "A";
                2: uart_byte = "C";
                3: uart_byte = "I";
                4: uart_byte = "L";
                5: uart_byte = 8'h0D;
                6: uart_byte = 8'h0A;
            endcase
        end

        MSG_DIFICIL: begin
            case (index)
                0: uart_byte = "D";
                1: uart_byte = "I";
                2: uart_byte = "F";
                3: uart_byte = "I";
                4: uart_byte = "C";
                5: uart_byte = "I";
                6: uart_byte = "L";
                7: uart_byte = 8'h0D;
                8: uart_byte = 8'h0A;
            endcase
        end

        MSG_CORRECTA: begin
            case (index)
                0: uart_byte = "C";
                1: uart_byte = "O";
                2: uart_byte = "R";
                3: uart_byte = "R";
                4: uart_byte = "E";
                5: uart_byte = "C";
                6: uart_byte = "T";
                7: uart_byte = "A";
                8: uart_byte = 8'h0D;
                9: uart_byte = 8'h0A;
            endcase
        end

        MSG_INCORRECTA: begin
            case (index)
                0:  uart_byte = "I";
                1:  uart_byte = "N";
                2:  uart_byte = "C";
                3:  uart_byte = "O";
                4:  uart_byte = "R";
                5:  uart_byte = "R";
                6:  uart_byte = "E";
                7:  uart_byte = "C";
                8:  uart_byte = "T";
                9:  uart_byte = "A";
                10: uart_byte = 8'h0D;
                11: uart_byte = 8'h0A;
            endcase
        end

        MSG_GANASTE: begin
            case (index)
                0: uart_byte = "G";
                1: uart_byte = "A";
                2: uart_byte = "N";
                3: uart_byte = "A";
                4: uart_byte = "S";
                5: uart_byte = "T";
                6: uart_byte = "E";
                7: uart_byte = 8'h0D;
                8: uart_byte = 8'h0A;
            endcase
        end

        MSG_PERDISTE: begin
            case (index)
                0: uart_byte = "P";
                1: uart_byte = "E";
                2: uart_byte = "R";
                3: uart_byte = "D";
                4: uart_byte = "I";
                5: uart_byte = "S";
                6: uart_byte = "T";
                7: uart_byte = "E";
                8: uart_byte = 8'h0D;
                9: uart_byte = 8'h0A;
            endcase
        end
    endcase
end
endfunction

function automatic logic [7:0] lcd_facil_byte(input integer index);
begin
    case (index)
        0: lcd_facil_byte = "F";
        1: lcd_facil_byte = "A";
        2: lcd_facil_byte = "C";
        3: lcd_facil_byte = "I";
        4: lcd_facil_byte = "L";
        default: lcd_facil_byte = 8'h00;
    endcase
end
endfunction

function automatic logic [7:0] lcd_win_byte(input integer index);
begin
    case (index)
        0: lcd_win_byte = "G";
        1: lcd_win_byte = "A";
        2: lcd_win_byte = "N";
        3: lcd_win_byte = "A";
        4: lcd_win_byte = "S";
        5: lcd_win_byte = "T";
        6: lcd_win_byte = "E";
        default: lcd_win_byte = 8'h00;
    endcase
end
endfunction

task automatic reset_system;
begin
    reset       = 1'b1;
    BTN_SEL_RAW = 1'b0;
    BTN_OK_RAW  = 1'b0;
    uart_rx     = 1'b1;

    repeat (10) @(posedge clk);

    @(negedge clk);
    reset = 1'b0;

    repeat (10) @(posedge clk);
end
endtask

task automatic press_sel;
begin
    @(negedge clk);
    BTN_SEL_RAW = 1'b1;
    #12_000_000;

    @(negedge clk);
    BTN_SEL_RAW = 1'b0;
    #12_000_000;
end
endtask

task automatic press_ok;
begin
    @(negedge clk);
    BTN_OK_RAW = 1'b1;
    #12_000_000;

    @(negedge clk);
    BTN_OK_RAW = 1'b0;
    #12_000_000;
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

task automatic expect_uart_message(input logic [2:0] id);
    integer i;
    integer errores_inicio;
    logic [7:0] recibido;
begin
    errores_inicio = errores;

    for (i = 0; i < uart_length(id); i = i + 1) begin
        uart_receive_byte(recibido);

        if (recibido !== uart_byte(id, i)) begin
            $display(
                "FAIL - UART ID %0d byte %0d: recibido %02h esperado %02h",
                id, i, recibido, uart_byte(id, i)
            );
            errores = errores + 1;
        end
    end

    if (errores == errores_inicio)
        $display("PASS - Mensaje UART ID %0d correcto", id);
end
endtask

task automatic expect_lcd_byte(input logic [7:0] esperado);
    logic encontrado;
begin
    encontrado = 1'b0;

    while (!encontrado) begin
        @(posedge lcd_e);
        #1;

        if (lcd_rs) begin
            encontrado = 1'b1;

            if (lcd_data !== esperado) begin
                $display(
                    "FAIL - LCD recibido %c (%02h), esperado %c (%02h)",
                    lcd_data, lcd_data, esperado, esperado
                );
                errores = errores + 1;
            end
        end
    end
end
endtask

task automatic expect_lcd_facil;
    integer i;
    integer errores_inicio;
begin
    errores_inicio = errores;

    for (i = 0; i < 5; i = i + 1)
        expect_lcd_byte(lcd_facil_byte(i));

    if (errores == errores_inicio)
        $display("PASS - LCD muestra FACIL");
end
endtask

task automatic expect_lcd_dashes(input integer cantidad);
    integer i;
    integer errores_inicio;
begin
    errores_inicio = errores;

    for (i = 0; i < cantidad; i = i + 1)
        expect_lcd_byte("-");

    if (errores == errores_inicio)
        $display("PASS - LCD muestra %0d guiones", cantidad);
end
endtask

task automatic expect_lcd_ganaste;
    integer i;
    integer errores_inicio;
begin
    errores_inicio = errores;

    for (i = 0; i < 7; i = i + 1)
        expect_lcd_byte(lcd_win_byte(i));

    if (errores == errores_inicio)
        $display("PASS - LCD muestra GANASTE");
end
endtask

task automatic send_wrong(input logic [7:0] letra);
begin
    fork
        expect_uart_message(MSG_INCORRECTA);
        uart_send_byte(letra);
    join
end
endtask

initial begin
    clk             = 1'b0;
    reset           = 1'b1;
    BTN_SEL_RAW     = 1'b0;
    BTN_OK_RAW      = 1'b0;
    uart_rx         = 1'b1;
    errores         = 0;

    $display("========================================");
    $display("PRUEBA FINAL TOP_GLOBAL");
    $display("========================================");

    reset_system();

    $display("PRUEBA INICIALIZACION");

    expect_lcd_facil();

    if (led == 16'h0001)
        $display("PASS - LED seleccion de modo");
    else begin
        $display("FAIL - LED inicial = %04h", led);
        errores = errores + 1;
    end

    $display("========================================");
    $display("PARTIDA FACIL - CASA");
    $display("========================================");

    force dut.game_inst.word_index = 6'd1;

    fork
        expect_uart_message(MSG_FACIL);
        expect_lcd_dashes(4);
        press_ok();
    join

    repeat (10) @(posedge clk);

    if (!dut.hardmode)
        $display("PASS - Modo facil");
    else begin
        $display("FAIL - hardmode deberia ser 0");
        errores = errores + 1;
    end

    if (dut.LargoPalabra == 5'd4)
        $display("PASS - Palabra CASA cargada");
    else begin
        $display(
            "FAIL - Largo esperado 4, obtenido %0d",
            dut.LargoPalabra
        );
        errores = errores + 1;
    end

    if (dut.TimerS == 6'd60)
        $display("PASS - Timer = 60");
    else begin
        $display(
            "FAIL - Timer esperado 60, obtenido %0d",
            dut.TimerS
        );
        errores = errores + 1;
    end

    if (led == 16'h0002)
        $display("PASS - LED partida activa");
    else begin
        $display("FAIL - LED partida = %04h", led);
        errores = errores + 1;
    end

    $display("PRUEBA LETRA A");

    fork
        expect_uart_message(MSG_CORRECTA);

        begin
            expect_lcd_byte("A");
            expect_lcd_byte("A");
        end

        uart_send_byte("A");
    join

    repeat (10) @(posedge clk);

    if (dut.LetrasRestantes == 5'd2)
        $display("PASS - A revela ambas posiciones");
    else begin
        $display(
            "FAIL - LetrasRestantes = %0d",
            dut.LetrasRestantes
        );
        errores = errores + 1;
    end

    $display("PRUEBA LETRA Z");

    fork
        expect_uart_message(MSG_INCORRECTA);
        uart_send_byte("Z");
    join

    repeat (10) @(posedge clk);

    if (dut.Fallos == 3'd1)
        $display("PASS - Fallos = 1");
    else begin
        $display("FAIL - Fallos = %0d", dut.Fallos);
        errores = errores + 1;
    end

    $display("PRUEBA LETRA C");

    fork
        expect_uart_message(MSG_CORRECTA);
        expect_lcd_byte("C");
        uart_send_byte("C");
    join

    repeat (10) @(posedge clk);

    if (dut.LetrasRestantes == 5'd1)
        $display("PASS - Queda una letra");
    else begin
        $display(
            "FAIL - LetrasRestantes = %0d",
            dut.LetrasRestantes
        );
        errores = errores + 1;
    end

    $display("PRUEBA VICTORIA");

    fork
        begin
            expect_uart_message(MSG_CORRECTA);
            expect_uart_message(MSG_GANASTE);
        end

        begin
            expect_lcd_byte("S");
            expect_lcd_ganaste();
        end

        uart_send_byte("S");
    join

    repeat (20) @(posedge clk);

    if (dut.GameWin)
        $display("PASS - GameWin activo");
    else begin
        $display("FAIL - GameWin no activo");
        errores = errores + 1;
    end

    if (led == 16'h0004)
        $display("PASS - LED resultado");
    else begin
        $display("FAIL - LED resultado = %04h", led);
        errores = errores + 1;
    end

    if ((dut.peri_inst.wins_tens == 4'd0) &&
        (dut.peri_inst.wins_ones == 4'd1))
        $display("PASS - Victorias = 01");
    else begin
        $display(
            "FAIL - Victorias = %0d%0d",
            dut.peri_inst.wins_tens,
            dut.peri_inst.wins_ones
        );
        errores = errores + 1;
    end

    release dut.game_inst.word_index;

    $display("========================================");
    $display("PRUEBA MODO DIFICIL");
    $display("========================================");

    reset_system();

    press_sel();

    repeat (10) @(posedge clk);

    if (dut.hardmode)
        $display("PASS - Hardmode seleccionado");
    else begin
        $display("FAIL - Hardmode no seleccionado");
        errores = errores + 1;
    end

    fork
        expect_uart_message(MSG_DIFICIL);
        press_ok();
    join

    repeat (20) @(posedge clk);

    if (dut.LargoPalabra > 5)
        $display(
            "PASS - Palabra dificil de %0d letras",
            dut.LargoPalabra
        );
    else begin
        $display(
            "FAIL - Palabra dificil tiene %0d letras",
            dut.LargoPalabra
        );
        errores = errores + 1;
    end

    if (dut.TimerS == 6'd45)
        $display("PASS - Timer dificil = 45");
    else begin
        $display(
            "FAIL - Timer dificil = %0d",
            dut.TimerS
        );
        errores = errores + 1;
    end

    $display("========================================");
    $display("PRUEBA DERROTA POR 6 FALLOS");
    $display("========================================");

    reset_system();

    force dut.game_inst.word_index = 6'd1;

    fork
        expect_uart_message(MSG_FACIL);
        press_ok();
    join

    send_wrong("B");
    send_wrong("D");
    send_wrong("E");
    send_wrong("F");
    send_wrong("G");

    fork
        begin
            expect_uart_message(MSG_INCORRECTA);
            expect_uart_message(MSG_PERDISTE);
        end

        uart_send_byte("H");
    join

    repeat (20) @(posedge clk);

    if (dut.Fallos == 3'd6)
        $display("PASS - Fallos = 6");
    else begin
        $display(
            "FAIL - Fallos esperado 6, obtenido %0d",
            dut.Fallos
        );
        errores = errores + 1;
    end

    if (dut.GameLose)
        $display("PASS - GameLose activo");
    else begin
        $display("FAIL - GameLose no activo");
        errores = errores + 1;
    end

    if (led == 16'h0004)
        $display("PASS - LED resultado derrota");
    else begin
        $display(
            "FAIL - LED derrota = %04h",
            led
        );
        errores = errores + 1;
    end

    release dut.game_inst.word_index;

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS DE TOP_GLOBAL PASARON");
    else
        $display(
            "TOP_GLOBAL FINALIZO CON %0d ERRORES",
            errores
        );

    $display("========================================");

    $finish;
end

initial begin
    #500_000_000;

    $display("FAIL - TIMEOUT DE SIMULACION TOP_GLOBAL");
    $finish;
end

endmodule
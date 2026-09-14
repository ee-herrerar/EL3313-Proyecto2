`timescale 1ns / 1ps

module TOP_PERI_tb;

logic clk;
logic reset;

logic BTN_SEL_RAW;
logic BTN_OK_RAW;

logic [5:0] TimerS;
logic [2:0] Fallos;
logic hardmode;
logic GameOn;
logic GameWin;
logic GameLose;
logic [95:0] PalabraActual;
logic [4:0] LargoPalabra;
logic [11:0] LetrasReveladas;

logic BTN_SEL;
logic BTN_OK;

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
integer sel_pulsos;
integer ok_pulsos;
integer correct_pulsos;
integer incorrect_pulsos;
integer win_pulsos;
integer lose_pulsos;

TOP_PERI dut (
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

always #5 clk = ~clk;

always @(posedge clk) begin
    if (BTN_SEL)
        sel_pulsos = sel_pulsos + 1;

    if (BTN_OK)
        ok_pulsos = ok_pulsos + 1;

    if (dut.correct_pulse)
        correct_pulsos = correct_pulsos + 1;

    if (dut.incorrect_pulse)
        incorrect_pulsos = incorrect_pulsos + 1;

    if (dut.win_pulse)
        win_pulsos = win_pulsos + 1;

    if (dut.lose_pulse)
        lose_pulsos = lose_pulsos + 1;
end

function automatic logic [7:0] facil_byte(input integer index);
begin
    case (index)
        0: facil_byte = "F";
        1: facil_byte = "A";
        2: facil_byte = "C";
        3: facil_byte = "I";
        4: facil_byte = "L";
        default: facil_byte = 8'h00;
    endcase
end
endfunction

function automatic logic [6:0] seg_value(input logic [3:0] bcd);
begin
    case (bcd)
        4'd0: seg_value = 7'b1000000;
        4'd1: seg_value = 7'b1111001;
        4'd2: seg_value = 7'b0100100;
        4'd3: seg_value = 7'b0110000;
        4'd4: seg_value = 7'b0011001;
        4'd5: seg_value = 7'b0010010;
        4'd6: seg_value = 7'b0000010;
        4'd7: seg_value = 7'b1111000;
        4'd8: seg_value = 7'b0000000;
        4'd9: seg_value = 7'b0010000;
        default: seg_value = 7'b1111111;
    endcase
end
endfunction

task automatic reset_system;
begin
    reset = 1'b1;
    BTN_SEL_RAW = 1'b0;
    BTN_OK_RAW = 1'b0;
    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;
    Fallos = 3'd0;
    LetrasReveladas = 12'b0;

    repeat (10) @(posedge clk);
    @(negedge clk);
    reset = 1'b0;
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

task automatic expect_facil;
    integer i;
    integer errores_inicio;
begin
    errores_inicio = errores;

    for (i = 0; i < 5; i = i + 1)
        expect_lcd_byte(facil_byte(i));

    if (errores == errores_inicio)
        $display("PASS - TOP_LCD integrado correctamente");
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

task automatic pulse_gameon;
begin
    @(negedge clk);
    GameOn = 1'b1;
    @(negedge clk);
    GameOn = 1'b0;
end
endtask

task automatic check_digit(
    input logic [3:0] an_expected,
    input logic [3:0] bcd_expected
);
    integer timeout;
begin
    timeout = 0;

    while ((an !== an_expected) && (timeout < 500_000)) begin
        @(posedge clk);
        timeout = timeout + 1;
    end

    #1;

    if (timeout == 500_000) begin
        $display("FAIL - Timeout esperando digito %b", an_expected);
        errores = errores + 1;
    end
    else if (seg !== seg_value(bcd_expected)) begin
        $display(
            "FAIL - Digito %b: seg=%07b esperado=%07b",
            an_expected, seg, seg_value(bcd_expected)
        );
        errores = errores + 1;
    end
end
endtask

initial begin
    integer antes;

    clk = 1'b0;
    reset = 1'b1;

    BTN_SEL_RAW = 1'b0;
    BTN_OK_RAW = 1'b0;

    TimerS = 6'd45;
    Fallos = 3'd0;
    hardmode = 1'b0;

    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;

    PalabraActual = {8'h43,8'h41,8'h53,8'h41,64'd0};
    LargoPalabra = 5'd4;
    LetrasReveladas = 12'b0;

    errores = 0;
    sel_pulsos = 0;
    ok_pulsos = 0;
    correct_pulsos = 0;
    incorrect_pulsos = 0;
    win_pulsos = 0;
    lose_pulsos = 0;

    $display("========================================");
    $display("PRUEBA TOP_PERI");
    $display("========================================");

    reset_system();

    $display("PRUEBA LCD");
    expect_facil();

    $display("PRUEBA LED ESTADO INICIAL");

    if (led == 16'h0001)
        $display("PASS - LED seleccion de modo");
    else begin
        $display("FAIL - LED inicial = %04h", led);
        errores = errores + 1;
    end

    $display("PRUEBA DISPLAY TIMER = 45");

    #100;

    if ((dut.time_tens == 4'd4) &&
        (dut.time_ones == 4'd5))
        $display("PASS - Conversion TimerS 45 -> 4,5");
    else begin
        $display(
            "FAIL - Timer BCD = %0d,%0d",
            dut.time_tens, dut.time_ones
        );
        errores = errores + 1;
    end

    check_digit(4'b0111, 4'd4);
    check_digit(4'b1011, 4'd5);
    check_digit(4'b1101, 4'd0);
    check_digit(4'b1110, 4'd0);

    if (dp == 1'b1)
        $display("PASS - Punto decimal apagado");
    else begin
        $display("FAIL - Punto decimal encendido");
        errores = errores + 1;
    end

    $display("PRUEBA BTN_SEL");

    antes = sel_pulsos;
    press_sel();

    if (sel_pulsos == antes + 1)
        $display("PASS - BTN_SEL genero un pulso");
    else begin
        $display(
            "FAIL - BTN_SEL genero %0d pulsos",
            sel_pulsos - antes
        );
        errores = errores + 1;
    end

    $display("PRUEBA BTN_OK");

    antes = ok_pulsos;
    press_ok();

    if (ok_pulsos == antes + 1)
        $display("PASS - BTN_OK genero un pulso");
    else begin
        $display(
            "FAIL - BTN_OK genero %0d pulsos",
            ok_pulsos - antes
        );
        errores = errores + 1;
    end

    $display("PRUEBA ESTADO PARTIDA");

    pulse_gameon();
    repeat (5) @(posedge clk);

    if (led == 16'h0002)
        $display("PASS - LED partida activa");
    else begin
        $display("FAIL - LED partida = %04h", led);
        errores = errores + 1;
    end

    $display("PRUEBA SONIDO LETRA CORRECTA");

    antes = correct_pulsos;

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_0010;

    repeat (3) @(posedge clk);

    if (correct_pulsos == antes + 1)
        $display("PASS - Pulso de letra correcta");
    else begin
        $display("FAIL - Pulso de letra correcta");
        errores = errores + 1;
    end

    #260_000;

    if (buzzer)
        $display("PASS - Buzzer correcto activo");
    else begin
        $display("FAIL - Buzzer correcto no activo");
        errores = errores + 1;
    end

    $display("PRUEBA SONIDO LETRA INCORRECTA");

    antes = incorrect_pulsos;

    @(negedge clk);
    Fallos = 3'd1;

    repeat (3) @(posedge clk);

    if (incorrect_pulsos == antes + 1)
        $display("PASS - Pulso de letra incorrecta");
    else begin
        $display("FAIL - Pulso de letra incorrecta");
        errores = errores + 1;
    end

    #1_050_000;

    if (buzzer)
        $display("PASS - Buzzer incorrecto activo");
    else begin
        $display("FAIL - Buzzer incorrecto no activo");
        errores = errores + 1;
    end

    $display("PRUEBA VICTORIA Y PRIORIDAD BUZZER");

    antes = correct_pulsos;

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_0011;
    GameWin = 1'b1;

    repeat (3) @(posedge clk);

    if (win_pulsos == 1)
        $display("PASS - Pulso de victoria");
    else begin
        $display("FAIL - Pulsos de victoria = %0d", win_pulsos);
        errores = errores + 1;
    end

    if (correct_pulsos == antes)
        $display("PASS - Victoria tiene prioridad sobre sonido correcto");
    else begin
        $display("FAIL - Se genero sonido correcto junto con victoria");
        errores = errores + 1;
    end

    if (led == 16'h0004)
        $display("PASS - LED resultado activo");
    else begin
        $display("FAIL - LED resultado = %04h", led);
        errores = errores + 1;
    end

    if ((dut.wins_tens == 4'd0) &&
        (dut.wins_ones == 4'd1))
        $display("PASS - Contador de victorias = 01");
    else begin
        $display(
            "FAIL - Victorias = %0d%0d",
            dut.wins_tens, dut.wins_ones
        );
        errores = errores + 1;
    end

    repeat (20) @(posedge clk);

    if (dut.wins_ones == 4'd1)
        $display("PASS - GameWin sostenido no cuenta doble");
    else begin
        $display("FAIL - GameWin conto mas de una victoria");
        errores = errores + 1;
    end

    #650_000;

    if (buzzer)
        $display("PASS - Buzzer victoria activo");
    else begin
        $display("FAIL - Buzzer victoria no activo");
        errores = errores + 1;
    end

    @(negedge clk);
    GameWin = 1'b0;

    repeat (5) @(posedge clk);

    $display("PRUEBA DERROTA Y PRIORIDAD BUZZER");

    antes = incorrect_pulsos;

    @(negedge clk);
    Fallos = 3'd2;
    GameLose = 1'b1;

    repeat (3) @(posedge clk);

    if (lose_pulsos == 1)
        $display("PASS - Pulso de derrota");
    else begin
        $display("FAIL - Pulsos de derrota = %0d", lose_pulsos);
        errores = errores + 1;
    end

    if (incorrect_pulsos == antes)
        $display("PASS - Derrota tiene prioridad sobre sonido incorrecto");
    else begin
        $display("FAIL - Se genero sonido incorrecto junto con derrota");
        errores = errores + 1;
    end

    if (led == 16'h0004)
        $display("PASS - LED resultado en derrota");
    else begin
        $display("FAIL - LED derrota = %04h", led);
        errores = errores + 1;
    end

    #1_700_000;

    if (buzzer)
        $display("PASS - Buzzer derrota activo");
    else begin
        $display("FAIL - Buzzer derrota no activo");
        errores = errores + 1;
    end

    @(negedge clk);
    GameLose = 1'b0;

    repeat (5) @(posedge clk);

    if (led == 16'h0001)
        $display("PASS - Regreso a seleccion de modo");
    else begin
        $display("FAIL - LED final = %04h", led);
        errores = errores + 1;
    end

    check_digit(4'b1110, 4'd1);

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS DE TOP_PERI PASARON");
    else
        $display(
            "PRUEBAS TOP_PERI FINALIZADAS CON %0d ERRORES",
            errores
        );

    $display("========================================");

    $finish;
end

initial begin
    #400_000_000;
    $display("FAIL - TIMEOUT DE SIMULACION TOP_PERI");
    $finish;
end

endmodule
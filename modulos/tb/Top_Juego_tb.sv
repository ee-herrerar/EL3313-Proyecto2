`timescale 1ns/1ps

module Top_Juego_tb;

logic clk,RESET,BTN_SEL,BTN_OK,NuevaLetra;
logic [7:0] LetraUART;
logic [5:0] TimerS;
logic [2:0] Fallos;
logic hardmode,GameWin,GameLose;
logic [95:0] PalabraActual;
logic [4:0] LargoPalabra,LetrasRestantes;
logic [11:0] LetrasReveladas;
integer errores;

localparam [3:0] ST_SELECCION = 4'd0;
localparam [3:0] ST_LLAMADA   = 4'd1;
localparam [3:0] ST_ACTIVA    = 4'd2;
localparam [3:0] ST_COMPROBAR = 4'd3;
localparam [3:0] ST_SEL_LETRA = 4'd4;
localparam [3:0] ST_CORRECTA  = 4'd5;
localparam [3:0] ST_INCORRECTA= 4'd6;
localparam [3:0] ST_LOSE      = 4'd7;
localparam [3:0] ST_WIN       = 4'd8;

Top_Juego dut(
    .clk(clk),
    .RESET(RESET),
    .BTN_SEL(BTN_SEL),
    .BTN_OK(BTN_OK),
    .NuevaLetra(NuevaLetra),
    .LetraUART(LetraUART),
    .TimerS(TimerS),
    .Fallos(Fallos),
    .hardmode(hardmode),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),
    .LetrasRestantes(LetrasRestantes)
);

always #5 clk=~clk;

task automatic pulso_OK;
begin
    @(negedge clk);
    BTN_OK=1'b1;
    @(posedge clk);
    #1;
    @(negedge clk);
    BTN_OK=1'b0;
end
endtask

task automatic pulso_SEL;
begin
    @(negedge clk);
    BTN_SEL=1'b1;
    @(posedge clk);
    #1;
    @(negedge clk);
    BTN_SEL=1'b0;
end
endtask

task automatic enviar_letra(input logic [7:0] letra);
begin
    @(negedge clk);
    LetraUART=letra;
    NuevaLetra=1'b1;
    @(posedge clk);
    #1;
    @(negedge clk);
    NuevaLetra=1'b0;
end
endtask

task automatic comprobar(input logic condicion,input string mensaje);
begin
    if(condicion)
        $display("PASS - %s",mensaje);
    else begin
        $display("ERROR - %s",mensaje);
        errores=errores+1;
    end
end
endtask

initial begin
    clk=0;
    RESET=1;
    BTN_SEL=0;
    BTN_OK=0;
    NuevaLetra=0;
    LetraUART=0;
    errores=0;

    force dut.word_index=6'd1;

    #20;
    RESET=0;
    @(posedge clk);
    #1;

    $display("----------------------------------");
    $display("PRUEBA RESET");
    comprobar(dut.fsm_inst.estado_actual==ST_SELECCION,"Estado inicial");
    comprobar(Fallos==0,"Fallos = 0");
    comprobar(GameWin==0 && GameLose==0,"GameOver desactivado");

    $display("----------------------------------");
    $display("PRUEBA ROM");
    #1;
    comprobar(LargoPalabra==5'd4,"Largo CASA = 4");
    comprobar(PalabraActual[95:64]==32'h43415341,"Palabra = CASA");

    $display("----------------------------------");
    $display("PRUEBA DIFICULTAD");
    pulso_SEL();
    comprobar(hardmode==1,"Hardmode = 1");
    pulso_SEL();
    comprobar(hardmode==0,"Hardmode = 0");

    $display("----------------------------------");
    $display("PRUEBA INICIO");
    pulso_OK();
    comprobar(dut.fsm_inst.estado_actual==ST_LLAMADA,"Estado LlamadaPalabra");

    @(posedge clk);
    #1;
    @(posedge clk);
    #1;

    comprobar(dut.fsm_inst.estado_actual==ST_ACTIVA,"Estado PalabraActiva");
    comprobar(LetrasRestantes==5'd4,"LetrasRestantes = 4");
    comprobar(TimerS==6'd60,"Timer = 60");

    $display("----------------------------------");
    $display("PRUEBA LETRA A");
    enviar_letra(8'h41);

    @(posedge clk); #1;
    @(posedge clk); #1;
    comprobar(dut.fsm_inst.estado_actual==ST_CORRECTA,"A es correcta");

    @(posedge clk); #1;
    comprobar(LetrasRestantes==5'd2,"Quedan 2 letras");
    comprobar(LetrasReveladas==12'b000000001010,"Dos A reveladas");

    @(posedge clk); #1;
    @(posedge clk); #1;
    comprobar(dut.fsm_inst.estado_actual==ST_ACTIVA,"Regresa a PalabraActiva");

    $display("----------------------------------");
    $display("PRUEBA LETRA REPETIDA");
    enviar_letra(8'h41);
    @(posedge clk); #1;
    @(posedge clk); #1;
    comprobar(dut.fsm_inst.estado_actual==ST_ACTIVA,"A repetida ignorada");
    comprobar(LetrasRestantes==5'd2,"No cambia LetrasRestantes");
    comprobar(Fallos==0,"No aumenta Fallos");

    $display("----------------------------------");
    $display("PRUEBA LETRA Z");
    enviar_letra(8'h5A);

    @(posedge clk); #1;
    @(posedge clk); #1;
    comprobar(dut.fsm_inst.estado_actual==ST_INCORRECTA,"Z es incorrecta");

    @(posedge clk); #1;
    comprobar(Fallos==3'd1,"Fallos = 1");

    @(posedge clk); #1;
    @(posedge clk); #1;
    comprobar(dut.fsm_inst.estado_actual==ST_ACTIVA,"Regresa a PalabraActiva");

    $display("----------------------------------");
    $display("PRUEBA VICTORIA");

    enviar_letra(8'h43);
    repeat(3) begin @(posedge clk); #1; end
    comprobar(LetrasRestantes==5'd1,"C deja 1 letra");
    repeat(2) begin @(posedge clk); #1; end

    enviar_letra(8'h53);
    repeat(3) begin @(posedge clk); #1; end
    comprobar(LetrasRestantes==5'd0,"S completa CASA");

    @(posedge clk);
    #1;
    comprobar(dut.fsm_inst.estado_actual==ST_WIN,"Estado GameOverWIN");
    comprobar(GameWin==1,"GameWin = 1");

    release dut.word_index;

    $display("----------------------------------");
    if(errores==0) begin
        $display("==================================");
        $display("TODAS LAS PRUEBAS PASARON");
        $display("==================================");
    end
    else begin
        $display("==================================");
        $display("PRUEBAS FALLIDAS: %0d",errores);
        $display("==================================");
    end

    $finish;
end

endmodule
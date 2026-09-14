module status_led (
    input  logic [1:0]  game_state,
    output logic [15:0] led
);

    localparam logic [1:0] STATE_MODE_SELECT = 2'd0;
    localparam logic [1:0] STATE_PLAYING     = 2'd1;
    localparam logic [1:0] STATE_RESULT      = 2'd2;

    always_comb begin
        led = 16'h0000;
        unique case (game_state)
            STATE_MODE_SELECT: led[0] = 1'b1; // pantalla de seleccion de modo
            STATE_PLAYING:     led[1] = 1'b1; // partida en curso
            STATE_RESULT:      led[2] = 1'b1; // mostrando resultado final
            default:           led[0] = 1'b1;
        endcase
    end

endmodule

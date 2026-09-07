module LEDStatus (
    input  logic       GameActivo,
    input  logic       GameOver,
    input  logic       UltimoAcierto,
    input  logic       UltimoFallo,

    output logic [3:0] LED
);

    always_comb begin

        LED = 4'b0000;

        LED[0] = GameActivo;
        LED[1] = GameOver;
        LED[2] = UltimoAcierto;
        LED[3] = UltimoFallo;

    end

endmodule

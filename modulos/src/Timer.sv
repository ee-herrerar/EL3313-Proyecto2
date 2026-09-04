module Timer (
    input  logic       clk,
    input  logic       rst,
    input  logic       hardmode,
    input  logic       GameOn,

    output logic [5:0] TimerS,
    output logic       TimeOut
);

    logic        Active;
    logic        GameOnPrev;

    logic [16:0] ContadorCiclos;
    logic [10:0] ContadorMs;


    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            ContadorCiclos <= 17'd0;
            ContadorMs     <= 11'd0;
            Active         <= 1'b0;
            GameOnPrev     <= 1'b0;
            TimerS         <= 6'd0;
            TimeOut        <= 1'b0;
        end

        else begin

            // Guardar estado anterior de GameOn
            GameOnPrev <= GameOn;


            // Detectar inicio de una nueva partida
            if (GameOn && !GameOnPrev) begin

                ContadorCiclos <= 17'd0;
                ContadorMs     <= 11'd0;
                Active         <= 1'b1;
                TimeOut        <= 1'b0;

                if (hardmode) begin
                    TimerS <= 6'd45;
                end
                else begin
                    TimerS <= 6'd60;
                end

            end


            // Timer activo
            else if (Active) begin

                // 100 000 ciclos a 100 MHz = 1 ms
                if (ContadorCiclos == 17'd99999) begin

                    ContadorCiclos <= 17'd0;

                    // 1000 ms = 1 segundo
                    if (ContadorMs == 11'd999) begin

                        ContadorMs <= 11'd0;

                        // Ultimo segundo
                        if (TimerS == 6'd1) begin
                            TimerS  <= 6'd0;
                            TimeOut <= 1'b1;
                            Active  <= 1'b0;
                        end

                        // Decrementar tiempo
                        else if (TimerS > 6'd1) begin
                            TimerS <= TimerS - 6'd1;
                        end

                    end

                    else begin
                        ContadorMs <= ContadorMs + 11'd1;
                    end

                end

                else begin
                    ContadorCiclos <= ContadorCiclos + 17'd1;
                end

            end

        end

    end

endmodule
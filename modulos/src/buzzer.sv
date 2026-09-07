module Buzzer #(
    parameter int unsigned CLK_FREQ = 100_000_000
)(
    input  logic clk,
    input  logic RESET,

    input  logic Acierto,
    input  logic Fallo,
    input  logic GameOver,

    output logic buzzer
);

    
    // Frecuencias
    

    localparam int unsigned FREQ_ACIERTO = 2000;
    localparam int unsigned FREQ_FALLO  = 500;
    localparam int unsigned FREQ_GAMEOVER = 300;

    // Duraciones
    localparam int unsigned TIME_ACIERTO_MS = 150;
    localparam int unsigned TIME_FALLO_MS   = 250;
    localparam int unsigned TIME_GAMEOVER_MS = 1000;

    // Estado interno
    

    logic active;

    logic [31:0] frequency;
    logic [31:0] duration_ms;

    logic [31:0] tone_counter;
    logic [31:0] time_counter;

    logic [31:0] half_period;

    
    // Generación de tono

    always_comb begin

        if (frequency != 0)
            half_period = CLK_FREQ / (2 * frequency);
        else
            half_period = 32'd1;

    end

    // Control del buzzer

    always_ff @(posedge clk) begin

        if (RESET) begin

            active      <= 1'b0;
            frequency   <= 32'd0;
            duration_ms <= 32'd0;

            tone_counter <= 32'd0;
            time_counter <= 32'd0;

            buzzer <= 1'b0;

        end

        else begin

          
            // Comienza Game Over
            

            if (GameOver && !active) begin

                active      <= 1'b1;
                frequency   <= FREQ_GAMEOVER;
                duration_ms <= TIME_GAMEOVER_MS;

                tone_counter <= 32'd0;
                time_counter <= 32'd0;

            end
          
            // Comienza acierto

            else if (Acierto && !active) begin

                active      <= 1'b1;
                frequency   <= FREQ_ACIERTO;
                duration_ms <= TIME_ACIERTO_MS;

                tone_counter <= 32'd0;
                time_counter <= 32'd0;

            end
          
            // Comienza fallo
    

            else if (Fallo && !active) begin

                active      <= 1'b1;
                frequency   <= FREQ_FALLO;
                duration_ms <= TIME_FALLO_MS;

                tone_counter <= 32'd0;
                time_counter <= 32'd0;

            end

            // Tono activo

            else if (active) begin

                // Generador de onda cuadrada

                if (tone_counter >= half_period - 1) begin

                    tone_counter <= 32'd0;
                    buzzer <= ~buzzer;

                end

                else begin

                    tone_counter <= tone_counter + 1'b1;

                end

                // Temporización aproximada en milisegundo

                if (time_counter >=
                    ((CLK_FREQ / 1000) * duration_ms) - 1) begin

                    active       <= 1'b0;
                    frequency    <= 32'd0;
                    time_counter <= 32'd0;
                    tone_counter <= 32'd0;

                    buzzer <= 1'b0;

                end

                else begin

                    time_counter <= time_counter + 1'b1;

                end

            end

            else begin

                buzzer <= 1'b0;

            end

        end

    end

endmodule

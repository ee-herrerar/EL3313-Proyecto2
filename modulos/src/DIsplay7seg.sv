module seven_seg_mux #(
    parameter integer CLK_FREQ_HZ    = 100_000_000,
    parameter integer REFRESH_HZ     = 1000          // refresco por digito
)(
    input  logic       clk,
    input  logic       rst,
    input  logic [3:0] time_tens,
    input  logic [3:0] time_ones,
    input  logic [3:0] wins_tens,
    input  logic [3:0] wins_ones,
    output logic [6:0] seg,
    output logic       dp,
    output logic [3:0] an
);
 
    // divisor de reloj: genera un pulso de habilitacion (clockenable) cada vez que toca cambiar de digito 
    
    localparam integer TICKS_PER_DIGIT = CLK_FREQ_HZ / REFRESH_HZ;
    localparam integer TICK_WIDTH      = $clog2(TICKS_PER_DIGIT);
 
    logic [TICK_WIDTH-1:0] tick_cnt;
    logic                  tick_en;
 
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_cnt <= '0;
        end else if (tick_cnt == TICKS_PER_DIGIT - 1) begin
            tick_cnt <= '0;
        end else begin
            tick_cnt <= tick_cnt + 1'b1;
        end
    end
 
    assign tick_en = (tick_cnt == TICKS_PER_DIGIT - 1);
 
    // ---- selector de digito activo (0..3), avanza con clock enable ----
    logic [1:0] digit_sel;
 
    always_ff @(posedge clk) begin
        if (rst)
            digit_sel <= 2'd0;
        else if (tick_en)
            digit_sel <= digit_sel + 1'b1;
    end
 
    // ---- mux del valor BCD y del anodo activo segun digit_sel ----
    logic [3:0] bcd_value;
 
    always_comb begin
        unique case (digit_sel)
            2'd0: begin bcd_value = wins_ones; an = 4'b1110; end
            2'd1: begin bcd_value = wins_tens; an = 4'b1101; end
            2'd2: begin bcd_value = time_ones; an = 4'b1011; end
            2'd3: begin bcd_value = time_tens; an = 4'b0111; end
        endcase
    end

    //  decodificador BCD -> 7 segmentos (activo en bajo) 
    always_comb begin
        unique case (bcd_value)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // apagado ante valor invalido (>9)
        endcase
    end
 
    assign dp = 1'b1; // punto decimal siempre apagado
 
endmodule

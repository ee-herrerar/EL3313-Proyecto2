module buzzer_driver #(
    parameter integer CLK_FREQ_HZ       = 100_000_000,
    parameter integer CORRECT_FREQ_HZ   = 2000,
    parameter integer CORRECT_MS        = 150,
    parameter integer INCORRECT_FREQ_HZ = 500,
    parameter integer INCORRECT_MS      = 250,
    parameter integer WIN_FREQ_HZ       = 800,
    parameter integer WIN_MS            = 500,
    parameter integer LOSE_FREQ_HZ      = 300,
    parameter integer LOSE_MS           = 1000
)(
    input  logic clk,
    input  logic rst,
    input  logic correct_pulse,
    input  logic incorrect_pulse,
    input  logic win_pulse,
    input  logic lose_pulse,
    output logic buzzer_pwm
);

localparam integer CORRECT_HALF   = CLK_FREQ_HZ / (2 * CORRECT_FREQ_HZ);
localparam integer INCORRECT_HALF = CLK_FREQ_HZ / (2 * INCORRECT_FREQ_HZ);
localparam integer WIN_HALF       = CLK_FREQ_HZ / (2 * WIN_FREQ_HZ);
localparam integer LOSE_HALF      = CLK_FREQ_HZ / (2 * LOSE_FREQ_HZ);

localparam integer CORRECT_DUR   = (CLK_FREQ_HZ / 1000) * CORRECT_MS;
localparam integer INCORRECT_DUR = (CLK_FREQ_HZ / 1000) * INCORRECT_MS;
localparam integer WIN_DUR       = (CLK_FREQ_HZ / 1000) * WIN_MS;
localparam integer LOSE_DUR      = (CLK_FREQ_HZ / 1000) * LOSE_MS;

localparam integer MAX_HALF =
    (CORRECT_HALF > INCORRECT_HALF) ?
        ((CORRECT_HALF > WIN_HALF) ?
            ((CORRECT_HALF > LOSE_HALF) ? CORRECT_HALF : LOSE_HALF) :
            ((WIN_HALF > LOSE_HALF) ? WIN_HALF : LOSE_HALF)) :
        ((INCORRECT_HALF > WIN_HALF) ?
            ((INCORRECT_HALF > LOSE_HALF) ? INCORRECT_HALF : LOSE_HALF) :
            ((WIN_HALF > LOSE_HALF) ? WIN_HALF : LOSE_HALF));

localparam integer MAX_DUR =
    (CORRECT_DUR > INCORRECT_DUR) ?
        ((CORRECT_DUR > WIN_DUR) ?
            ((CORRECT_DUR > LOSE_DUR) ? CORRECT_DUR : LOSE_DUR) :
            ((WIN_DUR > LOSE_DUR) ? WIN_DUR : LOSE_DUR)) :
        ((INCORRECT_DUR > WIN_DUR) ?
            ((INCORRECT_DUR > LOSE_DUR) ? INCORRECT_DUR : LOSE_DUR) :
            ((WIN_DUR > LOSE_DUR) ? WIN_DUR : LOSE_DUR));

localparam integer HALF_WIDTH = $clog2(MAX_HALF + 1);
localparam integer DUR_WIDTH  = $clog2(MAX_DUR + 1);

logic [HALF_WIDTH-1:0] half_period;
logic [HALF_WIDTH-1:0] toggle_cnt;
logic [DUR_WIDTH-1:0] duration_cnt;
logic active;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        half_period  <= '0;
        toggle_cnt   <= '0;
        duration_cnt <= '0;
        active       <= 1'b0;
        buzzer_pwm   <= 1'b0;
    end
    else if (correct_pulse) begin
        half_period  <= CORRECT_HALF;
        duration_cnt <= CORRECT_DUR;
        toggle_cnt   <= '0;
        active       <= 1'b1;
        buzzer_pwm   <= 1'b0;
    end
    else if (incorrect_pulse) begin
        half_period  <= INCORRECT_HALF;
        duration_cnt <= INCORRECT_DUR;
        toggle_cnt   <= '0;
        active       <= 1'b1;
        buzzer_pwm   <= 1'b0;
    end
    else if (win_pulse) begin
        half_period  <= WIN_HALF;
        duration_cnt <= WIN_DUR;
        toggle_cnt   <= '0;
        active       <= 1'b1;
        buzzer_pwm   <= 1'b0;
    end
    else if (lose_pulse) begin
        half_period  <= LOSE_HALF;
        duration_cnt <= LOSE_DUR;
        toggle_cnt   <= '0;
        active       <= 1'b1;
        buzzer_pwm   <= 1'b0;
    end
    else if (active) begin
        if (duration_cnt == 0) begin
            active       <= 1'b0;
            buzzer_pwm   <= 1'b0;
            toggle_cnt   <= '0;
        end
        else begin
            duration_cnt <= duration_cnt - 1'b1;

            if (toggle_cnt == half_period - 1'b1) begin
                toggle_cnt <= '0;
                buzzer_pwm <= ~buzzer_pwm;
            end
            else begin
                toggle_cnt <= toggle_cnt + 1'b1;
            end
        end
    end
    else begin
        buzzer_pwm <= 1'b0;
    end
end

endmodule
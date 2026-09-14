module counter_enable #(
    parameter int COUNT_1US     = 100,
    parameter int COUNT_ENABLE  = 160,
    parameter int COUNT_60US    = 6000
)(
    input  logic clk,
    input  logic reset,
    input  logic active,
    output logic enable,
    output logic flag_60us
);

logic [$clog2(COUNT_60US)-1:0] counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset)
        counter <= '0;
    else if (!active)
        counter <= '0;
    else if (counter == COUNT_60US - 1)
        counter <= '0;
    else
        counter <= counter + 1'b1;
end

assign enable = (counter >= COUNT_1US) &&
                (counter < COUNT_ENABLE);

assign flag_60us = (counter == COUNT_60US - 1);

endmodule
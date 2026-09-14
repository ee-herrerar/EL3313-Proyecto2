`timescale 1ns / 1ps

module LCD_PERIPH (
    input  logic        clk,
    input  logic        rst,

    input  logic        write_enable,
    input  logic [1:0]  addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata,

    input  logic        lcd_busy,
    input  logic        lcd_done,

    output logic        start,
    output logic        rs,
    output logic        clear,
    output logic        home,
    output logic [7:0]  data_byte
);

localparam logic [1:0] ADDR_CONTROL = 2'b00;
localparam logic [1:0] ADDR_DATA    = 2'b01;

logic done_reg;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        start     <= 1'b0;
        rs        <= 1'b0;
        clear     <= 1'b0;
        home      <= 1'b0;
        data_byte <= 8'h00;
        done_reg  <= 1'b0;
    end
    else begin
        start <= 1'b0;
        clear <= 1'b0;
        home  <= 1'b0;

        if (lcd_done)
            done_reg <= 1'b1;

        if (write_enable && !lcd_busy) begin
            case (addr)

                ADDR_CONTROL: begin
                    start <= wdata[0];
                    rs    <= wdata[1];
                    clear <= wdata[2];
                    home  <= wdata[3];

                    if (wdata[0] || wdata[2] || wdata[3])
                        done_reg <= 1'b0;
                end

                ADDR_DATA: begin
                    data_byte <= wdata[7:0];
                end

                default: begin
                end

            endcase
        end
    end
end

always_comb begin
    rdata = 32'h0000_0000;

    case (addr)

        ADDR_CONTROL: begin
            rdata[0] = start;
            rdata[1] = rs;
            rdata[2] = clear;
            rdata[3] = home;
            rdata[8] = lcd_busy;
            rdata[9] = done_reg;
        end

        ADDR_DATA: begin
            rdata[7:0] = data_byte;
        end

        default: begin
            rdata = 32'h0000_0000;
        end

    endcase
end

endmodule
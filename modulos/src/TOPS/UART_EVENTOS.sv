module UART_EVENTOS (
    input  logic        clk,
    input  logic        reset,

    input  logic        GameOn,
    input  logic        hardmode,
    input  logic [2:0]  Fallos,
    input  logic [11:0] LetrasReveladas,
    input  logic        GameWin,
    input  logic        GameLose,

    input  logic        mensaje_busy,

    output logic        mensaje_start,
    output logic [2:0]  mensaje_id
);

localparam logic [2:0] MSG_FACIL      = 3'd0;
localparam logic [2:0] MSG_DIFICIL    = 3'd1;
localparam logic [2:0] MSG_CORRECTA   = 3'd2;
localparam logic [2:0] MSG_INCORRECTA = 3'd3;
localparam logic [2:0] MSG_GANASTE    = 3'd4;
localparam logic [2:0] MSG_PERDISTE   = 3'd5;

logic [2:0]  FallosPrev;
logic [11:0] LetrasReveladasPrev;
logic GameWinPrev;
logic GameLosePrev;

logic pendiente_modo;
logic pendiente_correcta;
logic pendiente_incorrecta;
logic pendiente_win;
logic pendiente_lose;

logic [2:0] modo_id;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        FallosPrev           <= 3'd0;
        LetrasReveladasPrev  <= 12'd0;
        GameWinPrev          <= 1'b0;
        GameLosePrev         <= 1'b0;

        pendiente_modo       <= 1'b0;
        pendiente_correcta   <= 1'b0;
        pendiente_incorrecta <= 1'b0;
        pendiente_win        <= 1'b0;
        pendiente_lose       <= 1'b0;

        modo_id              <= MSG_FACIL;
        mensaje_start        <= 1'b0;
        mensaje_id           <= MSG_FACIL;
    end
    else begin
        mensaje_start <= 1'b0;

        FallosPrev          <= Fallos;
        LetrasReveladasPrev <= LetrasReveladas;
        GameWinPrev         <= GameWin;
        GameLosePrev        <= GameLose;

        if (!mensaje_busy && !mensaje_start) begin
            if (pendiente_win) begin
                mensaje_id    <= MSG_GANASTE;
                mensaje_start <= 1'b1;
                pendiente_win <= 1'b0;
            end
            else if (pendiente_lose) begin
                mensaje_id     <= MSG_PERDISTE;
                mensaje_start  <= 1'b1;
                pendiente_lose <= 1'b0;
            end
            else if (pendiente_incorrecta) begin
                mensaje_id           <= MSG_INCORRECTA;
                mensaje_start        <= 1'b1;
                pendiente_incorrecta <= 1'b0;
            end
            else if (pendiente_correcta) begin
                mensaje_id         <= MSG_CORRECTA;
                mensaje_start      <= 1'b1;
                pendiente_correcta <= 1'b0;
            end
            else if (pendiente_modo) begin
                mensaje_id     <= modo_id;
                mensaje_start  <= 1'b1;
                pendiente_modo <= 1'b0;
            end
        end

        if (GameOn) begin
            pendiente_modo <= 1'b1;

            if (hardmode)
                modo_id <= MSG_DIFICIL;
            else
                modo_id <= MSG_FACIL;
        end

        if (|(LetrasReveladas & ~LetrasReveladasPrev))
            pendiente_correcta <= 1'b1;

        if (Fallos > FallosPrev)
            pendiente_incorrecta <= 1'b1;

        if (GameWin && !GameWinPrev)
            pendiente_win <= 1'b1;

        if (GameLose && !GameLosePrev)
            pendiente_lose <= 1'b1;
    end
end

endmodule
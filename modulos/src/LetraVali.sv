module LetraVali (
    input logic [95:0] palabra,
    input logic [4:0] largo,
    input logic [7:0] letra,
    output logic acierto,
    output logic [11:0] coincidencias
); 

always_comb begin
    acierto = 1'b0;
    coincidencias = 12'b0;
    for (int i = 0; i < 12; i++) begin
        if (i < largo) begin
            if (palabra[95 - i*8 -: 8] == letra) begin
                coincidencias[i] = 1'b1;
                acierto = 1'b1;
            end
        end
    end
end

endmodule
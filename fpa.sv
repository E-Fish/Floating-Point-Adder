module fpa #(
parameter EXP = 8,
parameter MANT = 23
)(
    input logic [EXP+MANT:0] a,
    input logic [EXP+MANT:0] b,
    output logic [EXP+MANT:0] c 
);

logic sign_a;
logic [EXP-1:0] exponent_a;
logic [MANT:0] mantissa_a;

logic sign_b;
logic [EXP-1:0] exponent_b;
logic [MANT:0] mantissa_b;

logic [EXP-1:0] exponent_c;
logic [MANT+3:0] mantissa_c;

logic [EXP-1:0] diff;

// logic guard_a, sticky_a, round_a;
// logic guard_b, sticky_b, round_b;

integer i;

always_comb begin

    
    sign_a = a[EXP+MANT];
    exponent_a = a[EXP+MANT-1:MANT];
    

    sign_b = b[EXP+MANT];
    exponent_b = b[EXP+MANT-1:MANT];

    if(exponent_a == '0)begin
        mantissa_a = a[MANT-1:0];
        mantissa_b = {1'b1, b[MANT-1:0]};
    end
    else if
    (exponent_b == '0) begin
        mantissa_a = {1'b1, a[MANT-1:0]};
        mantissa_b = b[MANT-1:0];
    end
    else begin
        mantissa_a = {1'b1, a[MANT-1:0]};
        mantissa_b = {1'b1, b[MANT-1:0]};
    end
   
    
    //make exponents equal
    if(exponent_b < exponent_a) begin
        diff = exponent_a - exponent_b;

        for(int i = 0; i <= (diff - 3); i++) begin
            mantissa_b[diff - 3] |= mantissa_b[i];
        end

        mantissa_b = mantissa_b >> (diff - 3);
        exponent_b = exponent_a;
    end
    else begin
        diff = exponent_b - exponent_a;

        for(int i = 0; i <= (diff - 3); i++) begin
            mantissa_a[diff - 3] |= mantissa_a[i];
        end

        mantissa_a = mantissa_a >> (diff - 3);
        exponent_a = exponent_b;
    end

    //add or subtract mantissas
    if(sign_a == sign_b) begin
        c[EXP+MANT] = sign_a;
        mantissa_c = mantissa_a + mantissa_b;
    end
    else begin
        if(mantissa_a <= mantissa_b) begin
            c[EXP+MANT] = sign_b;
            mantissa_c = mantissa_b - mantissa_a;
        end else begin
            c[EXP+MANT] = sign_a;
            mantissa_c = mantissa_a - mantissa_b;
        end
    end
    exponent_c = exponent_a;

    if(mantissa_c == '0)begin
        mantissa_c = '0;
        exponent_c = '0;
        c[EXP+MANT] = 1'b0;
    end
    else begin
        //account for offsets
        if(mantissa_c[MANT+1]) begin
            mantissa_c = mantissa_c >> 1;
            exponent_c = exponent_c + 1;
        end else begin

            //normalization
            for(i = 0; i < MANT; i = i + 1)begin
                if(mantissa_c[MANT] == 0)begin
                    mantissa_c = mantissa_c << 1;
                    exponent_c = exponent_c - 1;
                end
            end
        end
    end
    c[EXP+MANT-1:MANT] = exponent_c;
    c[MANT-1:0] = mantissa_c[MANT-1:0];
    
end

endmodule

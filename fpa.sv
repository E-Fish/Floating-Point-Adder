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
logic [MANT+1:0] mantissa_c;

logic [EXP-1:0] diff;

integer i;

always_comb begin
    sign_a = a[EXP+MANT];
    exponent_a = a[EXP+MANT-1:MANT];
    mantissa_a = {1'b1, a[MANT-1:0]};

    sign_b = b[EXP+MANT];
    exponent_b = b[EXP+MANT-1:MANT];
    mantissa_b = {1'b1, b[MANT-1:0]};

   

    //make exponents equal
    if(exponent_b < exponent_a) begin
        diff = exponent_a - exponent_b;
        mantissa_b = mantissa_b >> diff;
        exponent_b = exponent_a;
    end
    else begin
        diff = exponent_b - exponent_a;
        mantissa_a = mantissa_a >> diff;
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

    //account for offsets
    if(mantissa_c[MANT+1]) begin
        mantissa_c = mantissa_c >> 1;
        exponent_c = exponent_c + 1;
    end else begin

        //change this to a chain of if/else ?
        for(i = 0; i < MANT; i = i + 1)begin
            if(mantissa_c[MANT] == 0)begin
                mantissa_c = mantissa_c << 1;
                exponent_c = exponent_c - 1;
            end
        end
    end
    c[EXP+MANT-1:MANT] = exponent_c;
    c[MANT-1:0] = mantissa_c[MANT-1:0];
end
endmodule


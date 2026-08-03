module fpa(
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] c 
);

logic sign_a;
logic [7:0] exponent_a;
logic [23:0] significand_a;

logic sign_b;
logic [7:0] exponent_b;
logic [23:0] significand_b;

logic [7:0] exponent_c;
logic [24:0] significand_c;

logic [7:0] diff;

integer i;

always_comb begin
    sign_a = a[31];
    exponent_a = a[30:23];
    significand_a = {1'b1, a[22:0]};

    sign_b = b[31];
    exponent_b = b[30:23];
    significand_b = {1'b1, b[22:0]};

    //make exponents equal
    if(exponent_b < exponent_a) begin
        diff = exponent_a - exponent_b;
        significand_b = significand_b >> diff;
        exponent_b = exponent_a;
    end
    else begin
        diff = exponent_b - exponent_a;
        significand_a = significand_a >> diff;
        exponent_a = exponent_b;
    end

    //add or subtract significands
    if(sign_a == sign_b) begin
        c[31] = sign_a;
        significand_c = significand_a + significand_b;
    end
    else begin
        if(significand_a <= significand_b) begin
            c[31] = sign_b;
            significand_c = significand_b - significand_a;
        end else begin
            c[31] = sign_a;
            significand_c = significand_a - significand_b;
        end
    end
    exponent_c = exponent_a;

    //account for offsets
    if(significand_c[24]) begin
        significand_c = significand_c >> 1;
        exponent_c = exponent_c + 1;
    end else begin

        //change this to a chain of if/else ?
        //might not be necessary (not comb)
        for(i = 0; i < 23; i = i + 1)begin
            if(significand_c[23] == 0)begin
                significand_c = significand_c << 1;
                exponent_c = exponent_c - 1;
            end
        end
    end
    c[30:23] = exponent_c;
    c[22:0] = significand_c[22:0];
end
endmodule

module fpa_pipe #(

    parameter EXP = 5, // FP32: 8; FP16: 5; BF16: 8
    parameter MANT = 10 // FP32: 23; FP16: 10; BF16: 7

)(
    input  logic clk,
    input  logic [EXP+MANT:0] a,
    input  logic [EXP+MANT:0] b,
    output logic [EXP+MANT:0] c 
);

    logic sign_a;
    logic [EXP-1:0] exponent_a;
    logic [MANT:0] mantissa_a;

    logic sign_b;
    logic [EXP-1:0] exponent_b;
    logic [MANT:0] mantissa_b;

    logic sign_c;
    logic [EXP-1:0] exponent_c;
    logic [MANT+1:0] mantissa_c;

    logic [EXP-1:0] diff;

    integer i;

    always_ff @(posedge clk) begin
        sign_a <= a[EXP+MANT];
        exponent_a <= a[EXP+MANT-1:MANT];

        sign_b <= b[EXP+MANT];
        exponent_b <= b[EXP+MANT-1:MANT];

        //Just an idea i was working with to make it not output to each variable multiple 
        //times in one clk to work w pipelining (and you would comment out the block below)
        //it fixed a few test cases
        mantissa_a <= (exponent_a == '0) ? a[MANT-1:0] : {1'b1, a[MANT-1:0]};
        mantissa_b <= (exponent_b == '0) ? b[MANT-1:0] : {1'b1, b[MANT-1:0]};
    end

    // always_ff @(posedge clk) begin

    //     if(exponent_a == '0)begin
    //         mantissa_a <= a[MANT-1:0];
    //         mantissa_b <= {1'b1, b[MANT-1:0]};
    //     end
    //     else if (exponent_b == '0) begin
    //         mantissa_a <= {1'b1, a[MANT-1:0]};
    //         mantissa_b <= b[MANT-1:0];
    //     end
    //     else begin
    //         mantissa_a <= {1'b1, a[MANT-1:0]};
    //         mantissa_b <= {1'b1, b[MANT-1:0]};
    //     end
    // end

    always_ff @(posedge clk) begin
    
        //make exponents equal
        if (exponent_b < exponent_a) begin
            diff = exponent_a - exponent_b;
            mantissa_b <= mantissa_b >> diff;
            exponent_b <= exponent_a;
        end
        else begin
            diff = exponent_b - exponent_a;
            mantissa_a <= mantissa_a >> diff;
            exponent_a <= exponent_b;
        end
    end

    //I added bc multiple blocks can't output to sign_c
    logic sign_sum;
    logic [EXP-1:0] exponent_sum;
    logic [MANT+1:0] mantissa_sum;

    always_ff @(posedge clk) begin
        exponent_sum <= exponent_a;

        if (sign_a == sign_b) begin
            sign_sum <= sign_a;
            mantissa_sum <= mantissa_a + mantissa_b;
        end
        else begin
            if (mantissa_a <= mantissa_b) begin
                sign_sum <= sign_b;
                mantissa_sum <= mantissa_b - mantissa_a;
            end 
            else begin
                sign_sum <= sign_a;
                mantissa_sum <= mantissa_a - mantissa_b;
            end
        end
    end

    always_ff @(posedge clk) begin

        if (mantissa_sum == '0) begin
            mantissa_c <= '0;
            exponent_c <= '0;
            sign_c <= 1'b0;
        end
        //If needs to be normalized
        else if (mantissa_sum[MANT+1]) begin
            mantissa_c <= mantissa_sum >> 1;
            exponent_c <= exponent_sum + 1;
            sign_c <= sign_sum;
        end
        //If its already normalized
        else if (mantissa_sum[MANT]) begin
            mantissa_c <= mantissa_sum;
            exponent_c <= exponent_sum;
            sign_c <= sign_sum;
        end
        else begin
            for (i = 0; i < MANT; i = i + 1) begin
                if (mantissa_sum[MANT] == 0) begin
                    mantissa_c <= mantissa_sum << 1;
                    exponent_c <= exponent_sum - 1;
                end
            end
            sign_c <= sign_sum;
        end
    end

    //I added it for sign bc i had to add a sign_c
    assign c[EXP+MANT] = sign_c;
    assign c[EXP+MANT-1:MANT] = exponent_c;
    assign c[MANT-1:0] = mantissa_c[MANT-1:0];

endmodule
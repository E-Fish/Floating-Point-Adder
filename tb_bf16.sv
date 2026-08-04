module tb_bf16;

localparam int MANTISSA = 7;
localparam int EXPONENT = 8;

logic [15:0] a;
logic [15:0] b;
logic [15:0] c;

fpa #(
    .MANT(MANTISSA),
    .EXP(EXPONENT)
) dut (
    .a(a),
    .b(b),
    .c(c)
);

initial begin
    //TEST 1: Basic functionality
    #10
    a = 16'h4000; //3.0
    b = 16'h4040; //2.0
    #10
    if(c == 16'h40A0) begin
        $display("TEST 1 PASSED");
    end
    else begin
        $display("TEST 1 FAILED");
    end

    //TEST 2: positive plus zero
    #10
    a = 16'h4090; //4.5
    b = 16'h0000; //0
    #10
    if(c == 16'h4090) begin
        $display("TEST 2 PASSED");
    end
    else begin
        $display("TEST 2 FAILED");
    end
    //TEST 3: negative plus zero
    #10
    a = 16'hC090; //-4.5
    b = 16'h0000; //0
    #10
    if(c == 16'hC090) begin
        $display("TEST 3 PASSED");
    end
    else begin
        $display("TEST 3 FAILED");
    end
    //TEST 4: positive plus negative (positive is greater)
    #10
    a = 16'h40A0; //5.0
    b = 16'hC000; //-2.0
    #10
    if(c == 16'h4040) begin
        $display("TEST 4 PASSED");
    end
    else begin
        $display("TEST 4 FAILED");
    end
    //TEST 5: positive plus negative (negative is greater)
    #10
    a = 16'h4000; //2.0
    b = 16'hC0A0; //-5.0
    #10
    if(c == 16'hC040) begin
        $display("TEST 5 PASSED");
    end
    else begin
        $display("TEST 5 FAILED");
    end
    //TEST 6: zero result
    #10
    a = 16'h40C8; //6.25
    b = 16'hC0C8; //-6.25
    #10
    if(c == 16'h0000) begin
        $display("TEST 6 PASSED");
    end
    else begin
        $display("TEST 6 FAILED");
    end
    //TEST 7: zero plus zero
    #10
    a = 16'h0; //0
    b = 16'h0; //0
    #10
    if(c == 16'h0) begin
        $display("TEST 7 PASSED");
    end
    else begin
        $display("TEST 7 FAILED");
    end
    //TEST 8: equal exponents
    #10
    a = 16'h3FC0; //1.5
    b = 16'h3FA0; //1.25
    #10
    if(c == 16'h4030) begin
        $display("TEST 8 PASSED");
    end
    else begin
        $display("TEST 8 FAILED");
    end
    //TEST 9: large and small exponent
    #10
    a = 16'h3F80; //1.0
    b = 16'h3A80; //2^-10
    #10
    if(c == 16'h3F80) begin
        $display("TEST 9 PASSED");
    end
    else begin
        $display("TEST 9 FAILED");
    end
    //TEST 10: truncation
    #10
    a = 16'h3F80; //1.0
    b = 16'h3EFF; //0.49
    #10
    if(c == 16'h3FBF) begin
        $display("TEST 10 PASSED");
    end
    else begin
        $display("TEST 10 FAILED");
    end
    $finish;
end







endmodule
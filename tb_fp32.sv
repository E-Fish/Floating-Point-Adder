module tb_fp32;

localparam int MANTISSA = 23;
localparam int EXPONENT = 8;

logic [31:0] a;
logic [31:0] b;
logic [31:0] c;

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
    a = 32'h40000000; //3.0
    b = 32'h40400000; //2.0
    #10
    if(c == 32'h40A00000) begin
        $display("TEST 1 PASSED");
    end
    else begin
        $display("TEST 1 FAILED");
    end

    //TEST 2: positive plus zero
    #10
    a = 32'h40900000; //4.5
    b = 32'h00000000; //0
    #10
    if(c == 32'h40900000) begin
        $display("TEST 2 PASSED");
    end
    else begin
        $display("TEST 2 FAILED");
    end
    //TEST 3: negative plus zero
    #10
    a = 32'hC0900000; //-4.5
    b = 32'h00000000; //0
    #10
    if(c == 32'hC0900000) begin
        $display("TEST 3 PASSED");
    end
    else begin
        $display("TEST 3 FAILED");
    end
    //TEST 4: positive plus negative (positive is greater)
    #10
    a = 32'h40A00000; //5.0
    b = 32'hC0000000; //-2.0
    #10
    if(c == 32'h40400000) begin
        $display("TEST 4 PASSED");
    end
    else begin
        $display("TEST 4 FAILED");
    end
    //TEST 5: positive plus negative (negative is greater)
    #10
    a = 32'h40000000; //2.0
    b = 32'hC0A00000; //-5.0
    #10
    if(c == 32'hC0400000) begin
        $display("TEST 5 PASSED");
    end
    else begin
        $display("TEST 5 FAILED");
    end
    //TEST 6: zero result
    #10
    a = 32'h40C80000; //6.25
    b = 32'hC0C80000; //-6.25
    #10
    if(c == 32'h0) begin
        $display("TEST 6 PASSED");
    end
    else begin
        $display("TEST 6 FAILED");
    end
    //TEST 7: zero plus zero
    #10
    a = 32'h0; //0
    b = 32'h0; //0
    #10
    if(c == 32'h0) begin
        $display("TEST 7 PASSED");
    end
    else begin
        $display("TEST 7 FAILED");
    end
    //TEST 8: equal exponents
    #10
    a = 32'h3FC00000; //1.5
    b = 32'h3FA00000; //1.25
    #10
    if(c == 32'h40300000) begin
        $display("TEST 8 PASSED");
    end
    else begin
        $display("TEST 8 FAILED");
    end
    //TEST 9: large and small exponent
    #10
    a = 32'h3F800000; //1.0
    b = 32'h30800000; //2^-30
    #10
    if(c == 32'h3F800000) begin
        $display("TEST 9 PASSED");
    end
    else begin
        $display("TEST 9 FAILED");
    end
    //TEST 10: truncation
    #10
    a = 32'h3F800000; //1.0
    b = 32'h3EFFFFFF; //0.49
    #10
    if(c == 32'h3FBFFFFF) begin
        $display("TEST 10 PASSED");
    end
    else begin
        $display("TEST 10 FAILED");
    end
    $finish;
end

endmodule
module tb_fp32;

    localparam int MANTISSA = 23;
    localparam int EXPONENT = 8;
    localparam int TOTAL = MANTISSA + EXPONENT;

    logic clk;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;

    fpa_pipe #(
        .MANT(MANTISSA),
        .EXP(EXPONENT)
    ) dut (
        .clk(clk),
        .a(a),
        .b(b),
        .c(c)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task run_test(logic [TOTAL:0] test_a, logic [TOTAL:0] test_b, logic [TOTAL:0] expected);
        begin
            a = test_a;
            b = test_b;
            
            // Note to self: repeat as many always_ff are in pipeline
            @(posedge clk);
            #1;
            @(posedge clk);
            #1;
            @(posedge clk);
            #1;
            @(posedge clk);
            #1;
            @(posedge clk);
            #1;
 
            if (c === expected) begin
                $display("a=%016b b=%016b out=%016b PASS", test_a, test_b, c);
            end 
            else begin
                $display("a=%016b b=%016b out=%016b expected=%016b FAIL", test_a, test_b, c, expected);
            end
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_fp32);

        a = 0; 
        b = 0;
        @(posedge clk); // Wait for clk edge
        #1; // Add small delay

        //TEST 1: Basic functionality
        run_test(32'h40000000, 32'h40400000, 32'h40A00000);

        //TEST 2: positive plus zero
        run_test(32'h40900000, 32'h00000000, 32'h40900000);

        //TEST 3: negative plus zero
        run_test(32'hC0900000, 32'h00000000, 32'hC0900000);

        //TEST 4: positive plus negative (positive is greater)
        run_test(32'h40A00000, 32'hC0000000, 32'h40400000);

        //TEST 5: positive plus negative (negative is greater)
        run_test(32'h40000000, 32'hC0A00000, 32'hC0400000);

        //TEST 6: zero result
        run_test(32'h40C80000, 32'hC0C80000, 32'h00000000);

        //TEST 7: zero plus zero
        run_test(32'h00000000, 32'h00000000, 32'h00000000);

        //TEST 8: equal exponents
        run_test(32'h3FC00000, 32'h3FA00000, 32'h40300000);

        //TEST 9: large and small exponent
        run_test(32'h3F800000, 32'h30800000, 32'h3F800000);

        //TEST 10: truncation
        run_test(32'h3F800000, 32'h3EFFFFFF, 32'h3FBFFFFF);
        
        $finish;

    end

    // initial begin
    //     //TEST 1: Basic functionality
    //     a = 32'h40000000; //3.0
    //     b = 32'h40400000; //2.0

    //     if(c == 32'h40A00000) begin
    //         $display("TEST 1 PASSED");
    //     end
    //     else begin
    //         $display("TEST 1 FAILED");
    //     end

    //     //TEST 2: positive plus zero
    //     #10
    //     a = 32'h40900000; //4.5
    //     b = 32'h00000000; //0
    //     #10
    //     if(c == 32'h40900000) begin
    //         $display("TEST 2 PASSED");
    //     end
    //     else begin
    //         $display("TEST 2 FAILED");
    //     end
    //     //TEST 3: negative plus zero
    //     #10
    //     a = 32'hC0900000; //-4.5
    //     b = 32'h00000000; //0
    //     #10
    //     if(c == 32'hC0900000) begin
    //         $display("TEST 3 PASSED");
    //     end
    //     else begin
    //         $display("TEST 3 FAILED");
    //     end
    //     //TEST 4: positive plus negative (positive is greater)
    //     #10
    //     a = 32'h40A00000; //5.0
    //     b = 32'hC0000000; //-2.0
    //     #10
    //     if(c == 32'h40400000) begin
    //         $display("TEST 4 PASSED");
    //     end
    //     else begin
    //         $display("TEST 4 FAILED");
    //     end
    //     //TEST 5: positive plus negative (negative is greater)
    //     #10
    //     a = 32'h40000000; //2.0
    //     b = 32'hC0A00000; //-5.0
    //     #10
    //     if(c == 32'hC0400000) begin
    //         $display("TEST 5 PASSED");
    //     end
    //     else begin
    //         $display("TEST 5 FAILED");
    //     end
    //     //TEST 6: zero result
    //     #10
    //     a = 32'h40C80000; //6.25
    //     b = 32'hC0C80000; //-6.25
    //     #10
    //     if(c == 32'h0) begin
    //         $display("TEST 6 PASSED");
    //     end
    //     else begin
    //         $display("TEST 6 FAILED");
    //     end
    //     //TEST 7: zero plus zero
    //     #10
    //     a = 32'h0; //0
    //     b = 32'h0; //0
    //     #10
    //     if(c == 32'h0) begin
    //         $display("TEST 7 PASSED");
    //     end
    //     else begin
    //         $display("TEST 7 FAILED");
    //     end
    //     //TEST 8: equal exponents
    //     #10
    //     a = 32'h3FC00000; //1.5
    //     b = 32'h3FA00000; //1.25
    //     #10
    //     if(c == 32'h40300000) begin
    //         $display("TEST 8 PASSED");
    //     end
    //     else begin
    //         $display("TEST 8 FAILED");
    //     end
    //     //TEST 9: large and small exponent
    //     #10
    //     a = 32'h3F800000; //1.0
    //     b = 32'h30800000; //2^-30
    //     #10
    //     if(c == 32'h3F800000) begin
    //         $display("TEST 9 PASSED");
    //     end
    //     else begin
    //         $display("TEST 9 FAILED");
    //     end
    //     //TEST 10: truncation
    //     #10
    //     a = 32'h3F800000; //1.0
    //     b = 32'h3EFFFFFF; //0.49
    //     #10
    //     if(c == 32'h3FBFFFFF) begin
    //         $display("TEST 10 PASSED");
    //     end
    //     else begin
    //         $display("TEST 10 FAILED");
    //     end
    //     $finish;
    // end

endmodule
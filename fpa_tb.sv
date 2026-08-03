`timescale 1ns / 1ps

//`include "fpa.sv"

module fpa_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;

    int pass_count = 0;
    int fail_count = 0;

    fpa fpa (
        .a(a),
        .b(b),
        .c(c)
    );

    task run_test(logic [31:0] test_a, logic [31:0] test_b, logic [31:0] expected);
        begin
            a = test_a;
            b = test_b;
            #5; // quick wait for logic to settle
 
            if (c === expected) begin
                pass_count++;
                $display("a=%016b b=%016b | out=%016b | PASS", test_a, test_b, c);
            end 
            else begin
                fail_count++;
                $display("a=%016b b=%016b | out=%016b expected=%016b | FAIL", test_a, test_b, c, expected);
            end
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, fpa_tb);

        a = 0; 
        b = 0;
        #5;

        run_test(32'h3F800000, 32'h3F800000, 32'h40000000); // 1.0 + 1.0 = 2.0
        run_test(32'h40000000, 32'hBF800000, 32'h3F800000); // 2.0 + (-1.0) = 1.0  (different signs, no cancellation to zero)
        run_test(32'h3FC00000, 32'h40200000, 32'h40800000); // 1.5 + 2.5 = 4.0
        run_test(32'h40400000, 32'h40800000, 32'h40E00000); // 3.0 + 4.0 = 7.0
        run_test(32'hC0400000, 32'h3F800000, 32'hC0000000); // -3.0 + 1.0 = -2.0
        run_test(32'h41000000, 32'h41000000, 32'h41800000); // 8.0 + 8.0 = 16.0 (forces the significand_c[24] carry-out normalize path)
        run_test(32'h3FA00000, 32'h3FA00000, 32'h40200000); // 1.25 + 1.25 = 2.5
        run_test(32'h49800000, 32'h49800000, 32'h4A000000); // 2^20 + 2^20 = 2^21 (large exponent alignment, no shift needed)// -1.0 + -1.0 = -2.0 (same sign, negative, exercises carry path w/ sign)
        run_test(32'hBF800000, 32'hBF800000, 32'hC0000000); // -1.0 + -1.0 = -2.0 (same sign, negative, exercises carry path w/ sign)
 
        // 1.0 + 2^-30 = 1.0 (exponent diff of 30 shifts significand_b fully to
        // zero before it can affect the sum -- truncation is "safe" here since
        // no bits of the final result depend on what got shifted out)
        run_test(32'h3F800000, 32'h30800000, 32'h3F800000);
 
        // Zero + zero -- KNOWN BUG: significand_a/b force an implicit leading 1
        // even when exponent==0 and mantissa==0, so this does NOT produce true
        // zero on the current DUT. Expected value here is the correct IEEE-754
        // result (0.0); this test is expected to FAIL until the zero-input
        // special case is added.
        run_test(32'h00000000, 32'h00000000, 32'h00000000);
 
        // 5.0 + (-5.0) = 0.0 -- KNOWN BUG: exact cancellation leaves
        // significand_c == 0, and the normalize loop decrements exponent_c
        // 23 times unconditionally with no zero-result check, corrupting the
        // exponent field. Expected value here is the correct IEEE-754 result
        // (0.0); this test is expected to FAIL until a zero-result check is
        // added before/after normalization.
        run_test(32'h40A00000, 32'hC0A00000, 32'h00000000);
 
        $display("Results: %0d passed, %0d failed (of %0d total)", pass_count, fail_count, pass_count + fail_count);

        $finish;
    end
 
endmodule

`timescale 1ns / 1ps

//`include "fpa.sv"

module tb_fp16a;

    localparam int EXPONENT = 5;
    localparam int MANTISSA = 10;
    localparam int TOTAL = MANTISSA + EXPONENT;

    logic clk;
    logic [TOTAL:0] a;
    logic [TOTAL:0] b;
    logic [TOTAL:0] c;

    fpa_pipe #(
        .MANT(MANTISSA),
        .EXP(EXPONENT)
    )  fpa (
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
        $dumpvars(0, tb_fp16a);

        a = 0; 
        b = 0;
        @(posedge clk); // Wait for clk edge
        #1; // Add small delay

        //Zero + zero
        run_test(16'b0000000000000000, 16'b0000000000000000, 16'b0000000000000000);

        //Zero + nonzero: 0+5.0 = 5.0
        run_test(16'b0000000000000000, 16'b0100010100000000, 16'b0100010100000000);

        //To have them cancel out: -3.0+3.0 = 0.0
        run_test(16'b1100001000000000, 16'b0100001000000000, 16'b0000000000000000);

        //Neg w/ same sign: -2.5+ -2.5 = -5.0
        run_test(16'b1100000100000000, 16'b1100000100000000, 16'b1100010100000000);

        //Forces right shift to normalize: 1.5+1.75 = 3.25
        run_test(16'b0011111000000000, 16'b0011111100000000, 16'b0100001010000000);

        //Forces left shift normalize and it almost cancels: 1.03125+ -1.0 = 0.03125
        run_test(16'b0011110000100000, 16'b1011110000000000, 16'b0010100000000000);

        //Very big difference in exponents: 1024.0+2^-10 = 1024.0
        run_test(16'b0110010000000000, 16'b0001010000000000, 16'b0110010000000000);

        //It has to shift the same amt as the mant: 32.0+0.03125 = 32.03125
        run_test(16'b0101000000000000, 16'b0010100000000000, 16'b0101000000000001);

        //Different signs, large magnitude cancellation: -100.0+100.0 = 0.0
        run_test(16'b1101011001000000, 16'b0101011001000000, 16'b0000000000000000);

        //Opposite signs but basic #s: 10.0+ -3.0 = 7.0
        run_test(16'b0100100100000000, 16'b1100001000000000, 16'b0100011100000000);

        //Smallest exp + smallest exp: 2^-14+2^-14 = 2^-13
        run_test(16'b0000010000000000, 16'b0000010000000000, 16'b0000100000000000);

        //Large magnitudes that are near top of the range: 30000.0+30000.0 = 60000.0
        run_test(16'b0111011101010011, 16'b0111011101010011, 16'b0111101101010011);

        //Doubling that requires a right shift to normalize: 6.0+6.0 = 12.0
        run_test(16'b0100011000000000, 16'b0100011000000000, 16'b0100101000000000);
        
        $finish;

    end
 
endmodule


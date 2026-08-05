IVERILOG = iverilog
FLAGS = -Wall -g2012

FPA = fpa.sv

FP16ATB = tb_fp16a.sv
BF16ATB = tb_bf16.sv
FP32ATB = tb_fp32.sv

OUT_FP16 = output_fp16
OUT_BF16 = output_bf16
OUT_FP32 = output_fp32

# To test all three data types we made
all: $(OUT_FP16) $(OUT_BF16) $(OUT_FP32)
	./$(OUT_FP16)
	./$(OUT_BF16)
	./$(OUT_FP32)

$(OUT_FP16): $(FPA) $(FP16ATB)
	$(IVERILOG) $(FLAGS) -o $(OUT_FP16) $(FPA) $(FP16ATB)

$(OUT_BF16): $(FPA) $(BF16ATB)
	$(IVERILOG) $(FLAGS) -o $(OUT_BF16) $(FPA) $(BF16ATB)

$(OUT_FP32): $(FPA) $(FP32ATB)
	$(IVERILOG) $(FLAGS) -o $(OUT_FP32) $(FPA) $(FP32ATB)

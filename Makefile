IVERILOG = iverilog
FLAGS = -Wall -g2012
FPA = fpa.sv
FPATB = fpa_tb.sv
OUT = output

#Compiles output and runs
all: $(OUT)
	./$(OUT)

$(OUT): $(FPA) $(FPATB)
	$(IVERILOG) $(FLAGS) -o $(OUT) $(FPA) $(FPATB)

#Just run w/o compile
run:
	./$(OUT)

#To delete output when done, if you wanna
clean:
	rm -f $(OUT)

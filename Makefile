CXX = gcc
src = $(wildcard examples/*.c)
obj = $(src:.c=.o)

LDFLAGS = -std=c11 -O3
OSFLAGS = -lm

examples: $(obj)
	@mkdir -p bin
	$(CXX) -o bin/$@ $^ $(LDFLAGS) $(OSFLAGS)

clean:
	rm $(obj)

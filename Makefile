libstring: $(libstring.sch)
	sc -i "./libstring.sch"

clean:
	rm "./libstring.h"

install:
	cp "./libstring.h" "/usr/local/include/libstring.h"

remove:
	rm "/usr/local/include/libstring.h"
CFLAGS=-g -Wall

all: parse_mitmdump

parse_mitmdump: parse_mitmdump.o
	$(CC) -o parse_mitmdump parse_mitmdump.o

clean:
	rm -f parse_mitmdump parse_mitmdump.o
	rm -f rawres.0* req.0* res.0*

CFLAGS=-g -Wall

all: parse_mitmdump spit_mitm_chunks

parse_mitmdump: parse_mitmdump.o
	$(CC) -o parse_mitmdump parse_mitmdump.o

spit_mitm_chunks: spit_mitm_chunks.o
	$(CC) -o spit_mitm_chunks spit_mitm_chunks.o

clean:
	rm -f parse_mitmdump parse_mitmdump.o
	rm -f rawres.0* req.0* res.0*
	rm -f spit_mitm_chunks spit_mitm_chunks.o


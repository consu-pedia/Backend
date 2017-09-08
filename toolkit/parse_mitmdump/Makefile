CPPFLAGS=`pkg-config --cflags libmongo-client`
CC=gcc -g -Wall

# OMG SERIOUSLY?!? WTF BBQ
# LDDEPS=`pkg-config --print-requires --print-requires-private libmongo-client`
LDDEPS=glib-2.0
LDFLAGS=`pkg-config --libs libmongo-client $(LDDEPS)`

all: parse_mitmdump spit_mitm_chunks plonk_in_mongodb

parse_mitmdump: parse_mitmdump.o
	$(CC) -o parse_mitmdump parse_mitmdump.o

spit_mitm_chunks: spit_mitm_chunks.o
	$(CC) -o spit_mitm_chunks spit_mitm_chunks.o

plonk_in_mongodb: plonk_in_mongodb.o
	echo "DBG linker deps: "$(LDDEPS)
	echo "DBG linker: "$(LDFLAGS)
	$(CC) -o plonk_in_mongodb plonk_in_mongodb.o $(LDFLAGS)

clean:
	rm -f parse_mitmdump parse_mitmdump.o
	rm -f rawres.0* req.0* res.0*
	rm -f spit_mitm_chunks spit_mitm_chunks.o
	rm -f plonk_in_mongodb plonk_in_mongodb.o


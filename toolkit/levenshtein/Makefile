CFLAGS=-g -Wall

all: levenshtein printmindist

levenshtein: levenshtein.o
	$(CC) -o levenshtein levenshtein.o

printmindist: printmindist.o
	$(CC) -o printmindist printmindist.o

clean:
	rm -f levenshtein levenshtein.o core
	rm -f printmindist printmindist.o

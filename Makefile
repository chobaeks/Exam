PROGRAMS := exam exam2 exam3

CC := gcc

all : $(PROGRAMS)

exam : exam.c
	claer
	$(CC) -Wall -o $@ $^

exam2 : exam2.c
	clear
	$(CC) -Wall -o $@ $^

exam3 : exam3.c
	clear
	$(CC) -Wall -o $@ $^

clean :
	rm -rf $(PROGRAMS)

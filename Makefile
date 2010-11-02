PROGRAMS := exam exam2 exam3 exam4

CC := gcc

all : $(PROGRAMS)

exam : exam.c
	clear
	$(CC) -Wall -o $@ $^

exam2 : exam2.c
	clear
	$(CC) -Wall -o $@ $^

exam3 : exam3.c
	clear
	$(CC) -Wall -o $@ $^

exam4 : exam4.c
	clear
	$(CC) -Wall -o $@ $^

clean :
	rm -rf $(PROGRAMS)

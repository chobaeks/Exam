PROGRAMS := exam

CC := gcc

all : $(PROGRAMS)

exam : exam.c
	$(CC) -Wall -o $@ $^

clean :
	rm -rf $(PROGRAMS)

CC := gcc

PROGRAMS := strchr cat ls big-int dic echo_server echo_client address

all: $(PROGRAMS)

strchr: strchr.c
	$(CC) -Wall -o $@ $^

cat: cat.c
	$(CC) -Wall -o $@ $^

ls: ls.c
	$(CC) -Wall -o $@ $^

big-int: big-int.c
	$(CC) -Wall -o $@ $^

#dic: dic.c
#	$(CC) -Wall -o $@ $^

udp_server: udp_server.c
	$(CC) -Wall -o $@ $^

udp_client: udp_client.c
	$(CC) -Wall -o $@ $^

echo_server: echo_server.c
	$(CC) -Wall -o $@ $^

echo_client: echo_client.c
	$(CC) -Wall -o $@ $^

address: address.c 
	clear
	$(CC) -Wall -o $@ $^
	./$@

clean: 
	rm -rf $(PROGRAMS)

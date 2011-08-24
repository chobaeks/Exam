#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>

struct data
{
  int a;
  int b;
  int sum;
};

int 
main (int    argc,
      char **argv)
{
  int sockfd;
  int clilen;
  //int state;
  char buf[255];

  struct sockaddr_in serveraddr;
  struct data add_data;

  memset (buf, 0x00, 255);
  clilen = sizeof (serveraddr);
  sockfd = socket (AF_INET, SOCK_DGRAM, 0);
  
  if (sockfd < 0)
    {
      perror ("socket error : ");

      exit (0);
    }

  bzero (&serveraddr, sizeof (serveraddr));
  serveraddr.sin_family = AF_INET;
  serveraddr.sin_addr.s_addr = inet_addr ("127.0.0.1");
  serveraddr.sin_port = htons (1234);

  add_data.a = atoi (argv[1]);
  add_data.b = atoi (argv[2]);

  sendto (sockfd, (void *)&add_data, sizeof (add_data), 0, (struct sockaddr *)&serveraddr, clilen);
  recvfrom (sockfd, (void *)&add_data, sizeof (add_data), 0, NULL, NULL);

  printf ("--> %d + %d = %d", add_data.a, add_data.b, add_data.sum);

  close (sockfd);
}

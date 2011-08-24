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
main (int     argc,
      char  **argv)
{
  int sockfd;
  int clilen;
  int state;
  int n;
  //int sum;
  struct data add_data;

  struct sockaddr_in serveraddr, clientaddr;

  clilen = sizeof (clientaddr);
  sockfd = socket (AF_INET, SOCK_DGRAM, 0);

  if (sockfd < 0)
    {
      perror ("socket error : ");

      exit (0);
    }

  //bzero : 바이트 스트링 s 의 처음 n 바이트 0 으로 채운다. 즉 초기화한다. 
  bzero (&serveraddr, sizeof (serveraddr));
  serveraddr.sin_family = AF_INET;
  //htonl : long intger 데이터를 호스트 byte order 로 변경한다. 데이터를 받을때 사용한다.
  serveraddr.sin_addr.s_addr = htonl (INADDR_ANY);
  serveraddr.sin_port = htons (80);

  state = bind (sockfd, (struct sockaddr *)&serveraddr, sizeof (serveraddr));

  if (state == -1)
    {
      perror ("bind error : ");
      exit (0);
    }

  while (1)
    {
      n = recvfrom (sockfd, (void *) &add_data, sizeof (add_data), 0, (struct sockaddr *)&clientaddr, &clilen);
      add_data.sum = add_data.a + add_data.b;
      sendto (sockfd, (void *)&add_data, sizeof (add_data), 0, (struct sockaddr *)&clientaddr, clilen);
    }

  close (sockfd);
}

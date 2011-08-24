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
  int sum;
  struct data add_data;

  struct sockaddr_int serveraddr, clientaddr;

  clilen = sizeof (clientaddr);
  sockfd = socket (AF_INET, SOCK_DGRAM, 0);

  if (sockfd < 0)
    {
      perror ("socket error : ");
      exit (0);
    }

  bzero (&serveraddr, sizeof (serveraddr));
  serveraddr.sin_family = AF_INET;
  serveraddr.sin_addr.s_addr = htonl (INADDR_ANY);
  serveraddr.sin_port = htons (1234);

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

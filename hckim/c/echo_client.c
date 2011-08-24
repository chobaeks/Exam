#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 5 
#define echo_client_USAGE     \
"Usage : \n"  \
" echo_clinet <ip> <port> \n" \

int
main (int    argc,
      char **argv)
{
  int sockfd;
  int len;
  int read_strlen;
  char test[30];
  char test_return[30];
  struct sockaddr_in address;

  if (argc != 3)
    {
      printf("Error\n%s", echo_client_USAGE);

      exit (EXIT_FAILURE);
    }

  sockfd = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP);

  if (sockfd == -1)
    {
      perror ("socket error ");

      exit (1);
    }

  address.sin_family = AF_INET;
  address.sin_addr.s_addr = inet_addr (argv[1]);
  //atoi - 문자열을 정수로 변환
  address.sin_port = atoi (argv[2]);
  len = sizeof (address);

  if (connect (sockfd, (struct sockaddr *) &address, sizeof (address)) == -1)
    {
      perror ("connect error ");

      exit (1);
    }
  else
    printf ("Connected Suceesed..!!\n");

  while(1)
    {
      printf ("Input Command (exit to quit) : ");
      fgets (test, 255, stdin);

      if (!strncmp (test, "quit", 4))
        break;

      /*
      if (write (sockfd, test, strlen (test)) == -1)
        {
          perror ("write error :");

          exit (1);
        }
        */

      write (sockfd, test, strlen (test));

      printf ("Message from server :");
        fputs (test_return, stdout);

      printf ("\n");
      /*
         str_len = read (sockfd, test, strlen (test));
         str_len = write (sockfd, test, strlen (test));
         recv_len = 0;

         printf ("%d\n", str_len);

         while (recv_len < str_len)
         {
         if ((recv_cnt = read (sockfd, &test[recv_len], 255)) == -1)
         {
         perror ("read error");

         exit (1);
         }

         printf ("%d\n", recv_cnt);

         recv_len += recv_cnt;
         }

         printf ("Message from server : %s\n", test);
      */
    }

  close (sockfd);
  exit (0);
}

#include <sys/types.h>
#include <sys/socket.h>
#include <stdio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 30
#define echo_server_USAGE     \
  "Usage : \n"  \
" echo_server <port> \n" \

int 
main (int    argc,
      char **argv)
{
  int server_sockfd;
  int client_sockfd;
  int server_len;
  int str_len;
  FILE *fp;
  char ch[30];
  //char ch_fp[256];
  socklen_t client_len;
  //sockaddr_in 으로 생성되있는 구조체를 server_address 와 client_address 로 새로운 구조체를 생성한다.
  struct sockaddr_in server_address;
  struct sockaddr_in client_address;

  fp = fopen ("1.txt", "r");

  if (argc != 2)
    {
      printf ("Error\n%s", echo_server_USAGE);

      exit (EXIT_FAILURE);
    }

  /*
   * 기존의 명명된 소켓을 삭제한다. 
   * unlink - 지정한 파일을 삭제한다.
   */
  unlink ("server_socket");

  /* 
   * 이름없는 서버를 생성한다.
   * socket 은 실패할 경우 -1 을, 성공할 경우 해당 소켓의 번호(?) 을 리턴한다.
   * PF_INET = IPv4를 사용하겠다.
   * SOCK_STREAM = 연결지향형 을 사용하겟다.
   * 0 = IPv4 연결지향형은 TCP 밖에 없으므로 자동으로 TCP가 된다. 정식적으로는 IPPROTO_TCP 라고 해야한다.)
   */
  server_sockfd = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (server_sockfd == -1)
    {
      perror ("Fail create socket : ");

      exit (0);
    }

  //소켓에 이름을 부여한다.
  server_address.sin_family = AF_INET;
  //htonl (INADDR_ANY) = 현재PC IP
  server_address.sin_addr.s_addr = htonl (INADDR_ANY);
  server_address.sin_port = atoi (argv[1]);
  server_len = sizeof (server_address);

  /*
   * bind 함수는 소켓에 주소, 프로토콜, 포트를 할당한다.
   * server_sockfd 소켓에 
   * server_address 의 객체에 있는 주소, 프로토콜, 포트를
   * server_len 데이터의 길이만큼 할당한다.
   * 정상적으로 성공하면 0 실패하면 -1 을 리턴한다.
   */
  if (bind (server_sockfd, (struct sockaddr *) &server_address, server_len) == -1)
    {
      perror ("bind error ");

      exit(1);
    }

  /* 
   * 연결 대기열을 생성하고 클라이언트의 요청을 기다린다.
   * listen 에는 SOCK_STREAM 이나 SEQPACKET 만 사용가능하며 5는 연결 대기열의 최대 숫자를 의미한다.
   */
  if (listen (server_sockfd, 5) == -1)
    {
      perror ("listen error ");

      exit (1);
    }

  while (1)
    {
      printf ("server waiting\n");

      client_len = sizeof (client_address);
      client_sockfd = accept (server_sockfd, (struct sockaddr *) &client_address, &client_len);

      if (client_sockfd == -1)
        {
          perror ("accept error ");

          exit (1);
        }
      else
        printf ("Connected client \n");

      while ((str_len = read (client_sockfd, ch, BUFSIZE)) != 0)
        write (client_sockfd, ch, str_len);

      close (client_sockfd);
    }

  close (server_sockfd);
  return 0;
}

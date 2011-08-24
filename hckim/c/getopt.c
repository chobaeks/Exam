#include <stdio.h>
#include <unistd.h>

int
main(int    argc,
     char **argv)
{
  int test;

  while ((test = getopt (argc, argv, "hvf:")) != -1)
    {
      switch (test)
        {
        case 'h':
          printf ("h옵션입니다\n");
          printf ("%s\n", argv[1]);
          break;
        case 'v':
          printf ("v옵션입니다\n");
          break;
        case 'f':
          printf ("f옵션입니다\n");
          break;
        }
    }

  return 0;
}

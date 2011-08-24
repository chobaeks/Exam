#include <stdio.h>

int
main (int    argc,
      char **argv)
{
  int number;
  int blank;
  int i;
  int j;

  number = 5;
  blank = (number - 1) / 2;

  for (i = 1; i < ((number -1) / 2); ++i)
    {
      for (j = 0; j < blank; ++j)
        printf (" ");

      for (j = 0; j < i; ++j)
        printf ("+");

      for (j = 0; j < blank; ++j)
        printf (" ");

      printf ("\n");
      ++blank;
    }

  return 0;
}


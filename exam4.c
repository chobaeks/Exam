#include <stdio.h>

int
main (int    argc,
      char **argv)
{
  int i = 1;
  int j = 0;

  while (1)
    {
      printf ("%d ", i);
      if (j == 4)
      break;
      j++;
      i++;

      printf ("\n");
    }
}

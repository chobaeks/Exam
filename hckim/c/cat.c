#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int
main (int   argc,
      char *argv[])
{
  FILE *fpr;
  char bufr[256];
  int i;
  int option; /* 예외처리 설정 -n 일 경우 1로 동작*/ 
  int count;

  option = 0;
  count = 1;

  for (i = 1; i < argc; i++)
    {
      if (strcmp(argv[i], "-n") == 0)
        {
          if (argc == 2)
            { 
              while ( fgets (bufr, sizeof (bufr), stdin) != NULL)
                {
                  printf ("%6d\t%s", count, bufr);

                  count++;
                }

              exit (EXIT_SUCCESS);
            }

          option = 1;
        }
    }

  if (argc == 1) 
    {
      while ( fgets (bufr, sizeof (bufr), stdin) != NULL)
        printf ("%s", bufr); 

      exit (EXIT_SUCCESS);
    }

  for (i = 1; i < argc; i++)
    {
      if (strcmp (argv[i], "-") == 0)
        {
          while ( fgets (bufr, sizeof (bufr), stdin) != NULL)
            {
              if (option == 1)
                {
                  printf ("%6d\t", count);
                  count++;
                }
              printf ("%s", bufr);
            }
        }

      if ( !(fpr = fopen (argv[i], "r")) )
        {
          if ( !(strcmp(argv[i], "-") == 0 || strcmp (argv[i], "-n") ==0) )
            printf ("cat: %s: No Such fire or directory\n", argv[i]);
        }
      else 
        {
          while (1)
            {
              fgets (bufr, sizeof (bufr), fpr);

              if (feof (fpr))
                {
                  fclose (fpr);

                  break;
                }

              if (option == 1)
                {
                  printf ("%6d\t", count);
                  count++;
                }

              printf ("%s", bufr);
            }
        }
    }

  return 0;
}

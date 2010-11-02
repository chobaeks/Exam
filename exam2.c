#include <stdio.h>
#include <string.h>

int
main (int   argc,
      char *argv[])
{
  int result;
  char newfilename[256];

  result = 0;

  if (argc <= 1) 
    {
      printf ("usuage : %s filename\n", argv[0]);

      return 1;
    }

  if ( strcmp(argv[1], "-d") == 0 )
    {
      if (argc <= 2)
        {
          printf ("usuage : %s -d filename\n", argv[0]);

          return 2;
        }

      result = remove (argv[2]);

      if (result == 0)
        printf ("deleted succed\n");

      else
        printf ("deleted failed\n");
    }

      sprintf (newfilename, "%s.bak", argv[1]);

      result = rename (argv[1], newfilename);

      if (result == 0)
        printf ("file conversion succed\n");

      else
        printf ("file conversion failed\n");

  return 0;
}

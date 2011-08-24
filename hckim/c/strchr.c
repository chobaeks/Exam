#include <stdio.h>
#include <string.h>
#include <malloc.h>

int
main (int   argc,
      char *argv[])
{
  char *p;
  int i, count;
  int *find;  

  find = (int *) malloc (sizeof (int) * strlen (argv[1]) );

  if (!find)
    return 1;

  count = 0;

  if (argc <= 2) 
    {
      printf("usuage : %s '문장' '찾을문자'\n", argv[0]);

      return 1;
    }

  p = argv[1];

  while (1)
    {
      p = strchr (p, argv[2][0]);

      if (!p)
        break;

      find[count] = strlen (p); 

      count++;
      p++;
    }

  printf ("%d\n", count);

  for (i = 0; i < count; i++)
    printf ("%d\n", strlen (argv[1]) - find[i] + 1);

  free (find);

  return 0;
}

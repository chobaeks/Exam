#include <stdio.h>
#include <string.h>

int
main (int   argc,
      char *argv[])
{
  FILE *fpr, *fpw;
  char bufr[256], bufw[256];
  char filename[256], newfilename[256]; 
  char oldchar [] = "dog";
  char newchar [] = "rabbit";
  char *p, *q;

  printf ("바꿀 파일명을 입력하십시요 :");

  scanf ("%s", filename);

  if ( !(fpr = fopen (filename, "r")) )
    {
      printf ("파일이 없거나 읽기에 실패하였습니다 : ");

      return 1;
    }

/*
  printf ("변경하고 싶은 문자를 입력하십시요 :");

  scanf ("%s", oldchar);

  printf ("어떤 문자로 변경할지 입력하십시요 :");

  scanf ("%s", newchar);
*/

  sprintf (newfilename, "%s", newchar);

  if ( !(fpw = fopen (newfilename, "w")) )
    {
      printf ("파일 쓰기에 실패하였습니다 : ");

      return 2;
    }

  while (1)
    {
      fgets (bufr, 256, fpr);

      if (feof (fpr))
        break;

      strcpy (bufw, bufr);

      p = strstr (bufr, oldchar);

      if (p)
        {
          q = bufw + (p - bufr);
          strcpy (q, newchar);
          printf ("%s", q);
          break;
          strcpy (q + strlen (newchar), p + strlen (oldchar));
        }

      fprintf (fpw, "%s", bufw);
    }

  fclose (fpr);
  fclose (fpw);

  return 0;
}

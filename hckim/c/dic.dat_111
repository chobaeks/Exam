/**
  dic.c 와  dic.dat 영어사전

  dic search
  단어 출력
  뜻 출력

  dic add 단어 뜻
  단어 확인

  dic remove
  그 줄 지우고 아래에서 땡긴다.

  dic bookmark list 
  dic bookmark add <word>
  dic bookmark remove <word>

  filename : bookmark.dat

  -b options path

  dic.dat 파일이 있는 디렉토리에 있는지 첫째로 확인 
  없을 경우 현재 디렉토리 확인
  없을 경우 에러 메세지

  dic -s xxx.dat 
  옵션을 줄 경우 특정 폴더에서 dat 파일을 불러온다.
  */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define DIC_COMMAND_ADD           "add"
#define DIC_COMMAND_SEARCH        "search"
#define DIC_COMMAND_REMOVE        "remove"
#define DIC_COMMAND_LIST          "list"
#define DIC_COMMAND_S             "-s"
#define DIC_COMMAND_BOOKMARK       "bookmark"
#define DIC_OPTION_ASCEND         "ascend"
#define DIC_OPTION_DESSCEND       "desscend"

#define DIC_USAGE          \
  "Usage:\n" \
"    dic [options] <command> \n" \
"\n" \
"Command:\n" \
"    search <word>\n" \
"       word에 해당하는 뜻을 찾아 출력해준다." \
"\n" \
"    add <word> <meaning>\n" \
"       word에 단어를 meaning에 뜻을 적으면 dic.dat 파일에 저장한다." \
"\n" \
"    remove <word>\n" \
"       word에 단어를 찾아 지운다." \
"\n" \
"    list ascend\n" \
"       단어를 오름차순으로 출력해준다." \
"\n" \
"    list desscend\n" \
"       단어를 내림차순으로 출력해준다." \
"\n" \
"    bookmark list\n" \
"       bookmark 의 단어를 출력해준다." \
"\n" \
"    bookmark add <word>\n" \
"       word 를 찾아 bookmark.dat 파일에 추가해준다." \
"\n" \
"    bookmark remove <word>\n" \
"       word 를 찾아 bookmark.dat 파일에서 지운다." \
"\n" \
"\n" \
"Option:\n"\
"    -s <path>\n" \
"      path에 해당하는 사전 dat 파일을 불러온다." \
"\n" \
"    -b <path>\n" \
"      path에 해당하는 북마크 dat 파일을 불러온다." \
"\n" \
/*
void
dic_sort (char **listsort)
{
  char *strtmp;
  int highlength;
  int i;
  int j;

  i = 0;

  while (1)
    {
      if (strlen (listsort[i]) < strlen (listsort[i + 1]))
        highlength = strlen (listsort[i + 1]);
      else
        highlength = strlen (listsort[i]);

      for (j = 0; j < highlength; j++)
        {
          if (listsort[i][j] < listsort[i + 1][j])
            {
              strtmp = listsort[i];
              listsort[i] = listsort[i + 1];
              listsort[i + 1] = strtmp;
              i = 0;

              break;
            }
        }
    }
}
*/

/**
 *  모든 argv 를 검사하여 command 와 일치하는 문자가 있으면 1을 리턴한다. 없으면 0 을 리턴한다.
 */
int
dic_command_compare (int    argc,
                     char **argv,
                     char *command)
{
  int i;
  int result;

  result = 0;

  for (i = 0; i < argc; i++)
    {
      if (!strcmp (argv[i], command))
        result = i + 1;
    }

  return result;
}

/**
 * fp 의 첫 문자부터 '|' 가 나올떄까지의 문자열을 query 와 비교하여 
 * 동일할 경우 1 을 반환한다. 틀릴경우 0 을 반환한다.
 * fp 에 EOF 가 나올떄까지 반복한다.
 * 문자열이 동일하고 option 이 1 일 경우 문자열이 동일한 행을 출력한다.
 * option 이 2 일 경우 dic.dat_tmp 파일에 query 를 제외한 문자열을 넣어놓는다.
 * option 이 3 일 경우 '|' 가 나올때까지 비교하는게 아니라 '\n' 이 나올때까지를 한 행으로 보고 비교한다.
 * option 이 4 일 경우 '\n' 이 나올떄까지 비교후에 bookmark.dat_tmp 에 넣고 query 를 제외한 문자열을 넣는다.
 */
int
dic_search_and_print (FILE *fp,
                      char *query,
                      int   option)
{
  int result;
  int search;
  int findpipe;
  int firstpipe;
  char *tmp_str;
  char *tmp_pipechr;
  char tmp_chr;
  FILE *tmp_fp;
  int i;
  
  if (option == 2)
    tmp_fp = fopen ("dic.dat_tmp", "a");

  if (option == 4)
    tmp_fp = fopen ("bookmark.dat_tmp", "a");

  result = 0;
  firstpipe = 0;

  while (1)
    {
      if (getc(fp) == EOF)
        break;

      fseek (fp, -1, SEEK_CUR);

      search = 1;

      while ((tmp_chr = getc (fp)) != '\n')
        {
          if (option != 3 || option != 4)
            if (tmp_chr == '|')
              findpipe = search;

          ++search;
        }

      if (option == 3 || option == 4)
        findpipe = search;

      tmp_str = (char *) malloc ((sizeof (char) * (search + 1)));
      tmp_pipechr = (char *) malloc ((sizeof (char) * (findpipe - 1)));

      fseek (fp, - search, SEEK_CUR);
      fgets (tmp_str, search + 1, fp); 

      for (i = 0; i < findpipe - 1; i++)
        tmp_pipechr[i] = tmp_str[i];

      if (strcmp (tmp_pipechr, query) == 0)
        {
          result = 1;

          if (option == 1)
            for (i = 0; i < strlen (tmp_str); i++)
              {
                if (tmp_str[i] == '|' && firstpipe == 0)
                  {
                    printf ("\n");
                    firstpipe = 1;
                    continue;
                  }

                printf ("%c", tmp_str[i]);
              }
          else if (option == 2 || option == 4)
            continue;
        }

      if (option == 2 || option == 4)
        {
          printf ("%s\n", tmp_str);
            fprintf (tmp_fp, "%s", tmp_str);
        }
    }

  if (option == 2 || option == 4)
    fclose (tmp_fp);

  return result;
}

/**
 * msg 로 받은 문자를 출력후 사용법을 출력하고 프로그램을 종료한다.
 */
static void
dic_error_and_exit (const char *msg)
{
  if (msg)
    fprintf (stderr, "%s\n", msg);
  printf ("%s", DIC_USAGE);

  exit (EXIT_FAILURE);
}

int
listqsort (const void *a, const void *b)
{
  return (strcmp ( *(char* const*)a, *(char* const*)b));
}

int
listdescqsort (const void *a, const void *b)
{
  return (strcmp ( *(char* const*)b, *(char* const*)a));
}

int
main (int    argc,
      char **argv)
{
  char *dicdat_path;
  char *bookmarkdat_path;
  char *command2;
  char *add_body;
 // char *check_option;
  char list;
  char **listsort;
  FILE *fp;
  FILE *fp_bookmark;
  int opt;
  int i;
  int j;
  int listline;
  int listsortline;
  int lastline;
  int listoption;
  int search_result;
  int command_compare;
  int listqsort (const void *a, const void *b);

  if (argc < 2)
    dic_error_and_exit ("command is needed");

  dicdat_path = (char *) malloc (sizeof(char) * strlen (argv[0]) + 5);
  bookmarkdat_path = (char *) malloc (sizeof(char) * 13);

  bookmarkdat_path = "bookmark.dat";

  sprintf (dicdat_path, "%s.dat", argv[0]);

  fp = fopen (dicdat_path, "r");

  if (fp == NULL)
    {
      dicdat_path = "dic.dat";
      fp = fopen (dicdat_path, "r");

      if (fp == NULL)
        {
          printf ("No file.\n");

          return 0;
        }
    }

  /**
   * -s, -b 가 포함되어 있을 경우
   */
  while ( (opt = getopt (argc, argv, "s:b:")) != -1)
    {
      switch (opt)
        {
        case 's':
          if ((argv[optind - 1][strlen (argv[optind - 1]) - 1]) != 't' || (argv[optind - 1][strlen (argv[optind - 1]) - 2]) != 'a' || (argv[optind - 1][strlen (argv[optind - 1]) - 3]) != 'd'  || (argv[optind - 1][strlen (argv[optind - 1]) - 4]) != '.' ) 
            dic_error_and_exit ("Filepath is only dat file.");

          if ((access (argv[optind - 1],F_OK)) == -1)
            {
              printf ("No file.\n");

              return 0;
            }
          else
            dicdat_path = argv[optind - 1];

        case 'b':
          if ((argv[optind - 1][strlen (argv[optind - 1]) - 1]) != 't' || (argv[optind - 1][strlen (argv[optind - 1]) - 2]) != 'a' || (argv[optind - 1][strlen (argv[optind - 1]) - 3]) != 'd'  || (argv[optind - 1][strlen (argv[optind - 1]) - 4]) != '.' ) 
            dic_error_and_exit ("Filepath is only dat file.");

          bookmarkdat_path = (char *) malloc (sizeof(char) * strlen (argv[optind - 1]) + 1);
          bookmarkdat_path = argv[optind - 1];
        }
    }
  /*
  if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_S)) != 0)
    {
      dicdat_path = argv[command_compare + 1];
      fp = fopen (dicdat_path, "r");

      if (fp == NULL)
        {
          printf ("No file.\n");

          return 0;
        }
    }
  else 
    {
      dicdat_path = (char *) malloc (sizeof(char) * strlen (argv[0]) + 5);

      sprintf (dicdat_path, "%s.dat", argv[0]);

      fp = fopen (dicdat_path, "r");

      if (fp == NULL)
        {
          dicdat_path = "dic.dat";
          fp = fopen (dicdat_path, "r");

          if (fp == NULL)
            {
              printf ("No file.\n");

              return 0;
            }
        }
    }
*/

  fp = fopen (dicdat_path, "a+");

for (j = 1; j < argc - 1; j++)
  {
    /**
     * search
     */
    if (! (strcmp (argv[j], DIC_COMMAND_SEARCH))) 
      //if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_SEARCH)) != 0)
      {
        if (j + 1 >= argc )
          dic_error_and_exit ("search command after one string.");

        command2 = argv[j + 1];

        search_result = dic_search_and_print (fp, command2, 1);

        if (search_result == 0)
          printf ("Error : %s\nIt is not present.\n", command2);

        return 0;
      }
    /**
     * add
     */
    else if (! (strcmp (argv[j], DIC_COMMAND_ADD)))
    //else if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_ADD)) != 0)
      {
        if (j + 1 >= argc)
          dic_error_and_exit ("add command after two string.");

        command2 = argv[j + 1];
        add_body = argv[j + 2];

        search_result = dic_search_and_print (fp, command2, 0);

        if (search_result == 1)
          printf ("Error : %s\nIt is already present.\n", command2);
        else
          {
            fprintf (fp, "%s|%s\n", command2, add_body); 
            printf ("%s add suceseed.\n", command2); 
          }
        //fwrite (command2, sizeof(char), strlen(command2), fp); 
        return 0;
      }
    /**
     * remove 
     */
    else if (! (strcmp (argv[j], DIC_COMMAND_REMOVE)))
    //else if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_REMOVE)) != 0)
      {
        if (j + 1 >= argc) 
          dic_error_and_exit ("remove command after one string.");

        command2 = argv[j + 1];

        search_result = dic_search_and_print (fp, command2, 0);

        if (search_result == 0)
          printf ("Error : %s \nIt is not present.\n", command2);
        else
          {
            fseek (fp, 0, SEEK_SET);
            dic_search_and_print (fp, command2, 2);

            remove (dicdat_path);

            if (rename ("dic.dat_tmp", dicdat_path) != 0)
              {
                printf ("dicdat_path rename fail.\n");

                exit (EXIT_FAILURE);
              }

            printf ("%s remove suceseed.\n", command2);
          }

        return 0;
      }
    /**
     * list
     */
    else if (! (strcmp (argv[j], DIC_COMMAND_LIST)))
    //else if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_LIST)) != 0)
      {
        if (j + 1 == argc)
          dic_error_and_exit ("list command after one string.");
        else if (!strcmp (argv[j + 1], DIC_OPTION_ASCEND))
          listoption = 1;
        else if (!strcmp (argv[j + 1], DIC_OPTION_DESSCEND))
          listoption = 2;

        fseek (fp, 0, SEEK_SET);

        lastline = 0;
        listline = 0;
        listsortline = 0;

        //getc 로 \n 가 있을때마다 listline 을 1 씩 올려 총 줄의 갯수를 얻어온다.
        while (1)
          {
            if (getc (fp) == EOF)
              break;

            fseek (fp, -1, SEEK_CUR);

            list = getc (fp);

            if (list == '\n')
              ++lastline;
          }

        listsortline = 0;
        listsort = (char* *) malloc (sizeof(char*) * lastline);

        fseek (fp, 0, SEEK_SET);

        while (1)
          {
            if (getc (fp) == EOF)
              break;

            fseek (fp, -1, SEEK_CUR);

            list = getc (fp);
            ++listline;

            if (list == '|')
              {
                listsort[listsortline] = (char *) malloc (sizeof(char) * listline + 1);

                fseek (fp, - listline, SEEK_CUR);
                fgets (listsort[listsortline], listline, fp); 

                while (getc (fp) != '\n')

                  listline = 0;
                ++listsortline;
              }
          }

        if (listoption == 1)
          qsort ((void *)listsort, lastline, sizeof(listsort[0]) , listqsort);
        else
          qsort ((void *)listsort, lastline, sizeof(listsort[0]) , listdescqsort);

        for (i = 0; i < lastline; i++)
          {
            printf ("%s\n", listsort[i]);
          }

        return 0;
      }
    /**
     * bookmark 
     */
    else if (! strcmp (argv[j], DIC_COMMAND_BOOKMARK))
    //else if ((command_compare = dic_command_compare (argc, argv, DIC_COMMAND_BOOKMARK)) != 0)
      {
        if (j + 1 == argc)
          dic_error_and_exit ("Unknown Bookmark Command.");

        if (!strcmp (argv[j + 1], "add"))
          {
            if (j + 2 >= argc)
              dic_error_and_exit ("Bookmark add command after one string.");

            fp_bookmark = fopen (bookmarkdat_path, "a+");

            if ((dic_search_and_print (fp_bookmark, argv[j + 2], 3)) == 1)
              printf ("Error : %s\nIt is already present.\n", argv[j + 2]);
            else
              {
                fprintf (fp_bookmark, "%s\n", argv[j + 2]); 
                printf ("%s add suceseed.\n", argv[j + 2]); 

              }
          }
        else if (!strcmp (argv[j + 1], "list"))
          {
            fp_bookmark = fopen (bookmarkdat_path, "a+");

            while (1)
              {
                if ( getc (fp_bookmark) == EOF)
                  break;

                fseek (fp_bookmark, -1, SEEK_CUR);

                printf ("%c", getc (fp_bookmark));
              }
          }
        else if (!strcmp (argv[j + 1], "remove"))
          {
            if (j + 2 >= argc)
              dic_error_and_exit ("Bookmark remove command after one string.");

            fp_bookmark = fopen (bookmarkdat_path, "a+");

            if ((dic_search_and_print (fp_bookmark, argv[j + 2], 3)) == 0)
              printf ("Error : %s\nIt is not present.\n", argv[j + 2]);
            else 
              {
                fseek (fp, 0, SEEK_SET);
                dic_search_and_print (fp_bookmark, argv[j + 2], 4);

                remove (bookmarkdat_path);

                if (rename ("bookmark.dat_tmp", bookmarkdat_path) != 0)
                  {
                    printf ("bookmark_path rename fail.\n");

                    exit (EXIT_FAILURE);
                  }

                printf ("%s remove suceseed.\n", argv[j + 2]);
              }
          }

        return 0;
      }
    // 해당하지 않는 경우
  }
dic_error_and_exit ("Unknown command");

fclose (fp);

return 0;
}

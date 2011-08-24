#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>

int
main (int    argc,
      char **argv)
{
  struct dirent *item;
  struct stat file_info;
  char *sortarray[255];//정렬을 위해 폴더의 내용을 배열에 적용. 255 일 경우 파일이 255 개를 넘으면 255개 이상은 읽지 못함. mallc 로 이후 변경
  char *temp; //버블정렬의 치환을 위한 임시 포인터
  char *filetemp[255]; //argc 를 검사해 파일일 경우 해당 배열포인터에 넣어놓는다.
  DIR *dp;
  int option;
  int i;
  int sortfor;
  int sortnext;
  int filefor;
  int returnstat; // stat 의 결과값을 받는다. (파일이나 폴더가 없을경우 -1 이 나온다) 
  int sortcount; // 버블정렬을 위한 배열의 변수. string에서 읽어들인 폴더의 파일갯수만큼을 기억한다. 한 폴더를 다 읽어들인후 0 으로 초기화된다.
  int multicount; // ./ls -a ~ 경우의 예외처리를 위한 count. argc 의 count 를 세고 -a 일 경우에는 + 시키지 않는다. 
  int arraycount; // 첫 줄은 띄우지 않기 위한 변수. printf 될 경우에 count 가 하나씩 올라간다. 0 일 경우에는 한칸을 띄우지 않는다.

  mode_t file_mode; // 이 부분이 무슨 구문인지 더 자세히 확인

  arraycount = 0;
  filefor = 0;
  option = 0;
  multicount = 0;

// argc 를 확인하여 -a 가 들어가있을 경우 option 값을 적용하고 multicount 로 -a 를 제외한 숫자를 센다. returnstat 가 -1 일 경우에 (파일이나 폴더가 없을경우) 에러 메세지를 출력한다. 
// returnstat 가 -1 이고 (파일이나 폴더가 아닐경우) 사이즈가 4096 가 아닐경우 (폴더가 아닐경우) filetemp 배열에 0 부터 넣는다.
  for (i = 1; i < argc; i++)
    {
      if (strcmp (argv[i], "-a") == 0)
        {
          option = 1;

          continue;
        }
      returnstat = stat (argv[i], &file_info);

      if (returnstat == -1)
        {

        if (arraycount > 0)
          printf("\n");

        printf ("ls: %s에 접근할 수 없습니다.: No such file or directory", argv[i]);

        arraycount++;
        }

      if (returnstat != -1 && file_info.st_size != 4096)
        {
          filetemp[filefor] = argv[i];
          filefor++;
        }

      multicount++;
      file_info.st_size = 0;
    }

  // 파일 (filetemp배열) 을 출력한다.
  if (filetemp[0] != NULL)
    {
      if (arraycount > 0)
          printf ("\n");

      for (i = 0; i < filefor; i++)
        {
          printf ("%s  ", filetemp[i]);
          arraycount++;
        }
    }

// argv 를 한 구문씩 opendir 로 읽어들여 폴더일경우 정상출력. 그 외의 경우 continue 처리.
  for (i = 0 ; i < argc; i++)
    {
      sortcount = 0;

      returnstat = stat (argv[i], &file_info); 
      file_mode = file_info.st_mode; // mode_t file_mode; 라인과 함께 무슨 구문인지 더 자세히 확인

      dp = opendir (argv[i]);

      if (multicount > 1 && arraycount > 0 && file_info.st_size == 4096) // argc string 이 2개 이상이고 2번째 출력이고 폴더일 경우에만 출력전에 한칸 띄운다.
        printf ("\n");

      if ( (argc == 1) || ((argc == 2) && (strcmp(argv[i], "-a") == 0)) ) // ./ls  이거나 ./ls -a 일 경우 해당 폴더를 출력
        {
          dp = opendir(".");
          file_info.st_size = 4096;
        }
// 폴더일 경우 출력문
      if (file_info.st_size == 4096) 
        {
          if (multicount > 1 && (strcmp (argv[i], "-a") != 0 )) // -a 를 제외한 string 이 2개 이상일 경우에 ".:" 을 추가
            {
              if (arraycount > 0)
                printf ("\n");

              printf ("%s:\n", argv[i]);
              arraycount++;
            }

          if (dp != NULL)
            {
              while (1)
                {
                  item = readdir (dp);
                  if (item == NULL)
                    break;

                  sortarray[sortcount] = item->d_name;

                  sortcount++;
                  /*
                     if (option == 1)
                     {
                     printf ("%s  ",item->d_name);
                     }

                     else if (option == 0)
                     {
                     if ( !(item->d_name[0] == '.') )
                     printf ("%s  ", item->d_name);
                     }
                     */
                }
            }

          for (sortfor = 0; sortfor < sortcount - 1; sortfor++) //버블정렬
            {
              if (sortarray[sortcount + 1] == NULL)
                break;

              for (sortnext = 0; sortnext < strlen (sortarray[sortfor]) || sortnext < strlen (sortarray[sortfor + 1]); sortnext++)
                {
                  if (sortarray[sortfor][sortnext] > sortarray[sortfor + 1][sortnext])
                    {
                      temp = sortarray[sortfor];
                      sortarray[sortfor] = sortarray[sortfor + 1];
                      sortarray[sortfor + 1] = temp;

                      sortfor = -1;
                      break;
                    }

                  else if (sortarray[sortfor][sortnext] == sortarray[sortfor + 1][sortnext])
                    continue;

                  else 
                    break;
                }
            }

          for (sortfor = 0; sortfor <= sortcount - 1; sortfor++) //정렬후 출력
            {
              if ( !((option == 0) && (sortarray[sortfor][0] == '.'))) 
                  printf ("%s  ", sortarray[sortfor]);
            } 
        }

      else if ( strcmp (argv[i], "./ls") == 0 || strcmp (argv[i], "-a") == 0 || returnstat == -1 ) // ./ls 나 -a  폴더도 아니고 파일도 아닐경우 경우 무시하고 다음으로 진행
        {
          closedir (dp);
          continue;
        }

      /*
         else if (returnstat == -1) // 폴더도 아니고 파일도 아닐경우 무시하고 다음으로 진행
         {
         closedir (dp);
         continue;
         }

         else // 폴더도 아니고 returnstat 값이 -1 이 아닐 경우 (파일일경우) 그냥 출력
         {
         printf ("%s", argv[i]);
         }
         */

      file_info.st_size = 0;
      closedir (dp);
    }
  printf("\n");

  return 0;
}

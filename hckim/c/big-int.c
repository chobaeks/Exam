#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void
big_int_help_string ()
{
  printf ("\nUsuage:\n");
  printf ("\tbig-int <command> [ options ]\n\n");
  printf ("Command:\n");
  printf ("\tadd <num1> <num2>\n");
  printf ("\t\tnum1 과 num2 을 합한 값을 출력합니다.\n");
  printf ("\n");
  printf ("\tsubtract <num1> <num2>\n");
  printf ("\t\tnum1에서 num2를 뺀 값을 출력합니다.\n");
  printf ("\n");
  printf ("\tlarger <num1> [ <num2>, ... ]\n");
  printf ("\t\t입력한 숫자 중 가장 큰 수를 출력합니다.\n");
  printf ("\n");
  printf ("\tsmaller <num1> [ <num2>, ... ]\n");
  printf ("\t\t입력한 숫자 중 가장 작은 수를 출력합니다.\n");
  printf ("\n");
  printf ("\tsort ascend <num1> [ <num2>, ... ]\n");
  printf ("\t\t입력한 숫자를 오름차순으로 정렬합니다.\n");
  printf ("\n");
  printf ("\tsort descend <num1> [ <num2>, ... ]\n");
  printf ("\t\t입력한 숫자를 내림차순으로 정렬합니다.\n");
  printf ("\n");
  printf ("\tequal <num1> <num2>\n");
  printf ("\t\t입력한 숫자가 같은지 다른지 여부를 TRUE/FALSE 형태로 출력합니다.\n");
  printf ("\n");
}


/*
NAME
   big_int_waring_string - 경고 메세지 출력.

SYNOPSIS
   big_int_waring_string (int number);

DESCRIPTION
   "Waring : " 메세지는 필수적으로 출력되며 number 에 따라 다른 경고 메세지를 출력한다.

   1 - Characters are not allowed. Reference help string.
   2 - Line is false. Reference help string.

   메세지 출력 다음줄에 big_int_help_string 함수를 불러와 help 메세지를 출력한다.
*/
void
big_int_waring_string (int waringnumber)
{
  printf ("Waring : ");

  switch (waringnumber)
    {
    case 1 : printf ("Characters are not allowed. Reference help string.\n");
             break;
    case 2 : printf ("Line is false. Reference help string.\n");
             break;
    }

  big_int_help_string ();
}


/*
NAME
   big_int_checkstring - 숫자 외의 다른 문자가 있는지 검사한다.

SYNOPSIS
   big_int_checkstring (int number, char **string)

DESCRIPTION
   두 번째 (string[1]) 문자열부터 number 만큼의 문자열을 검사하여 add, subtract, larger, smaller, sort, ascend, descend, equal, help 가 있는지 검사한다. 조건을 만족할 경우 다음 문자열을 검사한다.
   조건에 만족하지 않을 경우 문자열의 문자를 검사하여 47이하 58이상 (0 ~ 9) 가 아닐 경우 big_int_waring_string (1) 경고메세지를 출력하고 프로그램을 종료한다.
   단, 문자열의 첫번째 문자가 43 이나 45 (+, -) 를 만족할 경우에는 다음 문자를 검사한다.
*/
void
big_int_checkstring (int argc,
                     char **argv)
{
  int i;
  int j;

  for (i = 1; i < argc; i++)
    {
      if ( (strcmp (argv[i], "add") == 0) || (strcmp (argv[i], "subtract") == 0) || (strcmp (argv[i], "larger") == 0) || (strcmp (argv[i], "smaller") == 0) || (strcmp (argv[i], "sort") == 0) || (strcmp (argv[i], "ascend") == 0) || (strcmp (argv[i], "descend") == 0) || (strcmp (argv[i], "equal") == 0) || (strcmp (argv[i], "help") == 0) )
        continue;

      for (j = 0; j < strlen (argv[i]); j++)
        {
          if ( ((j == 0) && (argv[i][j] == 43)) || ((j == 0) && (argv[i][j] == 45)) )
            continue;

          if ((argv[i][j] <= 47) || (58 <= argv[i][j])) 
            {
              big_int_waring_string(1);

              exit (EXIT_FAILURE);
            }
        }
    }
}


/*
NAME
   big_int_option - 문자열을 확인하여 옵션값을 정한다.

SYNOPSIS
   int big_int_option (int number, char **string)

DESCRIPTION
   number 가 1 이거나 string 의 첫번째 문자열이 "help" 일 경우에 big_int_help_string 함수를 호출하고 프로그램을 종료한다.
   string 의 두 번째 문자열 (string[1]) 을 검사하여 아래 조건에 만족할 경우 option 변수에 해당 값을 넣는다.

   add - 1
   subtract - 2
   larger -3
   smaller - 4
   equal - 7

   두 번째 문자열이 "sort" 일 경우에 세 번째 문자열을 검사하여 아래 조건에 만족할 경우 option 변수에 해당 값을 넣는다.

   ascend - 5
   descend - 6

   두 번째 문자열이 "add" 이거나 "subtract" 일 경우 argv 가 4 가 아니라면 big_int_waring_string (2) 를 호출하고 프로그램을 종료한다.
   두 번째 문자열이 "larger", "smaller", "sort" 일 경우에 argc 가 2 보다 작거나 같다면 big_int_waring_string (2) 를 호출하고 프로그램을 종료한다.
   두 번째 문자열이 "sort" 이고 세 번째 문자열이 "ascend" 이거나 "descend" 일 경웨 argc 가 3 보다 작거나 같다면 big_int_waring_string (2) 를 호출하고 프로그램을 종료한다.
   두 번째 문자열이 "sort" 이고 세 번째 문자열이 "ascend" 나 "descend" 가 아닐 경우에는 "Unknown command : " 문자출력 후 string[2] 문자를 출력하고 big_int_help_string 을 호출한후 프로그램을 종료한다.
   상위 조건을 만족하지 않을 경우에"Unknown command : "문자출력 후 string[1] 문자를 출력하고 big_int_help_string 을 호출한후 프로그램을 종료한다.

RETURN VALUE
   big_int_optino 함수는 option 변수를 반환한다.
*/


int
big_int_option(int    argc,
               char **argv)
{
  int option;

  if (argc == 1 || strcmp (argv[1], "help") == 0)
    {
      big_int_help_string ();

      exit (EXIT_FAILURE);
    }

  if ((strcmp (argv[1], "add") == 0))
    {
      if (argc != 4)
        {
          big_int_waring_string (2);          

          exit (EXIT_FAILURE);
        }

      option = 1;
    }
  else if ((strcmp (argv[1], "subtract") == 0))
    {
      if (argc != 4)
        {
          big_int_waring_string (2);

          exit (EXIT_FAILURE);
        }

      option = 2;
    }
  else if ((strcmp (argv[1], "larger") == 0))
    {
      if (argc <= 2)
        {
          big_int_waring_string (2);

          exit (EXIT_FAILURE);
        }

      option = 3;
    }
  else if ((strcmp (argv[1], "smaller") == 0))
    {
      if (argc <= 2)
        {
          big_int_waring_string (2);

          exit (EXIT_FAILURE);
        }

      option = 4;
    }
  else if ((strcmp (argv[1], "sort") == 0))
    {
      if (argc <= 2)
        {
          big_int_waring_string (2);

          exit (EXIT_FAILURE);
        }

      if ((strcmp (argv[2], "ascend") == 0))
        {
          if (argc <= 3)
            {
              big_int_waring_string (2);

              exit (EXIT_FAILURE);
            }

          option = 5;
        }
      else if ((strcmp (argv[2], "descend") == 0))
        {
          if (argc <= 3)
            {
              big_int_waring_string (2);

              exit (EXIT_FAILURE);
            }

          option = 6;
        }
      else
        {
          printf ("Unknown command : %s \n", argv[2]);
          big_int_help_string ();

          exit (EXIT_FAILURE);
        }
    }
  else if ((strcmp (argv[1], "equal") == 0))
    {
      if (argc != 4)
        {
          big_int_waring_string (2);

          exit (EXIT_FAILURE);
        }

      option = 7;
    }
  else
    {
      printf ("Unknown command : %s\n", argv[1]);
      big_int_help_string ();

      exit (EXIT_FAILURE);
    }

  return option;
}


/*
NAME
   big_int_plus - 문자열 덧셈하기

SYNOPSIS
   char *big_int_plus (char *first, char *second)

DESCRIPTION
   first 문자열과 second 문자열을 덧셈해서 "plus" 포인터에 저장한다.
   big_int_plus 함수는 +, - 를 인식하지 못한다. 만약 앞에 +, - 가 존재할 경우 big_int_plusminusdelete 함수를 통해 삭제해야한다.

RETURN VALUE
   big_int_plus 함수는 plus 포인터를 반환한다.

BUGS
   big_int_plus 함수는 정수에 대한 덧셈이다. 만약 48 ~ 57 을 벗어난 값이 들어올 경우 예상하지 못한 값이 출력된다.
*/
char
*big_int_plus(char *plus_first, char *plus_second)
{
  char *plus;
  int firststrlen;
  int secondstrlen;
  int i;
  int j;
  int k;

  i = 0;
  k = -1;
  j = 0;

  firststrlen = strlen (plus_first);
  secondstrlen = strlen (plus_second);

  if (strlen (plus_first) > strlen (plus_second))
    plus = (char *) calloc (strlen (plus_first), sizeof (char));
  else
    plus = (char *) calloc (strlen (plus_second), sizeof (char));


  while (1)
    {
      if (k + 1 == firststrlen)
        break;

      k++;

      if (plus_first[k] == 48)
        continue;
      else
        break;
    }

  while (firststrlen + secondstrlen != 0)
    {
      //더한 숫자가 9 (아스키코드 105) 을 넘어갈경우
      if ((plus_first[firststrlen - 1] + plus_second[secondstrlen - 1] + plus[i]) >= 106)
        {
          //다음에 남아있는 숫자가 없다면 숫자 1 (아스키코드 48) 을 대입한다
          if (firststrlen - 1 == 0 && secondstrlen - 1 == 0)
            plus[i + 1] += 48;

          plus[i] += plus_first[firststrlen - 1] + plus_second[secondstrlen - 1] - 58;
          plus[i + 1] += 1;
        }
      //첫번째 숫자만 자리가 끝났을 경우
      else if (firststrlen == 0)
        if ((plus[i] + plus_second[secondstrlen - 1]) > 57)
          {
            if (plus_second[secondstrlen - 1] == 0)
              plus[i + 1] += 49;

            plus[i] = plus_second[secondstrlen - 1] - 9;
            plus[i + 1] += 1;
          }
        else
          plus[i] += plus_second[secondstrlen - 1];
      //두번째 숫자만 자리가 끝났을 경우
      else if (secondstrlen == 0)
        {
          if ((plus[i] + plus_first[firststrlen - 1]) > 57)
            {
              if (plus_first[firststrlen -1] == 0)
                plus[i + 1] += 49;

              plus[i] = plus_first[firststrlen - 1] - 9;
              plus[i + 1] += 1;
            }
          else
            plus[i] += plus_first[firststrlen - 1];
        }
      else
        plus[i] += plus_first[firststrlen - 1] + plus_second[secondstrlen - 1] - 48;

      i++;
      firststrlen--;
      secondstrlen--;

      //자릿수가 -1 이하일경우에는 0 으로 한다.
      if (firststrlen < 0)
        firststrlen = 0;
      if (secondstrlen < 0)
        secondstrlen = 0;
    }

  return plus;
}


/*
NAME
   big_int_minus - 문자열 뺄셈하기

SYNOPSIS
   char *big_int_minus (char *first, char *second)

DESCRIPTION
   first 문자열에서 second 문자열을 뺄셈해서 "minus" 포인터에 저장한다.
   big_int_minus 함수는 +, - 를 인식하지 못한다. 만약 앞에 +, - 가 존재할 경우 big_int_plusminusdelete 함수를 통해 삭제해야한다.

RETURN VALUE
   big_int_minus 함수는 minus 포인터를 반환한다.

BUGS
   big_int_minus 함수는 정수에 대한 뺄셈이다. 만약 48 ~ 57 을 벗어난 값이 들어올 경우 예상하지 못한 값이 출력된다.
*/
char
*big_int_minus (char *minus_first, char *minus_second)
{
  char *minus;
  int i;
  int firststrlen;
  int secondstrlen;

  firststrlen = strlen (minus_first);
  secondstrlen = strlen (minus_second);

  i = 0;

  if (firststrlen > secondstrlen)
    {
      minus = (char *) calloc (firststrlen, sizeof (char));
    }
  else
    {
      minus = (char *) calloc (secondstrlen, sizeof (char));
    }

  while ((firststrlen + secondstrlen) != 0)
    {
      if (minus_first[firststrlen - 1] + minus[i] < minus_second[secondstrlen - 1])
        {
          minus[i] += minus_first[firststrlen - 1] - minus_second[secondstrlen - 1] + 58;
          minus[i + 1] += -1;
        }
      else if (secondstrlen == 0)
        minus[i] += minus_first[firststrlen - 1];
      else if (minus_first[firststrlen - 1] + minus[i] > minus_second[secondstrlen - 1])
        minus[i] += minus_first[firststrlen - 1] - minus_second[secondstrlen - 1] + 48;
      else
        minus[i] = 48;

      i++;
      firststrlen--;
      secondstrlen--;

      //자릿수가 -1 이하일경우에는 0 으로 한다.
      if (firststrlen < 0)
        firststrlen = 0;
      if (secondstrlen < 0)
        secondstrlen = 0;
    }

  return minus;
}


/*
NAME
   big_int_print - 문자열 정수 출력하기

SYNOPSIS
   big_int_print (char *string)

DESCRIPTION
   string 문자열을 strlen 함수를 이용하여 문자의 갯수를 확인하고 i 에 저장한다.
   i 를 - 시키며 문자를 하나씩 출력한다. 만약 string[i] 가 48 이하이거나 58 이상일 경우에는 i-- 을 시켜 출력하지 않는다. i 가 -1 이 될떄까지 출력한다.
*/
void
big_int_print (char *plusprint)
{
  int i;

  i = strlen (plusprint);

  while (1)
    {
      if (i == 0)
        break;

      if (plusprint[i] <= 48 || 58 <= plusprint[i])
        i--;

      else
        break;
    }

  while (i != -1)
    {
      printf ("%c", plusprint[i]);

      i--;
    }
  printf ("\n");
}


/*
NAME
   big_int_plusminusdelete - 문자열의 +, - 삭제하기

SYNOPSIS
   char big_int_plusminusdelete (char *string)

DESCRIPTION
   string 함수의 첫번재 문자 (string[0]) 에 "+" 나 "-" 가 있을경우 삭제하고 plusminusdelete 문자열에 넣는다. "+" 나 "-" 가 없을 경우 string 그대로 plusminusdelete 문자열에 넣는다.

RETURN VALUE
   big_int_plusminusdelete 함수는 plusminusdelete 의 포인터를 반환한다.
   */
char
*big_int_plusminusdelete (char *plusminusdelete_temp)
{
  int i;
  char *plusminusdelete;

  plusminusdelete = (char *) calloc (strlen (plusminusdelete_temp), sizeof (char));

  if ((plusminusdelete_temp[0] == '-') || (plusminusdelete_temp[0] == '+'))
    {
      for (i = 0; i <= strlen (plusminusdelete_temp); i++)
        plusminusdelete[i] = plusminusdelete_temp[i + 1];

      return plusminusdelete;
    }
  else
    return plusminusdelete_temp;
}


/*
NAME
   big_int_sizecompare - 문자열 정수 크기비교

SYNOPSIS
   int big_int_sizecomapre (char *first, char *second)

DESCRIPTION
   first 문자열과 second 문자열의 크기를 비교하여 sizecompare 에 아래의 조건과 같이 대입한다.

   1 - first 문자열이 클 경우
   2 - second 문자열이 클 경우
   0 - 같을 경우

RETURN VALUE
   big_int_sizecompare 함수는 sizecompare 변수를 반환한다.

BUGS
   big_int_sizecompare 함수는 정수에 대한 값만을 비교한다. 정수 이외의 문자가 들어올 경우 예상하지 못한 결과가 나올 수 있다.
*/
int
big_int_sizecompare (char *sizecompare_first, char *sizecompare_second)
{
  int sizecompare;
  int i;

  if (sizecompare_first[0] != '-' && sizecompare_second[0] == '-')
    sizecompare = 1;
  else if (sizecompare_first[0] == '-' && sizecompare_second[0] != '-')
    sizecompare = 2;
  else if (sizecompare_first[0] != '-' && sizecompare_second[0] != '-') 
    {
      if (strlen (sizecompare_first) == strlen (sizecompare_second))
        {
          for (i = 0; i != strlen (sizecompare_second); i++)
            {
              if (sizecompare_first[i] > sizecompare_second[i])
                {
                  sizecompare = 1;
                  break;
                }
              else if (sizecompare_second[i] > sizecompare_first[i])
                {
                  sizecompare = 2;
                  break;
                }
              else
                sizecompare = 0;
            }
        }

      else if (strlen (sizecompare_first) > strlen (sizecompare_second))
        sizecompare = 1;
      else if (strlen (sizecompare_second) > strlen (sizecompare_first))
        sizecompare = 2;
    }
  else if (sizecompare_first[0] == '-' && sizecompare_second[0] == '-')
    {
      if (strlen (sizecompare_first) == strlen (sizecompare_second))
        {
          for (i = 0; i != strlen (sizecompare_second); i++)
            {
              if (sizecompare_first[i] > sizecompare_second[i])
                {
                  sizecompare = 2;
                  break;
                }
              else if (sizecompare_second[i] > sizecompare_first[i])
                {
                  sizecompare = 1;
                  break;
                }
              else
                sizecompare = 0;
            }
        }
      else if (strlen (sizecompare_first) > strlen (sizecompare_second))
        sizecompare = 2;
      else if (strlen (sizecompare_second) > strlen (sizecompare_first))
        sizecompare = 1;
    }

  return sizecompare;
}


/*
NAME
   big_int_minusfind - 문자열의 양수, 음수 판단

SYNOPSIS
   int big_int_minusfind (char *first, char *second)

DESCRIPTION
   first 와 second 함수의 첫번째 문자를 확인하여 아래와 같이 minusfind 변수에 대입한다.

   1 - first 와 second 모두 "-" 가 아닐경우
   2 - first 와 second 모두 "-" 일 경우
   3 - first 는 "-" 이고 second 는 "-" 가 아닐 경우
   4 - first 는 "-" 가 아니고 secodn 는 "-" 일 경우

RETURN VALUE
   big_int_minusfind 는 minusfind 변수를 반환한다.
*/
int
big_int_minusfind (char *minusfind_first, char *minusfind_second)
{
  int minusfind;

  if (minusfind_first[0] != '-' && minusfind_second[0] != '-')
    minusfind = 1;
  else if (minusfind_first[0] == '-' && minusfind_second[0] == '-')
    minusfind = 2;
  else if (minusfind_first[0] == '-' && minusfind_second[0] != '-')
    minusfind = 3;
  else if (minusfind_first[0] != '-' && minusfind_second[0] == '-')
    minusfind = 4;

  return minusfind;
}


/*
NAME
   big_int_larger - 문자열중 가장 큰 정수 확인

SYNOPSIS
   char *big_int_larger (int number, char **string)

DESCRIPTION
   string 세번째 문자열 (string[2]) 을 larger 포인터 문자열에 대입한다.
   number 가 될떄까지 big_int_sizecompare 함수를 호출하여 string[number] 와 larger 포인터의 크기를  확인한다.
   만약 big_int_sizecompare 의 반환값이 2일 경우에 string[number] 와 larger 를 바꾼다.
   number 가 끝나지 않았으면 계속 진행한다.

RETURN VALUE
   big_int_larger () 함수는 larger 포인터를 반환한다.
*/
char
*big_int_larger (int argc, char **argv)
{
  char *larger;
  int i;
  int sizecompare_larger;

  larger = argv[2];

  for (i = 3; i < argc; i++)
    {
      sizecompare_larger = big_int_sizecompare (larger, argv[i]);

      if (sizecompare_larger == 2)
        larger = argv[i];
    }

  return larger;
}


/*
NAME
   big_int_smaller - 문자열중 가장 작은 정수 확인

SYNOPSIS
   char *big_int_smaller (int number, char **string)

DESCRIPTION
   string 세번째 문자열 (string[2]) 을 smaller 포인터 문자열에 대입한다.
   number 가 될떄까지 big_int_sizecompare 함수를 호출하여 string[number] 와 larger 포인터의 크기를  확인한다.
   만약 big_int_sizecompare 의 반환값이 1일 경우에 string[number] 와 smaller 를 바꾼다.
   number 가 끝나지 않았으면 계속 진행한다.

RETURN VALUE
   big_int_smaller () 함수는 smaller 포인터를 반환한다.
*/
char
*big_int_smaller (int argc, char **argv)
{
  char *smaller;
  int i;
  int sizecompare_smaller;

  smaller = argv[2];

  for (i = 3; i < argc; i++)
    {
      sizecompare_smaller = big_int_sizecompare (smaller, argv[i]);

      if (sizecompare_smaller == 1)
        smaller = argv[i];
    }

  return smaller;
}


/*
NAME
   big_int_sort_ascend - 문자열의 정수를 오름차순으로 정렬한다.

SYNOPSIS
   big_int_sort_ascend (int number, char **string)

DESCRIPTION
   string 첫 번째 문자열과 두 번째 문자열을 big_int_sizecompare 함수를 호출하여 확인한다.
   두 번째 문자열이 "NULL" 값이 나올때까지 증가시키며 두 개의 문자열씩 확인한다.
   big_int_sizecompare 의 반환값이 2 일 경우에 문자열의 위치를 변경하고 첫번째 문자열부터 다시 확인한다.

   정렬이 종료되면 i = 0 이 number 가 될떄까지 string[i] 문자열을 출력한다.

BUGS
   big_int_ascend () 함수는 정수에 관한 정렬이기 때문에 정수외의 문자가 들어올 경우 예상하지 못한 결과값이 나올 수 있다.
*/
void
big_int_sort_ascend (int argc, char **argv)
{
  int i;
  int sizecompare_sort;
  char *temp;

  i = 3;

  while (1)
    {
      if (argv[i + 1] == NULL)
        break;

      sizecompare_sort = big_int_sizecompare (argv[i], argv[i + 1]); 

      if (sizecompare_sort == 1)
        {
          temp = argv[i];
          argv[i] = argv[i + 1];
          argv[i + 1] = temp;
          i = 3;
          continue;
        }

      i++;
    }

  for (i = 3; i < argc; i++)
    printf("%s\n", argv[i]);
}


/*
NAME
   big_int_sort_descend - 문자열의 정수를 내림차순으로 정렬한다.

SYNOPSIS
   big_int_sort_descend (int number, char **string)

DESCRIPTION
   string 첫 번째 문자열과 두 번째 문자열을 big_int_sizecompare 함수를 호출하여 확인한다.
   두 번째 문자열이 "NULL" 값이 나올때까지 증가시키며 두 개의 문자열씩 확인한다.
   big_int_sizecompare 의 반환값이 1 일 경우에 문자열의 위치를 변경하고 첫번째 문자열부터 다시 확인한다.

   정렬이 종료되면 i = 0 이 number 가 될떄까지 string[i] 문자열을 출력한다.

BUGS
   big_int_sort_descend () 함수는 정수에 관한 정렬이기 때문에 정수외의 문자가 들어올 경우 예상하지 못한 결과값이 나올 수 있다.
*/
void
big_int_sort_descend (int argc, char **argv)
{
  int i;
  int sizecompare_sort;
  char *temp;

  i = 3;

  while (1)
    {
      if (argv[i + 1] == NULL)
        break;

      sizecompare_sort = big_int_sizecompare (argv[i], argv[i + 1]); 

      if (sizecompare_sort == 2)
        {
          temp = argv[i];
          argv[i] = argv[i + 1];
          argv[i + 1] = temp;
          i = 3;
          continue;
        }

      i++;
    }

  for (i = 3; i < argc; i++)
    printf("%s\n", argv[i]);
}

//프로그램의 시작
int
main (int    argc,
      char **argv)
{
  int option;
  int minusfind;
  int sizecompare;
  char *plusminusdelete_firsttemp;
  char *plusminusdelete_secondtemp;
  char *plusminusdelete_first;
  char *plusminusdelete_second;
  char *plus;
  char *minus;
  char *larger;
  char *smaller;

  option = big_int_option (argc, argv);

  big_int_checkstring(argc, argv);

  switch (option)
    {
    case 1 : plusminusdelete_firsttemp = strdup (argv[2]);
             plusminusdelete_secondtemp = strdup (argv[3]);

             plusminusdelete_first = big_int_plusminusdelete (plusminusdelete_firsttemp);
             plusminusdelete_second = big_int_plusminusdelete (plusminusdelete_secondtemp);

             minusfind = big_int_minusfind (argv[2], argv[3]); 
             switch (minusfind)
               {
               case 1 : plus = big_int_plus (plusminusdelete_first, plusminusdelete_second);
                        big_int_print (plus);
                        break;
               case 2 : plus = big_int_plus (plusminusdelete_first, plusminusdelete_second);
                        printf ("-");
                        big_int_print (plus);
                        break;
               case 3 : 
                        sizecompare = big_int_sizecompare (plusminusdelete_first, plusminusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   break;
                          case 1 : minus = big_int_minus (plusminusdelete_first, plusminusdelete_second);
                                   printf ("-");
                                   big_int_print (minus);
                                   break;
                          case 2 : minus = big_int_minus (plusminusdelete_second, plusminusdelete_first);
                                   big_int_print (minus);
                                   break;
                          }
                        break;
               case 4 : 
                        sizecompare = big_int_sizecompare (plusminusdelete_first, plusminusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   break;
                          case 1: minus = big_int_minus (plusminusdelete_first, plusminusdelete_second);
                                  big_int_print (minus);
                                  break;
                          case 2: minus = big_int_minus (plusminusdelete_second, plusminusdelete_first);
                                  printf ("-");
                                  big_int_print (minus);
                                  break;
                          }
                        break;
               }
             break;
    case 2 : plusminusdelete_firsttemp = strdup (argv[2]);
             plusminusdelete_secondtemp = strdup (argv[3]);

             plusminusdelete_first = big_int_plusminusdelete (plusminusdelete_firsttemp);
             plusminusdelete_second = big_int_plusminusdelete (plusminusdelete_secondtemp);

             minusfind = big_int_minusfind (argv[2], argv[3]); 
             switch (minusfind)
               {
               case 1 : sizecompare = big_int_sizecompare (plusminusdelete_first, plusminusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   break;
                          case 1 : minus = big_int_minus (plusminusdelete_first, plusminusdelete_second);
                                   big_int_print (minus);
                                   break;
                          case 2 : minus = big_int_minus (plusminusdelete_second, plusminusdelete_first);
                                   big_int_print (minus);
                                   break;
                          }
                        break;
               case 2 : sizecompare = big_int_sizecompare (plusminusdelete_first, plusminusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   break;
                          case 1 : minus = big_int_minus (plusminusdelete_first, plusminusdelete_second);
                                   printf ("-");
                                   big_int_print (minus);
                                   break;
                          case 2 : minus = big_int_minus (plusminusdelete_second, plusminusdelete_first);
                                   big_int_print (minus);
                                   break;
                          }
                        break;
               case 3 : plus = big_int_plus (plusminusdelete_first, plusminusdelete_second);
                        printf ("-");
                        big_int_print (plus);
                        break;
               case 4: plus = big_int_plus (plusminusdelete_first, plusminusdelete_second);
                       big_int_print (plus);
                       break;
               }
             break;
    case 3 : larger = big_int_larger (argc, argv);
             printf ("%s\n", larger);
             break;
    case 4 : smaller = big_int_smaller (argc, argv);
             printf ("%s\n", smaller);
             break;
    case 5 : big_int_sort_ascend (argc, argv);
             break;
    case 6 : big_int_sort_descend (argc, argv);
             break;
    case 7 : sizecompare = big_int_sizecompare (argv[2], argv[3]);
             if (sizecompare == 0)
               printf ("TRUE\n");
             else
               printf ("FALSE\n");
             break;
    }

  return 0;
}

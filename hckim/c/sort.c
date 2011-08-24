#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void
big_int_waringstring()
{
    printf ("Usuage:\n");
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
    printf ("\tsort desscend <num1> [ <num2>, ... ]\n");
    printf ("\t\t입력한 숫자를 내림차순으로 정렬합니다.\n");
    printf ("\n");
    printf ("\tequal <num1> <num2>\n");
    printf ("\t\t입력한 숫자가 같은지 다른지 여부를 TRUE/FALSE 형태로 출력합니다.\n");
    printf ("\n");
}


int
big_int_option(int    argc,
               char **argv)
{
  int option;

  if (argc == 1 || strcmp (argv[1], "help") == 0)
    {
      big_int_waringstring();

      exit (EXIT_FAILURE);
    }

  if ((strcmp (argv[1], "add") == 0))
    {
      if (argc != 4)
        {
          printf ("usuage : %s %s <num1> <num2>\n", argv[0], argv[1]);
          exit (EXIT_FAILURE);
        }

      option = 1;
    }
  else if ((strcmp (argv[1], "subtract") == 0))
    {
      if (argc != 4)
        {
          printf ("usuage : %s %s <num1> <num2>\n", argv[0], argv[1]);
          exit (EXIT_FAILURE);
        }

      option = 2;
    }
  else if ((strcmp (argv[1], "larger") == 0))
    {
      if (argc <= 2)
        {
          printf ("usuage : %s %s <num1> [<num2>, ...]\n", argv[0], argv[1]);

          exit (EXIT_FAILURE);
        }

      option = 3;
    }
  else if ((strcmp (argv[1], "smaller") == 0))
    {
      if (argc <= 2)
        {
          printf ("usuage : %s %s <num1> [<num2>, ...]\n", argv[0], argv[1]);

          exit (EXIT_FAILURE);
        }

      option = 4;
    }
  else if ((strcmp (argv[1], "sort") == 0))
    {
      if (argc <= 2)
        {
          printf ("usuage : %s %s <num1> [<num2>, ...]\n", argv[0], argv[1]);

          exit (EXIT_FAILURE);
        }

      if ((strcmp (argv[2], "ascend") == 0))
        {
          if (argc <= 3)
            {
              printf ("usuage : %s %s %s <num1> [<num2>, ...]\n", argv[0], argv[1], argv[2]);

              exit (EXIT_FAILURE);
            }

          option = 5;
        }
      else if ((strcmp (argv[2], "desscend") == 0))
        {
          if (argc <= 3)
            {
              printf ("usuage : %s %s %s <num1> [<num2>, ...]\n", argv[0], argv[1], argv[2]);

              exit (EXIT_FAILURE);
            }

          option = 6;
        }
    }
  else if ((strcmp (argv[1], "equal") == 0))
    {
      if (argc != 4)
        {
          printf ("usuage : %s %s <num1> <num2>\n", argv[0], argv[1]);

          exit (EXIT_FAILURE);
        }

      option = 7;
    }
  else
    {
      printf ("unknown command : %s\n", argv[1]);
      big_int_waringstring();
      exit (EXIT_FAILURE);
    }

  /*
     if ((strcmp (argv[1], "sort") == 0))
     {
     if (strcmp (argv[2], "ascend") == 0)
        {
          if (argc <= 3)
          printf ("usuage : %s %s %s <num1> [<num2>, ...]\n", argv[0], argv[1], argv[2]);
        }

      if (argc <= 2)
        {

          exit (EXIT_FAILURE);
        }

      option = 4;
    }
    */

  return option;

  /*
  //크기가 큰 숫자의 자릿수의 자릿수만큼 sum 포인터와 minus 포인터 에 크기를 지정하고 초기화한다. 
  if (strlen (argv[1]) > strlen (argv[2]))
    {
      sum = (char *) calloc (strlen (argv[1]), sizeof (char));
      minus = (char *) calloc (strlen (argv[1]), sizeof (char));
    }
  else
    {
      sum = (char *) calloc (strlen (argv[2]), sizeof (char));
      minus = (char *) calloc (strlen (argv[2]), sizeof (char));
    }
*/
}


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
    {
      plus = (char *) calloc (strlen (plus_first), sizeof (char));
    }
  else
    {
      plus = (char *) calloc (strlen (plus_second), sizeof (char));
    }

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

  /*
  if (compare_result_minus == 1)
    {
      upnumber = strdup (first);
      downnumber = strdup (second);
    }
  else if (compare_result_minus == 2)
    {
      upnumber = strdup (second);
      downnumber = strdup (first);
    }
  else if (compare_result_minus == 0)
    return;

  upstrlen = strlen (upnumber);
  downstrlen = strlen (downnumber);
  */

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

void
big_int_print (char *plusprint)
{
  int i;

  i = strlen (plusprint);

  while (1)
    {
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
static void
sort_print (int minusi, int compare_result_print)
{

  printf ("first Numbers : %s\nSecond Numbers : %s \n\n", first, second);

  printf ("sum : ");

  //출력시에 앞에 아스키 코드 0 보다 작은 인수가 있으면 삭제한다. i 를 -- 시켜 해당부분은 출력하지 않는다.
  //덧셈 출력 부분
  while (1)
    {
      if (sum[i] <= 48 || 58 <= sum[i])
        i--;

      else
        break;
    }

  while (i != -1)
    {
      printf ("%c", sum[i]);

      i--;
    }

  //뺄셈 출력 부분
  if (compare_result_print != 0)
    {
      while (1)
        {
          if (minus[minusi] <= 48 || 58 <= minus[minusi])
            minusi--;

          else
            break;
        }

      printf ("\nminus : ");
      if (compare_result_print == 2)
        printf ("-");
      while (minusi != -1)
        {
          printf ("%c", minus[minusi]);

          minusi--;
        }
    }

  switch (compare_result_print)
    {
    case 0 : printf ("\nminus : 0 \nNumber same\n"); 
             break;
    case 1 : printf ("\nFirst Number large \n");
             break;
    case 2 : printf ("\nSecond Number large.\n");
             break;
    }
}


*/
char
*big_int_minusdelete (char *minusdelete_temp)
{
  int i;
  char *minusdelete;

  minusdelete = (char *) calloc (strlen (minusdelete_temp) - 1, sizeof (char));

  for (i = 0; i <= strlen (minusdelete_temp); i++)
    minusdelete[i] = minusdelete_temp[i + 1];

  return minusdelete;
}

   
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
static void
big_int_free (void)
{
  free (plus);
  free (minus);
  free (minusdelete_first);
  free (minusdelete_second);
}
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


int
main (int    argc,
      char **argv)
{
  int option;
  int minusfind;
  int sizecompare;
  char *minusdelete_first;
  char *minusdelete_second;
  char *plus;
  char *minus;

  option = big_int_option (argc, argv);

  switch (option)
    {
    case 1 : minusfind = big_int_minusfind (argv[2], argv[3]); 
             switch (minusfind)
               {
               case 1 : plus = big_int_plus (argv[2], argv[3]);
                        big_int_print (plus);
                        return 0;
               case 2 : minusdelete_first = big_int_minusdelete (argv[2]);
                        minusdelete_second = big_int_minusdelete (argv[3]);
                        plus = big_int_plus (minusdelete_first, minusdelete_second);
                        printf ("-");
                        big_int_print (plus);
                        return 0;
               case 3 : minusdelete_first = big_int_minusdelete (argv[2]);
                        sizecompare = big_int_sizecompare (minusdelete_first, argv[3]);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   return 0;
                          case 1 : minus = big_int_minus (minusdelete_first, argv[3]);
                                   printf ("-");
                                   big_int_print (minus);
                                   return 0;
                          case 2 : minus = big_int_minus (argv[3], minusdelete_first);
                                   big_int_print (minus);
                                   return 0;
                          }
               case 4 : minusdelete_second = big_int_minusdelete (argv[3]);
                        sizecompare = big_int_sizecompare (argv[2], minusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   return 0;
                          case 1: minus = big_int_minus (argv[2], minusdelete_second);
                                  big_int_print (minus);
                                  return 0;
                          case 2: minus = big_int_minus (minusdelete_second, argv[2]);
                                  printf ("-");
                                  big_int_print (minus);
                                  return 0;
                          }
               }
             break;
    case 2 : minusfind = big_int_minusfind (argv[2], argv[3]); 
             switch (minusfind)
               {
               case 1 : sizecompare = big_int_sizecompare (argv[2], argv[3]);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   return 0;
                          case 1 : minus = big_int_minus (argv[2], argv[3]);
                                   big_int_print (minus);
                                   return 0;
                          case 2 : minus = big_int_minus (argv[3], argv[2]);
                                   big_int_print (minus);
                                   return 0;
                          }
               case 2 : minusdelete_first = big_int_minusdelete (argv[2]);
                        minusdelete_second = big_int_minusdelete (argv[3]);
                        sizecompare = big_int_sizecompare (minusdelete_first, minusdelete_second);
                        switch (sizecompare)
                          {
                          case 0 : printf ("0\n");
                                   return 0;
                          case 1 : minus = big_int_minus (minusdelete_first, minusdelete_second);
                                   printf ("-");
                                   big_int_print (minus);
                                   return 0;
                          case 2 : minus = big_int_minus (minusdelete_second, minusdelete_first);
                                   big_int_print (minus);
                                   return 0;
                          }
               }
    case 3 : 
             break;
    }

 
/*
  int firststrlen_temp;
  int secondstrlen_temp;
  int compare_result;
  int sort_minuscompare;
  int minusi_temp;
  firststrlen_temp = strlen (argv[1]);
  secondstrlen_temp = strlen (argv[2]);
  sort_minuscompare = sort_minuscompare_temp(argv[1], argv[2]);

  compare_result = sort_compare (firststrlen_temp, secondstrlen_temp); //크기 비교. 크기가 같으면 0 argv[1] 이 크면 1 argv[2] 가 크면 2가 반환된다.
  sort_plus (firststrlen_temp, secondstrlen_temp); //덧셈하는 함수.
  minusi_temp = sort_minus (compare_result); //뺄셈하는 함수
  sort_print (minsi_temp, compare_result); //출력하는 함수.

  sort_free ();
 */

  return 0;
}

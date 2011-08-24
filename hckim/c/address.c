#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define ADDRESS_FILENAME          "address.dat"
#define ADDRESS_FILENAME_TMP      "address.tmp"

int
Address_List ()
{
  FILE *fp_Address_List;
  char Tmp_List;

  fp_Address_List = fopen ("./"ADDRESS_FILENAME, "a+");

  printf ("-Name List-\n");

  while (EOF != (Tmp_List = fgetc (fp_Address_List)))
    {
      if (Tmp_List != '|')
        putchar (Tmp_List);
      else
        {
          printf ("\n");
          while ('\n' != (Tmp_List = fgetc (fp_Address_List)))
            {
            }
        }
    }

  return 0;
}

int
Address_Find (char *Address_Name)
{
  FILE *fp_Address_Find;
  char *Tmp_Find;
  char Tmp_Name;
  int Name_Number;

  Name_Number = 0;

  Tmp_Find = (char *) malloc (1024 * sizeof (char));

  fp_Address_Find = fopen ("./"ADDRESS_FILENAME, "a+");

  while (EOF != (Tmp_Name = fgetc (fp_Address_Find)))
    {
      if (Tmp_Name != '|')
        Tmp_Find[Name_Number] = Tmp_Name;
      else if (Tmp_Name == '|')
        {
          if (strcmp (Tmp_Find, Address_Name) == 0)
            {
              printf ("Name : %s\n", Tmp_Find);

              fseek (fp_Address_Find, 2, SEEK_CUR);

              printf ("Address : ");
              while ('|' != (Tmp_Name = fgetc (fp_Address_Find)))
                  putchar (Tmp_Name);
              printf ("\n");

              fseek (fp_Address_Find, 2, SEEK_CUR);

              printf ("Phone : ");
              while ('|' != (Tmp_Name = fgetc (fp_Address_Find)))
                  putchar (Tmp_Name);
              printf ("\n");

              free (Tmp_Find);
              return 0;
            }

          Tmp_Find = (char *) malloc (1024 * sizeof (char));

          while ('\n' != (Tmp_Name = fgetc (fp_Address_Find)))
            {}
          Name_Number = -1;
        }

     ++Name_Number;
    }

  free (Tmp_Find);
  return 1;
}

int
Address_Delete (char *Address_Name)
{
  FILE *fp_Address_Delete;
  FILE *fp_Address_Delete_Tmp;
  char *Tmp_Delete;
  char Tmp_Name;
  int Name_Number;

  Name_Number = 0;

  Tmp_Delete = (char *) malloc (1024 * sizeof (char));

  fp_Address_Delete = fopen ("./"ADDRESS_FILENAME, "a+");
  fp_Address_Delete_Tmp = fopen ("./"ADDRESS_FILENAME_TMP, "a+");

  while (EOF != (Tmp_Name = fgetc (fp_Address_Delete)))
    {
      if (Tmp_Name != '|')
        Tmp_Delete[Name_Number] = Tmp_Name;
      else
        {
          while ('\n' != (Tmp_Name = fgetc (fp_Address_Delete)))
            {
            }

          if (strcmp (Tmp_Delete, Address_Name) == 0)
            return 1;

          Name_Number = -1;
        }

      ++Name_Number;
    }

  return 0;
}


/*
int
Address_Name_Duplicate_Check (char *Address_Name)
{
  FILE *fp_Duplicate_Check;
  char TmpName[1024];

  fp_Duplicate_Check = fopen ("./"ADDRESS_FILENAME, "a+");

 while (1)
   {
     fgets (TmpName, strlen (Address_Name), fp_Duplicate_Check);
     if (strcmp (TmpName, Address_Name) == 1)
       return 1;

     while (fgetc (fp_Duplicate_Check) != "\n")
       {}

     if (feof (fp_Duplicate_Check) == 0)
       return 0;

   }
}
*/

int 
Address_Add ()
{
  char Address_Add_Name[1024];
  char Address_Add_Address[1024];
  char Address_Add_Phone[20];
  FILE *fp_Address_Add;

  fp_Address_Add = fopen ("./"ADDRESS_FILENAME, "a+");

  printf ("Name : ");
  scanf ("%s", Address_Add_Name);
  //Address_Name_Duplicat_Check (Address_Add_Name);

  fprintf (fp_Address_Add, "%s|n|", Address_Add_Name);

  printf ("Address : ");
  scanf ("%s", Address_Add_Address);
  fprintf (fp_Address_Add, "%s|a|", Address_Add_Address);

  printf ("Phone : ");

  scanf ("%s", Address_Add_Phone);

// Waring - Address_Add_Phone 에 들어간 쓰레기값으로 인하여 버그발생
  while (strlen (Address_Add_Phone) > 20)
    {
      printf ("Length of 5 characters less phone number\nPhone : ");
      scanf ("%s", Address_Add_Phone);
    }
  fprintf (fp_Address_Add, "%s|p|", Address_Add_Phone);

  fprintf (fp_Address_Add, "\n");
  fclose (fp_Address_Add);

  return 0;
}


char
*Address_MenuSelect () 
{
  char *Number;
  Number = (char *) malloc (1024 * sizeof (char));

  printf ("Select Menu (list = 1, add = 2, delete = 3, find = 4, quit = 5) : ");

  scanf ("%s", Number); 

  return Number;
}

char
*Address_Inputname ()
{
  char *Name;

  Name = (char *) malloc (1024 * sizeof (char));

  printf ("Input Name : ");

  scanf ("%s", Name);

  return Name;
}



int
Address_Start ()
{
  char *Menu_Number;

  Menu_Number = Address_MenuSelect ();

  //메뉴 입력값이 한자리가 아니거나 아스키코드값48 (0) 이하 아스키코드값54 (6) 이상 일때 반복
  while (strlen (Menu_Number) != 1 || (Menu_Number[0] < 49 || Menu_Number[0] > 53))
    {
      printf ("Please Select 1 ~ 5 Number\n");
      Menu_Number = Address_MenuSelect ();
    }

  if (Menu_Number[0] == 49)
    Address_List ();

  else if (Menu_Number[0] == 50)
    Address_Add ();

  else if (Menu_Number[0] == 51)
    Address_Delete (Address_Inputname ());

  else if (Menu_Number[0] == 52)
    {
      if (Address_Find (Address_Inputname ()) == 1)
        printf ("Nothing Name\n");
    }

  else if (Menu_Number[0] == 53)
    {
      printf ("Bye!\n");

      return 1;
    }

  return 0;
}


int 
main (int    argc,
      char **argv)
{
  int StartEnd;

  while (1)
    {
      StartEnd = Address_Start ();

      if (StartEnd == 1)
        break;
    }

  return 0;
}

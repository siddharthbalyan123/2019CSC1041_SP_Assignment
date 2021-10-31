%{
//author: Siddharth Balyan										
//roll number : 2019CSC1041
#include <iostream>     //including required libraries and dependencies
#include <string.h>
#include <string>
#include "eg.tab.h" // output of bison on example1 .y
#include "sqlite3.h"
void yyerror(std::string);
int yyparse(void);
void placeholder(char*);
%}
%%
[\t\n]+ ; // do nothing on whitespace
"print" return PRINT ;
[a-zA-Z][a-zA-Z0-9]* {yylval.str_val = new std::string(yytext); return VARIABLE;}
[0-9][0-9]*(.[0-9]+)? {yylval.double_val = atof(yytext); return NUMBER;}
"=" return EQUALS;
"+" return PLUS;
"-" return MINUS;
"*" return ASTERISK;
"/" return FSLASH;
"(" return LPAREN;
")" return RPAREN;
";" return SEMICOLON;
%%
void yyerror(std::string str){ printf("Parse Error : \n%s\n",str.c_str());}
int yywrap(){return 0;}

std::string final_query;      //to store final sql query

std::string final(char *str)     //function to create final sql query 
{
   std::string final_s="SELECT ";
   int i=0;
   while(str[i]!='\0')
   {
      if(str[i]=='<')      //whenever "<" is encountered look for variable names
      {
         i++;
         i++;
         if(str[i]=='1')
         {
            final_s.append("basic");
         }
         else if(str[i]=='2')
         {
            final_s.append("ta");
         }
         else if(str[i]=='3')
         {
            final_s.append("pf");
         }
         i++;
         i++;
      }
      else
      {
         final_s.push_back(str[i]);    //otherwise enter value of operands
         i++;
      }
   } 
   final_query.append(final_s);
   final_query.append(" FROM salary");
   return final_s;
}

char *store = new char[100];     //callback to print formula by id
static int callback1(void *data, int argc, char **argv, char **azColName){
   store = argv[1];
   final(argv[1]);
   YY_BUFFER_STATE buffer = yy_scan_string(store);
   std::cout<<store<<"\n";
   yy_delete_buffer(buffer);
   return 0;
}

char *store2 = new char[100]; //callback to print enitre salary data
static int callback2(void *data, int argc, char **argv, char **azColName){
  for(int i=1;i<=3;i++)
   {
      store2= argv[i];
      std::cout<<store2<<" ";
   }
   YY_BUFFER_STATE buffer = yy_scan_string(store2);
   std::cout<<"\n";
   yy_delete_buffer(buffer);
   return 0;
}

static int callback3(void *data, int argc, char **argv, char **azColName)  //callback to perform the final query
{
    std::cout<<argv[0]<<"\n";
    return 0;
}
int main(int argc, char ** argv){
sqlite3 *db;
   char *zErrMsg = 0;
   int rc;     //trigger variable to run sql query
   int rc2;
   int rc3;
   std::string sql;
   std::string sql2;
   const char* data = "Callback function called";

   /* Open database */
   rc = sqlite3_open("tables.db", &db);   //connecting db
    
   std::cout<<"\n";     //error handling
   if( rc ) {
      fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
      return(0);
   } else {
      fprintf(stderr, "Opened database successfully\n");
   }
   std::cout<<"\n";
   std::cout<<"Enter formula ID :";    //asking user for formula id
   char x;
   std::cin>>x;

   /* Create SQL statement */
   sql = "SELECT * FROM formulae WHERE id =";
   sql2= "SELECT * FROM salary";
   sql.push_back(x);
   sql.push_back(';');  //pushing required id

   /* Execute SQL statement */
   std::cout<<"Required Formula : ";
   rc = sqlite3_exec(db, sql.c_str(), callback1, (void*)data, &zErrMsg); //formula sql
   std::cout<<"\n";
   std::cout<<"Required Salary Values : \n";
   rc2 = sqlite3_exec(db, sql2.c_str(), callback2, (void*)data, &zErrMsg); //salary sql
   std::cout<<"\n";
   std::cout<<"Required Result : \n";
   rc3 = sqlite3_exec(db, final_query.c_str(), callback3, (void*)data, &zErrMsg); //result sql
   std::cout<<"\n";

   if( rc3 != SQLITE_OK ) {
      fprintf(stderr, "SQL error: %s\n", zErrMsg);
      sqlite3_free(zErrMsg);
   } else {
      fprintf(stdout, "Operation done successfully\n");
   }
   sqlite3_close(db);   //closing db
   std::cout<<"\n";
   return 0;

}
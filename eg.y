%{
//author: Siddharth Balyan										
//roll number : 2019CSC1041
#include <cstdio>   //including required libraries and dependencies
#include <cstdlib>
#include <string>
#include <map>
#include "sqlite3.h"
using namespace std;
std::map < std::string , double > vars ; // map from variable name to value
extern int yylex ();
extern void yyerror (std::string str);
void Div0Error ( void );
void UnknownVarError (std::string s);
%}
%union{
int int_val;
double double_val;
std::string * str_val;
}
%token <int_val> PLUS MINUS ASTERISK FSLASH EQUALS PRINT LPAREN RPAREN SEMICOLON
%token <str_val> VARIABLE
%token <double_val> NUMBER
%type <double_val> expression;
%type <double_val> inner1;
%type <double_val> inner2;
%start parsetree
%%
parsetree: lines;
lines: lines line | line;
line: PRINT expression SEMICOLON{ printf("%lf\n",$2);} | VARIABLE EQUALS expression SEMICOLON{vars[*$1] = $3; delete $1;};
expression: expression PLUS inner1 {$$ = $1 + $3;} | expression MINUS inner1{$$ = $1 - $3 ;} | inner1{$$ = $1;};
inner1: inner1 ASTERISK inner2 {$$ = $1 * $3;} | inner1 FSLASH inner2
{if($3 == 0) Div0Error(); else $$ = $1 / $3;} | inner2 {$$ = $1;};
inner2: VARIABLE
{if (!vars.count(* $1)) UnknownVarError(* $1); else $$ = vars[* $1]; delete $1;} | NUMBER{$$ = $1;} | LPAREN expression RPAREN{$$ = $2;};
%%
void Div0Error(void){ printf("Error : division by zero \n"); exit(0);}
void UnknownVarError(std::string s){ printf(" Error : %s does not exist !\n", s.c_str()); exit(0);}
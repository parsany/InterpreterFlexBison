%{
#include "lang.tab.h" 
#include <string.h>
#include <stdlib.h> 

%}

%option noyywrap  
%option yylineno 

DIGIT    [0-9]
LETTER   [a-zA-Z_]
ID       {LETTER}({LETTER}|{DIGIT})*

%%

"int"        { return INT_KEYWORD; }
"main"       { return MAIN_KEYWORD; }
"let"        { return LET_KEYWORD; }
"show"       { return SHOW_KEYWORD; }
"vorood"     { return INPUT_KEYWORD; } 

{DIGIT}+     { yylval.ival = atoi(yytext); return INTEGER; } 
{ID}         { yylval.sval = strdup(yytext); return IDENTIFIER; }


"+"          { return ADD_OP; }
"-"          { return SUB_OP; }
"*"          { return MUL_OP; }
"/"          { return DIV_OP; }
"="          { return ASSIGN_OP; }

"("          { return LPAREN; }
")"          { return RPAREN; }
"{"          { return LBRACE; }
"}"          { return RBRACE; }
";"          { return SEMICOLON; }

[ \t\n]+     { } 
"//".* {} 
.            { fprintf(stderr, "Line %d: Unexpected character: %s\n", yylineno, yytext); }

%%
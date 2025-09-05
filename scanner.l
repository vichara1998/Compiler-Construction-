%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define strdup _strdup  

int current_line = 1;
void increment_line() { current_line++; }
%}

%%

"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }
";"                 { return SEMI; }
","                 { return COMMA; } 
":"                 { return COLON; }
"=>"                { return ARROW; }
"+"                 { return ADD; }
"-"                 { return SUB; }
"*"                 { return MULTI; }
"/"                 { return DIVIDE; }
":="                { return ASSIGN; }
"=="                { return EQ; }
"<>"                { return NEQ; }
"<"                 { return LT; }
">"                 { return GT; }
"<="                { return LEQ; }
">="                { return GEQ; }
"or"                { return OR; }
"and"               { return AND; }
"not"               { return NOT; }
"else"              { return ELSE; }
"float"             { return FLOAT; }
"func"              { return FUNC; }
"if"                { return IF; }
"implement"         { return IMPLEMENT; }
"class"             { return CLASS; }
"attribute"         { return ATTRIBUTE; }
"integer"           { return INTEGER; }
"isa"               { return ISA; }
"private"           { return PRIVATE; }
"public"            { return PUBLIC; }
"read"              { return READ; }
"return"            { return RETURN; }
"self"              { return SELF; }
"construct"         { return CONSTRUCT; }
"then"              { return THEN; }
"local"             { return LOCAL; }
"void"              { return VOID; }
"while"             { return WHILE; }
"write"             { return WRITE; } 

[ \t]+              ;
\n                  { increment_line(); }

"//"[^\n]*          ;
"/*"([^*]|\*+[^*/])*\*+\/   ;

([1-9][0-9]*|0)(\.[0-9]*[1-9]|\.0)?(e[+-]?[0-9]+)? { 
                        yylval.floatValue = strtod(yytext,NULL); return FLOATLIT; }

[1-9][0-9]*|0       { yylval.integerValue = atoi(yytext); return INTLIT; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.stringValue = strdup(yytext); return ID; }

.                   { yylval.stringValue = strdup(yytext); return UNKNOWN; }

%%

int yywrap(){ return 1; }

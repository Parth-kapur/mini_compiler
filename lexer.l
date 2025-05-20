%{
#include "parser.tab.h" 
#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}
%%
"if"      { return IF; }
"else"    { return ELSE; }
"while"   { return WHILE; }
"for"     { return FOR; }
"switch"  { return SWITCH; }
"case"    { return CASE; }
"default" { return DEFAULT; }
"break"   { return BREAK; }
"=="      { return EQ; }
"!="      { return NE; }
"<="      { return LE; }
">="      { return GE; }
"<"       { return LT; }
">"       { return GT; }
"="       { return ASSIGN; }
";"       { return SEMICOLON; }
","       { return COMMA; }
"{"       { return LBRACE; }
"}"       { return RBRACE; }
"("       { return LPAREN; }
")"       { return RPAREN; }
":"       { return COLON; }
"+"       { return PLUS; }
"-"       { return MINUS; }
"*"       { return MUL; }
"/"       { return DIV; }
[0-9]+                 { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.sval = strdup(yytext); return IDENT; }
[ \t\n]+               { /* skip whitespace */ }
.                      { printf("Unknown char: %s\n", yytext); }
%%
int yywrap() {
    return 1;
}


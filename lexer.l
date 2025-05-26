%{
#include "ast.h"
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option yylineno
%option noyywrap

%%

"if"           { printf("LEX: IF\n"); return IF; }
"else"         { printf("LEX: ELSE\n"); return ELSE; }
"while"        { printf("LEX: WHILE\n"); return WHILE; }
"for"          { printf("LEX: FOR\n"); return FOR; }
"switch"       { printf("LEX: SWITCH\n"); return SWITCH; }
"case"         { printf("LEX: CASE\n"); return CASE; }
"default"      { printf("LEX: DEFAULT\n"); return DEFAULT; }
"break"        { printf("LEX: BREAK\n"); return BREAK; }

"++"           { printf("LEX: INCR ('%s')\n", yytext); return INCR; }
"--"           { printf("LEX: DECR ('%s')\n", yytext); return DECR; }

"=="           { printf("LEX: EQ\n"); return EQ; }
"!="           { printf("LEX: NE\n"); return NE; }
"<="           { printf("LEX: LE\n"); return LE; }
">="           { printf("LEX: GE\n"); return GE; }
"<"            { printf("LEX: LT\n"); return LT; }
">"            { printf("LEX: GT\n"); return GT; }
"="            { printf("LEX: ASSIGN\n"); return ASSIGN; }

"+"            { printf("LEX: PLUS ('%s')\n", yytext); return PLUS; }
"-"            { printf("LEX: MINUS ('%s')\n", yytext); return MINUS; }
"*"            { printf("LEX: MUL\n"); return MUL; }
"/"            { printf("LEX: DIV\n"); return DIV; }
"%"            { printf("LEX: MOD\n"); return MOD; }

";"            { printf("LEX: SEMICOLON\n"); return SEMICOLON; }
","            { printf("LEX: COMMA\n"); return COMMA; }
"{"            { printf("LEX: LBRACE\n"); return LBRACE; }
"}"            { printf("LEX: RBRACE\n"); return RBRACE; }
"("            { printf("LEX: LPAREN\n"); return LPAREN; }
")"            { printf("LEX: RPAREN\n"); return RPAREN; }
":"            { printf("LEX: COLON\n"); return COLON; }

[0-9]+                 {
                           yylval.ival = atoi(yytext);
                           printf("LEX: NUMBER ('%s')\n", yytext);
                           return NUMBER;
                       }

[a-zA-Z_][a-zA-Z0-9_]*   {
                           yylval.sval = strdup(yytext);
                           if (!yylval.sval) {
                               fprintf(stderr, "CRITICAL ERROR: strdup failed for identifier '%s' in lexer. Exiting.\n", yytext);
                               exit(1);
                           }
                           printf("LEX: IDENT ('%s')\n", yytext);
                           return IDENT;
                       }

[ \t\n]+                { /* Ignore whitespace */ }

.                       {
                           printf("Lexical Error: Unknown character '%s' on line %d\n", yytext, yylineno);
                       }

%%


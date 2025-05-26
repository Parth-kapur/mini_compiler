%{
#include "parser.tab.h" 
#include "ast.h"      
#include <stdio.h>    
#include <stdlib.h>   
#include <string.h>   
%}

%option yylineno

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

[0-9]+                      { 
                                yylval.ival = atoi(yytext); 
                                return NUMBER; 
                            }
[a-zA-Z_][a-zA-Z0-9_]* { 
                                yylval.sval = strdup(yytext); 
                                if (yylval.sval == NULL) {
                                    fprintf(stderr, "DEBUG CRITICAL ERROR: strdup failed for identifier '%s' in lexer (out of memory?). Exiting.\n", yytext);
                                    fflush(stderr);
                                    exit(1); 
                                }
                                return IDENT; 
                            }
[ \t\n]+                    { /* Do nothing, just skip. */ }
.                           { 
                                printf("Lexical Error: Unknown character '%s' on line %d\n", yytext, yylineno); 
                            }
%%
int yywrap() {
    return 1;
}

const char* tokenToString(int token) {
    switch (token) {
        case IF: return "IF"; case ELSE: return "ELSE"; case WHILE: return "WHILE";
        case FOR: return "FOR"; case SWITCH: return "SWITCH"; case CASE: return "CASE";
        case DEFAULT: return "DEFAULT"; case BREAK: return "BREAK"; case EQ: return "EQ";
        case NE: return "NE"; case LE: return "LE"; case GE: return "GE"; case LT: return "LT";
        case GT: return "GT"; case ASSIGN: return "ASSIGN"; case SEMICOLON: return "SEMICOLON";
        case COMMA: return "COMMA"; case LBRACE: return "LBRACE"; case RBRACE: return "RBRACE";
        case LPAREN: return "LPAREN"; case RPAREN: return "RPAREN"; case COLON: return "COLON";
        case PLUS: return "PLUS"; case MINUS: return "MINUS"; case MUL: return "MUL";
        case DIV: return "DIV"; case NUMBER: return "NUMBER"; case IDENT: return "IDENT";
        case 0: return "EOF"; 
        default: 
            static char unknown_token_buffer[30];
            sprintf(unknown_token_buffer, "UNKNOWN_TOKEN_CODE(%d)", token);
            return unknown_token_buffer;
    }
}


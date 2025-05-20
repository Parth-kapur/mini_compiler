%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"  
int yylex();
void yyerror(const char *s);
extern ASTNode* root;  // Add this to keep track of the AST root
%}
%union {
	int ival;
	char* sval;
	struct ASTNode* node;  // Fixed declaration: use 'struct' keyword
}
%token <ival> NUMBER
%token <sval> IDENT
%token IF ELSE WHILE FOR SWITCH CASE DEFAULT BREAK
%token EQ NE LE GE LT GT ASSIGN SEMICOLON COMMA
%token LBRACE RBRACE LPAREN RPAREN COLON
%token PLUS MINUS MUL DIV
%type <node> stmt expr stmt_list case_list
%%
program:
    stmt_list               { printAST($1); root = $1; }
;
stmt_list:
      stmt                 { $$ = $1; }
    | stmt_list stmt       { $$ = createNode("stmt_list", $1, $2); }
;
stmt:
      IDENT ASSIGN expr SEMICOLON              { $$ = createAssignNode($1, $3); }
    | IF LPAREN expr RPAREN stmt               { $$ = createIfNode($3, $5, nullptr); }
    | IF LPAREN expr RPAREN stmt ELSE stmt     { $$ = createIfNode($3, $5, $7); }
    | WHILE LPAREN expr RPAREN stmt            { $$ = createWhileNode($3, $5); }
    | FOR LPAREN stmt expr SEMICOLON expr RPAREN stmt
                                               { $$ = createForNode($3, $4, $6, $8); }
    | SWITCH LPAREN expr RPAREN LBRACE case_list RBRACE
                                               { $$ = createSwitchNode($3, $6); }
    | LBRACE stmt_list RBRACE                  { $$ = $2; }
;
case_list:
      CASE NUMBER COLON stmt_list              { $$ = createCaseNode($2, $4, nullptr); }
    | case_list CASE NUMBER COLON stmt_list    { $$ = createCaseNode($3, $5, $1); }
;
expr:
      expr PLUS expr         { $$ = createOpNode("+", $1, $3); }
    | expr MINUS expr        { $$ = createOpNode("-", $1, $3); }
    | expr MUL expr          { $$ = createOpNode("*", $1, $3); }
    | expr DIV expr          { $$ = createOpNode("/", $1, $3); }
    | LPAREN expr RPAREN     { $$ = $2; }
    | NUMBER                 { $$ = createNumNode($1); }
    | IDENT                  { $$ = createIdNode($1); }
;
%%
void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

// Define root variable to store the abstract syntax tree
ASTNode* root = nullptr;

int main() {
    yyparse();
    return 0;
}


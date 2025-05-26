%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h" // For ASTNode and printAST

// Forward declarations for functions used in this file or by the lexer
int yylex();
void yyerror(const char *s); // Defined later in this file

// External declarations for variables/functions defined elsewhere (e.g., in lexer.l or ast.h)
extern FILE* yyin;      // Flex's input stream
extern int yylineno;    // Flex's current line number
extern const char* tokenToString(int token); // Your function from lexer.l
%}

/* Bison union, tokens, and types */
%union {
    int ival;
    char* sval;
    struct ASTNode* node;
}
%token <ival> NUMBER
%token <sval> IDENT
%token IF ELSE WHILE FOR SWITCH CASE DEFAULT BREAK
%token EQ NE LE GE LT GT ASSIGN SEMICOLON COMMA
%token LBRACE RBRACE LPAREN RPAREN COLON
%token PLUS MINUS MUL DIV
%type <node> stmt expr stmt_list case_list

%%
/* --- Your Grammar Rules --- */
program:
    stmt_list                       { root = $1; /* Assign to the global root */ }
;
stmt_list:
      stmt                          { $$ = $1; }
    | stmt_list stmt                { $$ = createNode("stmt_list", $1, $2); }
;
stmt:
      IDENT ASSIGN expr SEMICOLON       { $$ = createAssignNode($1, $3); }
    | IF LPAREN expr RPAREN stmt        { $$ = createIfNode($3, $5, nullptr); }
    | IF LPAREN expr RPAREN stmt ELSE stmt { $$ = createIfNode($3, $5, $7); }
    | WHILE LPAREN expr RPAREN stmt     { $$ = createWhileNode($3, $5); }
    | FOR LPAREN stmt expr SEMICOLON expr RPAREN stmt
                                        { $$ = createForNode($3, $4, $6, $8); }
    | SWITCH LPAREN expr RPAREN LBRACE case_list RBRACE
                                        { $$ = createSwitchNode($3, $6); }
    | BREAK SEMICOLON                   { $$ = createNode("break", nullptr, nullptr); }
    | LBRACE stmt_list RBRACE           { $$ = $2; }
;
case_list:
    /* empty */                         { $$ = nullptr; }
    | case_list CASE NUMBER COLON stmt_list
                                        { $$ = createNode("case_list", $1, createCaseNode($3, $5, nullptr)); }
    | case_list DEFAULT COLON stmt_list
                                        { $$ = createNode("case_list", $1, createNode("default", $4, nullptr)); }
;
expr:
      expr PLUS expr                  { $$ = createOpNode("+", $1, $3); }
    | expr MINUS expr                 { $$ = createOpNode("-", $1, $3); }
    | expr MUL expr                   { $$ = createOpNode("*", $1, $3); }
    | expr DIV expr                   { $$ = createOpNode("/", $1, $3); }
    | expr LT expr                    { $$ = createOpNode("<", $1, $3); }
    | expr GT expr                    { $$ = createOpNode(">", $1, $3); }
    | expr LE expr                    { $$ = createOpNode("<=", $1, $3); }
    | expr GE expr                    { $$ = createOpNode(">=", $1, $3); }
    | expr EQ expr                    { $$ = createOpNode("==", $1, $3); }
    | expr NE expr                    { $$ = createOpNode("!=", $1, $3); }
    | LPAREN expr RPAREN              { $$ = $2; }
    | NUMBER                          { $$ = createNumNode($1); }
    | IDENT                           { $$ = createIdNode($1); }
;

%%
/* --- Final C/C++ Code Section --- */

#include <vector>                   // For std::vector
#include "three_address_code.h"     // Provides 'Quad' and declares 'generate3AC'

// Definition of the error reporting function
void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s at line %d\n", s, yylineno);
    fflush(stderr);
}

// Definition of the global AST root pointer
ASTNode* root = nullptr;

// Definition of print3AC function
void print3AC(const std::vector<Quad>& quads) {
    printf("DEBUG: print3AC - Entered. Number of quads: %zu\n", quads.size());
    fflush(stdout);
    int counter = 0;
    for (const auto& q : quads) {
        counter++;
        if (q.op == "label") printf("%s:\n", q.result.c_str());
        else if (q.op == "goto") printf("goto %s\n", q.result.c_str());
        else if (q.op == "ifFalse") printf("ifFalse %s goto %s\n", q.arg1.c_str(), q.result.c_str());
        else if (q.op == "=") printf("%s = %s\n", q.result.c_str(), q.arg1.c_str());
        else printf("%s = %s %s %s\n", q.result.c_str(), q.arg1.c_str(), q.op.c_str(), q.arg2.c_str());
    }
    printf("DEBUG: print3AC - Exited normally after processing %d quads.\n", counter);
    fflush(stdout);
}

// Main function
int main(int argc, char **argv) {
    printf("DEBUG: Main - Program started.\n"); fflush(stdout);
    
    // Check for input file argument
    if (argc <= 1) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        fflush(stderr);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        fflush(stderr);
        return 1;
    }

    // --- First Pass: Print all tokens ---
    printf("--- Lexical Analysis (Tokens) ---\n"); fflush(stdout);
    int token_val;
    // We need to access yylval from the lexer, so we must declare it.
    // Since we removed it from the top, we can declare it here.
    // Alternatively, ensure lexer.l includes parser.tab.h before its first use of yylval.
    // The lexer file already has the necessary declarations if it includes parser.tab.h.
    while ((token_val = yylex())) {
        printf("Line %d, Token: %s", yylineno, tokenToString(token_val));
        if (token_val == NUMBER) {
             printf("(%d)", yylval.ival);
        } else if (token_val == IDENT) {
             printf("(%s)", yylval.sval);
        }
        printf("\n");
    }
    printf("-----------------------------------\n\n"); fflush(stdout);

    // --- Reset for Second Pass (Parsing) ---
    // Close and re-open the file. This is more reliable than rewind().
    fclose(yyin);
    
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        fflush(stderr);
        return 1;
    }
    yylineno = 1;

    // --- Second Pass: Parse the code ---
    printf("--- Parsing (Building AST) ---\n"); fflush(stdout);
    if (yyparse() == 0) { // yyparse returns 0 on success
        if (root != NULL) {
            printf("Parsing successful!\n-----------------------------------\n\n"); fflush(stdout);
            
            printf("--- Abstract Syntax Tree ---\n"); fflush(stdout);
            printAST(root);
            printf("-----------------------------------\n\n"); fflush(stdout);

            printf("--- Three-Address Code ---\n"); fflush(stdout);
            std::vector<Quad> three_address_codes = generate3AC(root);
            print3AC(three_address_codes);
            printf("-------------------------------------------\n\n"); fflush(stdout);
            
        } else {
            printf("Parsing reported success, but AST root is NULL.\n");
            fflush(stdout);
        }
    } else {
        printf("Parsing failed (yyparse returned non-zero).\n");
        fflush(stdout);
    }

    if (yyin) {
      fclose(yyin);
    }
    printf("DEBUG: Main - Program finishing.\n"); fflush(stdout);
    return 0;
}


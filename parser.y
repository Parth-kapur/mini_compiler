%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <string>

#include "ast.h"
#include "three_address_code.h"
#include "x8086_generator.h"  


extern int yylex();
extern void yyerror(const char *s);
extern FILE* yyin;
extern int yylineno;
extern const char* tokenToString(int token);

extern ASTNode* createNumNode(int val);
extern ASTNode* createIdNode(char* name);
extern ASTNode* createOpNode(const std::string& op, ASTNode* l, ASTNode* r);
extern ASTNode* createAssignNode(char* name, ASTNode* expr);
extern ASTNode* createIfNode(ASTNode* cond, ASTNode* thenStmt, ASTNode* elseStmt);
extern ASTNode* createWhileNode(ASTNode* cond, ASTNode* body);
extern ASTNode* createForNode(ASTNode* init, ASTNode* cond, ASTNode* inc, ASTNode* body);
extern ASTNode* createSwitchNode(ASTNode* expr, ASTNode* cases);
extern ASTNode* createCaseNode(int val, ASTNode* body, ASTNode* next);
extern ASTNode* createNode(const std::string& type, ASTNode* left, ASTNode* right);

ASTNode* root = nullptr;

%}

%union {
    int ival;
    char* sval;
    ASTNode* node;
}

%token <ival> NUMBER
%token <sval> IDENT

// ALL tokens MUST be declared here so Bison knows about them!
%token IF ELSE WHILE FOR SWITCH CASE DEFAULT BREAK
%token EQ NE LE GE LT GT ASSIGN SEMICOLON COMMA COLON
%token PLUS MINUS MUL DIV MOD
%token INCR
%token DECR
%token LPAREN RPAREN LBRACE RBRACE // <--- ADDED THESE MISSING DECLARATIONS

// Operator Precedence and Associativity
// Lower lines have higher precedence (higher numeric value for tokens, not used here)
%right ASSIGN
%left PLUS MINUS
%left MUL DIV MOD
%nonassoc EQ NE
%nonassoc LT LE GT GE
// Pre-increment/decrement bind strongly to the identifier
%right INCR DECR

%type <node> program stmt expr stmt_list case_list opt_expr

%%

program:
    stmt_list                                  { root = $1; }
;

stmt_list:
    stmt                                       { $$ = $1; }
    | stmt_list stmt                           { $$ = createNode("stmt_list", $1, $2); }
;

stmt:
    IDENT ASSIGN expr SEMICOLON                { $$ = createAssignNode($1, $3); }
    | expr SEMICOLON                           { $$ = $1; }
    | IF LPAREN expr RPAREN stmt               { $$ = createIfNode($3, $5, nullptr); }
    | IF LPAREN expr RPAREN stmt ELSE stmt     { $$ = createIfNode($3, $5, $7); }
    | WHILE LPAREN expr RPAREN stmt            { $$ = createWhileNode($3, $5); }
    | FOR LPAREN opt_expr SEMICOLON opt_expr SEMICOLON opt_expr RPAREN stmt
                                               { $$ = createForNode($3, $5, $7, $9); }
    | SWITCH LPAREN expr RPAREN LBRACE case_list RBRACE
                                               { $$ = createSwitchNode($3, $6); }
    | BREAK SEMICOLON                          { $$ = createNode("break", nullptr, nullptr); }
    | LBRACE stmt_list RBRACE                  { $$ = $2; }
;

opt_expr:
    expr                                       { $$ = $1; }
    | /* empty */                              { $$ = nullptr; }
;

case_list:
     /* empty */                                 { $$ = nullptr; }
    | case_list CASE NUMBER COLON stmt_list      { $$ = createNode("case_list_entry", $1, createCaseNode($3, $5, nullptr)); }
    | case_list DEFAULT COLON stmt_list          { $$ = createNode("case_list_entry", $1, createNode("default_case", $4, nullptr)); }
;


expr:
    expr PLUS expr                             { $$ = createOpNode("+", $1, $3); }
    | expr MINUS expr                          { $$ = createOpNode("-", $1, $3); }
    | expr MUL expr                            { $$ = createOpNode("*", $1, $3); }
    | expr DIV expr                            { $$ = createOpNode("/", $1, $3); }
    | expr MOD expr                            { $$ = createOpNode("%", $1, $3); }
    | expr LT expr                             { $$ = createOpNode("<", $1, $3); }
    | expr GT expr                             { $$ = createOpNode(">", $1, $3); }
    | expr LE expr                             { $$ = createOpNode("<=", $1, $3); }
    | expr GE expr                             { $$ = createOpNode(">=", $1, $3); }
    | expr EQ expr                             { $$ = createOpNode("==", $1, $3); }
    | expr NE expr                             { $$ = createOpNode("!=", $1, $3); }
    | LPAREN expr RPAREN                       { $$ = $2; }
    | NUMBER                                   { $$ = createNumNode($1); }
    | IDENT                                    { $$ = createIdNode($1); }
    | IDENT INCR                               { $$ = createOpNode("++_post", createIdNode($1), nullptr); }
    | IDENT DECR                               { $$ = createOpNode("--_post", createIdNode($1), nullptr); }
    | INCR IDENT                               { $$ = createOpNode("++_pre", createIdNode($2), nullptr); }
    | DECR IDENT                               { $$ = createOpNode("--_pre", createIdNode($2), nullptr); }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s at line %d\n", s, yylineno);
    fflush(stderr);
}
void print3AC(const std::vector<Quad>& quads) {
    std::cout << "--- Three-Address Code ---" << std::endl;
    std::cout << "DEBUG: print3AC - Entered. Number of quads: " << quads.size() << std::endl;

    for (const auto& q : quads) {
        if (q.op == "=") {
            std::cout << q.result << " = " << q.arg1 << std::endl;
        } else if (q.op == "label") {
            std::cout << q.result << ":" << std::endl;
        } else if (q.op == "goto") {
            std::cout << "goto " << q.result << std::endl;
        } else if (q.op == "ifFalse") {
            std::cout << "ifFalse " << q.arg1 << " goto " << q.result << std::endl;
        } else if (q.op == "if") {
            std::cout << "if " << q.arg1 << " goto " << q.result << std::endl;
        } else {
            std::cout << q.result << " = " << q.arg1 << " " << q.op << " " << q.arg2 << std::endl;
        }
    }

    std::cout << "DEBUG: print3AC - Exited normally after processing " << quads.size() << " quads." << std::endl;
    std::cout << "-----------------------------------" << std::endl;
}

int main(int argc, char **argv) {
    printf("DEBUG: Main - Program started.\n"); fflush(stdout);

    if (argc <= 1) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        fflush(stderr);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }

    yylineno = 1;

    printf("--- Parsing (Building AST) ---\n"); fflush(stdout);

    if (yyparse() == 0) {
        if (root != NULL) {
            printf("Parsing successful!\n-----------------------------------\n\n");
            printf("--- Abstract Syntax Tree ---\n");
            printAST(root);
            printf("-----------------------------------\n\n");

            printf("--- Three-Address Code ---\n");
            std::vector<Quad> quads = generate3AC(root);
            print3AC(quads);
            printf("-------------------------------------------\n\n");

            // ✅ NEW: Generate 8086 Assembly
            std::string outputAsmFile = "output.asm";
            generate8086(quads, outputAsmFile);
            printf("8086 Assembly saved to %s\n", outputAsmFile.c_str());
        } else {
            printf("Parsing succeeded, but AST root is NULL (possibly empty input).\n");
        }
    } else {
        printf("Parsing failed (yyparse returned non-zero).\n");
    }

    if (yyin) fclose(yyin);
    printf("DEBUG: Main - Program finishing.\n"); fflush(stdout);
    return 0;
}


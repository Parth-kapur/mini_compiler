#ifndef AST_H
#define AST_H
#include <string>
#include <iostream>

// Forward declaration of ASTNode for the parser
struct ASTNode;

// Define the ASTNode structure
struct ASTNode {
    std::string type;
    std::string value;
    ASTNode* left;
    ASTNode* right;
    ASTNode* third;
    ASTNode* fourth;  // Added to support for loops with 4 children
    
    ASTNode(std::string t, std::string v = "", ASTNode* l = nullptr, ASTNode* r = nullptr, 
           ASTNode* th = nullptr, ASTNode* f = nullptr)
        : type(t), value(v), left(l), right(r), third(th), fourth(f) {}
};

// AST constructors
ASTNode* createNumNode(int val);
ASTNode* createIdNode(char* name);
ASTNode* createOpNode(std::string op, ASTNode* l, ASTNode* r);
ASTNode* createAssignNode(char* name, ASTNode* expr);
ASTNode* createIfNode(ASTNode* cond, ASTNode* thenStmt, ASTNode* elseStmt);
ASTNode* createWhileNode(ASTNode* cond, ASTNode* body);
ASTNode* createForNode(ASTNode* init, ASTNode* cond, ASTNode* inc, ASTNode* body);
ASTNode* createSwitchNode(ASTNode* expr, ASTNode* cases);
ASTNode* createCaseNode(int val, ASTNode* body, ASTNode* next);
ASTNode* createNode(const std::string& type, ASTNode* left, ASTNode* right);
void printAST(ASTNode* root, int indent = 0);

// External root variable declaration
extern ASTNode* root;

#endif


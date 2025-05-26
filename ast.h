#ifndef AST_H
#define AST_H

#include <string>
#include <iostream>

struct ASTNode {
    std::string type;
    std::string value;
    ASTNode* left;
    ASTNode* right;
    ASTNode* third;
    ASTNode* fourth;

    ASTNode(std::string t, std::string v = "", ASTNode* l = nullptr, ASTNode* r = nullptr,
            ASTNode* th = nullptr, ASTNode* f = nullptr)
        : type(t), value(v), left(l), right(r), third(th), fourth(f) {}
};

// --- Print AST ---
void printAST(ASTNode* node, int indent);  // legacy interface
void printAST(ASTNode* node, const std::string& prefix = "", bool isLast = true);  // tree style

// --- AST node creators ---
ASTNode* createNumNode(int val);
ASTNode* createIdNode(char* name);
ASTNode* createOpNode(const std::string& op, ASTNode* l, ASTNode* r);
ASTNode* createAssignNode(char* name, ASTNode* expr);
ASTNode* createIfNode(ASTNode* cond, ASTNode* thenStmt, ASTNode* elseStmt);
ASTNode* createWhileNode(ASTNode* cond, ASTNode* body);
ASTNode* createForNode(ASTNode* init, ASTNode* cond, ASTNode* inc, ASTNode* body);
ASTNode* createSwitchNode(ASTNode* expr, ASTNode* cases);
ASTNode* createCaseNode(int val, ASTNode* body, ASTNode* next);
ASTNode* createNode(const std::string& type, ASTNode* left, ASTNode* right);

// --- AST root ---
extern ASTNode* root;

#endif // AST_H


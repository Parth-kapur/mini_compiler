#ifndef AST_H
#define AST_H

#include <string>
#include <iostream> // For std::cout in printAST if used (though printf is used in .cpp)

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

// Function prototypes for creating different types of AST nodes
ASTNode* createNumNode(int val);
ASTNode* createIdNode(char* name);
ASTNode* createOpNode(const std::string& op, ASTNode* l, ASTNode* r);
ASTNode* createAssignNode(char* name, ASTNode* expr);
ASTNode* createIfNode(ASTNode* cond, ASTNode* thenStmt, ASTNode* elseStmt);
ASTNode* createWhileNode(ASTNode* cond, ASTNode* body);
ASTNode* createForNode(ASTNode* init, ASTNode* cond, ASTNode* inc, ASTNode* body);
ASTNode* createSwitchNode(ASTNode* expr, ASTNode* cases);
ASTNode* createCaseNode(int val, ASTNode* body, ASTNode* next);
ASTNode* createNode(const std::string& type, ASTNode* left, ASTNode* right); // Generic node creator
void printAST(ASTNode* root, int indent = 0); // For printing the AST

// Global pointer to the root of the AST, declared as extern
extern ASTNode* root;

#endif // AST_H


#include "ast.h"

ASTNode* createNumNode(int val) {
    return new ASTNode("num", std::to_string(val));
}

ASTNode* createIdNode(char* name) {
    return new ASTNode("id", std::string(name));
}

ASTNode* createOpNode(std::string op, ASTNode* l, ASTNode* r) {
    return new ASTNode("op", op, l, r);
}

ASTNode* createAssignNode(char* name, ASTNode* expr) {
    return new ASTNode("assign", std::string(name), expr);
}

ASTNode* createIfNode(ASTNode* cond, ASTNode* thenStmt, ASTNode* elseStmt) {
    return new ASTNode("if", "", cond, thenStmt, elseStmt);
}

ASTNode* createWhileNode(ASTNode* cond, ASTNode* body) {
    return new ASTNode("while", "", cond, body);
}

ASTNode* createForNode(ASTNode* init, ASTNode* cond, ASTNode* inc, ASTNode* body) {
    return new ASTNode("for", "", init, cond, inc, body);
}

ASTNode* createSwitchNode(ASTNode* expr, ASTNode* cases) {
    return new ASTNode("switch", "", expr, cases);
}

ASTNode* createCaseNode(int val, ASTNode* body, ASTNode* next) {
    return new ASTNode("case", std::to_string(val), body, next);
}

ASTNode* createNode(const std::string& type, ASTNode* left, ASTNode* right) {
    return new ASTNode(type, "", left, right);
}

void printAST(ASTNode* root, int indent) {
    if (!root) return;
    for (int i = 0; i < indent; ++i) std::cout << "  ";
    std::cout << root->type;
    if (!root->value.empty()) std::cout << "(" << root->value << ")";
    std::cout << "\n";
    
    printAST(root->left, indent + 1);
    printAST(root->right, indent + 1);
    printAST(root->third, indent + 1);
    printAST(root->fourth, indent + 1); // Added to support the fourth node
}


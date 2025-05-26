#include "ast.h"
#include <string>
#include <iostream> // For std::cout in printAST
#include <cstdio>   // For fprintf, fflush (used for error messages)
#include <vector> 

// --- Node Creation Helpers ---

ASTNode* createNumNode(int val) {
    return new ASTNode("num", std::to_string(val));
}

ASTNode* createIdNode(char* name) {
    if (name == nullptr) {
        fprintf(stderr, "DEBUG CRITICAL ERROR: createIdNode received a null name. This can lead to a crash. Creating placeholder.\n");
        fflush(stderr);
        return new ASTNode("id", "<ERROR_NULL_ID_NAME>");
    }
    return new ASTNode("id", std::string(name));
}

ASTNode* createOpNode(const std::string& op, ASTNode* l, ASTNode* r) {
    return new ASTNode("op", op, l, r); // Handles +, -, *, /, <, >, ==, ++, -- etc.
}

ASTNode* createAssignNode(char* name, ASTNode* expr) {
    if (name == nullptr) {
        fprintf(stderr, "DEBUG CRITICAL ERROR: createAssignNode received a null name for the identifier. This can lead to a crash. Creating placeholder.\n");
        fflush(stderr);
        return new ASTNode("assign", "<ERROR_NULL_ASSIGN_ID>", expr);
    }
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

// --- AST Printing ---

void printAST(ASTNode* node, const std::string& prefix, bool isLast) {
    if (!node) return;

    std::cout << prefix << (isLast ? "└── " : "├── ")
              << node->type;
    if (!node->value.empty()) {
        std::cout << "(" << node->value << ")";
    }
    std::cout << std::endl;

    std::string newPrefix = prefix + (isLast ? "    " : "│   ");
    std::vector<ASTNode*> children;
    if (node->left) children.push_back(node->left);
    if (node->right) children.push_back(node->right);
    if (node->third) children.push_back(node->third);
    if (node->fourth) children.push_back(node->fourth);

    for (size_t i = 0; i < children.size(); ++i) {
        printAST(children[i], newPrefix, i == children.size() - 1);
    }
}

// --- Compatibility wrapper ---
void printAST(ASTNode* node, int indent) {
    std::string prefix(indent * 2, ' ');
    printAST(node, prefix, true);
}



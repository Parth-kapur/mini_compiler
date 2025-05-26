#include "ast.h"
#include <iostream>
#include <unordered_set>
#include <unordered_map>

int tempCount = 0;
std::unordered_set<std::string> declaredVars;
std::unordered_map<ASTNode*, std::string> tempNames;

std::string newTemp() {
    return "t" + std::to_string(++tempCount);
}

void semanticError(const std::string& msg) {
    std::cerr << "Semantic Error: " << msg << std::endl;
    exit(1);
}

std::string generate3AC(ASTNode* node) {
    if (!node) return "";

    if (node->type == "stmt_list") {
        generate3AC(node->left);
        generate3AC(node->right);
        return "";
    }

    else if (node->type == "assign") {
        std::string rhs = generate3AC(node->left);
        declaredVars.insert(node->value);  
        std::cout << node->value << " = " << rhs << std::endl;
        return "";
    }

    else if (node->type == "id") {
        if (declaredVars.find(node->value) == declaredVars.end()) {
            semanticError("Undeclared variable: " + node->value);
        }
        return node->value;
    }

    else if (node->type == "num") {
        return node->value;
    }

    else if (node->type == "op") {
        std::string left = generate3AC(node->left);
        std::string right = generate3AC(node->right);
        std::string temp = newTemp();
        std::cout << temp << " = " << left << " " << node->value << " " << right << std::endl;
        return temp;
    }

    else if (node->type == "if") {
        std::string cond = generate3AC(node->left);
        std::string label1 = "L" + std::to_string(tempCount + 1);
        std::string label2 = "L" + std::to_string(tempCount + 2);

        std::cout << "ifFalse " << cond << " goto " << label1 << std::endl;
        generate3AC(node->right); 
        std::cout << "goto " << label2 << std::endl;
        std::cout << label1 << ":" << std::endl;
        if (node->third) {
            generate3AC(node->third); 
        }
        std::cout << label2 << ":" << std::endl;
        return "";
    }

    return "";
}

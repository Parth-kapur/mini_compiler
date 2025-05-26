#ifndef THREE_ADDRESS_CODE_H
#define THREE_ADDRESS_CODE_H

#include "ast.h"    // For ASTNode
#include <string>   // For std::string
#include <vector>   // For std::vector

// Definition of a single Three-Address Code instruction (Quadruple)
struct Quad {
    std::string op;     // Operation (e.g., "+", "=", "ifFalse", "goto", "label")
    std::string arg1;   // First argument or source
    std::string arg2;   // Second argument or source (optional)
    std::string result; // Result or destination/target label
};

// Function to generate a list of three-address code instructions from the AST
std::vector<Quad> generate3AC(ASTNode* node);

#endif // THREE_ADDRESS_CODE_H


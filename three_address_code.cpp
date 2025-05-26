#include "three_address_code.h"
#include <iostream> // For std::cerr (though printf is used more for debug)
#include <string>
#include <vector>
#include <cstdio>   // For printf, fprintf, fflush

// --- Globals for 3AC Generation ---
static int tempCount = 0;
static int labelCount = 0;
static std::string currentBreakLabel = ""; // For handling break statements if you implement them

// --- Helper Functions ---
std::string newTemp() { return "t" + std::to_string(++tempCount); }
std::string newLabel() { return "L" + std::to_string(++labelCount); }

std::string safe_s(const char* s) { 
    if (s == nullptr) {
        return "<NULL_SVAL_ERROR_IN_3AC>";
    }
    return std::string(s); 
}
std::string safe_s(const std::string& s) { return s; }

// Forward declaration for the recursive helper
std::string generate3ACHelper(ASTNode* node, std::vector<Quad>& quads);

// --- Main Public Function ---
std::vector<Quad> generate3AC(ASTNode* node) {
    printf("DEBUG: generate3AC - Top level function called (Normal 3AC Generation).\n"); 
    fflush(stdout);
    
    std::vector<Quad> quads;
    tempCount = 0;
    labelCount = 0;
    currentBreakLabel = "";

    generate3ACHelper(node, quads);

    printf("DEBUG: generate3AC - Finished generating %zu quads.\n", quads.size()); 
    fflush(stdout);
    
    return quads; 
}

// --- Recursive Helper Function to Build the Quads by Traversing the AST ---
std::string generate3ACHelper(ASTNode* node, std::vector<Quad>& quads) {
    if (!node) {
        return "<NULL_AST_NODE_ERROR>"; 
    }

    if (node->type == "stmt_list") {
        if (node->left) generate3ACHelper(node->left, quads);
        if (node->right) generate3ACHelper(node->right, quads);
        return ""; 
    }

    if (node->type == "assign") {
        std::string rhs_str = generate3ACHelper(node->left, quads);
        quads.push_back({"=", safe_s(rhs_str), "", safe_s(node->value)});
        return "";
    }

    if (node->type == "id") {
        return safe_s(node->value); 
    }

    if (node->type == "num") {
        return safe_s(node->value); 
    }

    if (node->type == "op") {
        std::string left_operand = generate3ACHelper(node->left, quads);
        std::string right_operand = generate3ACHelper(node->right, quads);
        std::string temp_var = newTemp();
        quads.push_back({safe_s(node->value), safe_s(left_operand), safe_s(right_operand), safe_s(temp_var)});
        return temp_var; 
    }

    if (node->type == "if") {
        std::string cond_result = generate3ACHelper(node->left, quads);
        std::string else_label = newLabel();
        quads.push_back({"ifFalse", safe_s(cond_result), "", safe_s(else_label)});

        if(node->right) generate3ACHelper(node->right, quads); 

        if (node->third) { 
            std::string end_label = newLabel();
            quads.push_back({"goto", "", "", safe_s(end_label)}); 
            quads.push_back({"label", "", "", safe_s(else_label)}); 
            if(node->third) generate3ACHelper(node->third, quads); 
            quads.push_back({"label", "", "", safe_s(end_label)});   
        } else {
            quads.push_back({"label", "", "", safe_s(else_label)}); 
        }
        return "";
    }
    
    if (node->type == "while") {
        std::string start_label = newLabel();
        std::string end_label = newLabel();
        std::string old_break = currentBreakLabel; 
        currentBreakLabel = end_label;
        quads.push_back({"label", "", "", start_label});
        if(node->left) { 
            std::string cond_res = generate3ACHelper(node->left, quads);
            quads.push_back({"ifFalse", cond_res, "", end_label});
        }
        if(node->right) generate3ACHelper(node->right, quads); 
        quads.push_back({"goto", "", "", start_label});
        quads.push_back({"label", "", "", end_label});
        currentBreakLabel = old_break; 
        return "";
    }
    if (node->type == "for") {
        if(node->left) generate3ACHelper(node->left, quads); 
        std::string start_label = newLabel();
        std::string end_label = newLabel();
        std::string old_break = currentBreakLabel;
        currentBreakLabel = end_label;
        quads.push_back({"label", "", "", start_label});
        if(node->right) { 
             std::string cond_res = generate3ACHelper(node->right, quads);
             quads.push_back({"ifFalse", cond_res, "", end_label});
        }
        if(node->fourth)generate3ACHelper(node->fourth, quads); 
        if(node->third) generate3ACHelper(node->third, quads); 
        quads.push_back({"goto", "", "", start_label});
        quads.push_back({"label", "", "", end_label});
        currentBreakLabel = old_break;
        return "";
    }
     if (node->type == "break") {
        if (currentBreakLabel.empty()) {
             fprintf(stderr, "Semantic Error: 'break' statement not within a loop or switch.\n"); fflush(stderr);
        } else {
            quads.push_back({"goto", "", "", currentBreakLabel});
        }
        return "";
    }

    fprintf(stderr, "DEBUG WARNING: generate3ACHelper - Unhandled AST node type: [%s] with value [%s]\n", 
            node->type.c_str(), node->value.c_str());
    fflush(stderr);
    return "<UNHANDLED_AST_NODE_" + node->type + ">";
}


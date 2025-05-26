#include "x8086_generator.h"
#include <iostream> // For std::cerr (though printf/fprintf is used more here)
#include <fstream>  // For std::ofstream
#include <string>
#include <vector>
#include <set>
#include <map>
#include <cctype> // For std::isdigit
#include <cstdio> // For printf, fprintf, fflush

// Anonymous namespace for helper local to this file
namespace {
    bool isNumber_8086(const std::string& s) {
        if (s.empty()) return false;
        for (char const &c : s) {
            if (std::isdigit(c) == 0) return false;
        }
        return true;
    }

    // Helper function to write to both file and terminal
    void writeAsm(std::ofstream& outfile, const std::string& line) {
        outfile << line << "\n";
        printf("%s\n", line.c_str()); // Print to terminal
    }
    // Overload for char* (though std::string is preferred for safety)
    void writeAsm(std::ofstream& outfile, const char* line_cstr) {
        if (line_cstr) {
            outfile << line_cstr << "\n";
            printf("%s\n", line_cstr); 
        } else {
            fprintf(stderr, "DEBUG WARNING: writeAsm received null char*\n");
            fflush(stderr);
        }
    }

} // end anonymous namespace

void generate8086(const std::vector<Quad>& quads, const std::string& filename) {
    printf("DEBUG: *** Entered generate8086 function. ***\n");
    fflush(stdout); 

    printf("DEBUG: generate8086 - Output filename: %s\n", filename.c_str());
    fflush(stdout);
    printf("DEBUG: generate8086 - Number of quads received: %zu\n", quads.size());
    fflush(stdout);

    std::ofstream outfile(filename);
    if (!outfile.is_open()) {
        fprintf(stderr, "DEBUG CRITICAL ERROR: In generate8086 - Could not open output file '%s'. Terminating function.\n", filename.c_str());
        fflush(stderr);
        return; 
    }
    printf("DEBUG: generate8086 - Successfully opened output file '%s'.\n", filename.c_str());
    fflush(stdout);

    printf("--- Generated 8086 Assembly (also written to %s) ---\n", filename.c_str()); 
    fflush(stdout);

    std::set<std::string> variables;
    std::map<std::string, Quad> temp_definitions;

    // Pass 1: Collect all variable names
    for (const auto& q : quads) {
        if (!q.arg1.empty() && !isNumber_8086(q.arg1)) variables.insert(q.arg1);
        if (!q.arg2.empty() && !isNumber_8086(q.arg2)) variables.insert(q.arg2);
        if (!q.result.empty() && q.op != "label" && q.op != "goto") {
            variables.insert(q.result);
            // Ensure result is not empty before checking its first character
            if (!q.result.empty() && q.result[0] == 't') { 
                temp_definitions[q.result] = q;
            }
        }
    }

    writeAsm(outfile, ".MODEL SMALL");
    writeAsm(outfile, ".STACK 100h");
    writeAsm(outfile, ".DATA");
    for (const auto& var : variables) {
        std::string line = "    " + var + " DW ?";
        writeAsm(outfile, line);
    }

    writeAsm(outfile, "\n.CODE");
    writeAsm(outfile, "MAIN PROC");
    writeAsm(outfile, "    MOV AX, @DATA");
    writeAsm(outfile, "    MOV DS, AX");
    // Add a newline to terminal for readability after boilerplate
    if (variables.size() > 0) printf("\n"); // Only if data segment was not empty
    else printf("\n\n"); // If data segment was empty, ensure .CODE starts clearly


    // Pass 2: Translate Quads to Simplified 8086
    for (const auto& q : quads) {
        std::string asm_line1, asm_line2, asm_line3, asm_line4; 

        if (q.op == "label") {
            asm_line1 = q.result + ":";
            writeAsm(outfile, asm_line1);
        }
        else if (q.op == "=") {
            if (isNumber_8086(q.arg1)) {
                asm_line1 = "    MOV " + q.result + ", " + q.arg1;
                writeAsm(outfile, asm_line1);
            } 
            else {
                asm_line1 = "    MOV AX, " + q.arg1;
                asm_line2 = "    MOV " + q.result + ", AX";
                writeAsm(outfile, asm_line1);
                writeAsm(outfile, asm_line2);
            }
        }
        else if (q.op == "+" || q.op == "-") {
            asm_line1 = "    MOV AX, " + q.arg1;
            asm_line2 = "    MOV BX, " + q.arg2;
            writeAsm(outfile, asm_line1);
            writeAsm(outfile, asm_line2);
            if (q.op == "+") asm_line3 = "    ADD AX, BX";
            else if (q.op == "-") asm_line3 = "    SUB AX, BX"; // Added else if for clarity
            else { /* Should not happen if op is only + or - here */ }
            writeAsm(outfile, asm_line3);
            asm_line4 = "    MOV " + q.result + ", AX";
            writeAsm(outfile, asm_line4);
        }
        else if (q.op == "goto") {
            asm_line1 = "    JMP " + q.result;
            writeAsm(outfile, asm_line1);
        }
        else if (q.op == "ifFalse") {
            if (!q.arg1.empty() && temp_definitions.count(q.arg1)) {
                Quad condition = temp_definitions.at(q.arg1); 
                if (condition.arg1.empty() || condition.arg2.empty() || condition.op.empty()) {
                    fprintf(stderr, "DEBUG WARNING: x8086_generator - Corrupt condition for ifFalse (temp: %s, cond.arg1: %s, cond.op: %s, cond.arg2: %s)\n", 
                            q.arg1.c_str(), condition.arg1.c_str(), condition.op.c_str(), condition.arg2.c_str());
                    fflush(stderr);
                    continue; 
                }
                asm_line1 = "    MOV AX, " + condition.arg1;
                asm_line2 = "    CMP AX, " + condition.arg2;
                writeAsm(outfile, asm_line1);
                writeAsm(outfile, asm_line2);

                std::string jump_instruction;
                if(condition.op == "==") jump_instruction = "JNE"; 
                else if(condition.op == "!=") jump_instruction = "JE";  
                else if(condition.op == "<")  jump_instruction = "JGE"; 
                else if(condition.op == "<=") jump_instruction = "JG";  
                else if(condition.op == ">")  jump_instruction = "JLE"; 
                else if(condition.op == ">=") jump_instruction = "JL";  
                else {
                    fprintf(stderr, "DEBUG WARNING: x8086_generator - Unhandled condition.op '%s' for ifFalse (temp '%s').\n", 
                            condition.op.c_str(), q.arg1.c_str());
                    fflush(stderr);
                }
                if (!jump_instruction.empty()) {
                    asm_line3 = "    " + jump_instruction + " " + q.result;
                    writeAsm(outfile, asm_line3);
                }
            } else {
                fprintf(stderr, "DEBUG WARNING: x8086_generator - Temp variable '%s' for ifFalse not in temp_definitions or empty.\n", 
                        q.arg1.c_str());
                fflush(stderr);
            }
        }
        else if (!q.result.empty() && q.result[0] == 't' && 
                 (q.op == "==" || q.op == "!=" || q.op == "<" || q.op == "<=" || q.op == ">" || q.op == ">=")) {
            // This is a relational operation that creates a temporary.
            // Silently ignore it, as its logic is handled by the "ifFalse" case.
        }
        // Add a small empty line to terminal for readability between 3AC instruction translations
        if (!q.op.empty() && q.op != "label") printf("\n"); 
        fflush(stdout); // Flush after each instruction's translation
    }

    printf("\n"); // Final newline before exit boilerplate
    fflush(stdout);
    writeAsm(outfile, "\n    ; Exit the program");
    writeAsm(outfile, "    MOV AH, 4Ch");
    writeAsm(outfile, "    INT 21h");
    writeAsm(outfile, "MAIN ENDP");
    writeAsm(outfile, "END MAIN");

    outfile.close();
    printf("------------------------------------------------------\n"); 
    printf("DEBUG: generate8086 - Closed output file. Function finished.\n"); 
    fflush(stdout);
}


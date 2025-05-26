#include "simple_code_generator.h"
#include <cstdio>   // For printf, fflush
#include <fstream>  // For std::ofstream
#include <iostream> // For std::cerr (though printf/fprintf is used more here)

void generateSimpleCode(const std::vector<Quad>& quads, const std::string& filename) {
    printf("DEBUG: *** Entered generateSimpleCode function. ***\n");
    fflush(stdout);

    printf("DEBUG: generateSimpleCode - Output filename: %s\n", filename.c_str());
    fflush(stdout);
    printf("DEBUG: generateSimpleCode - Number of quads received: %zu\n", quads.size());
    fflush(stdout);

    std::ofstream outfile(filename);
    if (!outfile.is_open()) {
        fprintf(stderr, "DEBUG CRITICAL ERROR: In generateSimpleCode - Could not open output file '%s'. Terminating function.\n", filename.c_str());
        fflush(stderr);
        return; 
    }
    
    printf("DEBUG: generateSimpleCode - Successfully opened output file '%s'.\n", filename.c_str());
    fflush(stdout);

    outfile << "; Simple Code Generator Output\n";
    outfile << "; Received " << quads.size() << " 3AC instructions.\n";
    
    // Optionally, iterate through quads and print a summary or a few
    // for(const auto& q : quads) {
    //     outfile << "; 3AC: " << q.op << " " << q.arg1 << " " << q.arg2 << " " << q.result << "\n";
    // }

    outfile << "HALT ; End of simple program\n";

    outfile.close();
    printf("DEBUG: generateSimpleCode - Wrote to and closed output file. Function finished.\n");
    fflush(stdout);
}


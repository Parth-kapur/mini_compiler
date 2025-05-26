#ifndef X8086_GENERATOR_H
#define X8086_GENERATOR_H

#include "three_address_code.h" // This provides the definition for 'Quad' and 'std::vector'
#include <string>
#include <vector>

// This is the function declaration that parser.y (specifically parser.tab.cpp)
// needs to see when the main() function calls generate8086.
void generate8086(const std::vector<Quad>& quads, const std::string& filename);

#endif // X8086_GENERATOR_H


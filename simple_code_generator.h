#ifndef X8086_GENERATOR_H
#define X8086_GENERATOR_H

#include "three_address_code.h" // Provides 'Quad' and uses std::vector
#include <string>
#include <vector>

// This is the function declaration that parser.y needs to see.
void generate8086(const std::vector<Quad>& quads, const std::string& filename);

#endif // X8086_GENERATOR_H


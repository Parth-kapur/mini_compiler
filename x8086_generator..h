#ifndef X8086_GENERATOR_H
#define X8086_GENERATOR_H

#include "three_address_code.h" // For Quad
#include <string>
#include <vector>

// ✅ THIS MUST EXIST:
void generate8086(const std::vector<Quad>& quads, const std::string& filename);

#endif // X8086_GENERATOR_H


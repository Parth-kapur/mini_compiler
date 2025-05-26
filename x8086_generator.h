#ifndef SIMPLE_CODE_GENERATOR_H
#define SIMPLE_CODE_GENERATOR_H

#include "three_address_code.h" // For Quad and std::vector
#include <string>
#include <vector>

// Declaration for our new simple code generator function
void generateSimpleCode(const std::vector<Quad>& quads, const std::string& filename);

#endif // SIMPLE_CODE_GENERATOR_H


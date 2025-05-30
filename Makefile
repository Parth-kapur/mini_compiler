# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wno-unused-function -I.
# Tools
LEX = flex
BISON = bison

# Generated file names (for clarity and consistency)
PARSER_CPP_OUTPUT = parser.tab.cpp
PARSER_HEADER_OUTPUT = parser.tab.h
LEXER_C_OUTPUT = lex.yy.c

# Object files needed for the final program
OBJS = ast.o three_address_code.o x8086_generator.o $(PARSER_CPP_OUTPUT:.cpp=.o) $(LEXER_C_OUTPUT:.c=.o)

# The name of our final compiler executable
TARGET = compiler

# Default target: build the compiler
all: $(TARGET)
	@echo "--- Target 'all' completed: $(TARGET) should be built. ---"

# Rule to link all the object files into the final executable
$(TARGET): $(OBJS)
	@echo "--- Linking object files to create executable: $(TARGET) ---"
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)
	@echo "--- Linking complete. $(TARGET) is ready. ---"

# --- Compilation Rules for .o files from .cpp or .c files ---

$(PARSER_CPP_OUTPUT:.cpp=.o): $(PARSER_CPP_OUTPUT) $(PARSER_HEADER_OUTPUT) ast.h three_address_code.h
	@echo "--- Compiling $(PARSER_CPP_OUTPUT) into $(PARSER_CPP_OUTPUT:.cpp=.o) ---"
	$(CXX) $(CXXFLAGS) -c $(PARSER_CPP_OUTPUT) -o $(PARSER_CPP_OUTPUT:.cpp=.o)

$(LEXER_C_OUTPUT:.c=.o): $(LEXER_C_OUTPUT) $(PARSER_HEADER_OUTPUT)
	@echo "--- Compiling $(LEXER_C_OUTPUT) into $(LEXER_C_OUTPUT:.c=.o) (depends on $(PARSER_HEADER_OUTPUT)) ---"
	$(CXX) $(CXXFLAGS) -c $(LEXER_C_OUTPUT) -o $(LEXER_C_OUTPUT:.c=.o)

ast.o: ast.cpp ast.h
	@echo "--- Compiling ast.cpp into ast.o ---"
	$(CXX) $(CXXFLAGS) -c ast.cpp -o ast.o

three_address_code.o: three_address_code.cpp three_address_code.h ast.h
	@echo "--- Compiling three_address_code.cpp into three_address_code.o ---"
	$(CXX) $(CXXFLAGS) -c three_address_code.cpp -o three_address_code.o

x8086_generator.o: x8086_generator.cpp x8086_generator.h three_address_code.h
	@echo "--- Compiling x8086_generator.cpp into x8086_generator.o ---"
	$(CXX) $(CXXFLAGS) -c x8086_generator.cpp -o x8086_generator.o

# --- File Generation Rules (Bison and Flex) ---

$(PARSER_CPP_OUTPUT) $(PARSER_HEADER_OUTPUT): parser.y
	@echo "--- Running Bison on parser.y (simplified command: bison -d parser.y) ---"
	$(BISON) -d parser.y
	@echo "--- Bison finished. Attempting to rename parser.tab.c to $(PARSER_CPP_OUTPUT) ---"
	@mv parser.tab.c $(PARSER_CPP_OUTPUT) 2>/dev/null || echo "Note: parser.tab.c not found for renaming (maybe bison created .cpp or failed to create .c)."
	@echo "--- Checking if $(PARSER_HEADER_OUTPUT) was created by 'bison -d parser.y': ---"
	@ls -l $(PARSER_HEADER_OUTPUT) || (echo "ERROR: $(PARSER_HEADER_OUTPUT) was NOT created by Bison!" && exit 1)

$(LEXER_C_OUTPUT): lexer.l $(PARSER_HEADER_OUTPUT)
	@echo "--- Running Flex on lexer.l to generate $(LEXER_C_OUTPUT) (needs $(PARSER_HEADER_OUTPUT) to exist) ---"
	$(LEX) -o $(LEXER_C_OUTPUT) lexer.l
	@echo "--- Flex finished. $(LEXER_C_OUTPUT) should now exist. ---"

# Rule to clean up all generated files
clean:
	@echo "--- Cleaning up generated files and the target executable ---"
	rm -f $(TARGET) $(OBJS) $(PARSER_CPP_OUTPUT) $(PARSER_HEADER_OUTPUT) $(LEXER_C_OUTPUT) parser.tab.c output_simple.txt
	@echo "--- Cleanup complete. ---"


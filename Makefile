# Compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wno-unused-function
# Tools
LEX = flex
BISON = bison
# Files
FLEX_SRC = lexer.l
BISON_SRC = parser.y
AST_SRC = ast.cpp
OBJS = parser.tab.o lex.yy.o ast.o
# Output target
TARGET = parser

# Default target
all: $(TARGET)

# Generate the Parser first
parser.tab.c parser.tab.h: $(BISON_SRC)
	$(BISON) -d $(BISON_SRC)

# Then generate the Lexer
lex.yy.c: $(FLEX_SRC) parser.tab.h
	$(LEX) $(FLEX_SRC)

# Compile AST source file first (since others depend on it)
ast.o: $(AST_SRC) ast.h
	$(CXX) $(CXXFLAGS) -c $(AST_SRC)

# Compile parser object file (depends on ast.h)
parser.tab.o: parser.tab.c parser.tab.h ast.h
	$(CXX) $(CXXFLAGS) -c parser.tab.c

# Compile lexer object file (depends on parser.tab.h which depends on ast.h)
lex.yy.o: lex.yy.c parser.tab.h ast.h
	$(CXX) $(CXXFLAGS) -c lex.yy.c

# Link everything into final executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Clean build files
clean:
	rm -f *.o parser parser.tab.* lex.yy.c


CXX      := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -O2

BISON    := bison
FLEX     := flex

TARGET   := rx-cc

PARSER_SRC := part3.ypp
LEXER_SRC  := part3.lex
HELPERS_SRC:= part3_helpers.cpp

PARSER_OUT := part3.tab.cpp
PARSER_HDR := part3.tab.hpp
LEXER_OUT  := part3.yy.cpp

all: $(TARGET)

$(PARSER_OUT) $(PARSER_HDR): $(PARSER_SRC) part3_helpers.hpp
	$(BISON) -d --defines=$(PARSER_HDR) -o $(PARSER_OUT) $(PARSER_SRC)

$(LEXER_OUT): $(LEXER_SRC) $(PARSER_HDR) part3_helpers.hpp
	$(FLEX) -o $(LEXER_OUT) $(LEXER_SRC)

$(TARGET): $(PARSER_OUT) $(LEXER_OUT) $(HELPERS_SRC) part3_helpers.hpp
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(PARSER_OUT) $(LEXER_OUT) $(HELPERS_SRC) -lfl

clean:
	rm -f $(TARGET) $(PARSER_OUT) $(PARSER_HDR) $(LEXER_OUT) *.o

.PHONY: all clean

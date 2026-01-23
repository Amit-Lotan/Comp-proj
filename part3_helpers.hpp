#ifndef _PART3_HELPER_H_
#define _PART3_HELPER_H_

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <map>

#define LEXICAL_ERROR 1
#define SYNTAX_ERROR 2
#define SEMANTIC_ERROR 3
#define OPERATIONAL_ERROR 9

using namespace std;

typedef enum {int8 = 8, int16 = 16, int32 = 32, void_t = 0} Type;

// Generate a string out of an int
static string intToString(double num) {
    stringstream ss;
    ss << num;
    return ss.str();
}
// Merge two lists for backpatching
template <typename T>
static vector<T> merge(vector<T>& lst1, vector<T>& lst2) {
	vector<T> result = lst1;
	result.insert(result.end(), lst2.begin(), lst2.end());
	return result;
}
// Definition of a token's fields
typedef struct {
	// Name of the token (in case it represents an identifier)
	string str;
	// Type of the token
	Type type;
	// Offset in memory
	int offset;
	vector<int> nextList; 
	vector<int> trueList;
	vector<int> falseList;
	// Number of line the token's expression will be printed at in the .rsk file
	int quad;
	// Number of the register the token is assigned
	int regNum;
	// List of parameters' types in function's defenition
	vector<Type> paramTypes;
	// List of parameters registers' numbers in function's defenition
	vector<int>  paramRegs; 
} yystype;
// Definition of Symbol struct
class Symbol {
	public:
		map<int,Type> type; //each element holds the depth of the symbol and its type
		map<int,int> offset;// first int is the depth, second is 
		int depth; //the depth in which the most inner symbol is defined in.
};
// Definition of Function class
class Function {
	public:
		// The starting address in the buffer of the function implementation
		int startLineImplementation; 
		// The return type of the function.  
		Type returnType;
		// The types of parameters of the function
		vector<Type> paramTypes; 
		// List of all the addresses in .rsk file where the function is being called
		vector<int> callingLines;
		// Indicator for if the function has been defined or not
		bool defined; 
};


// Definition of Buffer class
class Buffer {
		vector<string> data;
	public:
		Buffer();
		// Emit a command as a new line at the end of the buffer
		void emit(const string& str);
		// Emit a command as a new line at the start of the buffer
		void emit_front(const string& str);
		// Backpatch the holes in list with a given line number
		void backpatch(vector<int> lst, int line);
		// Return the next empty line in the buffer
		int nextquad();
		// Print all the data in the buffer 
		string printBuffer();
};


// Global variables
static Buffer * buffer; 
static Buffer mainBuffer;
static map<string, Symbol> symbolTable; 
static map<string, Function> functionTable;
static int currentReturnType;
static int currentScopeRegsNum = 3; // Number of registers in use in the current function
static int currentScopeOffset = 0; // Current offset in memory: where to store the next piece of data
static int prevScopeOffset = 0;  
static int currentBlockDepth = 0;  // Current depth in blocks relatively to the most outer block
static vector<string> currentParamInsertionOrder;
static vector<string> tmpParamInsertionOrder;

#define YYSTYPE yystype

#endif

#ifndef PART3_HELPERS_HPP
#define PART3_HELPERS_HPP

#include <string>
#include <vector>
#include <map>
#include <iostream>

using namespace std;

// Error codes
#define LEXICAL_ERROR     1
#define SYNTAX_ERROR      2
#define SEMANTIC_ERROR    3
#define OPERATIONAL_ERROR 4

// Types
enum Type {
    void_t,
    int_t,
    float_t
};

// Semantic value struct (Node)
struct Node {
    string str;
    Type type = void_t;
    
    // Register number allocated for this expression
    int regNum = -1;
    
    // Offset in stack (for variables)
    int offset = 0;
    
    // Quad number (for markers)
    int quad = 0;
    
    // Backpatching lists
    vector<int> nextList;
    vector<int> trueList;
    vector<int> falseList;

    // For declarations / function parameters
    vector<string> paramNames;
    vector<Type> paramTypes;
    vector<int> paramRegs; // For call arguments
    
    // For named arguments
    vector<string> namedLabels;
    vector<int> namedRegs;
    vector<Type> namedTypes;
};

// Global Helper Classes
class CodeBuffer {
public:
    CodeBuffer();
    void emit(const string& str);
    void emit_front(const string& str);
    void backpatch(const vector<int>& lst, int line);
    int nextquad();
    string printBuffer();

private:
    vector<string> data;
};

struct Function {
    Type returnType;
    vector<Type> paramTypes;
    vector<string> paramNames; // Needed for named args
    int startLineImplementation;
    bool defined;
    vector<int> callingLines;
};

struct Symbol {
    int offset;
    Type type;
};

// Helpers
string intToString(int i);
template <typename T>
vector<T> merge(const vector<T>& l1, const vector<T>& l2) {
    vector<T> ret = l1;
    ret.insert(ret.end(), l2.begin(), l2.end());
    return ret;
}

#endif

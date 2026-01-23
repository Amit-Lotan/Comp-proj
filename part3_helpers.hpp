#ifndef PART3_HELPERS_HPP
#define PART3_HELPERS_HPP

#include <string>
#include <vector>
#include <map>
#include <iostream>

using namespace std;

#define LEXICAL_ERROR     1
#define SYNTAX_ERROR      2
#define SEMANTIC_ERROR    3
#define OPERATIONAL_ERROR 4

enum Type {
    void_t,
    int_t,
    float_type
};

struct Node {
    string str;
    Type type = void_t;
    int regNum = -1;
    int offset = 0;
    int quad = 0;
    
    vector<int> nextList;
    vector<int> trueList;
    vector<int> falseList;

    vector<string> paramNames;
    vector<Type> paramTypes;
    vector<int> paramRegs;
    
    vector<string> namedLabels;
    vector<int> namedRegs;
    vector<Type> namedTypes;
};

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
    vector<string> paramNames;
    int startLineImplementation;
    bool defined;
    vector<int> callingLines;
};

struct Symbol {
    int offset;
    Type type;
};

string intToString(int i);
template <typename T>
vector<T> merge(const vector<T>& l1, const vector<T>& l2) {
    vector<T> ret = l1;
    ret.insert(ret.end(), l2.begin(), l2.end());
    return ret;
}

#endif

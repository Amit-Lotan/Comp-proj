/*
    EE046266: Compilation Methods - Winter 2025-2026
    Project Part 3 - C-- to Riski compiler (rx-cc)

    This header contains small helper utilities shared by the Flex scanner
    and the Bison parser.
*/

#ifndef PART3_HELPERS_HPP
#define PART3_HELPERS_HPP

#include <string>
#include <vector>

// Exit codes (as required by the project PDF)
#define LEXICAL_ERROR     1
#define SYNTAX_ERROR      2
#define SEMANTIC_ERROR    3
#define OPERATIONAL_ERROR 4

// Primitive types in C--
enum Type {
    void_t  = 0,
    int_    = 1,
    float_  = 2
};

// Semantic attributes object (allocated on heap; Bison/Flex pass Attr* around)
struct Attr {
    // Generic lexeme (ID, operators, literal numbers, string contents)
    std::string str;

    // Expression type
    Type type = void_t;

    // Register index that holds the expression value.
    // For int_ => I<reg>, for float_ => F<reg>, for void_t => -1
    int reg = -1;

    // Frame-pointer-relative offset in bytes for variables (LVAL / identifier
    // expressions). Can be negative (for parameters).
    int offset = 0;

    // Marker quad (instruction index)
    int quad = -1;

    // Backpatching lists
    std::vector<int> nextList;
    std::vector<int> trueList;
    std::vector<int> falseList;

    // DCL ids (for variable/parameter declarations)
    std::vector<std::string> names;

    // Function parameter list (names+types in order)
    std::vector<std::string> paramNames;
    std::vector<Type> paramTypes;

    // Call arguments (positional and named)
    std::vector<int> posRegs;
    std::vector<Type> posTypes;

    std::vector<std::string> namedNames;
    std::vector<int> namedRegs;
    std::vector<Type> namedTypes;
};

// Small helpers
static inline std::string itos(int v) {
    return std::to_string(v);
}

static inline std::vector<int> mergeLists(const std::vector<int>& a, const std::vector<int>& b) {
    std::vector<int> out;
    out.reserve(a.size() + b.size());
    out.insert(out.end(), a.begin(), a.end());
    out.insert(out.end(), b.begin(), b.end());
    return out;
}

// A very small "code buffer" that stores the generated Riski assembly.
//
// Line numbers are 1-based (the first emitted instruction is line 1).
// Backpatching works by emitting jump instructions with a trailing space,
// e.g. "UJUMP " or "BREQZ I10 ", and then later appending the absolute
// jump target line number.
class CodeBuffer {
public:
    int nextQuad() const;
    void emit(const std::string& line);

    // Appends the numeric label to each listed line.
    void backpatch(const std::vector<int>& lst, int label);

    const std::vector<std::string>& getLines() const;

    // Replace an existing line (1-based line number). No-op on out-of-range.
    void patchLine(int lineNo, const std::string& newLine);

    // Return the entire program text (instructions separated by \n).
    std::string str() const;

private:
    std::vector<std::string> m_lines;
};


#endif

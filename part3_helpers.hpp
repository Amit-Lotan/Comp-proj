#pragma once

#include <string>
#include <vector>
#include <unordered_map>

// -----------------------------
// Types + attributes
// -----------------------------
enum class Type { INT, FLOAT, VOID, STR };

struct Attr {
  Type type = Type::VOID;

  // For EXP/LVAL temporaries
  int reg = -1;

  // For identifiers and strings
  std::string str;

  // Backpatch lists
  std::vector<int> trueList;
  std::vector<int> falseList;
  std::vector<int> nextList;

  // Marker quad
  int quad = -1;

  // For function signatures
  std::vector<Type> paramTypes;
  std::vector<std::string> paramNames;

  // For call args
  std::vector<int> argRegs;            // regs carrying each arg value
  std::vector<std::string> argNames;   // "" for positional, name for named

  // For multi-decl: id, id, id...
  std::vector<std::string> names;
};

struct VarBinding {
  Type type = Type::VOID;
  int offset = 0;      // bytes from FP (I1). locals >= 0, params < 0
  int scopeDepth = 0;
};

struct FunctionInfo {
  Type retType = Type::VOID;
  std::vector<Type> paramTypes;
  std::vector<std::string> paramNames;

  bool isDefined = false;
  int startLineImplementation = 0;

  // All call sites (lines of JLINK instructions)
  std::vector<int> callLines;

  // Only those call sites not yet patched to a local implementation
  std::vector<int> unresolvedCallLines;
};

// -----------------------------
// Code buffer (1-based "line numbers")
// -----------------------------
class CodeBuffer {
public:
  int nextQuad() const;  // 1-based next line index
  void emit(const std::string& line);
  void backpatch(const std::vector<int>& list, int label);
  std::string str() const;

private:
  std::vector<std::string> m_lines;
};

// -----------------------------
// Globals used by lex/yacc
// -----------------------------
extern CodeBuffer g_code;
extern std::string g_curr_lexeme;

extern std::unordered_map<std::string, FunctionInfo> g_functions;

// yy line number (flex %option yylineno)
extern int yylineno;

// Final output (driver writes it to .rsk)
extern std::string g_final_output;

// -----------------------------
// Exit codes
// -----------------------------
constexpr int LEXICAL_ERROR = 1;
constexpr int SYNTAX_ERROR = 2;
constexpr int SEMANTIC_ERROR = 3;
constexpr int OPERATIONAL_ERROR = 4;

// -----------------------------
// Error helpers
// -----------------------------
void reportLexicalErrorAndExit(const std::string& lexeme, int line);
void reportSyntaxErrorAndExit(const std::string& lexeme, int line);
void reportSemanticErrorAndExit(const std::string& msg, int line);
void reportOperationalErrorAndExit(const std::string& msg);

std::string typeToString(Type t);

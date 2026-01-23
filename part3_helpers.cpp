#include "part3_helpers.hpp"

#include <iostream>
#include <sstream>
#include <cstdlib>

CodeBuffer g_code;
std::string g_curr_lexeme;

std::unordered_map<std::string, FunctionInfo> g_functions;

std::string g_final_output;

int CodeBuffer::nextQuad() const {
  return static_cast<int>(m_lines.size()) + 1;
}

void CodeBuffer::emit(const std::string& line) {
  m_lines.push_back(line);
}

void CodeBuffer::backpatch(const std::vector<int>& list, int label) {
  for (int quad : list) {
    if (quad <= 0 || quad > static_cast<int>(m_lines.size())) {
      reportOperationalErrorAndExit("Internal backpatch error: invalid quad index");
    }
    m_lines[quad - 1] += std::to_string(label);
  }
}

std::string CodeBuffer::str() const {
  std::ostringstream oss;
  for (size_t i = 0; i < m_lines.size(); ++i) {
    oss << m_lines[i];
    if (i + 1 < m_lines.size()) oss << "\n";
  }
  oss << "\n";
  return oss.str();
}

std::string typeToString(Type t) {
  switch (t) {
    case Type::INT: return "int";
    case Type::FLOAT: return "float";
    case Type::VOID: return "void";
    case Type::STR: return "string";
  }
  return "<?>"; // unreachable
}

void reportLexicalErrorAndExit(const std::string& lexeme, int line) {
  std::cerr << "Lexical error: " << lexeme << " in line " << line << std::endl;
  std::exit(LEXICAL_ERROR);
}

void reportSyntaxErrorAndExit(const std::string& lexeme, int line) {
  std::cerr << "Syntax error: " << lexeme << " in line " << line << std::endl;
  std::exit(SYNTAX_ERROR);
}

void reportSemanticErrorAndExit(const std::string& msg, int line) {
  std::cerr << "Semantic error: " << msg << " in line " << line << std::endl;
  std::exit(SEMANTIC_ERROR);
}

void reportOperationalErrorAndExit(const std::string& msg) {
  std::cerr << "Operational error: " << msg << std::endl;
  std::exit(OPERATIONAL_ERROR);
}

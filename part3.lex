%option noyywrap
%option yylineno

%{
  #include <string>
  #include "part3_helpers.hpp"

  // Robust include for bison header name
  #if __has_include("part3.tab.hpp")
    #include "part3.tab.hpp"
  #else
    #include "part3.tab.h"
  #endif

  #define SET_LEXEME() do { g_curr_lexeme = yytext; } while(0)

  static std::string unescape_string(const std::string& s) {
    // s includes the surrounding quotes
    std::string out;
    for (size_t i = 1; i + 1 < s.size(); ++i) {
      char c = s[i];
      if (c == '\\') {
        if (i + 1 >= s.size() - 1) {
          return ""; // invalid escape
        }
        char n = s[++i];
        if (n == 'n') out.push_back('\n');
        else if (n == 't') out.push_back('\t');
        else if (n == '\"') out.push_back('\"');
        else return ""; // invalid escape
      } else {
        out.push_back(c);
      }
    }
    return out;
  }
%}

DIGIT     [0-9]
ID        [A-Za-z_][A-Za-z0-9_]*
INTNUM    {DIGIT}+
REALNUM   {DIGIT}+"."{DIGIT}+
WS        [ \t\r]+

%%

{WS}                  { /* skip */ }
"//".*                { /* skip comment */ }
\n                    { /* flex updates yylineno */ }

"int"                 { SET_LEXEME(); return TK_INT; }
"float"               { SET_LEXEME(); return TK_FLOAT; }
"void"                { SET_LEXEME(); return TK_VOID; }

"if"                  { SET_LEXEME(); return TK_IF; }
"then"                { SET_LEXEME(); return TK_THEN; }
"else"                { SET_LEXEME(); return TK_ELSE; }
"while"               { SET_LEXEME(); return TK_WHILE; }
"do"                  { SET_LEXEME(); return TK_DO; }
"return"              { SET_LEXEME(); return TK_RETURN; }
"read"                { SET_LEXEME(); return TK_READ; }
"write"               { SET_LEXEME(); return TK_WRITE; }

"&&"                  { SET_LEXEME(); return TK_AND; }
"||"                  { SET_LEXEME(); return TK_OR; }
"!"                   { SET_LEXEME(); return TK_NOT; }

"=="|"<>"|"<="|">="|"<"|">"  {
  SET_LEXEME();
  yylval = new Attr();
  yylval->str = yytext;
  return TK_RELOP;
}

"+"|"-"               {
  SET_LEXEME();
  yylval = new Attr();
  yylval->str = yytext;
  return TK_ADDOP;
}

"*"|"/"               {
  SET_LEXEME();
  yylval = new Attr();
  yylval->str = yytext;
  return TK_MULOP;
}

"="                   { SET_LEXEME(); return '='; }
";"                   { SET_LEXEME(); return ';'; }
","                   { SET_LEXEME(); return ','; }
":"                   { SET_LEXEME(); return ':'; }
"("                   { SET_LEXEME(); return '('; }
")"                   { SET_LEXEME(); return ')'; }
"{"                   { SET_LEXEME(); return '{'; }
"}"                   { SET_LEXEME(); return '}'; }

{REALNUM}             {
  SET_LEXEME();
  yylval = new Attr();
  yylval->type = Type::FLOAT;
  yylval->str = yytext;
  return TK_REALNUM;
}

{INTNUM}              {
  SET_LEXEME();
  yylval = new Attr();
  yylval->type = Type::INT;
  yylval->str = yytext;
  return TK_INTNUM;
}

\"([^\\\"\n]|\\[nt\"])*
\"                     {
  // This rule is here only so flex doesn't treat stray quotes as separate tokens.
  // Actual complete strings are handled below.
  SET_LEXEME();
  reportLexicalErrorAndExit(g_curr_lexeme, yylineno);
}

\"([^\\\"\n]|\\[nt\"])*
\"([^\\\"\n]|\\[nt\"])*\"  {
  SET_LEXEME();
  std::string raw = yytext;
  std::string val = unescape_string(raw);
  if (val.empty() && raw != "\"\"") {
    reportLexicalErrorAndExit(raw, yylineno);
  }
  yylval = new Attr();
  yylval->type = Type::STR;
  yylval->str = val;
  return TK_STRING;
}

{ID}                  {
  SET_LEXEME();
  yylval = new Attr();
  yylval->str = yytext;
  return TK_ID;
}

.                     {
  SET_LEXEME();
  reportLexicalErrorAndExit(g_curr_lexeme, yylineno);
}

%%

%{
#include <cstdlib>
#include <cstring>
#include <iostream>

#include "part3_helpers.hpp"
#include "part3.tab.hpp"
%}

%option noyywrap yylineno nodefault
%option noinput nounput

ID            [A-Za-z][A-Za-z0-9_]*
INTEGERNUM    [0-9]+
REALNUM       [0-9]+\.[0-9]+
RELOP         (==|<>|<=|>=|<|>)
ADDOP         (\+|-)
MULOP         (\*|\/)
STR           \"([^\"\\\n\r]|\\[tn\"\\])*\"
BADSTR        \"([^\"\\\n\r]|\\.)*\"

WS            [ \t\r]+
COMMENT       \#.*

%%

{WS}                { /* skip */ }
{COMMENT}           { /* skip */ }
\n                  { /* yylineno updated automatically */ }

/* IMPORTANT: '//' is NOT a comment in this language.
   The tests expect it to be a lexical error on the full lexeme "//". */
"//"                {
                        std::cerr << "Lexical error: '" << yytext
                                  << "' in line number " << yylineno << "\n";
                        std::exit(LEXICAL_ERROR);
                    }

"int"               { return TK_INT; }
"float"             { return TK_FLOAT; }
"void"              { return TK_VOID; }
"if"                { return TK_IF; }
"then"              { return TK_THEN; }
"else"              { return TK_ELSE; }
"while"             { return TK_WHILE; }
"do"                { return TK_DO; }
"read"              { return TK_READ; }
"write"             { return TK_WRITE; }
"return"            { return TK_RETURN; }

"&&"                { return TK_AND; }
"||"                { return TK_OR; }
"!"                 { return TK_NOT; }
"="                 { return TK_ASSIGN; }

"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
","                 { return ','; }
";"                 { return ';'; }
":"                 { return ':'; }

{RELOP}             {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_RELOP;
                    }

{ADDOP}             {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_ADDOP;
                    }

{MULOP}             {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_MULOP;
                    }

{STR}               {
                        std::string s(yytext);
                        yylval.a = new Attr();
                        if (s.size() >= 2) yylval.a->str = s.substr(1, s.size() - 2);
                        else yylval.a->str.clear();
                        return TK_STR;
                    }

{BADSTR}            {
                        std::cerr << "Lexical error: '" << yytext
                                  << "' in line number " << yylineno << "\n";
                        std::exit(LEXICAL_ERROR);
                    }

{REALNUM}           {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_REALNUM;
                    }

{INTEGERNUM}        {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_INTEGERNUM;
                    }

{ID}                {
                        yylval.a = new Attr();
                        yylval.a->str = yytext;
                        return TK_ID;
                    }

.                   {
                        std::cerr << "Lexical error: '" << yytext
                                  << "' in line number " << yylineno << "\n";
                        std::exit(LEXICAL_ERROR);
                    }

%%

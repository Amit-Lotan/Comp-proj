%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string>
    #include <iostream>
    #include "part3_helpers.hpp"
    #include "part3.tab.hpp"
    using namespace std;
%}

%option yylineno
%option noyywrap

digit           ([0-9])
letter          ([a-zA-Z])
whitespace      ([\t\r\n ])
id              {letter}({letter}|{digit}|_)*
integer         {digit}+
real            {digit}+\.{digit}+
str             \"(\\.|[^"\n])*\"
relop           "=="|"<>"|"<"|"<="|">"|">="
addop           "+"|"-" 
mulop           "*"|"/"
assign          "="
and             "&&"
or              "||"
not             "!"
comment         "#"([^\r\n]|[^\n])*

%%

int             { return TINT; }
float           { return TFLOAT; }
void            { return TVOID; }
write           { return TWRITE; }
read            { return TREAD; }
while           { return TWHILE; }
do              { return TDO; }
if              { return TIF; }
then            { return TTHEN; }
else            { return TELSE; }
return          { return TRET; }

{relop}         { yylval.node = new Node(); yylval.node->str = yytext; return TRELOP; }
{addop}         { yylval.node = new Node(); yylval.node->str = yytext; return TADDOP; }
{mulop}         { yylval.node = new Node(); yylval.node->str = yytext; return TMULOP; }
{assign}        { return TASSIGN; }
{and}           { return TAND; }
{or}            { return TOR; }
{not}           { return TNOT; }

{integer}       { yylval.node = new Node(); yylval.node->str = yytext; return TNUM; }
{real}          { yylval.node = new Node(); yylval.node->str = yytext; return TREAL; }
{id}            { yylval.node = new Node(); yylval.node->str = yytext; return TID; }
{str}           { 
                    string s = yytext;
                    // Remove quotes
                    yylval.node = new Node(); 
                    yylval.node->str = s.substr(1, s.length()-2); 
                    return TSTR;
                }

[(){},:;]       { return yytext[0]; }

{comment}       ;
{whitespace}    ;

.               {
                    cerr << "Lexical error: '" << yytext << "' in line number " << yylineno << endl;
                    exit(LEXICAL_ERROR);
                }

%%

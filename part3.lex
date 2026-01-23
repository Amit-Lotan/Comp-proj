%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <map>
	#include <iostream>
	#include <string>
	#include "part3_helper.hpp"
	#include "part3.tab.hpp"
	using namespace std;
	extern "C" int yylex();
%}

%option yylineno
%option noyywrap
%option outfile="part3-lex.cpp"


digit   		([0-9])
letter  		([a-zA-Z])
signs			[(){},:;]
id 				{letter}({letter}|{digit}|_)*
num 			{digit}+	
str				\"(\\.|[^"\n])*\"
relop 			"=="|"<>"|"<"|"<="|">"|">="
addop 			"+"|"-"	
mulop 			"*"|"/"
assign 			"="
and 			"&&"
or				"||"
not				"!"
whitespace		([\t\r\n ])
comment 		"#"([^\r\n]|[^\n])*


%%

int8			return TINT8;
int16			return TINT16;
int32			return TINT32;
void			return TVOID;
write			return TWRITE;
read			return TREAD;
while			return TWHILE;
do				return TDO;
if				return TIF;
then			return TTHEN;
else			return TELSE;
return			return TRET;
{signs}			{ yylval.str = strdup(yytext);
				return yytext[0];}
{num}			{yylval.str = strdup(yytext);
				return TNUM;}
{str}			{char* string = yytext;
				string[yyleng-1] = 0;
				string++;
				yylval.str = strdup(string);
				return TSTR;}
{relop}			{yylval.str = strdup(yytext);
				return TRELOP;}
{addop}			{yylval.str = strdup(yytext);
				return TADDOP;}
{mulop}			{yylval.str = strdup(yytext);
				return TMULOP;}
{assign}		return TASSIGN;
{and}			return TAND;
{or}			return TOR;
{not}			return TNOT;
{id}			{yylval.str = strdup(yytext);
				return TID;}
{comment}		; /* Ignore */
{whitespace}	; /* Ignore */
.				{
					cerr << "Lexical error: '" << yytext << "' in line number " << yylineno << endl;
					exit(LEXICAL_ERROR);
				}
%%

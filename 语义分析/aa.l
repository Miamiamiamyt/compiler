%{
#include <stdio.h>
#include <string.h>	
#include <stdlib.h>
#include <string.h> 
#include "b.tab.h"
extern YYSTYPE yylval;
%}
%option yylineno
Space [ \n\t]
Ident [A-Za-z][A-Za-z0-9]*
Operator |[\{]|[\}]|["]|[<]|[>]|[,]|[\.]||[;]
%%
{Space} {;}
"write"  {printf("write ");return(WRITE);}
"read" {printf("read ");return(READ);}
"if" {printf("if ");return(IF);}
"then" {printf("then ");return(THEN);}
"while" {printf("while ");return(WHILE);}
"do" {printf("do ");return(DO);}
"call" {printf("call ");return(CALL);}
"begin" {printf("begin ");return(BEGIN1);}
"end" {printf("end ");return(END);}
"const" {printf("const ");return(CONST);}
"var" {printf("var ");return(VAR);}
"procedure" {printf("procedure ");return(PROCEDURE);}
"odd" {printf("odd ");return(ODD);}
{Ident} {strcpy(yylval.name,yytext);printf("ID ");return(ID);}//把id传回来
[+-]?[0-9]+ {yylval.val=atoi(yytext);printf("number ");return(NUM);}//把值传回来，atoi字符串转int 
":=" {printf("赋值 ");return(ASSIGNMENT);}
"+" {printf("加 ");return(PLUS);}
"-" {printf("减 ");return(MINUS);}
"*" {printf("乘 ");return(MULTIPLY);}
"/" {printf("除 ");return(DIVIDE);}
"[" {printf("[ ");return('[');}
"]" {printf("] ");return(']');}
"(" {printf("( ");return('(');}
")" {printf(") ");return(')');}
"{" {printf("{ ");return('{');}  
"}" {printf("} ");return('}');} 
">" {printf("大于 ");return(GT);}
"<" {printf("小于 ");return(LT);}
">=" {printf("大于等于 ");return(GE);}
"<=" {printf("小于等于 ");return(LE);}
"<>" {printf("不等于 ");return(NE);}
"==" {printf("等于 ");return(EQ);}
"=" {printf("= ");return('=');}
"#" {printf("# ");return('#');}
";" {printf("; ");return(';');}
"," {printf(", ");return(',');}
"." {printf(". ");return('.');}
%%
int yywrap(){
	return 1;
}

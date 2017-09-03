%{
#include<ctype.h>
#include<stdio.h>
extern int yylex();
extern int yyerror();	
%}
%token NUM
%token ID 
%token WRITE READ IF THEN WHILE DO CALL BEGIN END CONST VAR PROCEDURE ODD ASSIGNMENT GT LT GE LE NE EQ PLUS MINUS MULTIPLY DIVIDE
%left PLUS MINUS
%left MULTIPLY DIVIDE
%%
program: sprogram'.' {printf("程序::=分程序\n");}
        ;
sprogram: clsm sentence {printf("分程序::=常量说明部分 语句\n");}
         | blsm sentence {printf("分程序::=变量说明部分 语句\n");}
         | gcsm sentence {printf("分程序::=过程说明部分 语句\n");}
         | sentence {printf("分程序::= 语句\n");}
         ;
clsm: CONST cldy cldy1';' {printf("常量说明部分::= CONST 常量定义{,常量定义}\n");}
     ;
cldy: ID'='wfhzs {printf("常量定义::=标识符=无符号整数");}
    ;
cldy1: 
      | cldy1','cldy
      ;
blsm: VAR ID id1';' {printf("变量说明::=VAR 标识符{,标识符}\n");}
     ;
id1: 
    | id1 ',' ID 
    ;
gcsm: gcsb sprogram gcsm1'.' {printf("过程说明部分::=过程首部 分程序{;过程说明部分}\n");}
    ;
gcsm1: 
     | gcsm1';'gcsm
     ;
gcsb: PROCEDURE ID';' {printf("过程首部:=PROCEDURE 标识符\n");}
    ;
sentence: {printf("语句:=空\n");}
        | fzyj {printf("语句:=赋值语句\n");}
        | fhyj {printf("语句:=复合语句\n");}
        | tjyj {printf("语句:=条件语句\n");}
        | dxxhyj {printf("语句:=当型循环语句语句\n");}
        | gcdyyj {printf("语句:=过程调用语句\n");}
        | dyj {printf("语句:=读语句\n");}
        | xyj {printf("语句:=写语句\n");}
        ;
fzyj: ID ASSIGNMENT bds {printf("赋值语句::=标识符:=表达式\n");}
    ;
fhyj: BEGIN sentence yuju1 END {printf("复合语句::=BEGIN 语句{;语句} END\n");}
    ;
yuju1:
     | yuju1';'sentence
     ;
tjyj: IF tj THEN sentence {printf("条件语句::=IF 条件 THEN 语句\n");}
    ;
tj:  bds gxysf bds {printf("条件::=表达式 关系运算符 表达式\n");}
  | ODD bds {printf("条件::=ODD 表达式\n");}
  ;
bds: PLUS xiang x1 {printf("表达式::=+项{加法运算符 项}\n");}
   | MINUS xiang x1 {printf("表达式::=-项{加法运算符 项}\n");}
   | xiang x1  {printf("表达式::=项{加法运算符 项}\n");}
   ;
xiang: yinzi y1 {printf("项::=因子{乘法运算符 因子}\n");}
     ;
x1: 
  | x1 jfysf xiang
  ;
y1:
  | y1 cfysf yinzi
  ;
yinzi: '('bds')' {printf("因子::=(表达式)\n");}
      | ID {printf("因子::=标识符\n");}
      | wfhzs {printf("因子::=无符号整数\n");} 
      ;
wfhzs: NUM num1 {printf("无符号整数::=数字{数字}\n");}
     ;
num1:
     | num1 NUM
     ;
jfysf: PLUS
     | MINUS
     ;
cfysf: 	MULTIPLY
     | DIVIDE
     ;
gxysf: EQ
     | NE
     | LT
     | LE
     | GT
     | GE
     ;
dxxhyj: WHILE tj DO sentence {printf("当型循环语句::=WHILE 条件 DO 语句\n");}
      ;
gcdyyj: CALL ID {printf("过程调用语句::=CALL 标识符\n");}
      ;
dyj: READ '('ID id1')' {printf("读语句::=READ(标识符{,标识符})\n");}
   ;
xyj: WRITE '('bds bds1')' {printf("写语句::=WRITE(表达式{,表达式})\n");}
   ;
bds1: 
    | ','bds
    ;
%%
 int main(int argc, char** argv) 
{ 
  FILE* f = fopen("gcd.p", "r"); 
  if (!f) 
 { 
   yyerror("gcd.p"); 
   return 1; 
 } 
   yyrestart(f); 
   yyparse(); 
   return 0; 
}
char *s; 
int yyerror(s)
{   
  fprintf(stderr,"语法错误:%s\n",s);  
  return 0; 
}



         



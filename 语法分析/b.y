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
program: sprogram'.' {printf("����::=�ֳ���\n");}
        ;
sprogram: clsm sentence {printf("�ֳ���::=����˵������ ���\n");}
         | blsm sentence {printf("�ֳ���::=����˵������ ���\n");}
         | gcsm sentence {printf("�ֳ���::=����˵������ ���\n");}
         | sentence {printf("�ֳ���::= ���\n");}
         ;
clsm: CONST cldy cldy1';' {printf("����˵������::= CONST ��������{,��������}\n");}
     ;
cldy: ID'='wfhzs {printf("��������::=��ʶ��=�޷�������");}
    ;
cldy1: 
      | cldy1','cldy
      ;
blsm: VAR ID id1';' {printf("����˵��::=VAR ��ʶ��{,��ʶ��}\n");}
     ;
id1: 
    | id1 ',' ID 
    ;
gcsm: gcsb sprogram gcsm1'.' {printf("����˵������::=�����ײ� �ֳ���{;����˵������}\n");}
    ;
gcsm1: 
     | gcsm1';'gcsm
     ;
gcsb: PROCEDURE ID';' {printf("�����ײ�:=PROCEDURE ��ʶ��\n");}
    ;
sentence: {printf("���:=��\n");}
        | fzyj {printf("���:=��ֵ���\n");}
        | fhyj {printf("���:=�������\n");}
        | tjyj {printf("���:=�������\n");}
        | dxxhyj {printf("���:=����ѭ��������\n");}
        | gcdyyj {printf("���:=���̵������\n");}
        | dyj {printf("���:=�����\n");}
        | xyj {printf("���:=д���\n");}
        ;
fzyj: ID ASSIGNMENT bds {printf("��ֵ���::=��ʶ��:=���ʽ\n");}
    ;
fhyj: BEGIN sentence yuju1 END {printf("�������::=BEGIN ���{;���} END\n");}
    ;
yuju1:
     | yuju1';'sentence
     ;
tjyj: IF tj THEN sentence {printf("�������::=IF ���� THEN ���\n");}
    ;
tj:  bds gxysf bds {printf("����::=���ʽ ��ϵ����� ���ʽ\n");}
  | ODD bds {printf("����::=ODD ���ʽ\n");}
  ;
bds: PLUS xiang x1 {printf("���ʽ::=+��{�ӷ������ ��}\n");}
   | MINUS xiang x1 {printf("���ʽ::=-��{�ӷ������ ��}\n");}
   | xiang x1  {printf("���ʽ::=��{�ӷ������ ��}\n");}
   ;
xiang: yinzi y1 {printf("��::=����{�˷������ ����}\n");}
     ;
x1: 
  | x1 jfysf xiang
  ;
y1:
  | y1 cfysf yinzi
  ;
yinzi: '('bds')' {printf("����::=(���ʽ)\n");}
      | ID {printf("����::=��ʶ��\n");}
      | wfhzs {printf("����::=�޷�������\n");} 
      ;
wfhzs: NUM num1 {printf("�޷�������::=����{����}\n");}
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
dxxhyj: WHILE tj DO sentence {printf("����ѭ�����::=WHILE ���� DO ���\n");}
      ;
gcdyyj: CALL ID {printf("���̵������::=CALL ��ʶ��\n");}
      ;
dyj: READ '('ID id1')' {printf("�����::=READ(��ʶ��{,��ʶ��})\n");}
   ;
xyj: WRITE '('bds bds1')' {printf("д���::=WRITE(���ʽ{,���ʽ})\n");}
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
  fprintf(stderr,"�﷨����:%s\n",s);  
  return 0; 
}



         



%{
#include <stdio.h>
#include <string.h>	
#include <stdlib.h>
int i=0;
int k[13]={0};
char* key[13]={"write","read","if","then","while","do","call","begin","end","const","var","procedure","odd"};
char* con[20]={"0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"};
int c[20]={0};
char iden[20][5]={'\0'}; 
int I[20]={0};
char oper[25][2]={'\0'};
int o[25]={0};
char other[30][5]={'\0'};
int O[30]={0};
%}
Space [ \n\t]
Keyword write|read|if|then|while|do|call|begin|end|const|var|procedure|odd
Const ([0-9])+
Ident [A-Za-z][A-Za-z0-9]*
Operator [+]|[-]|[*]|[/]|[[]|[]]|[(]|[)]|[{]|[}]|[^]|[?]|["]|[$]|[<]|[>]|[,]|[.]|[=]|[>][=]|[<][=]|[=][=]|[!][=]|[;]
%%
{Const} {
  for(i=0;i<20;i++) {
    if(strcmp(yytext,con[i])==0) {
      c[i]++;
      break;
	}
  }
}
{Keyword} {
  for(i=0;i<13;i++) {
    if(strcmp(yytext,key[i])==0) {
     k[i]++;
     break;
  }
  }
}
{Ident} {
  int flag=0;
  for(i=0;i<20;i++) {
    if(strcmp(yytext,iden[i])==0) {
      I[i]++;
      flag=1;
	}
  }
  if(flag==0) {
    for(i=0;i<20;i++) {
    if(iden[i][0]=='\0') {
      strcpy(iden[i],yytext);
      I[i]++;
      break;
	}
  }
  }
}
{Space} {;}
{Operator} {
  int flag=0;
  for(i=0;i<25;i++) {
    if(strcmp(yytext,oper[i])==0) {
      o[i]++;
      flag=1;
	}
  }
  if(flag==0) {
    for(i=0;i<25;i++) {
    if(oper[i][0]=='\0') {
      strcpy(oper[i],yytext);
      o[i]++;
      break;
	}
  }
  }
}
. {
  int flag=0;
  for(i=0;i<30;i++) {
    if(strcmp(yytext,other[i])==0) {
      O[i]++;
      flag=1;
	}
  }
  if(flag==0) {
    for(i=0;i<30;i++) {
    if(other[i][0]=='\0') {
      strcpy(other[i],yytext);
      O[i]++;
      break;
	}
  }
  }
}
%%
void main(char argc,char* agrv[]) {
	yyin=fopen(argv[0],"r");
	yyout=fopen(argv[1],"w");
	  yylex();
    fprintf(yyout,"K:\n");
	for(i=0;i<13;i++) {
	  if(k[i]!=0) {
	     fprintf(yyout,"%s %d\n",key[i],k[i]);
	  }
	}
	fprintf(yyout,"\nC:\n");
	for(i=0;i<20;i++) {
      if(c[i]!=0) {
        fprintf(yyout,"%s %d\n",con[i],c[i]);
	  }
	}
	fprintf(yyout,"\nI:\n");
	for(i=0;i<20;i++) {
      if(I[i]!=0) {
        fprintf(yyout,"%s %d\n",iden[i],I[i]);
	  }
	}
	fprintf(yyout,"\nP:\n");
	for(i=0;i<25;i++) {
      if(o[i]!=0) {
        fprintf(yyout,"%s %d\n",oper[i],o[i]);
	  }
	}
	fprintf(yyout,"\nO:\n");
	for(i=0;i<30;i++) {
      if(O[i]!=0) {
        fprintf(yyout,"%s %d\n",other[i],O[i]);
	  }
	}
	fclose(yyin);
	fclose(yyout);
}
int yywrap(){
	return 1;
}

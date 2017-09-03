%{
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "lex.yy.c"
extern int yylex();
extern int yyerror();
#define insnum 300
#define fhbsize 1000
#define LIT 0
#define OPR 1
#define LOD 2
#define STO 3
#define CAL 4
#define INT 5
#define JMP 6
#define JPC 7
//FILE* fout;
int cur=0;//记录当前记录到第几条指令 

int display[10]={0};//display表，规定一个程序中最多嵌套10个过程

int curlevel=0;//记录当前过程所在的层次

int disa[10]={0};		//变量在运行栈中相对本过程基地址的偏移量

int curfhb=1;  //当前符号表元组号

int curidval; //当前标识符的值 

typedef struct instruction {
  int f;//功能码 
  int l;//层次差 
  int a;//功能区别 
}instruction;
instruction ins[insnum];//可以理解为运行栈 
typedef struct fuhaobiao {
  char name[14];//符号名称
  int type;//符号类型，1：const 2:var 3:procedure
  int level;//符号被引用的层次
  int val;//符号对应的值 
  int address;//变量在符号表中相对本过程基地址的偏移量 
}fuhaobiao;
fuhaobiao fhb[fhbsize];

%}

%union {
  int val;//数字和int型标识符 
  char name[14];//id的类型是string 
}

%token<val> NUM
%token<name> ID 
%token WRITE READ IF THEN WHILE DO CALL BEGIN1 END CONST VAR PROCEDURE ODD ASSIGNMENT GT LT GE LE NE EQ PLUS MINUS MULTIPLY DIVIDE
%left PLUS MINUS
%left MULTIPLY DIVIDE
%%
program: sprogram'.' {printf("程序::=分程序\n");}
        ;

record: {//记录非终结符 
       $<val>$ = cur;//记录当前代码号
     }
     ;
sprogram: record {
            curlevel++;//层次加一
            addins(JMP,0,0);//无条件跳转，后面回填 
          }
          spart {
            ins[$<val>1].a=cur;
            fhb[display[curlevel-1]-1].address=cur;//from 0
            addins(INT,0,disa[curlevel]);//在运行栈中为被调用的过程开辟a个单元的数据区
          }
          sentence 
          {
		    printf("分程序\n");
		    curlevel--;//从这个分程序出来，层次减一
		    addins(OPR,0,0);//返回过程调用并退栈 
			curfhb = display[curlevel];
		  }
         ;

spart:
     |clsm
     |blsm
     |gcsm
     |clsm blsm
     |blsm clsm
     |clsm gcsm
     |blsm gcsm
     |clsm blsm gcsm
     |blsm clsm gcsm
     ;
clsm: CONST cldy1';' {printf("常量说明部分::= CONST 常量定义{,常量定义}\n");}
     ;
cldy: ID'='wfhzs {
        printf("常量定义::=标识符=无符号整数");
	    curidval= $<val>3;
	    insertfhb(1,$1);
	    //printf("%s",fhb[curfhb].name);
	}
    ;
cldy1: cldy
      | cldy1','cldy
      ;
blsm: VAR id1';' {
        printf("变量说明::=VAR 标识符{,标识符}\n");
	  }
     ;
id1: id2 
    | id1 ',' id2 
    ;
id2: ID {
     insertfhb(2,$1);
     printf("%d",fhb[curfhb-1].type);
   }
   ;
gcsm: gcsb gcsm1 {printf("过程说明部分::=过程首部 分程序{;过程说明部分}\n");}
    | gcsm gcsb gcsm1
    ;
gcsb: PROCEDURE ID';' {
       printf("过程首部:=PROCEDURE 标识符\n");
       insertfhb(3,$2);
	 }
    ;
gcsm1: sprogram';'
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
fzyj: ID ASSIGNMENT bds {
        printf("赋值语句::=标识符:=表达式\n");
        int i = checkfhb($1);
	    if(i==-1||fhb[i].type!=2) {//不在符号表中或不是变量
		  printf("非法赋值！\n");
		  exit(0); 
	    }//if
	    addins(STO,curlevel-fhb[i].level,fhb[i].address)//将栈顶内容送入某变量单元中，就是把这个赋值过程写入运行栈 
	}
    ;
fhyj: BEGIN1 yuju1 END {printf("复合语句::=BEGIN 语句{;语句} END\n");}
    ;
yuju1: sentence
     | yuju1';'sentence
     ;
jump: { //记录非终结符，并且跳转 
      addins(JPC,0,0);//条件跳转，后面根据通过record记录的命令号回填跳转地址 
	}
	; 
tjyj: IF tj THEN record jump sentence {
        printf("条件语句::=IF 条件 THEN 语句\n");
	    ins[$<val>4].a=cur;
	}
    ;
tj:  bds EQ bds {printf("条件::=表达式 = 表达式\n");addins(OPR,0,8);}
  | bds NE bds {printf("条件::=表达式 <> 表达式\n");addins(OPR,0,9);}
  | bds LT bds {printf("条件::=表达式 < 表达式\n");addins(OPR,0,10);}
  | bds LE bds {printf("条件::=表达式 <= 表达式\n");addins(OPR,0,13);}
  | bds GT bds {printf("条件::=表达式 > 表达式\n");addins(OPR,0,12);}
  | bds GE bds {printf("条件::=表达式 >= 表达式\n");addins(OPR,0,11);}
  | ODD bds {printf("条件::=ODD 表达式\n");addins(OPR,0,6);}
  ;
bds: PLUS xiang {printf("表达式::=+项{加法运算符 项}\n");}
   | MINUS xiang {printf("表达式::=-项{加法运算符 项}\n");addins(OPR,0,1);}//取反 
   | xiang {printf("表达式::=项{加法运算符 项}\n");}
   | bds PLUS xiang {printf("表达式::=加法运算\n");addins(OPR,0,2);}//相加 
   | bds MINUS xiang {printf("表达式::=减法运算\n");addins(OPR,0,3);}//相减 
   ;
xiang: yinzi y1 {printf("项::=因子{乘法运算符 因子}\n");}
     ;
y1:
  | y1 MULTIPLY yinzi {addins(OPR,0,4);} 
  | y1 DIVIDE yinzi {addins(OPR,0,5);}
  ;
yinzi: '('bds')' {printf("因子::=(表达式)\n");}
      | ID {
	      printf("因子::=标识符\n");
	      int i = checkfhb($1);
	      if(i==-1||fhb[i].type==3) {
	        printf("该符号不存在!");
	        exit(0);
		  }//if
		  else if(fhb[i].type==1) {
		    addins(LIT,0,fhb[i].val);//LIT将常数值取到栈顶，
		  }
		  else {
		    addins(LOD,curlevel-fhb[i].level,fhb[i].address);//LOD将变量值取到栈顶 
	      }//else
		}
      | wfhzs {
	      printf("因子::=无符号整数\n");
		  addins(LIT,0,$<val>1);
		} 
      ;
wfhzs: NUM num1 {printf("无符号整数::=数字{数字}\n");}
     ;
num1:
     | num1 NUM
     ;
dxxhyj: WHILE record tj record jump DO sentence {
          printf("当型循环语句::=WHILE 条件 DO 语句\n");
		  addins(JMP,0,$<val>2);//无条件跳转到a地址
		  ins[$<val>4].a=cur; 
		}
      ;
gcdyyj: CALL ID {
          printf("过程调用语句::=CALL 标识符\n");
	      int i=checkfhb($2);
	      if(i==-1||fhb[i].type!=3) {//判断调用的是不是过程 
	        printf("无效调用！\n");
	        exit(0);
	      }//if 
	      addins(CAL,curlevel-fhb[i].level,fhb[i].address);//CAL 调用过程 
	   }
      ;
dyj: READ '('dyj1')' {printf("读语句::=READ(标识符{,标识符})\n");}
   ;
dyj1: ID {
	   int i=checkfhb($1);
	   //printf("%s",$1);
	   if(i==-1||fhb[i].type!=2) {//判断是不是变量
	     printf("该标识符不是变量！\n");
		 exit(0); 
       }//if
       addins(OPR,0,16);//从命令行读入一个输入置于栈顶
	   addins(STO,curlevel-fhb[i].level,fhb[i].address);//STO将栈顶内容送入某一变量单元中，就是把读入的值放入该变量的val中 
	 } 
    ;
xyj: WRITE '('bds1')' {
       printf("写语句::=WRITE(表达式{,表达式})\n");
	   addins(OPR,0,15);//屏幕输出换行 
	 }
   ;
bds1: bds {addins(OPR,0,14);}//栈顶值输出至屏幕}
    | bds1','bds {addins(OPR,0,14);} 
    ;
%%
int addins(int f,int l,int a) {
  if(cur>insnum) {
    printf("超出能记录的指令数\n");
    return -1;
  }
  else {
    ins[cur].f=f;
    ins[cur].l=l;
    ins[cur].a=a;
    cur++;
  }
  return cur;
}

int insertfhb(int type,char str[]) {//符号类型，1：const 2:var 3:procedure
  fhb[curfhb].type=type;
  strcpy(fhb[curfhb].name,str);
  switch(type) {
    case 1:{//const 
      fhb[curfhb].val=curidval;
      break;
	}//1
	case 2:{//var
	  fhb[curfhb].level=curlevel;
	  fhb[curfhb].address=disa[curlevel];//在运行栈中的偏移量 
	  disa[curlevel]++;
	  break;
    }//2
    case 3:{//procedure
      fhb[curfhb].level=curlevel;
      display[curlevel]=curfhb+1;
      break;
	}//3
  }//switch
  curfhb++;
  return 0;
}

int checkfhb(char name[]) {//查找被赋值的标识符是否已经在符号表中 
  int i;
  int flag=0;
  for(i=0;i<fhbsize;i++) {
    printf("%d  %s",i,fhb[i].name);
    if(strcmp(name,fhb[i].name)==0) {//该标识符已在符号表中 
      return i; 
      flag=1;
    }
  }
  if(flag==0) {
    printf("%d ",fhb[i].type);
    return -1;
  }
}

void interpret() 
{
    int p, b, t;
    instruction i;
    int s[fhbsize];

    printf("start pl0\n");
    t=0; b=1;  //t：数据栈顶指针；b：基地址；
    p=0;	// 指令指针
    s[1]=0; s[2]=0; s[3]=0;
    do {
        i=ins[p++];
        switch (i.f) 
        {
        case LIT: 
            t=t+1;
            s[t]=i.a;
            break;
        case OPR: 
            switch(i.a) 
            {
                case 0:
                    t=b-1;
                    p=s[t+3];
                    b=s[t+2];
                    break;
                case 1: 
                    s[t]=-s[t];
                    break;
                case 2: 
                    t=t-1;
                    s[t]=s[t] + s[t+1];
                    break;
                case 3:
                    t=t-1;
                    s[t]=s[t] - s[t+1];
                    break;
                case 4: 
                    t=t-1;
                    s[t]=s[t] * s[t+1];
                    break;
                case 5: 
                    t=t-1;
                    s[t]=s[t] / s[t+1];
                    break;
                case 6: 
                    s[t]=(s[t] % 2 == 1);
                    break;
                case 8: 
                    t=t-1;
                    s[t]=(s[t] == s[t+1]);
                    break;
                case 9:
                    t=t-1;
                    s[t]=(s[t] != s[t+1]);
                    break;
                case 10:
                    t=t-1;
                    s[t]=(s[t]<s[t+1]);
                    break;
                case 11: 
                    t=t-1;
                    s[t]=(s[t]>=s[t+1]);
                    break;
                case 12: 
                    t=t-1;
                    s[t]=(s[t]>s[t+1]);
                    break;
                case 13: 
                    t=t-1;
                    s[t]=(s[t]<=s[t+1]);
                    break;
                case 14: 
                    printf(" %d", s[t]);
                    t=t-1;
                    break;
                case 15: 
                    printf("\n");
                    break;
                case 16: 
                    t=t+1;
                    printf("请输入:");
                    scanf("%d", &s[t]);
                    break;
            }
		    break;
        case LOD: 
            t=t+1;
            s[t]=s[base(i.l, s, b)+i.a];
            break;
        case STO: 
            s[base(i.l, s, b)+i.a]=s[t];
            t=t-1;
            break;
        case CAL:
            s[t+1]=base(i.l, s, b);
            s[t+2]=b;
            s[t+3]=p;
            b=t+1;
            p=i.a;
            break;
        case INT: 
            t=t+i.a;
            break;
        case JMP: 
            p=i.a;
            break;
        case JPC: 
            if (s[t]==0) 
            {
                p=i.a;
            }
			//printf("---nextp %d  ----\n",p);
            t=t-1;
            break;
        }//end switch
    }while (p!=0);
}
int base(int l, int s[], int b) {//找基地址 
	int i = b;
	while(l > 0) {
		i = s[i];
		l--;
	}
	return i;
}
int showins() {//显示三元式 
	int i;
	char funcs[8][4] = {"LIT", "OPR", "LOD", "STO", "CAL", "INT", "JMP", "JPC"};
	for(i=0; i<cur; i++) {
		printf("%d: %s %d %d\n", i, funcs[ins[i].f], ins[i].l, ins[i].a);
	}
	return 0;
}
int main(int argc,char *argv[])
{
   char s1[18];
   scanf("%s",&s1);
   FILE *file=fopen(s1,"r");
   printf("%s",s1);
   yyin=file;
   int i;
   for(i = 0; i < 10; i++) {    
		disa[i] = 3;//1:动态链，2.返回地址 3.静态链   
		display[i] = 1;
	}  
    yyparse();
    showins();
	interpret();
    return 0;
} 
int yyerror(char *s)
{   
  fprintf(stderr,"语法错误:%s\n",s);  
  return 0; 
}



         



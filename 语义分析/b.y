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
int cur=0;//��¼��ǰ��¼���ڼ���ָ�� 

int display[10]={0};//display���涨һ�����������Ƕ��10������

int curlevel=0;//��¼��ǰ�������ڵĲ��

int disa[10]={0};		//����������ջ����Ա����̻���ַ��ƫ����

int curfhb=1;  //��ǰ���ű�Ԫ���

int curidval; //��ǰ��ʶ����ֵ 

typedef struct instruction {
  int f;//������ 
  int l;//��β� 
  int a;//�������� 
}instruction;
instruction ins[insnum];//�������Ϊ����ջ 
typedef struct fuhaobiao {
  char name[14];//��������
  int type;//�������ͣ�1��const 2:var 3:procedure
  int level;//���ű����õĲ��
  int val;//���Ŷ�Ӧ��ֵ 
  int address;//�����ڷ��ű�����Ա����̻���ַ��ƫ���� 
}fuhaobiao;
fuhaobiao fhb[fhbsize];

%}

%union {
  int val;//���ֺ�int�ͱ�ʶ�� 
  char name[14];//id��������string 
}

%token<val> NUM
%token<name> ID 
%token WRITE READ IF THEN WHILE DO CALL BEGIN1 END CONST VAR PROCEDURE ODD ASSIGNMENT GT LT GE LE NE EQ PLUS MINUS MULTIPLY DIVIDE
%left PLUS MINUS
%left MULTIPLY DIVIDE
%%
program: sprogram'.' {printf("����::=�ֳ���\n");}
        ;

record: {//��¼���ս�� 
       $<val>$ = cur;//��¼��ǰ�����
     }
     ;
sprogram: record {
            curlevel++;//��μ�һ
            addins(JMP,0,0);//��������ת��������� 
          }
          spart {
            ins[$<val>1].a=cur;
            fhb[display[curlevel-1]-1].address=cur;//from 0
            addins(INT,0,disa[curlevel]);//������ջ��Ϊ�����õĹ��̿���a����Ԫ��������
          }
          sentence 
          {
		    printf("�ֳ���\n");
		    curlevel--;//������ֳ����������μ�һ
		    addins(OPR,0,0);//���ع��̵��ò���ջ 
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
clsm: CONST cldy1';' {printf("����˵������::= CONST ��������{,��������}\n");}
     ;
cldy: ID'='wfhzs {
        printf("��������::=��ʶ��=�޷�������");
	    curidval= $<val>3;
	    insertfhb(1,$1);
	    //printf("%s",fhb[curfhb].name);
	}
    ;
cldy1: cldy
      | cldy1','cldy
      ;
blsm: VAR id1';' {
        printf("����˵��::=VAR ��ʶ��{,��ʶ��}\n");
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
gcsm: gcsb gcsm1 {printf("����˵������::=�����ײ� �ֳ���{;����˵������}\n");}
    | gcsm gcsb gcsm1
    ;
gcsb: PROCEDURE ID';' {
       printf("�����ײ�:=PROCEDURE ��ʶ��\n");
       insertfhb(3,$2);
	 }
    ;
gcsm1: sprogram';'
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
fzyj: ID ASSIGNMENT bds {
        printf("��ֵ���::=��ʶ��:=���ʽ\n");
        int i = checkfhb($1);
	    if(i==-1||fhb[i].type!=2) {//���ڷ��ű��л��Ǳ���
		  printf("�Ƿ���ֵ��\n");
		  exit(0); 
	    }//if
	    addins(STO,curlevel-fhb[i].level,fhb[i].address)//��ջ����������ĳ������Ԫ�У����ǰ������ֵ����д������ջ 
	}
    ;
fhyj: BEGIN1 yuju1 END {printf("�������::=BEGIN ���{;���} END\n");}
    ;
yuju1: sentence
     | yuju1';'sentence
     ;
jump: { //��¼���ս����������ת 
      addins(JPC,0,0);//������ת���������ͨ��record��¼������Ż�����ת��ַ 
	}
	; 
tjyj: IF tj THEN record jump sentence {
        printf("�������::=IF ���� THEN ���\n");
	    ins[$<val>4].a=cur;
	}
    ;
tj:  bds EQ bds {printf("����::=���ʽ = ���ʽ\n");addins(OPR,0,8);}
  | bds NE bds {printf("����::=���ʽ <> ���ʽ\n");addins(OPR,0,9);}
  | bds LT bds {printf("����::=���ʽ < ���ʽ\n");addins(OPR,0,10);}
  | bds LE bds {printf("����::=���ʽ <= ���ʽ\n");addins(OPR,0,13);}
  | bds GT bds {printf("����::=���ʽ > ���ʽ\n");addins(OPR,0,12);}
  | bds GE bds {printf("����::=���ʽ >= ���ʽ\n");addins(OPR,0,11);}
  | ODD bds {printf("����::=ODD ���ʽ\n");addins(OPR,0,6);}
  ;
bds: PLUS xiang {printf("���ʽ::=+��{�ӷ������ ��}\n");}
   | MINUS xiang {printf("���ʽ::=-��{�ӷ������ ��}\n");addins(OPR,0,1);}//ȡ�� 
   | xiang {printf("���ʽ::=��{�ӷ������ ��}\n");}
   | bds PLUS xiang {printf("���ʽ::=�ӷ�����\n");addins(OPR,0,2);}//��� 
   | bds MINUS xiang {printf("���ʽ::=��������\n");addins(OPR,0,3);}//��� 
   ;
xiang: yinzi y1 {printf("��::=����{�˷������ ����}\n");}
     ;
y1:
  | y1 MULTIPLY yinzi {addins(OPR,0,4);} 
  | y1 DIVIDE yinzi {addins(OPR,0,5);}
  ;
yinzi: '('bds')' {printf("����::=(���ʽ)\n");}
      | ID {
	      printf("����::=��ʶ��\n");
	      int i = checkfhb($1);
	      if(i==-1||fhb[i].type==3) {
	        printf("�÷��Ų�����!");
	        exit(0);
		  }//if
		  else if(fhb[i].type==1) {
		    addins(LIT,0,fhb[i].val);//LIT������ֵȡ��ջ����
		  }
		  else {
		    addins(LOD,curlevel-fhb[i].level,fhb[i].address);//LOD������ֵȡ��ջ�� 
	      }//else
		}
      | wfhzs {
	      printf("����::=�޷�������\n");
		  addins(LIT,0,$<val>1);
		} 
      ;
wfhzs: NUM num1 {printf("�޷�������::=����{����}\n");}
     ;
num1:
     | num1 NUM
     ;
dxxhyj: WHILE record tj record jump DO sentence {
          printf("����ѭ�����::=WHILE ���� DO ���\n");
		  addins(JMP,0,$<val>2);//��������ת��a��ַ
		  ins[$<val>4].a=cur; 
		}
      ;
gcdyyj: CALL ID {
          printf("���̵������::=CALL ��ʶ��\n");
	      int i=checkfhb($2);
	      if(i==-1||fhb[i].type!=3) {//�жϵ��õ��ǲ��ǹ��� 
	        printf("��Ч���ã�\n");
	        exit(0);
	      }//if 
	      addins(CAL,curlevel-fhb[i].level,fhb[i].address);//CAL ���ù��� 
	   }
      ;
dyj: READ '('dyj1')' {printf("�����::=READ(��ʶ��{,��ʶ��})\n");}
   ;
dyj1: ID {
	   int i=checkfhb($1);
	   //printf("%s",$1);
	   if(i==-1||fhb[i].type!=2) {//�ж��ǲ��Ǳ���
	     printf("�ñ�ʶ�����Ǳ�����\n");
		 exit(0); 
       }//if
       addins(OPR,0,16);//�������ж���һ����������ջ��
	   addins(STO,curlevel-fhb[i].level,fhb[i].address);//STO��ջ����������ĳһ������Ԫ�У����ǰѶ����ֵ����ñ�����val�� 
	 } 
    ;
xyj: WRITE '('bds1')' {
       printf("д���::=WRITE(���ʽ{,���ʽ})\n");
	   addins(OPR,0,15);//��Ļ������� 
	 }
   ;
bds1: bds {addins(OPR,0,14);}//ջ��ֵ�������Ļ}
    | bds1','bds {addins(OPR,0,14);} 
    ;
%%
int addins(int f,int l,int a) {
  if(cur>insnum) {
    printf("�����ܼ�¼��ָ����\n");
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

int insertfhb(int type,char str[]) {//�������ͣ�1��const 2:var 3:procedure
  fhb[curfhb].type=type;
  strcpy(fhb[curfhb].name,str);
  switch(type) {
    case 1:{//const 
      fhb[curfhb].val=curidval;
      break;
	}//1
	case 2:{//var
	  fhb[curfhb].level=curlevel;
	  fhb[curfhb].address=disa[curlevel];//������ջ�е�ƫ���� 
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

int checkfhb(char name[]) {//���ұ���ֵ�ı�ʶ���Ƿ��Ѿ��ڷ��ű��� 
  int i;
  int flag=0;
  for(i=0;i<fhbsize;i++) {
    printf("%d  %s",i,fhb[i].name);
    if(strcmp(name,fhb[i].name)==0) {//�ñ�ʶ�����ڷ��ű��� 
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
    t=0; b=1;  //t������ջ��ָ�룻b������ַ��
    p=0;	// ָ��ָ��
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
                    printf("������:");
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
int base(int l, int s[], int b) {//�һ���ַ 
	int i = b;
	while(l > 0) {
		i = s[i];
		l--;
	}
	return i;
}
int showins() {//��ʾ��Ԫʽ 
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
		disa[i] = 3;//1:��̬����2.���ص�ַ 3.��̬��   
		display[i] = 1;
	}  
    yyparse();
    showins();
	interpret();
    return 0;
} 
int yyerror(char *s)
{   
  fprintf(stderr,"�﷨����:%s\n",s);  
  return 0; 
}



         



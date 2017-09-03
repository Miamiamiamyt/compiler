#ifndef BISON_B_TAB_H
# define BISON_B_TAB_H

# ifndef YYSTYPE
typedef union{
	int val;
	char name[14];
} yystype;
#  define YYSTYPE yystype
#  define YYSTYPE_IS_TRIVIAL 1
# endif
# define	NUM	257
# define	ID	258
# define	WRITE	259
# define	READ	260
# define	IF	261
# define	THEN	262
# define	WHILE	263
# define	DO	264
# define	CALL	265
# define	BEGIN1	266
# define	END	267
# define	CONST	268
# define	VAR	269
# define	PROCEDURE	270
# define	ODD	271
# define	ASSIGNMENT	272
# define	GT	273
# define	LT	274
# define	GE	275
# define	LE	276
# define	NE	277
# define	EQ	278
# define	PLUS	279
# define	MINUS	280
# define	MULTIPLY	281
# define	DIVIDE	282

extern YYSTYPE yylval;

#endif /* not BISON_B_TAB_H */

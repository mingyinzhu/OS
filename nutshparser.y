	/*yacc file for io redirect*/
%{
#include <stdio.h>
#include <string.h>

int yylex();
int yyerror(char *s);
%}

	/*next step is to define grammar*/

%union
{
	char *string;	
}

%token IORIGHT IOLEFT IO_RR IO_LL IOAMPER IO_RRAMPER AMPER PIPE INVALID NEWLINE
%token <string> WORD
%start commands

%%

arguments:
	arguments WORD
	| 
	;

cmds_args:
	WORD arguments;
	;

pipes:
	pipes PIPE cmds_args
	|cmds_args
	;

io_redir:
	IO_RR WORD
	|IORIGHT WORD
	|IO_RRAMPER WORD
	|IOAMPER WORD
	|IOLEFT WORD
	;

all_io_redir:
	all_io_redir io_redir
	|
	;

background:
	AMPER
	|
	;

line:
	pipes all_io_redir background NEWLINE {printf("Nice grammar\n");}
	|NEWLINE {printf("You entered nothing\n");}
	|error NEWLINE{yyerrok;}
	;

commands:
	commands line
	|
	;
%%

int yyerror(char *s)
{
	fprintf(stderr,"error: %s\n",s);
	return 0;
}

int yywrap()
{
	return 1;
}

int main()
{
	yyparse();
	return 0;
}

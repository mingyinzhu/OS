	/*yacc file for io redirect*/
%{
#include <stdio.h>
#include <string.h>

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}

int yywrap()
{
	return 1;
}

int main()
{
	yyparse();
}

%}

%token IORIGHT IOLEFT IO_RR IO_LL IOAMPER AMPER PIPE INVALID WORD

	/*next step is to define grammar*/

%union
{
	char *string_value;
	
}

%%


%%

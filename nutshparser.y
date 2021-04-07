	/*yacc file for io redirect*/

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "nutshell.h"

int yylex();

void yyerror(const char *str)
{
	fprintf(stderr,"error: %s\n",str);
}

int yywrap()
{
	return 1;
}

int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

%}

%token IORIGHT IOLEFT IO_RR IO_LL IOAMPER AMPER PIPE INVALID WORD SETENV PENV END BYE UNSETENV CD ALIAS EOF1 UNALIAS

%union{
	char *string;
}

%type<string> WORD PENV CD BYE
	/*next step is to define grammar*/

%%

builtin_cmd:
		BYE END		{exit(1); return 1;}
		| SETENV WORD WORD END	{setEnv($2, $3); return 1;};
		| PENV END		{printEnv(); return 1;};
		| UNSETENV WORD END	{unsetEnv($2); return 1;};	
		| CD WORD END {chgDir($2); return 1;}
		| CD END {chgDir("~"); return 1;}
		| ALIAS WORD WORD END {runSetAlias($2, $3); return 1;}
		| ALIAS WORD PENV END {runSetAlias($2, $3); return 1;}
		| ALIAS WORD BYE END {runSetAlias($2, $3); return 1;}
		| ALIAS WORD CD END {runSetAlias($2, $3); return 1;}
		| ALIAS END {printAlias(); return 1;}
		| UNALIAS WORD END {unalias1 = false; rmAlias($2); return 1;}
		| EOF1 {exit(1); return 1;}
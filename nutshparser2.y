
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "nutshell.h"
#define BLU "\x1B[34m"
#define RESET "\x1B[0m"

int yylex();
int yyerror(const char *s);
int runSetAlias(char *name, char *word);
struct basic_command current_command;
%}
%define parse.error verbose
%union
{
	char *string;		
}
%token WORD SETENV PENV END BYE UNSETENV CD ALIAS EOF1 UNALIAS INVALID

/*
%type <string> pipes
%type <string> io_redir
%type <string> line
%type <string> arguments
%type<string> WORD PENV CD BYE
*/

%type<string> WORD PENV CD BYE
%token <string> IO_RR
%token <string> IORIGHT
%token <string> IO_RRAMPER
%token <string> IOLEFT
%token <string> IOAMPER
%token <string> AMPER
%token <string> PIPE
%token <string> IO_LL

%start commands
%%

builtin_cmd:
		BYE END		{exit(1); return 1;}
		| SETENV WORD WORD END	{alias2 = false; setEnv($2, $3); return 1;};
		| PENV END		{printEnv(); return 1;};
		| UNSETENV WORD END	{alias2 = false; unsetEnv($2); return 1;};	
		| CD WORD END {alias2 = false; chgDir($2); return 1;}
		| CD END {alias2 = false; chgDir("~"); return 1;}
		| ALIAS WORD WORD END {alias1 = false; runSetAlias($2, $3); return 1;}
		| ALIAS END {alias1 = false; printAlias(); return 1;}
		| UNALIAS WORD END {unalias1 = false; rmAlias($2); return 1;}
		| EOF1 {printf("\n"); exit(1); return 1;}

commands:
	commands builtin_cmd {return 1;	}
	|
	;
%%

int yyerror(const char *s)
{
	fprintf(stderr,"error: %s. Go back to kindergarten\n",s);
	return 0;
}

int yywrap()
{
	return 1;
}

int runSetAlias(char *name, char *word) {
	
	if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
	char *word2 = calloc(strlen(word)+1,1);
	strcpy(word2, word);
	while(ifAlias(word2)){
	
	if(strcmp(name, subAliases(word2)) == 0){
		free(word2);
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
	}
		char *word3 = calloc(strlen(subAliases(word2))+1,1);
		strcpy(word3, subAliases(word2));
		free(word2);
		word2 = calloc(strlen(word3)+1,1);
		strcpy(word2, word3);
		free(word3);
	}
	free(word2);
	for (int i = 0; i < aliasIndex; i++) {
		/*
		if((strcmp(aliasTable.name[i], word) == 0) && (strcmp(aliasTable.word[i], name) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		*/
		if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}



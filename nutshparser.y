
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
void copyCommand(struct basic_command* current_command);
%}
%define parse.error verbose
%union
{
	char *string;		
}
%token ERRSTDOUT ERRFILE WORD SETENV PENV END BYE UNSETENV CD ALIAS EOF1 UNALIAS INVALID

%type <string> pipes
%type <string> line
%type <string> arguments
%type<string> WORD PENV CD BYE

%token <string> IO_RR
%token <string> IORIGHT
%token <string> IO_RRAMPER
%token <string> IOLEFT
%token <string> IOAMPER
%token <string> AMPER
%token <string> PIPE
%token <string> IO_LL
%type <string> ERRSTDOUT
%type <string> ERRFILE

%start commands
%%

builtin_cmd:
		BYE	{exit(1);}
		| SETENV WORD WORD {setEnv($2, $3);};
		| PENV		{printEnv(); };
		| UNSETENV WORD {unsetEnv($2);};	
		| CD WORD {chgDir($2);}
		| CD {chgDir("~");}
		| ALIAS WORD WORD {alias1 = false; runSetAlias($2, $3);}
		| ALIAS {alias1 = false; printAlias(); }
		| UNALIAS WORD {unalias1 = false; rmAlias($2); }
		| EOF1 {exit(1); }

arguments:
	arguments WORD {
			 insert_arg(&current_command, $2);
	}
	|{}
	;

cmds_args:
	WORD arguments{
			current_command.name = strdup($1);
	}
	;

pipes:
	pipes PIPE cmds_args {			copyCommand(&current_command);
						indexCommands = indexCommands + 1;
						free(current_command.args);						
						/*printf("Command table: %d, %s, %d,%s,%s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args,command_table[indexCommands-1].args[0],command_table[indexCommands-1].args[1]);*/
						current_command.num_args = 1;
						
						
	}
	|cmds_args {				copyCommand(&current_command);
						indexCommands = indexCommands + 1;
						free(current_command.args);
						printf("Command table: %d, %s, %d,%s,%s,%s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args,command_table[indexCommands-1].args[0],command_table[indexCommands-1].args[1],command_table[indexCommands-1].args[2]);
						current_command.num_args = 1;
						
	}
	;

input_redir:
	IOLEFT WORD {
		input_name = strdup($2);
	}
	| {}
	;

output_redir:
	IO_RR WORD {
			output_name = strdup($2);
	}			
	|IORIGHT WORD {
			output_name = strdup($2);
	}
	|{}
	;

err_redir:
	ERRSTDOUT {
			err_name = strdup("2>&1");
	}
	|ERRFILE WORD {
			err_name =strdup($2);
	}
	|{}		
	;

all_io_redir:
	all_io_redir input_redir output_redir err_redir{ printf("entered redirect\n");}
	|
	;

background:
	AMPER
	|
	;

line:
	pipes input_redir output_redir err_redir background END {	printf("%s %s %s\n", input_name, output_name, err_name);
						execute_other_commands();
						return 1;
	}
	|END { return 1;
	}
	|error END{	yyerrok; return 1;
	}
	;

commands:
	commands builtin_cmd input_redir output_redir err_redir END{return 1;}
	|commands line {}
	|{}
	;
%%


int yyerror(const char *s)
{
	fprintf(stderr,"error: %s\n" ,s);
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

	for (int i = 0; i < aliasIndex; i++) {
		
		if((strcmp(aliasTable.name[i], word) == 0) && (strcmp(aliasTable.word[i], name) == 0)){
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

void copyCommand(struct basic_command* current_command){
		current_command -> args[0] = strdup(current_command->name);
		command_table[indexCommands].args = malloc((current_command -> num_args+1)*sizeof(char*));
		for(int i=0;i<current_command -> num_args;i++)
			command_table[indexCommands].args[i] = strdup(current_command -> args[i]);	
		command_table[indexCommands].args[current_command -> num_args] = NULL;
		command_table[indexCommands].name = strdup(current_command -> name);
		command_table[indexCommands].num_args = current_command -> num_args;
		}

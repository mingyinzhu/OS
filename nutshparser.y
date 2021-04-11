
%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "nutshell.h"
#define BLU "\x1B[34m"
#define RESET "\x1B[0m"

int yylex();
int yyerror(char *s);
int runSetAlias(char *name, char *word);
struct basic_command current_command;
%}
%define parse.error verbose
%union
{
	char *string;		
}
%token SETENV PENV END BYE UNSETENV CD ALIAS EOF1 UNALIAS

%type <string> pipes
%type <string> io_redir
%type <string> line
%type <string> arguments
%type<string> WORD PENV CD BYE

%token <string> WORD
%token <string> IO_RR
%token <string> IORIGHT
%token <string> IO_RRAMPER
%token <string> IOLEFT
%token <string> IOAMPER
%token <string> AMPER
%token <string> NEWLINE
%token <string> PIPE
%token <string> IO_LL

%start commands
%%

builtin_cmd:
		BYE END		{exit(1); return 1;}
		| SETENV WORD WORD END	{setEnv($2, $3); return 1;};
		| PENV END		{printEnv(); return 1;};
		| UNSETENV WORD END	{unsetEnv($2); return 1;};	
		| CD WORD END {chgDir($2); return 1;}
		| CD END {chgDir("~"); return 1;}
		| ALIAS WORD WORD END {alias1 = false; runSetAlias($2, $3); return 1;}
		| ALIAS END {alias1 = false; printAlias(); return 1;}
		| UNALIAS WORD END {unalias1 = false; rmAlias($2); return 1;}
		| EOF1 {exit(1); return 1;}

arguments:
	arguments WORD {current_command.num_args = 1;
			current_command.args = malloc(1);
			 insert_arg(&current_command, $2);
	}
	|{current_command.num_args = 1;
			current_command.args = malloc(1);
	}
	;

cmds_args:
	WORD arguments{
			current_command.name = $1;
	}
	;

pipes:
	pipes PIPE cmds_args {	current_command.args[0] = current_command.name;
						printf("%s, %s, %s\n", current_command.args[0],current_command.args[1],current_command.args[2]);
						struct basic_command perm_command;
						perm_command.name = current_command.name;
						perm_command.args = malloc(current_command.num_args*sizeof(char*));
						for(int i=0;i<current_command.num_args;i++)
							perm_command.args[i] = strdup(current_command.args[i]);
						perm_command.num_args = current_command.num_args;
						perm_command.input_name = current_command.input_name;
						perm_command.output_name = current_command.output_name;

						command_table[indexCommands] = perm_command;
						indexCommands = indexCommands + 1;
						free(current_command.args);						
						printf("Command table: %d, %s, %d,%s,%s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args,command_table[indexCommands-1].args[0],command_table[indexCommands].args[1]);
						current_command.num_args = 0;
						
						
	}
	|cmds_args { current_command.args[0] = current_command.name;
						printf("%s, %s, %s\n", current_command.args[0], current_command.args[1], current_command.args[2]);
						struct basic_command perm_command;
						perm_command.name = current_command.name;
						perm_command.args = malloc(current_command.num_args*sizeof(char*));
						for(int i=0;i<current_command.num_args;i++)
							perm_command.args[i] = strdup(current_command.args[i]);
						perm_command.num_args = current_command.num_args;
						perm_command.input_name = current_command.input_name;
						perm_command.output_name = current_command.output_name;
							
						command_table[indexCommands] = perm_command;
						indexCommands = indexCommands + 1;
						free(current_command.args);
						printf("Command table: %d, %s, %d,%s,%s,%s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args,command_table[indexCommands-1].args[0],command_table[indexCommands-1].args[1],command_table[indexCommands-1].args[2]);
						current_command.num_args = 0;
						
	}
	;

io_redir:
	IO_RR WORD {
			current_command.name = ">>";
			current_command.input_name = $1;
			current_command.output_name = $2;
			command_table[indexCommands] = current_command;
			indexCommands = indexCommands+1;			
			printf("Command table: %d, %s, %s, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].input_name,command_table[indexCommands-1].output_name);
	}
	|IORIGHT WORD {
			current_command.name = ">";
			current_command.input_name = $1;
			current_command.output_name = $2;			
			command_table[indexCommands] = current_command;
			indexCommands = indexCommands+1;			
			printf("Command table: %d, %s, %s, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].input_name,command_table[indexCommands-1].output_name);

	}
	|IO_RRAMPER WORD{
			current_command.name = ">>&";
			current_command.input_name = $1;
			current_command.output_name = $2;
			command_table[indexCommands] = current_command;
			indexCommands = indexCommands +1;			
			printf("Command table: %d, %s, %s, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].input_name,command_table[indexCommands-1].output_name);
			
	}
	|IOAMPER WORD {
			current_command.name = ">&";
			current_command.input_name = $1;
			current_command.output_name = $2;
			command_table[indexCommands] = current_command;
			indexCommands= indexCommands + 1;			
			printf("Command table: %d, %s, %s, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].input_name,command_table[indexCommands-1].output_name);
			
	}
	|IOLEFT WORD {
			current_command.name = "<";
			current_command.input_name = $2;
			current_command.output_name = $1;
			command_table[indexCommands] = current_command;
			indexCommands= indexCommands+1;			
			printf("Command table: %d, %s, %s, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].input_name,command_table[indexCommands-1].output_name);
			
	}
	;

all_io_redir:
	all_io_redir io_redir {}
	|
	;

background:
	AMPER
	|
	;

line:
	pipes all_io_redir background NEWLINE {printf("Nice grammar\n");
						execute_other_commands();
						return 1;
	}
	|NEWLINE {printf("You entered nothing\n");
	}
	|error NEWLINE{yyerrok;
	}
	;

commands:
	commands builtin_cmd {return 1;	}
	| commands line { return 1; }
	|
	;
%%

int yyerror(char *s)
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

int main()
{
	
	
	while(1){
		
		printf(BLU "Ready" RESET);
		printf("$:");
		indexCommands = 0;
		yyparse();
		
	}
	return 0;
}


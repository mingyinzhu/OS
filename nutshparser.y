
%{
#include <fcntl.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "nutshell.h"

int yylex();
int yyerror(const char *s);
int runSetAlias(char *name, char *word);
void copyCommand(struct basic_command* current_command);
void redirect();

/*
unalias_var = NULL;
directory = NULL;
unset_var = NULL;
var_env = NULL;
name_env = NULL;
bcommand_name = NULL;
var_alias = NULL;
name_alias = NULL;
*/

%}
%define parse.error verbose
%union
{
	char *string;		
}
%token ERRSTDOUT ERRFILE WORD SETENV PENV END CD BYE UNSETENV ALIAS EOF1 UNALIAS INVALID

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
		| SETENV WORD WORD {alias2 = false; bcommand_name =strdup("setenv"); var_env = strdup($2); name_env = strdup($3);};
		| PENV		{bcommand_name = strdup("printenv"); };
		| UNSETENV WORD {alias2 = false; bcommand_name = strdup("unsetenv"); unset_var = strdup($2);};	
		| CD WORD {alias2 = false; bcommand_name = strdup("chgDir"); directory = strdup($2);}
		| CD {alias2 = false; bcommand_name = strdup("chgDir"); directory = strdup("~");}
		| ALIAS WORD WORD {alias1 = false; bcommand_name = strdup("runSetAlias"); var_alias = strdup($2); name_alias= strdup($3);}
		| ALIAS {alias1 = false; bcommand_name =strdup("printAlias"); }
		| UNALIAS WORD {unalias1 = false; bcommand_name = strdup("rmAlias"); unalias_var = strdup($2); }
		| EOF1 {printf("\n"); exit(1); }

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
	pipes PIPE cmds_args {	
						copyCommand(&current_command);
						indexCommands = indexCommands + 1;
						free(current_command.args);						
						current_command.args=malloc(128*sizeof(char*));
						current_command.num_args = 1;
						
						
	}
	|cmds_args {				copyCommand(&current_command);
						indexCommands = indexCommands + 1;
						free(current_command.args);
						current_command.args=malloc(128*sizeof(char*));
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
	IO_RR WORD {	append = true;
			output_name = strdup($2);
	}			
	|IORIGHT WORD {	append=false;
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

background:
	AMPER {background = true;}
	| {background = false;}
	;

line:
	pipes input_redir output_redir err_redir background END {	
								execute_other_commands();
								
	}
	|END { 
	}
	|error END{	yyerrok; 
	}
	;

commands:
	commands builtin_cmd input_redir output_redir err_redir END { if(strcmp(bcommand_name,"setenv")==0){
										setEnv(var_env, name_env);
										free(var_env);
										free(name_env);
									}
									if(strcmp(bcommand_name, "printenv")==0){
										printEnv();
									}
									if(strcmp(bcommand_name, "unsetenv")==0){
										unsetEnv(unset_var);
										free(unset_var);
									}
									if(strcmp(bcommand_name ,"chgDir")==0){
										chgDir(directory);
										free(directory);
									}
									if(strcmp(bcommand_name, "runSetAlias")==0){
										runSetAlias(var_alias,name_alias);
										free(var_alias);
										free(name_alias);
									}
									if(strcmp(bcommand_name, "printAlias")==0){
										printAlias();
									}
									if(strcmp(bcommand_name,"rmAlias")==0){
										rmAlias(unalias_var);
										free(unalias_var);
									}
									free(bcommand_name);
								
									return 1;}
	|commands line {return 1;}
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

void copyCommand(struct basic_command* current_command){
		current_command->args[0] = strdup(current_command->name);
		command_table[indexCommands].args = malloc((current_command->num_args+1)*sizeof(char*));
		for(int i=0;i<current_command->num_args;i++){
			if(current_command->args[i]!= NULL)
				command_table[indexCommands].args[i] = strdup(current_command->args[i]);
		}	
		command_table[indexCommands].args[current_command->num_args] = NULL;
		command_table[indexCommands].name = strdup(current_command->name);
		command_table[indexCommands].num_args = current_command->num_args;
		}


	/*yacc file for io redirect*/
%{
#include <stdio.h>
#include <string.h>
#include "nutshell.h"

int yylex();
int yyerror(char *s);
struct basic_command current_command;

%}

	/*next step is to define grammar*/

%union
{
	char *string;		
}

/*%token IORIGHT IOLEFT IO_RR IO_LL IOAMPER IO_RRAMPER AMPER PIPE INVALID NEWLINE*/
%token <string> WORD
%start commands
%type <string> pipes
%type <string> all_io_redir
%type <string> line
%type <string> arguments
%token <string> IO_RR
%token <string> IORIGHT
%token <string> IO_RRAMPER
%token <string> IOLEFT
%token <string> IOAMPER
%token <string> AMPER
%token <string> NEWLINE
%token <string> PIPE
%token <string> IO_LL
%%

arguments:
	arguments WORD {printf("%s", $2); 
			insert_arg(&current_command, $2);
	}
	| 
	;

cmds_args:
	WORD arguments {printf("%s\n",$1); 
			current_command.name = $1;
			printf("%s\n",current_command.name);
	 }
	;

pipes:
	pipes PIPE cmds_args
	|cmds_args
	;

io_redir:
	IO_RR WORD {printf("%s", $1);}
	|IORIGHT WORD {printf("%s", $1);}
	|IO_RRAMPER WORD {printf("%s", $1);}
	|IOAMPER WORD {printf("%s", $1);}
	|IOLEFT WORD {printf("%s", $1);}
	;

all_io_redir:
	all_io_redir io_redir {printf("%s", $1);}
	|
	;

background:
	AMPER
	|
	;

line:
	pipes all_io_redir background NEWLINE {printf("Nice grammar\n");
						command_table[indexCommands] = current_command;
						indexCommands = indexCommands + 1;
						printf("Command table: %d, %s, %d\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args);
						current_command.num_args = 0;
						free(current_command.args);
	}
	|NEWLINE {printf("You entered nothing\n");
	}
	|error NEWLINE{yyerrok;
	}
	;

commands:
	commands line { return 1;
	}
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

int main()
{
	printf("Ready\n");

	while(1){
		current_command.args = malloc(10*sizeof(char));
		indexCommands = 0;
		yyparse();
		
	}
	return 0;
}


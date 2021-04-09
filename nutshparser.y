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
%type <string> io_redir
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
	arguments WORD {/*printf("%s", $2);*/ 
			current_command.args = malloc(100);
			insert_arg(&current_command, $2);
	}
	| 
	;

cmds_args:
	WORD arguments {
			current_command.name = $1;
	 }
	;

pipes:
	pipes PIPE cmds_args {command_table[indexCommands] = current_command;
						indexCommands = indexCommands + 1;
						printf("Command table: %d, %s, %d, %s\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args,command_table[indexCommands-1].args[0]);
						current_command.num_args = 0;
						free(current_command.args);
						
	}
	|cmds_args {command_table[indexCommands] = current_command;
						indexCommands = indexCommands + 1;
						printf("Command table: %d, %s, %d\n", indexCommands-1, command_table[indexCommands-1].name, command_table[indexCommands-1].num_args);
						current_command.num_args = 0;
						free(current_command.args);
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
		indexCommands = 0;
		yyparse();
		
	}
	return 0;
}


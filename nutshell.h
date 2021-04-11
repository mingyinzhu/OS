#include <stddef.h>
#include <stdlib.h>

struct basic_command
{
	int space_args; //size of args array
	int num_args; //number of arguments
	char* name; //name of command
	char** args; //array of arguments
	char* output_name;
	char* input_name;
};

struct basic_command command_table[128];
int indexCommands;

void insert_arg(struct basic_command* Command, char* arg);
void set_space(struct basic_command* Command, int size);
void execute_other_commands();

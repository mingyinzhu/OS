#include <stddef.h>
#include <stdlib.h>
#include "nutshell.h"
#include <stdio.h>
#include <unistd.h>

void insert_arg(struct basic_command* Command, char* arg)
{
	printf("You've entered the insert_arg function. Size of args: %d\n",(int)(sizeof(Command -> args)/sizeof(char)));
	Command -> num_args = Command -> num_args + 1;

	if(Command -> num_args > Command -> space_args)
	{
		Command -> args = realloc(Command -> args, sizeof(Command ->args)*2);
		Command -> space_args = sizeof(Command -> args);
	}
	Command -> args[Command -> num_args-1] = arg;
	Command -> args[sizeof(Command -> args) -1] = NULL;
}

void set_space(struct basic_command* Command, int size)
{
	Command -> space_args = size;
	Command -> args = malloc(size);
}

/*
void execute_other_commands()
{
	int temp_in = dup(0);
	int temp_out = dup(1);

	int input;
	if(commands_table[0].input_name){
	//	input = open(command_table[0].input_name);
	}
	else
	{
		input = dup(temp_in);
	}

	int pid;
	int output;

	for(int i =0;i< indexCommands;i++)
	{
		//loop through command table
		//char* name_command = command_table[i].name;
		dup2(input,0);
		close(input);
		if(i == indexCommands-1)
		{
			if(command_table[indexCommands-1].output_name)
			{
				output = open(command_table[indexCommands-1].output_name);
			}
			else
			{
				output = dup(temp_out);
			}
			}
			else
			{
				int pipe1[2];
				pipe(pipe1);
				output = pipe1[1];
				input = pipe1[0];
			}

			dup2(output,1);
			close(output);

			pid = fork();
			if(pid ==0 )
			{
				

			}
			}
		}
}
}*/

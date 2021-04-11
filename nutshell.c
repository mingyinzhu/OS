#include <stddef.h>
#include <stdlib.h>
#include "nutshell.h"
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

void insert_arg(struct basic_command* Command, char* arg)
{
	Command -> num_args = Command -> num_args + 1;
	if(Command -> num_args >=  Command -> space_args)
	{
		Command -> args = realloc(Command -> args, sizeof(Command ->args)*2);
		Command -> space_args = sizeof(Command -> args);
	}
	Command -> args[Command -> num_args-1] = arg;
	Command -> args[Command -> num_args] = NULL;
}


void execute_other_commands()
{
	printf("Entered execute_other_commands. There are %d commands.\n",indexCommands);
	char* env[] = {"PATH=/bin","PATH=/usr/bin",(char*)0};
	int std_in = dup(0);
	int std_out = dup(1);

	int input;

	pid_t pid;
	int output;

	for(int i =0;i< indexCommands;i++)
	{
		printf("Command %d: %s\n", i, command_table[i].name);
		if(command_table[i].input_name){
			input = open(command_table[0].input_name,O_RDONLY);
		}
		else
		{
			input = dup(std_in);
		}

		dup2(input,0);
		close(input);

		//if it's the last command, check for background option
		if(i == indexCommands-1)
		{
			if(command_table[i].output_name)
			{
				output = open(command_table[i].output_name,O_WRONLY);
			}
			else
			{
				output = dup(std_out);
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
			if(pid <0)
			{
				printf("fork error\n");
				continue;
			}
			if(pid ==0 )
			{
				char* path = malloc(strlen("/bin/")+strlen(command_table[i].name) +1);
				strcpy(path, "/bin/");
				strcat(path,command_table[i].name);
				execve(path,command_table[i].args,env);
				perror("execve");
				exit(1);

			}
	}

			dup2(std_in,0);
			dup2(std_out,1);
			close(std_in);
			close(std_out);

}



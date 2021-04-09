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

	if(Command -> num_args > Command -> space_args)
	{
		Command -> args = realloc(Command -> args, sizeof(Command ->args)*2);
		Command -> space_args = sizeof(Command -> args);
	}
	Command -> args[Command -> num_args-1] = arg;
	Command -> args[sizeof(Command -> args) -1] = NULL;
}


void execute_other_commands()
{
	char* env[] = {NULL};
	int std_in = dup(0);
	int std_out = dup(1);

	int input;
	if(command_table[0].input_name){
		input = open(command_table[0].input_name,O_RDONLY);
	}
	else
	{
		input = dup(std_in);
	}

	int pid;
	int output;

	for(int i =0;i< indexCommands;i++)
	{
		//loop through command table
		//char* name_command = command_table[i].name;
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
			if(pid ==0 )
			{
				char* command_path1 = "/bin/";
				char* command_path2 = "/usr/bin/";
				char* command_path = "";
				if(access(strcat("/bin/",command_table[i].name),F_OK)==0){
					strcat(command_path1,command_table[i].name);
					command_path = command_path1;
				}
				else if(access(strcat("/usr/bin/",command_table[i].name),F_OK)==0){
					strcat(command_path2,command_table[i].name);
					command_path = command_path2;
				}
				else{
					printf("invalid command");
					exit(1);
				}
				strcat(command_path,command_table[i].name);
				execve(command_path,command_table[i].args,env);
				perror("execve");
				exit(1);

			}
	}

			dup2(std_in,0);
			dup2(std_out,1);
			close(std_in);
			close(std_out);

}



<<<<<<< HEAD
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
	char* env[] = {"PATH=/bin","PATH=/usr/bin",(char*)0}; //I read that this doesn't matter when using execve. The path still has to be written out.
	int std_in = dup(0);
	int std_out = dup(1);

	int input;

	pid_t pid;
	int output;
	int new_fd[2];
	int old_fd[2];
	pipe(old_fd);
	for(int i =0;i< indexCommands;i++)
	{
		printf("Command %d: %s\n", i, command_table[i].name);

		if(i!=indexCommands-1)
		{
			pipe(new_fd);
		}

		pid = fork();

		if(pid <0)
		{
			printf("fork error\n");
			continue;
		}
		if(pid ==0 )
		{
			if(i!=0)
			{
				dup2(old_fd[0],0);
				close(old_fd[0]);
				close(old_fd[1]);
			}
			if(i!=indexCommands-1)
			{

				close(new_fd[0]);
				dup2(new_fd[1],1);
				close(new_fd[1]);
			}
			char* path = malloc(strlen("/bin/")+strlen(command_table[i].name) +1);
			strcpy(path, "/bin/");
			strcat(path,command_table[i].name);
			execve(path,command_table[i].args,env);
			perror("execve");
			exit(1);
		}
		else
		{

			if(i!=0)
			{

				close(old_fd[0]);
				close(old_fd[1]);
			}
			if(1!=indexCommands-1)
			{
				//dup2(&old_fd,&new_fd);
			}
		}
	}

			dup2(std_in,0);
			dup2(std_out,1);
			close(std_in);
			close(std_out);

}


=======
/*nutshell c file*/
>>>>>>> 997e97a9ef829096e74ab445bc5722b0de69fa00

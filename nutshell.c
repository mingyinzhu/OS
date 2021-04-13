#define _GNU_SOURCE
#include <stddef.h>
#include <stdlib.h>
#include "nutshell.h"
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>


#include <libgen.h>
#include <errno.h>
#include <fnmatch.h>
#include <dirent.h>
#include "nutshparser2.tab.h"

extern char **environ;

void insert_arg(struct basic_command* Command, char* arg)
{
	Command -> num_args = Command -> num_args + 1;
	if(Command -> num_args >  Command -> space_args)
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

int setEnv(char *var, char *word){

    char *cwd = get_current_dir_name();
    char *word1 = replaceString(word,"..", dirname(strdup(cwd)));
    char *word2 = replaceString(word1,".", cwd);
    char *word3 = replaceString(word2,"~", getenv("HOME"));
    setenv(var, word3, 1);
    free(word1);
    free(word2);
    free(word3);
    free(cwd);


    return 1;
}

int printEnv(){
   for(char **env = environ; *env; env++){
       puts(*env);
   }
    return 1;
}

int unsetEnv(char *var){
    if(strcmp(var, "HOME") == 0){
        printf("Can't unset HOME variable\n");
        return 1;
    }

    if(strcmp(var, "PATH") == 0){
        printf("Can't unset PATH variable\n");
        return 1;
    }

    unsetenv(var);
    return 1;
}

int chgDir(char *dir){
    char *dir2 = replaceString(dir,"~", getenv("HOME"));
    //chdir(dir2);
    if(chdir(dir2)!=0){
            fprintf(stderr, "cd %s failed: %s\n", dir2, strerror(errno));
            return 1;
        }
    setEnv("PWD", ".");
    setEnv("HOME",".");
    setEnv("PATH",".:/usr/bin");

    return 1;
}


char* replaceString(char* word, char *old, char *new1){

    int i = 0;
    int num = 0;
    int nlen = strlen(new1);
    int olen = strlen(old);

    for(i = 0; word[i] != '\0'; i++){
        if(strstr(&word[i], old) == &word[i]){
            num++;
            i += olen -1;
        }
    }

    int size = i+num*(nlen-olen)+1;
    char *updated = (char *)calloc(size,1);
    i = 0;

    while(*word){
        if(strstr(word, old) == word){
            strcpy(&updated[i], new1);
            i += nlen;
            word += olen;
        }
        else
        updated[i++] = *word++;
    }

    return updated;

}

int printAlias(){
    for(int i = 0; i<aliasIndex; i++){
        printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
    }
    return 1;
}

int rmAlias(char *word){
    for(int i = 0; i<aliasIndex; i++){
        if(strcmp(aliasTable.name[i], word) == 0){
            aliasIndex--;
            for(int j = i; j<aliasIndex; j++){
                strcpy(aliasTable.name[j], aliasTable.name[j+1]);
                strcpy(aliasTable.word[j], aliasTable.word[j+1]);
            }
            return 1;
        }
    }
    return 1;

}

int wildcard(char *word){
    DIR *d;
    struct dirent *dir;
    d = opendir(".");
    char files[128][100];
    int cnt = 0;
    if(d){
        while((dir = readdir(d)) != NULL){
            int res = fnmatch(word, dir->d_name, 0);
            if(res == 0){
                strcpy(files[cnt], dir->d_name);
                cnt++;
            }
        }
    }

    qsort(files, cnt, 100, newcmp);
    for(int i=0; i<cnt; i++){
        printf("%s\n", files[i]);
    }
    if(cnt == 0){
        char *word1 = delChar(word, '*');
        char *word2 = delChar(word1, '?');
        printf("%s\n", word2);
        free(word1);
        free(word2);
    }
    return 1;
}

int newcmp(const void *str1, const void *str2)
{
	return strcmp((const char*)str1, (const char*)str2);
}

char* delChar(char *word, char c){
    int j = 0;
    int len = strlen(word);
    char newword[len+1];

    for(int i=0;i<len;i++){
        if(word[i]!=c){
             newword[j] = word[i];
             j++;
        }
    }

    newword[j] = '\0';
    char *updated = (char *)calloc(len+1,1);
    strcpy(updated, newword);

    return updated;
}

int main()
{
    setEnv("HOME",".");
    setEnv("PATH",".:/usr/bin");

    aliasIndex = 0;

    //wildcard("?sup.*");

    while(1){
        printf("\033[0;35m");
        printf("FSMZ$ ");
        printf("\033[0m");
	indexCommands=0;
	current_command.num_args = 1;
	current_command.args = malloc(1);
        yyparse();
    }

    return 0;
}




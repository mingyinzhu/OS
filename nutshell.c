#define _GNU_SOURCE
#include <stddef.h>
#include <stdlib.h>
#include "nutshell.h"
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

#include <libgen.h>
#include <errno.h>
#include <fnmatch.h>
#include <dirent.h>
#include "nutshparser.tab.h"

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
	char* env[] = {"PATH=/bin","PATH=/usr/bin",(char*)0}; //I read that this doesn't matter when using execve. The path still has to be written out.

	pid_t pid;
	pid_t wpid;
	int status;
	int new_fd[2];
	int old_fd[2];
	pipe(old_fd);

	//redirection
	if(input_name){
		freopen(input_name, "r", stdin);
	}
	if(output_name){
		freopen(output_name,"w+", stdout);
	}
	if(err_name){
		if(err_name == "2>&1")
			dup2(1,2);
		else
			freopen(err_name, "w", stderr);
	}

	//execute commands and pipe
	for(int i =0;i< indexCommands;i++)
	{
		if(i!=indexCommands-1)
		{
			pipe(new_fd);
		}

		pid = fork();

		if(pid <0)
		{
			printf("fork error\n");
			//put something here to catch the error
		}
		if(pid ==0 ) //child
		{
			if(i!=0) //if not first command, close input side of old pipe, duplicate the stdin to the input side of old pipe
			{
				dup2(old_fd[0],0);
				close(old_fd[0]);
				close(old_fd[1]);
			}
			if(i!=indexCommands-1) //if not last command, close the output side of new pipe, duplicate stdout to the output side of new pipe
			{

				close(new_fd[0]);
				dup2(new_fd[1],1);
				close(new_fd[1]);
			}

			//execute command
			char* path = malloc(strlen("/bin/")+strlen(command_table[i].name) +1);
			strcpy(path, "/bin/");
			strcat(path,command_table[i].name);
			execve(path,command_table[i].args,env);
			perror("execve");
			exit(1);
		}//end of child

		else //parent
		{

			if(i!=0)
			{

				close(old_fd[0]);
				close(old_fd[1]);
			}
			if(i!=indexCommands-1)
			{
				dup2(old_fd[0],new_fd[0]);
				dup2(old_fd[1],new_fd[1]);
			}
		} //end of parent
	}//end of for loop
		while((wpid = wait(&status))>0);

			close(old_fd[0]);
			close(old_fd[1]);
			close(new_fd[0]);
			close(new_fd[1]);

}

int setEnv(char *var, char *word){
    if(expand == true){
    char *cwd = get_current_dir_name();
    char *word1 = replaceString(word,"..", dirname(strdup(cwd)));
    char *word2 = replaceString(word1,".", cwd);
    char *word3 = replaceString(word2,"~", getenv("HOME"));
    setenv(var, word3, 1);
    free(word1);
    free(word2);
    free(word3);
    free(cwd);
    }
    else{
	setenv(var, word, 1);
    }

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
	char *dir2;
    if(expand = true){
    	dir2 = strdup(replaceString(dir,"~", getenv("HOME")));
    }
    else{
    	dir2 = strdup(dir);
    }
    //chdir(dir2);
    if(chdir(dir2)!=0){
            fprintf(stderr, "cd %s failed: %s\n", dir2, strerror(errno));
            return 1;
        }
    setEnv("PWD", ".");
    //setEnv("HOME",".");
    //setEnv("PATH",".:/usr/bin");

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

char* wildcard(char *word){
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
    /*
    for(int i=0; i<cnt; i++){
        printf("%s\n", files[i]);
    }
    */
    if(cnt == 0){
       
        char *word1 = delChar(word, '*');
        char *word2 = delChar(word1, '?');
        strcpy(files[cnt], word2);
        cnt++;
        free(word1);
        free(word2);
    }
    
    char final[12927];
    strcpy(final, files[0]);
    for(int i = 1;i < cnt;i++){
        strcat(final," ");
        strcat(final, files[i]);
    }
    char *final2 = (char *)calloc(strlen(final) + 1,1);
    strcpy(final2, final);
    
    return final2;
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

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}

int main()
{
    expand = true;
    setEnv("HOME",".");
    setEnv("PATH",".:/usr/bin");

    aliasIndex = 0;
	printf("\033[0;35m");
        printf("FSMZ$ ");
        printf("\033[0m");

    //wildcard("?sup.*");

    while(1){
        indexCommands=0;
	current_command.num_args = 1;
	current_command.args = malloc(1);
        yyparse();
	printf("\033[0;35m");
        printf("FSMZ$ ");
        printf("\033[0m");
 }

    return 0;
}




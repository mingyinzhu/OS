/*nutshell c file*/
#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <libgen.h>
#include <unistd.h>
#include <errno.h>
#include "nutshell.h"
#include "nutshparser.tab.h"

extern char **environ;

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


int main()
{
    setEnv("HOME",".");
    setEnv("PATH",".:/usr/bin");

    aliasIndex = 0;

    while(1){
        yyparse();
    }

    return 0;
}
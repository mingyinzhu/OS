#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>

struct basic_command
{
	int space_args; //size of args array
	int num_args; //number of arguments
	char* name; //name of command
	char** args; //array of arguments
};

struct basic_command command_table[128];
int indexCommands;
char* input_name;
char* output_name;
char* err_name;
bool background;
bool append;
struct basic_command current_command;
bool expand;

void insert_arg(struct basic_command* Command, char* arg);
void execute_other_commands();

int setEnv(char *var, char *word);
int printEnv();
int unsetEnv(char *var);
char* replaceString(char* word, char *old, char *new1);
int chgDir(char *dir);
int printAlias();
int rmAlias(char *word);
char* wildcard(char *word);
int newcmp(const void *str1, const void *str2);
char* delChar(char *word, char c);
char* subAliases(char* name);
bool ifAlias(char* name);

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct aTable aliasTable;

int aliasIndex;
bool unalias1;
bool alias1;
bool alias2;

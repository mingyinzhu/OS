
#include <stdbool.h>

int setEnv(char *var, char *word);
int printEnv();
int unsetEnv(char *var);
char* replaceString(char* word, char *old, char *new1);
int chgDir(char *dir);
int printAlias();
int rmAlias(char *word);
int wildcard(char *word);
int newcmp(const void *str1, const void *str2);
char* delChar(char *word, char c);

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct aTable aliasTable;

int aliasIndex;
bool unalias1;
bool alias1;
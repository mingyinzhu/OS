
int setEnv(char *var, char *word);
int printEnv();
int unsetEnv(char *var);
char* replaceString(char* word, char *old, char *new1);
int chgDir(char *dir);

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct aTable aliasTable;

int aliasIndex;
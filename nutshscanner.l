	/*scan for io redirect*/

%{
#include "nutshparser.tab.h"
#include "nutshell.h"
#include <string.h>
#include <stdbool.h>

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

%}

%%

\n	{return END;}
">"	{return IORIGHT;}
"<"	{return IOLEFT;}
">>"	{return IO_RR;}
"<<"	{return IO_LL;}
">&"	{return IOAMPER;}
"|"	{return PIPE;}
"&"	{return AMPER;}
[ \t]	{	/*do nothing, ignore spaces and tabs*/}
unsetenv {return UNSETENV;}
setenv {return SETENV;}
printenv {yylval.string = strdup("printenv"); return PENV;}
bye {yylval.string = strdup("bye"); return BYE;}
cd {yylval.string = strdup("cd"); return CD;}
unalias {unalias1 = true; return UNALIAS;}
alias {return ALIAS;}
<<EOF>> {return EOF1;}

 /*[^ \t\n][^ \t\n]*	{yylval.string = strdup(yytext);
			return WORD;
			
			} */
[^ \t\n][^ \t\n]* {if(ifAlias(yytext) && !unalias1) {
                        //printf("yytext before sub: %s\n", yytext);
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           	free( yycopy );
                    } else {
                        //printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return WORD;
                    };
				}

.	{	/*invalid token*/
		return INVALID;}


%%

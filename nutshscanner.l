	/*scan for io redirect*/

%{
#include "nutshparser2.tab.h"
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
">>&"	{return IO_RRAMPER;}
"|"	{return PIPE;}
"&"	{return AMPER;}
[ \t]	{	/*do nothing, ignore spaces and tabs*/}
unsetenv {return UNSETENV;}
setenv {return SETENV;}
printenv {yylval.string = strdup("printenv"); if(alias1) return WORD; else return PENV;}
bye {yylval.string = strdup("bye"); if(alias1) return WORD; else return BYE;}
cd {yylval.string = strdup("cd"); if(alias1) return WORD; else return CD;}
unalias {unalias1 = true; return UNALIAS;}
alias {alias1 = true; return ALIAS;}
<<EOF>> {return EOF1;}

\$\{[ .A-Za-z0-9!\/_-][ .A-Za-z0-9!\/_-]*\}	{yylval.string = strndup(yytext+2,yyleng-3);
						printf("%s\n", yylval.string);
						}
\"[[ .A-Za-z0-9!\/_-][ .A-Za-z0-9!\/_-]*\"	{ yylval.string = strndup(++yytext, yyleng-2);
						if(ifAlias(yylval.string) && !unalias1 && !alias1) {
							char *yycopy = strdup( subAliases(yylval.string) );
							for ( int i = strlen(subAliases(yylval.string)) - 1; i >= 0; --i )
								unput( yycopy[i] );
							free( yycopy );
                   } 
		    else {
            
                      return WORD;
                   }; 
					}

[.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*		{if(ifAlias(yytext) && !unalias1 && !alias1) {
							char *yycopy = strdup( subAliases(yytext) );
							for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
								unput( yycopy[i] );
							free( yycopy );
                    } 
						else {
							yylval.string = strdup(yytext);
							return WORD;
                    };
					}
			
.	{	/*invalid token*/
		return INVALID;}
%%

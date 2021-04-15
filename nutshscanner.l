	/*scan for io redirect*/

%{
#include "nutshparser.tab.h"
#include "nutshell.h"
#include <string.h>
#include <stdbool.h>

int yyerrorlex (const char*s){
	printf("%s\n", s);
	return 0;
}

%}

%%

\n	{return END;}
">"	{return IORIGHT;}
"<"	{return IOLEFT;}
">>"	{return IO_RR;}
">&"	{return IOAMPER;}
"2>"	{return ERRFILE;}
"2>&1"	{return ERRSTDOUT;}
"|"	{return PIPE;}
"&"	{return AMPER;}
[ \t]	{	/*do nothing, ignore spaces and tabs*/}
unsetenv {alias2 = true; return UNSETENV;}
setenv {alias2 = true; return SETENV;}
printenv {yylval.string = strdup("printenv"); if(alias1) return WORD; else return PENV;}
bye {yylval.string = strdup("bye"); if(alias1) return WORD; else return BYE;}
cd {alias2 = true; yylval.string = strdup("cd"); if(alias1) return WORD; else return CD;}
unalias {unalias1 = true; return UNALIAS;}
alias {alias1 = true; return ALIAS;}
<<EOF>> {return EOF1;}

\$\{[ \$~:.A-Za-z0-9!\/_-][ \$~:.A-Za-z0-9!\/_-]*\}	{
						char* env_var = strndup(yytext+2, yyleng-3);
						char* env_name = getenv(env_var);
						if(env_name!=NULL){
							yylval.string = strdup(env_name);
							num_words = num_words + 1;
							return WORD;
						}
						else{
							printf("Could not substitute variable\n");
						}
						}
[\"\'][[ \$~:.A-Za-z0-9!\/_-][ \$~:.A-Za-z0-9!\/_-]*[\"\']	{ expand = false;
								yylval.string = strndup(yytext+1, yyleng-2);
								num_words = num_words + 1;
								if(ifAlias(yylval.string) && !unalias1 && !alias1 && !alias2 && num_words==1) {
									char *yycopy = strdup( subAliases(yylval.string) );
									for ( int i = strlen(subAliases(yylval.string)) - 1; i >= 0; --i )
										unput( yycopy[i] );
									free( yycopy );
								} 
								else {
            
									return WORD;
								}; 
							}

[=+\?\*~:.A-Za-z0-9!\/_-][=+\?\*~:.A-Za-z0-9!\/_-]*	{	num_words = num_words + 1;
								expand = true;
								if(ifAlias(yytext) && !unalias1 && !alias1 && !alias2 && num_words == 1) {
								char *yycopy = strdup( subAliases(yytext) );
								for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
									unput( yycopy[i] );
								free( yycopy );
							}	 
						else {
							if(strcmp(yytext,wildcard(yytext)) == 0){
								yylval.string = strdup(yytext);
								return WORD;	
							}
							else{
								char *yycopy2 = strdup( wildcard(yytext) );
							for ( int i = strlen(wildcard(yytext)) - 1; i >= 0; --i )
								unput( yycopy2[i] );
							free( yycopy2 );
							}
							
						    };
					}
			
.	{ return INVALID; }

%%

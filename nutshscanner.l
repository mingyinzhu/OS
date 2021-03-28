	/*scan for io redirect*/

%{
#include "y.tab.h"
#include <string.h>
%}

%%

\n	{return NEWLINE;}
">"	{return IORIGHT;}
"<"	{return IOLEFT;}
">>"	{return IO_RR;}
"<<"	{return IO_LL;}
">&"	{return IOAMPER;}
"|"	{return PIPE;}
"&"	{return AMPER;}
[ \t]	{	/*do nothing, ignore spaces and tabs*/}
[^ \t\n][^ \t\n]*	{yylval.string_val = strdup(yytext);
			return WORD;
			/*need to fix later to allow filenames to have numbers*/
			}
.	{	/*invalid token*/
		return INVALID;}


%%


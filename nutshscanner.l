	/*scan for io redirect*/

%{
#include "nutshparser.tab.h"
#include <string.h>
%}

%%

\n	{return NEWLINE;}
">"	{return IORIGHT;}
"<"	{return IOLEFT;}
">>"	{return IO_RR;}
"<<"	{return IO_LL;}
">&"	{return IOAMPER;}
">>&"	{return IO_RRAMPER;}
"|"	{return PIPE;}
"&"	{return AMPER;}
[ \t]	{	/*do nothing, ignore spaces and tabs*/}
[.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*	{yylval.string = strdup(yytext);
			return WORD;
			/*need to fix later to allow filenames to have numbers*/
			}
%%


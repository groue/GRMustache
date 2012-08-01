%{
#include <stdio.h>
#include "GRMustacheExpression.tab.h"
%}

%%
[_a-zA-Z0-9]+[?!]?       return ID;
[ \t\n\t]+               return WS;
.                        return IMPLICIT_ENUMERATOR;
%%

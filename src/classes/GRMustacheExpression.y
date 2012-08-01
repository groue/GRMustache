%{
%}

%token WS ID

[ \r\n\t]* { return WS; }
[_a-zA-Z0-9]+ { return ID; }

%%

input : expression;

expression : WS* (identifierExpression | scopedExpression | filterExpression) WS*;

identifierExpression : ID;

scopedExpression : ('.' | '.' ID | expression '.' ID);

filterExpression : expression '(' expression ')';

%%

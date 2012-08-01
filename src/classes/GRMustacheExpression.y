%{
#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
int yylex(void);  
int yywrap();
void yyerror(const char *str);
%}

%token ID
%token WS
%token IMPLICIT_ENUMERATOR

%start	input 

%%

input : expression { exit(0); };

expression : scopableExpression { printf("expression\n"); }
           | nonScopableExpression { printf("expression\n"); };

nonScopableExpression : implicitEnumeratorExpression { printf("nonScopableExpression\n"); };

scopableExpression : identifierExpression { printf("scopableExpression\n"); }
                   | scopedExpression { printf("scopableExpression\n"); }
                   | filterExpression { printf("scopableExpression\n"); };

implicitEnumeratorExpression : IMPLICIT_ENUMERATOR { printf("implicitEnumeratorExpression\n"); };

identifierExpression : ID { printf("identifierExpression\n"); };

scopedExpression : '.' ID { printf("scopedExpression\n"); }
                 | scopableExpression '.' ID { printf("scopedExpression\n"); };

filterExpression : expression '(' expression ')' { printf("filterExpression\n"); };

%%

void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}

int yywrap()
{
        return 1;
}

int main()
{
    yyparse();
    return 0;
}


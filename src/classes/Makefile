GRMustacheExpressions: GRMustacheExpression.yy.c GRMustacheExpression.tab.c
	cc -ll -o GRMustacheExpressions GRMustacheExpression.yy.c GRMustacheExpression.tab.c

GRMustacheExpression.yy.c: GRMustacheExpression.tab.h GRMustacheExpression.l
	lex -o GRMustacheExpression.yy.c  GRMustacheExpression.l

GRMustacheExpression.tab.c: GRMustacheExpression.y
	bison -d GRMustacheExpression.y

GRMustacheExpression.tab.h: GRMustacheExpression.tab.c

clean:
	rm GRMustacheExpression.tab.c
	rm GRMustacheExpression.tab.h
	rm GRMustacheExpression.yy.c
	rm GRMustacheExpressions

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern int yyparse(void);
extern int yylex(void);
void yyerror(const char *s);

/* Stack for production rules */
char **productionStack = NULL; 
int stackTop = 0;              
int stackCapacity = 0;         

void initializeStack(int initialSize) {
    productionStack = malloc(sizeof(char*) * initialSize);
    if (!productionStack) { fprintf(stderr, "Memory allocation failed\n"); exit(1); }
    stackCapacity = initialSize;
    stackTop = 0;
}

void addToStack(const char *production) {
    if (stackTop >= stackCapacity) {
        stackCapacity *= 2;
        productionStack = realloc(productionStack, sizeof(char*) * stackCapacity);
        if (!productionStack) { fprintf(stderr, "Memory reallocation failed\n"); exit(1); }
    }
    productionStack[stackTop++] = strdup(production);
}

void generateOutput() {
    if (stackTop == 0) { printf("\nStack empty.\n"); return; }
    FILE *fp = fopen("production_stack.txt", "w");
    if (!fp) { fprintf(stderr, "File open failed\n"); return; }
    printf("\nStack (top→bottom):\n");
    for(int i=stackTop-1, num=0; i>=0; i--, num++){
        printf("%d: %s\n", num, productionStack[i]);
        fprintf(fp, "%d: %s\n", num, productionStack[i]);
    }
    fclose(fp);
    printf("\nFile write complete: production_stack.txt\n");
}

void freeStack() {
    for(int i=0;i<stackTop;i++) free(productionStack[i]);
    free(productionStack);
    productionStack = NULL;
    stackTop = 0;
    stackCapacity = 0;
}

%}

/* Token types */
%union {
    int integerValue;
    double floatValue;
    char *stringValue;
}

%token LPAREN 
%token RPAREN 
%token LBRACE 
%token RBRACE 
%token LBRACKET 
%token RBRACKET 
%token SEMI 
%token COMMA 
%token COLON 
%token DOT
%token ARROW

%token ADD 
%token SUB 
%token MULTI 
%token DIVIDE 
%token ASSIGN 
%token EQ 
%token NEQ 
%token LT 
%token GT 
%token LEQ 
%token GEQ 
%token OR 
%token AND 
%token NOT

%token IF 
%token ELSE 
%token FLOAT
%token FUNC
%token IMPLEMENT 
%token CLASS 
%token ATTRIBUTE 
%token INTEGER 
%token PRIVATE 
%token PUBLIC 
%token READ 
%token RETURN 
%token SELF 
%token CONSTRUCT 
%token THEN 
%token LOCAL 
%token VOID 
%token WHILE
%token WRITE 
%token ISA

%token <stringValue> ID 
%token <stringValue> UNKNOWN 
%token <interValue> INTLIT 
%token <floatValue> FLOATLIT 
%token COMMENT_INLINE 
%token COMMENT_BLOCK  

%start prog

%%

prog :
      blockSeq { addToStack("prog -> blockSeq"); }
    ;

blockSeq :
      classOrImplOrFunc blockSeq { addToStack("blockSeq -> classOrImplOrFunc blockSeq"); }
    | /* empty */ { addToStack("blockSeq -> ε"); }
    ;

classOrImplOrFunc :
      classDecl { addToStack("classOrImplOrFunc -> classDecl"); }
    | implDef { addToStack("classOrImplOrFunc -> implDef"); }
    | funcDef { addToStack("classOrImplOrFunc -> funcDef"); }
    ;

classDecl :
      CLASS ID extendsClause LBRACE vMemberBlock RBRACE SEMI
      { addToStack("classDecl -> CLASS ID extendsClause LBRACE vMemberBlock RBRACE SEMI"); }
    ;

extendsClause :
      ISA ID interfaceList { addToStack("extendsClause -> ISA ID interfaceList"); }
    | /* empty */ { addToStack("extendsClause -> ε"); }
    ;

interfaceList :
      COMMA ID interfaceList { addToStack("interfaceList -> COMMA ID interfaceList"); }
    | funcDef interfaceList { addToStack("interfaceList -> funcDef interfaceList"); }
    | /* empty */ { addToStack("interfaceList -> ε"); }
    ;

vMemberBlock :
      visibility memberDecl vMemberBlock { addToStack("vMemberBlock -> visibility memberDecl vMemberBlock"); }
    | /* empty */ { addToStack("vMemberBlock -> ε"); }
    ;

implDef :
      IMPLEMENT ID LBRACE interfaceList RBRACE { addToStack("implDef -> IMPLEMENT ID LBRACE interfaceList RBRACE"); }
    ;

funcDef :
      funcHead funcBody { addToStack("funcDef -> funcHead funcBody"); }
    ;

visibility :
      PUBLIC { addToStack("visibility -> PUBLIC"); }
    | PRIVATE { addToStack("visibility -> PRIVATE"); }
    ;

memberDecl :
      funcDecl { addToStack("memberDecl -> funcDecl"); }
    | attributeDecl { addToStack("memberDecl -> attributeDecl"); }
    ;

funcDecl :
      funcHead SEMI { addToStack("funcDecl -> funcHead SEMI"); }
    ;

funcHead :
      FUNC ID LPAREN fParams RPAREN ARROW returnType { addToStack("funcHead -> FUNC ID LPAREN fParams RPAREN ARROW returnType"); }
    | CONSTRUCT LPAREN fParams RPAREN { addToStack("funcHead -> CONSTRUCT LPAREN fParams RPAREN"); }
    ;

funcBody :
      LBRACE implBlock RBRACE { addToStack("funcBody -> LBRACE implBlock RBRACE"); }
    ;

implBlock :
      varDeclOrStmt implBlock { addToStack("implBlock -> varDeclOrStmt implBlock"); }
    | /* empty */ { addToStack("implBlock -> ε"); }
    ;

varDeclOrStmt :
      localVarDecl { addToStack("varDeclOrStmt -> localVarDecl"); }
    | statement { addToStack("varDeclOrStmt -> statement"); }
    ;

attributeDecl :
      ATTRIBUTE varDecl { addToStack("attributeDecl -> ATTRIBUTE varDecl"); }
    ;

localVarDecl :
      LOCAL varDecl { addToStack("localVarDecl -> LOCAL varDecl"); }
    ;

varDecl :
      ID COLON type arrayDimension SEMI { addToStack("varDecl -> ID COLON type arrayDimension SEMI"); }
    ;

arrayDimension :
      arraySize arrayDimension { addToStack("arrayDimension -> arraySize arrayDimension"); }
    | /* empty */ { addToStack("arrayDimension -> ε"); }
    ;

arraySize :
      LBRACE INTLIT RBRACE { addToStack("arraySize -> LBRACE INTLIT RBRACE"); }
    | LBRACE RBRACE { addToStack("arraySize -> LBRACE RBRACE"); }
    ;

type :
      INTEGER { addToStack("type -> INTEGER"); }
    | FLOAT { addToStack("type -> FLOAT"); }
    | ID { addToStack("type -> ID"); }
    ;

returnType :
      type { addToStack("returnType -> type"); }
    | VOID { addToStack("returnType -> VOID"); }
    ;

fParams :
      ID COLON type arrayDimension fParamSeq { addToStack("fParams -> ID COLON type arrayDimension fParamSeq"); }
    | /* empty */ { addToStack("fParams -> ε"); }
    ;

fParamSeq :
      COMMA ID COLON type arrayDimension fParamSeq { addToStack("fParamSeq -> COMMA ID COLON type arrayDimension fParamSeq"); }
    | /* empty */ { addToStack("fParamSeq -> ε"); }
    ;

statement :
      ID ASSIGN ID SEMI { addToStack("statement -> ID ASSIGN ID SEMI"); } 
    | WRITE LPAREN ID RPAREN SEMI { addToStack("statement -> WRITE(...)"); }
    | RETURN LPAREN ID RPAREN SEMI { addToStack("statement -> RETURN(...)"); }
    ;

%%

int main(int argc, char **argv) {
    printf("Parser running...\n");
    initializeStack(100);

    if(argc >= 2){
        yyin = fopen(argv[1], "r");
        if(!yyin){ perror("File open failed"); return 1; }
        printf("Scanning: %s\n", argv[1]);
    } else {
        printf("Enter input manually:\n");
        yyin = stdin;
    }

    yyparse();
    generateOutput();
    freeStack();

    printf("Parser exiting.\n");
    return 0;
}

void yyerror(const char *s){
    fprintf(stderr, "Error: %s\n", s);
}

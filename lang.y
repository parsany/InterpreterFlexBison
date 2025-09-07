%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(); 
extern int yylineno; 
extern char* yytext; 

void yyerror(const char *s);

#define MAX_SYMBOLS 100
typedef struct {
    char *name;
    int value;
} Symbol;

Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

// symbol table vars val
int lookupSymbol(char *name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return symbolTable[i].value;
        }
    }
    fprintf(stderr, "Line %d: Undefined variable '%s'\n", yylineno, name);
    exit(EXIT_FAILURE);
}

//storing vars and values
void storeSymbol(char *name, int value) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            symbolTable[i].value = value;
            return;
        }
    }
    if (symbolCount < MAX_SYMBOLS) {
        symbolTable[symbolCount].name = name;
        symbolTable[symbolCount].value = value;
        symbolCount++;
    } else {
        fprintf(stderr, "Line %d: Symbol table overflow\n", yylineno);
        exit(EXIT_FAILURE);
    }
}


int readIntegerInput() {
    int val;
    FILE *tty; 

    printf("vorudi ra vared konid: ");
    fflush(stdout); 

    tty = fopen("/dev/tty", "r");
    if (tty == NULL) {
        perror("Failed to open /dev/tty for interactive input");
        fprintf(stderr, "Line %d: Cannot open terminal for input. Is stdin redirected AND no tty available?\n", yylineno);
        exit(EXIT_FAILURE);
    }

    if (fscanf(tty, "%d", &val) == 1) {
        int c;
        while ((c = getc(tty)) != '\n' && c != EOF);
        fclose(tty); 
        return val;
    } else {
        fprintf(stderr, "Line %d: Invalid numeric input received from terminal.\n", yylineno);
        if (feof(tty)) {
            fprintf(stderr, "Line %d: EOF encountered on terminal input.\n", yylineno);
        }
        if (ferror(tty)) {
            perror("Error reading from terminal");
        }
        fclose(tty);
        exit(EXIT_FAILURE);
    }
}

%}

%union {
    int ival;
    char *sval;
}

%token <ival> INTEGER
%token <sval> IDENTIFIER
%token INT_KEYWORD MAIN_KEYWORD LET_KEYWORD SHOW_KEYWORD INPUT_KEYWORD
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON ASSIGN_OP
%token ADD_OP SUB_OP MUL_OP DIV_OP

%type <ival> expression term factor primary

%left ADD_OP SUB_OP
%left MUL_OP DIV_OP

%%

/* Grammar Rules */
program:
    INT_KEYWORD MAIN_KEYWORD LPAREN RPAREN LBRACE statements RBRACE { printf("execution executed.\n"); }
    ;

statements:
    /* empty */
    | statements statement
    ;

statement:
    LET_KEYWORD IDENTIFIER ASSIGN_OP expression SEMICOLON {
        storeSymbol($2, $4); 
    }
    | SHOW_KEYWORD LPAREN expression RPAREN SEMICOLON {
        printf("%d\n", $3); 
    }
    ;

expression:
    term                        { $$ = $1; }
    | expression ADD_OP term    { $$ = $1 + $3; }
    | expression SUB_OP term    { $$ = $1 - $3; }
    ;

term:
    factor                      { $$ = $1; }
    | term MUL_OP factor        { $$ = $1 * $3; }
    | term DIV_OP factor        { 
                                  if ($3 == 0) {
                                      yyerror("Division by zero");
                                      YYERROR; 
                                  }
                                  $$ = $1 / $3; 
                                }
    ;

factor:
    primary                     { $$ = $1; }
    ;
    
primary:
    INTEGER                     { $$ = $1; }
    | IDENTIFIER                { $$ = lookupSymbol($1); free($1); }
    | LPAREN expression RPAREN  { $$ = $2; }
    | INPUT_KEYWORD LPAREN RPAREN { $$ = readIntegerInput(); }
    ;

%%

int main(int argc, char **argv) {
    printf("Starting interpreter...\n");
    yyparse(); //parsing
    
    for (int i = 0; i < symbolCount; i++) {
        if (symbolTable[i].name) { 
            symbolTable[i].name = NULL;
        }
    }
    symbolCount = 0; 

    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Line %d: Error: %s ", yylineno, s);
    if (yytext && strlen(yytext) > 0) {
        fprintf(stderr, "near token '%s'\n", yytext);
    } else {
        fprintf(stderr, "\n");
    }
}
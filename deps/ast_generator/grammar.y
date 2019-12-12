/****************************************
*  Computer Algebra System SINGULAR     *
****************************************/
/*
* ABSTRACT: SINGULAR shell grammatik
*/
%{

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include "tok.h"
#include "grammar.tab.h"

#define JLGRAMMAR_DBGMASK (0 + 0)


extern int   yylineno;
extern FILE* yyin;

extern int        cmdtok;
extern int        inerror;

int yylex(YYSTYPE *lvalp);
void yyerror(astree ** retv, const char * fmt);

void enterrule(const char * s);
void exitrule(const char * s);
void exitrule_ex(const char * s, astree * expr);
void exitrule_int(const char * s, int i);
void exitrule_str(const char * s, const char * name);
%}



%pure-parser
%parse-param {astree ** retv}

/* special symbols */
%token DOTDOT
%token EQUAL_EQUAL
%token GE
%token LE
%token MINUSMINUS
%token NOT
%token NOTEQUAL
%token PLUSPLUS
%token COLONCOLON
%token ARROW

/* types, part 1 (ring indep.)*/
%token <i> GRING_CMD
%token <i> BIGINTMAT_CMD
%token <i> INTMAT_CMD
%token <i> PROC_CMD
%token <i> STATIC_PROC_CMD
%token <i> RING_CMD

/* valid when ring defined ! */
%token <i> BEGIN_RING
/* types, part 2 */
%token <i> BUCKET_CMD
%token <i> IDEAL_CMD
%token <i> MAP_CMD
%token <i> MATRIX_CMD
%token <i> MODUL_CMD
%token <i> NUMBER_CMD
%token <i> POLY_CMD
%token <i> RESOLUTION_CMD
%token <i> SMATRIX_CMD
%token <i> VECTOR_CMD
/* end types */

/* ring dependent cmd, with argumnts indep. of a ring*/
%token <i> BETTI_CMD
%token <i> E_CMD
%token <i> FETCH_CMD
%token <i> FREEMODULE_CMD
%token <i> KEEPRING_CMD
%token <i> IMAP_CMD
%token <i> KOSZUL_CMD
%token <i> MAXID_CMD
%token <i> MONOM_CMD
%token <i> PAR_CMD
%token <i> PREIMAGE_CMD
%token <i> VAR_CMD

/*system variables in ring block*/
%token <i> VALTVARS
%token <i> VMAXDEG
%token <i> VMAXMULT
%token <i> VNOETHER
%token <i> VMINPOLY

%token <i> END_RING
/* end of ring definitions */

%token <i> CMD_1
%token <i> CMD_2
%token <i> CMD_3
%token <i> CMD_12
%token <i> CMD_13
%token <i> CMD_23
%token <i> CMD_123
%token <i> CMD_M
%token <i> ROOT_DECL
%token <i> ROOT_DECL_LIST
%token <i> RING_DECL
%token <i> RING_DECL_LIST
%token <i> EXAMPLE_CMD
%token <i> EXPORT_CMD
%token <i> HELP_CMD
%token <i> KILL_CMD
%token <i> LIB_CMD
%token <i> LISTVAR_CMD
%token <i> SETRING_CMD
%token <i> TYPE_CMD

%token <name> STRINGTOK INT_CONST
%token <name> UNKNOWN_IDENT RINGVAR PROC_DEF

/* control */
%token <i> APPLY
%token <i> ASSUME_CMD
%token <i> BREAK_CMD
%token <i> CONTINUE_CMD
%token <i> ELSE_CMD
%token <i> EVAL
%token <i> QUOTE
%token <i> FOR_CMD
%token <i> IF_CMD
%token <i> SYS_BREAK
%token <i> WHILE_CMD
%token <i> RETURN
%token <i> PARAMETER
%token <i> QUIT_CMD

/* system variables */
%token <i> SYSVAR

%type <tree> extendedid
%type <tree>   rlist ordering OrderingList orderelem
%type <tree> stringexpr
%type <tree>   expr elemexpr exprlist expr_arithmetic
%type <tree>   declare_ip_variable left_value
%type <tree>    error
%type <tree>    ordername
%type <i>    cmdeq
%type <tree>    setrings
%type <tree>    ringcmd1
%type <tree>    mat_cmd

%type <i>    '=' '<' '+' '-' COLONCOLON
%type <i>    '/' '[' ']' '^' ',' ';'


/* new types */
%type <tree> top_lines
%type <tree> top_pprompt
%type <tree> lines
%type <tree> pprompt
%type <tree> npprompt
%type <tree> assign 
%type <tree> command 
%type <tree> exportcmd killcmd listcmd parametercmd ringcmd scriptcmd setringcmd typecmd
%type <tree> flowctrl ifcmd whilecmd example_dummy forcmd proccmd filecmd helpcmd
%type <tree> returncmd
%type <tree> quote_start
%type <tree> quote_end
%type <tree> assume_start
%type <tree> examplecmd
%type <tree> procarglist
%type <tree> procarg


/*%nonassoc '=' PLUSEQUAL DOTDOT*/
/*%nonassoc '=' DOTDOT COLONCOLON*/
%nonassoc '='
%left ','
%left '&'
%left EQUAL_EQUAL NOTEQUAL
%left '<'
%nonassoc DOTDOT
%left '+' '-' ':'
%left '/'
%left UMINUS NOT
%left  '^'
%left '[' ']'
%left '(' ')'
%left '{' '}'
%left PLUSPLUS MINUSMINUS
%left COLONCOLON
%left '.'
%left ARROW

%%

top_lines:
            {
                enterrule("top_lines -> ");
                $$ = astnode_make0(RULE_top_lines(1));
                *retv = $$;
                exitrule("top_lines -> ");
            }

        | top_lines top_pprompt
            {
                enterrule("top_lines -> top_lines top_pprompt");
                $$ = astnode_append($1, $2);
                *retv = $$;
                exitrule_ex("top_lines -> top_lines top_pprompt",$$);
            }
        ;

top_pprompt:
        flowctrl                       /* if, while, for, proc */
            {
                enterrule("top_pprompt -> flowctrl");
                $$ = astnode_make1(RULE_top_pprompt(1), $1);
                exitrule("top_pprompt -> flowctrl");
            }

        | command ';'                  /* commands returning no value */
            {
                enterrule("top_pprompt -> command ';'");
                $$ = astnode_make1(RULE_top_pprompt(2), $1);
                exitrule_ex("top_pprompt -> command ';'",$$);
            }

        | declare_ip_variable ';'      /* default initialization */
            {
                enterrule("top_pprompt -> declare_ip_variable ';'");
                $$ = astnode_make1(RULE_top_pprompt(3), $1);
                exitrule("top_pprompt -> declare_ip_variable ';'");
            }

        | returncmd
            {
                enterrule("pprompt -> returncmd");
                $$ = astnode_make1(RULE_top_pprompt(99), $1);
                exitrule("pprompt -> returncmd");
            }

        | SYS_BREAK
            {
                enterrule("top_pprompt -> SYS_BREAK");
                $$ = astnode_make0(RULE_top_pprompt(4));
                exitrule("top_pprompt -> SYS_BREAK");
            }

        | ';'                    /* ignore empty statements */
            {
                enterrule("top_pprompt -> ';'");
                $$ = astnode_make0(RULE_top_pprompt(5));
                exitrule_ex("top_pprompt -> ';'", $$);
            }

        | error ';'
            {
                enterrule("top_pprompt -> error ';'");
                YYABORT;
                exitrule("top_pprompt -> error ';'");
            }
        ;

lines:
            {
                enterrule("lines -> ");
                $$ = astnode_make0(RULE_lines(1));
                exitrule("lines -> ");
            }

        | lines pprompt
            {
                enterrule("lines -> lines pprompt");
                $$ = astnode_append($1, $2);
                exitrule_ex("lines -> lines pprompt",$$);
            }
        ;

pprompt:
        flowctrl                       /* if, while, for, proc */
            {
                enterrule("pprompt -> flowctrl");
                $$ = astnode_make1(RULE_pprompt(1), $1);
                exitrule("pprompt -> flowctrl");
            }

        | command ';'                  /* commands returning no value */
            {
                enterrule("pprompt -> command ';'");
                $$ = astnode_make1(RULE_pprompt(2), $1);
                exitrule_ex("pprompt -> command ';'",$$);
            }

        | declare_ip_variable ';'      /* default initialization */
            {
                enterrule("pprompt -> declare_ip_variable ';'");
                $$ = astnode_make1(RULE_pprompt(3), $1);
                exitrule("pprompt -> declare_ip_variable ';'");
            }

        | returncmd
            {
                enterrule("pprompt -> returncmd");
                $$ = astnode_make1(RULE_pprompt(4), $1);
                exitrule("pprompt -> returncmd");
            }

        | SYS_BREAK
            {
                enterrule("pprompt -> SYS_BREAK");
                $$ = astnode_make0(RULE_pprompt(5));
                exitrule("pprompt -> SYS_BREAK");
            }

        | ';'                    /* ignore empty statements */
            {
                enterrule("pprompt -> ';'");
                $$ = astnode_make0(RULE_pprompt(6));
                exitrule_ex("pprompt -> ';'", $$);
            }

        | error ';'
            {
                enterrule("pprompt -> error ';'");
                YYABORT;
                exitrule("pprompt -> error ';'");
            }
        ;


npprompt:
        flowctrl                       /* if, while, for, proc */
            {
                enterrule("npprompt -> flowctrl");
                $$ = astnode_make1(RULE_npprompt(1), $1);
                exitrule("npprompt -> flowctrl");
            }

        | command                   /* commands returning no value */
            {
                enterrule("npprompt -> command");
                $$ = astnode_make1(RULE_npprompt(2), $1);
                exitrule_ex("npprompt -> command ';'",$$);
            }

        | declare_ip_variable       /* default initialization */
            {
                enterrule("npprompt -> declare_ip_variable");
                $$ = astnode_make1(RULE_npprompt(3), $1);
                exitrule("npprompt -> declare_ip_variable ';'");
            }

        | returncmd
            {
                enterrule("npprompt -> returncmd");
                $$ = astnode_make1(RULE_npprompt(4), $1);
                exitrule("npprompt -> returncmd");
            }

        | SYS_BREAK
            {
                enterrule("npprompt -> SYS_BREAK");
                $$ = astnode_make0(RULE_npprompt(5));
                exitrule("npprompt -> SYS_BREAK");
            }

        | error
            {
                enterrule("npprompt -> error ';'");
                YYABORT;
                exitrule("npprompt -> error ';'");
            }
        ;


flowctrl: ifcmd
            {
                enterrule("flowctrl -> ifcmd");
                $$ = astnode_make1(RULE_flowctrl(1), $1);
                exitrule("flowctrl -> ifcmd");
            }

        | whilecmd
            {
                enterrule("flowctrl -> whilecmd");
                $$ = astnode_make1(RULE_flowctrl(2), $1);
                exitrule("flowctrl -> whilecmd");
            }

        | example_dummy
            {
                enterrule("flowctrl -> example_dummy");
                $$ = astnode_make1(RULE_flowctrl(3), $1);
                exitrule("flowctrl -> example_dummy");
            }

        | forcmd
            {
                enterrule("flowctrl -> forcmd");
                $$ = astnode_make1(RULE_flowctrl(4), $1);
                exitrule("flowctrl -> forcmd");
            }

        | proccmd
            {
                enterrule("flowctrl -> proccmd");
                $$ = astnode_make1(RULE_flowctrl(5), $1);
                exitrule_ex("flowctrl -> proccmd",$$);
            }

        | filecmd
            {
                enterrule("flowctrl -> filecmd");
                $$ = astnode_make1(RULE_flowctrl(6), $1);
                exitrule_ex("flowctrl -> filecmd",$$);
            }

        | helpcmd
            {
                enterrule("flowctrl -> helpcmd");
                $$ = astnode_make1(RULE_flowctrl(7), $1);
                exitrule_ex("flowctrl -> helpcmd",$$);
            }

        | examplecmd
            {
                enterrule("flowctrl -> examplecmd");
                $$ = astnode_make1(RULE_flowctrl(8), $1);
                exitrule("flowctrl -> examplecmd");
            }
        ;

example_dummy : EXAMPLE_CMD '{' lines '}'
            {
                enterrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
                $$ = astnode_make1(RULE_example_dummy(1), $3);
                exitrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
            }
        ;

command: assign
            {
                enterrule("command -> assign");
                $$ = astnode_make1(RULE_command(1), $1);
                exitrule_ex("command -> assign",$$);
            }

         | exportcmd
            {
                enterrule("command -> exportcmd");
                $$ = astnode_make1(RULE_command(2), $1);
                exitrule_ex("command -> exportcmd",$$);
            }

         | killcmd
            {
                enterrule("command -> killcmd");
                $$ = astnode_make1(RULE_command(3), $1);
                exitrule_ex("command -> killcmd",$$);
            }

         | listcmd
            {
                enterrule("command -> listcmd");
                $$ = astnode_make1(RULE_command(4), $1);
                exitrule_ex("command -> listcmd",$$);
            }

         | parametercmd
            {
                enterrule("command -> parametercmd");
                $$ = astnode_make1(RULE_command(5), $1);
                exitrule_ex("command -> parametercmd",$$);
            }

         | ringcmd
            {
                enterrule("command -> ringcmd");
                $$ = astnode_make1(RULE_command(6), $1);
                exitrule_ex("command -> ringcmd",$$);
            }

         | scriptcmd
            {
                enterrule("command -> scriptcmd");
                $$ = astnode_make1(RULE_command(7), $1);
                exitrule_ex("command -> scriptcmd",$$);
            }

         | setringcmd
            {
                enterrule("command -> setringcmd");
                $$ = astnode_make1(RULE_command(8), $1);
                exitrule_ex("command -> setringcmd",$$);
            }

         | typecmd
            {
                enterrule("command -> typecmd");
                $$ = astnode_make1(RULE_command(9), $1);
                exitrule_ex("command -> typecmd",$$);
            }
         ;

assign: left_value exprlist
            {
                enterrule("assign -> left_value exprlist");
                $$ = astnode_make2(RULE_assign(1), $1, $2);
                exitrule_ex("assign -> left_value exprlist",$$);
            }
        ;

elemexpr:
        RINGVAR
            {
                enterrule("elemexpr -> RINGVAR");
                $$ = astnode_make1(RULE_elemexpr(1), aststring_make($1));
                exitrule("elemexpr -> RINGVAR");
            }

        | UNKNOWN_IDENT
            {
                enterrule("extendedid -> UNKNOWN_IDENT");
                $$ = astnode_make1(RULE_elemexpr(99), aststring_make($1));
                exitrule_ex("extendedid -> UNKNOWN_IDENT",$$);
            }

        | '`' expr '`'
            {
                enterrule("extendedid -> '`' expr '`'");
                $$ = astnode_make1(RULE_elemexpr(98), $2);
                exitrule_ex("extendedid -> '`' expr '`'",$$);
            }

        | elemexpr COLONCOLON elemexpr
            {
                enterrule("elemexpr -> elemexpr COLONCOLON elemexpr");
                $$ = astnode_make2(RULE_elemexpr(3), $1, $3);
                exitrule("elemexpr -> elemexpr COLONCOLON elemexpr");
            }

        | expr '.' elemexpr
            {
                enterrule("elemexpr -> expr '.' elemexpr");
                $$ = astnode_make2(RULE_elemexpr(4), $1, $3);
                exitrule("elemexpr -> expr '.' elemexpr");
            }

        | elemexpr '('  ')'
            {
                enterrule("elemexpr -> elemexpr '('  ')'");
                $$ = astnode_make1(RULE_elemexpr(5), $1);
                exitrule("elemexpr -> elemexpr '('  ')'");
            }

        | elemexpr '(' exprlist ')'
            {
                enterrule("elemexpr -> elemexpr '(' exprlist ')'");
                $$ = astnode_make2(RULE_elemexpr(6), $1, $3);
                exitrule_ex("elemexpr -> elemexpr '(' exprlist ')'", $$);
            }

        | '[' exprlist ']'
            {
                enterrule("elemexpr -> '[' exprlist ']'");
                $$ = astnode_make1(RULE_elemexpr(7), $2);
                exitrule("elemexpr -> '[' exprlist ']'");
            }

        | INT_CONST
            {
                enterrule("elemexpr -> INT_CONST");
                $$ = astnode_make1(RULE_elemexpr(8), aststring_make($1));
                exitrule_ex("elemexpr -> INT_CONST", $$);
            }

        | SYSVAR
            {
                enterrule("elemexpr -> SYSVAR");
                $$ = astnode_make1(RULE_elemexpr(9), astint_make($1));
                exitrule("elemexpr -> SYSVAR");
            }

        | stringexpr
            {
                enterrule("elemexpr -> stringexpr");
                $$ = astnode_make1(RULE_elemexpr(10), $1);
                exitrule("elemexpr -> stringexpr");
            }

        | PROC_CMD '(' expr ')'
            {
                enterrule("elemexpr -> PROC_CMD '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(11), astint_make($1), $3);
                exitrule("elemexpr -> PROC_CMD '(' expr ')'");
            }

        | ROOT_DECL '(' expr ')'
            {
                enterrule("elemexpr -> ROOT_DECL '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(12), astint_make($1), $3);
                exitrule("elemexpr -> ROOT_DECL '(' expr ')'");
            }

        | ROOT_DECL_LIST '(' exprlist ')'
            {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
                $$ = astnode_make2(RULE_elemexpr(13), astint_make($1), $3);
                exitrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
            }

        | ROOT_DECL_LIST '(' ')'
            {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
                $$ = astnode_make1(RULE_elemexpr(14), astint_make($1));
                exitrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
            }

        | RING_DECL '(' expr ')'
            {
                enterrule("elemexpr -> RING_DECL '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(15), astint_make($1), $3);
                exitrule("elemexpr -> RING_DECL '(' expr ')'");
            }

        | RING_DECL_LIST '(' exprlist ')'
            {
                enterrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
                $$ = astnode_make2(RULE_elemexpr(16), astint_make($1), $3);
                exitrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
            }

        | RING_DECL_LIST '(' ')'
            {
                enterrule("elemexpr -> RING_DECL_LIST '(' ')'");
                $$ = astnode_make1(RULE_elemexpr(17), astint_make($1));
                exitrule("elemexpr -> RING_DECL_LIST '(' ')'");
            }

        | CMD_1 '(' expr ')'
            {
                enterrule("elemexpr -> CMD_1 '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(18), astint_make($1), $3);
                exitrule("elemexpr -> CMD_1 '(' expr ')'");
            }

        | CMD_12 '(' expr ')'
            {
                enterrule("elemexpr -> CMD_12 '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(19), astint_make($1), $3);
                exitrule("elemexpr -> CMD_12 '(' expr ')'");
            }

        | CMD_13 '(' expr ')'
            {
                enterrule("elemexpr -> CMD_13 '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(20), astint_make($1), $3);
                exitrule("elemexpr -> CMD_13 '(' expr ')'");
            }

        | CMD_123 '(' expr ')'
            {
                enterrule("elemexpr -> CMD_123 '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(21), astint_make($1), $3);
                exitrule("elemexpr -> CMD_123 '(' expr ')'");
            }

        | CMD_2 '(' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
                $$ = astnode_make3(RULE_elemexpr(22), astint_make($1), $3, $5);
                exitrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
            }

        | CMD_12 '(' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
                $$ = astnode_make3(RULE_elemexpr(23), astint_make($1), $3, $5);
                exitrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
            }

        | CMD_23 '(' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
                $$ = astnode_make3(RULE_elemexpr(24), astint_make($1), $3, $5);
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
            }

        | CMD_123 '(' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
                $$ = astnode_make3(RULE_elemexpr(25), astint_make($1), $3, $5);
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
            }

        | CMD_3 '(' expr ',' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
                $$ = astnode_make4(RULE_elemexpr(26), astint_make($1), $3, $5, $7);
                exitrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
            }

        | CMD_13 '(' expr ',' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
                $$ = astnode_make4(RULE_elemexpr(27), astint_make($1), $3, $5, $7);
                exitrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
            }

        | CMD_23 '(' expr ',' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
                $$ = astnode_make4(RULE_elemexpr(28), astint_make($1), $3, $5, $7);
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
            }

        | CMD_123 '(' expr ',' expr ',' expr ')'
            {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
                $$ = astnode_make4(RULE_elemexpr(29), astint_make($1), $3, $5, $7);
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
            }

        | CMD_M '(' ')'
            {
                enterrule("elemexpr -> CMD_M '(' ')'");
                $$ = astnode_make1(RULE_elemexpr(30), astint_make($1));
                exitrule("elemexpr -> CMD_M '(' ')'");
            }

        | CMD_M '(' exprlist ')'
            {
                enterrule("elemexpr -> CMD_M '(' exprlist ')'");
                $$ = astnode_make2(RULE_elemexpr(31), astint_make($1), $3);
                exitrule("elemexpr -> CMD_M '(' exprlist ')'");
            }

        | mat_cmd '(' expr ',' expr ',' expr ')'
            {
                enterrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
                $$ = astnode_make4(RULE_elemexpr(32), $1, $3, $5, $7);
                exitrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
            }

        | mat_cmd '(' expr ')'
            {
                enterrule("elemexpr -> mat_cmd '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(33), $1, $3);
                exitrule("elemexpr -> mat_cmd '(' expr ')'");
            }

        | RING_CMD '(' rlist ',' rlist ',' ordering ')'
            {
                enterrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
                $$ = astnode_make4(RULE_elemexpr(34), astint_make($1), $3, $5, $7);
                exitrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
            }

        | RING_CMD '(' expr ')'
            {
                enterrule("elemexpr -> RING_CMD '(' expr ')'");
                $$ = astnode_make2(RULE_elemexpr(35), astint_make($1), $3);
                exitrule("elemexpr -> RING_CMD '(' expr ')'");
            }

        | extendedid  ARROW '{' lines '}'
            {
                enterrule("elemexpr -> extendedid  ARROW '{' lines '}'");
                $$ = astnode_make2(RULE_elemexpr(36), $1, $4);
                exitrule("elemexpr -> extendedid  ARROW '{' lines '}'");
            }

        | '(' exprlist ')'
            {
                enterrule("elemexpr -> '(' exprlist ')'");
                $$ = astnode_make1(RULE_elemexpr(37), $2);
                exitrule_ex("elemexpr -> '(' exprlist ')'",$$);
            }
        ;

exprlist:
        exprlist ',' expr
            {
                enterrule("exprlist -> exprlist ',' expr");
                $$ = astnode_append($1, $3);
                exitrule_ex("exprlist -> exprlist ',' expr",$$);
            }

        | expr
            {
                enterrule("exprlist -> expr");
                $$ = astnode_make1(RULE_exprlist(1), $1);
                exitrule_ex("exprlist -> expr",$$);
            }
        ;

expr:   expr_arithmetic
            {
                enterrule("expr -> expr_arithmetic");
                $$ = astnode_make1(RULE_expr(1), $1);
                exitrule_ex("expr -> expr_arithmetic",$$);
            }

        | elemexpr
            {
                enterrule("expr -> elemexpr");
                $$ = astnode_make1(RULE_expr(2), $1);
                exitrule_ex("expr -> elemexpr",$$);
            }

        | expr '[' expr ',' expr ']'
            {
                enterrule("expr -> expr '[' expr ',' expr ']'");
                $$ = astnode_make3(RULE_expr(3), $1, $3, $5);
                exitrule("expr -> expr '[' expr ',' expr ']'");
            }

        | expr '[' expr ']'
            {
                enterrule("expr -> expr '[' expr ']'");
                $$ = astnode_make2(RULE_expr(4), $1, $3);
                exitrule("expr -> expr '[' expr ']'");
            }

        | APPLY '('  expr ',' CMD_1 ')'
            {
                enterrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
                $$ = astnode_make2(RULE_expr(5), $3, astint_make($5));
                exitrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
            }

        | APPLY '('  expr ',' CMD_12 ')'
            {
                enterrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
                $$ = astnode_make2(RULE_expr(6), $3, astint_make($5));
                exitrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
            }

        | APPLY '('  expr ',' CMD_13 ')'
            {
                enterrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
                $$ = astnode_make2(RULE_expr(7), $3, astint_make($5));
                exitrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
            }

        | APPLY '('  expr ',' CMD_123 ')'
            {
                enterrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
                $$ = astnode_make2(RULE_expr(8), $3, astint_make($5));
                exitrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
            }

        | APPLY '('  expr ',' CMD_M ')'
            {
                enterrule("expr -> APPLY '('  expr ',' CMD_M ')'");
                $$ = astnode_make2(RULE_expr(9), $3, astint_make($5));
                exitrule("expr -> APPLY '('  expr ',' CMD_M ')'");
            }

        | APPLY '('  expr ',' expr ')'
            {
                enterrule("expr -> APPLY '('  expr ',' expr ')'");
                $$ = astnode_make2(RULE_expr(10), $3, $5);
                exitrule("expr -> APPLY '('  expr ',' expr ')'");
            }

        | quote_start expr quote_end
            {
                enterrule("expr -> quote_start expr quote_end");
                $$ = astnode_make1(RULE_expr(11), $2);
                exitrule("expr -> quote_start expr quote_end");
            }

        | quote_start expr '=' expr quote_end
            {
                enterrule("expr -> quote_start expr '=' expr quote_end");
                $$ = astnode_make2(RULE_expr(12), $2, $4);
                exitrule("expr -> quote_start expr '=' expr quote_end");
            }

        | assume_start expr ',' expr quote_end
            {
                enterrule("expr -> assume_start expr ',' expr quote_end");
                $$ = astnode_make2(RULE_expr(13), $2, $4);
                exitrule("expr -> assume_start expr ',' expr quote_end");
            }

        | EVAL  '('
            {
                enterrule("expr -> EVAL  '('");
                exitrule("expr -> EVAL  '('");
            }

          expr ')'
            {
                enterrule("expr -> EVAL  '(' expr ')'");
                $$ = astnode_make1(RULE_expr(14), $4);
                exitrule("expr -> EVAL  '(' expr ')'");
            }
          ;

quote_start:    QUOTE  '('
            {
                enterrule("quote_start -> QUOTE  '('");
                $$ = astnode_make0(RULE_quote_start(1));
                exitrule("quote_start -> QUOTE  '('");
            }
          ;

assume_start:    ASSUME_CMD '('
            {
                enterrule("assume_start -> ASSUME_CMD '('");
                $$ = astnode_make0(RULE_assume_start(2));
                exitrule("assume_start ASSUME_CMD '('");
            }
          ;

quote_end: ')'
            {
                enterrule("quote_end -> ')'");
                $$ = astnode_make0(RULE_quote_end(1));
                exitrule("quote_end -> ')'");
            }
          ;

expr_arithmetic:
          expr PLUSPLUS     %prec PLUSPLUS
            {
                enterrule("expr_arithmetic -> expr PLUSPLUS");
                $$ = astnode_make1(RULE_expr_arithmetic(1), $1);
                exitrule_ex("expr_arithmetic -> expr PLUSPLUS",$$);
            }

        | expr MINUSMINUS   %prec MINUSMINUS
            {
                enterrule("expr_arithmetic -> expr MINUSMINUS");
                $$ = astnode_make1(RULE_expr_arithmetic(2), $1);
                exitrule_ex("expr_arithmetic -> expr MINUSMINUS",$$);
            }

        | expr '+' expr
            {
                enterrule("expr_arithmetic -> expr '+' expr");
                $$ = astnode_make2(RULE_expr_arithmetic(3), $1, $3);
                exitrule_ex("expr_arithmetic -> expr '+' expr",$$);
            }

        | expr '-' expr
            {
                enterrule("expr_arithmetic -> expr '-' expr");
                $$ = astnode_make2(RULE_expr_arithmetic(4), $1, $3);
                exitrule_ex("expr_arithmetic -> expr '-' expr",$$);
            }

        | expr '/' expr
            {
                enterrule("expr_arithmetic -> expr '/' expr");
                if ($<i>2 == '*')
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(5), $1, $3);
                }
                else if ($<i>2 == '%')
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(6), $1, $3);
                }
                else if ($<i>2 == INTDIV_CMD)
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(99), $1, $3);
                }
                else
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(7), $1, $3);
                }
                exitrule_ex("expr_arithmetic -> expr '/' expr",$$);
            }

        | expr '^' expr
            {
                enterrule("expr_arithmetic -> expr '^' expr");
                $$ = astnode_make2(RULE_expr_arithmetic(8), $1, $3);
                exitrule_ex("expr_arithmetic -> expr '^' expr",$$);
            }

        | expr '<' expr
            {
                enterrule("expr_arithmetic -> expr '<' expr");
                if ($<i>2 == GE)
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(9), $1, $3);
                }
                else if ($<i>2 == LE)
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(10), $1, $3);
                }
                else if ($<i>2 == '>')
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(11), $1, $3);
                }
                else
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(12), $1, $3);
                }
                exitrule_ex("expr_arithmetic -> expr '<' expr",$$);
            }

        | expr '&' expr
            {
                enterrule("expr_arithmetic -> expr '&' expr");
                if ($<i>2 == '&')
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(13), $1, $3);
                }
                else
                {
                    $$ = astnode_make2(RULE_expr_arithmetic(14), $1, $3);
                }
                exitrule_ex("expr_arithmetic -> expr '&' expr",$$);
            }

        | expr NOTEQUAL expr
            {
                enterrule("expr_arithmetic -> expr NOTEQUAL expr");
                $$ = astnode_make2(RULE_expr_arithmetic(15), $1, $3);
                exitrule("expr_arithmetic -> expr NOTEQUAL expr");
            }

        | expr EQUAL_EQUAL expr
            {
                enterrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
                $$ = astnode_make2(RULE_expr_arithmetic(16), $1, $3);
                exitrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
            }

        | expr DOTDOT expr
            {
                enterrule("expr_arithmetic -> expr DOTDOT expr");
                $$ = astnode_make2(RULE_expr_arithmetic(17), $1, $3);
                exitrule("expr_arithmetic -> expr DOTDOT expr");
            }

        | expr ':' expr
            {
                enterrule("expr_arithmetic -> expr ':' expr");
                $$ = astnode_make2(RULE_expr_arithmetic(18), $1, $3);
                exitrule("expr_arithmetic -> expr ':' expr");
            }

        | NOT expr
            {
                enterrule("expr_arithmetic -> NOT expr");
                $$ = astnode_make1(RULE_expr_arithmetic(19), $2);
                exitrule("expr_arithmetic -> NOT expr");
            }

        | '-' expr %prec UMINUS
            {
                enterrule("expr_arithmetic -> '-' expr");
                $$ = astnode_make1(RULE_expr_arithmetic(20), $2);
                exitrule("expr_arithmetic -> '-' expr");
            }
        ;

left_value:
        declare_ip_variable cmdeq
            {
                enterrule("left_value -> declare_ip_variable cmdeq");
                $$ = astnode_make1(RULE_left_value(1), $1);
                exitrule_ex("left_value -> declare_ip_variable cmdeq",$$);
            }

        | exprlist cmdeq
            {
                enterrule("left_value -> exprlist cmdeq");
                $$ = astnode_make1(RULE_left_value(2), $1);
                exitrule("left_value -> exprlist cmdeq");
            }
        ;


extendedid:
        UNKNOWN_IDENT
            {
                enterrule("extendedid -> UNKNOWN_IDENT");
                $$ = astnode_make1(RULE_extendedid(1), aststring_make($1));
                exitrule_ex("extendedid -> UNKNOWN_IDENT",$$);
            }

        | '`' expr '`'
            {
                enterrule("extendedid -> '`' expr '`'");
                $$ = astnode_make1(RULE_extendedid(2), $2);
                exitrule_ex("extendedid -> '`' expr '`'",$$);
            }

        | extendedid '(' exprlist ')'
            {
                enterrule("extendedid -> extendedid '(' exprlist ')'");
                $$ = astnode_make2(RULE_extendedid(3), $1, $3);
                exitrule_ex("extendedid -> extendedid '(' exprlist ')'", $$);
            }
        ;

declare_ip_variable:

        ROOT_DECL extendedid
            {
                enterrule("declare_ip_variable -> ROOT_DECL elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(1), astint_make($1), $2);
                exitrule_ex("declare_ip_variable -> ROOT_DECL elemexpr",$$);
            }

        | UNKNOWN_IDENT extendedid
            {
                enterrule("declare_ip_variable -> UNKNOWN_IDENT elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(99), aststring_make($1), $2);
                exitrule_ex("declare_ip_variable -> UNKNOWN_IDENT elemexpr",$$);
            }

        | ROOT_DECL_LIST extendedid
            {
                enterrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(2), astint_make($1), $2);
                exitrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
            }

        | RING_DECL extendedid
            {
                enterrule("declare_ip_variable -> RING_DECL elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(3), astint_make($1), $2);
                exitrule("declare_ip_variable -> RING_DECL elemexpr");
            }

        | RING_DECL_LIST extendedid
            {
                enterrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(4), astint_make($1), $2);
                exitrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
            }

        | mat_cmd extendedid '[' expr ']' '[' expr ']'
            {
                enterrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
                $$ = astnode_make4(RULE_declare_ip_variable(5), $1, $2, $4, $7);
                exitrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
            }

        | mat_cmd extendedid
            {
                enterrule("declare_ip_variable -> mat_cmd elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(6), $1, $2);
                exitrule("declare_ip_variable -> mat_cmd elemexpr");
            }

        | declare_ip_variable ',' extendedid
            {
                enterrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
                $$ = astnode_make2(RULE_declare_ip_variable(7), $1, $3);
                exitrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
            }

        | PROC_CMD extendedid
            {
                enterrule("declare_ip_variable -> PROC_CMD elemexpr");
                $$ = astnode_make1(RULE_declare_ip_variable(8), $2);
                exitrule("declare_ip_variable -> PROC_CMD elemexpr");
            }
        ;

stringexpr:
        STRINGTOK
            {
                enterrule("stringexpr -> STRINGTOK");
                $$ = astnode_make1(RULE_stringexpr(1), aststring_make($1));
                exitrule("stringexpr -> STRINGTOK");
            }
        ;

rlist:
        expr
            {
                enterrule("rlist -> expr");
                $$ = astnode_make1(RULE_rlist(1), $1);
                exitrule("rlist -> expr");
            }
        ;

ordername:
        UNKNOWN_IDENT
            {
                enterrule("ordername -> UNKNOWN_IDENT");
                $$ = astnode_make1(RULE_ordername(1), aststring_make($1));
                exitrule("ordername -> UNKNOWN_IDENT");
            }
        ;

orderelem:
        ordername
            {
                enterrule("orderelem -> ordername");
                $$ = astnode_make1(RULE_orderelem(1), $1);
                exitrule("orderelem -> ordername");
            }
        | ordername '(' exprlist ')'
            {
                enterrule("orderelem -> ordername '(' exprlist ')'");
                $$ = astnode_make2(RULE_orderelem(2), $1, $3);
                exitrule("orderelem -> ordername '(' exprlist ')'");
            }
        ;

OrderingList:
        orderelem
            {
                enterrule("OrderingList -> orderelem");
                $$ = astnode_make1(RULE_OrderingList(1), $1);
                exitrule("OrderingList -> orderelem");
            }

        |  orderelem ',' OrderingList
            {
                enterrule("OrderingList -> orderelem ',' OrderingList");
                $$ = astnode_make2(RULE_OrderingList(2), $1, $3);
                exitrule("OrderingList -> orderelem ',' OrderingList");
            }
        ;

ordering:
        orderelem
            {
                enterrule("ordering -> orderelem");
                $$ = astnode_make1(RULE_ordering(1), $1);
                exitrule("ordering -> orderelem");
            }

        | '(' OrderingList ')'
            {
                enterrule("ordering -> '(' OrderingList ')'");
                $$ = astnode_make1(RULE_ordering(2), $2);
                exitrule("ordering -> '(' OrderingList ')'");
            }
        ;

cmdeq:  '='
            {
                enterrule("cmdeq -> '='");
                $$ = $1;
                exitrule("cmdeq -> '='");
            }
        ;


mat_cmd: MATRIX_CMD
            {
                enterrule("mat_cmd -> MATRIX_CMD");
                $$ = astnode_make1(RULE_mat_cmd(1), astint_make($1));
                exitrule("mat_cmd -> MATRIX_CMD");
            }

        | INTMAT_CMD
            {
                enterrule("mat_cmd -> INTMAT_CMD");
                $$ = astnode_make1(RULE_mat_cmd(2), astint_make($1));
                exitrule("mat_cmd -> INTMAT_CMD");
            }

        | BIGINTMAT_CMD
            {
                enterrule("mat_cmd -> BIGINTMAT_CMD");
                $$ = astnode_make1(RULE_mat_cmd(3), astint_make($1));
                exitrule("mat_cmd -> BIGINTMAT_CMD");
            }
          ;

/* --------------------------------------------------------------------*/
/* section of pure commands                                            */
/* --------------------------------------------------------------------*/

filecmd:
        '<' stringexpr
            {
                enterrule("filecmd -> '<' stringexpr");
                $$ = astnode_make1(RULE_filecmd(1), $2);
                exitrule("filecmd -> '<' stringexpr");
            }
        ;

helpcmd:
        HELP_CMD STRINGTOK ';'
            {
                enterrule("helpcmd -> HELP_CMD STRINGTOK ';'");
                $$ = astnode_make1(RULE_helpcmd(1), aststring_make($2));
                exitrule("helpcmd -> HELP_CMD STRINGTOK ';'");
            }

        | HELP_CMD ';'
            {
                enterrule("helpcmd -> HELP_CMD ';'");
                $$ = astnode_make0(RULE_helpcmd(2));
                exitrule("helpcmd -> HELP_CMD ';'");
            }
        ;

examplecmd:
        EXAMPLE_CMD STRINGTOK ';'
            {
                enterrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
                $$ = astnode_make1(RULE_examplecmd(1), aststring_make($2));
                exitrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
            }
       ;

exportcmd:
        EXPORT_CMD exprlist
            {
                enterrule("exportcmd -> EXPORT_CMD exprlist");
                $$ = astnode_make1(RULE_exportcmd(1), $2);
                exitrule("exportcmd -> EXPORT_CMD exprlist");
            }
        ;

killcmd:
        KILL_CMD elemexpr
            {
                enterrule("killcmd -> KILL_CMD elemexpr");
                $$ = astnode_make1(RULE_killcmd(1), $2);
                exitrule("killcmd -> KILL_CMD elemexpr");
            }

        | killcmd ',' elemexpr
            {
                enterrule("killcmd -> killcmd ',' elemexpr");
                $$ = astnode_make2(RULE_killcmd(2), $1, $3);
                exitrule("killcmd -> killcmd ',' elemexpr");
            }
        ;

listcmd:
        LISTVAR_CMD '(' ROOT_DECL ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                $$ = astnode_make1(RULE_listcmd(1), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }

        | LISTVAR_CMD '(' ROOT_DECL_LIST ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
                $$ = astnode_make1(RULE_listcmd(2), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
            }

        | LISTVAR_CMD '(' RING_DECL ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                $$ = astnode_make1(RULE_listcmd(3), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }

        | LISTVAR_CMD '(' RING_DECL_LIST ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
                $$ = astnode_make1(RULE_listcmd(4), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
            }

        | LISTVAR_CMD '(' RING_CMD ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
                $$ = astnode_make1(RULE_listcmd(5), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
            }

        | LISTVAR_CMD '(' mat_cmd ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
                $$ = astnode_make1(RULE_listcmd(6), $3);
                exitrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
            }

        | LISTVAR_CMD '(' PROC_CMD ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
                $$ = astnode_make1(RULE_listcmd(7), astint_make($3));
                exitrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
            }

        | LISTVAR_CMD '(' elemexpr ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
                $$ = astnode_make1(RULE_listcmd(8), $3);
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
                $$ = astnode_make2(RULE_listcmd(9), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
                $$ = astnode_make2(RULE_listcmd(10), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
                $$ = astnode_make2(RULE_listcmd(11), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
                $$ = astnode_make2(RULE_listcmd(12), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
                $$ = astnode_make2(RULE_listcmd(13), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
                $$ = astnode_make2(RULE_listcmd(14), $3, $5);
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
            }

        | LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
                $$ = astnode_make2(RULE_listcmd(15), $3, astint_make($5));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
            }

        | LISTVAR_CMD '(' ')'
            {
                enterrule("listcmd -> LISTVAR_CMD '(' ')'");
                $$ = astnode_make0(RULE_listcmd(16));
                exitrule("listcmd -> LISTVAR_CMD '(' ')'");
            }
        ;

ringcmd1:
       RING_CMD
            {
                enterrule("ringcmd1 -> RING_CMD");
                $$ = astnode_make0(RULE_ringcmd1(1));
                exitrule("ringcmd1 -> RING_CMD");
            }
       ;

ringcmd:
        ringcmd1
          elemexpr cmdeq
          rlist     ','      /* description of coeffs */
          rlist     ','      /* var names */
          ordering           /* list of (multiplier ordering (weight(s))) */
            {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
                $$ = astnode_make4(RULE_ringcmd(1), $2, $4, $6, $8);
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
            }

        | ringcmd1 elemexpr
            {
                enterrule("ringcmd -> ringcmd1 elemexpr");
                $$ = astnode_make1(RULE_ringcmd(2), $2);
                exitrule("ringcmd -> ringcmd1 elemexpr");
            }

        | ringcmd1 elemexpr cmdeq elemexpr
            {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
                $$ = astnode_make2(RULE_ringcmd(3), $2, $4);
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
            }

        | ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'
            {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
                $$ = astnode_make3(RULE_ringcmd(4), $2, $4, $6);
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
            }
        ;

scriptcmd:
         SYSVAR stringexpr
            {
                enterrule("scriptcmd -> SYSVAR stringexpr");
                $$ = astnode_make2(RULE_scriptcmd(1), astint_make($1), $2);
                exitrule("scriptcmd -> SYSVAR stringexpr");
            }
        ;

setrings:
        SETRING_CMD
            {
                enterrule("setrings -> SETRING_CMD");
                $$ = astnode_make0(RULE_setrings(1));
                exitrule("setrings -> SETRING_CMD");
            }
        | KEEPRING_CMD
            {
                enterrule("setrings -> KEEPRING_CMD");
                $$ = astnode_make0(RULE_setrings(2));
                exitrule("setrings -> KEEPRING_CMD");
            }
        ;

setringcmd:
        setrings expr
            {
                enterrule("setringcmd -> setrings expr");
                $$ = astnode_make2(RULE_setringcmd(1), $1, $2);
                exitrule("setringcmd -> setrings expr");
            }
        ;

typecmd:
        TYPE_CMD expr
            {
                enterrule("typecmd -> TYPE_CMD expr");
                $$ = astnode_make1(RULE_typecmd(1), $2);
                exitrule("typecmd -> TYPE_CMD expr");
            }

        | exprlist
            {
                enterrule("typecmd -> exprlist");
                $$ = astnode_make1(RULE_typecmd(2), $1);
                exitrule_ex("typecmd -> exprlist", $$);
            }
        ;

/* --------------------------------------------------------------------*/
/* section of flow control                                             */
/* --------------------------------------------------------------------*/

ifcmd: IF_CMD '(' expr ')' '{' lines '}'
            {
                enterrule("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'");
                $$ = astnode_make2(RULE_ifcmd(1), $3, $6);
                exitrule_ex("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'",$$);
            }

        | ELSE_CMD '{' lines '}'
            {
                enterrule("ifcmd -> ELSE_CMD '{' lines '}'");
                $$ = astnode_make1(RULE_ifcmd(2), $3);
                exitrule_ex("ifcmd -> ELSE_CMD '{' lines '}'",$$);
            }

        | IF_CMD '(' expr ')' BREAK_CMD
            {
                enterrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
                $$ = astnode_make1(RULE_ifcmd(3), $3);
                exitrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
            }

        | BREAK_CMD
            {
                enterrule("ifcmd -> BREAK_CMD");
                $$ = astnode_make0(RULE_ifcmd(4));
                exitrule("ifcmd -> BREAK_CMD");
            }

        | CONTINUE_CMD
            {
                enterrule("ifcmd -> CONTINUE_CMD");
                $$ = astnode_make0(RULE_ifcmd(5));
                exitrule("ifcmd -> CONTINUE_CMD");
            }
      ;

whilecmd:
        WHILE_CMD '(' expr ')' '{' lines '}'
            {
                enterrule("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'");
                $$ = astnode_make2(RULE_whilecmd(1), $3, $6);
                exitrule_ex("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'",$$);
            }
        ;

forcmd:
        FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'
            {
                enterrule("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'");
                $$ = astnode_make4(RULE_forcmd(1), $3, $5, $7, $10);
                exitrule_ex("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'",$$);
            }
        ;

proccmd:
        PROC_CMD UNKNOWN_IDENT '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT '{' lines '}'");
                $$ = astnode_make3(RULE_proccmd(1), astint_make($1), aststring_make($2), $4);
                exitrule("proccmd -> PROC_CMD UNKNOWN_IDENT '{' lines '}'");
            }

        | PROC_CMD UNKNOWN_IDENT STRINGTOK '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT '{' lines '}'");
                $$ = astnode_make3(RULE_proccmd(1), astint_make($1), aststring_make($2), $5);
                exitrule("proccmd -> PROC_CMD UNKNOWN_IDENT '{' lines '}'");
            }

        | PROC_CMD UNKNOWN_IDENT '(' ')' '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT '(' ')' '{' lines '}'");
                $$ = astnode_make3(RULE_proccmd(1), astint_make($1), aststring_make($2), $6);
                exitrule_ex("proccmd -> PROC_CMD UNKNOWN_IDENT '(' ')' '{' lines '}'",$$);
            }

        | PROC_CMD UNKNOWN_IDENT '(' ')' STRINGTOK '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT '(' ')' '{' lines '}'");
                $$ = astnode_make3(RULE_proccmd(1), astint_make($1), aststring_make($2), $7);
                exitrule_ex("proccmd -> PROC_CMD UNKNOWN_IDENT '(' ')' '{' lines '}'",$$);
            }

        | PROC_CMD UNKNOWN_IDENT '(' procarglist ')' '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT '(' procarglist ')' '{' lines '}'");
                $$ = astnode_make4(RULE_proccmd(2), astint_make($1), aststring_make($2), $4, $7);
                exitrule_ex("proccmd -> PROC_CMD UNKNOWN_IDENT '(' procarglist ')' '{' lines '}'",$$);
            }

        | PROC_CMD UNKNOWN_IDENT '(' procarglist ')' STRINGTOK '{' lines '}'
            {
                enterrule("proccmd -> PROC_CMD UNKNOWN_IDENT STRINGTOK '(' procarglist ')' '{' lines '}'");
                $$ = astnode_make4(RULE_proccmd(2), astint_make($1), aststring_make($2), $4, $8);
                exitrule_ex("proccmd -> PROC_CMD UNKNOWN_IDENT STRINGTOK '(' procarglist ')' '{' lines '}'",$$);
            }
        ;

parametercmd:
        PARAMETER declare_ip_variable
            {
                enterrule("parametercmd -> PARAMETER declare_ip_variable");
                $$ = astnode_make1(RULE_parametercmd(1), $2);
                exitrule("parametercmd -> PARAMETER declare_ip_variable");
            }

        | PARAMETER expr
            {
                enterrule("parametercmd -> PARAMETER expr");
                $$ = astnode_make1(RULE_parametercmd(2), $2);
                exitrule("parametercmd -> PARAMETER expr");
            }
        ;

returncmd:
        RETURN '(' exprlist ')'
            {
                enterrule("returncmd -> RETURN '(' exprlist ')'");
                $$ = astnode_make1(RULE_returncmd(1), $3);
                exitrule_ex("returncmd -> RETURN '(' exprlist ')'",$$);
            }

        | RETURN '(' ')'
            {
                enterrule("returncmd -> RETURN '(' ')'");
                $$ = astnode_make0(RULE_returncmd(2));
                exitrule_ex("returncmd -> RETURN '(' ')'",$$);
            }
        ;

procarglist:
        procarglist ',' procarg
            {
                enterrule("procarglist -> procarglist ',' procarg");
                $$ = astnode_append($1, $3);
                exitrule_ex("procarglist -> procarglist ',' procarg",$$);
            }

        | procarg
            {
                enterrule("procarglist -> procarg");
                $$ = astnode_make1(RULE_procarglist(1), $1);
                exitrule_ex("procarglist -> procarg",$$);
            }
        ;

procarg:
        UNKNOWN_IDENT extendedid
            {
                enterrule("procarg -> UNKNOWN_IDENT extendedid");
                $$ = astnode_make2(RULE_procarg(1), aststring_make($1), $2);
                exitrule_ex("procarg -> UNKNOWN_IDENT extendedid",$$);
            }
        | ROOT_DECL extendedid
            {
                enterrule("procarg -> ROOT_DECL extendedid");
                $$ = astnode_make2(RULE_procarg(2), astint_make($1), $2);
                exitrule_ex("procarg -> ROOT_DECL extendedid",$$);
            }

        | ROOT_DECL_LIST extendedid
            {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                $$ = astnode_make2(RULE_procarg(3), astint_make($1), $2);
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",$$);
            }

        | RING_DECL extendedid
            {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                $$ = astnode_make2(RULE_procarg(4), astint_make($1), $2);
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",$$);
            }

        | RING_DECL_LIST extendedid
            {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                $$ = astnode_make2(RULE_procarg(5), astint_make($1), $2);
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",$$);
            }

        | PROC_CMD extendedid
            {
                enterrule("procarg -> PROC_CMD extendedid");
                $$ = astnode_make2(RULE_procarg(6), astint_make(PROC_CMD), $2);
                exitrule_ex("procarg -> PROC_CMD extendedid",$$);
            }

        | extendedid
            {
                enterrule("procarg -> extendedid");
                $$ = astnode_make2(RULE_procarg(7), astint_make(DEF_CMD), $1);
                exitrule_ex("procarg -> extendedid",$$);
            }
        ;

%%


void yyerror(astree ** retv, const char * fmt)
{
    *retv = NULL;
}

void enterrule(const char * s) {
    if (JLGRAMMAR_DBGMASK & 1) {printf(">>  %s\n",s);}
}

void exitrule(const char * s) {
    if (JLGRAMMAR_DBGMASK & 1) {
        printf("  <<%s\n\n",s);
    }
}

void exitrule_ex(const char * s, astree * expr) {
    if (JLGRAMMAR_DBGMASK & 2) {
        printf("  <<%s %p:\n",s,expr);
        fflush(stdout);
/*        jl_call1(mjl_func_mydump, expr);*/
        printf("\n\n");
        fflush(stdout);
    }
}
void exitrule_int(const char * s, int i) {
    if (JLGRAMMAR_DBGMASK & 2) {printf("  <<%s\n",s);}
}
void exitrule_str(const char * s, const char * name) {
    if (JLGRAMMAR_DBGMASK & 2) {printf("  <<%s\n",s);}
}

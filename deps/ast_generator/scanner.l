%{
/****************************************
*  Computer Algebra System SINGULAR     *
****************************************/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "tok.h"

int feReadLine(char* b, int l);
#define ALLOC(a) omAlloc((a))
#ifndef NEW_FLEX
#endif /* NEW_LEX */
int blocknest = 0;

// WARNING: different version of flex define different types for these vars
//          we do not need any of them right now
//extern char * yytext;
//extern unsigned char * yytext;
//extern yy_size_t yyleng;
//extern int inerror;

static char * dupyytext()
{
    char* s;
    if (yyleng>0) yytext[yyleng-1] = '\0';
    s = (char*)malloc((yyleng + 1) * sizeof(char));
    strncpy(s, (char *)yytext, yyleng);
    return s;
}


static char * dupyytextNL()
{
  int i = yyleng;//strlen((char *)yytext);
  char * rc = (char*)malloc(3+i);
  if (i>0)
  {
    strncpy( rc, (char *)yytext, i-1 );
  }
  else
  {
    i++;
  }
  rc[i-1] = '\n';
  rc[i] = '\n';
  rc[i+1] = '\0';
  return rc;
}

struct token_lookup_entry {
    const char * name;
    int tokval; // lvalp->i
    int toktype;
};

static struct token_lookup_entry token_lookup[] = {
{"ASSUME",          ASSUME_CMD,         ASSUME_CMD},
{"alias",           ALIAS_CMD,          PARAMETER},
{"align",           ALIGN_CMD,          CMD_2},
{"and",             '&' ,               LOGIC_OP},
{"apply",           APPLY,              APPLY},
{"attrib",          ATTRIB_CMD,         CMD_123},
{"bareiss",         BAREISS_CMD,        CMD_13},
{"betti",           BETTI_CMD,          CMD_12},
{"bigint",          BIGINT_CMD,         ROOT_DECL},
{"bigintmat",       BIGINTMAT_CMD,      BIGINTMAT_CMD},
{"branchTo",        BRANCHTO_CMD,       CMD_M},
{"break",           BREAK_CMD,          BREAK_CMD},
{"breakpoint",      BREAKPOINT_CMD ,    CMD_M},
{"char",            CHARACTERISTIC_CMD, CMD_1},
{"char_series",     CHAR_SERIES_CMD,    CMD_1},
{"charstr",         CHARSTR_CMD,        CMD_1},
{"chinrem",         CHINREM_CMD,        CMD_2},
{"cleardenom",      CONTENT_CMD,        CMD_1},
{"close",           CLOSE_CMD,          CMD_1},
{"coef",            COEF_CMD,           CMD_M},
{"coeffs",          COEFFS_CMD,         CMD_23},
{"continue",        CONTINUE_CMD,       CONTINUE_CMD},
{"contract",        CONTRACT_CMD,       CMD_2},
{"convhull",        NEWTONPOLY_CMD,     CMD_1},
{"cring",           CRING_CMD,          ROOT_DECL},
{"dbprint",         DBPRINT_CMD,        CMD_M},
{"def",             DEF_CMD,            ROOT_DECL},
{"defined",         DEFINED_CMD,        CMD_1},
{"deg",             DEG_CMD,            CMD_12},
{"degBound",        VMAXDEG,            SYSVAR},
{"degree",          DEGREE_CMD,         CMD_1},
{"delete",          DELETE_CMD,         CMD_2},
{"denominator",     DENOMINATOR_CMD,    CMD_1},
{"det",             DET_CMD,            CMD_12},
{"diff",            DIFF_CMD,           CMD_2},
{"dim",             DIM_CMD,            CMD_12},
{"div",             INTDIV_CMD,         MULDIV_OP},
{"division",        DIVISION_CMD,       CMD_M},
{"dump",            DUMP_CMD,           CMD_1},
{"echo",            VECHO,              SYSVAR},
{"extgcd",          EXTGCD_CMD,         CMD_2},
{"ERROR",           ERROR_CMD ,         CMD_1},
{"eliminate",       ELIMINATION_CMD,    CMD_23},
{"else",            ELSE_CMD ,          ELSE_CMD},
{"eval",            EVAL ,              EVAL},
{"example",         EXAMPLE_CMD ,       EXAMPLE_CMD},
{"execute",         EXECUTE_CMD ,       CMD_1},
{"export",          EXPORT_CMD ,        EXPORT_CMD},
{"exportto",        EXPORTTO_CMD ,      CMD_2},
{"facstd",          FACSTD_CMD ,        CMD_12},
{"factmodd",        FMD_CMD ,           CMD_M},
{"factorize",       FAC_CMD ,           CMD_12},
{"farey",           FAREY_CMD ,         CMD_2},
{"fetch",           FETCH_CMD ,         CMD_M},
{"fglm",            FGLM_CMD ,          CMD_2},
{"fglmquot",        FGLMQUOT_CMD,       CMD_2},
{"find",            FIND_CMD ,          CMD_23},
{"finduni",         FINDUNI_CMD,        CMD_1},
{"forif",           IF_CMD ,            IF_CMD},
{"freemodule",      FREEMODULE_CMD ,    CMD_1},
{"fres",            FRES_CMD ,          CMD_23},
{"frwalk",          FWALK_CMD ,         CMD_23},
{"gen",             E_CMD ,             CMD_1},
{"getdump",         GETDUMP_CMD,        CMD_1},
{"gcd",             GCD_CMD ,           CMD_2},
{"GCD",             GCD_CMD ,           CMD_2},
{"hilb",            HILBERT_CMD ,       CMD_123},
{"highcorner",      HIGHCORNER_CMD,     CMD_1},
{"homog",           HOMOG_CMD ,         CMD_123},
{"hres",            HRES_CMD ,          CMD_2},
{"ideal",           IDEAL_CMD,          RING_DECL_LIST},
{"if",              IF_CMD,             IF_CMD},
{"imap",            IMAP_CMD,           CMD_2},
{"impart",          IMPART_CMD,         CMD_1},
{"importfrom",      IMPORTFROM_CMD,     CMD_2},
{"indepSet",        INDEPSET_CMD,       CMD_12},
{"insert",          INSERT_CMD,         CMD_23},
{"int",             INT_CMD,            ROOT_DECL},
{"interpolation",   INTERPOLATE_CMD,    CMD_2},
{"interred",        INTERRED_CMD,       CMD_1},
{"intersect",       INTERSECT_CMD,      CMD_M},
{"intmat",          INTMAT_CMD,         INTMAT_CMD},
{"intvec",          INTVEC_CMD,         ROOT_DECL_LIST},
{"jacob",           JACOB_CMD ,         CMD_1},
{"janet",           JANET_CMD ,         CMD_12},
{"jet",             JET_CMD ,           CMD_M},
{"kbase",           KBASE_CMD ,         CMD_12},
{"keepring",        KEEPRING_CMD ,      KEEPRING_CMD},
{"kernel",          KERNEL_CMD ,        CMD_2},
{"kill",            KILL_CMD ,          KILL_CMD},
{"killattrib",      KILLATTR_CMD ,      CMD_12},
{"koszul",          KOSZUL_CMD ,        CMD_23},
{"kres",            KRES_CMD ,          CMD_2},
{"LIB",             LIB_CMD ,           SYSVAR},
{"laguerre",        LAGSOLVE_CMD,       CMD_3},
{"lead",            LEAD_CMD ,          CMD_1},
{"leadcoef",        LEADCOEF_CMD ,      CMD_1},
{"leadexp",         LEADEXP_CMD ,       CMD_1},
{"leadmonom",       LEADMONOM_CMD ,     CMD_1},
{"lift",            LIFT_CMD ,          CMD_M},
{"liftstd",         LIFTSTD_CMD ,       CMD_M},
{"link",            LINK_CMD ,          ROOT_DECL},
{"listvar",         LISTVAR_CMD ,       LISTVAR_CMD},
{"list",            LIST_CMD ,          ROOT_DECL_LIST},
{"load",            LOAD_CMD ,          CMD_12},
{"lres",            LRES_CMD ,          CMD_2},
{"ludecomp",        LU_CMD ,            CMD_1},
{"luinverse",       LUI_CMD ,           CMD_M},
{"lusolve",         LUS_CMD ,           CMD_M},
{"map",             MAP_CMD ,           RING_DECL},
{"matrix",          MATRIX_CMD ,        MATRIX_CMD},
{"maxideal",        MAXID_CMD ,         CMD_1},
{"memory",          MEMORY_CMD ,        CMD_1},
{"minbase",         MINBASE_CMD ,       CMD_1},
{"minor",           MINOR_CMD ,         CMD_M},
{"minpoly",         VMINPOLY,           SYSVAR},
{"minres",          MINRES_CMD ,        CMD_1},
{"mod",             '%' ,               MULDIV_OP},
{"module",          MODUL_CMD ,         RING_DECL_LIST},
{"modulo",          MODULO_CMD ,        CMD_2},
{"monitor",         MONITOR_CMD ,       CMD_12},
{"monomial",        MONOM_CMD ,         CMD_1},
{"mpresmat",        MPRES_CMD,          CMD_2},
{"mult",            MULTIPLICITY_CMD ,  CMD_1},
{"multBound",       VMAXMULT,           SYSVAR},
{"mres",            MRES_CMD ,          CMD_2},
{"mstd",            MSTD_CMD ,          CMD_1},
{"noether",         VNOETHER,           SYSVAR},
{"nameof",          NAMEOF_CMD ,        CMD_1},
{"names",           NAMES_CMD ,         CMD_M},
{"newstruct",       NEWSTRUCT_CMD ,     CMD_23},
{"ncols",           COLS_CMD ,          CMD_1},
{"not",             NOT ,               NOT},
{"npars",           NPARS_CMD ,         CMD_1},
{"nres",            RES_CMD ,           CMD_2},
{"nrows",           ROWS_CMD ,          CMD_1},
{"number",          NUMBER_CMD ,        RING_DECL},
{"numerator",       NUMERATOR_CMD ,     CMD_1},
{"nvars",           NVARS_CMD ,         CMD_1},
{"open",            OPEN_CMD ,          CMD_1},
{"option",          OPTION_CMD ,        CMD_M},
{"or",              '|' ,               LOGIC_OP},
{"ord",             ORD_CMD ,           CMD_1},
{"ordstr",          ORDSTR_CMD ,        CMD_1},
{"package",         PACKAGE_CMD ,       ROOT_DECL},
{"pagewidth",       VCOLMAX,            SYSVAR},
{"par",             PAR_CMD ,           CMD_1},
{"parameter",       PARAMETER ,         PARAMETER},
{"pardeg",          PARDEG_CMD ,        CMD_1},
{"parstr",          PARSTR_CMD ,        CMD_12},
{"poly",            POLY_CMD ,          RING_DECL},
{"polyBucket",      BUCKET_CMD ,        RING_DECL},
{"preimage",        PREIMAGE_CMD ,      CMD_13},
{"prime",           PRIME_CMD ,         CMD_1},
{"primefactors",    PFAC_CMD ,          CMD_12},
{"print",           PRINT_CMD ,         CMD_12},
{"printlevel",      VPRINTLEVEL,        SYSVAR},
{"prune",           PRUNE_CMD ,         CMD_1},
{"proc",            PROC_CMD ,          PROC_CMD},
{"qhweight",        QHWEIGHT_CMD ,      CMD_1},
{"qrds",            QRDS_CMD ,          CMD_M},
{"qring",           QRING_CMD ,         ROOT_DECL},
{"quote",           QUOTE ,             QUOTE},
{"quotient",        QUOTIENT_CMD ,      CMD_2},
{"random",          RANDOM_CMD,         CMD_23},
{"rank",            RANK_CMD,           CMD_12},
{"read",            READ_CMD,           CMD_12},
{"reduce",          REDUCE_CMD,         CMD_M},
{"regularity",      REGULARITY_CMD,     CMD_1},
{"repart",          REPART_CMD,         CMD_1},
{"reservedName",    RESERVEDNAME_CMD,   CMD_M},
/*{"reservedNameList",RESERVEDNAMELIST_CMD ,  CMD_M},*/
{"resolution",      RESOLUTION_CMD,     RING_DECL},
{"resultant",       RESULTANT_CMD,      CMD_3},
{"restart",         RESTART_CMD,        CMD_1},
{"return",          RETURN,             RETURN},
{"ring",            RING_CMD,           RING_CMD},
{"ringlist",        RINGLIST_CMD,       CMD_1},
{"ring_list",       RING_LIST_CMD,      CMD_1},
{"rtimer",          VRTIMER,            SYSVAR},
{"rvar",            IS_RINGVAR,         CMD_1},
{"sba",             SBA_CMD,            CMD_123},
{"setring",         SETRING_CMD,        SETRING_CMD},
{"simplex",         SIMPLEX_CMD,        CMD_M},
{"simplify",        SIMPLIFY_CMD,       CMD_2},
{"size",            COUNT_CMD,          CMD_1},
{"slimgb",          SLIM_GB_CMD,        CMD_1},
{"short",           VSHORTOUT ,         SYSVAR},
{"smatrix",         SMATRIX_CMD,        SMATRIX_CMD},
{"sortvec",         SORTVEC_CMD,        CMD_1},
{"sqrfree",         SQR_FREE_CMD,       CMD_12},
{"sres",            SRES_CMD,           CMD_2},
{"status",          STATUS_CMD,         CMD_M},
{"std",             STD_CMD,            CMD_M},
{"string",          STRING_CMD,         ROOT_DECL_LIST},
{"subst",           SUBST_CMD,          CMD_M},
{"system",          SYSTEM_CMD,         CMD_M},
{"syz",             SYZYGY_CMD,         CMD_12},
{"tensor",          TENSOR_CMD ,        CMD_2},
{"test",            TEST_CMD ,          CMD_M},
{"trace",           TRACE_CMD ,         CMD_1},
{"TRACE",           TRACE ,             SYSVAR},
{"transpose",       TRANSPOSE_CMD ,     CMD_1},
{"timer",           VTIMER,             SYSVAR},
{"type",            TYPE_CMD ,          TYPE_CMD},
{"typeof",          TYPEOF_CMD,         CMD_1},
{"univariate",      UNIVARIATE_CMD,     CMD_1},
{"uressolve",       URSOLVE_CMD,        CMD_M},
{"vandermonde",     VANDER_CMD,         CMD_3},
{"var",             VAR_CMD ,           CMD_1},
{"variables",       VARIABLES_CMD,      CMD_1},
{"varstr",          VARSTR_CMD,         CMD_12},
{"vdim",            VDIM_CMD,           CMD_1},
{"vector",          VECTOR_CMD,         RING_DECL},
{"voice",           VOICE,              SYSVAR},
{"wedge",           WEDGE_CMD ,         CMD_2},
{"weight",          WEIGHT_CMD ,        CMD_1},
{"write",           WRITE_CMD ,         CMD_M},
};


  #undef YY_DECL
  #define YY_DECL int yylex(YYSTYPE* lvalp)



//#define YY_INPUT(buf,result,max_size) \
//    { \
//    int c = getchar(); \
//    result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
//    }

%}

digit          [0-9]
letter         [@a-zA-Z\']
integer        {digit}+
monom          {letter}+{digit}*
rgvars         ({digit}+[/])*{digit}+{monom}+
realnum        {digit}*"."{digit}+("e"[+-]{digit}+)?
name           ({letter}({letter}*{digit}*_*)*|_)
parname        #

/* %start START */
%option never-interactive

%x string
%x brace
%x bracestr
%x bracket
%x asstring

%%
\/\/[^\n]*
^[ \r\t\n]*#![^\n]*
"/*"                     {
                            while (1) {
                                int c;
                                while ( (c = input()) != '*' && c != EOF );
                                if ( c == '*' ) {
                                    while ( (c = input()) == '*' );
                                    if ( c == '/' ) break; /* found the end */
                                } else {
                                    break;
                                }
                            }
                         }
static[ \t\n]+proc      {
                            return STATIC_PROC_CMD;
                        }
proc                    {
                            return PROC_CMD;
                        }
if                      {
                            return IF_CMD;
                        }
else                    {
                            return ELSE_CMD;
                        }
while                   {
                            return WHILE_CMD;
                        }
for                     {
                            return FOR_CMD;
                        }
return                  {
                            return RETURN;
                        }

("help"|"?")[ \t\n]*     {
                           BEGIN(asstring);
                           return HELP_CMD;
                         }

example[ \t\n]*          {
                           BEGIN(asstring);
                           return EXAMPLE_CMD;
                         }
<asstring>[^;\n]+        {
                           lvalp->name = dupyytext();
                           BEGIN(INITIAL);
                           return STRINGTOK;
                         }
<asstring>;              {
                           BEGIN(INITIAL);
                           return *yytext;
                         }

<brace>"\""              {
                           BEGIN(bracestr);
                           yymore();
                         }
<brace>"("               { if (blocknest++) yymore(); }
<brace>[^;\(\)]          { if (blocknest) yymore(); }
<brace>";"               {
                           if (blocknest)
                           {
                             lvalp->name = dupyytext();
                             return STRINGTOK;
                           }
                         }
<brace>")"               {
                           if (--blocknest <= 0)
                           {
                             BEGIN(INITIAL);
                             lvalp->name = dupyytext();
                             return STRINGTOK;
                           }
                           yymore();
                         }
<bracestr>"\""           {
                           BEGIN(brace);
                           yymore();
                         }
<bracestr>[^\"]          { yymore(); }
<bracket>"("             {
                            return '(';
                          }
<bracket>","             {
                            return ','; 
                         }
<bracket>[ \t\n]*        { ; }
<bracket>[^\(\), \t\n]*  {
                           lvalp->name = dupyytext();
                           return STRINGTOK;
                         }
<bracket>\"[^\"]*\"      {
                           lvalp->name = dupyytext();
                           return STRINGTOK;
                         }
<bracket>")"             {
                           BEGIN(INITIAL);
                           return ')';
                         }

"{"                      {
                           BEGIN(INITIAL);
                           return '{';
                         }
"}"                      {
                           BEGIN(INITIAL);
                           return '}';
                         }
"\""                     { BEGIN(string);}
~                        { return SYS_BREAK; }
<string>[^\"]            { yymore(); }
<string>"\\\\"           { yymore(); }
<string>"\\\""           { yymore(); }
<string>"\""             {
                           char * s;
                           BEGIN(INITIAL);
                           s = lvalp->name = dupyytext();
                           s = lvalp->name = dupyytext();
                           while (*yytext)
                           {
                             if (*yytext == '\\') yytext++;
                             *s++ = *yytext++;
                           }
                           *s++ = *yytext++;
                           return STRINGTOK;
                         }

[ \t\r\n]                /* skip whitespace */
".."                     { return DOTDOT; }
"::"                     { return COLONCOLON; }
"--"                     { return MINUSMINUS; }
"++"                     { return PLUSPLUS  ; }
"=="                     { return EQUAL_EQUAL; }
"&&"                     { lvalp->i='&'; return LOGIC_OP; }
"||"                     { lvalp->i='|'; return LOGIC_OP; }
"<="                     { lvalp->i=LE; return COMP_OP; }
">="                     { lvalp->i=GE; return COMP_OP; }
"!"                      { return NOT; }
"!="                     { return NOTEQUAL; }
"<>"                     { return NOTEQUAL; }
"**"                     { return '^'; }
"->"                     { return ARROW; }
\\                       { return '\\'; }
newline                  {
                           lvalp->name = duplicate_string("\n");
                           return STRINGTOK;
                         }
{integer}                {
                           lvalp->name = duplicate_string(yytext);
                           return INT_CONST;
                         }
\$                       {
                           lvalp->name = duplicate_string(yytext);
                           return INT_CONST;
                         }
(quit|exit)[ \t\n]*;     {
                           lvalp->name = duplicate_string(yytext);
                            return INT_CONST;
                         }

{rgvars}|{realnum}       {
                           lvalp->name = duplicate_string(yytext);
                           return RINGVAR;
                         }
[0-9]+\."e"[+-][0-9]+    {
                           lvalp->name = duplicate_string(yytext);
                           return RINGVAR;
                         }
[0-9]+\./[^\.]           {
                           lvalp->name = duplicate_string(yytext);
                           return RINGVAR;
                         }

({parname}|{name})      {
                           /* {name} */

                            int rc = 0;
                            for (int i = 0; i < sizeof(token_lookup)/sizeof(struct token_lookup_entry); i++)
                            {
                                if (strcmp(yytext, token_lookup[i].name) == 0)
                                {
                                    lvalp->i = token_lookup[i].tokval;
                                    rc = token_lookup[i].toktype;
                                    break;
                                }
                            }
                            if (rc)
                            {
//printf("SCANNER: %s RETURN %d with lpval->i = %d\n", yytext, rc, lvalp->i);
                                return rc;
                            }

                            lvalp->name = duplicate_string(yytext);
                            return UNKNOWN_IDENT;
                        }

.                       {
                           /*if (*yytext == '\n') REJECT;*/
                           char ch= *yytext;
                           lvalp->i = ch;
                           switch(ch)
                           {
                             /* case '&': */
                             case '|':
                               return LOGIC_OP;
                             /* case '/': */
                             case '%':
                             case '*':
                               return MULDIV_OP;
                             /* case '<': */
                             case '>':
                               return COMP_OP;
                             default:
                               break;
                            }
                            return ch;
                         }
%%

void * myynewbuffer()
{
  void * oldb = YY_CURRENT_BUFFER;
  yy_switch_to_buffer(yy_create_buffer(NULL, YY_BUF_SIZE));
  return oldb;
}

void myyoldbuffer(void * oldb)
{
  yy_delete_buffer(YY_CURRENT_BUFFER);
  yy_switch_to_buffer((YY_BUFFER_STATE)oldb);
  //yy_flush_buffer((YY_BUFFER_STATE)oldb);
}

void myychangebuffer()
{
  yy_flush_buffer((YY_BUFFER_STATE)YY_CURRENT_BUFFER);
  yy_delete_buffer(YY_CURRENT_BUFFER);
  yy_switch_to_buffer(yy_create_buffer(NULL, YY_BUF_SIZE));
}

void my_yy_flush() { YY_FLUSH_BUFFER;BEGIN(0); }


int yywrap() {
   return 1;
}

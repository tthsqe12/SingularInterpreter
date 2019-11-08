/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 7 "grammar.y" /* yacc.c:339  */


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

#line 96 "grammar.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "grammar.tab.h".  */
#ifndef YY_YY_GRAMMAR_TAB_H_INCLUDED
# define YY_YY_GRAMMAR_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    DOTDOT = 258,
    EQUAL_EQUAL = 259,
    GE = 260,
    LE = 261,
    MINUSMINUS = 262,
    NOT = 263,
    NOTEQUAL = 264,
    PLUSPLUS = 265,
    COLONCOLON = 266,
    ARROW = 267,
    GRING_CMD = 268,
    BIGINTMAT_CMD = 269,
    INTMAT_CMD = 270,
    PROC_CMD = 271,
    STATIC_PROC_CMD = 272,
    RING_CMD = 273,
    BEGIN_RING = 274,
    BUCKET_CMD = 275,
    IDEAL_CMD = 276,
    MAP_CMD = 277,
    MATRIX_CMD = 278,
    MODUL_CMD = 279,
    NUMBER_CMD = 280,
    POLY_CMD = 281,
    RESOLUTION_CMD = 282,
    SMATRIX_CMD = 283,
    VECTOR_CMD = 284,
    BETTI_CMD = 285,
    E_CMD = 286,
    FETCH_CMD = 287,
    FREEMODULE_CMD = 288,
    KEEPRING_CMD = 289,
    IMAP_CMD = 290,
    KOSZUL_CMD = 291,
    MAXID_CMD = 292,
    MONOM_CMD = 293,
    PAR_CMD = 294,
    PREIMAGE_CMD = 295,
    VAR_CMD = 296,
    VALTVARS = 297,
    VMAXDEG = 298,
    VMAXMULT = 299,
    VNOETHER = 300,
    VMINPOLY = 301,
    END_RING = 302,
    CMD_1 = 303,
    CMD_2 = 304,
    CMD_3 = 305,
    CMD_12 = 306,
    CMD_13 = 307,
    CMD_23 = 308,
    CMD_123 = 309,
    CMD_M = 310,
    ROOT_DECL = 311,
    ROOT_DECL_LIST = 312,
    RING_DECL = 313,
    RING_DECL_LIST = 314,
    EXAMPLE_CMD = 315,
    EXPORT_CMD = 316,
    HELP_CMD = 317,
    KILL_CMD = 318,
    LIB_CMD = 319,
    LISTVAR_CMD = 320,
    SETRING_CMD = 321,
    TYPE_CMD = 322,
    STRINGTOK = 323,
    INT_CONST = 324,
    UNKNOWN_IDENT = 325,
    RINGVAR = 326,
    PROC_DEF = 327,
    APPLY = 328,
    ASSUME_CMD = 329,
    BREAK_CMD = 330,
    CONTINUE_CMD = 331,
    ELSE_CMD = 332,
    EVAL = 333,
    QUOTE = 334,
    FOR_CMD = 335,
    IF_CMD = 336,
    SYS_BREAK = 337,
    WHILE_CMD = 338,
    RETURN = 339,
    PARAMETER = 340,
    QUIT_CMD = 341,
    SYSVAR = 342,
    UMINUS = 343
  };
#endif

/* Value type.  */



int yyparse (astree ** retv);

#endif /* !YY_YY_GRAMMAR_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 230 "grammar.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   3406

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  107
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  49
/* YYNRULES -- Number of rules.  */
#define YYNRULES  203
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  471

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   343

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    98,     2,
     101,   102,     2,    90,    96,    91,   105,    92,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    99,    97,
      89,    88,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    93,     2,    94,    95,     2,   106,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   103,     2,   104,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,   100
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   202,   202,   209,   219,   226,   233,   240,   247,   254,
     263,   269,   278,   285,   292,   299,   306,   313,   320,   330,
     337,   344,   351,   358,   365,   374,   381,   388,   395,   402,
     409,   416,   423,   431,   439,   446,   453,   460,   467,   474,
     481,   488,   495,   503,   512,   519,   526,   533,   540,   547,
     554,   561,   568,   575,   582,   589,   596,   603,   610,   617,
     624,   631,   638,   645,   652,   659,   666,   673,   680,   687,
     694,   701,   708,   715,   722,   729,   736,   743,   750,   757,
     764,   773,   780,   788,   795,   802,   809,   816,   823,   830,
     837,   844,   851,   858,   865,   872,   880,   879,   893,   901,
     909,   918,   925,   932,   939,   946,   968,   975,   997,  1011,
    1018,  1025,  1032,  1039,  1046,  1055,  1062,  1072,  1079,  1089,
    1096,  1103,  1110,  1117,  1124,  1131,  1138,  1145,  1154,  1163,
    1170,  1179,  1188,  1194,  1203,  1210,  1219,  1226,  1234,  1243,
    1250,  1257,  1270,  1279,  1286,  1295,  1304,  1313,  1320,  1329,
    1336,  1343,  1350,  1357,  1364,  1371,  1378,  1385,  1392,  1399,
    1406,  1413,  1420,  1427,  1434,  1443,  1452,  1463,  1470,  1477,
    1486,  1495,  1501,  1510,  1519,  1526,  1538,  1545,  1552,  1559,
    1566,  1575,  1584,  1593,  1600,  1607,  1614,  1621,  1628,  1635,
    1642,  1651,  1658,  1667,  1674,  1683,  1690,  1699,  1705,  1712,
    1719,  1726,  1733,  1740
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "DOTDOT", "EQUAL_EQUAL", "GE", "LE",
  "MINUSMINUS", "NOT", "NOTEQUAL", "PLUSPLUS", "COLONCOLON", "ARROW",
  "GRING_CMD", "BIGINTMAT_CMD", "INTMAT_CMD", "PROC_CMD",
  "STATIC_PROC_CMD", "RING_CMD", "BEGIN_RING", "BUCKET_CMD", "IDEAL_CMD",
  "MAP_CMD", "MATRIX_CMD", "MODUL_CMD", "NUMBER_CMD", "POLY_CMD",
  "RESOLUTION_CMD", "SMATRIX_CMD", "VECTOR_CMD", "BETTI_CMD", "E_CMD",
  "FETCH_CMD", "FREEMODULE_CMD", "KEEPRING_CMD", "IMAP_CMD", "KOSZUL_CMD",
  "MAXID_CMD", "MONOM_CMD", "PAR_CMD", "PREIMAGE_CMD", "VAR_CMD",
  "VALTVARS", "VMAXDEG", "VMAXMULT", "VNOETHER", "VMINPOLY", "END_RING",
  "CMD_1", "CMD_2", "CMD_3", "CMD_12", "CMD_13", "CMD_23", "CMD_123",
  "CMD_M", "ROOT_DECL", "ROOT_DECL_LIST", "RING_DECL", "RING_DECL_LIST",
  "EXAMPLE_CMD", "EXPORT_CMD", "HELP_CMD", "KILL_CMD", "LIB_CMD",
  "LISTVAR_CMD", "SETRING_CMD", "TYPE_CMD", "STRINGTOK", "INT_CONST",
  "UNKNOWN_IDENT", "RINGVAR", "PROC_DEF", "APPLY", "ASSUME_CMD",
  "BREAK_CMD", "CONTINUE_CMD", "ELSE_CMD", "EVAL", "QUOTE", "FOR_CMD",
  "IF_CMD", "SYS_BREAK", "WHILE_CMD", "RETURN", "PARAMETER", "QUIT_CMD",
  "SYSVAR", "'='", "'<'", "'+'", "'-'", "'/'", "'['", "']'", "'^'", "','",
  "';'", "'&'", "':'", "UMINUS", "'('", "')'", "'{'", "'}'", "'.'", "'`'",
  "$accept", "top_lines", "top_pprompt", "lines", "pprompt", "npprompt",
  "flowctrl", "example_dummy", "command", "assign", "elemexpr", "exprlist",
  "expr", "$@1", "quote_start", "assume_start", "quote_end",
  "expr_arithmetic", "left_value", "extendedid", "declare_ip_variable",
  "stringexpr", "rlist", "ordername", "orderelem", "OrderingList",
  "ordering", "cmdeq", "mat_cmd", "filecmd", "helpcmd", "examplecmd",
  "exportcmd", "killcmd", "listcmd", "ringcmd1", "ringcmd", "scriptcmd",
  "setrings", "setringcmd", "typecmd", "ifcmd", "whilecmd", "forcmd",
  "proccmd", "parametercmd", "returncmd", "procarglist", "procarg", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,    61,    60,
      43,    45,    47,    91,    93,    94,    44,    59,    38,    58,
     343,    40,    41,   123,   125,    46,    96
};
# endif

#define YYPACT_NINF -424

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-424)))

#define YYTABLE_NINF -169

#define yytable_value_is_error(Yytable_value) \
  (!!((Yytable_value) == (-169)))

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    -424,   424,  -424,   -74,  3099,  -424,  -424,   -39,   -14,   -35,
    -424,  -424,   -28,   -23,   -21,   -18,    57,    77,   107,   119,
     -37,   -16,     7,   132,   -57,  3099,   -13,  3099,   122,  -424,
    3099,  -424,  -424,   -53,  -424,   131,   134,  -424,  -424,   141,
     145,   153,   155,   186,  -424,   199,  3166,    36,    36,  3099,
    3099,  -424,  3099,  3099,  -424,  -424,  -424,   154,  -424,     4,
     -58,  2598,  3099,  3099,  -424,  3099,   307,   -75,  -424,   146,
    -424,  -424,  -424,  -424,   229,  -424,  3099,  -424,  -424,  3099,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,   226,   -35,
     232,   241,   247,   250,  -424,  -424,    37,   257,   -31,  3099,
    -424,   168,  3233,  3099,  3099,  3099,  3099,  3099,  3099,  3099,
    2697,  3099,  -424,  2764,  -424,  3099,  -424,  2831,  -424,   263,
    -424,   266,   271,  -424,    48,  2598,  2898,  2598,  -424,  3099,
    -424,  -424,  -424,  -424,  1834,  3099,  3099,   164,  2598,   275,
    -424,  -424,    37,   -62,   -82,   218,  -424,  3099,  2965,  -424,
    3099,  -424,  3099,  3099,  -424,  3099,  -424,  3099,  3099,  3099,
    3099,  3099,  3099,  3099,  3099,  3099,    91,  1492,   266,   272,
     -53,  -424,  -424,  3099,   289,  3099,   129,  2598,   276,  2497,
    -424,   274,   283,  2604,  -424,  3099,  1678,   294,  1863,  1927,
    1960,   254,   552,  1971,   740,  -424,   -20,  1982,  -424,    33,
    1999,  -424,    92,  -424,   518,  -424,   -83,   -66,    90,   117,
     174,   201,  -424,     1,   203,  2024,   612,  3099,  -424,  -424,
     300,   305,  -424,  -424,    -9,  -424,  2035,  2096,  -424,  -424,
    -424,  -424,  -424,    99,  2598,   452,   150,   150,   646,    17,
      17,    37,  1852,    61,  2609,    17,  -424,  3099,  -424,  -424,
    3099,  -424,  -424,   928,  3099,   284,  3233,    -7,   -53,   -53,
     -53,   -53,   -53,   -53,   301,  -424,   103,  -424,   706,  -424,
      -7,   303,   104,   800,  2132,  -424,  3233,  -424,  3099,  3099,
    3099,  -424,  3099,  -424,  3099,  3099,  -424,  -424,  -424,  -424,
    -424,  -424,   306,  -424,  -424,  -424,  -424,  -424,   312,    55,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,   377,  -424,  -424,
    3300,  -424,  2143,  3032,  3099,    31,   308,  -424,  -424,  3099,
    2160,  2160,   894,  3099,  -424,  2193,   239,  2598,   316,   108,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,    -7,   315,  -424,
     177,  -424,   317,  -424,  3099,   325,  2204,  2257,  2268,  2301,
    1116,  1304,  -424,  -424,  -424,   320,   326,   327,   335,   341,
     343,   354,   213,   228,   237,   253,   287,  2312,  -424,  -424,
     178,  2329,  -424,  -424,  -424,  2365,  -424,  -424,  -424,  2376,
     364,  3099,  3233,   357,   988,  -424,  -424,   360,  1082,  -424,
     197,   -41,  -424,  3099,  -424,  3099,  3099,  -424,  3099,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  1834,  1176,  1270,  -424,  3099,  3099,
     113,   368,  -424,  -424,  1364,  -424,  -424,  1458,  -424,  -424,
     395,   365,  -424,   367,  2426,  2443,  2473,  2490,   369,  -424,
    -424,  2540,  2587,  -424,   -41,  1552,  -424,  1646,  -424,   371,
     386,  3099,  -424,  -424,  -424,  -424,  -424,   393,  -424,  -424,
    -424,  -424,  -424,   395,  -424,   216,  -424,  -424,  -424,  1740,
    -424
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     1,     0,     0,   141,   140,     0,     0,   165,
     139,   172,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   171,
       0,   128,    51,   117,    44,     0,     0,   179,   180,     0,
       0,     0,     0,     0,     7,     0,     0,    52,     0,     0,
       0,     8,     0,     0,     3,     4,    27,     0,    34,    84,
     175,    82,     0,     0,    83,     0,    45,     0,    53,     0,
      30,    31,    32,    35,    36,    37,     0,    39,    40,     0,
      41,    42,    25,    26,    28,    29,    38,     9,     0,     0,
       0,     0,     0,     0,   117,    52,   113,     0,   117,     0,
     127,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   119,     0,   121,     0,   122,     0,   123,     0,
      10,   146,     0,   144,    84,     0,     0,   174,   120,     0,
      99,    10,    96,    98,     0,     0,     0,     0,   192,   191,
     170,   142,   114,     0,     0,     0,     5,     0,     0,   138,
       0,   116,     0,     0,   102,     0,   101,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    43,     0,
       0,     6,   115,     0,   125,     0,    84,   173,     0,     0,
      10,     0,     0,     0,    10,     0,   129,     0,     0,     0,
       0,     0,     0,     0,     0,    73,     0,     0,    57,     0,
       0,    60,     0,   145,     0,   143,     0,     0,     0,     0,
       0,     0,   164,    84,     0,     0,     0,     0,    24,    23,
       0,     0,    19,    20,    21,    22,     0,     0,    50,    80,
     118,    46,    48,     0,    81,   111,   110,   109,   107,   103,
     104,   105,     0,   106,   108,   112,    47,     0,   100,    93,
       0,    10,   126,     0,     0,    84,     0,     0,     0,     0,
       0,     0,     0,   117,     0,   203,     0,   196,     0,    54,
       0,     0,     0,     0,    82,    78,     0,    61,     0,     0,
       0,    62,     0,    63,     0,     0,    64,    74,    55,    56,
      58,    59,     0,    16,    17,    33,    11,    12,     0,     0,
      15,   155,   153,   149,   150,   151,   152,     0,   156,   154,
       0,   177,     0,     0,     0,     0,     0,    49,    86,     0,
       0,     0,     0,     0,    76,     0,    84,   129,     0,     0,
     202,   198,   199,   200,   201,   197,    10,     0,     0,   183,
       0,    10,     0,   187,     0,     0,     0,     0,     0,     0,
       0,     0,    18,    13,    14,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    97,   194,
       0,     0,   178,    10,    10,     0,    94,    95,    79,     0,
       0,     0,     0,     0,     0,   195,    10,     0,     0,    10,
       0,     0,    65,     0,    66,     0,     0,    67,     0,    68,
     163,   161,   157,   158,   159,   160,   162,    87,    88,    89,
      90,    91,    92,   193,     0,     0,     0,    85,     0,     0,
       0,     0,    10,   184,     0,    10,   188,     0,   130,   131,
       0,   132,   136,     0,     0,     0,     0,     0,     0,   176,
     181,     0,     0,   169,     0,     0,   185,     0,   189,   134,
       0,     0,    77,    69,    70,    71,    72,     0,    75,   124,
     166,   186,   190,     0,   137,     0,    10,   135,   133,     0,
     182
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -424,  -424,  -424,   -88,  -424,    56,     3,  -424,     5,  -424,
     -19,   -24,    12,  -424,  -424,  -424,    76,  -424,  -424,   191,
       2,   351,  -251,  -424,  -423,    45,    66,   -50,    -1,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,  -424,
    -424,  -424,  -424,  -424,  -424,  -424,  -132,  -102,   175
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     1,    54,   204,   296,   221,   297,    56,   298,    58,
      59,    60,    61,   217,    62,    63,   249,    64,    65,    66,
     299,    68,   187,   431,   432,   450,   433,   172,    97,    70,
      71,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,    82,    83,    84,    85,    86,   300,   266,   267
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      69,   121,   225,    67,    55,   328,    57,   449,   124,   258,
     151,   119,   147,   149,   150,   147,    96,    94,    99,   301,
     229,   170,   171,    87,   154,   345,   143,   156,   144,   429,
     149,    98,   228,    94,   150,   102,   302,   178,   150,   125,
     449,   168,   127,   216,   154,    69,   120,   156,   139,   259,
     260,   261,   262,    53,    94,   122,   101,   176,   138,   147,
     430,   142,    99,   263,   111,   145,   102,    53,   154,    53,
     179,   156,   180,   103,   166,   167,   150,    94,   104,   149,
     105,   272,   287,   106,   123,   113,   196,   170,   125,   199,
      53,   177,   268,   202,   152,   153,   273,   307,   154,    53,
     155,   156,   148,   308,    31,   148,   372,   213,   115,   160,
     161,   181,   162,    53,   186,   188,   189,   190,   191,   192,
     193,   194,   165,   197,   233,   214,   256,   200,   231,   150,
     161,   421,   162,    69,   373,   289,   224,   222,   125,   223,
     147,   215,   165,   149,  -147,  -147,   246,   226,   227,   148,
    -147,   170,   354,   152,   161,   329,   255,   154,   107,   125,
     156,   144,   234,   322,   235,   236,   165,   237,   340,   238,
     239,   240,   241,   242,   243,   244,   245,   125,   108,   247,
     157,   158,   159,   160,   161,   253,   162,   125,   150,   163,
     164,   111,   303,   248,   291,   150,   165,   274,   100,   337,
     337,   317,    94,    69,   337,   338,   342,   443,   109,   150,
     383,   112,   114,   116,   118,    69,    94,   149,   113,   304,
     110,   152,   153,   126,   128,   154,  -167,   155,   156,   312,
     148,  -167,   129,   117,    94,   130,   182,   326,    53,   157,
     158,   159,   160,   161,   131,   162,   132,   173,   384,   164,
     147,   146,    53,   388,   133,   165,   134,   152,   153,   320,
     174,   154,   321,   155,   156,    99,   325,    69,   327,   183,
      53,   184,    69,   337,   150,   115,   305,   152,   153,   387,
     413,   154,   225,   155,   156,   415,   416,   135,   327,   370,
     346,   347,   348,   150,   349,   147,   350,   351,   424,   428,
     136,   427,   117,   306,   173,   309,   361,   157,   158,   159,
     160,   161,   150,   162,   103,   407,   163,   164,   468,   169,
     390,    69,   367,   165,   230,   175,   371,    99,   100,   106,
     408,   375,   381,   111,   445,   379,  -168,   447,   107,   409,
     148,  -168,   113,   157,   158,   159,   160,   161,   115,   162,
     280,   117,   163,   164,   109,   410,   281,   420,   173,   165,
     203,   252,   150,   157,   158,   159,   160,   161,   205,   162,
     265,   170,   163,   164,   265,   251,   269,   257,   469,   165,
    -148,  -148,   254,    69,   270,   148,  -148,    69,   110,   411,
     276,     5,     6,   355,   327,   356,   376,   377,   140,   141,
      10,   313,   314,   352,   336,   434,   341,   435,   436,   353,
     437,   374,   382,    69,    69,    69,   224,   222,   386,   223,
     389,   391,   400,    69,     2,     3,    69,   465,   401,   402,
     441,   442,     4,   357,   358,   359,   360,   403,     5,     6,
       7,     8,     9,   404,    69,   405,    69,    10,   265,   330,
     331,   332,   333,   334,   335,  -169,   406,   419,    11,   154,
     422,   265,   156,   425,   444,   429,   451,   463,    69,   452,
     438,   457,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,   464,    28,
      29,    30,    31,    32,    33,    34,   466,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    45,   467,    46,
     460,    47,   385,    48,     0,    49,     0,    50,     0,   292,
       0,    51,     0,     0,     0,    52,     4,     0,   265,     0,
      53,     0,     5,     6,     7,     8,     9,     0,     0,     0,
       0,    10,   158,   159,   160,   161,     0,   162,     0,     0,
       0,   164,    11,     0,     0,   152,   153,   165,     0,   154,
       0,   155,   156,     0,     0,     0,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,     0,    28,    29,    30,    31,    32,    33,    34,
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
     293,    45,   220,    46,     0,    47,     0,    48,     0,    49,
       0,    50,     0,   292,     0,   294,     0,     0,     0,    52,
       4,     0,   295,     0,    53,     0,     5,     6,     7,     8,
       9,     0,     0,     0,     0,    10,     0,     0,     0,     0,
       0,   157,   158,   159,   160,   161,    11,   162,   282,   152,
     163,   164,     0,   154,   283,     0,   156,   165,     0,     0,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,     0,    28,    29,    30,
      31,    32,    33,    34,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,   293,    45,   220,    46,     0,    47,
       0,    48,     0,    49,     0,    50,     0,   292,     0,   294,
       0,     0,     0,    52,     4,     0,   311,     0,    53,     0,
       5,     6,     7,     8,     9,     0,     0,     0,     0,    10,
       0,     0,     0,     0,     0,     0,   158,   159,   160,   161,
      11,   162,     0,   152,   153,   164,     0,   154,     0,   155,
     156,   165,     0,     0,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
       0,    28,    29,    30,    31,    32,    33,    34,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,   293,    45,
     220,    46,     0,    47,     0,    48,     0,    49,     0,    50,
       0,   292,     0,   294,     0,     0,     0,    52,     4,     0,
     339,     0,    53,     0,     5,     6,     7,     8,     9,     0,
       0,     0,     0,    10,     0,     0,     0,     0,     0,   157,
     158,   159,   160,   161,    11,   162,   285,     0,   163,   164,
       0,     0,   286,     0,     0,   165,     0,     0,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,     0,    28,    29,    30,    31,    32,
      33,    34,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,   293,    45,   220,    46,     0,    47,     0,    48,
       0,    49,     0,    50,     0,   292,     0,   294,     0,     0,
       0,    52,     4,     0,   343,     0,    53,     0,     5,     6,
       7,     8,     9,     0,     0,     0,     0,    10,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    11,     0,
       0,   152,   153,     0,     0,   154,     0,   155,   156,     0,
       0,     0,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,     0,    28,
      29,    30,    31,    32,    33,    34,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,   293,    45,   220,    46,
       0,    47,     0,    48,     0,    49,     0,    50,     0,   292,
       0,   294,     0,     0,     0,    52,     4,     0,   378,     0,
      53,     0,     5,     6,     7,     8,     9,     0,     0,     0,
       0,    10,     0,     0,     0,     0,     0,   157,   158,   159,
     160,   161,    11,   162,   323,     0,   163,   164,     0,     0,
     324,     0,     0,   165,     0,     0,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,     0,    28,    29,    30,    31,    32,    33,    34,
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
     293,    45,   220,    46,     0,    47,     0,    48,     0,    49,
       0,    50,     0,   292,     0,   294,     0,     0,     0,    52,
       4,     0,   423,     0,    53,     0,     5,     6,     7,     8,
       9,     0,     0,     0,     0,    10,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    11,     0,     0,   152,
     153,     0,     0,   154,     0,   155,   156,     0,     0,     0,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,     0,    28,    29,    30,
      31,    32,    33,    34,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,   293,    45,   220,    46,     0,    47,
       0,    48,     0,    49,     0,    50,     0,   292,     0,   294,
       0,     0,     0,    52,     4,     0,   426,     0,    53,     0,
       5,     6,     7,     8,     9,     0,     0,     0,     0,    10,
       0,     0,     0,     0,     0,   157,   158,   159,   160,   161,
      11,   162,   396,     0,   163,   164,     0,     0,   397,     0,
       0,   165,     0,     0,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
       0,    28,    29,    30,    31,    32,    33,    34,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,   293,    45,
     220,    46,     0,    47,     0,    48,     0,    49,     0,    50,
       0,   292,     0,   294,     0,     0,     0,    52,     4,     0,
     439,     0,    53,     0,     5,     6,     7,     8,     9,     0,
       0,     0,     0,    10,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    11,     0,     0,   152,   153,     0,
       0,   154,     0,   155,   156,     0,     0,     0,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,     0,    28,    29,    30,    31,    32,
      33,    34,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,   293,    45,   220,    46,     0,    47,     0,    48,
       0,    49,     0,    50,     0,   292,     0,   294,     0,     0,
       0,    52,     4,     0,   440,     0,    53,     0,     5,     6,
       7,     8,     9,     0,     0,     0,     0,    10,     0,     0,
       0,     0,     0,   157,   158,   159,   160,   161,    11,   162,
     398,     0,   163,   164,     0,     0,   399,     0,     0,   165,
       0,     0,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,     0,    28,
      29,    30,    31,    32,    33,    34,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,   293,    45,   220,    46,
       0,    47,     0,    48,     0,    49,     0,    50,     0,   292,
       0,   294,     0,     0,     0,    52,     4,     0,   446,     0,
      53,     0,     5,     6,     7,     8,     9,     0,     0,     0,
       0,    10,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    11,     0,     0,   152,   153,     0,     0,   154,
       0,   155,   156,     0,     0,     0,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,    27,     0,    28,    29,    30,    31,    32,    33,    34,
       0,    35,    36,    37,    38,    39,    40,    41,    42,    43,
     293,    45,   220,    46,     0,    47,     0,    48,     0,    49,
       0,    50,     0,   292,     0,   294,     0,     0,     0,    52,
       4,     0,   448,     0,    53,     0,     5,     6,     7,     8,
       9,     0,     0,     0,     0,    10,     0,     0,     0,     0,
       0,   157,   158,   159,   160,   161,    11,   162,   250,     0,
     163,   164,     0,     0,     0,     0,     0,   165,     0,     0,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,    27,     0,    28,    29,    30,
      31,    32,    33,    34,     0,    35,    36,    37,    38,    39,
      40,    41,    42,    43,   293,    45,   220,    46,     0,    47,
       0,    48,     0,    49,     0,    50,     0,   292,     0,   294,
       0,     0,     0,    52,     4,     0,   461,     0,    53,     0,
       5,     6,     7,     8,     9,     0,     0,     0,     0,    10,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      11,   152,   153,     0,     0,   154,     0,   155,   156,     0,
       0,     0,     0,     0,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
       0,    28,    29,    30,    31,    32,    33,    34,     0,    35,
      36,    37,    38,    39,    40,    41,    42,    43,   293,    45,
     220,    46,     0,    47,     0,    48,     0,    49,     0,    50,
       0,   292,     0,   294,     0,     0,     0,    52,     4,     0,
     462,     0,    53,     0,     5,     6,     7,     8,     9,     0,
       0,     0,     0,    10,     0,     0,     0,   157,   158,   159,
     160,   161,     0,   162,    11,     0,   163,   164,     0,     0,
     275,     0,     0,   165,     0,     0,     0,     0,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,     0,    28,    29,    30,    31,    32,
      33,    34,     0,    35,    36,    37,    38,    39,    40,    41,
      42,    43,   293,    45,   220,    46,     0,    47,     0,    48,
       0,    49,     0,    50,     0,   218,     0,   294,     0,     0,
       0,    52,     4,     0,   470,     0,    53,     0,     5,     6,
       7,     8,     9,     0,     0,   152,   153,    10,     0,   154,
       0,   155,   156,     0,     0,     0,   152,   153,    11,     0,
     154,     0,   155,   156,     0,     0,     0,     0,     0,     0,
       0,     0,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,    27,     0,    28,
      29,    30,    31,    32,    33,    34,     0,    35,    36,    37,
      38,    39,    40,    41,    42,    43,   219,    45,   220,    46,
       0,    47,     0,    48,     0,    49,     0,    50,     0,     0,
     152,   153,     0,     0,   154,    52,   155,   156,     0,     0,
      53,   157,   158,   159,   160,   161,   318,   162,   319,     0,
     163,   164,   157,   158,   159,   160,   161,   165,   162,     0,
       0,   163,   164,   152,   153,   277,     0,   154,   165,   155,
     156,     0,     0,     0,   152,   153,     0,     0,   154,     0,
     155,   156,     0,     0,     0,   152,   153,     0,     0,   154,
       0,   155,   156,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   152,   153,     0,     0,   154,     0,   155,   156,
       0,     0,     0,     0,     0,     0,   157,   158,   159,   160,
     161,     0,   162,   278,     0,   163,   164,   152,   153,     0,
       0,   154,   165,   155,   156,     0,     0,     0,   152,   153,
       0,     0,   154,     0,   155,   156,     0,     0,     0,   157,
     158,   159,   160,   161,     0,   162,   279,     0,   163,   164,
     157,   158,   159,   160,   161,   165,   162,   284,     0,   163,
     164,   157,   158,   159,   160,   161,   165,   162,     0,     0,
     163,   164,     0,     0,   288,     0,     0,   165,   157,   158,
     159,   160,   161,     0,   162,     0,     0,   163,   164,   152,
     153,   290,     0,   154,   165,   155,   156,     0,     0,     0,
       0,     0,     0,   157,   158,   159,   160,   161,     0,   162,
     310,     0,   163,   164,   157,   158,   159,   160,   161,   165,
     162,     0,     0,   163,   164,   152,   153,   315,     0,   154,
     165,   155,   156,     0,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   152,   153,     0,     0,   154,     0,   155,
     156,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   157,   158,   159,   160,   161,
       0,   162,     0,     0,   163,   164,   152,   153,   316,     0,
     154,   165,   155,   156,     0,     0,     0,   152,   153,     0,
       0,   154,     0,   155,   156,     0,     0,     0,     0,     0,
       0,   157,   158,   159,   160,   161,     0,   162,   344,     0,
     163,   164,   157,   158,   159,   160,   161,   165,   162,     0,
       0,   163,   164,     0,     0,   368,     0,     0,   165,   157,
     158,   159,   160,   161,     0,   162,     0,     0,   163,   164,
     152,   153,   248,     0,   154,   165,   155,   156,     0,     0,
       0,   152,   153,     0,     0,   154,     0,   155,   156,     0,
       0,     0,   157,   158,   159,   160,   161,   380,   162,     0,
       0,   163,   164,   157,   158,   159,   160,   161,   165,   162,
       0,     0,   163,   164,   152,   153,   392,     0,   154,   165,
     155,   156,     0,     0,     0,   152,   153,     0,     0,   154,
       0,   155,   156,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   152,   153,     0,     0,   154,     0,   155,   156,
       0,     0,     0,     0,     0,     0,   157,   158,   159,   160,
     161,     0,   162,   393,     0,   163,   164,   157,   158,   159,
     160,   161,   165,   162,     0,     0,   163,   164,   152,   153,
     394,     0,   154,   165,   155,   156,     0,     0,     0,   152,
     153,     0,     0,   154,     0,   155,   156,     0,     0,     0,
     157,   158,   159,   160,   161,     0,   162,   395,     0,   163,
     164,   157,   158,   159,   160,   161,   165,   162,     0,     0,
     163,   164,     0,     0,   412,     0,     0,   165,   157,   158,
     159,   160,   161,     0,   162,     0,   414,   163,   164,   152,
     153,     0,     0,   154,   165,   155,   156,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,   157,   158,   159,   160,   161,   417,
     162,     0,     0,   163,   164,   157,   158,   159,   160,   161,
     165,   162,   418,     0,   163,   164,   152,   153,     0,     0,
     154,   165,   155,   156,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   152,   153,     0,     0,   154,     0,   155,
     156,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   258,     0,   157,   158,   159,   160,   161,
       0,   162,     0,     0,   163,   164,     0,     0,   453,     0,
       0,   165,   157,   158,   159,   160,   161,     0,   162,     0,
       0,   163,   164,   152,   153,   454,     0,   154,   165,   155,
     156,     0,     0,   259,   260,   261,   262,     0,     0,     0,
       0,     0,   157,   158,   159,   160,   161,   263,   162,     0,
       0,   163,   164,     0,     0,   455,     0,     0,   165,   157,
     158,   159,   160,   161,     0,   162,     0,     0,   163,   164,
     152,   153,   456,     0,   154,   165,   155,   156,     0,   264,
       0,   152,   153,    53,     0,   154,     0,   155,   156,     0,
       0,     0,   152,   153,     0,     0,   154,     0,   155,   156,
     258,     0,     0,     0,     0,     0,     0,     0,     0,   157,
     158,   159,   160,   161,     0,   162,     0,     0,   163,   164,
       0,     0,   458,     0,     0,   165,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     259,   260,   261,   262,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   263,     0,   157,   158,   159,   160,
     161,   459,   162,     0,     0,   163,   164,   157,   158,   159,
     160,   161,   165,   162,     0,     0,   163,   164,   157,   158,
     159,   160,   161,   165,   162,     4,   271,     0,   164,     0,
      53,     5,     6,    88,   165,    89,     0,     0,     0,     0,
      10,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    12,    13,    14,    15,    16,
      17,    18,    19,    90,    91,    92,    93,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    94,    34,     0,
      35,    36,     4,     0,     0,    40,    41,     0,     5,     6,
      88,     0,    89,     0,    95,     0,     0,    10,    49,     0,
      50,     0,     0,     0,     0,     0,     0,     0,    52,   195,
       0,     0,     0,    53,     0,     0,     0,     0,     0,     0,
       0,     0,    12,    13,    14,    15,    16,    17,    18,    19,
      90,    91,    92,    93,     0,     0,     0,     0,     0,     0,
       0,     0,    31,    32,    94,    34,     0,    35,    36,     4,
       0,     0,    40,    41,     0,     5,     6,    88,     0,    89,
       0,    95,     0,     0,    10,    49,     0,    50,     0,     0,
       0,     0,     0,     0,     0,    52,   198,     0,     0,     0,
      53,     0,     0,     0,     0,     0,     0,     0,     0,    12,
      13,    14,    15,    16,    17,    18,    19,    90,    91,    92,
      93,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    94,    34,     0,    35,    36,     4,     0,     0,    40,
      41,     0,     5,     6,   206,     0,   207,     0,    95,     0,
       0,    10,    49,     0,    50,     0,     0,     0,     0,     0,
       0,     0,    52,   201,     0,     0,     0,    53,     0,     0,
       0,     0,     0,     0,     0,     0,    12,    13,    14,    15,
      16,    17,    18,    19,   208,   209,   210,   211,     0,     0,
       0,     0,     0,     0,     0,     0,    31,    32,    94,    34,
       0,    35,    36,     4,     0,     0,    40,    41,     0,     5,
       6,    88,     0,    89,     0,    95,     0,     0,    10,    49,
       0,    50,     0,     0,     0,     0,     0,     0,     0,    52,
     212,     0,     0,     0,    53,     0,     0,     0,     0,     0,
       0,     0,     0,    12,    13,    14,    15,    16,    17,    18,
      19,    90,    91,    92,    93,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    94,    34,     0,    35,    36,
       4,     0,     0,    40,    41,     0,     5,     6,    88,     0,
      89,     0,    95,     0,     0,    10,    49,     0,    50,     0,
       0,     0,     0,     0,     0,     0,    52,   232,     0,     0,
       0,    53,     0,     0,     0,     0,     0,     0,     0,     0,
      12,    13,    14,    15,    16,    17,    18,    19,    90,    91,
      92,    93,     0,     0,     0,     0,     0,     0,     0,     0,
      31,    32,    94,    34,     0,    35,    36,     4,     0,     0,
      40,    41,     0,     5,     6,    88,     0,    89,     0,    95,
       0,     0,    10,    49,     0,    50,     0,     0,     0,     0,
       0,     0,     0,    52,   369,     0,     0,     0,    53,     0,
       0,     0,     0,     0,     0,     0,     0,    12,    13,    14,
      15,    16,    17,    18,    19,    90,    91,    92,    93,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    94,
      34,     0,    35,    36,     4,     0,     0,    40,    41,     0,
       5,     6,   137,     0,    89,     0,    95,     0,     0,    10,
      49,     0,    50,     0,     0,     0,     0,     0,     0,     0,
      52,     0,     0,     0,     0,    53,     0,     0,     0,     0,
       0,     0,     0,     0,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,     0,     0,     0,     0,
       0,     0,     0,     0,    31,    32,    33,    34,     0,    35,
      36,     4,     0,     0,    40,    41,     0,     5,     6,    88,
       0,    89,     0,    95,     0,     0,    10,    49,     0,    50,
       0,     0,     0,     0,     0,     0,     0,    52,     0,     0,
       0,     0,    53,     0,     0,     0,     0,     0,     0,     0,
       0,    12,    13,    14,    15,    16,    17,    18,    19,    90,
      91,    92,    93,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    94,    34,     0,    35,    36,     4,     0,
       0,    40,    41,     0,     5,     6,    88,     0,    89,     0,
      95,     0,     0,    10,    49,     0,    50,     0,     0,     0,
       0,     0,     0,     0,   185,     0,     0,     0,     0,    53,
       0,     0,     0,     0,     0,     0,     0,     0,   362,    13,
      14,   363,   364,    17,   365,   366,    90,    91,    92,    93,
       0,     0,     0,     0,     0,     0,     0,     0,    31,    32,
      94,    34,     0,    35,    36,     0,     0,     0,    40,    41,
       0,     0,     0,     0,     0,     0,     0,    95,     0,     0,
       0,    49,     0,    50,     0,     0,     0,     0,     0,     0,
       0,    52,     0,     0,     0,     0,    53
};

static const yytype_int16 yycheck[] =
{
       1,    25,   134,     1,     1,   256,     1,   430,    27,    16,
      60,    68,    11,    88,    96,    11,     4,    70,   101,   102,
     102,    96,    97,    97,     7,   276,    50,    10,    52,    70,
      88,    70,    94,    70,    96,   101,   102,    68,    96,    27,
     463,    65,    30,   131,     7,    46,   103,    10,    46,    56,
      57,    58,    59,   106,    70,    68,    70,    76,    46,    11,
     101,    49,   101,    70,   101,    53,   101,   106,     7,   106,
     101,    10,   103,   101,    62,    63,    96,    70,   101,    88,
     101,   183,   102,   101,    97,   101,   110,    96,    76,   113,
     106,    79,   180,   117,     3,     4,   184,    96,     7,   106,
       9,    10,   101,   102,    68,   101,    75,   126,   101,    92,
      93,    99,    95,   106,   102,   103,   104,   105,   106,   107,
     108,   109,   105,   111,   148,   126,   176,   115,   147,    96,
      93,   382,    95,   134,   103,   102,   134,   134,   126,   134,
      11,   129,   105,    88,    96,    97,   165,   135,   136,   101,
     102,    96,    97,     3,    93,   257,   175,     7,   101,   147,
      10,   185,   150,   251,   152,   153,   105,   155,   270,   157,
     158,   159,   160,   161,   162,   163,   164,   165,   101,    88,
      89,    90,    91,    92,    93,   173,    95,   175,    96,    98,
      99,   101,   102,   102,   102,    96,   105,   185,     7,    96,
      96,   102,    70,   204,    96,   102,   102,    94,   101,    96,
     102,    20,    21,    22,    23,   216,    70,    88,   101,   102,
     101,     3,     4,   101,    33,     7,    97,     9,    10,   217,
     101,   102,   101,   101,    70,   101,    68,   256,   106,    89,
      90,    91,    92,    93,   103,    95,   101,   101,   336,    99,
      11,    97,   106,   341,   101,   105,   101,     3,     4,   247,
      69,     7,   250,     9,    10,   101,   254,   268,   256,   101,
     106,   103,   273,    96,    96,   101,   102,     3,     4,   102,
     102,     7,   414,     9,    10,   373,   374,   101,   276,   313,
     278,   279,   280,    96,   282,    11,   284,   285,   386,   102,
     101,   389,   101,   102,   101,   102,   307,    89,    90,    91,
      92,    93,    96,    95,   101,   102,    98,    99,   102,    12,
     344,   322,   310,   105,   106,    96,   314,   101,   137,   101,
     102,   319,    93,   101,   422,   323,    97,   425,   101,   102,
     101,   102,   101,    89,    90,    91,    92,    93,   101,    95,
      96,   101,    98,    99,   101,   102,   102,   381,   101,   105,
      97,   170,    96,    89,    90,    91,    92,    93,    97,    95,
     179,    96,    98,    99,   183,   103,   102,   101,   466,   105,
      96,    97,    93,   384,   101,   101,   102,   388,   101,   102,
      96,    14,    15,    16,   382,    18,   320,   321,    47,    48,
      23,   101,    97,    97,   103,   393,   103,   395,   396,    97,
     398,   103,    96,   414,   415,   416,   414,   414,   103,   414,
     103,    96,   102,   424,     0,     1,   427,   451,   102,   102,
     418,   419,     8,    56,    57,    58,    59,   102,    14,    15,
      16,    17,    18,   102,   445,   102,   447,    23,   257,   258,
     259,   260,   261,   262,   263,     3,   102,    93,    34,     7,
     103,   270,    10,   103,    96,    70,   101,    96,   469,   102,
     414,   102,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,   102,    65,
      66,    67,    68,    69,    70,    71,   103,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,   463,    85,
     444,    87,   337,    89,    -1,    91,    -1,    93,    -1,     1,
      -1,    97,    -1,    -1,    -1,   101,     8,    -1,   337,    -1,
     106,    -1,    14,    15,    16,    17,    18,    -1,    -1,    -1,
      -1,    23,    90,    91,    92,    93,    -1,    95,    -1,    -1,
      -1,    99,    34,    -1,    -1,     3,     4,   105,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    -1,    65,    66,    67,    68,    69,    70,    71,
      -1,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,     1,    -1,    97,    -1,    -1,    -1,   101,
       8,    -1,   104,    -1,   106,    -1,    14,    15,    16,    17,
      18,    -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,
      -1,    89,    90,    91,    92,    93,    34,    95,    96,     3,
      98,    99,    -1,     7,   102,    -1,    10,   105,    -1,    -1,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    -1,    65,    66,    67,
      68,    69,    70,    71,    -1,    73,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    -1,    87,
      -1,    89,    -1,    91,    -1,    93,    -1,     1,    -1,    97,
      -1,    -1,    -1,   101,     8,    -1,   104,    -1,   106,    -1,
      14,    15,    16,    17,    18,    -1,    -1,    -1,    -1,    23,
      -1,    -1,    -1,    -1,    -1,    -1,    90,    91,    92,    93,
      34,    95,    -1,     3,     4,    99,    -1,     7,    -1,     9,
      10,   105,    -1,    -1,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      -1,    65,    66,    67,    68,    69,    70,    71,    -1,    73,
      74,    75,    76,    77,    78,    79,    80,    81,    82,    83,
      84,    85,    -1,    87,    -1,    89,    -1,    91,    -1,    93,
      -1,     1,    -1,    97,    -1,    -1,    -1,   101,     8,    -1,
     104,    -1,   106,    -1,    14,    15,    16,    17,    18,    -1,
      -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    89,
      90,    91,    92,    93,    34,    95,    96,    -1,    98,    99,
      -1,    -1,   102,    -1,    -1,   105,    -1,    -1,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    -1,    65,    66,    67,    68,    69,
      70,    71,    -1,    73,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    -1,    87,    -1,    89,
      -1,    91,    -1,    93,    -1,     1,    -1,    97,    -1,    -1,
      -1,   101,     8,    -1,   104,    -1,   106,    -1,    14,    15,
      16,    17,    18,    -1,    -1,    -1,    -1,    23,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    34,    -1,
      -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    -1,    65,
      66,    67,    68,    69,    70,    71,    -1,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      -1,    87,    -1,    89,    -1,    91,    -1,    93,    -1,     1,
      -1,    97,    -1,    -1,    -1,   101,     8,    -1,   104,    -1,
     106,    -1,    14,    15,    16,    17,    18,    -1,    -1,    -1,
      -1,    23,    -1,    -1,    -1,    -1,    -1,    89,    90,    91,
      92,    93,    34,    95,    96,    -1,    98,    99,    -1,    -1,
     102,    -1,    -1,   105,    -1,    -1,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    -1,    65,    66,    67,    68,    69,    70,    71,
      -1,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,     1,    -1,    97,    -1,    -1,    -1,   101,
       8,    -1,   104,    -1,   106,    -1,    14,    15,    16,    17,
      18,    -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    34,    -1,    -1,     3,
       4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    -1,    65,    66,    67,
      68,    69,    70,    71,    -1,    73,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    -1,    87,
      -1,    89,    -1,    91,    -1,    93,    -1,     1,    -1,    97,
      -1,    -1,    -1,   101,     8,    -1,   104,    -1,   106,    -1,
      14,    15,    16,    17,    18,    -1,    -1,    -1,    -1,    23,
      -1,    -1,    -1,    -1,    -1,    89,    90,    91,    92,    93,
      34,    95,    96,    -1,    98,    99,    -1,    -1,   102,    -1,
      -1,   105,    -1,    -1,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      -1,    65,    66,    67,    68,    69,    70,    71,    -1,    73,
      74,    75,    76,    77,    78,    79,    80,    81,    82,    83,
      84,    85,    -1,    87,    -1,    89,    -1,    91,    -1,    93,
      -1,     1,    -1,    97,    -1,    -1,    -1,   101,     8,    -1,
     104,    -1,   106,    -1,    14,    15,    16,    17,    18,    -1,
      -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    34,    -1,    -1,     3,     4,    -1,
      -1,     7,    -1,     9,    10,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    -1,    65,    66,    67,    68,    69,
      70,    71,    -1,    73,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    -1,    87,    -1,    89,
      -1,    91,    -1,    93,    -1,     1,    -1,    97,    -1,    -1,
      -1,   101,     8,    -1,   104,    -1,   106,    -1,    14,    15,
      16,    17,    18,    -1,    -1,    -1,    -1,    23,    -1,    -1,
      -1,    -1,    -1,    89,    90,    91,    92,    93,    34,    95,
      96,    -1,    98,    99,    -1,    -1,   102,    -1,    -1,   105,
      -1,    -1,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    -1,    65,
      66,    67,    68,    69,    70,    71,    -1,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      -1,    87,    -1,    89,    -1,    91,    -1,    93,    -1,     1,
      -1,    97,    -1,    -1,    -1,   101,     8,    -1,   104,    -1,
     106,    -1,    14,    15,    16,    17,    18,    -1,    -1,    -1,
      -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    34,    -1,    -1,     3,     4,    -1,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    61,
      62,    63,    -1,    65,    66,    67,    68,    69,    70,    71,
      -1,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    -1,    87,    -1,    89,    -1,    91,
      -1,    93,    -1,     1,    -1,    97,    -1,    -1,    -1,   101,
       8,    -1,   104,    -1,   106,    -1,    14,    15,    16,    17,
      18,    -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,
      -1,    89,    90,    91,    92,    93,    34,    95,    96,    -1,
      98,    99,    -1,    -1,    -1,    -1,    -1,   105,    -1,    -1,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    60,    61,    62,    63,    -1,    65,    66,    67,
      68,    69,    70,    71,    -1,    73,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    -1,    87,
      -1,    89,    -1,    91,    -1,    93,    -1,     1,    -1,    97,
      -1,    -1,    -1,   101,     8,    -1,   104,    -1,   106,    -1,
      14,    15,    16,    17,    18,    -1,    -1,    -1,    -1,    23,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      34,     3,     4,    -1,    -1,     7,    -1,     9,    10,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    63,
      -1,    65,    66,    67,    68,    69,    70,    71,    -1,    73,
      74,    75,    76,    77,    78,    79,    80,    81,    82,    83,
      84,    85,    -1,    87,    -1,    89,    -1,    91,    -1,    93,
      -1,     1,    -1,    97,    -1,    -1,    -1,   101,     8,    -1,
     104,    -1,   106,    -1,    14,    15,    16,    17,    18,    -1,
      -1,    -1,    -1,    23,    -1,    -1,    -1,    89,    90,    91,
      92,    93,    -1,    95,    34,    -1,    98,    99,    -1,    -1,
     102,    -1,    -1,   105,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    -1,    65,    66,    67,    68,    69,
      70,    71,    -1,    73,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    -1,    87,    -1,    89,
      -1,    91,    -1,    93,    -1,     1,    -1,    97,    -1,    -1,
      -1,   101,     8,    -1,   104,    -1,   106,    -1,    14,    15,
      16,    17,    18,    -1,    -1,     3,     4,    23,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,     3,     4,    34,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    -1,    65,
      66,    67,    68,    69,    70,    71,    -1,    73,    74,    75,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      -1,    87,    -1,    89,    -1,    91,    -1,    93,    -1,    -1,
       3,     4,    -1,    -1,     7,   101,     9,    10,    -1,    -1,
     106,    89,    90,    91,    92,    93,    94,    95,    96,    -1,
      98,    99,    89,    90,    91,    92,    93,   105,    95,    -1,
      -1,    98,    99,     3,     4,   102,    -1,     7,   105,     9,
      10,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,    -1,
       9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,
      -1,    -1,    -1,    -1,    -1,    -1,    89,    90,    91,    92,
      93,    -1,    95,    96,    -1,    98,    99,     3,     4,    -1,
      -1,     7,   105,     9,    10,    -1,    -1,    -1,     3,     4,
      -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,    89,
      90,    91,    92,    93,    -1,    95,    96,    -1,    98,    99,
      89,    90,    91,    92,    93,   105,    95,    96,    -1,    98,
      99,    89,    90,    91,    92,    93,   105,    95,    -1,    -1,
      98,    99,    -1,    -1,   102,    -1,    -1,   105,    89,    90,
      91,    92,    93,    -1,    95,    -1,    -1,    98,    99,     3,
       4,   102,    -1,     7,   105,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    89,    90,    91,    92,    93,    -1,    95,
      96,    -1,    98,    99,    89,    90,    91,    92,    93,   105,
      95,    -1,    -1,    98,    99,     3,     4,   102,    -1,     7,
     105,     9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,     4,    -1,    -1,     7,    -1,     9,
      10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    89,    90,    91,    92,    93,
      -1,    95,    -1,    -1,    98,    99,     3,     4,   102,    -1,
       7,   105,     9,    10,    -1,    -1,    -1,     3,     4,    -1,
      -1,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    89,    90,    91,    92,    93,    -1,    95,    96,    -1,
      98,    99,    89,    90,    91,    92,    93,   105,    95,    -1,
      -1,    98,    99,    -1,    -1,   102,    -1,    -1,   105,    89,
      90,    91,    92,    93,    -1,    95,    -1,    -1,    98,    99,
       3,     4,   102,    -1,     7,   105,     9,    10,    -1,    -1,
      -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,    -1,
      -1,    -1,    89,    90,    91,    92,    93,    94,    95,    -1,
      -1,    98,    99,    89,    90,    91,    92,    93,   105,    95,
      -1,    -1,    98,    99,     3,     4,   102,    -1,     7,   105,
       9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,
      -1,    -1,    -1,    -1,    -1,    -1,    89,    90,    91,    92,
      93,    -1,    95,    96,    -1,    98,    99,    89,    90,    91,
      92,    93,   105,    95,    -1,    -1,    98,    99,     3,     4,
     102,    -1,     7,   105,     9,    10,    -1,    -1,    -1,     3,
       4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      89,    90,    91,    92,    93,    -1,    95,    96,    -1,    98,
      99,    89,    90,    91,    92,    93,   105,    95,    -1,    -1,
      98,    99,    -1,    -1,   102,    -1,    -1,   105,    89,    90,
      91,    92,    93,    -1,    95,    -1,    97,    98,    99,     3,
       4,    -1,    -1,     7,   105,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    89,    90,    91,    92,    93,    94,
      95,    -1,    -1,    98,    99,    89,    90,    91,    92,    93,
     105,    95,    96,    -1,    98,    99,     3,     4,    -1,    -1,
       7,   105,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,     4,    -1,    -1,     7,    -1,     9,
      10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    16,    -1,    89,    90,    91,    92,    93,
      -1,    95,    -1,    -1,    98,    99,    -1,    -1,   102,    -1,
      -1,   105,    89,    90,    91,    92,    93,    -1,    95,    -1,
      -1,    98,    99,     3,     4,   102,    -1,     7,   105,     9,
      10,    -1,    -1,    56,    57,    58,    59,    -1,    -1,    -1,
      -1,    -1,    89,    90,    91,    92,    93,    70,    95,    -1,
      -1,    98,    99,    -1,    -1,   102,    -1,    -1,   105,    89,
      90,    91,    92,    93,    -1,    95,    -1,    -1,    98,    99,
       3,     4,   102,    -1,     7,   105,     9,    10,    -1,   102,
      -1,     3,     4,   106,    -1,     7,    -1,     9,    10,    -1,
      -1,    -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,
      16,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    89,
      90,    91,    92,    93,    -1,    95,    -1,    -1,    98,    99,
      -1,    -1,   102,    -1,    -1,   105,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      56,    57,    58,    59,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    70,    -1,    89,    90,    91,    92,
      93,    94,    95,    -1,    -1,    98,    99,    89,    90,    91,
      92,    93,   105,    95,    -1,    -1,    98,    99,    89,    90,
      91,    92,    93,   105,    95,     8,   102,    -1,    99,    -1,
     106,    14,    15,    16,   105,    18,    -1,    -1,    -1,    -1,
      23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    54,    55,    56,    57,    58,    59,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    68,    69,    70,    71,    -1,
      73,    74,     8,    -1,    -1,    78,    79,    -1,    14,    15,
      16,    -1,    18,    -1,    87,    -1,    -1,    23,    91,    -1,
      93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,   102,
      -1,    -1,    -1,   106,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    68,    69,    70,    71,    -1,    73,    74,     8,
      -1,    -1,    78,    79,    -1,    14,    15,    16,    -1,    18,
      -1,    87,    -1,    -1,    23,    91,    -1,    93,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   101,   102,    -1,    -1,    -1,
     106,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,
      49,    50,    51,    52,    53,    54,    55,    56,    57,    58,
      59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,
      69,    70,    71,    -1,    73,    74,     8,    -1,    -1,    78,
      79,    -1,    14,    15,    16,    -1,    18,    -1,    87,    -1,
      -1,    23,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   101,   102,    -1,    -1,    -1,   106,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,    71,
      -1,    73,    74,     8,    -1,    -1,    78,    79,    -1,    14,
      15,    16,    -1,    18,    -1,    87,    -1,    -1,    23,    91,
      -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,
     102,    -1,    -1,    -1,   106,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    68,    69,    70,    71,    -1,    73,    74,
       8,    -1,    -1,    78,    79,    -1,    14,    15,    16,    -1,
      18,    -1,    87,    -1,    -1,    23,    91,    -1,    93,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   101,   102,    -1,    -1,
      -1,   106,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    54,    55,    56,    57,
      58,    59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      68,    69,    70,    71,    -1,    73,    74,     8,    -1,    -1,
      78,    79,    -1,    14,    15,    16,    -1,    18,    -1,    87,
      -1,    -1,    23,    91,    -1,    93,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   101,   102,    -1,    -1,    -1,   106,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,
      71,    -1,    73,    74,     8,    -1,    -1,    78,    79,    -1,
      14,    15,    16,    -1,    18,    -1,    87,    -1,    -1,    23,
      91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     101,    -1,    -1,    -1,    -1,   106,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    68,    69,    70,    71,    -1,    73,
      74,     8,    -1,    -1,    78,    79,    -1,    14,    15,    16,
      -1,    18,    -1,    87,    -1,    -1,    23,    91,    -1,    93,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,    -1,    -1,
      -1,    -1,   106,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    68,    69,    70,    71,    -1,    73,    74,     8,    -1,
      -1,    78,    79,    -1,    14,    15,    16,    -1,    18,    -1,
      87,    -1,    -1,    23,    91,    -1,    93,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   101,    -1,    -1,    -1,    -1,   106,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,
      70,    71,    -1,    73,    74,    -1,    -1,    -1,    78,    79,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    87,    -1,    -1,
      -1,    91,    -1,    93,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   101,    -1,    -1,    -1,    -1,   106
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,   108,     0,     1,     8,    14,    15,    16,    17,    18,
      23,    34,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    65,    66,
      67,    68,    69,    70,    71,    73,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    85,    87,    89,    91,
      93,    97,   101,   106,   109,   113,   114,   115,   116,   117,
     118,   119,   121,   122,   124,   125,   126,   127,   128,   135,
     136,   137,   138,   139,   140,   141,   142,   143,   144,   145,
     146,   147,   148,   149,   150,   151,   152,    97,    16,    18,
      56,    57,    58,    59,    70,    87,   119,   135,    70,   101,
     126,    70,   101,   101,   101,   101,   101,   101,   101,   101,
     101,   101,   126,   101,   126,   101,   126,   101,   126,    68,
     103,   118,    68,    97,   117,   119,   101,   119,   126,   101,
     101,   103,   101,   101,   101,   101,   101,    16,   119,   127,
     128,   128,   119,   118,   118,   119,    97,    11,   101,    88,
      96,   134,     3,     4,     7,     9,    10,    89,    90,    91,
      92,    93,    95,    98,    99,   105,   119,   119,   118,    12,
      96,    97,   134,   101,   126,    96,   117,   119,    68,   101,
     103,   119,    68,   101,   103,   101,   119,   129,   119,   119,
     119,   119,   119,   119,   119,   102,   118,   119,   102,   118,
     119,   102,   118,    97,   110,    97,    16,    18,    56,    57,
      58,    59,   102,   117,   135,   119,   110,   120,     1,    82,
      84,   112,   113,   115,   127,   153,   119,   119,    94,   102,
     106,   117,   102,   118,   119,   119,   119,   119,   119,   119,
     119,   119,   119,   119,   119,   119,   117,    88,   102,   123,
      96,   103,   126,   119,    93,   117,   134,   101,    16,    56,
      57,    58,    59,    70,   102,   126,   154,   155,   110,   102,
     101,   102,   154,   110,   119,   102,    96,   102,    96,    96,
      96,   102,    96,   102,    96,    96,   102,   102,   102,   102,
     102,   102,     1,    82,    97,   104,   111,   113,   115,   127,
     153,   102,   102,   102,   102,   102,   102,    96,   102,   102,
      96,   104,   119,   101,    97,   102,   102,   102,    94,    96,
     119,   119,   110,    96,   102,   119,   117,   119,   129,   154,
     126,   126,   126,   126,   126,   126,   103,    96,   102,   104,
     154,   103,   102,   104,    96,   129,   119,   119,   119,   119,
     119,   119,    97,    97,    97,    16,    18,    56,    57,    58,
      59,   135,    48,    51,    52,    54,    55,   119,   102,   102,
     118,   119,    75,   103,   103,   119,   123,   123,   104,   119,
      94,    93,    96,   102,   110,   155,   103,   102,   110,   103,
     118,    96,   102,    96,   102,    96,    96,   102,    96,   102,
     102,   102,   102,   102,   102,   102,   102,   102,   102,   102,
     102,   102,   102,   102,    97,   110,   110,    94,    96,    93,
     118,   129,   103,   104,   110,   103,   104,   110,   102,    70,
     101,   130,   131,   133,   119,   119,   119,   119,   112,   104,
     104,   119,   119,    94,    96,   110,   104,   110,   104,   131,
     132,   101,   102,   102,   102,   102,   102,   102,   102,    94,
     133,   104,   104,    96,   102,   118,   103,   132,   102,   110,
     104
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   107,   108,   108,   109,   109,   109,   109,   109,   109,
     110,   110,   111,   111,   111,   111,   111,   111,   111,   112,
     112,   112,   112,   112,   112,   113,   113,   113,   113,   113,
     113,   113,   113,   114,   115,   115,   115,   115,   115,   115,
     115,   115,   115,   116,   117,   117,   117,   117,   117,   117,
     117,   117,   117,   117,   117,   117,   117,   117,   117,   117,
     117,   117,   117,   117,   117,   117,   117,   117,   117,   117,
     117,   117,   117,   117,   117,   117,   117,   117,   117,   117,
     117,   118,   118,   119,   119,   119,   119,   119,   119,   119,
     119,   119,   119,   119,   119,   119,   120,   119,   121,   122,
     123,   124,   124,   124,   124,   124,   124,   124,   124,   124,
     124,   124,   124,   124,   124,   125,   125,   126,   126,   127,
     127,   127,   127,   127,   127,   127,   127,   127,   128,   129,
     129,   130,   131,   131,   132,   132,   133,   133,   134,   135,
     135,   135,   136,   137,   137,   138,   139,   140,   140,   141,
     141,   141,   141,   141,   141,   141,   141,   141,   141,   141,
     141,   141,   141,   141,   141,   142,   143,   143,   143,   143,
     144,   145,   145,   146,   147,   147,   148,   148,   148,   148,
     148,   149,   150,   151,   151,   151,   151,   151,   151,   151,
     151,   152,   152,   153,   153,   154,   154,   155,   155,   155,
     155,   155,   155,   155
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     1,     2,     2,     1,     1,     2,
       0,     2,     1,     2,     2,     1,     1,     1,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     4,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     2,     1,     1,     3,     3,     3,     4,
       3,     1,     1,     1,     4,     4,     4,     3,     4,     4,
       3,     4,     4,     4,     4,     6,     6,     6,     6,     8,
       8,     8,     8,     3,     4,     8,     4,     8,     4,     5,
       3,     3,     1,     1,     1,     6,     4,     6,     6,     6,
       6,     6,     6,     3,     5,     5,     0,     5,     2,     2,
       1,     2,     2,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     2,     2,     2,     2,     1,     3,     2,
       2,     2,     2,     2,     8,     2,     3,     2,     1,     1,
       5,     1,     1,     4,     1,     3,     1,     3,     1,     1,
       1,     1,     2,     3,     2,     3,     2,     2,     3,     4,
       4,     4,     4,     4,     4,     4,     4,     6,     6,     6,
       6,     6,     6,     6,     3,     1,     8,     2,     4,     7,
       2,     1,     1,     2,     2,     1,     7,     4,     5,     1,
       1,     7,    11,     5,     7,     8,     9,     5,     7,     8,
       9,     2,     2,     4,     3,     3,     1,     2,     2,     2,
       2,     2,     2,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (retv, YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value, retv); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, astree ** retv)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  YYUSE (retv);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, astree ** retv)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, retv);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule, astree ** retv)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              , retv);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule, retv); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, astree ** retv)
{
  YYUSE (yyvaluep);
  YYUSE (retv);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/*----------.
| yyparse.  |
`----------*/

int
yyparse (astree ** retv)
{
/* The lookahead symbol.  */
int yychar;


/* The semantic value of the lookahead symbol.  */
/* Default value used for initialization, for pacifying older GCCs
   or non-GCC compilers.  */
YY_INITIAL_VALUE (static YYSTYPE yyval_default;)
YYSTYPE yylval YY_INITIAL_VALUE (= yyval_default);

    /* Number of syntax errors so far.  */
    int yynerrs;

    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex (&yylval);
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 202 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_lines -> ");
                (yyval.tree) = astnode_make0(RULE_top_lines(1));
                *retv = (yyval.tree);
                exitrule("top_lines -> ");
            }
#line 2239 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 210 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_lines -> top_lines top_pprompt");
                (yyval.tree) = astnode_append((yyvsp[-1].tree), (yyvsp[0].tree));
                *retv = (yyval.tree);
                exitrule_ex("top_lines -> top_lines top_pprompt",(yyval.tree));
            }
#line 2250 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 220 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(1), (yyvsp[0].tree));
                exitrule("top_pprompt -> flowctrl");
            }
#line 2260 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 227 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> command ';'");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(2), (yyvsp[-1].tree));
                exitrule_ex("top_pprompt -> command ';'",(yyval.tree));
            }
#line 2270 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 234 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> declare_ip_variable ';'");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(3), (yyvsp[-1].tree));
                exitrule("top_pprompt -> declare_ip_variable ';'");
            }
#line 2280 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 241 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_top_pprompt(4));
                exitrule("top_pprompt -> SYS_BREAK");
            }
#line 2290 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 248 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> ';'");
                (yyval.tree) = astnode_make0(RULE_top_pprompt(5));
                exitrule_ex("top_pprompt -> ';'", (yyval.tree));
            }
#line 2300 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 255 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> error ';'");
                YYABORT;
                exitrule("top_pprompt -> error ';'");
            }
#line 2310 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 263 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("lines -> ");
                (yyval.tree) = astnode_make0(RULE_lines(1));
                exitrule("lines -> ");
            }
#line 2320 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 270 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("lines -> lines pprompt");
                (yyval.tree) = astnode_append((yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule_ex("lines -> lines pprompt",(yyval.tree));
            }
#line 2330 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 279 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_pprompt(1), (yyvsp[0].tree));
                exitrule("pprompt -> flowctrl");
            }
#line 2340 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 286 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> command ';'");
                (yyval.tree) = astnode_make1(RULE_pprompt(2), (yyvsp[-1].tree));
                exitrule_ex("pprompt -> command ';'",(yyval.tree));
            }
#line 2350 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 293 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> declare_ip_variable ';'");
                (yyval.tree) = astnode_make1(RULE_pprompt(3), (yyvsp[-1].tree));
                exitrule("pprompt -> declare_ip_variable ';'");
            }
#line 2360 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 300 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> returncmd");
                (yyval.tree) = astnode_make1(RULE_pprompt(4), (yyvsp[0].tree));
                exitrule("pprompt -> returncmd");
            }
#line 2370 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 307 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_pprompt(5));
                exitrule("pprompt -> SYS_BREAK");
            }
#line 2380 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 314 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> ';'");
                (yyval.tree) = astnode_make0(RULE_pprompt(6));
                exitrule_ex("pprompt -> ';'", (yyval.tree));
            }
#line 2390 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 321 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> error ';'");
                YYABORT;
                exitrule("pprompt -> error ';'");
            }
#line 2400 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 331 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_npprompt(1), (yyvsp[0].tree));
                exitrule("npprompt -> flowctrl");
            }
#line 2410 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 338 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> command");
                (yyval.tree) = astnode_make1(RULE_npprompt(2), (yyvsp[0].tree));
                exitrule_ex("npprompt -> command ';'",(yyval.tree));
            }
#line 2420 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 345 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> declare_ip_variable");
                (yyval.tree) = astnode_make1(RULE_npprompt(3), (yyvsp[0].tree));
                exitrule("npprompt -> declare_ip_variable ';'");
            }
#line 2430 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 352 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> returncmd");
                (yyval.tree) = astnode_make1(RULE_npprompt(4), (yyvsp[0].tree));
                exitrule("npprompt -> returncmd");
            }
#line 2440 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 359 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_npprompt(5));
                exitrule("npprompt -> SYS_BREAK");
            }
#line 2450 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 366 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> error ';'");
                YYABORT;
                exitrule("npprompt -> error ';'");
            }
#line 2460 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 375 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> ifcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(1), (yyvsp[0].tree));
                exitrule("flowctrl -> ifcmd");
            }
#line 2470 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 382 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> whilecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(2), (yyvsp[0].tree));
                exitrule("flowctrl -> whilecmd");
            }
#line 2480 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 389 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> example_dummy");
                (yyval.tree) = astnode_make1(RULE_flowctrl(3), (yyvsp[0].tree));
                exitrule("flowctrl -> example_dummy");
            }
#line 2490 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 396 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> forcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(4), (yyvsp[0].tree));
                exitrule("flowctrl -> forcmd");
            }
#line 2500 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 403 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> proccmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(5), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> proccmd",(yyval.tree));
            }
#line 2510 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 410 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> filecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(6), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> filecmd",(yyval.tree));
            }
#line 2520 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 417 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> helpcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(7), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> helpcmd",(yyval.tree));
            }
#line 2530 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 424 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> examplecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(8), (yyvsp[0].tree));
                exitrule("flowctrl -> examplecmd");
            }
#line 2540 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 432 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
                (yyval.tree) = astnode_make1(RULE_example_dummy(1), (yyvsp[-1].tree));
                exitrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
            }
#line 2550 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 440 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> assign");
                (yyval.tree) = astnode_make1(RULE_command(1), (yyvsp[0].tree));
                exitrule_ex("command -> assign",(yyval.tree));
            }
#line 2560 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 447 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> exportcmd");
                (yyval.tree) = astnode_make1(RULE_command(2), (yyvsp[0].tree));
                exitrule_ex("command -> exportcmd",(yyval.tree));
            }
#line 2570 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 454 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> killcmd");
                (yyval.tree) = astnode_make1(RULE_command(3), (yyvsp[0].tree));
                exitrule_ex("command -> killcmd",(yyval.tree));
            }
#line 2580 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 461 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> listcmd");
                (yyval.tree) = astnode_make1(RULE_command(4), (yyvsp[0].tree));
                exitrule_ex("command -> listcmd",(yyval.tree));
            }
#line 2590 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 468 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> parametercmd");
                (yyval.tree) = astnode_make1(RULE_command(5), (yyvsp[0].tree));
                exitrule_ex("command -> parametercmd",(yyval.tree));
            }
#line 2600 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 475 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> ringcmd");
                (yyval.tree) = astnode_make1(RULE_command(6), (yyvsp[0].tree));
                exitrule_ex("command -> ringcmd",(yyval.tree));
            }
#line 2610 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 482 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> scriptcmd");
                (yyval.tree) = astnode_make1(RULE_command(7), (yyvsp[0].tree));
                exitrule_ex("command -> scriptcmd",(yyval.tree));
            }
#line 2620 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 489 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> setringcmd");
                (yyval.tree) = astnode_make1(RULE_command(8), (yyvsp[0].tree));
                exitrule_ex("command -> setringcmd",(yyval.tree));
            }
#line 2630 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 496 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> typecmd");
                (yyval.tree) = astnode_make1(RULE_command(9), (yyvsp[0].tree));
                exitrule_ex("command -> typecmd",(yyval.tree));
            }
#line 2640 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 504 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("assign -> left_value exprlist");
                (yyval.tree) = astnode_make2(RULE_assign(1), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule_ex("assign -> left_value exprlist",(yyval.tree));
            }
#line 2650 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 44:
#line 513 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RINGVAR");
                (yyval.tree) = astnode_make1(RULE_elemexpr(1), aststring_make((yyvsp[0].name)));
                exitrule("elemexpr -> RINGVAR");
            }
#line 2660 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 45:
#line 520 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> extendedid");
                (yyval.tree) = astnode_make1(RULE_elemexpr(2), (yyvsp[0].tree));
                exitrule_ex("elemexpr -> extendedid",(yyval.tree));
            }
#line 2670 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 527 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr COLONCOLON elemexpr");
                (yyval.tree) = astnode_make2(RULE_elemexpr(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("elemexpr -> elemexpr COLONCOLON elemexpr");
            }
#line 2680 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 534 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> expr '.' elemexpr");
                (yyval.tree) = astnode_make2(RULE_elemexpr(4), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("elemexpr -> expr '.' elemexpr");
            }
#line 2690 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 541 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr '('  ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(5), (yyvsp[-2].tree));
                exitrule("elemexpr -> elemexpr '('  ')'");
            }
#line 2700 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 49:
#line 548 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(6), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule_ex("elemexpr -> elemexpr '(' exprlist ')'", (yyval.tree));
            }
#line 2710 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 555 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> '[' exprlist ']'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(7), (yyvsp[-1].tree));
                exitrule("elemexpr -> '[' exprlist ']'");
            }
#line 2720 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 562 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> INT_CONST");
                (yyval.tree) = astnode_make1(RULE_elemexpr(8), aststring_make((yyvsp[0].name)));
                exitrule_ex("elemexpr -> INT_CONST", (yyval.tree));
            }
#line 2730 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 569 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> SYSVAR");
                (yyval.tree) = astnode_make1(RULE_elemexpr(9), astint_make((yyvsp[0].i)));
                exitrule("elemexpr -> SYSVAR");
            }
#line 2740 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 576 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> stringexpr");
                (yyval.tree) = astnode_make1(RULE_elemexpr(10), (yyvsp[0].tree));
                exitrule("elemexpr -> stringexpr");
            }
#line 2750 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 583 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> PROC_CMD '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(11), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> PROC_CMD '(' expr ')'");
            }
#line 2760 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 55:
#line 590 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(12), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> ROOT_DECL '(' expr ')'");
            }
#line 2770 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 56:
#line 597 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(13), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
            }
#line 2780 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 57:
#line 604 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(14), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
            }
#line 2790 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 58:
#line 611 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(15), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_DECL '(' expr ')'");
            }
#line 2800 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 59:
#line 618 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(16), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
            }
#line 2810 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 60:
#line 625 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL_LIST '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(17), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> RING_DECL_LIST '(' ')'");
            }
#line 2820 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 632 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_1 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(18), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_1 '(' expr ')'");
            }
#line 2830 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 62:
#line 639 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_12 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(19), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_12 '(' expr ')'");
            }
#line 2840 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 63:
#line 646 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_13 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(20), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_13 '(' expr ')'");
            }
#line 2850 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 64:
#line 653 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(21), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ')'");
            }
#line 2860 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 65:
#line 660 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(22), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
            }
#line 2870 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 66:
#line 667 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(23), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
            }
#line 2880 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 67:
#line 674 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(24), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
            }
#line 2890 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 68:
#line 681 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(25), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
            }
#line 2900 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 69:
#line 688 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(26), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
            }
#line 2910 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 70:
#line 695 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(27), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
            }
#line 2920 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 71:
#line 702 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(28), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
            }
#line 2930 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 72:
#line 709 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(29), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
            }
#line 2940 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 73:
#line 716 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_M '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(30), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> CMD_M '(' ')'");
            }
#line 2950 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 74:
#line 723 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_M '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(31), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_M '(' exprlist ')'");
            }
#line 2960 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 75:
#line 730 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(32), (yyvsp[-7].tree), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
            }
#line 2970 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 76:
#line 737 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> mat_cmd '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(33), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> mat_cmd '(' expr ')'");
            }
#line 2980 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 77:
#line 744 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(34), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
            }
#line 2990 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 78:
#line 751 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_CMD '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(35), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_CMD '(' expr ')'");
            }
#line 3000 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 79:
#line 758 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> extendedid  ARROW '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(36), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> extendedid  ARROW '{' lines '}'");
            }
#line 3010 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 80:
#line 765 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> '(' exprlist ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(37), (yyvsp[-1].tree));
                exitrule_ex("elemexpr -> '(' exprlist ')'",(yyval.tree));
            }
#line 3020 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 81:
#line 774 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exprlist -> exprlist ',' expr");
                (yyval.tree) = astnode_append((yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("exprlist -> exprlist ',' expr",(yyval.tree));
            }
#line 3030 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 82:
#line 781 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exprlist -> expr");
                (yyval.tree) = astnode_make1(RULE_exprlist(1), (yyvsp[0].tree));
                exitrule_ex("exprlist -> expr",(yyval.tree));
            }
#line 3040 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 83:
#line 789 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr_arithmetic");
                (yyval.tree) = astnode_make1(RULE_expr(1), (yyvsp[0].tree));
                exitrule_ex("expr -> expr_arithmetic",(yyval.tree));
            }
#line 3050 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 84:
#line 796 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> elemexpr");
                (yyval.tree) = astnode_make1(RULE_expr(2), (yyvsp[0].tree));
                exitrule_ex("expr -> elemexpr",(yyval.tree));
            }
#line 3060 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 85:
#line 803 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr '[' expr ',' expr ']'");
                (yyval.tree) = astnode_make3(RULE_expr(3), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> expr '[' expr ',' expr ']'");
            }
#line 3070 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 86:
#line 810 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr '[' expr ']'");
                (yyval.tree) = astnode_make2(RULE_expr(4), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> expr '[' expr ']'");
            }
#line 3080 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 87:
#line 817 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(5), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
            }
#line 3090 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 88:
#line 824 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(6), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
            }
#line 3100 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 89:
#line 831 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(7), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
            }
#line 3110 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 90:
#line 838 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(8), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
            }
#line 3120 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 91:
#line 845 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_M ')'");
                (yyval.tree) = astnode_make2(RULE_expr(9), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_M ')'");
            }
#line 3130 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 92:
#line 852 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' expr ')'");
                (yyval.tree) = astnode_make2(RULE_expr(10), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> APPLY '('  expr ',' expr ')'");
            }
#line 3140 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 93:
#line 859 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> quote_start expr quote_end");
                (yyval.tree) = astnode_make1(RULE_expr(11), (yyvsp[-1].tree));
                exitrule("expr -> quote_start expr quote_end");
            }
#line 3150 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 94:
#line 866 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> quote_start expr '=' expr quote_end");
                (yyval.tree) = astnode_make2(RULE_expr(12), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> quote_start expr '=' expr quote_end");
            }
#line 3160 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 95:
#line 873 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> assume_start expr ',' expr quote_end");
                (yyval.tree) = astnode_make2(RULE_expr(13), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> assume_start expr ',' expr quote_end");
            }
#line 3170 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 96:
#line 880 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> EVAL  '('");
                exitrule("expr -> EVAL  '('");
            }
#line 3179 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 97:
#line 886 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> EVAL  '(' expr ')'");
                (yyval.tree) = astnode_make1(RULE_expr(14), (yyvsp[-1].tree));
                exitrule("expr -> EVAL  '(' expr ')'");
            }
#line 3189 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 98:
#line 894 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("quote_start -> QUOTE  '('");
                (yyval.tree) = astnode_make0(RULE_quote_start(1));
                exitrule("quote_start -> QUOTE  '('");
            }
#line 3199 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 99:
#line 902 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("assume_start -> ASSUME_CMD '('");
                (yyval.tree) = astnode_make0(RULE_assume_start(2));
                exitrule("assume_start ASSUME_CMD '('");
            }
#line 3209 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 100:
#line 910 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("quote_end -> ')'");
                (yyval.tree) = astnode_make0(RULE_quote_end(1));
                exitrule("quote_end -> ')'");
            }
#line 3219 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 101:
#line 919 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr PLUSPLUS");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(1), (yyvsp[-1].tree));
                exitrule_ex("expr_arithmetic -> expr PLUSPLUS",(yyval.tree));
            }
#line 3229 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 102:
#line 926 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr MINUSMINUS");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(2), (yyvsp[-1].tree));
                exitrule_ex("expr_arithmetic -> expr MINUSMINUS",(yyval.tree));
            }
#line 3239 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 103:
#line 933 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '+' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '+' expr",(yyval.tree));
            }
#line 3249 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 104:
#line 940 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '-' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(4), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '-' expr",(yyval.tree));
            }
#line 3259 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 105:
#line 947 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '/' expr");
                if ((yyvsp[-1].i) == '*')
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(5), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else if ((yyvsp[-1].i) == '%')
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(6), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else if ((yyvsp[-1].i) == INTDIV_CMD)
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(99), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(7), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                exitrule_ex("expr_arithmetic -> expr '/' expr",(yyval.tree));
            }
#line 3284 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 106:
#line 969 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '^' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(8), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '^' expr",(yyval.tree));
            }
#line 3294 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 107:
#line 976 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '<' expr");
                if ((yyvsp[-1].i) == GE)
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(9), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else if ((yyvsp[-1].i) == LE)
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(10), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else if ((yyvsp[-1].i) == '>')
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(11), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(12), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                exitrule_ex("expr_arithmetic -> expr '<' expr",(yyval.tree));
            }
#line 3319 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 108:
#line 998 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '&' expr");
                if ((yyvsp[-1].i) == '&')
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(13), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                else
                {
                    (yyval.tree) = astnode_make2(RULE_expr_arithmetic(14), (yyvsp[-2].tree), (yyvsp[0].tree));
                }
                exitrule_ex("expr_arithmetic -> expr '&' expr",(yyval.tree));
            }
#line 3336 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 109:
#line 1012 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr NOTEQUAL expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(15), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr NOTEQUAL expr");
            }
#line 3346 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 110:
#line 1019 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(16), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
            }
#line 3356 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 111:
#line 1026 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr DOTDOT expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(17), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr DOTDOT expr");
            }
#line 3366 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 112:
#line 1033 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr ':' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(18), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr ':' expr");
            }
#line 3376 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 113:
#line 1040 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> NOT expr");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(19), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> NOT expr");
            }
#line 3386 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 114:
#line 1047 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> '-' expr");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(20), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> '-' expr");
            }
#line 3396 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 115:
#line 1056 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("left_value -> declare_ip_variable cmdeq");
                (yyval.tree) = astnode_make1(RULE_left_value(1), (yyvsp[-1].tree));
                exitrule_ex("left_value -> declare_ip_variable cmdeq",(yyval.tree));
            }
#line 3406 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 116:
#line 1063 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("left_value -> exprlist cmdeq");
                (yyval.tree) = astnode_make1(RULE_left_value(2), (yyvsp[-1].tree));
                exitrule("left_value -> exprlist cmdeq");
            }
#line 3416 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 117:
#line 1073 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("extendedid -> UNKNOWN_IDENT");
                (yyval.tree) = astnode_make1(RULE_extendedid(1), aststring_make((yyvsp[0].name)));
                exitrule_ex("extendedid -> UNKNOWN_IDENT",(yyval.tree));
            }
#line 3426 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 118:
#line 1080 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("extendedid -> '`' expr '`'");
                (yyval.tree) = astnode_make1(RULE_extendedid(2), (yyvsp[-1].tree));
                exitrule_ex("extendedid -> '`' expr '`'",(yyval.tree));
            }
#line 3436 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 119:
#line 1090 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> ROOT_DECL elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(1), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("declare_ip_variable -> ROOT_DECL elemexpr",(yyval.tree));
            }
#line 3446 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 120:
#line 1097 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> UNKNOWN_IDENT elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(99), aststring_make((yyvsp[-1].name)), (yyvsp[0].tree));
                exitrule_ex("declare_ip_variable -> UNKNOWN_IDENT elemexpr",(yyval.tree));
            }
#line 3456 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 121:
#line 1104 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(2), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
            }
#line 3466 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 122:
#line 1111 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> RING_DECL elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(3), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> RING_DECL elemexpr");
            }
#line 3476 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 123:
#line 1118 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(4), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
            }
#line 3486 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 124:
#line 1125 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
                (yyval.tree) = astnode_make4(RULE_declare_ip_variable(5), (yyvsp[-7].tree), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
            }
#line 3496 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 125:
#line 1132 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> mat_cmd elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(6), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> mat_cmd elemexpr");
            }
#line 3506 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 126:
#line 1139 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(7), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
            }
#line 3516 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 127:
#line 1146 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> PROC_CMD elemexpr");
                (yyval.tree) = astnode_make1(RULE_declare_ip_variable(8), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> PROC_CMD elemexpr");
            }
#line 3526 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 128:
#line 1155 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("stringexpr -> STRINGTOK");
                (yyval.tree) = astnode_make1(RULE_stringexpr(1), aststring_make((yyvsp[0].name)));
                exitrule("stringexpr -> STRINGTOK");
            }
#line 3536 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 129:
#line 1164 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("rlist -> expr");
                (yyval.tree) = astnode_make1(RULE_rlist(1), (yyvsp[0].tree));
                exitrule("rlist -> expr");
            }
#line 3546 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 130:
#line 1171 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("rlist -> '(' expr ',' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_rlist(2), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("rlist -> '(' expr ',' exprlist ')'");
            }
#line 3556 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 131:
#line 1180 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordername -> UNKNOWN_IDENT");
                (yyval.tree) = astnode_make1(RULE_ordername(1), aststring_make((yyvsp[0].name)));
                exitrule("ordername -> UNKNOWN_IDENT");
            }
#line 3566 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 132:
#line 1189 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("orderelem -> ordername");
                (yyval.tree) = astnode_make1(RULE_orderelem(1), (yyvsp[0].tree));
                exitrule("orderelem -> ordername");
            }
#line 3576 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 133:
#line 1195 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("orderelem -> ordername '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_orderelem(2), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("orderelem -> ordername '(' exprlist ')'");
            }
#line 3586 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 134:
#line 1204 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("OrderingList -> orderelem");
                (yyval.tree) = astnode_make1(RULE_OrderingList(1), (yyvsp[0].tree));
                exitrule("OrderingList -> orderelem");
            }
#line 3596 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 135:
#line 1211 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("OrderingList -> orderelem ',' OrderingList");
                (yyval.tree) = astnode_make2(RULE_OrderingList(2), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("OrderingList -> orderelem ',' OrderingList");
            }
#line 3606 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 136:
#line 1220 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordering -> orderelem");
                (yyval.tree) = astnode_make1(RULE_ordering(1), (yyvsp[0].tree));
                exitrule("ordering -> orderelem");
            }
#line 3616 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 137:
#line 1227 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordering -> '(' OrderingList ')'");
                (yyval.tree) = astnode_make1(RULE_ordering(2), (yyvsp[-1].tree));
                exitrule("ordering -> '(' OrderingList ')'");
            }
#line 3626 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 138:
#line 1235 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("cmdeq -> '='");
                (yyval.i) = (yyvsp[0].i);
                exitrule("cmdeq -> '='");
            }
#line 3636 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 139:
#line 1244 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> MATRIX_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(1), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> MATRIX_CMD");
            }
#line 3646 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 140:
#line 1251 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> INTMAT_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(2), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> INTMAT_CMD");
            }
#line 3656 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 141:
#line 1258 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> BIGINTMAT_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(3), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> BIGINTMAT_CMD");
            }
#line 3666 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 142:
#line 1271 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("filecmd -> '<' stringexpr");
                (yyval.tree) = astnode_make1(RULE_filecmd(1), (yyvsp[0].tree));
                exitrule("filecmd -> '<' stringexpr");
            }
#line 3676 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 143:
#line 1280 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("helpcmd -> HELP_CMD STRINGTOK ';'");
                (yyval.tree) = astnode_make1(RULE_helpcmd(1), aststring_make((yyvsp[-1].name)));
                exitrule("helpcmd -> HELP_CMD STRINGTOK ';'");
            }
#line 3686 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 144:
#line 1287 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("helpcmd -> HELP_CMD ';'");
                (yyval.tree) = astnode_make0(RULE_helpcmd(2));
                exitrule("helpcmd -> HELP_CMD ';'");
            }
#line 3696 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 145:
#line 1296 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
                (yyval.tree) = astnode_make1(RULE_examplecmd(1), aststring_make((yyvsp[-1].name)));
                exitrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
            }
#line 3706 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 146:
#line 1305 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exportcmd -> EXPORT_CMD exprlist");
                (yyval.tree) = astnode_make1(RULE_exportcmd(1), (yyvsp[0].tree));
                exitrule("exportcmd -> EXPORT_CMD exprlist");
            }
#line 3716 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 147:
#line 1314 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("killcmd -> KILL_CMD elemexpr");
                (yyval.tree) = astnode_make1(RULE_killcmd(1), (yyvsp[0].tree));
                exitrule("killcmd -> KILL_CMD elemexpr");
            }
#line 3726 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 148:
#line 1321 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("killcmd -> killcmd ',' elemexpr");
                (yyval.tree) = astnode_make2(RULE_killcmd(2), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("killcmd -> killcmd ',' elemexpr");
            }
#line 3736 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 149:
#line 1330 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(1), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }
#line 3746 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 150:
#line 1337 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(2), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
            }
#line 3756 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 151:
#line 1344 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(3), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }
#line 3766 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 152:
#line 1351 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(4), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
            }
#line 3776 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 153:
#line 1358 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(5), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
            }
#line 3786 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 154:
#line 1365 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(6), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
            }
#line 3796 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 155:
#line 1372 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(7), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
            }
#line 3806 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 156:
#line 1379 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(8), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
            }
#line 3816 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 157:
#line 1386 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(9), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
            }
#line 3826 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 158:
#line 1393 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(10), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
            }
#line 3836 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 159:
#line 1400 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(11), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
            }
#line 3846 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 160:
#line 1407 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(12), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
            }
#line 3856 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 161:
#line 1414 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(13), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
            }
#line 3866 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 162:
#line 1421 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(14), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
            }
#line 3876 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 163:
#line 1428 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(15), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
            }
#line 3886 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 164:
#line 1435 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ')'");
                (yyval.tree) = astnode_make0(RULE_listcmd(16));
                exitrule("listcmd -> LISTVAR_CMD '(' ')'");
            }
#line 3896 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 165:
#line 1444 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd1 -> RING_CMD");
                (yyval.tree) = astnode_make0(RULE_ringcmd1(1));
                exitrule("ringcmd1 -> RING_CMD");
            }
#line 3906 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 166:
#line 1457 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
                (yyval.tree) = astnode_make4(RULE_ringcmd(1), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
            }
#line 3916 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 167:
#line 1464 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr");
                (yyval.tree) = astnode_make1(RULE_ringcmd(2), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr");
            }
#line 3926 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 168:
#line 1471 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
                (yyval.tree) = astnode_make2(RULE_ringcmd(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
            }
#line 3936 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 169:
#line 1478 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
                (yyval.tree) = astnode_make3(RULE_ringcmd(4), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
            }
#line 3946 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 170:
#line 1487 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("scriptcmd -> SYSVAR stringexpr");
                (yyval.tree) = astnode_make2(RULE_scriptcmd(1), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("scriptcmd -> SYSVAR stringexpr");
            }
#line 3956 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 171:
#line 1496 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setrings -> SETRING_CMD");
                (yyval.tree) = astnode_make0(RULE_setrings(1));
                exitrule("setrings -> SETRING_CMD");
            }
#line 3966 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 172:
#line 1502 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setrings -> KEEPRING_CMD");
                (yyval.tree) = astnode_make0(RULE_setrings(2));
                exitrule("setrings -> KEEPRING_CMD");
            }
#line 3976 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 173:
#line 1511 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setringcmd -> setrings expr");
                (yyval.tree) = astnode_make2(RULE_setringcmd(1), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule("setringcmd -> setrings expr");
            }
#line 3986 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 174:
#line 1520 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("typecmd -> TYPE_CMD expr");
                (yyval.tree) = astnode_make1(RULE_typecmd(1), (yyvsp[0].tree));
                exitrule("typecmd -> TYPE_CMD expr");
            }
#line 3996 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 175:
#line 1527 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("typecmd -> exprlist");
                (yyval.tree) = astnode_make1(RULE_typecmd(2), (yyvsp[0].tree));
                exitrule_ex("typecmd -> exprlist", (yyval.tree));
            }
#line 4006 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 176:
#line 1539 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_ifcmd(1), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'",(yyval.tree));
            }
#line 4016 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 177:
#line 1546 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> ELSE_CMD '{' lines '}'");
                (yyval.tree) = astnode_make1(RULE_ifcmd(2), (yyvsp[-1].tree));
                exitrule_ex("ifcmd -> ELSE_CMD '{' lines '}'",(yyval.tree));
            }
#line 4026 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 178:
#line 1553 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
                (yyval.tree) = astnode_make1(RULE_ifcmd(3), (yyvsp[-2].tree));
                exitrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
            }
#line 4036 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 179:
#line 1560 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> BREAK_CMD");
                (yyval.tree) = astnode_make0(RULE_ifcmd(4));
                exitrule("ifcmd -> BREAK_CMD");
            }
#line 4046 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 180:
#line 1567 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> CONTINUE_CMD");
                (yyval.tree) = astnode_make0(RULE_ifcmd(5));
                exitrule("ifcmd -> CONTINUE_CMD");
            }
#line 4056 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 181:
#line 1576 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_whilecmd(1), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'",(yyval.tree));
            }
#line 4066 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 182:
#line 1585 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'");
                (yyval.tree) = astnode_make4(RULE_forcmd(1), (yyvsp[-8].tree), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'",(yyval.tree));
            }
#line 4076 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 183:
#line 1594 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(1), aststring_make((yyvsp[-3].name)), (yyvsp[-1].tree));
                exitrule("proccmd -> PROC_CMD extendedid '{' lines '}'");
            }
#line 4086 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 184:
#line 1601 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '(' ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(2), aststring_make((yyvsp[-5].name)), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid '(' ')' '{' lines '}'",(yyval.tree));
            }
#line 4096 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 185:
#line 1608 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make3(RULE_proccmd(3), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4106 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 186:
#line 1615 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make4(RULE_proccmd(4), aststring_make((yyvsp[-7].name)), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4116 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 187:
#line 1622 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> STATIC_PROC_CMD extendedid '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(11), aststring_make((yyvsp[-3].name)), (yyvsp[-1].tree));
                exitrule("proccmd -> STATIC_PROC_CMD extendedid '{' lines '}'");
            }
#line 4126 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 188:
#line 1629 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> STATIC_PROC_CMD extendedid '(' ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(12), aststring_make((yyvsp[-5].name)), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> STATIC_PROC_CMD extendedid '(' ')' '{' lines '}'",(yyval.tree));
            }
#line 4136 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 189:
#line 1636 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> STATIC_PROC_CMD extendedid '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make3(RULE_proccmd(13), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> STATIC_PROC_CMD extendedid '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4146 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 190:
#line 1643 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> STATIC_PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make4(RULE_proccmd(14), aststring_make((yyvsp[-7].name)), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> STATIC_PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4156 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 191:
#line 1652 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("parametercmd -> PARAMETER declare_ip_variable");
                (yyval.tree) = astnode_make1(RULE_parametercmd(1), (yyvsp[0].tree));
                exitrule("parametercmd -> PARAMETER declare_ip_variable");
            }
#line 4166 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 192:
#line 1659 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("parametercmd -> PARAMETER expr");
                (yyval.tree) = astnode_make1(RULE_parametercmd(2), (yyvsp[0].tree));
                exitrule("parametercmd -> PARAMETER expr");
            }
#line 4176 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 193:
#line 1668 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("returncmd -> RETURN '(' exprlist ')'");
                (yyval.tree) = astnode_make1(RULE_returncmd(1), (yyvsp[-1].tree));
                exitrule_ex("returncmd -> RETURN '(' exprlist ')'",(yyval.tree));
            }
#line 4186 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 194:
#line 1675 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("returncmd -> RETURN '(' ')'");
                (yyval.tree) = astnode_make0(RULE_returncmd(2));
                exitrule_ex("returncmd -> RETURN '(' ')'",(yyval.tree));
            }
#line 4196 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 195:
#line 1684 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarglist -> procarglist ',' procarg");
                (yyval.tree) = astnode_append((yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("procarglist -> procarglist ',' procarg",(yyval.tree));
            }
#line 4206 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 196:
#line 1691 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarglist -> procarg");
                (yyval.tree) = astnode_make1(RULE_procarglist(1), (yyvsp[0].tree));
                exitrule_ex("procarglist -> procarg",(yyval.tree));
            }
#line 4216 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 197:
#line 1700 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> UNKNOWN_IDENT extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(1), aststring_make((yyvsp[-1].name)), (yyvsp[0].tree));
                exitrule_ex("procarg -> UNKNOWN_IDENT extendedid",(yyval.tree));
            }
#line 4226 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 198:
#line 1706 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(2), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL extendedid",(yyval.tree));
            }
#line 4236 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 199:
#line 1713 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(3), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",(yyval.tree));
            }
#line 4246 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 200:
#line 1720 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(4), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",(yyval.tree));
            }
#line 4256 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 201:
#line 1727 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(5), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",(yyval.tree));
            }
#line 4266 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 202:
#line 1734 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> PROC_CMD extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(6), astint_make(PROC_CMD), (yyvsp[0].tree));
                exitrule_ex("procarg -> PROC_CMD extendedid",(yyval.tree));
            }
#line 4276 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 203:
#line 1741 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(7), astint_make(DEF_CMD), (yyvsp[0].tree));
                exitrule_ex("procarg -> extendedid",(yyval.tree));
            }
#line 4286 "grammar.tab.c" /* yacc.c:1646  */
    break;


#line 4290 "grammar.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (retv, YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (retv, yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, retv);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp, retv);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (retv, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, retv);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp, retv);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 1748 "grammar.y" /* yacc.c:1906  */



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

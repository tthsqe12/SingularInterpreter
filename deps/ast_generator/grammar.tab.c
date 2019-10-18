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
    RING_CMD = 272,
    BEGIN_RING = 273,
    BUCKET_CMD = 274,
    IDEAL_CMD = 275,
    MAP_CMD = 276,
    MATRIX_CMD = 277,
    MODUL_CMD = 278,
    NUMBER_CMD = 279,
    POLY_CMD = 280,
    RESOLUTION_CMD = 281,
    SMATRIX_CMD = 282,
    VECTOR_CMD = 283,
    BETTI_CMD = 284,
    E_CMD = 285,
    FETCH_CMD = 286,
    FREEMODULE_CMD = 287,
    KEEPRING_CMD = 288,
    IMAP_CMD = 289,
    KOSZUL_CMD = 290,
    MAXID_CMD = 291,
    MONOM_CMD = 292,
    PAR_CMD = 293,
    PREIMAGE_CMD = 294,
    VAR_CMD = 295,
    VALTVARS = 296,
    VMAXDEG = 297,
    VMAXMULT = 298,
    VNOETHER = 299,
    VMINPOLY = 300,
    END_RING = 301,
    CMD_1 = 302,
    CMD_2 = 303,
    CMD_3 = 304,
    CMD_12 = 305,
    CMD_13 = 306,
    CMD_23 = 307,
    CMD_123 = 308,
    CMD_M = 309,
    NEWSTRUCT_CMD = 310,
    ROOT_DECL_NEWSTRUCT = 311,
    ROOT_DECL = 312,
    ROOT_DECL_LIST = 313,
    RING_DECL = 314,
    RING_DECL_LIST = 315,
    EXAMPLE_CMD = 316,
    EXPORT_CMD = 317,
    HELP_CMD = 318,
    KILL_CMD = 319,
    LIB_CMD = 320,
    LISTVAR_CMD = 321,
    SETRING_CMD = 322,
    TYPE_CMD = 323,
    STRINGTOK = 324,
    INT_CONST = 325,
    UNKNOWN_IDENT = 326,
    RINGVAR = 327,
    PROC_DEF = 328,
    APPLY = 329,
    ASSUME_CMD = 330,
    BREAK_CMD = 331,
    CONTINUE_CMD = 332,
    ELSE_CMD = 333,
    EVAL = 334,
    QUOTE = 335,
    FOR_CMD = 336,
    IF_CMD = 337,
    SYS_BREAK = 338,
    WHILE_CMD = 339,
    RETURN = 340,
    PARAMETER = 341,
    QUIT_CMD = 342,
    SYSVAR = 343,
    UMINUS = 344
  };
#endif

/* Value type.  */



int yyparse (astree ** retv);

#endif /* !YY_YY_GRAMMAR_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 231 "grammar.tab.c" /* yacc.c:358  */

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
#define YYLAST   3663

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  108
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  49
/* YYNRULES -- Number of rules.  */
#define YYNRULES  197
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  463

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   344

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    99,     2,
     102,   103,     2,    91,    97,    92,   106,    93,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,   100,    98,
      90,    89,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    94,     2,    95,    96,     2,   107,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   104,     2,   105,     2,     2,     2,     2,
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
      85,    86,    87,    88,   101
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   203,   203,   210,   220,   227,   234,   241,   248,   255,
     264,   270,   279,   286,   293,   300,   307,   314,   321,   331,
     338,   345,   352,   359,   366,   375,   382,   389,   396,   403,
     410,   417,   424,   432,   440,   447,   454,   461,   468,   475,
     482,   489,   496,   504,   513,   520,   527,   534,   541,   548,
     555,   562,   569,   576,   583,   590,   597,   604,   611,   618,
     625,   632,   639,   646,   653,   660,   667,   674,   683,   690,
     697,   704,   711,   718,   725,   732,   739,   746,   753,   760,
     767,   774,   783,   790,   798,   805,   812,   819,   826,   833,
     840,   847,   854,   861,   868,   875,   882,   890,   889,   903,
     911,   919,   928,   935,   942,   949,   956,   978,   985,  1007,
    1021,  1028,  1035,  1042,  1049,  1056,  1065,  1072,  1082,  1089,
    1099,  1106,  1113,  1120,  1127,  1134,  1141,  1148,  1155,  1164,
    1173,  1180,  1189,  1198,  1204,  1213,  1220,  1229,  1236,  1244,
    1253,  1260,  1267,  1280,  1289,  1296,  1305,  1314,  1323,  1330,
    1339,  1346,  1353,  1360,  1367,  1374,  1381,  1388,  1395,  1402,
    1409,  1416,  1423,  1430,  1437,  1444,  1453,  1462,  1473,  1480,
    1487,  1496,  1505,  1511,  1520,  1529,  1536,  1548,  1555,  1562,
    1569,  1576,  1585,  1594,  1603,  1610,  1617,  1624,  1633,  1640,
    1649,  1656,  1665,  1672,  1681,  1688,  1695,  1702
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "DOTDOT", "EQUAL_EQUAL", "GE", "LE",
  "MINUSMINUS", "NOT", "NOTEQUAL", "PLUSPLUS", "COLONCOLON", "ARROW",
  "GRING_CMD", "BIGINTMAT_CMD", "INTMAT_CMD", "PROC_CMD", "RING_CMD",
  "BEGIN_RING", "BUCKET_CMD", "IDEAL_CMD", "MAP_CMD", "MATRIX_CMD",
  "MODUL_CMD", "NUMBER_CMD", "POLY_CMD", "RESOLUTION_CMD", "SMATRIX_CMD",
  "VECTOR_CMD", "BETTI_CMD", "E_CMD", "FETCH_CMD", "FREEMODULE_CMD",
  "KEEPRING_CMD", "IMAP_CMD", "KOSZUL_CMD", "MAXID_CMD", "MONOM_CMD",
  "PAR_CMD", "PREIMAGE_CMD", "VAR_CMD", "VALTVARS", "VMAXDEG", "VMAXMULT",
  "VNOETHER", "VMINPOLY", "END_RING", "CMD_1", "CMD_2", "CMD_3", "CMD_12",
  "CMD_13", "CMD_23", "CMD_123", "CMD_M", "NEWSTRUCT_CMD",
  "ROOT_DECL_NEWSTRUCT", "ROOT_DECL", "ROOT_DECL_LIST", "RING_DECL",
  "RING_DECL_LIST", "EXAMPLE_CMD", "EXPORT_CMD", "HELP_CMD", "KILL_CMD",
  "LIB_CMD", "LISTVAR_CMD", "SETRING_CMD", "TYPE_CMD", "STRINGTOK",
  "INT_CONST", "UNKNOWN_IDENT", "RINGVAR", "PROC_DEF", "APPLY",
  "ASSUME_CMD", "BREAK_CMD", "CONTINUE_CMD", "ELSE_CMD", "EVAL", "QUOTE",
  "FOR_CMD", "IF_CMD", "SYS_BREAK", "WHILE_CMD", "RETURN", "PARAMETER",
  "QUIT_CMD", "SYSVAR", "'='", "'<'", "'+'", "'-'", "'/'", "'['", "']'",
  "'^'", "','", "';'", "'&'", "':'", "UMINUS", "'('", "')'", "'{'", "'}'",
  "'.'", "'`'", "$accept", "top_lines", "top_pprompt", "lines", "pprompt",
  "npprompt", "flowctrl", "example_dummy", "command", "assign", "elemexpr",
  "exprlist", "expr", "$@1", "quote_start", "assume_start", "quote_end",
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
     335,   336,   337,   338,   339,   340,   341,   342,   343,    61,
      60,    43,    45,    47,    91,    93,    94,    44,    59,    38,
      58,   344,    40,    41,   123,   125,    46,    96
};
# endif

#define YYPACT_NINF -417

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-417)))

#define YYTABLE_NINF -170

#define yytable_value_is_error(Yytable_value) \
  (!!((Yytable_value) == (-170)))

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    -417,   490,  -417,   -82,  2944,  -417,  -417,  3012,   -71,  -417,
    -417,   -44,   -33,   -16,   -11,     8,    30,    41,    52,    60,
    2944,  3080,  3148,  3216,  3284,   -56,  2944,   -46,  2944,    75,
    -417,  2944,  -417,  -417,  -417,  -417,    82,   104,  -417,  -417,
     -84,   114,   126,   130,   139,  -417,   142,  2468,    83,    83,
    2944,  2944,  -417,  2944,  2944,  -417,  -417,  -417,    47,  -417,
      26,   -62,  2375,  2944,  2944,  -417,  2944,   155,   -42,  -417,
    3352,  -417,  -417,  -417,  -417,   153,  -417,  2944,  -417,  -417,
    2944,  -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,   158,
     -71,   167,   170,   182,   192,  -417,    70,   196,   -59,  2944,
     399,  2375,  3420,  2944,  2944,  2944,  2944,  2944,  2944,  2944,
    2536,   231,   492,  2944,   507,  2604,   697,  2944,   887,  2672,
    1077,   204,  -417,   207,   219,  -417,   251,  2740,  2375,  2944,
    -417,  -417,  -417,  -417,  1535,  2944,  2944,  3488,  2375,   214,
    -417,  -417,    70,   -80,   -65,   230,  -417,  2944,  2808,  -417,
    2944,  -417,  2944,  2944,  -417,  2944,  -417,  2944,  2944,  2944,
    2944,  2944,  2944,  2944,  2944,  2944,    15,  1283,   207,   215,
    2944,  -417,  -417,  2944,    89,  2944,   140,  2375,  2944,  2944,
    2604,  2944,  2672,  2944,   225,  1880,  -417,  1566,  2944,  1629,
     234,  1664,  1681,  1692,   356,   377,  1703,   523,  -417,   -35,
     235,  1727,  -417,   -27,  1801,  -417,   -24,  -417,   585,  -417,
      32,    72,    94,   154,   156,   161,  -417,   149,   164,  1825,
     680,  2944,  -417,  -417,   226,   236,  -417,  -417,   -55,  -417,
    1836,  1853,  -417,  -417,  -417,  -417,  -417,   -19,  2375,   302,
     109,   109,   618,    65,    65,    70,  1555,    23,   337,    65,
    -417,  2944,  -417,  -417,  2944,  -417,  1267,   713,  2944,   601,
    3420,  1566,  1727,   -14,  1801,   -10,   713,    24,   -63,   -63,
     -63,   238,  -417,    50,  -417,   775,  -417,  1870,  -417,  3420,
    -417,  2944,  2944,  2944,  -417,  2944,  -417,  2944,  2944,  -417,
    -417,   266,  -417,  -417,  -417,  -417,   240,  -417,  -417,  -417,
    -417,  -417,   245,   -38,  -417,  -417,  -417,  -417,  -417,  -417,
    -417,  1854,  -417,  -417,  3556,  -417,  1899,  2876,  2944,   -47,
     241,  -417,  -417,  2944,  1968,  1968,   870,  2944,  -417,  1997,
      91,  2375,   253,  -417,  -417,    53,  -417,  -417,  -417,  -417,
      24,   247,  -417,  2944,   255,  2008,  2025,  2036,  2066,   903,
    1093,   252,  -417,  -417,  -417,   254,   258,   259,   261,   264,
     265,   267,   184,   187,   205,   211,   213,  2134,  -417,  -417,
      76,  2164,  -417,  -417,  -417,  2181,  -417,  -417,  -417,  2192,
     277,  2944,  3420,   269,   965,  -417,  -417,   107,   -66,  -417,
    2944,  -417,  2944,  2944,  -417,  2944,  -417,  -417,  -417,  -417,
    -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,
    -417,  -417,  1535,  1060,  1155,  -417,  2944,  2944,     6,   278,
    -417,  -417,  1250,  -417,  -417,   287,   272,  -417,   274,  2203,
    2232,  2301,  2330,   276,  -417,  -417,  2347,  2364,  -417,   -66,
    1345,  -417,   285,   282,  2944,  -417,  -417,  -417,  -417,  -417,
     284,  -417,  -417,  -417,  -417,   287,  -417,   133,  -417,  -417,
    -417,  1440,  -417
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       2,     0,     1,     0,     0,   142,   141,     0,   166,   140,
     173,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     172,     0,   129,    51,   118,    44,     0,     0,   180,   181,
       0,     0,     0,     0,     0,     7,     0,     0,    52,     0,
       0,     0,     8,     0,     0,     3,     4,    27,     0,    34,
      85,   176,    83,     0,     0,    84,     0,    45,     0,    53,
       0,    30,    31,    32,    35,    36,    37,     0,    39,    40,
       0,    41,    42,    25,    26,    28,    29,    38,     9,     0,
       0,     0,     0,     0,     0,    52,   114,     0,   118,     0,
      85,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    85,     0,    85,     0,    85,     0,    85,     0,
      85,     0,    10,   147,     0,   145,    85,     0,   175,     0,
     100,    10,    97,    99,     0,     0,     0,     0,   189,   188,
     171,   143,   115,     0,     0,     0,     5,     0,     0,   139,
       0,   117,     0,     0,   103,     0,   102,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    43,     0,
       0,     6,   116,     0,    85,     0,    85,   174,     0,     0,
       0,     0,     0,     0,     0,     0,    10,    83,     0,   130,
       0,     0,     0,     0,     0,     0,     0,     0,    74,     0,
       0,    83,    57,     0,    83,    60,     0,   146,     0,   144,
       0,     0,     0,     0,     0,     0,   165,    85,     0,     0,
       0,     0,    24,    23,     0,     0,    19,    20,    21,    22,
       0,     0,    50,    81,   119,    46,    48,     0,    82,   112,
     111,   110,   108,   104,   105,   106,     0,   107,   109,   113,
      47,     0,   101,    94,     0,    10,    85,     0,     0,    85,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   197,     0,   193,     0,    54,    83,    79,     0,
      61,     0,     0,     0,    62,     0,    63,     0,     0,    64,
      75,     0,    55,    56,    58,    59,     0,    16,    17,    33,
      11,    12,     0,     0,    15,   156,   154,   150,   151,   152,
     153,     0,   157,   155,     0,   178,     0,     0,     0,     0,
       0,    49,    87,     0,     0,     0,     0,     0,    77,     0,
      85,   130,     0,    56,    59,     0,   196,   194,   195,    10,
       0,     0,   184,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    18,    13,    14,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    98,   191,
       0,     0,   179,    10,    10,     0,    95,    96,    80,     0,
       0,     0,     0,     0,     0,   192,    10,     0,     0,    65,
       0,    66,     0,     0,    68,     0,    69,    67,   164,   162,
     158,   159,   160,   161,   163,    88,    89,    90,    91,    92,
      93,   190,     0,     0,     0,    86,     0,     0,     0,     0,
      10,   185,     0,   131,   132,     0,   133,   137,     0,     0,
       0,     0,     0,     0,   177,   182,     0,     0,   170,     0,
       0,   186,   135,     0,     0,    78,    70,    71,    72,    73,
       0,    76,   125,   167,   187,     0,   138,     0,    10,   136,
     134,     0,   183
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -417,  -417,  -417,  -125,  -417,   -23,     3,  -417,    10,  -417,
      43,   -25,   118,  -417,  -417,  -417,  -271,  -417,  -417,  -171,
       2,   163,  -258,  -417,  -416,   -64,   -32,   -49,    -1,  -417,
    -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,  -417,
    -417,  -417,  -417,  -417,  -417,  -417,  -127,   123,    64
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     1,    55,   208,   300,   225,   301,    57,   302,    59,
      60,    61,    62,   221,    63,    64,   253,    65,    66,    67,
     303,    69,   190,   426,   427,   443,   428,   172,    97,    71,
      72,    73,    74,    75,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,   304,   273,   274
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      70,   123,   332,    68,    56,   424,   220,   229,    34,   442,
     184,    58,   151,   121,   272,   232,    88,   150,   152,   153,
     131,   344,   154,   124,   155,   156,   143,   149,   144,   372,
     154,   102,   150,   156,   149,   150,   425,   147,   233,   442,
     268,   168,   170,   185,    54,   186,    70,   149,   122,   139,
     100,   149,   125,   376,   377,   170,   171,   373,   103,   170,
     354,   275,   150,   112,   114,   116,   118,   120,   290,   104,
     150,   126,   154,   150,   144,   156,   293,   154,   150,   295,
     156,   269,   270,   150,   321,   199,   105,   150,   144,   333,
     203,   106,   144,   334,   206,    34,   272,   336,   337,   338,
     147,   438,   147,   150,   251,   157,   158,   159,   160,   161,
     107,   162,   152,   174,   163,   164,   154,   161,   252,   156,
     176,   165,    96,   237,   419,   101,   218,   260,   148,   165,
     326,    54,   108,    70,   178,   305,   228,   226,   101,   101,
     101,   101,   101,   109,   227,   146,   101,   340,   144,   128,
     340,   147,    32,   341,   110,   263,   383,   265,   160,   161,
     147,   162,   111,   144,   161,   138,   162,   169,   142,   272,
     217,   165,   145,   150,   102,   306,   165,   127,  -126,   411,
     100,   166,   167,   258,   129,   381,  -126,  -126,   101,  -169,
     235,   148,  -126,   148,  -169,   101,   179,   307,   177,   157,
     158,   159,   160,   161,   150,   162,   130,    70,   250,   164,
     423,   140,   141,   256,   384,   165,   132,   187,   259,    70,
     189,   191,   192,   193,   194,   195,   196,   197,   133,   149,
     150,   201,   134,   152,   153,   204,   460,   154,  -168,   155,
     156,   135,   148,  -168,   136,   101,   311,   219,   413,   414,
     175,   148,   312,   230,   231,   101,   180,   308,   181,   309,
     178,   422,   147,   182,   310,   101,   183,   313,   238,   179,
     239,   240,   180,   241,    70,   242,   243,   244,   245,   246,
     247,   248,   249,   101,   181,   229,   103,   405,   101,   106,
     406,   257,   370,   101,   182,   440,   261,   262,   183,   264,
     200,   266,   207,   330,   150,  -170,   277,   107,   407,   154,
     361,   170,   156,   109,   408,   110,   409,   209,   387,   255,
     157,   158,   159,   160,   161,    70,   162,   267,   317,   163,
     164,   279,   291,   461,   318,   351,   165,   234,   352,   316,
     152,   153,   339,   353,   154,   374,   155,   156,  -148,  -148,
     382,   386,   388,   148,  -148,   397,   418,   398,   424,   152,
     153,   399,   400,   154,   401,   155,   156,   402,   403,   324,
     404,   417,   325,   420,   444,   439,   329,   445,   331,   450,
     152,   153,   455,    70,   154,   456,   155,   156,   458,   433,
     335,   459,     0,   158,   159,   160,   161,   331,   162,   345,
     346,   347,   164,   348,   385,   349,   350,   453,   165,     0,
     147,    70,    70,    70,   228,   226,     0,     0,     0,   457,
       0,    70,   227,     0,     0,     0,     0,   157,   158,   159,
     160,   161,   367,   162,     0,     0,   371,   164,     0,    70,
       0,   375,     0,   165,     0,   379,   157,   158,   159,   160,
     161,     0,   162,   283,     0,   163,   164,     0,     0,   284,
      70,     0,   165,     0,     0,     0,     0,   157,   158,   159,
     160,   161,     0,   162,   285,     0,   163,   164,     0,     0,
     286,     0,     0,   165,     0,     0,     0,     0,  -128,     0,
       2,     3,     0,     0,     0,     0,  -128,  -128,     4,     0,
     331,   148,  -128,   147,     5,     6,     7,     8,   429,     0,
     430,   431,     9,   432,     0,     0,     0,     0,   147,     0,
       0,     0,     0,    10,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,   436,   437,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,    45,    46,     0,    47,     0,    48,     0,
      49,  -121,    50,     0,    51,     0,   296,     0,    52,  -121,
    -121,     0,    53,     4,   148,  -121,  -120,    54,     0,     5,
       6,     7,     8,     0,  -120,  -120,     0,     9,     0,   148,
    -120,     0,   147,   157,   158,   159,   160,   161,    10,   162,
     288,   152,   163,   164,     0,   154,   289,     0,   156,   165,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   297,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,   296,     0,   298,     0,     0,     0,    53,     4,     0,
     299,     0,    54,     0,     5,     6,     7,     8,  -149,  -149,
       0,     0,     9,   148,  -149,     0,     0,     0,   147,   158,
     159,   160,   161,    10,   162,     0,   152,   153,   164,     0,
     154,     0,   155,   156,   165,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,   297,    46,   224,    47,     0,    48,     0,
      49,     0,    50,     0,    51,     0,   296,     0,   298,     0,
       0,     0,    53,     4,     0,   315,  -122,    54,     0,     5,
       6,     7,     8,     0,  -122,  -122,     0,     9,     0,   148,
    -122,     0,     0,   157,   158,   159,   160,   161,    10,   162,
     327,     0,   163,   164,     0,     0,   328,     0,     0,   165,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   297,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,   296,     0,   298,     0,     0,     0,    53,     4,     0,
     342,     0,    54,     0,     5,     6,     7,     8,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,   147,     0,
       0,     0,     0,    10,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,   297,    46,   224,    47,     0,    48,     0,
      49,     0,    50,     0,    51,     0,   296,     0,   298,     0,
       0,     0,    53,     4,     0,   378,  -123,    54,     0,     5,
       6,     7,     8,     0,  -123,  -123,     0,     9,     0,   148,
    -123,     0,     0,   157,   158,   159,   160,   161,    10,   162,
     393,     0,   163,   164,     0,     0,   394,     0,     0,   165,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   297,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,   296,     0,   298,     0,     0,     0,    53,     4,     0,
     421,     0,    54,     0,     5,     6,     7,     8,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,   147,     0,
       0,     0,     0,    10,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,   297,    46,   224,    47,     0,    48,     0,
      49,     0,    50,     0,    51,     0,   296,     0,   298,     0,
       0,     0,    53,     4,     0,   434,  -124,    54,     0,     5,
       6,     7,     8,     0,  -124,  -124,     0,     9,     0,   148,
    -124,     0,     0,   157,   158,   159,   160,   161,    10,   162,
     395,     0,   163,   164,     0,     0,   396,     0,     0,   165,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   297,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,   296,     0,   298,     0,     0,     0,    53,     4,     0,
     435,     0,    54,     0,     5,     6,     7,     8,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,   147,     0,
       0,     0,     0,    10,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,   297,    46,   224,    47,     0,    48,     0,
      49,     0,    50,     0,    51,     0,   296,     0,   298,     0,
       0,     0,    53,     4,     0,   441,  -127,    54,     0,     5,
       6,     7,     8,     0,  -127,  -127,     0,     9,     0,   148,
    -127,     0,     0,   157,   158,   159,   160,   161,    10,   162,
     254,     0,   163,   164,     0,     0,     0,     0,     0,   165,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   297,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,   296,     0,   298,     0,     0,     0,    53,     4,     0,
     454,     0,    54,     0,     5,     6,     7,     8,     0,     0,
       0,     0,     9,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    10,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,     0,    29,    30,    31,    32,
      33,    34,    35,     0,    36,    37,    38,    39,    40,    41,
      42,    43,    44,   297,    46,   224,    47,     0,    48,     0,
      49,     0,    50,     0,    51,     0,   222,     0,   298,     0,
       0,     0,    53,     4,     0,   462,     0,    54,     0,     5,
       6,     7,     8,     0,     0,     0,     0,     9,   152,   153,
       0,     0,   154,     0,   155,   156,     0,     0,    10,   152,
     153,     0,     0,   154,     0,   155,   156,     0,     0,     0,
       0,     0,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
       0,    29,    30,    31,    32,    33,    34,    35,     0,    36,
      37,    38,    39,    40,    41,    42,    43,    44,   223,    46,
     224,    47,     0,    48,     0,    49,     0,    50,     0,    51,
       0,     0,   152,   153,     0,     0,   154,    53,   155,   156,
       0,     0,    54,     0,     0,   157,   158,   159,   160,   161,
     322,   162,   323,     0,   163,   164,   157,   158,   159,   160,
     161,   165,   162,     0,     0,   163,   164,   152,   153,   276,
       0,   154,   165,   155,   156,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   152,   153,     0,     0,   154,     0,
     155,   156,     0,     0,     0,   152,   153,     0,     0,   154,
       0,   155,   156,     0,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,     0,     0,   157,
     158,   159,   160,   161,     0,   162,     0,     0,   163,   164,
     152,   153,   278,     0,   154,   165,   155,   156,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   157,   158,   159,   160,   161,     0,
     162,     0,     0,   163,   164,     0,     0,   280,     0,     0,
     165,   157,   158,   159,   160,   161,     0,   162,   281,     0,
     163,   164,   157,   158,   159,   160,   161,   165,   162,   282,
       0,   163,   164,   157,   158,   159,   160,   161,   165,   162,
     287,     0,   163,   164,   152,   153,     0,     0,   154,   165,
     155,   156,     0,     0,     0,     0,     0,   157,   158,   159,
     160,   161,     0,   162,     0,     0,   163,   164,   152,   153,
     292,     0,   154,   165,   155,   156,     0,     0,     0,   152,
     153,     0,     0,   154,     0,   155,   156,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,     0,     5,     6,
     355,   356,     0,   152,   153,     0,     9,   154,     0,   155,
     156,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   157,   158,   159,   160,   161,   268,   162,     0,     0,
     163,   164,   152,   153,   294,     0,   154,   165,   155,   156,
       0,   357,   358,   359,   360,   157,   158,   159,   160,   161,
       0,   162,   314,     0,   163,   164,   157,   158,   159,   160,
     161,   165,   162,     0,     0,   163,   164,   269,   270,   319,
       0,     0,   165,   157,   158,   159,   160,   161,     0,   162,
       0,    34,   163,   164,     0,     0,   320,     0,     0,   165,
     157,   158,   159,   160,   161,     0,   162,   343,     0,   163,
     164,   152,   153,     0,     0,   154,   165,   155,   156,     0,
       0,     0,     0,   271,     0,     0,     0,    54,     0,   157,
     158,   159,   160,   161,     0,   162,     0,     0,   163,   164,
     152,   153,   368,     0,   154,   165,   155,   156,     0,     0,
       0,   152,   153,     0,     0,   154,     0,   155,   156,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   152,   153,
       0,     0,   154,     0,   155,   156,     0,     0,     0,   152,
     153,     0,     0,   154,     0,   155,   156,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   157,   158,
     159,   160,   161,     0,   162,     0,     0,   163,   164,   152,
     153,   252,     0,   154,   165,   155,   156,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   157,   158,   159,
     160,   161,   380,   162,     0,     0,   163,   164,   157,   158,
     159,   160,   161,   165,   162,     0,     0,   163,   164,     0,
       0,   389,     0,     0,   165,   157,   158,   159,   160,   161,
       0,   162,   390,     0,   163,   164,   157,   158,   159,   160,
     161,   165,   162,     0,     0,   163,   164,   152,   153,   391,
       0,   154,   165,   155,   156,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   157,   158,   159,   160,
     161,     0,   162,   392,     0,   163,   164,   152,   153,     0,
       0,   154,   165,   155,   156,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   152,   153,     0,     0,   154,     0,
     155,   156,     0,     0,     0,   152,   153,     0,     0,   154,
       0,   155,   156,     0,     0,     0,   152,   153,     0,     0,
     154,     0,   155,   156,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   157,   158,   159,   160,   161,     0,
     162,     0,     0,   163,   164,   152,   153,   410,     0,   154,
     165,   155,   156,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   157,   158,   159,   160,   161,     0,
     162,     0,   412,   163,   164,     0,     0,     0,     0,     0,
     165,   157,   158,   159,   160,   161,   415,   162,     0,     0,
     163,   164,   157,   158,   159,   160,   161,   165,   162,   416,
       0,   163,   164,   157,   158,   159,   160,   161,   165,   162,
       0,     0,   163,   164,   152,   153,   446,     0,   154,   165,
     155,   156,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   157,   158,   159,   160,   161,     0,   162,     0,
       0,   163,   164,   152,   153,   447,     0,   154,   165,   155,
     156,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     152,   153,     0,     0,   154,     0,   155,   156,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   152,   153,     0,
       0,   154,     0,   155,   156,     0,     0,     0,   152,   153,
       0,     0,   154,     0,   155,   156,     0,     0,     0,     0,
       0,   157,   158,   159,   160,   161,     0,   162,     0,     0,
     163,   164,     0,     0,   448,     0,     0,   165,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     157,   158,   159,   160,   161,     0,   162,     0,     0,   163,
     164,     0,     0,   449,     0,     0,   165,   157,   158,   159,
     160,   161,     0,   162,     0,     0,   163,   164,     0,     0,
     451,     0,     0,   165,   157,   158,   159,   160,   161,   452,
     162,     0,     0,   163,   164,   157,   158,   159,   160,   161,
     165,   162,     0,     0,   163,   164,     4,     0,     0,     0,
       0,   165,     5,     6,   137,    90,     0,     0,     0,     0,
       9,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,     0,
       0,     0,     0,     0,     0,     0,     0,    32,    33,    34,
      35,     0,    36,    37,     4,     0,     0,    41,    42,     0,
       5,     6,    89,    90,     0,     0,    95,     0,     9,     0,
      50,     0,    51,     0,     0,     0,     0,     0,     0,     0,
      53,     0,     0,     0,     0,    54,     0,     0,     0,     0,
       0,     0,     0,    11,    12,    13,    14,    15,    16,    17,
      18,    19,     0,    91,    92,    93,    94,     0,     0,     0,
       0,     0,     0,     0,     0,    32,    33,    34,    35,     0,
      36,    37,     4,     0,     0,    41,    42,     0,     5,     6,
      89,    90,     0,     0,    95,     0,     9,     0,    50,     0,
      51,     0,     0,     0,     0,     0,     0,     0,    53,   198,
       0,     0,     0,    54,     0,     0,     0,     0,     0,     0,
       0,    11,    12,    13,    14,    15,    16,    17,    18,    19,
       0,    91,    92,    93,    94,     0,     0,     0,     0,     0,
       0,     0,     0,    32,    33,    34,    35,     0,    36,    37,
       4,     0,     0,    41,    42,     0,     5,     6,    89,    90,
       0,     0,    95,     0,     9,     0,    50,     0,    51,     0,
       0,     0,     0,     0,     0,     0,    53,   202,     0,     0,
       0,    54,     0,     0,     0,     0,     0,     0,     0,    11,
      12,    13,    14,    15,    16,    17,    18,    19,     0,    91,
      92,    93,    94,     0,     0,     0,     0,     0,     0,     0,
       0,    32,    33,    34,    35,     0,    36,    37,     4,     0,
       0,    41,    42,     0,     5,     6,   210,   211,     0,     0,
      95,     0,     9,     0,    50,     0,    51,     0,     0,     0,
       0,     0,     0,     0,    53,   205,     0,     0,     0,    54,
       0,     0,     0,     0,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,     0,   212,   213,   214,
     215,     0,     0,     0,     0,     0,     0,     0,     0,    32,
      33,    34,    35,     0,    36,    37,     4,     0,     0,    41,
      42,     0,     5,     6,    89,    90,     0,     0,    95,     0,
       9,     0,    50,     0,    51,     0,     0,     0,     0,     0,
       0,     0,    53,   216,     0,     0,     0,    54,     0,     0,
       0,     0,     0,     0,     0,    11,    12,    13,    14,    15,
      16,    17,    18,    19,     0,    91,    92,    93,    94,     0,
       0,     0,     0,     0,     0,     0,     0,    32,    33,    34,
      35,     0,    36,    37,     4,     0,     0,    41,    42,     0,
       5,     6,    89,    90,     0,     0,    95,     0,     9,     0,
      50,     0,    51,     0,     0,     0,     0,     0,     0,     0,
      53,   236,     0,     0,     0,    54,     0,     0,     0,     0,
       0,     0,     0,    11,    12,    13,    14,    15,    16,    17,
      18,    19,     0,    91,    92,    93,    94,     0,     0,     0,
       0,     0,     0,     0,     0,    32,    33,    34,    35,     0,
      36,    37,     4,     0,     0,    41,    42,     0,     5,     6,
      89,    90,     0,     0,    95,     0,     9,     0,    50,     0,
      51,     0,     0,     0,     0,     0,     0,     0,    53,   369,
       0,     0,     0,    54,     0,     0,     0,     0,     0,     0,
       0,    11,    12,    13,    14,    15,    16,    17,    18,    19,
       0,    91,    92,    93,    94,     0,     0,     0,     0,     0,
       0,     0,     0,    32,    33,    34,    35,     0,    36,    37,
       4,     0,     0,    41,    42,     0,     5,     6,    89,    90,
       0,     0,    95,     0,     9,     0,    50,     0,    51,     0,
       0,     0,     0,     0,     0,     0,    53,     0,     0,     0,
       0,    54,     0,     0,     0,     0,     0,     0,     0,    11,
      12,    13,    14,    15,    16,    17,    18,    19,     0,    91,
      92,    93,    94,     0,     0,     0,     0,     0,     0,     0,
       0,    32,    33,    98,    35,     0,    36,    37,     4,     0,
       0,    41,    42,     0,     5,     6,    89,    90,     0,     0,
      95,     0,     9,     0,    50,     0,    51,     0,     0,     0,
       0,     0,     0,     0,    99,     0,     0,     0,     0,    54,
       0,     0,     0,     0,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,     0,    91,    92,    93,
      94,     0,     0,     0,     0,     0,     0,     0,     0,    32,
      33,    34,    35,     0,    36,    37,     4,     0,     0,    41,
      42,     0,     5,     6,    89,    90,     0,     0,    95,     0,
       9,     0,    50,     0,    51,     0,     0,     0,     0,     0,
       0,     0,   113,     0,     0,     0,     0,    54,     0,     0,
       0,     0,     0,     0,     0,    11,    12,    13,    14,    15,
      16,    17,    18,    19,     0,    91,    92,    93,    94,     0,
       0,     0,     0,     0,     0,     0,     0,    32,    33,    34,
      35,     0,    36,    37,     4,     0,     0,    41,    42,     0,
       5,     6,    89,    90,     0,     0,    95,     0,     9,     0,
      50,     0,    51,     0,     0,     0,     0,     0,     0,     0,
     115,     0,     0,     0,     0,    54,     0,     0,     0,     0,
       0,     0,     0,    11,    12,    13,    14,    15,    16,    17,
      18,    19,     0,    91,    92,    93,    94,     0,     0,     0,
       0,     0,     0,     0,     0,    32,    33,    34,    35,     0,
      36,    37,     4,     0,     0,    41,    42,     0,     5,     6,
      89,    90,     0,     0,    95,     0,     9,     0,    50,     0,
      51,     0,     0,     0,     0,     0,     0,     0,   117,     0,
       0,     0,     0,    54,     0,     0,     0,     0,     0,     0,
       0,    11,    12,    13,    14,    15,    16,    17,    18,    19,
       0,    91,    92,    93,    94,     0,     0,     0,     0,     0,
       0,     0,     0,    32,    33,    34,    35,     0,    36,    37,
       4,     0,     0,    41,    42,     0,     5,     6,    89,    90,
       0,     0,    95,     0,     9,     0,    50,     0,    51,     0,
       0,     0,     0,     0,     0,     0,   119,     0,     0,     0,
       0,    54,     0,     0,     0,     0,     0,     0,     0,    11,
      12,    13,    14,    15,    16,    17,    18,    19,     0,    91,
      92,    93,    94,     0,     0,     0,     0,     0,     0,     0,
       0,    32,    33,    34,    35,     0,    36,    37,     4,     0,
       0,    41,    42,     0,     5,     6,    89,    90,     0,     0,
      95,     0,     9,     0,    50,     0,    51,     0,     0,     0,
       0,     0,     0,     0,   173,     0,     0,     0,     0,    54,
       0,     0,     0,     0,     0,     0,     0,    11,    12,    13,
      14,    15,    16,    17,    18,    19,     0,    91,    92,    93,
      94,     0,     0,     0,     0,     0,     0,     0,     0,    32,
      33,    34,    35,     0,    36,    37,     4,     0,     0,    41,
      42,     0,     5,     6,    89,    90,     0,     0,    95,     0,
       9,     0,    50,     0,    51,     0,     0,     0,     0,     0,
       0,     0,   188,     0,     0,     0,     0,    54,     0,     0,
       0,     0,     0,     0,     0,    11,    12,    13,    14,    15,
      16,    17,    18,    19,     0,    91,    92,    93,    94,     0,
       0,     0,     0,     0,     0,     0,     0,    32,    33,    34,
      35,     0,    36,    37,     4,     0,     0,    41,    42,     0,
       5,     6,    89,    90,     0,     0,    95,     0,     9,     0,
      50,     0,    51,     0,     0,     0,     0,     0,     0,     0,
      99,     0,     0,     0,     0,    54,     0,     0,     0,     0,
       0,     0,     0,   362,    12,    13,   363,   364,    16,   365,
     366,    19,     0,    91,    92,    93,    94,     0,     0,     0,
       0,     0,     0,     0,     0,    32,    33,    34,    35,     0,
      36,    37,     0,     0,     0,    41,    42,     0,     0,     0,
       0,     0,     0,     0,    95,     0,     0,     0,    50,     0,
      51,     0,     0,     0,     0,     0,     0,     0,    53,     0,
       0,     0,     0,    54
};

static const yytype_int16 yycheck[] =
{
       1,    26,   260,     1,     1,    71,   131,   134,    71,   425,
      69,     1,    61,    69,   185,    95,    98,    97,     3,     4,
     104,   279,     7,    69,     9,    10,    51,    89,    53,    76,
       7,   102,    97,    10,    89,    97,   102,    11,   103,   455,
      16,    66,    97,   102,   107,   104,    47,    89,   104,    47,
       7,    89,    98,   324,   325,    97,    98,   104,   102,    97,
      98,   186,    97,    20,    21,    22,    23,    24,   103,   102,
      97,    28,     7,    97,    99,    10,   103,     7,    97,   103,
      10,    57,    58,    97,   103,   110,   102,    97,   113,   103,
     115,   102,   117,   103,   119,    71,   267,   268,   269,   270,
      11,    95,    11,    97,    89,    90,    91,    92,    93,    94,
     102,    96,     3,    70,    99,   100,     7,    94,   103,    10,
      77,   106,     4,   148,   382,     7,   127,   176,   102,   106,
     255,   107,   102,   134,   102,   103,   134,   134,    20,    21,
      22,    23,    24,   102,   134,    98,    28,    97,   173,    31,
      97,    11,    69,   103,   102,   180,   103,   182,    93,    94,
      11,    96,   102,   188,    94,    47,    96,    12,    50,   340,
     127,   106,    54,    97,   102,   103,   106,   102,    89,   103,
     137,    63,    64,    94,   102,    94,    97,    98,    70,    98,
     147,   102,   103,   102,   103,    77,   102,   103,    80,    90,
      91,    92,    93,    94,    97,    96,   102,   208,   165,   100,
     103,    48,    49,   170,   339,   106,   102,    99,   175,   220,
     102,   103,   104,   105,   106,   107,   108,   109,   102,    89,
      97,   113,   102,     3,     4,   117,   103,     7,    98,     9,
      10,   102,   102,   103,   102,   127,    97,   129,   373,   374,
      97,   102,   103,   135,   136,   137,   102,   103,   102,   103,
     102,   386,    11,   102,   103,   147,   102,   103,   150,   102,
     152,   153,   102,   155,   275,   157,   158,   159,   160,   161,
     162,   163,   164,   165,   102,   412,   102,   103,   170,   102,
     103,   173,   317,   175,   102,   420,   178,   179,   102,   181,
      69,   183,    98,   260,    97,     3,   188,   102,   103,     7,
     311,    97,    10,   102,   103,   102,   103,    98,   343,   104,
      90,    91,    92,    93,    94,   326,    96,   102,   102,    99,
     100,    97,    97,   458,    98,    69,   106,   107,    98,   221,
       3,     4,   104,    98,     7,   104,     9,    10,    97,    98,
      97,   104,    97,   102,   103,   103,   381,   103,    71,     3,
       4,   103,   103,     7,   103,     9,    10,   103,   103,   251,
     103,    94,   254,   104,   102,    97,   258,   103,   260,   103,
       3,     4,    97,   384,     7,   103,     9,    10,   104,   412,
     267,   455,    -1,    91,    92,    93,    94,   279,    96,   281,
     282,   283,   100,   285,   340,   287,   288,   439,   106,    -1,
      11,   412,   413,   414,   412,   412,    -1,    -1,    -1,   444,
      -1,   422,   412,    -1,    -1,    -1,    -1,    90,    91,    92,
      93,    94,   314,    96,    -1,    -1,   318,   100,    -1,   440,
      -1,   323,    -1,   106,    -1,   327,    90,    91,    92,    93,
      94,    -1,    96,    97,    -1,    99,   100,    -1,    -1,   103,
     461,    -1,   106,    -1,    -1,    -1,    -1,    90,    91,    92,
      93,    94,    -1,    96,    97,    -1,    99,   100,    -1,    -1,
     103,    -1,    -1,   106,    -1,    -1,    -1,    -1,    89,    -1,
       0,     1,    -1,    -1,    -1,    -1,    97,    98,     8,    -1,
     382,   102,   103,    11,    14,    15,    16,    17,   390,    -1,
     392,   393,    22,   395,    -1,    -1,    -1,    -1,    11,    -1,
      -1,    -1,    -1,    33,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,   416,   417,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    -1,    86,    -1,    88,    -1,
      90,    89,    92,    -1,    94,    -1,     1,    -1,    98,    97,
      98,    -1,   102,     8,   102,   103,    89,   107,    -1,    14,
      15,    16,    17,    -1,    97,    98,    -1,    22,    -1,   102,
     103,    -1,    11,    90,    91,    92,    93,    94,    33,    96,
      97,     3,    99,   100,    -1,     7,   103,    -1,    10,   106,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,     1,    -1,    98,    -1,    -1,    -1,   102,     8,    -1,
     105,    -1,   107,    -1,    14,    15,    16,    17,    97,    98,
      -1,    -1,    22,   102,   103,    -1,    -1,    -1,    11,    91,
      92,    93,    94,    33,    96,    -1,     3,     4,   100,    -1,
       7,    -1,     9,    10,   106,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    -1,
      90,    -1,    92,    -1,    94,    -1,     1,    -1,    98,    -1,
      -1,    -1,   102,     8,    -1,   105,    89,   107,    -1,    14,
      15,    16,    17,    -1,    97,    98,    -1,    22,    -1,   102,
     103,    -1,    -1,    90,    91,    92,    93,    94,    33,    96,
      97,    -1,    99,   100,    -1,    -1,   103,    -1,    -1,   106,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,     1,    -1,    98,    -1,    -1,    -1,   102,     8,    -1,
     105,    -1,   107,    -1,    14,    15,    16,    17,    -1,    -1,
      -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,    11,    -1,
      -1,    -1,    -1,    33,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    -1,
      90,    -1,    92,    -1,    94,    -1,     1,    -1,    98,    -1,
      -1,    -1,   102,     8,    -1,   105,    89,   107,    -1,    14,
      15,    16,    17,    -1,    97,    98,    -1,    22,    -1,   102,
     103,    -1,    -1,    90,    91,    92,    93,    94,    33,    96,
      97,    -1,    99,   100,    -1,    -1,   103,    -1,    -1,   106,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,     1,    -1,    98,    -1,    -1,    -1,   102,     8,    -1,
     105,    -1,   107,    -1,    14,    15,    16,    17,    -1,    -1,
      -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,    11,    -1,
      -1,    -1,    -1,    33,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    -1,
      90,    -1,    92,    -1,    94,    -1,     1,    -1,    98,    -1,
      -1,    -1,   102,     8,    -1,   105,    89,   107,    -1,    14,
      15,    16,    17,    -1,    97,    98,    -1,    22,    -1,   102,
     103,    -1,    -1,    90,    91,    92,    93,    94,    33,    96,
      97,    -1,    99,   100,    -1,    -1,   103,    -1,    -1,   106,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,     1,    -1,    98,    -1,    -1,    -1,   102,     8,    -1,
     105,    -1,   107,    -1,    14,    15,    16,    17,    -1,    -1,
      -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,    11,    -1,
      -1,    -1,    -1,    33,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    -1,
      90,    -1,    92,    -1,    94,    -1,     1,    -1,    98,    -1,
      -1,    -1,   102,     8,    -1,   105,    89,   107,    -1,    14,
      15,    16,    17,    -1,    97,    98,    -1,    22,    -1,   102,
     103,    -1,    -1,    90,    91,    92,    93,    94,    33,    96,
      97,    -1,    99,   100,    -1,    -1,    -1,    -1,    -1,   106,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,     1,    -1,    98,    -1,    -1,    -1,   102,     8,    -1,
     105,    -1,   107,    -1,    14,    15,    16,    17,    -1,    -1,
      -1,    -1,    22,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    33,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
      60,    61,    62,    63,    64,    -1,    66,    67,    68,    69,
      70,    71,    72,    -1,    74,    75,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    -1,
      90,    -1,    92,    -1,    94,    -1,     1,    -1,    98,    -1,
      -1,    -1,   102,     8,    -1,   105,    -1,   107,    -1,    14,
      15,    16,    17,    -1,    -1,    -1,    -1,    22,     3,     4,
      -1,    -1,     7,    -1,     9,    10,    -1,    -1,    33,     3,
       4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      -1,    -1,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      -1,    66,    67,    68,    69,    70,    71,    72,    -1,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    -1,    88,    -1,    90,    -1,    92,    -1,    94,
      -1,    -1,     3,     4,    -1,    -1,     7,   102,     9,    10,
      -1,    -1,   107,    -1,    -1,    90,    91,    92,    93,    94,
      95,    96,    97,    -1,    99,   100,    90,    91,    92,    93,
      94,   106,    96,    -1,    -1,    99,   100,     3,     4,   103,
      -1,     7,   106,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,    -1,
       9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    90,
      91,    92,    93,    94,    -1,    96,    -1,    -1,    99,   100,
       3,     4,   103,    -1,     7,   106,     9,    10,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    90,    91,    92,    93,    94,    -1,
      96,    -1,    -1,    99,   100,    -1,    -1,   103,    -1,    -1,
     106,    90,    91,    92,    93,    94,    -1,    96,    97,    -1,
      99,   100,    90,    91,    92,    93,    94,   106,    96,    97,
      -1,    99,   100,    90,    91,    92,    93,    94,   106,    96,
      97,    -1,    99,   100,     3,     4,    -1,    -1,     7,   106,
       9,    10,    -1,    -1,    -1,    -1,    -1,    90,    91,    92,
      93,    94,    -1,    96,    -1,    -1,    99,   100,     3,     4,
     103,    -1,     7,   106,     9,    10,    -1,    -1,    -1,     3,
       4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    -1,    14,    15,
      16,    17,    -1,     3,     4,    -1,    22,     7,    -1,     9,
      10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    90,    91,    92,    93,    94,    16,    96,    -1,    -1,
      99,   100,     3,     4,   103,    -1,     7,   106,     9,    10,
      -1,    57,    58,    59,    60,    90,    91,    92,    93,    94,
      -1,    96,    97,    -1,    99,   100,    90,    91,    92,    93,
      94,   106,    96,    -1,    -1,    99,   100,    57,    58,   103,
      -1,    -1,   106,    90,    91,    92,    93,    94,    -1,    96,
      -1,    71,    99,   100,    -1,    -1,   103,    -1,    -1,   106,
      90,    91,    92,    93,    94,    -1,    96,    97,    -1,    99,
     100,     3,     4,    -1,    -1,     7,   106,     9,    10,    -1,
      -1,    -1,    -1,   103,    -1,    -1,    -1,   107,    -1,    90,
      91,    92,    93,    94,    -1,    96,    -1,    -1,    99,   100,
       3,     4,   103,    -1,     7,   106,     9,    10,    -1,    -1,
      -1,     3,     4,    -1,    -1,     7,    -1,     9,    10,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,     4,
      -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,     3,
       4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    90,    91,
      92,    93,    94,    -1,    96,    -1,    -1,    99,   100,     3,
       4,   103,    -1,     7,   106,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    90,    91,    92,
      93,    94,    95,    96,    -1,    -1,    99,   100,    90,    91,
      92,    93,    94,   106,    96,    -1,    -1,    99,   100,    -1,
      -1,   103,    -1,    -1,   106,    90,    91,    92,    93,    94,
      -1,    96,    97,    -1,    99,   100,    90,    91,    92,    93,
      94,   106,    96,    -1,    -1,    99,   100,     3,     4,   103,
      -1,     7,   106,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    90,    91,    92,    93,
      94,    -1,    96,    97,    -1,    99,   100,     3,     4,    -1,
      -1,     7,   106,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,    -1,
       9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,     7,
      -1,     9,    10,    -1,    -1,    -1,     3,     4,    -1,    -1,
       7,    -1,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    90,    91,    92,    93,    94,    -1,
      96,    -1,    -1,    99,   100,     3,     4,   103,    -1,     7,
     106,     9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    90,    91,    92,    93,    94,    -1,
      96,    -1,    98,    99,   100,    -1,    -1,    -1,    -1,    -1,
     106,    90,    91,    92,    93,    94,    95,    96,    -1,    -1,
      99,   100,    90,    91,    92,    93,    94,   106,    96,    97,
      -1,    99,   100,    90,    91,    92,    93,    94,   106,    96,
      -1,    -1,    99,   100,     3,     4,   103,    -1,     7,   106,
       9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    90,    91,    92,    93,    94,    -1,    96,    -1,
      -1,    99,   100,     3,     4,   103,    -1,     7,   106,     9,
      10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,     4,    -1,    -1,     7,    -1,     9,    10,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,     4,    -1,
      -1,     7,    -1,     9,    10,    -1,    -1,    -1,     3,     4,
      -1,    -1,     7,    -1,     9,    10,    -1,    -1,    -1,    -1,
      -1,    90,    91,    92,    93,    94,    -1,    96,    -1,    -1,
      99,   100,    -1,    -1,   103,    -1,    -1,   106,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      90,    91,    92,    93,    94,    -1,    96,    -1,    -1,    99,
     100,    -1,    -1,   103,    -1,    -1,   106,    90,    91,    92,
      93,    94,    -1,    96,    -1,    -1,    99,   100,    -1,    -1,
     103,    -1,    -1,   106,    90,    91,    92,    93,    94,    95,
      96,    -1,    -1,    99,   100,    90,    91,    92,    93,    94,
     106,    96,    -1,    -1,    99,   100,     8,    -1,    -1,    -1,
      -1,   106,    14,    15,    16,    17,    -1,    -1,    -1,    -1,
      22,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    56,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      72,    -1,    74,    75,     8,    -1,    -1,    79,    80,    -1,
      14,    15,    16,    17,    -1,    -1,    88,    -1,    22,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     102,    -1,    -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    -1,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    72,    -1,
      74,    75,     8,    -1,    -1,    79,    80,    -1,    14,    15,
      16,    17,    -1,    -1,    88,    -1,    22,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   102,   103,
      -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      -1,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    72,    -1,    74,    75,
       8,    -1,    -1,    79,    80,    -1,    14,    15,    16,    17,
      -1,    -1,    88,    -1,    22,    -1,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   102,   103,    -1,    -1,
      -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    -1,    57,
      58,    59,    60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    72,    -1,    74,    75,     8,    -1,
      -1,    79,    80,    -1,    14,    15,    16,    17,    -1,    -1,
      88,    -1,    22,    -1,    92,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   102,   103,    -1,    -1,    -1,   107,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    -1,    57,    58,    59,
      60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    72,    -1,    74,    75,     8,    -1,    -1,    79,
      80,    -1,    14,    15,    16,    17,    -1,    -1,    88,    -1,
      22,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   102,   103,    -1,    -1,    -1,   107,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    -1,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      72,    -1,    74,    75,     8,    -1,    -1,    79,    80,    -1,
      14,    15,    16,    17,    -1,    -1,    88,    -1,    22,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     102,   103,    -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    -1,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    72,    -1,
      74,    75,     8,    -1,    -1,    79,    80,    -1,    14,    15,
      16,    17,    -1,    -1,    88,    -1,    22,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   102,   103,
      -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      -1,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    72,    -1,    74,    75,
       8,    -1,    -1,    79,    80,    -1,    14,    15,    16,    17,
      -1,    -1,    88,    -1,    22,    -1,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   102,    -1,    -1,    -1,
      -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    -1,    57,
      58,    59,    60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    72,    -1,    74,    75,     8,    -1,
      -1,    79,    80,    -1,    14,    15,    16,    17,    -1,    -1,
      88,    -1,    22,    -1,    92,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   102,    -1,    -1,    -1,    -1,   107,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    -1,    57,    58,    59,
      60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    72,    -1,    74,    75,     8,    -1,    -1,    79,
      80,    -1,    14,    15,    16,    17,    -1,    -1,    88,    -1,
      22,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   102,    -1,    -1,    -1,    -1,   107,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    -1,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      72,    -1,    74,    75,     8,    -1,    -1,    79,    80,    -1,
      14,    15,    16,    17,    -1,    -1,    88,    -1,    22,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     102,    -1,    -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    -1,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    72,    -1,
      74,    75,     8,    -1,    -1,    79,    80,    -1,    14,    15,
      16,    17,    -1,    -1,    88,    -1,    22,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   102,    -1,
      -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      -1,    57,    58,    59,    60,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    72,    -1,    74,    75,
       8,    -1,    -1,    79,    80,    -1,    14,    15,    16,    17,
      -1,    -1,    88,    -1,    22,    -1,    92,    -1,    94,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   102,    -1,    -1,    -1,
      -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,
      48,    49,    50,    51,    52,    53,    54,    55,    -1,    57,
      58,    59,    60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    72,    -1,    74,    75,     8,    -1,
      -1,    79,    80,    -1,    14,    15,    16,    17,    -1,    -1,
      88,    -1,    22,    -1,    92,    -1,    94,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   102,    -1,    -1,    -1,    -1,   107,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,
      50,    51,    52,    53,    54,    55,    -1,    57,    58,    59,
      60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    72,    -1,    74,    75,     8,    -1,    -1,    79,
      80,    -1,    14,    15,    16,    17,    -1,    -1,    88,    -1,
      22,    -1,    92,    -1,    94,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   102,    -1,    -1,    -1,    -1,   107,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      52,    53,    54,    55,    -1,    57,    58,    59,    60,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      72,    -1,    74,    75,     8,    -1,    -1,    79,    80,    -1,
      14,    15,    16,    17,    -1,    -1,    88,    -1,    22,    -1,
      92,    -1,    94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     102,    -1,    -1,    -1,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    47,    48,    49,    50,    51,    52,    53,
      54,    55,    -1,    57,    58,    59,    60,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    72,    -1,
      74,    75,    -1,    -1,    -1,    79,    80,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    88,    -1,    -1,    -1,    92,    -1,
      94,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   102,    -1,
      -1,    -1,    -1,   107
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,   109,     0,     1,     8,    14,    15,    16,    17,    22,
      33,    47,    48,    49,    50,    51,    52,    53,    54,    55,
      56,    57,    58,    59,    60,    61,    62,    63,    64,    66,
      67,    68,    69,    70,    71,    72,    74,    75,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    86,    88,    90,
      92,    94,    98,   102,   107,   110,   114,   115,   116,   117,
     118,   119,   120,   122,   123,   125,   126,   127,   128,   129,
     136,   137,   138,   139,   140,   141,   142,   143,   144,   145,
     146,   147,   148,   149,   150,   151,   152,   153,    98,    16,
      17,    57,    58,    59,    60,    88,   120,   136,    71,   102,
     118,   120,   102,   102,   102,   102,   102,   102,   102,   102,
     102,   102,   118,   102,   118,   102,   118,   102,   118,   102,
     118,    69,   104,   119,    69,    98,   118,   102,   120,   102,
     102,   104,   102,   102,   102,   102,   102,    16,   120,   128,
     129,   129,   120,   119,   119,   120,    98,    11,   102,    89,
      97,   135,     3,     4,     7,     9,    10,    90,    91,    92,
      93,    94,    96,    99,   100,   106,   120,   120,   119,    12,
      97,    98,   135,   102,   118,    97,   118,   120,   102,   102,
     102,   102,   102,   102,    69,   102,   104,   120,   102,   120,
     130,   120,   120,   120,   120,   120,   120,   120,   103,   119,
      69,   120,   103,   119,   120,   103,   119,    98,   111,    98,
      16,    17,    57,    58,    59,    60,   103,   118,   136,   120,
     111,   121,     1,    83,    85,   113,   114,   116,   128,   154,
     120,   120,    95,   103,   107,   118,   103,   119,   120,   120,
     120,   120,   120,   120,   120,   120,   120,   120,   120,   120,
     118,    89,   103,   124,    97,   104,   118,   120,    94,   118,
     135,   120,   120,   119,   120,   119,   120,   102,    16,    57,
      58,   103,   127,   155,   156,   111,   103,   120,   103,    97,
     103,    97,    97,    97,   103,    97,   103,    97,    97,   103,
     103,    97,   103,   103,   103,   103,     1,    83,    98,   105,
     112,   114,   116,   128,   154,   103,   103,   103,   103,   103,
     103,    97,   103,   103,    97,   105,   120,   102,    98,   103,
     103,   103,    95,    97,   120,   120,   111,    97,   103,   120,
     118,   120,   130,   103,   103,   155,   127,   127,   127,   104,
      97,   103,   105,    97,   130,   120,   120,   120,   120,   120,
     120,    69,    98,    98,    98,    16,    17,    57,    58,    59,
      60,   136,    47,    50,    51,    53,    54,   120,   103,   103,
     119,   120,    76,   104,   104,   120,   124,   124,   105,   120,
      95,    94,    97,   103,   111,   156,   104,   119,    97,   103,
      97,   103,    97,    97,   103,    97,   103,   103,   103,   103,
     103,   103,   103,   103,   103,   103,   103,   103,   103,   103,
     103,   103,    98,   111,   111,    95,    97,    94,   119,   130,
     104,   105,   111,   103,    71,   102,   131,   132,   134,   120,
     120,   120,   120,   113,   105,   105,   120,   120,    95,    97,
     111,   105,   132,   133,   102,   103,   103,   103,   103,   103,
     103,   103,    95,   134,   105,    97,   103,   119,   104,   133,
     103,   111,   105
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   108,   109,   109,   110,   110,   110,   110,   110,   110,
     111,   111,   112,   112,   112,   112,   112,   112,   112,   113,
     113,   113,   113,   113,   113,   114,   114,   114,   114,   114,
     114,   114,   114,   115,   116,   116,   116,   116,   116,   116,
     116,   116,   116,   117,   118,   118,   118,   118,   118,   118,
     118,   118,   118,   118,   118,   118,   118,   118,   118,   118,
     118,   118,   118,   118,   118,   118,   118,   118,   118,   118,
     118,   118,   118,   118,   118,   118,   118,   118,   118,   118,
     118,   118,   119,   119,   120,   120,   120,   120,   120,   120,
     120,   120,   120,   120,   120,   120,   120,   121,   120,   122,
     123,   124,   125,   125,   125,   125,   125,   125,   125,   125,
     125,   125,   125,   125,   125,   125,   126,   126,   127,   127,
     128,   128,   128,   128,   128,   128,   128,   128,   128,   129,
     130,   130,   131,   132,   132,   133,   133,   134,   134,   135,
     136,   136,   136,   137,   138,   138,   139,   140,   141,   141,
     142,   142,   142,   142,   142,   142,   142,   142,   142,   142,
     142,   142,   142,   142,   142,   142,   143,   144,   144,   144,
     144,   145,   146,   146,   147,   148,   148,   149,   149,   149,
     149,   149,   150,   151,   152,   152,   152,   152,   153,   153,
     154,   154,   155,   155,   156,   156,   156,   156
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
       3,     4,     4,     4,     4,     6,     6,     6,     6,     6,
       8,     8,     8,     8,     3,     4,     8,     4,     8,     4,
       5,     3,     3,     1,     1,     1,     6,     4,     6,     6,
       6,     6,     6,     6,     3,     5,     5,     0,     5,     2,
       2,     1,     2,     2,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     2,     2,     2,     2,     1,     3,
       2,     2,     2,     2,     2,     8,     2,     3,     2,     1,
       1,     5,     1,     1,     4,     1,     3,     1,     3,     1,
       1,     1,     1,     2,     3,     2,     3,     2,     2,     3,
       4,     4,     4,     4,     4,     4,     4,     4,     6,     6,
       6,     6,     6,     6,     6,     3,     1,     8,     2,     4,
       7,     2,     1,     1,     2,     2,     1,     7,     4,     5,
       1,     1,     7,    11,     5,     7,     8,     9,     2,     2,
       4,     3,     3,     1,     2,     2,     2,     1
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
#line 203 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_lines -> ");
                (yyval.tree) = astnode_make0(RULE_top_lines(1));
                *retv = (yyval.tree);
                exitrule("top_lines -> ");
            }
#line 2286 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 3:
#line 211 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_lines -> top_lines top_pprompt");
                (yyval.tree) = astnode_append((yyvsp[-1].tree), (yyvsp[0].tree));
                *retv = (yyval.tree);
                exitrule_ex("top_lines -> top_lines top_pprompt",(yyval.tree));
            }
#line 2297 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 4:
#line 221 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(1), (yyvsp[0].tree));
                exitrule("top_pprompt -> flowctrl");
            }
#line 2307 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 5:
#line 228 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> command ';'");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(2), (yyvsp[-1].tree));
                exitrule_ex("top_pprompt -> command ';'",(yyval.tree));
            }
#line 2317 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 6:
#line 235 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> declare_ip_variable ';'");
                (yyval.tree) = astnode_make1(RULE_top_pprompt(3), (yyvsp[-1].tree));
                exitrule("top_pprompt -> declare_ip_variable ';'");
            }
#line 2327 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 242 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_top_pprompt(4));
                exitrule("top_pprompt -> SYS_BREAK");
            }
#line 2337 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 249 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> ';'");
                (yyval.tree) = astnode_make0(RULE_top_pprompt(5));
                exitrule_ex("top_pprompt -> ';'", (yyval.tree));
            }
#line 2347 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 9:
#line 256 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("top_pprompt -> error ';'");
                YYABORT;
                exitrule("top_pprompt -> error ';'");
            }
#line 2357 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 264 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("lines -> ");
                (yyval.tree) = astnode_make0(RULE_lines(1));
                exitrule("lines -> ");
            }
#line 2367 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 11:
#line 271 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("lines -> lines pprompt");
                (yyval.tree) = astnode_append((yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule_ex("lines -> lines pprompt",(yyval.tree));
            }
#line 2377 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 12:
#line 280 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_pprompt(1), (yyvsp[0].tree));
                exitrule("pprompt -> flowctrl");
            }
#line 2387 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 13:
#line 287 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> command ';'");
                (yyval.tree) = astnode_make1(RULE_pprompt(2), (yyvsp[-1].tree));
                exitrule_ex("pprompt -> command ';'",(yyval.tree));
            }
#line 2397 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 294 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> declare_ip_variable ';'");
                (yyval.tree) = astnode_make1(RULE_pprompt(3), (yyvsp[-1].tree));
                exitrule("pprompt -> declare_ip_variable ';'");
            }
#line 2407 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 301 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> returncmd");
                (yyval.tree) = astnode_make1(RULE_pprompt(4), (yyvsp[0].tree));
                exitrule("pprompt -> returncmd");
            }
#line 2417 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 308 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_pprompt(5));
                exitrule("pprompt -> SYS_BREAK");
            }
#line 2427 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 17:
#line 315 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> ';'");
                (yyval.tree) = astnode_make0(RULE_pprompt(6));
                exitrule_ex("pprompt -> ';'", (yyval.tree));
            }
#line 2437 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 18:
#line 322 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("pprompt -> error ';'");
                YYABORT;
                exitrule("pprompt -> error ';'");
            }
#line 2447 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 19:
#line 332 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> flowctrl");
                (yyval.tree) = astnode_make1(RULE_npprompt(1), (yyvsp[0].tree));
                exitrule("npprompt -> flowctrl");
            }
#line 2457 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 20:
#line 339 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> command");
                (yyval.tree) = astnode_make1(RULE_npprompt(2), (yyvsp[0].tree));
                exitrule_ex("npprompt -> command ';'",(yyval.tree));
            }
#line 2467 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 346 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> declare_ip_variable");
                (yyval.tree) = astnode_make1(RULE_npprompt(3), (yyvsp[0].tree));
                exitrule("npprompt -> declare_ip_variable ';'");
            }
#line 2477 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 353 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> returncmd");
                (yyval.tree) = astnode_make1(RULE_npprompt(4), (yyvsp[0].tree));
                exitrule("npprompt -> returncmd");
            }
#line 2487 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 360 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> SYS_BREAK");
                (yyval.tree) = astnode_make0(RULE_npprompt(5));
                exitrule("npprompt -> SYS_BREAK");
            }
#line 2497 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 24:
#line 367 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("npprompt -> error ';'");
                YYABORT;
                exitrule("npprompt -> error ';'");
            }
#line 2507 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 25:
#line 376 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> ifcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(1), (yyvsp[0].tree));
                exitrule("flowctrl -> ifcmd");
            }
#line 2517 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 383 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> whilecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(2), (yyvsp[0].tree));
                exitrule("flowctrl -> whilecmd");
            }
#line 2527 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 390 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> example_dummy");
                (yyval.tree) = astnode_make1(RULE_flowctrl(3), (yyvsp[0].tree));
                exitrule("flowctrl -> example_dummy");
            }
#line 2537 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 397 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> forcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(4), (yyvsp[0].tree));
                exitrule("flowctrl -> forcmd");
            }
#line 2547 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 404 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> proccmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(5), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> proccmd",(yyval.tree));
            }
#line 2557 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 411 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> filecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(6), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> filecmd",(yyval.tree));
            }
#line 2567 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 418 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> helpcmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(7), (yyvsp[0].tree));
                exitrule_ex("flowctrl -> helpcmd",(yyval.tree));
            }
#line 2577 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 425 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("flowctrl -> examplecmd");
                (yyval.tree) = astnode_make1(RULE_flowctrl(8), (yyvsp[0].tree));
                exitrule("flowctrl -> examplecmd");
            }
#line 2587 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 433 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
                (yyval.tree) = astnode_make1(RULE_example_dummy(1), (yyvsp[-1].tree));
                exitrule("example_dummy -> EXAMPLE_CMD '{' lines '}'");
            }
#line 2597 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 441 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> assign");
                (yyval.tree) = astnode_make1(RULE_command(1), (yyvsp[0].tree));
                exitrule_ex("command -> assign",(yyval.tree));
            }
#line 2607 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 35:
#line 448 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> exportcmd");
                (yyval.tree) = astnode_make1(RULE_command(2), (yyvsp[0].tree));
                exitrule_ex("command -> exportcmd",(yyval.tree));
            }
#line 2617 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 36:
#line 455 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> killcmd");
                (yyval.tree) = astnode_make1(RULE_command(3), (yyvsp[0].tree));
                exitrule_ex("command -> killcmd",(yyval.tree));
            }
#line 2627 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 462 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> listcmd");
                (yyval.tree) = astnode_make1(RULE_command(4), (yyvsp[0].tree));
                exitrule_ex("command -> listcmd",(yyval.tree));
            }
#line 2637 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 469 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> parametercmd");
                (yyval.tree) = astnode_make1(RULE_command(5), (yyvsp[0].tree));
                exitrule_ex("command -> parametercmd",(yyval.tree));
            }
#line 2647 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 476 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> ringcmd");
                (yyval.tree) = astnode_make1(RULE_command(6), (yyvsp[0].tree));
                exitrule_ex("command -> ringcmd",(yyval.tree));
            }
#line 2657 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 483 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> scriptcmd");
                (yyval.tree) = astnode_make1(RULE_command(7), (yyvsp[0].tree));
                exitrule_ex("command -> scriptcmd",(yyval.tree));
            }
#line 2667 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 41:
#line 490 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> setringcmd");
                (yyval.tree) = astnode_make1(RULE_command(8), (yyvsp[0].tree));
                exitrule_ex("command -> setringcmd",(yyval.tree));
            }
#line 2677 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 497 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("command -> typecmd");
                (yyval.tree) = astnode_make1(RULE_command(9), (yyvsp[0].tree));
                exitrule_ex("command -> typecmd",(yyval.tree));
            }
#line 2687 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 505 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("assign -> left_value exprlist");
                (yyval.tree) = astnode_make2(RULE_assign(1), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule_ex("assign -> left_value exprlist",(yyval.tree));
            }
#line 2697 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 44:
#line 514 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RINGVAR");
                (yyval.tree) = astnode_make1(RULE_elemexpr(1), aststring_make((yyvsp[0].name)));
                exitrule("elemexpr -> RINGVAR");
            }
#line 2707 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 45:
#line 521 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> extendedid");
                (yyval.tree) = astnode_make1(RULE_elemexpr(2), (yyvsp[0].tree));
                exitrule_ex("elemexpr -> extendedid",(yyval.tree));
            }
#line 2717 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 528 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr COLONCOLON elemexpr");
                (yyval.tree) = astnode_make2(RULE_elemexpr(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("elemexpr -> elemexpr COLONCOLON elemexpr");
            }
#line 2727 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 535 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> expr '.' elemexpr");
                (yyval.tree) = astnode_make2(RULE_elemexpr(4), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("elemexpr -> expr '.' elemexpr");
            }
#line 2737 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 48:
#line 542 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr '('  ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(5), (yyvsp[-2].tree));
                exitrule("elemexpr -> elemexpr '('  ')'");
            }
#line 2747 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 49:
#line 549 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> elemexpr '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(6), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule_ex("elemexpr -> elemexpr '(' exprlist ')'", (yyval.tree));
            }
#line 2757 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 50:
#line 556 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> '[' exprlist ']'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(7), (yyvsp[-1].tree));
                exitrule("elemexpr -> '[' exprlist ']'");
            }
#line 2767 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 51:
#line 563 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> INT_CONST");
                (yyval.tree) = astnode_make1(RULE_elemexpr(8), aststring_make((yyvsp[0].name)));
                exitrule_ex("elemexpr -> INT_CONST", (yyval.tree));
            }
#line 2777 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 52:
#line 570 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> SYSVAR");
                (yyval.tree) = astnode_make1(RULE_elemexpr(9), astint_make((yyvsp[0].i)));
                exitrule("elemexpr -> SYSVAR");
            }
#line 2787 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 53:
#line 577 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> stringexpr");
                (yyval.tree) = astnode_make1(RULE_elemexpr(10), (yyvsp[0].tree));
                exitrule("elemexpr -> stringexpr");
            }
#line 2797 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 54:
#line 584 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> PROC_CMD '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(11), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> PROC_CMD '(' expr ')'");
            }
#line 2807 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 55:
#line 591 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(12), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> ROOT_DECL '(' expr ')'");
            }
#line 2817 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 56:
#line 598 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(13), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> ROOT_DECL_LIST '(' exprlist ')'");
            }
#line 2827 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 57:
#line 605 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(14), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> ROOT_DECL_LIST '(' ')'");
            }
#line 2837 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 58:
#line 612 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(15), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_DECL '(' expr ')'");
            }
#line 2847 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 59:
#line 619 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(16), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_DECL_LIST '(' exprlist ')'");
            }
#line 2857 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 60:
#line 626 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_DECL_LIST '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(17), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> RING_DECL_LIST '(' ')'");
            }
#line 2867 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 61:
#line 633 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_1 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(18), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_1 '(' expr ')'");
            }
#line 2877 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 62:
#line 640 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_12 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(19), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_12 '(' expr ')'");
            }
#line 2887 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 63:
#line 647 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_13 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(20), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_13 '(' expr ')'");
            }
#line 2897 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 64:
#line 654 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(21), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ')'");
            }
#line 2907 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 65:
#line 661 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(22), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_2 '(' expr ',' expr ')'");
            }
#line 2917 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 66:
#line 668 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(23), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_12 '(' expr ',' expr ')'");
            }
#line 2927 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 67:
#line 675 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> NEWSTRUCT_CMD '(' STRINGTOK ',' STRINGTOK ')'");
                if (!stringlist_has(&prev_newstruct_names, (yyvsp[-3].name)))
                    stringlist_insert(&new_newstruct_names, (yyvsp[-3].name));
                (yyval.tree) = astnode_make2(RULE_elemexpr(99), aststring_make((yyvsp[-3].name)), aststring_make((yyvsp[-1].name)));
                exitrule("elemexpr -> NEWSTRUCT_CMD '(' STRINGTOK ',' STRINGTOK ')'");
            }
#line 2939 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 68:
#line 684 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(24), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ')'");
            }
#line 2949 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 69:
#line 691 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
                (yyval.tree) = astnode_make3(RULE_elemexpr(25), astint_make((yyvsp[-5].i)), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ')'");
            }
#line 2959 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 70:
#line 698 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(26), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_3 '(' expr ',' expr ',' expr ')'");
            }
#line 2969 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 71:
#line 705 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(27), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_13 '(' expr ',' expr ',' expr ')'");
            }
#line 2979 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 72:
#line 712 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(28), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_23 '(' expr ',' expr ',' expr ')'");
            }
#line 2989 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 73:
#line 719 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(29), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_123 '(' expr ',' expr ',' expr ')'");
            }
#line 2999 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 74:
#line 726 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_M '(' ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(30), astint_make((yyvsp[-2].i)));
                exitrule("elemexpr -> CMD_M '(' ')'");
            }
#line 3009 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 75:
#line 733 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> CMD_M '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(31), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> CMD_M '(' exprlist ')'");
            }
#line 3019 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 76:
#line 740 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(32), (yyvsp[-7].tree), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> mat_cmd '(' expr ',' expr ',' expr ')'");
            }
#line 3029 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 77:
#line 747 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> mat_cmd '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(33), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> mat_cmd '(' expr ')'");
            }
#line 3039 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 78:
#line 754 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
                (yyval.tree) = astnode_make4(RULE_elemexpr(34), astint_make((yyvsp[-7].i)), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_CMD '(' rlist ',' rlist ',' ordering ')'");
            }
#line 3049 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 79:
#line 761 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> RING_CMD '(' expr ')'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(35), astint_make((yyvsp[-3].i)), (yyvsp[-1].tree));
                exitrule("elemexpr -> RING_CMD '(' expr ')'");
            }
#line 3059 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 80:
#line 768 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> extendedid  ARROW '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_elemexpr(36), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule("elemexpr -> extendedid  ARROW '{' lines '}'");
            }
#line 3069 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 81:
#line 775 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("elemexpr -> '(' exprlist ')'");
                (yyval.tree) = astnode_make1(RULE_elemexpr(37), (yyvsp[-1].tree));
                exitrule_ex("elemexpr -> '(' exprlist ')'",(yyval.tree));
            }
#line 3079 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 82:
#line 784 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exprlist -> exprlist ',' expr");
                (yyval.tree) = astnode_append((yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("exprlist -> exprlist ',' expr",(yyval.tree));
            }
#line 3089 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 83:
#line 791 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exprlist -> expr");
                (yyval.tree) = astnode_make1(RULE_exprlist(1), (yyvsp[0].tree));
                exitrule_ex("exprlist -> expr",(yyval.tree));
            }
#line 3099 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 84:
#line 799 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr_arithmetic");
                (yyval.tree) = astnode_make1(RULE_expr(1), (yyvsp[0].tree));
                exitrule_ex("expr -> expr_arithmetic",(yyval.tree));
            }
#line 3109 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 85:
#line 806 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> elemexpr");
                (yyval.tree) = astnode_make1(RULE_expr(2), (yyvsp[0].tree));
                exitrule_ex("expr -> elemexpr",(yyval.tree));
            }
#line 3119 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 86:
#line 813 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr '[' expr ',' expr ']'");
                (yyval.tree) = astnode_make3(RULE_expr(3), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> expr '[' expr ',' expr ']'");
            }
#line 3129 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 87:
#line 820 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> expr '[' expr ']'");
                (yyval.tree) = astnode_make2(RULE_expr(4), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> expr '[' expr ']'");
            }
#line 3139 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 88:
#line 827 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(5), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_1 ')'");
            }
#line 3149 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 89:
#line 834 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(6), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_12 ')'");
            }
#line 3159 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 90:
#line 841 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(7), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_13 ')'");
            }
#line 3169 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 91:
#line 848 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
                (yyval.tree) = astnode_make2(RULE_expr(8), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_123 ')'");
            }
#line 3179 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 92:
#line 855 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' CMD_M ')'");
                (yyval.tree) = astnode_make2(RULE_expr(9), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("expr -> APPLY '('  expr ',' CMD_M ')'");
            }
#line 3189 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 93:
#line 862 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> APPLY '('  expr ',' expr ')'");
                (yyval.tree) = astnode_make2(RULE_expr(10), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> APPLY '('  expr ',' expr ')'");
            }
#line 3199 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 94:
#line 869 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> quote_start expr quote_end");
                (yyval.tree) = astnode_make1(RULE_expr(11), (yyvsp[-1].tree));
                exitrule("expr -> quote_start expr quote_end");
            }
#line 3209 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 95:
#line 876 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> quote_start expr '=' expr quote_end");
                (yyval.tree) = astnode_make2(RULE_expr(12), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> quote_start expr '=' expr quote_end");
            }
#line 3219 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 96:
#line 883 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> assume_start expr ',' expr quote_end");
                (yyval.tree) = astnode_make2(RULE_expr(13), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("expr -> assume_start expr ',' expr quote_end");
            }
#line 3229 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 97:
#line 890 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> EVAL  '('");
                exitrule("expr -> EVAL  '('");
            }
#line 3238 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 98:
#line 896 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr -> EVAL  '(' expr ')'");
                (yyval.tree) = astnode_make1(RULE_expr(14), (yyvsp[-1].tree));
                exitrule("expr -> EVAL  '(' expr ')'");
            }
#line 3248 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 99:
#line 904 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("quote_start -> QUOTE  '('");
                (yyval.tree) = astnode_make0(RULE_quote_start(1));
                exitrule("quote_start -> QUOTE  '('");
            }
#line 3258 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 100:
#line 912 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("assume_start -> ASSUME_CMD '('");
                (yyval.tree) = astnode_make0(RULE_assume_start(2));
                exitrule("assume_start ASSUME_CMD '('");
            }
#line 3268 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 101:
#line 920 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("quote_end -> ')'");
                (yyval.tree) = astnode_make0(RULE_quote_end(1));
                exitrule("quote_end -> ')'");
            }
#line 3278 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 102:
#line 929 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr PLUSPLUS");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(1), (yyvsp[-1].tree));
                exitrule_ex("expr_arithmetic -> expr PLUSPLUS",(yyval.tree));
            }
#line 3288 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 103:
#line 936 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr MINUSMINUS");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(2), (yyvsp[-1].tree));
                exitrule_ex("expr_arithmetic -> expr MINUSMINUS",(yyval.tree));
            }
#line 3298 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 104:
#line 943 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '+' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '+' expr",(yyval.tree));
            }
#line 3308 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 105:
#line 950 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '-' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(4), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '-' expr",(yyval.tree));
            }
#line 3318 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 106:
#line 957 "grammar.y" /* yacc.c:1646  */
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
#line 3343 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 107:
#line 979 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr '^' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(8), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("expr_arithmetic -> expr '^' expr",(yyval.tree));
            }
#line 3353 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 108:
#line 986 "grammar.y" /* yacc.c:1646  */
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
#line 3378 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 109:
#line 1008 "grammar.y" /* yacc.c:1646  */
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
#line 3395 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 110:
#line 1022 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr NOTEQUAL expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(15), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr NOTEQUAL expr");
            }
#line 3405 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 111:
#line 1029 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(16), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr EQUAL_EQUAL expr");
            }
#line 3415 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 112:
#line 1036 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr DOTDOT expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(17), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr DOTDOT expr");
            }
#line 3425 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 113:
#line 1043 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> expr ':' expr");
                (yyval.tree) = astnode_make2(RULE_expr_arithmetic(18), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> expr ':' expr");
            }
#line 3435 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 114:
#line 1050 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> NOT expr");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(19), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> NOT expr");
            }
#line 3445 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 115:
#line 1057 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("expr_arithmetic -> '-' expr");
                (yyval.tree) = astnode_make1(RULE_expr_arithmetic(20), (yyvsp[0].tree));
                exitrule("expr_arithmetic -> '-' expr");
            }
#line 3455 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 116:
#line 1066 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("left_value -> declare_ip_variable cmdeq");
                (yyval.tree) = astnode_make1(RULE_left_value(1), (yyvsp[-1].tree));
                exitrule_ex("left_value -> declare_ip_variable cmdeq",(yyval.tree));
            }
#line 3465 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 117:
#line 1073 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("left_value -> exprlist cmdeq");
                (yyval.tree) = astnode_make1(RULE_left_value(2), (yyvsp[-1].tree));
                exitrule("left_value -> exprlist cmdeq");
            }
#line 3475 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 118:
#line 1083 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("extendedid -> UNKNOWN_IDENT");
                (yyval.tree) = astnode_make1(RULE_extendedid(1), aststring_make((yyvsp[0].name)));
                exitrule_ex("extendedid -> UNKNOWN_IDENT",(yyval.tree));
            }
#line 3485 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 119:
#line 1090 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("extendedid -> '`' expr '`'");
                (yyval.tree) = astnode_make1(RULE_extendedid(2), (yyvsp[-1].tree));
                exitrule_ex("extendedid -> '`' expr '`'",(yyval.tree));
            }
#line 3495 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 120:
#line 1100 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> ROOT_DECL elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(1), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("declare_ip_variable -> ROOT_DECL elemexpr",(yyval.tree));
            }
#line 3505 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 121:
#line 1107 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> ROOT_DECL elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(99), aststring_make((yyvsp[-1].name)), (yyvsp[0].tree));
                exitrule_ex("declare_ip_variable -> ROOT_DECL elemexpr",(yyval.tree));
            }
#line 3515 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 122:
#line 1114 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(2), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> ROOT_DECL_LIST elemexpr");
            }
#line 3525 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 123:
#line 1121 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> RING_DECL elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(3), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> RING_DECL elemexpr");
            }
#line 3535 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 124:
#line 1128 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(4), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> RING_DECL_LIST elemexpr");
            }
#line 3545 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 125:
#line 1135 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
                (yyval.tree) = astnode_make4(RULE_declare_ip_variable(5), (yyvsp[-7].tree), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule("declare_ip_variable -> mat_cmd elemexpr '[' expr ']' '[' expr ']'");
            }
#line 3555 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 126:
#line 1142 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> mat_cmd elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(6), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> mat_cmd elemexpr");
            }
#line 3565 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 127:
#line 1149 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
                (yyval.tree) = astnode_make2(RULE_declare_ip_variable(7), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> declare_ip_variable ',' elemexpr");
            }
#line 3575 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 128:
#line 1156 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("declare_ip_variable -> PROC_CMD elemexpr");
                (yyval.tree) = astnode_make1(RULE_declare_ip_variable(8), (yyvsp[0].tree));
                exitrule("declare_ip_variable -> PROC_CMD elemexpr");
            }
#line 3585 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 129:
#line 1165 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("stringexpr -> STRINGTOK");
                (yyval.tree) = astnode_make1(RULE_stringexpr(1), aststring_make((yyvsp[0].name)));
                exitrule("stringexpr -> STRINGTOK");
            }
#line 3595 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 130:
#line 1174 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("rlist -> expr");
                (yyval.tree) = astnode_make1(RULE_rlist(1), (yyvsp[0].tree));
                exitrule("rlist -> expr");
            }
#line 3605 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 131:
#line 1181 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("rlist -> '(' expr ',' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_rlist(2), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("rlist -> '(' expr ',' exprlist ')'");
            }
#line 3615 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 132:
#line 1190 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordername -> UNKNOWN_IDENT");
                (yyval.tree) = astnode_make1(RULE_ordername(1), aststring_make((yyvsp[0].name)));
                exitrule("ordername -> UNKNOWN_IDENT");
            }
#line 3625 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 133:
#line 1199 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("orderelem -> ordername");
                (yyval.tree) = astnode_make1(RULE_orderelem(1), (yyvsp[0].tree));
                exitrule("orderelem -> ordername");
            }
#line 3635 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 134:
#line 1205 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("orderelem -> ordername '(' exprlist ')'");
                (yyval.tree) = astnode_make2(RULE_orderelem(2), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("orderelem -> ordername '(' exprlist ')'");
            }
#line 3645 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 135:
#line 1214 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("OrderingList -> orderelem");
                (yyval.tree) = astnode_make1(RULE_OrderingList(1), (yyvsp[0].tree));
                exitrule("OrderingList -> orderelem");
            }
#line 3655 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 136:
#line 1221 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("OrderingList -> orderelem ',' OrderingList");
                (yyval.tree) = astnode_make2(RULE_OrderingList(2), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("OrderingList -> orderelem ',' OrderingList");
            }
#line 3665 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 137:
#line 1230 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordering -> orderelem");
                (yyval.tree) = astnode_make1(RULE_ordering(1), (yyvsp[0].tree));
                exitrule("ordering -> orderelem");
            }
#line 3675 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 138:
#line 1237 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ordering -> '(' OrderingList ')'");
                (yyval.tree) = astnode_make1(RULE_ordering(2), (yyvsp[-1].tree));
                exitrule("ordering -> '(' OrderingList ')'");
            }
#line 3685 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 139:
#line 1245 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("cmdeq -> '='");
                (yyval.i) = (yyvsp[0].i);
                exitrule("cmdeq -> '='");
            }
#line 3695 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 140:
#line 1254 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> MATRIX_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(1), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> MATRIX_CMD");
            }
#line 3705 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 141:
#line 1261 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> INTMAT_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(2), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> INTMAT_CMD");
            }
#line 3715 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 142:
#line 1268 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("mat_cmd -> BIGINTMAT_CMD");
                (yyval.tree) = astnode_make1(RULE_mat_cmd(3), astint_make((yyvsp[0].i)));
                exitrule("mat_cmd -> BIGINTMAT_CMD");
            }
#line 3725 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 143:
#line 1281 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("filecmd -> '<' stringexpr");
                (yyval.tree) = astnode_make1(RULE_filecmd(1), (yyvsp[0].tree));
                exitrule("filecmd -> '<' stringexpr");
            }
#line 3735 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 144:
#line 1290 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("helpcmd -> HELP_CMD STRINGTOK ';'");
                (yyval.tree) = astnode_make1(RULE_helpcmd(1), aststring_make((yyvsp[-1].name)));
                exitrule("helpcmd -> HELP_CMD STRINGTOK ';'");
            }
#line 3745 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 145:
#line 1297 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("helpcmd -> HELP_CMD ';'");
                (yyval.tree) = astnode_make0(RULE_helpcmd(2));
                exitrule("helpcmd -> HELP_CMD ';'");
            }
#line 3755 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 146:
#line 1306 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
                (yyval.tree) = astnode_make1(RULE_examplecmd(1), aststring_make((yyvsp[-1].name)));
                exitrule("examplecmd -> EXAMPLE_CMD STRINGTOK ';'");
            }
#line 3765 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 147:
#line 1315 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("exportcmd -> EXPORT_CMD exprlist");
                (yyval.tree) = astnode_make1(RULE_exportcmd(1), (yyvsp[0].tree));
                exitrule("exportcmd -> EXPORT_CMD exprlist");
            }
#line 3775 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 148:
#line 1324 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("killcmd -> KILL_CMD elemexpr");
                (yyval.tree) = astnode_make1(RULE_killcmd(1), (yyvsp[0].tree));
                exitrule("killcmd -> KILL_CMD elemexpr");
            }
#line 3785 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 149:
#line 1331 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("killcmd -> killcmd ',' elemexpr");
                (yyval.tree) = astnode_make2(RULE_killcmd(2), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("killcmd -> killcmd ',' elemexpr");
            }
#line 3795 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 150:
#line 1340 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(1), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }
#line 3805 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 151:
#line 1347 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(2), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL_LIST ')'");
            }
#line 3815 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 152:
#line 1354 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(3), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' ROOT_DECL ')'");
            }
#line 3825 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 153:
#line 1361 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(4), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_DECL_LIST ')'");
            }
#line 3835 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 154:
#line 1368 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(5), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' RING_CMD ')'");
            }
#line 3845 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 155:
#line 1375 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(6), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' mat_cmd ')'");
            }
#line 3855 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 156:
#line 1382 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(7), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' PROC_CMD ')'");
            }
#line 3865 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 157:
#line 1389 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
                (yyval.tree) = astnode_make1(RULE_listcmd(8), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ')'");
            }
#line 3875 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 158:
#line 1396 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(9), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL ')'");
            }
#line 3885 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 159:
#line 1403 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(10), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' ROOT_DECL_LIST ')'");
            }
#line 3895 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 160:
#line 1410 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(11), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL ')'");
            }
#line 3905 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 161:
#line 1417 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(12), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_DECL_LIST ')'");
            }
#line 3915 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 162:
#line 1424 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(13), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' RING_CMD ')'");
            }
#line 3925 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 163:
#line 1431 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(14), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' mat_cmd ')'");
            }
#line 3935 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 164:
#line 1438 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
                (yyval.tree) = astnode_make2(RULE_listcmd(15), (yyvsp[-3].tree), astint_make((yyvsp[-1].i)));
                exitrule("listcmd -> LISTVAR_CMD '(' elemexpr ',' PROC_CMD ')'");
            }
#line 3945 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 165:
#line 1445 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("listcmd -> LISTVAR_CMD '(' ')'");
                (yyval.tree) = astnode_make0(RULE_listcmd(16));
                exitrule("listcmd -> LISTVAR_CMD '(' ')'");
            }
#line 3955 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 166:
#line 1454 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd1 -> RING_CMD");
                (yyval.tree) = astnode_make0(RULE_ringcmd1(1));
                exitrule("ringcmd1 -> RING_CMD");
            }
#line 3965 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 167:
#line 1467 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
                (yyval.tree) = astnode_make4(RULE_ringcmd(1), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq rlist ','  rlist ',' ordering");
            }
#line 3975 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 168:
#line 1474 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr");
                (yyval.tree) = astnode_make1(RULE_ringcmd(2), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr");
            }
#line 3985 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 169:
#line 1481 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
                (yyval.tree) = astnode_make2(RULE_ringcmd(3), (yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr");
            }
#line 3995 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 170:
#line 1488 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
                (yyval.tree) = astnode_make3(RULE_ringcmd(4), (yyvsp[-5].tree), (yyvsp[-3].tree), (yyvsp[-1].tree));
                exitrule("ringcmd -> ringcmd1 elemexpr cmdeq elemexpr '[' exprlist ']'");
            }
#line 4005 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 171:
#line 1497 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("scriptcmd -> SYSVAR stringexpr");
                (yyval.tree) = astnode_make2(RULE_scriptcmd(1), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule("scriptcmd -> SYSVAR stringexpr");
            }
#line 4015 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 172:
#line 1506 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setrings -> SETRING_CMD");
                (yyval.tree) = astnode_make0(RULE_setrings(1));
                exitrule("setrings -> SETRING_CMD");
            }
#line 4025 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 173:
#line 1512 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setrings -> KEEPRING_CMD");
                (yyval.tree) = astnode_make0(RULE_setrings(2));
                exitrule("setrings -> KEEPRING_CMD");
            }
#line 4035 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 174:
#line 1521 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("setringcmd -> setrings expr");
                (yyval.tree) = astnode_make2(RULE_setringcmd(1), (yyvsp[-1].tree), (yyvsp[0].tree));
                exitrule("setringcmd -> setrings expr");
            }
#line 4045 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 175:
#line 1530 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("typecmd -> TYPE_CMD expr");
                (yyval.tree) = astnode_make1(RULE_typecmd(1), (yyvsp[0].tree));
                exitrule("typecmd -> TYPE_CMD expr");
            }
#line 4055 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 176:
#line 1537 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("typecmd -> exprlist");
                (yyval.tree) = astnode_make1(RULE_typecmd(2), (yyvsp[0].tree));
                exitrule_ex("typecmd -> exprlist", (yyval.tree));
            }
#line 4065 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 177:
#line 1549 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_ifcmd(1), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("ifcmd -> IF_CMD '(' expr ')' '{' lines '}'",(yyval.tree));
            }
#line 4075 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 178:
#line 1556 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> ELSE_CMD '{' lines '}'");
                (yyval.tree) = astnode_make1(RULE_ifcmd(2), (yyvsp[-1].tree));
                exitrule_ex("ifcmd -> ELSE_CMD '{' lines '}'",(yyval.tree));
            }
#line 4085 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 179:
#line 1563 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
                (yyval.tree) = astnode_make1(RULE_ifcmd(3), (yyvsp[-2].tree));
                exitrule("ifcmd -> IF_CMD '(' expr ')' BREAK_CMD");
            }
#line 4095 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 180:
#line 1570 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> BREAK_CMD");
                (yyval.tree) = astnode_make0(RULE_ifcmd(4));
                exitrule("ifcmd -> BREAK_CMD");
            }
#line 4105 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 181:
#line 1577 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("ifcmd -> CONTINUE_CMD");
                (yyval.tree) = astnode_make0(RULE_ifcmd(5));
                exitrule("ifcmd -> CONTINUE_CMD");
            }
#line 4115 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 182:
#line 1586 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_whilecmd(1), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("whilecmd -> WHILE_CMD '(' expr ')' '{' lines '}'",(yyval.tree));
            }
#line 4125 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 183:
#line 1595 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'");
                (yyval.tree) = astnode_make4(RULE_forcmd(1), (yyvsp[-8].tree), (yyvsp[-6].tree), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("forcmd -> FOR_CMD '(' npprompt ';' expr ';' npprompt ')' '{' lines '}'",(yyval.tree));
            }
#line 4135 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 184:
#line 1604 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(1), aststring_make((yyvsp[-3].name)), (yyvsp[-1].tree));
                exitrule("proccmd -> PROC_CMD extendedid '{' lines '}'");
            }
#line 4145 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 185:
#line 1611 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '(' ')' '{' lines '}'");
                (yyval.tree) = astnode_make2(RULE_proccmd(2), aststring_make((yyvsp[-5].name)), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid '(' ')' '{' lines '}'",(yyval.tree));
            }
#line 4155 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 186:
#line 1618 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make3(RULE_proccmd(3), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4165 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 187:
#line 1625 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("proccmd -> PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'");
                (yyval.tree) = astnode_make4(RULE_proccmd(4), aststring_make((yyvsp[-7].name)), aststring_make((yyvsp[-6].name)), (yyvsp[-4].tree), (yyvsp[-1].tree));
                exitrule_ex("proccmd -> PROC_CMD extendedid STRINGTOK '(' procarglist ')' '{' lines '}'",(yyval.tree));
            }
#line 4175 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 188:
#line 1634 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("parametercmd -> PARAMETER declare_ip_variable");
                (yyval.tree) = astnode_make1(RULE_parametercmd(1), (yyvsp[0].tree));
                exitrule("parametercmd -> PARAMETER declare_ip_variable");
            }
#line 4185 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 189:
#line 1641 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("parametercmd -> PARAMETER expr");
                (yyval.tree) = astnode_make1(RULE_parametercmd(2), (yyvsp[0].tree));
                exitrule("parametercmd -> PARAMETER expr");
            }
#line 4195 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 190:
#line 1650 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("returncmd -> RETURN '(' exprlist ')'");
                (yyval.tree) = astnode_make1(RULE_returncmd(1), (yyvsp[-1].tree));
                exitrule_ex("returncmd -> RETURN '(' exprlist ')'",(yyval.tree));
            }
#line 4205 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 191:
#line 1657 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("returncmd -> RETURN '(' ')'");
                (yyval.tree) = astnode_make0(RULE_returncmd(2));
                exitrule_ex("returncmd -> RETURN '(' ')'",(yyval.tree));
            }
#line 4215 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 192:
#line 1666 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarglist -> procarglist ',' procarg");
                (yyval.tree) = astnode_append((yyvsp[-2].tree), (yyvsp[0].tree));
                exitrule_ex("procarglist -> procarglist ',' procarg",(yyval.tree));
            }
#line 4225 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 193:
#line 1673 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarglist -> procarg");
                (yyval.tree) = astnode_make1(RULE_procarglist(1), (yyvsp[0].tree));
                exitrule_ex("procarglist -> procarg",(yyval.tree));
            }
#line 4235 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 194:
#line 1682 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(1), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL extendedid",(yyval.tree));
            }
#line 4245 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 195:
#line 1689 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> ROOT_DECL_LIST extendedid");
                (yyval.tree) = astnode_make2(RULE_procarg(2), astint_make((yyvsp[-1].i)), (yyvsp[0].tree));
                exitrule_ex("procarg -> ROOT_DECL_LIST extendedid",(yyval.tree));
            }
#line 4255 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 196:
#line 1696 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> PROC_CMD extendedid");
                (yyval.tree) = astnode_make1(RULE_procarg(3), (yyvsp[0].tree));
                exitrule_ex("procarg -> PROC_CMD extendedid",(yyval.tree));
            }
#line 4265 "grammar.tab.c" /* yacc.c:1646  */
    break;

  case 197:
#line 1703 "grammar.y" /* yacc.c:1646  */
    {
                enterrule("procarg -> extendedid");
                (yyval.tree) = astnode_make1(RULE_procarg(4), (yyvsp[0].tree));
                exitrule_ex("procarg -> extendedid",(yyval.tree));
            }
#line 4275 "grammar.tab.c" /* yacc.c:1646  */
    break;


#line 4279 "grammar.tab.c" /* yacc.c:1646  */
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
#line 1710 "grammar.y" /* yacc.c:1906  */



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

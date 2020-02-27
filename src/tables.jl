
const _UMINUS = 342

@enum CMDS begin
# SingularInterpreter only
    STUPLE_CMD = 100
    HANDLED_TYPES = 101
# must match deps/ast_generator/grammar.tab.h
    DOTDOT = 258
    EQUAL_EQUAL = 259
    GE = 260
    LE = 261
    MINUSMINUS = 262
    NOT = 263
    NOTEQUAL = 264
    PLUSPLUS = 265
    COLONCOLON = 266
    ARROW = 267
    GRING_CMD = 268
    BIGINTMAT_CMD = 269
    INTMAT_CMD = 270
    PROC_CMD = 271
    RING_CMD = 272
    BEGIN_RING = 273
    BUCKET_CMD = 274
    IDEAL_CMD = 275
    MAP_CMD = 276
    MATRIX_CMD = 277
    MODUL_CMD = 278
    NUMBER_CMD = 279
    POLY_CMD = 280
    RESOLUTION_CMD = 281
    SMATRIX_CMD = 282
    VECTOR_CMD = 283
    BETTI_CMD = 284
    E_CMD = 285
    FETCH_CMD = 286
    FREEMODULE_CMD = 287
    KEEPRING_CMD = 288
    IMAP_CMD = 289
    KOSZUL_CMD = 290
    MAXID_CMD = 291
    MONOM_CMD = 292
    PAR_CMD = 293
    PREIMAGE_CMD = 294
    VAR_CMD = 295
    VALTVARS = 296
    VMAXDEG = 297
    VMAXMULT = 298
    VNOETHER = 299
    VMINPOLY = 300
    END_RING = 301
    CMD_1 = 302
    CMD_2 = 303
    CMD_3 = 304
    CMD_12 = 305
    CMD_13 = 306
    CMD_23 = 307
    CMD_123 = 308
    CMD_M = 309
    ROOT_DECL = 310
    ROOT_DECL_LIST = 311
    RING_DECL = 312
    RING_DECL_LIST = 313
    EXAMPLE_CMD = 314
    EXPORT_CMD = 315
    HELP_CMD = 316
    KILL_CMD = 317
    LIB_CMD = 318
    LISTVAR_CMD = 319
    SETRING_CMD = 320
    TYPE_CMD = 321
    STRINGTOK = 322
    BLOCKTOK = 323
    INT_CONST = 324
    UNKNOWN_IDENT = 325
    MONOM = 326
    PROC_DEF = 327
    APPLY = 328
    ASSUME_CMD = 329
    BREAK_CMD = 330
    CONTINUE_CMD = 331
    ELSE_CMD = 332
    EVAL = 333
    QUOTE = 334
    FOR_CMD = 335
    IF_CMD = 336
    SYS_BREAK = 337
    WHILE_CMD = 338
    RETURN = 339
    PARAMETER = 340
    SYSVAR = 341
    UMINUS = 342

    COMMAND = _UMINUS + 2
    ANY_TYPE = _UMINUS + 3
    IDHDL = _UMINUS + 4

#must match deps/ast_generator/tok.h
  ALIAS_CMD     =  _UMINUS + 15
  ALIGN_CMD
  ATTRIB_CMD
  BAREISS_CMD
  BIGINT_CMD
  BRANCHTO_CMD
  BRACKET_CMD
  BREAKPOINT_CMD
  CHARACTERISTIC_CMD
  CHARSTR_CMD
  CHAR_SERIES_CMD
  CHINREM_CMD
  CMATRIX_CMD
  CNUMBER_CMD
  CPOLY_CMD
  CLOSE_CMD
  COEFFS_CMD
  COEF_CMD
  COLS_CMD
  CONTENT_CMD
  CONTRACT_CMD
  COUNT_CMD
  CRING_CMD
  DBPRINT_CMD
  DEF_CMD
  DEFINED_CMD
  DEG_CMD
  DEGREE_CMD
  DELETE_CMD
  DENOMINATOR_CMD
  DET_CMD
  DIFF_CMD
  DIM_CMD
  DIVISION_CMD
  DUMP_CMD
  ELIMINATION_CMD
  END_GRAMMAR
  ENVELOPE_CMD
  ERROR_CMD
  EXECUTE_CMD
  EXPORTTO_CMD
  EXTGCD_CMD
  FAC_CMD
  FAREY_CMD
  FIND_CMD
  FACSTD_CMD
  FMD_CMD
  FRES_CMD
  FWALK_CMD
  FGLM_CMD
  FGLMQUOT_CMD
  FINDUNI_CMD
  GCD_CMD
  GETDUMP_CMD
  HIGHCORNER_CMD
  HILBERT_CMD
  HOMOG_CMD
  HRES_CMD
  IMPART_CMD
  IMPORTFROM_CMD
  INDEPSET_CMD
  INSERT_CMD
  INT_CMD
  INTDIV_CMD
  INTERPOLATE_CMD
  INTERRED_CMD
  INTERSECT_CMD
  INTVEC_CMD
  IS_RINGVAR
  JACOB_CMD
  JANET_CMD
  JET_CMD
  KBASE_CMD
  KERNEL_CMD
  KILLATTR_CMD
  KRES_CMD
  LAGSOLVE_CMD
  LEAD_CMD
  LEADCOEF_CMD
  LEADEXP_CMD
  LEADMONOM_CMD
  LIFTSTD_CMD
  LIFT_CMD
  LINK_CMD
  LIST_CMD
  LOAD_CMD
  LRES_CMD
  LU_CMD
  LUI_CMD
  LUS_CMD
  MEMORY_CMD
  MINBASE_CMD
  MINOR_CMD
  MINRES_CMD
  MODULO_CMD
  MONITOR_CMD
  MPRES_CMD
  MRES_CMD
  MSTD_CMD
  MULTIPLICITY_CMD
  NAMEOF_CMD
  NAMES_CMD
  NEWSTRUCT_CMD
  NCALGEBRA_CMD
  NC_ALGEBRA_CMD
  NEWTONPOLY_CMD
  NPARS_CMD
  NUMERATOR_CMD
  NVARS_CMD
  ORD_CMD
  OPEN_CMD
  OPPOSE_CMD
  OPPOSITE_CMD
  OPTION_CMD
  ORDSTR_CMD
  PACKAGE_CMD
  PARDEG_CMD
  PARENT_CMD
  PARSTR_CMD
  PFAC_CMD
  PRIME_CMD
  PRINT_CMD
  PRUNE_CMD
  QHWEIGHT_CMD
  QRING_CMD
  QRDS_CMD
  QUOTIENT_CMD
  RANDOM_CMD
  RANK_CMD
  READ_CMD
  REDUCE_CMD
  REGULARITY_CMD
  REPART_CMD
  RES_CMD
  RESERVEDNAME_CMD
  RESERVEDNAMELIST_CMD
  RESTART_CMD
  RESULTANT_CMD
  RIGHTSTD_CMD
  RINGLIST_CMD
  RING_LIST_CMD
  ROWS_CMD
  SBA_CMD
  SIMPLEX_CMD
  SIMPLIFY_CMD
  SLIM_GB_CMD
  SORTVEC_CMD
  SQR_FREE_CMD
  SRES_CMD
  STATUS_CMD
  STD_CMD
  STRING_CMD
  SUBST_CMD
  SYSTEM_CMD
  SYZYGY_CMD
  TENSOR_CMD
  TEST_CMD
  TRANSPOSE_CMD
  TRACE_CMD
  TWOSTD_CMD
  TYPEOF_CMD
  UNIVARIATE_CMD
  UNLOAD_CMD # /* unused*/
  URSOLVE_CMD
  VANDER_CMD
  VARIABLES_CMD
  VARSTR_CMD
  VDIM_CMD
  WAIT1ST_CMD
  WAITALL_CMD
  WEDGE_CMD
  WEIGHT_CMD
  WRITE_CMD
#  /* start system var section: VECHO */
  VECHO
  VCOLMAX
  VTIMER
  VRTIMER
  TRACE
  VOICE
  VSHORTOUT
  VPRINTLEVEL
  # /* end system var section: VPRINTLEVEL */

  MAX_TOK # /* must be the last, biggest token number */
end

@assert Int(UMINUS) == _UMINUS

const system_var_to_string = Dict{Int, String}(
    Int(VMAXDEG)        => "degBound",
    Int(VMAXMULT)       => "multBound",
    Int(VMINPOLY)       => "minpoly",
    Int(VNOETHER)       => "noether",
    Int(VSHORTOUT)      => "short",
    Int(VECHO)          => "echo",
    Int(VCOLMAX)        => "pagewidth",
    Int(VPRINTLEVEL)    => "printlevel",
    Int(VRTIMER)        => "rtimer",
    Int(VTIMER)         => "timer",
    Int(TRACE)          => "TRACE",
    Int(VOICE)          => "voice"
)

const cmds_that_screw_everything = Set{Int}([
    Int(EXECUTE_CMD)
])

const op_to_string = Dict{Int, String}(Int(c) => s for (c, s) in [
    '+'         => "plus",
    '-'         => "minus",
    '*'         => "times",
    '/'         => "divide",
    '%'         => "mod",
    '^'         => "power",
    '<'         => "less",
    '>'         => "greater",
    ':'         => "colon",
    EQUAL_EQUAL => "equalequal",
    GE          => "greaterequal",
    LE          => "lessequal",
    '['         => "getindex",
])
# '|', '&' exist only for Int

const cmd_to_string = Dict{Int, String}(
    Int(ALIGN_CMD)    => "align",
    Int(ATTRIB_CMD)    => "attrib",
    Int(BAREISS_CMD)    => "bareiss",
    Int(BETTI_CMD)    => "betti",
    Int(BRANCHTO_CMD)    => "branchTo",
    Int(BREAKPOINT_CMD)    => "breakpoint",
    Int(CHARACTERISTIC_CMD)    => "char",
    Int(CHAR_SERIES_CMD)    => "char_series",
    Int(CHARSTR_CMD)    => "charstr",
    Int(CHINREM_CMD)    => "chinrem",
    Int(CONTENT_CMD)    => "cleardenom",
    Int(CLOSE_CMD)    => "close",
    Int(COEF_CMD)    => "coef",
    Int(COEFFS_CMD)    => "coeffs",
    Int(CONTRACT_CMD)    => "contract",
    Int(NEWTONPOLY_CMD)    => "convhull",
    Int(DBPRINT_CMD)    => "dbprint",
    Int(DEFINED_CMD)    => "defined",
    Int(DEG_CMD)    => "deg",
    Int(DEGREE_CMD)    => "degree",
    Int(DELETE_CMD)    => "delete",
    Int(DENOMINATOR_CMD)    => "denominator",
    Int(DET_CMD)    => "det",
    Int(DIFF_CMD)    => "diff",
    Int(DIM_CMD)    => "dim",
    Int(DIVISION_CMD)    => "division",
    Int(DUMP_CMD)    => "dump",
    Int(EXTGCD_CMD)    => "extgcd",
    Int(ERROR_CMD)    => "ERROR",
    Int(ELIMINATION_CMD)    => "eliminate",
    Int(EXECUTE_CMD)    => "execute",
    Int(EXPORTTO_CMD)    => "exportto",
    Int(FACSTD_CMD)    => "facstd",
    Int(FMD_CMD)    => "factmodd",
    Int(FAC_CMD)    => "factorize",
    Int(FAREY_CMD)    => "farey",
    Int(FETCH_CMD)    => "fetch",
    Int(FGLM_CMD)    => "fglm",
    Int(FGLMQUOT_CMD)    => "fglmquot",
    Int(FIND_CMD)    => "find",
    Int(FINDUNI_CMD)    => "finduni",
    Int(FREEMODULE_CMD)    => "freemodule",
    Int(FRES_CMD)    => "fres",
    Int(FWALK_CMD)    => "frwalk",
    Int(E_CMD)    => "gen",
    Int(GETDUMP_CMD)    => "getdump",
    Int(GCD_CMD)    => "gcd",
    Int(GCD_CMD)    => "GCD",
    Int(HILBERT_CMD)    => "hilb",
    Int(HIGHCORNER_CMD)    => "highcorner",
    Int(HOMOG_CMD)    => "homog",
    Int(HRES_CMD)    => "hres",
    Int(IMAP_CMD)    => "imap",
    Int(IMPART_CMD)    => "impart",
    Int(IMPORTFROM_CMD)    => "importfrom",
    Int(INDEPSET_CMD)    => "indepSet",
    Int(INSERT_CMD)    => "insert",
    Int(INTERPOLATE_CMD)    => "interpolation",
    Int(INTERRED_CMD)    => "interred",
    Int(INTERSECT_CMD)    => "intersect",
    Int(JACOB_CMD)    => "jacob",
    Int(JANET_CMD)    => "janet",
    Int(JET_CMD)    => "jet",
    Int(KBASE_CMD)    => "kbase",
    Int(KERNEL_CMD)    => "kernel",
    Int(KILLATTR_CMD)    => "killattrib",
    Int(KOSZUL_CMD)    => "koszul",
    Int(KRES_CMD)    => "kres",
    Int(LAGSOLVE_CMD)    => "laguerre",
    Int(LEAD_CMD)    => "lead",
    Int(LEADCOEF_CMD)    => "leadcoef",
    Int(LEADEXP_CMD)    => "leadexp",
    Int(LEADMONOM_CMD)    => "leadmonom",
    Int(LIFT_CMD)    => "lift",
    Int(LIFTSTD_CMD)    => "liftstd",
    Int(LOAD_CMD)    => "load",
    Int(LRES_CMD)    => "lres",
    Int(LU_CMD)    => "ludecomp",
    Int(LUI_CMD)    => "luinverse",
    Int(LUS_CMD)    => "lusolve",
    Int(MAXID_CMD)    => "maxideal",
    Int(MEMORY_CMD)    => "memory",
    Int(MINBASE_CMD)    => "minbase",
    Int(MINOR_CMD)    => "minor",
    Int(MINRES_CMD)    => "minres",
    Int(MODULO_CMD)    => "modulo",
    Int(MONITOR_CMD)    => "monitor",
    Int(MONOM_CMD)    => "monomial",
    Int(MPRES_CMD)    => "mpresmat",
    Int(MULTIPLICITY_CMD)    => "mult",
    Int(MRES_CMD)    => "mres",
    Int(MSTD_CMD)    => "mstd",
    Int(NAMEOF_CMD)    => "nameof",
    Int(NAMES_CMD)    => "names",
    Int(NEWSTRUCT_CMD)    => "newstruct",
    Int(COLS_CMD)    => "ncols",
    Int(NPARS_CMD)    => "npars",
    Int(RES_CMD)    => "nres",
    Int(ROWS_CMD)    => "nrows",
    Int(NUMERATOR_CMD)    => "numerator",
    Int(NVARS_CMD)    => "nvars",
    Int(OPEN_CMD)    => "open",
    Int(OPTION_CMD)    => "option",
    Int(ORD_CMD)    => "ord",
    Int(ORDSTR_CMD)    => "ordstr",
    Int(PAR_CMD)    => "par",
    Int(PARDEG_CMD)    => "pardeg",
    Int(PARSTR_CMD)    => "parstr",
    Int(PREIMAGE_CMD)    => "preimage",
    Int(PRIME_CMD)    => "prime",
    Int(PFAC_CMD)    => "primefactors",
    Int(PRINT_CMD)    => "print",
    Int(PRUNE_CMD)    => "prune",
    Int(QHWEIGHT_CMD)    => "qhweight",
    Int(QRDS_CMD)    => "qrds",
    Int(QUOTIENT_CMD)    => "quotient",
    Int(RANDOM_CMD)    => "random",
    Int(RANK_CMD)    => "rank",
    Int(READ_CMD)    => "read",
    Int(REDUCE_CMD)    => "reduce",
    Int(REGULARITY_CMD)    => "regularity",
    Int(REPART_CMD)    => "repart",
    Int(RESERVEDNAME_CMD)    => "reservedName",
#    Int(RESERVEDNAMELIST_CMD)    => "reservedNameList",
    Int(RESULTANT_CMD)    => "resultant",
    Int(RESTART_CMD)    => "restart",
    Int(RINGLIST_CMD)    => "ringlist",
    Int(RING_LIST_CMD)    => "ring_list",
    Int(IS_RINGVAR)    => "rvar",
    Int(SBA_CMD)    => "sba",
    Int(SIMPLEX_CMD)    => "simplex",
    Int(SIMPLIFY_CMD)    => "simplify",
    Int(COUNT_CMD)    => "size",
    Int(SLIM_GB_CMD)    => "slimgb",
    Int(SORTVEC_CMD)    => "sortvec",
    Int(SQR_FREE_CMD)    => "sqrfree",
    Int(SRES_CMD)    => "sres",
    Int(STATUS_CMD)    => "status",
    Int(STD_CMD)    => "std",
    Int(SUBST_CMD)    => "subst",
    Int(SYSTEM_CMD)    => "system",
    Int(SYZYGY_CMD)    => "syz",
    Int(TENSOR_CMD)    => "tensor",
    Int(TEST_CMD)    => "test",
    Int(TRACE_CMD)    => "trace",
    Int(TRANSPOSE_CMD)    => "transpose",
    Int(TYPEOF_CMD)    => "typeof",
    Int(UNIVARIATE_CMD)    => "univariate",
    Int(URSOLVE_CMD)    => "uressolve",
    Int(VANDER_CMD)    => "vandermonde",
    Int(VAR_CMD)    => "var",
    Int(VARIABLES_CMD)    => "variables",
    Int(VARSTR_CMD)    => "varstr",
    Int(VDIM_CMD)    => "vdim",
    Int(WEDGE_CMD)    => "wedge",
    Int(WEIGHT_CMD)    => "weight",
    Int(WRITE_CMD)    => "write"
)

const cmd_to_builtin_type_string = Dict{Int, String}(
    Int(DEF_CMD) => "def",
    Int(PROC_CMD) => "proc",
    Int(INT_CMD) => "int",
    Int(BIGINT_CMD) => "bigint",
    Int(STRING_CMD) => "string",
    Int(INTVEC_CMD) => "intvec",
    Int(INTMAT_CMD) => "intmat",
    Int(BIGINTMAT_CMD) => "bigintmat",
    Int(LIST_CMD) => "list",
    Int(RING_CMD) => "ring",
    Int(QRING_CMD) => "ring",
    Int(NUMBER_CMD) => "number",
    Int(POLY_CMD) => "poly",
    Int(IDEAL_CMD) => "ideal",
    Int(MATRIX_CMD) => "matrix",
    Int(MODUL_CMD) => "module",
    Int(VECTOR_CMD) => "vector",
    Int(MAP_CMD) => "map",
    Int(LINK_CMD) => "link",
    Int(RESOLUTION_CMD) => "resolution"
)

const builtin_typestring_to_symbol = Dict{String, Symbol}(
    "def" => :Any,
    "proc" => :Sproc,
    "int" => :Int,
    "bigint" => :BigInt,
    "string" => :Sstring,
    "intvec" => :Sintvec,
    "intmat" => :Sintmat,
    "bigintmat" => :Sbigintmat,
    "list" => :Slist,
    "ring" => :Sring,
    "qring" => :Sring,
    "number" => :Snumber,
    "poly" => :Spoly,
    "vector" => :Svector,
    "ideal" => :Sideal,
    "module" => :Smodule,
    "matrix" => :Smatrix,
    "map" => Symbol("???"),
    "link" => Symbol("???"),
    "resolution" => Symbol("???")
)

const NONE = END_RING


#### options in rtGlobal.si_opt_1
const OPT_PROT_MASK             = UInt32(1) << 0
const OPT_REDSB_MASK            = UInt32(1) << 1
const OPT_NOT_BUCKETS_MASK      = UInt32(1) << 2
const OPT_NOT_SUGAR_MASK        = UInt32(1) << 3
const OPT_INTERRUPT_MASK        = UInt32(1) << 4
const OPT_SUGARCRIT_MASK        = UInt32(1) << 5
const OPT_DEBUG_MASK            = UInt32(1) << 6
const OPT_REDTHROUGH_MASK       = UInt32(1) << 7
const OPT_NO_SYZ_MINIM_MASK     = UInt32(1) << 8
const OPT_RETURN_SB_MASK        = UInt32(1) << 9
const OPT_FASTHC_MASK           = UInt32(1) << 10
const OPT_OLDSTD_MASK           = UInt32(1) << 20
const OPT_STAIRCASEBOUND_MASK   = UInt32(1) << 22
const OPT_MULTBOUND_MASK        = UInt32(1) << 23
const OPT_DEGBOUND_MASK         = UInt32(1) << 24
const OPT_REDTAIL_MASK          = UInt32(1) << 25
const OPT_INTSTRATEGY_MASK      = UInt32(1) << 26
const OPT_FINDET_MASK           = UInt32(1) << 27
const OPT_INFREDTAIL_MASK       = UInt32(1) << 28
const OPT_SB_1_MASK             = UInt32(1) << 29
const OPT_NOTREGULARITY_MASK    = UInt32(1) << 30
const OPT_WEIGHTM_MASK          = UInt32(1) << 31

const valid_test_options = UInt32(1) << 0 |
                           UInt32(1) << 1 |
                           UInt32(1) << 2 |
                           UInt32(1) << 3 |
                           UInt32(1) << 4 |
                           UInt32(1) << 5 |
                           UInt32(1) << 6 |
                           UInt32(1) << 7 |
                           UInt32(1) << 8 |
                           UInt32(1) << 9 |
                           UInt32(1) << 10 |
                           UInt32(1) << 11 |
                           UInt32(1) << 12 |
                           UInt32(1) << 13 |
                           UInt32(1) << 14 |
                           UInt32(1) << 15 |
                           UInt32(1) << 16 |
                           UInt32(1) << 17 |
                           UInt32(1) << 18 |
                           UInt32(1) << 19 |
                           OPT_OLDSTD_MASK |
                           UInt32(1) << 21 |
                           UInt32(1) << 22 |
                           OPT_REDTAIL_MASK |
                           OPT_INTSTRATEGY_MASK |
                           UInt32(1) << 27 |
                           UInt32(1) << 28 |
                           UInt32(1) << 29 |
                           UInt32(1) << 30 |
                           UInt32(1) << 31

const test_options = Pair{String, UInt32}[
    "prot"          => OPT_PROT_MASK,
    "redSB"         => OPT_REDSB_MASK,
    "notBuckets"    => OPT_NOT_BUCKETS_MASK,
    "notSugar"      => OPT_NOT_SUGAR_MASK,
    "interrupt"     => OPT_INTERRUPT_MASK,
    "sugarCrit"     => OPT_SUGARCRIT_MASK,
    "teach"         => OPT_DEBUG_MASK,
    "notSyzMinim"   => OPT_NO_SYZ_MINIM_MASK,
    "returnSB"      => OPT_RETURN_SB_MASK,
    "fastHC"        => OPT_FASTHC_MASK,
    "staircaseBound"=> OPT_STAIRCASEBOUND_MASK,
    "multBound"     => OPT_MULTBOUND_MASK,
    "degBound"      => OPT_DEGBOUND_MASK,
    "redTail"       => OPT_REDTAIL_MASK,
    "redThrough"    => OPT_REDTHROUGH_MASK,
    "lazy"          => OPT_OLDSTD_MASK,
    "intStrategy"   => OPT_INTSTRATEGY_MASK,
    "infRedTail"    => OPT_INFREDTAIL_MASK,
    "notRegularity" => OPT_NOTREGULARITY_MASK,
    "weightM"       => OPT_WEIGHTM_MASK
]

#### options in rtGlobal.si_opt_2
const V_QUIET_MASK          = UInt32(1) << 0
const V_QRING_MASK          = UInt32(1) << 1
const V_SHOW_MEM_MASK       = UInt32(1) << 2
const V_YACC_MASK           = UInt32(1) << 3
const V_REDEFINE_MASK       = UInt32(1) << 4
const V_READING_MASK        = UInt32(1) << 5
const V_LOAD_LIB_MASK       = UInt32(1) << 6
const V_DEBUG_LIB_MASK      = UInt32(1) << 7
const V_LOAD_PROC_MASK      = UInt32(1) << 8
const V_DEF_RES_MASK        = UInt32(1) << 9
const V_SHOW_USE_MASK       = UInt32(1) << 11
const V_IMAP_MASK           = UInt32(1) << 12
const V_PROMPT_MASK         = UInt32(1) << 13
const V_NSB_MASK            = UInt32(1) << 14
const V_CONTENTSB_MASK      = UInt32(1) << 15
const V_CANCELUNIT_MASK     = UInt32(1) << 16
const V_MODPSOLVSB_MASK     = UInt32(1) << 17
const V_UPTORADICAL_MASK    = UInt32(1) << 18
const V_FINDMONOM_MASK      = UInt32(1) << 19
const V_COEFSTRAT_MASK      = UInt32(1) << 20
const V_IDLIFT_MASK         = UInt32(1) << 21
const V_LENGTH_MASK         = UInt32(1) << 22
const V_ALLWARN_MASK        = UInt32(1) << 24
const V_INTERSECT_ELIM_MASK = UInt32(1) << 25
const V_INTERSECT_SYZ_MASK  = UInt32(1) << 26
const V_DEG_STOP_MASK       = UInt32(1) << 31

const verbose_options = Pair{String, UInt32}[
    "mem"           => V_SHOW_MEM_MASK,
    "yacc"          => V_YACC_MASK,
    "redefine"      => V_REDEFINE_MASK,
    "reading"       => V_READING_MASK,
    "loadLib"       => V_LOAD_LIB_MASK,
    "debugLib"      => V_DEBUG_LIB_MASK,
    "loadProc"      => V_LOAD_PROC_MASK,
    "defRes"        => V_DEF_RES_MASK,
    "usage"         => V_SHOW_USE_MASK,
    "Imap"          => V_IMAP_MASK,
    "prompt"        => V_PROMPT_MASK,
    "length"        => V_LENGTH_MASK,
    "notWarnSB"     => V_NSB_MASK,
    "contentSB"     => V_CONTENTSB_MASK,
    "cancelunit"    => V_CANCELUNIT_MASK,
    "modpsolve"     => V_MODPSOLVSB_MASK,
    "geometricSB"   => V_UPTORADICAL_MASK,
    "findMonomials" => V_FINDMONOM_MASK,
    "coefStrat"     => V_COEFSTRAT_MASK,
    "qringNF"       => V_QRING_MASK,
    "warn"          => V_ALLWARN_MASK,
    "intersectSyz"  => V_INTERSECT_SYZ_MASK,
    "intersectElim" => V_INTERSECT_ELIM_MASK
]

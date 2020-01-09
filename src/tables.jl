
@enum CMDS begin
# must match deps/ast_generator/grammar.tab.h
  DOTDOT = 258
  EQUAL_EQUAL
  GE
  LE
  MINUSMINUS
  NOT
  NOTEQUAL
  PLUSPLUS
  COLONCOLON
  ARROW
  GRING_CMD
  BIGINTMAT_CMD
  INTMAT_CMD
  PROC_CMD
  STATIC_PROC_CMD
  RING_CMD
  BEGIN_RING
  BUCKET_CMD
  IDEAL_CMD
  MAP_CMD
  MATRIX_CMD
  MODUL_CMD
  NUMBER_CMD
  POLY_CMD
  RESOLUTION_CMD
  SMATRIX_CMD
  VECTOR_CMD
  BETTI_CMD
  E_CMD
  FETCH_CMD
  FREEMODULE_CMD
  KEEPRING_CMD
  IMAP_CMD
  KOSZUL_CMD
  MAXID_CMD
  MONOM_CMD
  PAR_CMD
  PREIMAGE_CMD
  VAR_CMD
  VALTVARS
  VMAXDEG
  VMAXMULT
  VNOETHER
  VMINPOLY
  END_RING
  CMD_1
  CMD_2
  CMD_3
  CMD_12
  CMD_13
  CMD_23
  CMD_123
  CMD_M
  ROOT_DECL
  ROOT_DECL_LIST
  RING_DECL
  RING_DECL_LIST
  EXAMPLE_CMD
  EXPORT_CMD
  HELP_CMD
  KILL_CMD
  LIB_CMD
  LISTVAR_CMD
  SETRING_CMD
  TYPE_CMD
  STRINGTOK
  INT_CONST
  UNKNOWN_IDENT
  RINGVAR
  PROC_DEF
  APPLY
  ASSUME_CMD
  BREAK_CMD
  CONTINUE_CMD
  ELSE_CMD
  EVAL
  QUOTE
  FOR_CMD
  IF_CMD
  SYS_BREAK
  WHILE_CMD
  RETURN
  PARAMETER
  QUIT_CMD
  SYSVAR
  UMINUS
#must match deps/ast_generator/tok.h
  ALIAS_CMD = 1000
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
  RESTART_CMD
  RESULTANT_CMD
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
  UNLOAD_CMD
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

  VECHO
  VCOLMAX
  VTIMER
  VRTIMER
  TRACE
  VOICE
  VSHORTOUT
  VPRINTLEVEL

  MAX_TOK
end


const system_var_to_string = Dict{Int, String}(
    Int(VMAXDEG)        => "degBound",
    Int(VECHO)          => "echo",
    Int(VMINPOLY)       => "minpoly",
    Int(VMAXMULT)       => "multBound",
    Int(VNOETHER)       => "noether",
    Int(VCOLMAX)        => "pagewidth",
    Int(VPRINTLEVEL)    => "printlevel",
    Int(VRTIMER)        => "rtimer",
    Int(VSHORTOUT)      => "short",
    Int(VTIMER)         => "timer",
    Int(TRACE)          => "TRACE",
    Int(VOICE)          => "voice"
)

const cmds_that_screw_everything = Set{Int}([
    Int(EXECUTE_CMD)
])

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
    Int(NUMBER_CMD) => "number",
    Int(POLY_CMD) => "poly",
    Int(IDEAL_CMD) => "ideal",
    Int(MODUL_CMD) => "module",
    Int(MATRIX_CMD) => "matrix",
    Int(MODUL_CMD) => "module",
    Int(VECTOR_CMD) => "vector",
    Int(MAP_CMD) => "map",
    Int(LINK_CMD) => "link",
    Int(RESOLUTION_CMD) => "resolution"
)

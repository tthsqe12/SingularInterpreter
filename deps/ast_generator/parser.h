
#define RULE_top_lines(i)            (100 + i)
#define RULE_top_pprompt(i)          (200 + i)
#define RULE_lines(i)                (300 + i)
#define RULE_pprompt(i)              (400 + i)
#define RULE_npprompt(i)             (500 + i)
#define RULE_flowctrl(i)             (600 + i)
#define RULE_example_dummy(i)        (700 + i)
#define RULE_command(i)              (800 + i)
#define RULE_assign(i)               (900 + i)
#define RULE_elemexpr(i)            (1000 + i)
#define RULE_exprlist(i)            (1100 + i)
#define RULE_expr(i)                (1200 + i)
#define RULE_quote_start(i)         (1300 + i)
#define RULE_assume_start(i)        (1400 + i)
#define RULE_quote_end(i)           (1500 + i)
#define RULE_expr_arithmetic(i)     (1600 + i)
#define RULE_left_value(i)          (1700 + i)
#define RULE_extendedid(i)          (1800 + i)
#define RULE_declare_ip_variable(i) (1900 + i)
#define RULE_stringexpr(i)          (2000 + i)
#define RULE_rlist(i)               (2100 + i)
#define RULE_ordername(i)           (2200 + i)
#define RULE_orderelem(i)           (2300 + i)
#define RULE_OrderingList(i)        (2400 + i)
#define RULE_ordering(i)            (2500 + i)
#define RULE_mat_cmd(i)             (2600 + i)
#define RULE_filecmd(i)             (2700 + i)
#define RULE_helpcmd(i)             (2800 + i)
#define RULE_examplecmd(i)          (2900 + i)
#define RULE_exportcmd(i)           (3000 + i)
#define RULE_killcmd(i)             (3100 + i)
#define RULE_listcmd(i)             (3200 + i)
#define RULE_ringcmd1(i)            (3300 + i)
#define RULE_ringcmd(i)             (3400 + i)
#define RULE_scriptcmd(i)           (3500 + i)
#define RULE_setrings(i)            (3600 + i)
#define RULE_setringcmd(i)          (3700 + i)
#define RULE_typecmd(i)             (3800 + i)
#define RULE_ifcmd(i)               (3900 + i)
#define RULE_whilecmd(i)            (4000 + i)
#define RULE_forcmd(i)              (4100 + i)
#define RULE_proccmd(i)             (4200 + i)
#define RULE_parametercmd(i)        (4300 + i)
#define RULE_returncmd(i)           (4400 + i)
#define RULE_procarglist(i)         (4500 + i)
#define RULE_procarg(i)             (4600 + i)



typedef struct _astree {
    int type;
    int number;
    char * string;
    size_t length;
    int rule;
    struct _astree ** child;
} astree;

typedef struct _stringlist_node {
    char * string;
    struct _stringlist_node * next;
} stringlist_node;

typedef struct _stringlist_list {
    stringlist_node * first;
    size_t length;
} stringlist;


extern stringlist prev_newstruct_names;
extern stringlist new_newstruct_names;

char * duplicate_string(const char * t);

void stringlist_init(stringlist * L);
void stringlist_clear(stringlist * L);
int stringlist_has(stringlist * L, const char * s);
int stringlist_insert(stringlist * L, const char * s);

/*
    make an 1d array of type Any
    assume the caller holds reference to the elements of a
*/
/*jl_value_t * astnode_make(jl_value_t ** a, size_t len);*/

astree * aststring_make(char * s);
astree * astint_make(int n);
astree * astnode_make0(int h);
astree * astnode_make1(int h, astree * a1);
astree * astnode_make2(int h, astree * a1, astree * a2);
astree * astnode_make3(int h, astree * a1, astree * a2, astree * a3);
astree * astnode_make4(int h, astree * a1, astree * a2, astree * a3, astree * a4);
astree * astnode_append(astree * x, astree * a);
astree * astnode_prepend(astree * x, astree * a);

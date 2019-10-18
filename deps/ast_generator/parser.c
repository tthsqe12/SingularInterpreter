
#include "julia.h"
#include "tok.h"
#include "grammar.tab.h"
#include "scanner.h"


jl_value_t * mjl_AstNode_type;
jl_function_t * mjl_make_fxn, * mjl_append_fxn, * mjl_prepend_fxn, * mjl_func_mydump;

/* global sets used by the lexer */
stringlist prev_newstruct_names;
stringlist new_newstruct_names;


char * duplicate_string(const char * t)
{
    size_t n = strlen(t);
    char * s = (char *) malloc(n + 1);
    strcpy(s, t);
    return s;
}


void stringlist_init(stringlist * L)
{
    L->first = NULL;
    L->length = 0;
}

void stringlist_clear(stringlist * L)
{
    size_t i = 0;
    stringlist_node * n = L->first;
    while (n != NULL)
    {
        i++;
        stringlist_node * m = n->next;
        free(n->string);
        free(n);
        n = m;
    }
    assert(i == L->length);
    L->first = NULL;
    L->length = 0;
}

int stringlist_has(stringlist * L, const char * s)
{
    stringlist_node * n = L->first;
    while (n != NULL)
    {
        if (strcmp(s, n->string) == 0)
            return 1;
        n = n->next;
    }
    return 0;
}

int stringlist_insert(stringlist * L, const char * s)
{
    stringlist_node * n = L->first;
    if (n == NULL)
    {
        assert(L->length == 0);
        n = (stringlist_node *) malloc(sizeof(stringlist_node));
        L->first = n;
    }
    else
    {
        stringlist_node * p;
        do {
            p = n;
            if (strcmp(s, n->string) == 0)
                return 0;
            n = n->next;
        } while (n != NULL);
        n = (stringlist_node *) malloc(sizeof(stringlist_node));
        p->next = n;
    }
    n->next = NULL;
    n->string = duplicate_string(s);
    L->length++;
    return 1;
}



#define TREE_TYPE_NODE   0
#define TREE_TYPE_INT    1
#define TREE_TYPE_STRING 2


astree * aststring_make(char * s)
{
    astree * r = (astree *) malloc(sizeof(astree));
    r->type = TREE_TYPE_STRING;
    r->number = -1;
    r->string = s;
    r->length = 0;
    r->rule = -1;
    r->child = NULL;
    return r;
}

astree * astint_make(int n)
{
    astree * r = (astree *) malloc(sizeof(astree));
    r->type = TREE_TYPE_INT;
    r->number = n;
    r->string = NULL;
    r->length = 0;
    r->rule = -1;
    r->child = NULL;
    return r;
}


astree * astnode_make(int h, size_t len)
{
    astree * r = (astree *) malloc(sizeof(astree));
    r->type = TREE_TYPE_NODE;
    r->number = -1;
    r->string = NULL;
    r->length = len;
    r->rule = h;
    r->child = (astree **) malloc((len + (len == 0))*sizeof(astree *));
    return r;
}


void ast_clear(astree * r)
{
    if (r->type == TREE_TYPE_STRING)
    {
        free(r->string);
    }
    else if (r->type == TREE_TYPE_NODE)
    {
        for (size_t i = 0; i < r->length; i++)
        {
            ast_clear(r->child[i]);
        }
        free(r->child);
    }

    free(r);
}


astree * astnode_make0(int h)
{
    astree * r = astnode_make(h, 0);
    return r;
}

astree * astnode_make1(int h, astree * a1)
{
    astree * r = astnode_make(h, 1);
    r->child[0] = a1;
    return r;
}

astree * astnode_make2(int h, astree * a1, astree * a2)
{
    astree * r = astnode_make(h, 2);
    r->child[0] = a1;
    r->child[1] = a2;
    return r;
}

astree * astnode_make3(int h, astree * a1, astree * a2, astree * a3)
{
    astree * r = astnode_make(h, 3);
    r->child[0] = a1;
    r->child[1] = a2;
    r->child[2] = a3;
    return r;
}

astree * astnode_make4(int h, astree * a1, astree * a2, astree * a3, astree * a4)
{
    astree * r = astnode_make(h, 4);
    r->child[0] = a1;
    r->child[1] = a2;
    r->child[2] = a3;
    r->child[3] = a4;
    return r;    
}

astree * astnode_append(astree * x, astree * a)
{
    astree * r = astnode_make(x->rule, x->length + 1);
    for (size_t i = 0; i < x->length; i++)
    {
        r->child[i] = x->child[i];
    }
    r->child[x->length] = a;
    free(x);
    return r;
}

astree * astnode_prepend(astree * x, astree * a)
{
    astree * r = astnode_make(x->rule, x->length + 1);
    r->child[0] = a;
    for (size_t i = 0; i < x->length; i++)
    {
        r->child[i + 1] = x->child[i];
    }
    free(x);
    return r;
}


jl_value_t * make_jl_tree(astree * a)
{
    if (a->type == TREE_TYPE_INT)
    {
        return jl_box_int64(a->number);
    }
    else if (a->type == TREE_TYPE_STRING)
    {
        return jl_cstr_to_string(a->string);
    }

    jl_value_t ** args;
    JL_GC_PUSHARGS(args, a->length + 1);
    args[0] = jl_box_int64(a->rule);
    for (size_t i = 0; i < a->length; i++)
    {
        args[i + 1] = make_jl_tree(a->child[i]);
    }
    JL_GC_POP();

    return jl_call(mjl_make_fxn, args, a->length + 1);
}


jl_value_t * singular_parse(
    const char * s,
    const char ** names,
    size_t length)
{
    stringlist_init(&prev_newstruct_names);
    stringlist_init(&new_newstruct_names);
    for (size_t i = 0; i < length; i++)
        stringlist_insert(&prev_newstruct_names, names[i]);

    jl_value_t * mod = (jl_value_t *) jl_eval_string("SingularInterpreter");
    mjl_make_fxn = jl_get_function((jl_module_t *) mod, "AstNodeMake");


/*
    mjl_make_fxn = jl_get_function(jl_main_module, "AstNodeMake");
*/
    JL_GC_PUSH1(&mjl_make_fxn);

    astree * retv = NULL;
    yy_scan_string(s);
    yyparse(&retv);

    jl_value_t * r;
    if (retv == NULL)
    {
        r = jl_cstr_to_string("syntax/parser error you/I dummy");
    }
    else
    {
        astree * strings = astnode_make0(-1);
        stringlist_node * n = new_newstruct_names.first;
        while (n != NULL)
        {
            strings = astnode_append(strings, aststring_make(duplicate_string(n->string)));
            n = n->next;
        }
        retv = astnode_make2(-1, retv, strings);
        r = make_jl_tree(retv);
        ast_clear(retv);
    }
    JL_GC_POP();

    stringlist_clear(&prev_newstruct_names);
    stringlist_clear(&new_newstruct_names);
    return r;
}

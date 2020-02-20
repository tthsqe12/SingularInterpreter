#include "jlcxx/jlcxx.hpp"
#include "includes.h"

typedef ssize_t jint; // julia Int

// for calling interpreter routines from SingularInterpreter

static const char* lv_string_names[3] = {"", "__string_name_1", "__string_name_2"};

// idhdl == idrec* (cf. idrec.h)
static idhdl string_idhdls[3] = {NULL, NULL, NULL};

static idhdl string_idhdl(int i) {
    assert(1 <= i && i <=2);
    idhdl x = string_idhdls[i];
    if (x == NULL) {
        x = IDROOT->set(lv_string_names[i], 0, STRING_CMD, false);
        string_idhdls[i] = x;
    }
    return x;
}

/*
  the following could be used to "mirror" types between C++ & Julia
  it's unfortunately unconvenient, because of some restrictions:
  + we want a `mutable struct` for sleftv on the Julia side, as it's big and we want
    mutation for convenience
  + but then Julia arrays use boxed values, and it's not easy to mirror on the Julia side
    a heap-allocated array created on the c++ side
  + moreover, unsafe_load creates copies, so it's not possible to mutate in Julia a value
    which was sent to Julia as a pointer

namespace jlcxx
{
 template<> struct IsImmutable<leftv> : std::true_type {};
 template<> struct IsBits<leftv> : std::true_type {};

 template<> struct IsBits<sleftv> : std::true_type {};
}

// to put in singular_define_sleftv_bridge:
jlcxx::static_type_mapping<sleftv>::set_julia_type((jl_datatype_t*)jlcxx::julia_type("Sleftv_"));
jlcxx::static_type_mapping<leftv>::set_julia_type((jl_datatype_t*)jlcxx::julia_type("Leftv_"));
*/

// hack to work around private members from bigintmat
struct bigintmat_twin
{
   coeffs m_coeffs;
   number *v;
   int row;
   int col;
};

static void singular_define_table_h(jlcxx::Module & Singular);

void init_sleftv(leftv lv, void* data, int type) {
    lv->Init();
    lv->data = data;
    lv->rtyp = type;
}
void singular_define_sleftv_bridge(jlcxx::Module & Singular) {

    Singular.add_type<sleftv>("Sleftv");

    Singular.method("sleftv_init", [](leftv lv) { return lv->Init(); });
    Singular.method("sleftv_type", [](leftv lv) { return lv->Typ(); });
    Singular.method("sleftv_type", [](leftv lv, int typ) { lv->rtyp = typ; });
    Singular.method("sleftv_data", [](leftv lv) { return lv->Data(); });
    Singular.method("sleftv_data", [](leftv lv, void* data) { lv->data = data; });
    Singular.method("sleftv_next", [](leftv lv) { return lv->next; });
    Singular.method("sleftv_next", [](leftv lv, leftv next) { lv->next = next; });
    Singular.method("sleftv_at", [](leftv lv, int i) { return lv + i; });
    Singular.set_const("sleftv_sizeof", sizeof(sleftv));

    // can't be a constant, because at the time of module initialization, the constant is invalid
    // it could also be created on the Julia side via:
    // coeffs_BIGINT = libSingular.nInitChar(libSingular.n_Q, Ptr{Nothing}(0))
    Singular.method("coeffs_BIGINT", []{ return coeffs_BIGINT; });

    Singular.method("rCopy", &rCopy);

    Singular.method("set_sleftv_string",
                    [](leftv lv, const std::string& x, bool withname) {
                        // TODO (or not): avoid copying this poor string 2 or 3 times

                        if (withname) {
                            idhdl id = string_idhdl(1); // TODO: fix this 1 !! so that it's not overwritten in the same call
                                                        // (for now only one argument can use this, so it's temporarily safe)
                            IDDATA(id) = omStrDup(x.c_str());
                            init_sleftv(lv, id, IDHDL);
                            lv->name = id->id; // Hans says it's necessary to have the name both in the
                                               // idhdl and as the name field of the sleftv, but they can
                                               // be the same pointer
                        }
                        else
                            init_sleftv(lv, (void*)omStrDup(x.c_str()), STRING_CMD);
                    });

    // for `Vector{Int}`
    Singular.method("set_sleftv_intvec",
                    [](leftv lv, jlcxx::ArrayRef<ssize_t> a, bool ismatrix, int d1, int d2) {
                        assert(d1 * d2 == a.size());
                        assert(ismatrix || d2 == 1);

                        intvec *iv; // cannot use a global intvec, Singular
                                    // then sometimes tries to de-allocate it
                        if (ismatrix) {
                            iv = new intvec(d1, d2, 0);
                            // iv and a use row-major and column-major formats respectively
                            for (int i=0, i2=1; i2<=d2; ++i2)
                                for (int i1=1; i1<=d1; ++i1)
                                    IMATELEM(*iv, i1, i2) = a[i++];
                        }
                        else {
                            iv = new intvec(d1);
                            for (int i=0; i<a.size(); ++i)
                                (*iv)[i] = a[i];
                        }
                        init_sleftv(lv, iv, ismatrix ? (int)INTMAT_CMD : (int)INTVEC_CMD);
                    });

    Singular.method("set_sleftv_bigintmat",
                    [](leftv lv, jlcxx::ArrayRef<jl_value_t*> a, int d1, int d2) {
                        assert(d1 * d2 == a.size());
                        assert(d1 >= 0 && d2 >= 0);

                        auto bim_ = new bigintmat_twin; // we initialize by hand do avoid useless
                                                        // zero-initialization
                        // cf. bigintmat.h
                        bim_ -> m_coeffs = coeffs_BIGINT;
                        bim_ -> row = d1;
                        bim_ -> col = d2;
                        int l = d1 * d2;
                        bim_ -> v = (number *)omAlloc(sizeof(number)*l);
                        auto bim = reinterpret_cast<bigintmat*>(bim_);
                        for (int i = 0, i2=1; i2 <= d2; ++i2)
                            for (int i1=1; i1 <= d1; ++i1) {
                                auto b = reinterpret_cast<__mpz_struct*>(a[i++]);
                                BIMATELEM(*bim, i1, i2) = n_InitMPZ(b, coeffs_BIGINT);
                            }
                        init_sleftv(lv, bim, BIGINTMAT_CMD);
                    });

    Singular.method("set_sleftv_list",
                    [](leftv lv, jint len) {
                        slists* list = (lists)omAllocBin(slists_bin); // segfaults with: `new slists`
                        list->Init(len);
                        init_sleftv(lv, list, LIST_CMD);
                        return list->m;
                    });

    Singular.method("lvres_array_get_dims",
                    [] (void* data, int type){
                        jint r, c;
                        intvec *iv;
                        bigintmat *bim;
                        switch (type) {
                        case INTVEC_CMD:
                        case INTMAT_CMD:
                            iv = (intvec*)data;
                            r = iv->rows();
                            c = iv->cols();
                            break;
                        case BIGINTMAT_CMD:
                            bim = (bigintmat*)data;
                            r = bim->rows();
                            c = bim->rows();
                            break;
                        default:
                            assert(false);
                        }
                        return std::make_tuple(r, c);
                    });

    Singular.method("lvres_to_jlarray",
                    [](jlcxx::ArrayRef<ssize_t> a, void* data, int type) {
                        assert(type == INTVEC_CMD || type == INTMAT_CMD);
                        intvec &iv = *(intvec*)data;
                        assert(a.size() == iv.length());
                        int d1 = iv.rows(), d2 = iv.cols();
                        if (type == INTMAT_CMD)
                            for (int i=0, i2=1; i2<=d2; ++i2)
                                for (int i1=1; i1<=d1; ++i1)
                                    a[i++] = IMATELEM(iv, i1, i2);
                        else
                            for (int i=0; i<iv.length(); ++i)
                                a[i] = iv[i];
                    });

    Singular.method("lvres_bim_get_elt_ij",
                    [](void* data, int type, int i, int j) {
                        assert(type == BIGINTMAT_CMD);
                        bigintmat &bim = *(bigintmat*)data;
                        assert(1 <= i && i <= bim.rows() &&
                               1 <= j && j <= bim.cols());
                        return (void*)BIMATELEM(bim, i, j);
                    });

    Singular.method("internal_void_to_lists",
                    [](void* data) {
                        lists l = (lists)data;
                        return std::make_tuple((jint)(l->nr + 1), l->m);
                    });

    Singular.method("iiExprArith1",
                    [](int op, leftv res, leftv lv) {
                        int err = iiExprArith1(res, lv, op);
                        if (err)
                            errorreported = 0;
                        return err;
                    });

    Singular.method("iiExprArith2",
                    [](int op, leftv res, leftv lv1, leftv lv2) {
                        // TODO: check what is the default proccall argument
                        int err = iiExprArith2(res, lv1, op, lv2);
                        if (err)
                            errorreported = 0;
                        return err;
                    });

    Singular.method("iiExprArith3",
                    [](int op, leftv res, leftv lv1, leftv lv2, leftv lv3) {
                        int err = iiExprArith3(res, op, lv1, lv2, lv3);
                        if (err)
                            errorreported = 0;
                        return err;
                    });

    Singular.method("iiExprArithM",
                    [](int op, leftv res, leftv lvs) {
                        int err = iiExprArithM(res, lvs, op);
                        if (err)
                            errorreported = 0;
                        return err;
                    });

    Singular.method("rChangeCurrRing", [](ring r) {
                                           ring old = currRing;
                                           rChangeCurrRing(r);
                                           return old;
                                       });

    Singular.method("clear_currRing", [] { rChangeCurrRing(NULL); });

    Singular.method("internal_void_to_ideal_helper",
                      [](void *x) { return reinterpret_cast<ideal>(x); });

    Singular.method("internal_void_to_matrix_helper",
                      [](void *x) { return reinterpret_cast<matrix>(x); });

    Singular.method("internal_void_to_number_helper",
                      [](void *x) { return reinterpret_cast<number>(x); });

    Singular.method("internal_to_void_helper",
                      [](ring x) { return reinterpret_cast<void*>(x); });

    Singular.method("allocate_sleftv_array",
                    [](jlcxx::ArrayRef<void*> a) {
                        int sz = a.size();
                        // TODO: this is leaking memory, but doesn't matter if
                        // allocated only once per session; still decide whether
                        // a static array on the c++ side is better
                        auto slvs = new sleftv[sz];
                        for (int i=0; i<sz; ++i)
                            a[i] = &slvs[i];
                    });

    singular_define_table_h(Singular);
}

// below: only singular_define_table_h stuff

#define IPARITH // necessary in order for table.h to include its content

// macros we here don't care about
#define D(x) NULL

#define ALLOW_LP 0
#define ALLOW_NC 0
#define ALLOW_PLURAL 0
#define ALLOW_RING 0
#define ALLOW_ZZ 0
#define NO_CONVERSION 0
#define NO_NC 0
#define NO_RING 0
#define NO_ZERODIVISOR 0
#define NULL_VAL 0
#define WARN_RING 0

#define jjWRONG NULL
#define jjWRONG2 NULL
#define jjWRONG3 NULL

struct sValCmd1
{
  proc1 p;
  short cmd;
  short res;
  short arg;
  short valid_for;
};

typedef BOOLEAN (*proc2)(leftv,leftv,leftv);

struct sValCmd2
{
  proc2 p;
  short cmd;
  short res;
  short arg1;
  short arg2;
  short valid_for;
};

typedef BOOLEAN (*proc3)(leftv,leftv,leftv,leftv);

struct sValCmd3
{
  proc3 p;
  short cmd;
  short res;
  short arg1;
  short arg2;
  short arg3;
  short valid_for;
};

struct sValCmdM
{
  proc1 p;
  short cmd;
  short res;
  short number_of_args; /* -1: any, -2: any >0, .. */
  short valid_for;
};

typedef void *   (*iiConvertProc)(void * data);
typedef void    (*iiConvertProcL)(leftv out,leftv in);

struct sConvertTypes
{
  int i_typ;
  int o_typ;
  iiConvertProc p;
  iiConvertProcL pl;
};

#include <Singular/table.h>

static void singular_define_table_h(jlcxx::Module & Singular) {
    Singular.method("dArith1",
                    [](int i) {
                        sValCmd1 r = dArith1[i];
                        return std::make_tuple((jint)r.cmd, (jint)r.res, (jint)r.arg);
                    });

    Singular.method("dArith2",
                    [](int i) {
                        sValCmd2 r = dArith2[i];
                        return std::make_tuple((jint)r.cmd, (jint)r.res, (jint)r.arg1, (jint)r.arg2);
                    });

    Singular.method("dArith3",
                    [](int i) {
                        sValCmd3 r = dArith3[i];
                        return std::make_tuple((jint)r.cmd, (jint)r.res,
                                               (jint)r.arg1, (jint)r.arg2, (jint)r.arg3);
                    });

    Singular.method("dArithM",
                    [](int i) {
                        sValCmdM r = dArithM[i];
                        return std::make_tuple((jint)r.cmd, (jint)r.res,
                                               (jint)r.number_of_args);
                    });

    Singular.method("dConvertTypes",
                    [](int i) {
                        sConvertTypes r = dConvertTypes[i];
                        return std::make_tuple((jint)r.i_typ, (jint)r.o_typ);
                    });
}

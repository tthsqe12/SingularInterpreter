#include "jlcxx/jlcxx.hpp"
#include "includes.h"

typedef ssize_t jint; // julia Int

// for calling interpreter routines from SingularInterpreter
static sleftv lv1;
static sleftv lv2;
static sleftv lvres;

static const char* lv_string_names[3] = {"", "__string_name_1", "__string_name_2"};

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

static void singular_define_table_h(jlcxx::Module & Singular);

void singular_define_sleftv_bridge(jlcxx::Module & Singular) {

    Singular.method("set_leftv_arg_i", [](jint x, int i) {
                                           assert(0 <= i && i <= 2);
                                           auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                                           lv.Init();
                                           lv.data = (void*)x;
                                           lv.rtyp = INT_CMD;
                                       });

    Singular.method("set_leftv_arg_i", [](poly x, int type, int i, bool copy) {
                                           assert(0 <= i && i <= 2);
                                           assert(type == POLY_CMD || type == VECTOR_CMD);
                                           auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                                           lv.Init();
                                           lv.data = copy ? pCopy(x) : x;
                                           lv.rtyp = type;
                                       });

    Singular.method("set_leftv_arg_i", [](ideal x, int type, int i, bool copy) {
                                           assert(0 <= i && i <= 2);
                                           assert(type == IDEAL_CMD);
                                           auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                                           lv.Init();
                                           lv.data = copy ? idCopy(x) : x;
                                           lv.rtyp = IDEAL_CMD;
                                       });

    Singular.method("set_leftv_arg_i",
                    [](number x, int type, int i, bool copy) {
                        assert(0 <= i && i <= 2);
                        assert(type == NUMBER_CMD);
                        auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                        lv.Init();
                        lv.data = copy ? nCopy(x) : x;
                        lv.rtyp = NUMBER_CMD;
                    });

    Singular.method("set_leftv_arg_i",
                    [](ring x, int i, bool copy) {
                        assert(0 <= i && i <= 2);
                        auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                        lv.Init();
                        lv.data = (void*)(copy ? rCopy(x) : x);
                        lv.rtyp = RING_CMD;
                    });

    // experimental
    Singular.method("set_leftv_arg_i", [](void *x, int i, bool copy) {
                                           assert(0 <= i && i <= 2);
                                           assert(!copy);
                                           auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                                           lv.Init();
                                           lv.data = x;
                                           lv.rtyp = ANY_TYPE;
                                       });


    Singular.method("set_leftv_arg_i",
                    [](const std::string& x, int i, bool withname) {
                        // TODO (or not): avoid copying this poor string 2 or 3 times
                        assert(0 <= i && i <= 2);
                        auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                        lv.Init();
                        if (withname) {
                            idhdl id = string_idhdl(i);
                            IDDATA(id) = omStrDup(x.c_str());
                            lv.data = id;
                            lv.name = id->id; // Hans says it's necessary to have the name both in the
                                              // idhdl and as the name field of the sleftv, but they can
                                              // be the same pointer
                            lv.rtyp = IDHDL;
                        }
                        else {
                            lv.data = (void*)(omStrDup(x.c_str()));
                            lv.rtyp = STRING_CMD;
                        }
                    });


    // for `Vector{Int}`
    Singular.method("set_leftv_arg_i",
                    [](jlcxx::ArrayRef<ssize_t> a, bool ismatrix, int d1, int d2, int i) {
                        assert(1 <= i && i <= 2);
                        assert(d1 * d2 == a.size());
                        assert(ismatrix || d2 == 1);
                        auto &lv = i == 0 ? lvres : i == 1 ? lv1 : lv2;
                        lv.Init();
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
                        lv.data = (void*)iv;
                        lv.rtyp = ismatrix ? (int)INTMAT_CMD : (int)INTVEC_CMD;
                    });

    // TODO: check if lvres must be somehow de-allocated / does not leak
    Singular.method("get_leftv_res",
                    [](bool clear_curr_ring) {
                        void *res = (void*)lvres.Data();
                        int t = lvres.Typ();
                        if (clear_curr_ring)
                            rChangeCurrRing(NULL); // must happen *after* lvres.Data(), as
                                                   // this can check for its validity
                        return std::make_tuple(t, res);
                    });

    Singular.method("get_leftv_res_next",
                    [](void *next) {
                        if (next == NULL) // start the iteration
                            next = &lvres;
                        leftv lvres_next = (leftv)next;
                        auto r = std::make_tuple(lvres_next->Typ(), lvres_next->Data(), (void*)lvres_next->next);
                        if (lvres_next->next == NULL)
                            rChangeCurrRing(NULL);
                        return r;
                    });

    Singular.method("lvres_array_get_dim",
                    [](int d) {
                        assert(1 <= d && d <= 2);
                        assert(lvres.rtyp == INTVEC_CMD || lvres.rtyp == INTMAT_CMD);
                        intvec *iv = (intvec*)lvres.data;
                        return d == 1 ? iv->rows() : iv->cols();
                    });

    Singular.method("lvres_to_jlarray",
                    [](jlcxx::ArrayRef<ssize_t> a){
                        assert(lvres.rtyp == INTVEC_CMD || lvres.rtyp == INTMAT_CMD);
                        intvec &iv = *(intvec*)lvres.data;
                        assert(a.size() == iv.length());
                        int d1 = iv.rows(), d2 = iv.cols();
                        if (lvres.rtyp == INTMAT_CMD)
                            for (int i=0, i2=1; i2<=d2; ++i2)
                                for (int i1=1; i1<=d1; ++i1)
                                    a[i++] = IMATELEM(iv, i1, i2);
                        else
                            for (int i=0; i<iv.length(); ++i)
                                a[i] = iv[i];
                        rChangeCurrRing(NULL);
                    });

    Singular.method("list_length", [](void* data) {
                                             lists l = (lists)data;
                                             return (jint)(l->nr+1);
                                         });

    Singular.method("list_elt_i",
                    [](void* data, int i) {
                        assert(lvres.rtyp == LIST_CMD);
                        lists l = (lists)data;
                        assert(0 < i && i <= l->nr+1);
                        sleftv &e = l->m[i-1];
                        void *d;
                        int t;
                        if (e.rtyp == IDEAL_CMD)
                            d = (void*)idCopy((ideal)e.data);
                        else if (e.rtyp == INTMAT_CMD)
                            d = (void*)ivCopy((intvec*)e.data);
                        else
                            d = (void*)NULL;
                        return std::make_tuple(e.rtyp, d);
                    });

    Singular.method("iiExprArith1",
                    [](int op) {
                        int err = iiExprArith1(&lvres, &lv1, op);
                        if (err) {
                            errorreported = 0;
                            rChangeCurrRing(NULL); // done somewhere else when !err
                        }
                        return err;
                    });

    Singular.method("iiExprArith2",
                    [](int op) {
                        // TODO: check what is the default proccall argument
                        int err = iiExprArith2(&lvres, &lv1, op, &lv2);
                        if (err) {
                            errorreported = 0;
                            rChangeCurrRing(NULL);
                        }
                        return err;
                    });

    Singular.method("rChangeCurrRing", [](ring r) {
                                           ring old = currRing;
                                           rChangeCurrRing(r);
                                           return old;
                                       });

    Singular.method("internal_void_to_ideal_helper",
                      [](void *x) { return reinterpret_cast<ideal>(x); });

    Singular.method("internal_void_to_number_helper",
                      [](void *x) { return reinterpret_cast<number>(x); });

    Singular.method("internal_to_void_helper",
                      [](ring x) { return reinterpret_cast<void*>(x); });

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

#include <Singular/table.h>

static void singular_define_table_h(jlcxx::Module & Singular) {
    Singular.method("dArith1",
                    [](int i) {
                        sValCmd1 r = dArith1[i];
                        return std::make_tuple((jint)r.cmd, (jint)r.res, (jint)r.arg);
                    });

}

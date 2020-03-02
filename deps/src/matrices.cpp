#include "matrices.h"

void singular_define_matrices(jlcxx::Module & Singular)
{
    Singular.method("mpNew", &mpNew);

    Singular.method("ncols", [](matrix I) { return (int)MATCOLS(I); });

    Singular.method("nrows", [](matrix I) { return (int)MATROWS(I); });

    Singular.method("id_Matrix2Module", [](ideal M, ring r) {
        return id_Matrix2Module((matrix)M, r);
    });
    Singular.method("id_Matrix2Module", [](matrix M, ring r) {
        return id_Matrix2Module(M, r);
    });

    Singular.method("id_Module2Matrix", &id_Module2Matrix);

    Singular.method("mp_getindex", [](matrix M, int i, int j) {
        return (poly)MATELEM(M, i, j);
    });

    Singular.method("mp_setindex", [](matrix M, int i, int j, poly p, ring r) {
        p_Delete(&MATELEM(M, i, j), r);
        MATELEM(M, i, j) = p;
    });

    /* v seems to be unaltered by this operation */
    Singular.method("mp_from_vector", [](poly v, ring r) {
        matrix m=(matrix)id_Vec2Ideal(v, r);
        int h=MATCOLS(m);
        MATCOLS(m)=MATROWS(m);
        MATROWS(m)=h;
        m->rank=h;
        return m;
    });

    Singular.method("mp_from_ideal", [](ideal h) {
        return (matrix) h;
    });

    Singular.method("mp_Copy",
                    [](matrix M, ring R) { return mp_Copy(M, R); });

    Singular.method("mp_Delete",
                    [](matrix M, ring R) { return mp_Delete(&M, R); });

    Singular.method("mp_Add", &mp_Add);

    Singular.method("mp_Sub", &mp_Sub);

    Singular.method("mp_Mult", &mp_Mult);

    Singular.method("mp_Equal", &mp_Equal);

    Singular.method("mp_Equal", [](ideal a, ideal b, ring r) {
        return mp_Equal(reinterpret_cast<matrix>(a), reinterpret_cast<matrix>(b), r);
    });

    Singular.method("iiStringMatrix", [](matrix I, int d, ring o) {
        auto str_ptr = iiStringMatrix(I, d, o);
        std::string s(iiStringMatrix(I, d, o));
        omFree(str_ptr);
        return s;
    });

    Singular.method("mp_zero", [](matrix a, ring r) {
        for (int i = 0; i < a->nrows*a->ncols; i++)
            p_Delete(a->m + i, r);  // sets it back to zero
    });

    /* append b to a starting at index ai; b is completely consumed by this operation */
    Singular.method("mp_append", [](matrix a, int ai, matrix b, ring r) {
        int bi = 0;
        while (ai < a->nrows*a->ncols && bi < b->nrows*b->ncols)
        {
            poly t = a->m[ai];
            a->m[ai] = b->m[bi];
            b->m[bi] = t;
            ai++;
            bi++;
        }
        mp_Delete(&b, r);
        return ai;
    });

    Singular.method("syInit", []() {
        return (ssyStrategy *) omAlloc0(sizeof(ssyStrategy));
    });

    Singular.method("syCopy", &syCopy);

    Singular.method("syKillComputation", &syKillComputation);

    Singular.method("syPrint", [](syStrategy a, ring r, const std::string rname) {
        SPrintStart();
        const ring origin = currRing;
        rChangeCurrRing(r);
        syPrint(a, rname.c_str());
        rChangeCurrRing(origin);
        char * s = SPrintEnd();
        std::string S(s);
        omFree(s);
        return S;
    });
}

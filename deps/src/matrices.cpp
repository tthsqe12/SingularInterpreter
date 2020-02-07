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

    Singular.method("mp_getindex", [](matrix M, int i, int j) {
        return (poly)MATELEM(M, i, j);
    });

    Singular.method("mp_setindex", [](matrix M, int i, int j, poly p, ring r) {
        p_Delete(&MATELEM(M, i, j), r);
        MATELEM(M, i, j) = p;
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
}

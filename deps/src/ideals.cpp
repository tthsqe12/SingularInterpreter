#include "ideals.h"

auto id_sres_helper(sip_sideal * m, int n, ring R)
{
    auto origin = currRing;
    rChangeCurrRing(R);
    syStrategy s = sySchreyer(m, n);
    rChangeCurrRing(origin);
    auto r = s->minres;
    bool minimal = true;
    if (r == NULL) {
        r = s->fullres;
        minimal = false;
    }
    return std::make_tuple(reinterpret_cast<void *>(r), s->length, minimal);
}


auto id_fres_helper(sip_sideal * I, int n, std::string method, ring R)
{
    auto origin = currRing;
    rChangeCurrRing(R);
    syStrategy s = syFrank(I, n, method.c_str());
    rChangeCurrRing(origin);
    auto r = s->minres;
    bool minimal = true;
    if (r == NULL) {
        r = s->fullres;
        minimal = false;
    }
    return std::make_tuple(reinterpret_cast<void *>(r), s->length, minimal);
}


ideal id_Syzygies_internal(ideal m, ring o)
{
    ideal      id = NULL;
    intvec *   n = NULL;
    tHomog     h = testHomog;
    const ring origin = currRing;
    rChangeCurrRing(o);
    id = idSyzygies(m, h, &n);
    rChangeCurrRing(origin);
    if (n != NULL)
        delete n;
    return id;
}

auto id_Slimgb_helper(ideal a, ring b, bool complete_reduction = false)
{
    //  bool complete_reduction= false;
    unsigned int crbit;
    if (complete_reduction)
        auto crbit = Sy_bit(OPT_REDSB);
    else
        crbit = 0;
    ideal id = NULL;
    if (!idIs0(a)) {
        intvec *     n = NULL;
        tHomog       h = testHomog;
        const ring   origin = currRing;
        unsigned int save_opt = si_opt_1;
        si_opt_1 |= crbit;
        rChangeCurrRing(b);
        id = t_rep_gb(b, a, a->rank);
        si_opt_1 = save_opt;
        rChangeCurrRing(origin);
        if (n != NULL)
            delete n;
    }
    else
        id = idInit(0, a->rank);
    return id;
}

auto id_Std_helper(ideal a, ring b, bool complete_reduction = false)
{
    // bool complete_reduction= false;
    unsigned int crbit;
    if (complete_reduction)
        crbit = Sy_bit(OPT_REDSB);
    else
        crbit = 0;
    ideal id = NULL;
    if (!idIs0(a)) {
        intvec *     n = NULL;
        tHomog       h = testHomog;
        const ring   origin = currRing;
        unsigned int save_opt = si_opt_1;
        si_opt_1 |= crbit;
        rChangeCurrRing(b);
        id = kStd(a, b->qideal, h, &n);
        si_opt_1 = save_opt;
        rChangeCurrRing(origin);
        if (n != NULL)
            delete n;
    }
    else
    {
        id = idInit(0, a->rank);
    }
    idSkipZeroes(id);
    return id;
}


/* 1-based with auto resize */
void id_setindex_fancy(ideal h, int n, poly p, ring r)
{
    if (n <= 0)
        return;
    int old_elems = IDELEMS(h);
    if (n <= old_elems)
    {
        if (h->m[n - 1] != NULL)
            p_Delete(&h->m[n - 1], r);
    }
    else
    {
        poly * old_polys = h->m;
        poly * new_polys = (poly *)omAlloc0(n*sizeof(poly));
        for (int i = 0; i < old_elems; i++)
            new_polys[i] = old_polys[i];
        if (old_elems > 0)
            omFreeSize((ADDRESS)old_polys, sizeof(poly)*old_elems);
        h->m = new_polys;
        IDELEMS(h) = n;
    }
    h->m[n - 1] = p;
};

/* append b to a; b is completely consumed by this operation */
void id_append(ideal a, ideal b, ring r)
{
    int belems = IDELEMS(b);
    int aelems = IDELEMS(a);
    if (belems > 0)
    {
        poly * old_polys = a->m;
        poly * new_polys = (poly *)omAlloc0((aelems + belems)*sizeof(poly));
        for (int i = 0; i < aelems; i++)
            new_polys[i] = old_polys[i];
        if (aelems > 0)
            omFreeSize((ADDRESS)old_polys, sizeof(poly)*aelems);
        for (int i = 0; i < belems; i++)
        {
            new_polys[aelems + i] = b->m[i];
            b->m[i] = NULL;
        }
        a->m = new_polys;
        IDELEMS(a) = aelems + belems;
    }
    id_Delete(&b, r);
    return;
}



void singular_define_ideals(jlcxx::Module & Singular)
{
    Singular.method("id_Delete",
                    [](ideal m, ring n) { return id_Delete(&m, n); });

    Singular.method("id_Copy", &id_Copy);

    Singular.method("idInit", &idInit);

    Singular.method("setindex_internal",
                    [](ideal r, poly n, int o) { return r->m[o] = n; });

    Singular.method("id_setindex_fancy", &id_setindex_fancy);

    /* modules have to keep a bound on the rank */
    Singular.method("mo_setindex_fancy", [](ideal m, int n, poly p, ring r) {
        long maxcomp = 0;
        if ((p!=NULL) && (p_GetComp(p, r)!=0))
            maxcomp = p_MaxComp(p, r);
        id_setindex_fancy(m, n, p, r);
        m->rank=si_max(m->rank,maxcomp);
    });

    /* append b to a; b is completely consumed by this operation */
    Singular.method("id_append", &id_append);

    /* modules have to keep a bound on the rank */
    Singular.method("mo_append", [](ideal a, ideal b, ring r) {
        // maybe just use maxcomp = b->rank ?
        long maxcomp = 0;
        for (int i = 0; i < b->ncols; i++)
        {
            poly p = b->m[i];
            if ((p!=NULL) && (p_GetComp(p, r)!=0))
                maxcomp = si_max(maxcomp, p_MaxComp(p, r));
        }
        id_append(a, b, r);
        a->rank=si_max(a->rank,maxcomp);
    });


    Singular.method("getindex",
                    [](ideal r, int o) { return (poly)(r->m[o]); });

    Singular.method("idIs0", &idIs0);

    Singular.method("id_IsConstant", &id_IsConstant);

    Singular.method("id_IsZeroDim", &id_IsZeroDim);

    Singular.method("idElem", &idElem);

    Singular.method("id_Normalize", &id_Normalize);

    Singular.method("id_Head", &id_Head);

    Singular.method("id_MaxIdeal",
                    [](int m, ring n) { return id_MaxIdeal(m, n); });

    Singular.method("id_Add", &id_Add);

    Singular.method("id_Mult", &id_Mult);

    Singular.method("id_Power", &id_Power);

    Singular.method("id_IsEqual", [](ideal m, ideal n, ring o) {
        return mp_Equal((ip_smatrix *)m, (ip_smatrix *)n, o);
    });

    Singular.method("id_Variables", [](ideal I, ring r) {
        int *e=(int *)omAlloc0((rVar(r)+1)*sizeof(int));
        int n=0;
        for(int i=I->nrows*I->ncols-1;i>=0;i--)
        {
            int n0=p_GetVariables(I->m[i],e,r);
            if (n0>n) n=n0;
        }
        ideal l=idInit(n,1);
        for(int i=rVar(r);i>0;i--)
        {
            if (e[i]>0)
            {
                n--;
                poly p=p_One(r);
                p_SetExp(p,i,1,r);
                p_Setm(p,r);
                l->m[n]=p;
                if (n==0) break;
            }
        }
        omFreeSize((ADDRESS)e,(rVar(r)+1)*sizeof(int));
        return l;
    });

    Singular.method("id_FreeModule", &id_FreeModule);

    Singular.method("idSkipZeroes", &idSkipZeroes);

    Singular.method("id_ncols", [](ideal m) { return m->ncols; });

    Singular.method("ngens", [](ideal m) { return (int)IDELEMS(m); });

    Singular.method("rank", [](ideal m) { return (int)m->rank; });

    Singular.method("id_Quotient", [](ideal a, ideal b, bool c, ring d) {
        const ring origin = currRing;
        rChangeCurrRing(d);
        ideal id = idQuot(a, b, c, TRUE);
        rChangeCurrRing(origin);
        return id;
    });

    Singular.method("id_Intersection", [](ideal a, ideal b, ring c) {
        const ring origin = currRing;
        rChangeCurrRing(c);
        ideal id = idSect(a, b);
        rChangeCurrRing(origin);
        return id;
    });

    Singular.method("id_Syzygies", &id_Syzygies_internal);

    Singular.method("id_sres", &id_sres_helper);

    Singular.method("id_fres", &id_fres_helper);

    Singular.method("id_Slimgb", &id_Slimgb_helper);

    Singular.method("id_Std", &id_Std_helper);

    Singular.method("id_Eliminate", [](ideal m, poly p, ring o) {
        const ring origin = currRing;
        rChangeCurrRing(o);
        ideal res = idElimination(m, p);
        rChangeCurrRing(origin);
        return res;
    });

    Singular.method("id_Satstd", &id_Satstd);

    Singular.method("id_Array2Vector", [](void * p, int a, ring o) {
        return id_Array2Vector(reinterpret_cast<poly *>(p), a, o);
    });

    Singular.method("p_Vector2Array", [](poly p, void * a, int b, ring o) {
        p_Vec2Array(p, reinterpret_cast<poly *>(a), b, o);
    });

    Singular.method("internal_void_to_poly_helper",
                    [](void * p) { return reinterpret_cast<poly>(p); });

    Singular.method(
        "maGetPreimage", [](ring trgt, ideal a, ideal b, ring src) {
            sip_smap sing_map = {a->m, (char *)"julia_ring", 1, a->ncols};
            return maGetPreimage(trgt, &sing_map, b, src);
    });

    Singular.method("id_Jet", [](ideal I, int n, ring r) {
        ideal res = id_Jet(I, n, r);
        return res;
    });

    Singular.method("id_vdim", [](ideal I, ring r) {
        const ring origin = currRing;
        rChangeCurrRing(r);
	int n=scMult0Int(I, r->qideal);
	rChangeCurrRing(origin);
	return n;
    });

    Singular.method("id_kbase", [](ideal I, int n, ring r) {
        ideal res;
	    const ring origin = currRing;
        rChangeCurrRing(r);
        res = scKBase(n, I, r->qideal);
        rChangeCurrRing(origin);
        return res;
    });

    Singular.method("id_highcorner", [](ideal I, ring r) {
        poly h;
        const ring origin = currRing;
        rChangeCurrRing(r);
        h = iiHighCorner(I, 0);
        rChangeCurrRing(origin);
        return h;
    });
    Singular.method("maMapIdeal", [](ideal map_id, ring pr, ideal im_id,
                    ring im) {

        rChangeCurrRing(pr);
        nMapFunc nMap =n_SetMap(currRing->cf, im->cf);
        return maMapIdeal(map_id, pr, im_id, im, nMap);
    });
    Singular.method("idMinBase", [](ideal I, ring r) {
        rChangeCurrRing(r);
        return idMinBase(I);
    });

    Singular.method("maInit", [] (int ncols) {
        map m = (map)idInit(ncols, 1);
        m->preimage = omStrDup("???");
        return m;
    });

    Singular.method("ma_Delete", [](map m, ring r) {
        omFreeBinAddr((ADDRESS)m->preimage);
        m->preimage=NULL;
        id_Delete((ideal*)&m,r);
    });

    Singular.method("maCopy", &maCopy);

    Singular.method("ma_ncols", [](map m) {return m->ncols;});

    Singular.method("ma_getindex0", [](map m, int i) {return m->m[i];});
}

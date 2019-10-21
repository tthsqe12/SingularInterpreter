#include "rings.h"
#include "polys/ext_fields/transext.h"

auto rDefault_helper(coeffs                       cf,
                     jlcxx::ArrayRef<std::string> vars,
                     int                 ord)
{
//printf("rDefault_helper called\n");
    auto    len = vars.size();
    char ** vars_ptr = new char *[len];
    for (int i = 0; i < len; i++) {
        vars_ptr[i] = new char[vars[i].length() + 1];
        std::strcpy(vars_ptr[i], vars[i].c_str());
    }
    auto r = rDefault(cf, len, vars_ptr, (rRingOrder_t)(ord));
    delete[] vars_ptr;
    r->ShortOut = 0;
    return r;
}

auto rDefault_long_helper(coeffs                        cf,
                          jlcxx::ArrayRef<uint8_t *>    vars,
                          jlcxx::ArrayRef<int>          ord,
                          int *                         blk0,
                          int *                         blk1,
                          unsigned long                 bitmask)
{
//printf("rDefault_long_helper called\n");
    auto    len = vars.size();
    char ** vars_ptr = new char *[len];

    for (int i = 0; i < len; i++) {
        vars_ptr[i] = reinterpret_cast<char *>(vars[i]);
        // std::strcpy(vars_ptr[i],vars[i].c_str());
    }
    auto           len_ord = ord.size();
    rRingOrder_t * ord_ptr = (rRingOrder_t *) omAlloc0(len_ord * sizeof(rRingOrder_t));
    for (int i = 0; i < len_ord; i++) {
        ord_ptr[i] = (rRingOrder_t) ord[i];
    }
    int ** wvhdl = NULL;
    auto r = rDefault(cf, len, vars_ptr, len_ord, ord_ptr, blk0, blk1, wvhdl,
                      bitmask);
    delete[] vars_ptr;
    r->ShortOut = 0;
    return r;
}


std::string rPrint_helper(ring r)
{
    SPrintStart();
    // unfortunately we have static BOOLEAN ipPrint_RING in ipprint.cc
    PrintS("polynomial ring, over a ");
    PrintS(!rField_is_Ring(r) ? "field" : 
            rField_is_Domain(r) ? "domain"
                                : "ring (with zero-divisors)");
    PrintS(r->OrdSgn == 1     ? ", global" :
           r->MixedOrder == 1 ? ", mixed"  :
                                ", local");
    PrintS(" ordering\n");
    rWrite(r, TRUE);
    char * s = SPrintEnd();
    std::string S(s);
    omFree(s);
    return S;
}

auto rDefault_weighted_helper(
    coeffs cf,
    jlcxx::ArrayRef<uint8_t *> vars,
    jlcxx::ArrayRef<int> ord_data)
{
    int nvars = vars.size();
    char ** vars_ptr = new char *[nvars];

    for (int i = 0; i < nvars; i++)
        vars_ptr[i] = reinterpret_cast<char *>(vars[i]);

    size_t j = 0;
    int nord = ord_data[j++];

    rRingOrder_t * ord = (rRingOrder_t *) omAlloc0((nord + 1) * sizeof(rRingOrder_t));
    int * blk0 = (int *) omAlloc0((nord + 1) * sizeof(int));
    int * blk1 = (int *) omAlloc0((nord + 1) * sizeof(int));
    int ** wvhdl = (int **) omAlloc0((nord + 1) * sizeof(int *));

    for (int i = 0; i < nord; i++)
    {
        ord[i] = (rRingOrder_t) ord_data[j++];
        blk0[i] = ord_data[j++];
        blk1[i] = ord_data[j++];
        int len = ord_data[j++];
        if (len > 0)
        {
            wvhdl[i] = (int *) omAlloc0(len * sizeof(int));
            for (int k = 0; k < len; k++)
                wvhdl[i][k] = ord_data[j++];
        }
        else
        {
            wvhdl[i] = nullptr;
        }
    }

//printf("rDefault_weighted_helper called with nvars = %d, nord = %d, mask = %d\n", nvars, nord, (1<<15) - 1);

    auto r = rDefault(cf, nvars, vars_ptr, nord, ord, blk0, blk1, wvhdl, (1<<15) - 1);
    delete[] vars_ptr;
    r->ShortOut = 0;

//    rWrite(r, 1); printf("\n");

    return r;
}


coeffs nInitChar_simple_helper(
    int characteristic)
{
//printf("nInitChar_simple_helper called\n");
    return nInitChar(characteristic == 0 ? n_Q : n_Zp, (void*)(long)characteristic);
}


coeffs nInitChar_transcendental_helper(
    int characteristic,
    jlcxx::ArrayRef<uint8_t *> vars)
{
//printf("nInitChar_transcendental_helper called\n");
    int nvars = vars.size();
    char ** vars_ptr = (char **) omAlloc0(nvars*sizeof(char*));
    for (int i = 0; i < nvars; i++)
        vars_ptr[i] = (char *) vars[i];
    TransExtInfo extParam;
    extParam.r = rDefault(characteristic, nvars, vars_ptr);
    omFree(vars_ptr);
    return nInitChar(n_transExt, &extParam);
}

coeffs nInitChar_real_helper(
    int f1,
    int f2)
{
//printf("nInitChar_real_helper called\n");
    if (f2 <= (short)SHORT_REAL_LENGTH)
    {
        return nInitChar(n_R, NULL);
    }
    else
    {
        LongComplexInfo param;
        param.float_len = si_min(f1, 32767);
        param.float_len2 = si_min(f2, 32767);
        return nInitChar(n_long_R, (void*)&param);
    }
}

coeffs nInitChar_complex_helper(
    int f1,
    int f2,
    uint8_t * imag_unit)
{
//printf("nInitChar_complex_helper called\n");
    LongComplexInfo param;
    param.float_len = si_min(f1, 32767);
    param.float_len2 = si_min(f2, 32767);
    if (param.float_len < SHORT_REAL_LENGTH)
    {
        param.float_len = SHORT_REAL_LENGTH;
        param.float_len2 = SHORT_REAL_LENGTH;
    }
    param.par_name = (char *) imag_unit;
    return nInitChar(n_long_C, (void*)&param);
}

std::tuple<int, poly> p_mInit_helper(uint8_t * s, ring r)
{
    BOOLEAN ok = FALSE;
    poly p = p_mInit((char *) s, ok, r);
    return std::make_tuple(ok != FALSE, p);
}


number n_Init_helper(int i, ring r)
{
    return n_Init(i, r->cf);
}

number pGetConstantCoeff_helper(poly p, ring r)
{
    number n = pGetCoeff(p);
    pGetCoeff(p) = NULL;
    p_LmFree(p, r);
    return n;
}

ring rDefault_null_helper()
{
    return NULL;
}

poly p_null_helper()
{
    return NULL;
}

void singular_define_rings(jlcxx::Module & Singular)
{
    Singular.method("toPolyRef", [](void * ptr) {
       return reinterpret_cast<spolyrec*>(ptr);
    });
    Singular.method("rDefault_null_helper", &rDefault_null_helper);
    Singular.method("p_null_helper", &p_null_helper);

    Singular.method("rDefault_helper", &rDefault_helper);
    Singular.method("rDefault_long_helper", &rDefault_long_helper);
    Singular.method("rDefault_weighted_helper", &rDefault_weighted_helper);

    Singular.method("rPrint_helper", &rPrint_helper);

    Singular.method("nInitChar_simple_helper", &nInitChar_simple_helper);
    Singular.method("nInitChar_transcendental_helper", &nInitChar_transcendental_helper);
    Singular.method("nInitChar_real_helper", &nInitChar_real_helper);
    Singular.method("nInitChar_complex_helper", &nInitChar_complex_helper);

    Singular.method("p_mInit_helper", &p_mInit_helper);
    Singular.method("n_Init_helper", [](long i, ring r) {return n_Init(i, r->cf);});
    Singular.method("p_IsConstant", [](poly p, ring r) {return int(p_IsConstant(p, r));});
    Singular.method("pGetConstantCoeff_helper", &pGetConstantCoeff_helper);

    Singular.method("rDelete", &rDelete);
    Singular.method("rString", [](ip_sring * r) {
        auto s = rString(r);
        std::string ret_string(s);
        omFree(s);
        return ret_string;
    });
    Singular.method("rChar", &rChar);
    Singular.method("rGetVar", &rGetVar);
    Singular.method("rVar", &rVar);
    Singular.method("rGetExpSize", [](unsigned long bitmask, int N) {
        int bits;
        return static_cast<unsigned int>(rGetExpSize(bitmask, bits, N));
    });
    Singular.method("rHasGlobalOrdering", &rHasGlobalOrdering);
    Singular.method("rHasMixedOrdering", &rHasMixedOrdering);
    Singular.method("rIsQuotientRing", [](ring r) {

    return r->qideal != NULL;
    });
    Singular.method("rBitmask",
                    [](ip_sring * r) { return (unsigned int)r->bitmask; });
    Singular.method("p_Delete", [](spolyrec * p, ip_sring * r) {
        return p_Delete(&p, r);
    });
    Singular.method("p_Copy",
                    [](spolyrec * p, ip_sring * r) { return p_Copy(p, r); });
    Singular.method("p_IsOne",
                    [](spolyrec * p, ip_sring * r) { return p_IsOne(p, r); });
    Singular.method("p_One", [](ip_sring * r) { return p_One(r); });
    Singular.method("p_IsUnit", [](spolyrec * p, ip_sring * r) {
        return p_IsUnit(p, r);
    });
    Singular.method("p_GetExp", [](spolyrec * p, int i, ip_sring * r) {
        return p_GetExp(p, i, r);
    });
    Singular.method("p_GetComp", [](spolyrec * p, ip_sring * r) {
        return p_GetComp(p, r);
    });
    Singular.method("p_String", [](spolyrec * p, ip_sring * r) {
        auto s_ptr = p_String(p, r);
        std::string s(s_ptr);
        omFree(s_ptr);
        return s;
    });
    Singular.method("p_ISet",
                    [](long i, ip_sring * r) { return p_ISet(i, r); });
    Singular.method("p_NSet",
                    [](snumber * p, ip_sring * r) { return p_NSet(p, r); });
    Singular.method("p_NSet",
                    [](void * p, ip_sring * r) { return p_NSet(reinterpret_cast<snumber*>(p), r); }
    );
    Singular.method("pLength", [](spolyrec * p) { return pLength(p); });
    Singular.method("SetpNext",
                    [](spolyrec * p, spolyrec * q) { p->next = q; });
    Singular.method("pNext", [](spolyrec * a) {
        poly p = pNext(a);
        return p;
    });
    Singular.method("p_Init", [](ip_sring * r) { return p_Init(r); });
    Singular.method("p_Head", [](spolyrec * a, ip_sring * r) {
        poly p = p_Head(a, r); return p; });
    Singular.method("p_SetCoeff0", [](spolyrec * a, snumber * n, ip_sring * r) {
        p_SetCoeff0(a, n, r); });
    Singular.method("p_SetExp", [](spolyrec * a, int i, int v, ip_sring * r) {
        p_SetExp(a, i, v, r); });
    Singular.method("p_SetNext", [](spolyrec * a, spolyrec * m) {
        pNext(a) = m; });
    Singular.method("p_SortMerge", [](spolyrec * a, ip_sring * r) {
        return p_SortMerge(a, r); });
    Singular.method("p_SortAdd", [](spolyrec * a, ip_sring * r) {
        return p_SortAdd(a, r); });
    Singular.method("p_Setm", [](spolyrec * a, ip_sring * r) {
        p_Setm(a, r); });
    Singular.method("p_Neg",
                    [](spolyrec * p, ip_sring * r) { return p_Neg(p, r); });
    Singular.method("pGetCoeff", [](spolyrec * p) { return pGetCoeff(p); });
    Singular.method("pSetCoeff", [](spolyrec * p, long c, ip_sring * r) {
        number n = n_Init(c, r);
        return p_SetCoeff(p, n, r);
    });
    Singular.method("pSetCoeff0", [](spolyrec * p, long c, ip_sring * r) {
        number n = n_Init(c, r);
        return p_SetCoeff0(p, n, r);
    });
    Singular.method("pLDeg", [](spolyrec * a, ip_sring * r) {
        long res;
        int  dummy;
        if (a != NULL) {
            res = r->pLDeg(a, &dummy, r);
        }
        else {
            res = -1;
        }
        return res;
    });
    Singular.method("p_Add_q", [](spolyrec * p, spolyrec * q, ip_sring * r) {
        return p_Add_q(p, q, r);
    });
    Singular.method("p_Sub", [](spolyrec * p, spolyrec * q, ip_sring * r) {
        return p_Sub(p, q, r);
    });
    Singular.method("p_Mult_q", [](spolyrec * p, spolyrec * q, ip_sring * r) {
        return p_Mult_q(p, q, r);
    });
    Singular.method("pp_Mult_qq", [](spolyrec * p, spolyrec * q, ip_sring * r) {
        return pp_Mult_qq(p, q, r);
    });
    Singular.method("p_Power", [](spolyrec * p, int q, ip_sring * r) {
        return p_Power(p, q, r);
    });
    Singular.method("p_EqualPolys",
                    [](spolyrec * p, spolyrec * q, ip_sring * r) {
                        return p_EqualPolys(p, q, r);
                    });
    Singular.method("p_Divide", [](spolyrec * p, spolyrec * q, ip_sring * r) {
        return p_Divide(p, q, r);
    });
    Singular.method("p_DivRem", [](spolyrec * a, spolyrec * b, ip_sring * r) {
       poly rest;
       poly q = p_DivRem(a, b, rest, r);
       return std::make_tuple(reinterpret_cast<void *>(q), reinterpret_cast<void *>(rest));
    });
    Singular.method("p_Div_nn", [](spolyrec * p, snumber * n, ip_sring * r) {
        return p_Div_nn(p, n, r);
    });
    Singular.method("p_IsDivisibleBy", [](spolyrec * p, spolyrec * q, ip_sring * r) {
       poly res;
       ideal I = idInit(1, 1);
       const ring origin = currRing;
       I->m[0] = q;
       rChangeCurrRing(r);
       res = kNF(I, NULL, p, 0, KSTD_NF_LAZY);
       rChangeCurrRing(origin);
       id_Delete(&I, r);
       if (res == NULL)
          return true;
       else
       {
          p_Delete(&res, r);
          return false;
       }
    });
    Singular.method("singclap_gcd",
                    [](spolyrec * p, spolyrec * q, ip_sring * r) {
                        return singclap_gcd(p, q, r);
                    });
    Singular.method("p_ExtGcd_internal", [](spolyrec * a, spolyrec * b,
                                            void * res, void * s, void * t,
                                            ip_sring * r) {
        return singclap_extgcd(a, b, reinterpret_cast<spolyrec *&>(res),
                               reinterpret_cast<spolyrec *&>(s),
                               reinterpret_cast<spolyrec *&>(t), r);
    });
    Singular.method("singclap_sqrfree",
                    [](spolyrec * p, jlcxx::ArrayRef<int> a, ip_sring * r) {
                        rChangeCurrRing(r);
			intvec * v = NULL;
			ideal I = singclap_sqrfree(pCopy(p), &v, 0, currRing);
			int * content = v->ivGetVec();
			for(int i=0; i<v->length(); i++)
			{
			  a.push_back(content[i]);
			}
		        return I;
    });
    Singular.method("singclap_factorize",
                    [](spolyrec * p, jlcxx::ArrayRef<int> a, ip_sring * r) {
                        rChangeCurrRing(r);
			intvec * v = NULL;
			ideal I = singclap_factorize(pCopy(p), &v, 0, currRing);
			int * content = v->ivGetVec();
			for(int i=0; i<v->length(); i++)
			{
			  a.push_back(content[i]);
			}
		        return I;
    });
    Singular.method("p_Content", [](spolyrec * p, ip_sring * r) {
                        return p_Content(p, r);
    });
    Singular.method("p_GetExpVL_internal",
                    [](spolyrec * p, long * ev, ip_sring * r) {
                        return p_GetExpVL(p, ev, r);
                    });
    Singular.method("p_SetExpV_internal",
                    [](spolyrec * p, int * ev, ip_sring * r) {
                        return p_SetExpV(p, ev, r);
                    });
    Singular.method("p_Reduce",
                    [](spolyrec * p, sip_sideal * G, ip_sring * R) {
                        const ring origin = currRing;
                        rChangeCurrRing(R);
                        poly res = kNF(G, R->qideal, p);
                        rChangeCurrRing(origin);
                        return res;
                    });
    Singular.method("p_Reduce",
                    [](sip_sideal * p, sip_sideal * G, ip_sring * R) {
                        const ring origin = currRing;
                        rChangeCurrRing(R);
                        ideal res = kNF(G, R->qideal, p);
                        rChangeCurrRing(origin);
                        return res;
                    });

    Singular.method("letterplace_ring_helper",
                    [](ip_sring * r, long block_size) {
                        rUnComplete(r);
                        r->isLPring = block_size;
                        r->ShortOut = FALSE;
                        r->CanShortOut = FALSE;
                        rComplete(r);
                    });

    Singular.method("p_Subst", [](poly p, int i, poly q, ring r) {
        poly p_cp = p_Copy(p, r);
        return p_Subst(p_cp, i, q, r);
    });
    Singular.method("maEvalAt", [](poly p, jlcxx::ArrayRef<void*> vals, ring r) {
       number * varr = (number *) omAlloc0(vals.size() * sizeof(number));
       for (int i = 0; i < vals.size(); i++)
          varr[i] = (number) vals[i];
       number res = maEvalAt(p, varr, r);
       omFree(varr);
       return res;
    });
    Singular.method("p_PermPoly", [](poly p, int * perm, ring old_ring,
                                     ring new_ring, void * map_func_ptr) {
        nMapFunc map_func = reinterpret_cast<nMapFunc>(map_func_ptr);
        return p_PermPoly(p, perm, old_ring, new_ring, map_func);
    });
   Singular.method("p_Jet",
                   [](poly p, int i, ring r) {
                       poly p_cp = p_Copy(p, r);
                       return p_Jet(p_cp, i, r);
    });
   Singular.method("p_Diff",
                   [](poly p, int i, ring r) {
                       poly p_cp = p_Copy(p, r);
                       return p_Diff(p_cp, i, r);
    });
    Singular.method("maMapPoly",
                   [](poly map_p, ring pr, ideal im_id, ring im) {
                       rChangeCurrRing(pr);
                       nMapFunc nMap =n_SetMap(currRing->cf, im->cf);
                       return maMapPoly(map_p, pr, im_id, im, nMap);
    });
    Singular.method("p_GetOrder",
                   [](poly p, ring r) {
		       long res;
                       if( p != NULL)
		       {  res = p_GetOrder(p, r);}
		       else 
		       {  res = -1;}
		       return res; 
    });
}

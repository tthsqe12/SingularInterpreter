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
    Singular.method("rChangeCurrRing", &rChangeCurrRing);

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

    Singular.method("rGetShortOut", [](ring r) {
        return r->ShortOut;
    });

    Singular.method("rSetShortOut", [](ring r, ssize_t a) {
        BOOLEAN shortOut = (BOOLEAN)(a);
        if (shortOut==0)
          r->ShortOut = 0;
        else
        {
          if (r->CanShortOut)
            r->ShortOut = 1;
        }
        shortOut = r->ShortOut;
        coeffs cf = r->cf;
        while (nCoeff_is_Extension(cf))
        {
          cf->extRing->ShortOut = shortOut;
          cf = cf->extRing->cf;
        }
    });

    Singular.method("rGetNoether", [](ring r) {
        return p_Copy(r->ppNoether, r);
    });

    Singular.method("rSetNoether", [](ring r, poly p) {
        p_Delete(&r->ppNoether, r);
        r->ppNoether = p;
    });

    Singular.method("rGetMinpoly", [](ring r) {
        if (nCoeff_is_algExt(r->cf) && !nCoeff_is_GF(r->cf))
        {
            const ring A = r->cf->extRing;
            return reinterpret_cast<number>(p_Copy(A->qideal->m[0], A));
        }
        else
        {
            return n_Init(0, r->cf);
        }
    });

    Singular.method("rSetMinpoly", [](ring r, number a) {

        if (!nCoeff_is_transExt(r->cf) && (r->idroot == NULL) && n_IsZero(a, r->cf))
        {
            return 0;
        }

        if (!nCoeff_is_transExt(r->cf) )
        {
            WarnS("Trying to set minpoly over non-transcendental ground field...");
            if(!nCoeff_is_algExt(r->cf) )
            {
                WerrorS("cannot set minpoly for these coeffients");
                return 1;
            }
        }

        if (rVar(r->cf->extRing) != 1 && !n_IsZero(a, r->cf))
        {
            WerrorS("only univarite minpoly allowed");
            return 2;
        }

        BOOLEAN redefine_from_algext = FALSE;
        if (r->idroot != NULL)
        {
            redefine_from_algext = r->cf->extRing->qideal != NULL;
        }

        number p = n_Copy(a, r);
        n_Normalize(p, r);

        if (n_IsZero(p, r->cf))
        {
            n_Delete(&p, r->cf);
            if (nCoeff_is_transExt(r->cf))
            {
                return FALSE;
            }
            WarnS("cannot set minpoly to 0 / alg. extension?");
            return 3;
        }

        // remove all object currently in the ring
        while (r->idroot != NULL)
        {
            killhdl2(r->idroot, &(r->idroot), r);
        }

        AlgExtInfo A;

        A.r = rCopy(r->cf->extRing); // Copy  ground field!
        // if minpoly was already set:
        if (r->cf->extRing->qideal != NULL)
            id_Delete(&A.r->qideal, A.r);
        ideal q = idInit(1,1);
        if (p == NULL || NUM((fraction)p) == NULL)
        {
            WerrorS("Could not construct the alg. extension: minpoly==0");
            // cleanup A: TODO
            rDelete( A.r );
            return 4;
        }
        if (!redefine_from_algext && (DEN((fraction)(p)) != NULL)) // minpoly must be a fraction with poly numerator...!!
        {
            poly n = DEN((fraction)(p));
            if (!p_IsConstantPoly(n, r->cf->extRing))
            {
                WarnS("denominator must be constant - ignoring it");
            }
            p_Delete(&n, r->cf->extRing);
            DEN((fraction)(p)) = NULL;
        }

        if (redefine_from_algext)
            q->m[0] = (poly)p;
        else
            q->m[0] = NUM((fraction)p);
        A.r->qideal = q;

        // :(
        //  NUM((fractionObject *)p) = NULL; // makes 0/ NULL fraction - which should not happen!
        //  n_Delete(&p, r->cf); // doesn't expect 0/ NULL :(
        if (!redefine_from_algext)
        {
            EXTERN_VAR omBin fractionObjectBin;
            NUM((fractionObject *)p) = NULL; // not necessary, but still...
            omFreeBin((ADDRESS)p, fractionObjectBin);
        }

        coeffs new_cf = nInitChar(n_algExt, &A);
        if (new_cf == NULL)
        {
            WerrorS("Could not construct the alg. extension: llegal minpoly?");
            // cleanup A: TODO
            rDelete(A.r);
            return 5;
        }
        else
        {
            nKillChar(r->cf);
            r->cf = new_cf;
        }
        return 0;
    });

    Singular.method("new_qring", [](ideal id, ring r) {

        coeffs newcf = r->cf;
        const int cpos = id_PosConstant(id, r);

        if(rField_is_Ring(r))
        {
            if (cpos >= 0)
            {
                newcf = n_CoeffRingQuot1(p_GetCoeff(id->m[cpos], r), r->cf);
                if (newcf == NULL)
                    return reinterpret_cast<ring>(NULL);
            }
        }

        ring qr = rCopy(r);
        assume(qr->cf == r->cf);

        if ( qr->cf != newcf )
        {
            nKillChar(qr->cf);
            qr->cf = newcf;
        }

        ideal qid;

        if ((rField_is_Ring(r)) && (cpos != -1))
        {
            int i, j;
            int *perm = (int *)omAlloc0((qr->N+1)*sizeof(int));

            for(i=qr->N;i>0;i--)
                perm[i]=i;

            nMapFunc nMap = n_SetMap(r->cf, newcf);
            qid = idInit(IDELEMS(id)-1,1);
            for (i = 0, j = 0; i<IDELEMS(id); i++)
                if (i != cpos)
                    qid->m[j++] = p_PermPoly(id->m[i], perm, r, qr, nMap, NULL, 0);
        }
        else
        {
            qid = idrCopyR(id,r,qr);
        }

        idSkipZeroes(qid);
/*
        if ((idElem(qid)>1) || rIsSCA(r) || (r->qideal!=NULL))
            assumeStdFlag(a);
*/
        if (r->qideal!=NULL) /* we are already in a qring! */
        {
            ideal tmp = id_SimpleAdd(qid, r->qideal, r);
            id_Delete(&qid, r);
            qid = tmp;
            id_Delete(&qr->qideal, r);
        }

        qr->qideal = qid;
        if (idElem(qid) == 0)
            id_Delete(&qr->qideal, r);

        return qr;
    });


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

    Singular.method("p_SetCompP", [](poly p, int i, ring r) {
        p_SetCompP(p, i, r);
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
    Singular.method("p_DegW", [](spolyrec * a, jlcxx::ArrayRef<ssize_t> iv, ip_sring * r) {
        long res;
        int  dummy;
        if (a != NULL) {
            short * s = (short *)omAlloc0((rVar(r)+1)*sizeof(short));
            int len=0;
            len=si_min(int(iv.size()),rVar(r)); // usually: rVar(r)==length()
            for (int i=len;i>0;i--)
                s[i]=iv[i-1];
            res = p_DegW(a, s, r);
            omFreeSize( (ADDRESS)s, (rVar(r)+1)*sizeof(short) );
        }
        else {
            res = -1;
        }
        return res;
    });
    Singular.method("p_Variables", [](spolyrec * p, ip_sring * r) {
        int *e=(int *)omAlloc0((rVar(r)+1)*sizeof(int));
        int n=p_GetVariables(p,e,r);
        if (n==0) n=1;
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
    Singular.method("p_leadexp", [](spolyrec * p, ip_sring * r) {
        int s = r->N;
        jlcxx::Array<size_t> ans;
        for(int i = 1; i <= s; i++)
            ans.push_back(p == NULL ? 0 : p_GetExp(p, i, r));
        return ans;
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
    Singular.method("maMapPoly", [](poly map_p, ring pr, map im_id, ring im) {
        const ring origin = currRing;
        rChangeCurrRing(pr);
        nMapFunc nMap =n_SetMap(currRing->cf, im->cf);
        poly p = maMapPoly(map_p, pr, (ideal)im_id, im, nMap);
        rChangeCurrRing(origin);
        return p;
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

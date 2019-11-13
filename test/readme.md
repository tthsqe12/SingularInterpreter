# benchmarks

`singular`: interpreter written in c
`julia`:  interpreter written in julia that stores every variable in a lookup table
`julia'`: interpreter written in julia with local variables optimized where possible

The difference between `julia` and `julia'` can be seen in the output code below.
Peephole optimizations could be applied to `julia'` to make an even better `julia''`,
but for now the benefit of having local variables as real local variables is clear.
The code emitted by `julia` is what you get when the transpiler is not able to prove
the correctness of moving singular local variables to julia local variables,
which will probably be the case for most variables in most code.


```
| task            | singular  |    julia  |   julia'  |
recursive calls and int arithmetic                  |
| fib1(12)        |        9  |      506  |      374  |
| fib1(15)        |       18  |        5  |        3  |
| fib1(18)        |       77  |       20  |       13  |
| fib1(21)        |      305  |      104  |       69  |
| fib1(24)        |     1243  |      362  |      241  |
| fib1(27)        |     5284  |     1444  |      945  |
for loops with bigint arithmetic                    |
| fib2(  1000)    |       30  |      607  |      164  |
| fib2( 10000)    |       81  |       64  |       24  |
| fib2( 40000)    |      329  |      330  |      201  |
| fib2(160000)    |     1528  |     1360  |      882  |
for loops with int arithmetic
| fib2m(  1000)   |        8  |      197  |       87  |
| fib2m( 10000)   |       80  |       39  |        8  |
| fib2m( 40000)   |      311  |      142  |       47  |
| fib2m(160000)   |     1219  |      519  |      142  |
| fib2m(640000)   |     4824  |     2031  |      472  |
99.99% bigint mul. julia probably uses a subpar gmp
| fib3(10^3)      |       16  |      223  |       85  |
| fib3(10^4)      |        1  |        2  |        2  |
| fib3(10^5)      |        2  |        1  |        1  |
| fib3(10^6)      |       15  |       15  |       13  |
| fib3(10^7)      |      147  |      204  |      203  |
recursively list all permutations of 1, ..., n
| permute(3)      |        1  |      697  |      542  |
| permute(4)      |        2  |       39  |       40  |
| permute(5)      |       14  |       44  |       44  |
| permute(6)      |       92  |       84  |       67  |
| permute(7)      |      674  |      328  |      181  |
| permute(8)      |     5916  |     2870  |     1386  |
```

More tasks involving lists will be added soon.

------------------------------------
`singular` code:

```
proc permute(list N)
{
    int i, j, k;
    list L, L1;

    if (size(N) == 1)
    {
        return(list(N));
    }
    else
    {
        k = 1;
        for (i = 1; i <= size(N); i++)
        {
            L = permute(delete(N,i));
            for (j = 1; j <= size(L); j++)
            {
                L1[k] = L[j] + list(N[i]);
                k = k + 1;
            }
        }
    }
    return(L1);
};

proc fib1(int n)
{
    if (n <= 1)
    {
        return(n);
    }
    else
    {
        return(fib1(n - 1) + fib1(n - 2));
    }
};

proc fib2(int n)
{
    bigint a = 0;
    bigint b = 1;
    for (int i = n; i > 0; i--)
    {
        (a, b) = (b + 0, a + b);
    }
    return(a);
};

proc fib2m(int n)
{
    int a = 0;
    int b = 1;
    for (int i = n; i > 0; i--)
    {
        (a, b) = (b mod 1000, (a + b) mod 1000);
    }
    return(a);
};

proc fib3(int n)
{
    if (n <= 1)
    {
        return(bigint(n), bigint(1));
    }
    bigint a, b = fib3(n div 2);
    if (n mod 2)
    {
        return(a*a + b*b, b*(2*a + b));
    }
    else
    {
        return(a*(2*b - a), a*a + b*b);
    }
};

int time;
bigint a, b;
system("--ticks-per-sec", 1000);
time = rtimer; a    = fib1(12);         "fib1(12): " + string(rtimer - time);
time = rtimer; a    = fib1(15);         "fib1(15): " + string(rtimer - time);
time = rtimer; a    = fib1(18);         "fib1(18): " + string(rtimer - time);
time = rtimer; a    = fib1(21);         "fib1(21): " + string(rtimer - time);
time = rtimer; a    = fib1(24);         "fib1(24): " + string(rtimer - time);
time = rtimer; a    = fib1(27);         "fib1(27): " + string(rtimer - time);
time = rtimer; a    = fib2( 1000);      "fib2(  1000): " + string(rtimer - time);
time = rtimer; a    = fib2( 10000);     "fib2( 10000): " + string(rtimer - time);
time = rtimer; a    = fib2( 40000);     "fib2( 40000): " + string(rtimer - time);
time = rtimer; a    = fib2(160000);     "fib2(160000): " + string(rtimer - time);
time = rtimer; a    = fib2m( 1000);     "fib2m(  1000): " + string(rtimer - time);
time = rtimer; a    = fib2m( 10000);    "fib2m( 10000): " + string(rtimer - time);
time = rtimer; a    = fib2m( 40000);    "fib2m( 40000): " + string(rtimer - time);
time = rtimer; a    = fib2m(160000);    "fib2m(160000): " + string(rtimer - time);
time = rtimer; a    = fib2m(640000);    "fib2m(640000): " + string(rtimer - time);
time = rtimer; a, b = fib3(10^3);       "fib3(10^3): " + string(rtimer - time);
time = rtimer; a, b = fib3(10^4);       "fib3(10^4): " + string(rtimer - time);
time = rtimer; a, b = fib3(10^5);       "fib3(10^5): " + string(rtimer - time);
time = rtimer; a, b = fib3(10^6);       "fib3(10^6): " + string(rtimer - time);
time = rtimer; a, b = fib3(10^7);       "fib3(10^7): " + string(rtimer - time);
```


-----------------------------
`julia` code
```
rt_declare_proc(SingularInterpreter.SName(:permute))
function ##permute(#N)
    rt_enterfunction(:Top)
    rt_parameter_list(SingularInterpreter.SName(:N), #N)
    rt_declare_int(SingularInterpreter.SName(:i))
    rt_declare_int(SingularInterpreter.SName(:j))
    rt_declare_int(SingularInterpreter.SName(:k))
    rt_declare_list(SingularInterpreter.SName(:L))
    rt_declare_list(SingularInterpreter.SName(:L1))
    if rt_asbool(rtequalequal(rtsize(SingularInterpreter.SName(:N)), 1))
        ##358 = rt_copy_allow_tuple(rt_cast2list(rt_make(SingularInterpreter.SName(:N))))
        rt_leavefunction()
        return ##358
    else
        rtassign(SingularInterpreter.SName(:k), rt_copy_allow_tuple(1))
        rtassign(SingularInterpreter.SName(:i), rt_copy_allow_tuple(1))
        while rt_asbool(rtlessequal(SingularInterpreter.SName(:i), rtsize(SingularInterpreter.SName(:N))))
            rtassign(SingularInterpreter.SName(:L), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:permute), rt_copy_allow_tuple(rtdelete(SingularInterpreter.SName(:N), SingularInterpreter.SName(:i)))...)))
            rtassign(SingularInterpreter.SName(:j), rt_copy_allow_tuple(1))
            while rt_asbool(rtlessequal(SingularInterpreter.SName(:j), rtsize(SingularInterpreter.SName(:L))))
                rt_setindex(rt_make(SingularInterpreter.SName(:L1)), rt_make(SingularInterpreter.SName(:k)), rt_copy_allow_tuple(rtplus(rt_getindex(rt_make(SingularInterpreter.SName(:L)), rt_make(SingularInterpreter.SName(:j))), rt_cast2list(rt_copy_allow_tuple(rt_getindex(rt_make(SingularInterpreter.SName(:N)), rt_make(SingularInterpreter.SName(:i))))...))))
                rtassign(SingularInterpreter.SName(:k), rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:k), 1)))
                rt_incrementby(SingularInterpreter.SName(:j), 1)
            end
            rt_incrementby(SingularInterpreter.SName(:i), 1)
        end
    end
    ##359 = rt_copy(rt_make(SingularInterpreter.SName(:L1)))
    rt_leavefunction()
    return ##359
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:permute), SProc(##permute, "permute", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib1))
function ##fib1(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    if rt_asbool(rtlessequal(SingularInterpreter.SName(:n), 1))
        ##360 = rt_copy(rt_make(SingularInterpreter.SName(:n)))
        rt_leavefunction()
        return ##360
    else
        ##361 = rt_copy_allow_tuple(rtplus(rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(SingularInterpreter.SName(:n), 1))...), rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(SingularInterpreter.SName(:n), 2))...)))
        rt_leavefunction()
        return ##361
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib1), SProc(##fib1, "fib1", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib2))
function ##fib2(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    rt_declare_bigint(SingularInterpreter.SName(:a))
    rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(0))
    rt_declare_bigint(SingularInterpreter.SName(:b))
    rtassign(SingularInterpreter.SName(:b), rt_copy_allow_tuple(1))
    rt_declare_int(SingularInterpreter.SName(:i))
    rtassign(SingularInterpreter.SName(:i), rt_copy(rt_make(SingularInterpreter.SName(:n))))
    while rt_asbool(rtgreater(SingularInterpreter.SName(:i), 0))
        ##362 = (rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:b), 0))..., rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:a), SingularInterpreter.SName(:b)))...)
        rt_checktuplelength(##362, 2)
        rtassign(SingularInterpreter.SName(:a), ##362[1])
        rtassign(SingularInterpreter.SName(:b), ##362[2])
        rt_incrementby(SingularInterpreter.SName(:i), -1)
    end
    ##363 = rt_copy(rt_make(SingularInterpreter.SName(:a)))
    rt_leavefunction()
    return ##363
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib2), SProc(##fib2, "fib2", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib2m))
function ##fib2m(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    rt_declare_int(SingularInterpreter.SName(:a))
    rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(0))
    rt_declare_int(SingularInterpreter.SName(:b))
    rtassign(SingularInterpreter.SName(:b), rt_copy_allow_tuple(1))
    rt_declare_int(SingularInterpreter.SName(:i))
    rtassign(SingularInterpreter.SName(:i), rt_copy(rt_make(SingularInterpreter.SName(:n))))
    while rt_asbool(rtgreater(SingularInterpreter.SName(:i), 0))
        ##364 = (rt_copy_allow_tuple(rtmod(SingularInterpreter.SName(:b), 1000))..., rt_copy_allow_tuple(rtmod(rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:a), SingularInterpreter.SName(:b))), 1000))...)
        rt_checktuplelength(##364, 2)
        rtassign(SingularInterpreter.SName(:a), ##364[1])
        rtassign(SingularInterpreter.SName(:b), ##364[2])
        rt_incrementby(SingularInterpreter.SName(:i), -1)
    end
    ##365 = rt_copy(rt_make(SingularInterpreter.SName(:a)))
    rt_leavefunction()
    return ##365
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib2m), SProc(##fib2m, "fib2m", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib3))
function ##fib3(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    if rt_asbool(rtlessequal(SingularInterpreter.SName(:n), 1))
        ##366 = (rt_copy_allow_tuple(rt_cast2bigint(rt_make(SingularInterpreter.SName(:n))))..., rt_copy_allow_tuple(rt_cast2bigint(1))...)
        rt_leavefunction()
        return ##366
    end
    rt_declare_bigint(SingularInterpreter.SName(:a))
    rt_declare_bigint(SingularInterpreter.SName(:b))
    ##367 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtdiv(SingularInterpreter.SName(:n), 2))...))...,)
    rt_checktuplelength(##367, 2)
    rtassign(SingularInterpreter.SName(:a), ##367[1])
    rtassign(SingularInterpreter.SName(:b), ##367[2])
    if rt_asbool(rtmod(SingularInterpreter.SName(:n), 2))
        ##368 = (rt_copy_allow_tuple(rtplus(rttimes(SingularInterpreter.SName(:a), SingularInterpreter.SName(:a)), rttimes(SingularInterpreter.SName(:b), SingularInterpreter.SName(:b))))..., rt_copy_allow_tuple(rttimes(SingularInterpreter.SName(:b), rt_copy_allow_tuple(rtplus(rttimes(2, SingularInterpreter.SName(:a)), SingularInterpreter.SName(:b)))))...)
        rt_leavefunction()
        return ##368
    else
        ##369 = (rt_copy_allow_tuple(rttimes(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtminus(rttimes(2, SingularInterpreter.SName(:b)), SingularInterpreter.SName(:a)))))..., rt_copy_allow_tuple(rtplus(rttimes(SingularInterpreter.SName(:a), SingularInterpreter.SName(:a)), rttimes(SingularInterpreter.SName(:b), SingularInterpreter.SName(:b))))...)
        rt_leavefunction()
        return ##369
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib3), SProc(##fib3, "fib3", :Top))
```

-----------------------------
`julia'` code
```
rt_declare_proc(SingularInterpreter.SName(:permute))
function ##permute(#N)
    rt_enterfunction(:Top)
    local L1::SList
    local N::SList
    local j::Int
    local k::Int
    local L::SList
    local i::Int
    N = rt_convert2list(#N)
    i = rt_defaultconstructor_int()
    j = rt_defaultconstructor_int()
    k = rt_defaultconstructor_int()
    L = rt_defaultconstructor_list()
    L1 = rt_defaultconstructor_list()
    if rt_asbool(rtequalequal(rtsize(rt_ref(N)), 1))
        ##358 = rt_copy_allow_tuple(rt_cast2list(rt_ref(N)))
        rt_leavefunction()
        return ##358
    else
        k = rt_assign(k, rt_copy_allow_tuple(1))
        i = rt_assign(i, rt_copy_allow_tuple(1))
        while rt_asbool(rtlessequal(rt_ref(i), rtsize(rt_ref(N))))
            L = rt_assign(L, rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:permute), rt_copy_allow_tuple(rtdelete(rt_ref(N), rt_ref(i)))...)))
            j = rt_assign(j, rt_copy_allow_tuple(1))
            while rt_asbool(rtlessequal(rt_ref(j), rtsize(rt_ref(L))))
                rt_setindex(rt_ref(L1), rt_ref(k), rt_copy_allow_tuple(rtplus(rt_getindex(rt_ref(L), rt_ref(j)), rt_cast2list(rt_copy_allow_tuple(rt_getindex(rt_ref(N), rt_ref(i)))...))))
                k = rt_assign(k, rt_copy_allow_tuple(rtplus(rt_ref(k), 1)))
                j = rt_assign(j, rtplus(j, 1))
            end
            i = rt_assign(i, rtplus(i, 1))
        end
    end
    ##359 = rt_copy_allow_tuple(rt_ref(L1))
    rt_leavefunction()
    return ##359
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:permute), SProc(##permute, "permute", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib1))
function ##fib1(#n)
    rt_enterfunction(:Top)
    local n::Int
    n = rt_convert2int(#n)
    if rt_asbool(rtlessequal(rt_ref(n), 1))
        ##360 = rt_copy_allow_tuple(rt_ref(n))
        rt_leavefunction()
        return ##360
    else
        ##361 = rt_copy_allow_tuple(rtplus(rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(rt_ref(n), 1))...), rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(rt_ref(n), 2))...)))
        rt_leavefunction()
        return ##361
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib1), SProc(##fib1, "fib1", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib2))
function ##fib2(#n)
    rt_enterfunction(:Top)
    local i::Int
    local b::BigInt
    local a::BigInt
    local n::Int
    n = rt_convert2int(#n)
    a = rt_defaultconstructor_bigint()
    a = rt_assign(a, rt_copy_allow_tuple(0))
    b = rt_defaultconstructor_bigint()
    b = rt_assign(b, rt_copy_allow_tuple(1))
    i = rt_defaultconstructor_int()
    i = rt_assign(i, rt_copy_allow_tuple(rt_ref(n)))
    while rt_asbool(rtgreater(rt_ref(i), 0))
        ##362 = (rt_copy_allow_tuple(rtplus(rt_ref(b), 0))..., rt_copy_allow_tuple(rtplus(rt_ref(a), rt_ref(b)))...)
        rt_checktuplelength(##362, 2)
        a = rt_assign(a, ##362[1])
        b = rt_assign(b, ##362[2])
        i = rt_assign(i, rtplus(i, -1))
    end
    ##363 = rt_copy_allow_tuple(rt_ref(a))
    rt_leavefunction()
    return ##363
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib2), SProc(##fib2, "fib2", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib2m))
function ##fib2m(#n)
    rt_enterfunction(:Top)
    local i::Int
    local b::Int
    local a::Int
    local n::Int
    n = rt_convert2int(#n)
    a = rt_defaultconstructor_int()
    a = rt_assign(a, rt_copy_allow_tuple(0))
    b = rt_defaultconstructor_int()
    b = rt_assign(b, rt_copy_allow_tuple(1))
    i = rt_defaultconstructor_int()
    i = rt_assign(i, rt_copy_allow_tuple(rt_ref(n)))
    while rt_asbool(rtgreater(rt_ref(i), 0))
        ##364 = (rt_copy_allow_tuple(rtmod(rt_ref(b), 1000))..., rt_copy_allow_tuple(rtmod(rt_copy_allow_tuple(rtplus(rt_ref(a), rt_ref(b))), 1000))...)
        rt_checktuplelength(##364, 2)
        a = rt_assign(a, ##364[1])
        b = rt_assign(b, ##364[2])
        i = rt_assign(i, rtplus(i, -1))
    end
    ##365 = rt_copy_allow_tuple(rt_ref(a))
    rt_leavefunction()
    return ##365
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib2m), SProc(##fib2m, "fib2m", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib3))
function ##fib3(#n)
    rt_enterfunction(:Top)
    local b::BigInt
    local a::BigInt
    local n::Int
    n = rt_convert2int(#n)
    if rt_asbool(rtlessequal(rt_ref(n), 1))
        ##366 = (rt_copy_allow_tuple(rt_cast2bigint(rt_ref(n)))..., rt_copy_allow_tuple(rt_cast2bigint(1))...)
        rt_leavefunction()
        return ##366
    end
    a = rt_defaultconstructor_bigint()
    b = rt_defaultconstructor_bigint()
    ##367 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtdiv(rt_ref(n), 2))...))...,)
    rt_checktuplelength(##367, 2)
    a = rt_assign(a, ##367[1])
    b = rt_assign(b, ##367[2])
    if rt_asbool(rtmod(rt_ref(n), 2))
        ##368 = (rt_copy_allow_tuple(rtplus(rttimes(rt_ref(a), rt_ref(a)), rttimes(rt_ref(b), rt_ref(b))))..., rt_copy_allow_tuple(rttimes(rt_ref(b), rt_copy_allow_tuple(rtplus(rttimes(2, rt_ref(a)), rt_ref(b)))))...)
        rt_leavefunction()
        return ##368
    else
        ##369 = (rt_copy_allow_tuple(rttimes(rt_ref(a), rt_copy_allow_tuple(rtminus(rttimes(2, rt_ref(b)), rt_ref(a)))))..., rt_copy_allow_tuple(rtplus(rttimes(rt_ref(a), rt_ref(a)), rttimes(rt_ref(b), rt_ref(b))))...)
        rt_leavefunction()
        return ##369
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib3), SProc(##fib3, "fib3", :Top))
```

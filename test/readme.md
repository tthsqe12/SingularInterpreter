#benchmarks

```
singular: interpreter written in c
julia:    interpreter written in julia that stores every variable in a lookup table
julia':   interpreter written in julia with local variables optimized where possible
```

The difference between `julia` and `julia'` can be seen in the output code below.

```
| task            | singular  | julia     | julia'    |
| --------------- | --------- | --------- | --------- |
| fib1(12)        |        9  |      506  |      374  |
| fib1(15)        |       18  |        5  |        3  |
| fib1(18)        |       77  |       20  |       13  |
| fib1(21)        |      305  |      104  |       69  |
| fib1(24)        |     1243  |      362  |      241  |
| fib1(27)        |     5284  |     1444  |      945  |
| fib2(  1000)    |       30  |      607  |      164  |
| fib2( 10000)    |       81  |       64  |       24  |
| fib2( 40000)    |      329  |      330  |      201  |
| fib2(160000)    |     1528  |     1360  |      882  |
| fib2m(  1000)   |        8  |      197  |       87  |
| fib2m( 10000)   |       80  |       39  |        8  |
| fib2m( 40000)   |      311  |      142  |       47  |
| fib2m(160000)   |     1219  |      519  |      142  |
| fib2m(640000)   |     4824  |     2031  |      472  |
| fib3(10^3)      |       16  |      223  |       85  |
| fib3(10^4)      |        1  |        2  |        2  |
| fib3(10^5)      |        2  |        1  |        1  |
| fib3(10^6)      |       15  |       15  |       13  |
| fib3(10^7)      |      147  |      204  |      203  |
```

The tasks are

```
fib1: recursive calls and int arithmetic
fib2: for loops with bigint arithmetic
fib2m: for loops with int arithmetic
fib3: not much is tested since everything is in the bigint arithmetic
```

More tasks involving lists will be added soon.

------------------------------------
`singular` code:

```
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
---------- transpiled code ----------
rt_declare_proc(SingularInterpreter.SName(:fib1))
function ##fib1(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    if rt_asbool(rtlessequal(SingularInterpreter.SName(:n), 1))
        ##358 = rt_copy(rt_make(SingularInterpreter.SName(:n)))
        rt_leavefunction()
        return ##358
    else
        ##359 = rt_copy_allow_tuple(rtplus(rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(SingularInterpreter.SName(:n), 1))...), rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(SingularInterpreter.SName(:n), 2))...)))
        rt_leavefunction()
        return ##359
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
        ##360 = (rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:b), 0))..., rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:a), SingularInterpreter.SName(:b)))...)
        rt_checktuplelength(##360, 2)
        rtassign(SingularInterpreter.SName(:a), ##360[1])
        rtassign(SingularInterpreter.SName(:b), ##360[2])
        rt_incrementby(SingularInterpreter.SName(:i), -1)
    end
    ##361 = rt_copy(rt_make(SingularInterpreter.SName(:a)))
    rt_leavefunction()
    return ##361
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
        ##362 = (rt_copy_allow_tuple(rtmod(SingularInterpreter.SName(:b), 1000))..., rt_copy_allow_tuple(rtmod(rt_copy_allow_tuple(rtplus(SingularInterpreter.SName(:a), SingularInterpreter.SName(:b))), 1000))...)
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
rtassign(SingularInterpreter.SName(:fib2m), SProc(##fib2m, "fib2m", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib3))
function ##fib3(#n)
    rt_enterfunction(:Top)
    rt_parameter_int(SingularInterpreter.SName(:n), #n)
    if rt_asbool(rtlessequal(SingularInterpreter.SName(:n), 1))
        ##364 = (rt_copy_allow_tuple(rt_cast2bigint(rt_make(SingularInterpreter.SName(:n))))..., rt_copy_allow_tuple(rt_cast2bigint(1))...)
        rt_leavefunction()
        return ##364
    end
    rt_declare_bigint(SingularInterpreter.SName(:a))
    rt_declare_bigint(SingularInterpreter.SName(:b))
    ##365 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtdiv(SingularInterpreter.SName(:n), 2))...))...,)
    rt_checktuplelength(##365, 2)
    rtassign(SingularInterpreter.SName(:a), ##365[1])
    rtassign(SingularInterpreter.SName(:b), ##365[2])
    if rt_asbool(rtmod(SingularInterpreter.SName(:n), 2))
        ##366 = (rt_copy_allow_tuple(rtplus(rttimes(SingularInterpreter.SName(:a), SingularInterpreter.SName(:a)), rttimes(SingularInterpreter.SName(:b), SingularInterpreter.SName(:b))))..., rt_copy_allow_tuple(rttimes(SingularInterpreter.SName(:b), rt_copy_allow_tuple(rtplus(rttimes(2, SingularInterpreter.SName(:a)), SingularInterpreter.SName(:b)))))...)
        rt_leavefunction()
        return ##366
    else
        ##367 = (rt_copy_allow_tuple(rttimes(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtminus(rttimes(2, SingularInterpreter.SName(:b)), SingularInterpreter.SName(:a)))))..., rt_copy_allow_tuple(rtplus(rttimes(SingularInterpreter.SName(:a), SingularInterpreter.SName(:a)), rttimes(SingularInterpreter.SName(:b), SingularInterpreter.SName(:b))))...)
        rt_leavefunction()
        return ##367
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib3), SProc(##fib3, "fib3", :Top))
rt_declare_int(SingularInterpreter.SName(:time))
rt_declare_bigint(SingularInterpreter.SName(:a))
rt_declare_bigint(SingularInterpreter.SName(:b))
rt_printout(rtsystem(rt_copy_allow_tuple(SingularInterpreter.SString("--ticks-per-sec"))..., 1000))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 12)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(12): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 15)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(15): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 18)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(18): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 21)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(21): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 24)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(24): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 27)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(27): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 1000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2(  1000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 10000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2( 10000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 40000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2( 40000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 160000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2(160000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 1000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(  1000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 10000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m( 10000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 40000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m( 40000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 160000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(160000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 640000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(640000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##368 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 3))...))...,)
rt_checktuplelength(##368, 2)
rtassign(SingularInterpreter.SName(:a), ##368[1])
rtassign(SingularInterpreter.SName(:b), ##368[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^3): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##369 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 4))...))...,)
rt_checktuplelength(##369, 2)
rtassign(SingularInterpreter.SName(:a), ##369[1])
rtassign(SingularInterpreter.SName(:b), ##369[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^4): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##370 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 5))...))...,)
rt_checktuplelength(##370, 2)
rtassign(SingularInterpreter.SName(:a), ##370[1])
rtassign(SingularInterpreter.SName(:b), ##370[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^5): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##371 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 6))...))...,)
rt_checktuplelength(##371, 2)
rtassign(SingularInterpreter.SName(:a), ##371[1])
rtassign(SingularInterpreter.SName(:b), ##371[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^6): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##372 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 7))...))...,)
rt_checktuplelength(##372, 2)
rtassign(SingularInterpreter.SName(:a), ##372[1])
rtassign(SingularInterpreter.SName(:b), ##372[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^7): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
------- transpiled in 155.0 ms -------
```

-----------------------------
`julia'` code
```
---------- transpiled code ----------
rt_declare_proc(SingularInterpreter.SName(:fib1))
function ##fib1(#n)
    rt_enterfunction(:Top)
    local n::Int
    n = rt_convert2int(#n)
    if rt_asbool(rtlessequal(rt_ref(n), 1))
        ##358 = rt_copy_allow_tuple(rt_ref(n))
        rt_leavefunction()
        return ##358
    else
        ##359 = rt_copy_allow_tuple(rtplus(rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(rt_ref(n), 1))...), rtcall(false, SingularInterpreter.SName(:fib1), rt_copy_allow_tuple(rtminus(rt_ref(n), 2))...)))
        rt_leavefunction()
        return ##359
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
        ##360 = (rt_copy_allow_tuple(rtplus(rt_ref(b), 0))..., rt_copy_allow_tuple(rtplus(rt_ref(a), rt_ref(b)))...)
        rt_checktuplelength(##360, 2)
        a = rt_assign(a, ##360[1])
        b = rt_assign(b, ##360[2])
        i = rt_assign(i, rtplus(i, -1))
    end
    ##361 = rt_copy_allow_tuple(rt_ref(a))
    rt_leavefunction()
    return ##361
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
        ##362 = (rt_copy_allow_tuple(rtmod(rt_ref(b), 1000))..., rt_copy_allow_tuple(rtmod(rt_copy_allow_tuple(rtplus(rt_ref(a), rt_ref(b))), 1000))...)
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
rtassign(SingularInterpreter.SName(:fib2m), SProc(##fib2m, "fib2m", :Top))
rt_declare_proc(SingularInterpreter.SName(:fib3))
function ##fib3(#n)
    rt_enterfunction(:Top)
    local b::BigInt
    local a::BigInt
    local n::Int
    n = rt_convert2int(#n)
    if rt_asbool(rtlessequal(rt_ref(n), 1))
        ##364 = (rt_copy_allow_tuple(rt_cast2bigint(rt_ref(n)))..., rt_copy_allow_tuple(rt_cast2bigint(1))...)
        rt_leavefunction()
        return ##364
    end
    a = rt_defaultconstructor_bigint()
    b = rt_defaultconstructor_bigint()
    ##365 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtdiv(rt_ref(n), 2))...))...,)
    rt_checktuplelength(##365, 2)
    a = rt_assign(a, ##365[1])
    b = rt_assign(b, ##365[2])
    if rt_asbool(rtmod(rt_ref(n), 2))
        ##366 = (rt_copy_allow_tuple(rtplus(rttimes(rt_ref(a), rt_ref(a)), rttimes(rt_ref(b), rt_ref(b))))..., rt_copy_allow_tuple(rttimes(rt_ref(b), rt_copy_allow_tuple(rtplus(rttimes(2, rt_ref(a)), rt_ref(b)))))...)
        rt_leavefunction()
        return ##366
    else
        ##367 = (rt_copy_allow_tuple(rttimes(rt_ref(a), rt_copy_allow_tuple(rtminus(rttimes(2, rt_ref(b)), rt_ref(a)))))..., rt_copy_allow_tuple(rtplus(rttimes(rt_ref(a), rt_ref(a)), rttimes(rt_ref(b), rt_ref(b))))...)
        rt_leavefunction()
        return ##367
    end
    rt_leavefunction()
    return nothing
end
rtassign(SingularInterpreter.SName(:fib3), SProc(##fib3, "fib3", :Top))
rt_declare_int(SingularInterpreter.SName(:time))
rt_declare_bigint(SingularInterpreter.SName(:a))
rt_declare_bigint(SingularInterpreter.SName(:b))
rt_printout(rtsystem(rt_copy_allow_tuple(SingularInterpreter.SString("--ticks-per-sec"))..., 1000))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 12)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(12): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 15)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(15): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 18)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(18): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 21)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(21): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 24)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(24): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib1), 27)))
rt_printout(rtplus(SingularInterpreter.SString("fib1(27): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 1000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2(  1000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 10000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2( 10000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 40000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2( 40000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2), 160000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2(160000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 1000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(  1000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 10000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m( 10000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 40000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m( 40000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 160000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(160000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
rtassign(SingularInterpreter.SName(:a), rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib2m), 640000)))
rt_printout(rtplus(SingularInterpreter.SString("fib2m(640000): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##368 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 3))...))...,)
rt_checktuplelength(##368, 2)
rtassign(SingularInterpreter.SName(:a), ##368[1])
rtassign(SingularInterpreter.SName(:b), ##368[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^3): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##369 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 4))...))...,)
rt_checktuplelength(##369, 2)
rtassign(SingularInterpreter.SName(:a), ##369[1])
rtassign(SingularInterpreter.SName(:b), ##369[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^4): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##370 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 5))...))...,)
rt_checktuplelength(##370, 2)
rtassign(SingularInterpreter.SName(:a), ##370[1])
rtassign(SingularInterpreter.SName(:b), ##370[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^5): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##371 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 6))...))...,)
rt_checktuplelength(##371, 2)
rtassign(SingularInterpreter.SName(:a), ##371[1])
rtassign(SingularInterpreter.SName(:b), ##371[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^6): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
rtassign(SingularInterpreter.SName(:time), rt_copy_allow_tuple(rt_get_rtimer()))
##372 = (rt_copy_allow_tuple(rtcall(false, SingularInterpreter.SName(:fib3), rt_copy_allow_tuple(rtpower(10, 7))...))...,)
rt_checktuplelength(##372, 2)
rtassign(SingularInterpreter.SName(:a), ##372[1])
rtassign(SingularInterpreter.SName(:b), ##372[2])
rt_printout(rtplus(SingularInterpreter.SString("fib3(10^7): "), rt_cast2string(rt_copy_allow_tuple(rtminus(rt_get_rtimer(), SingularInterpreter.SName(:time)))...)))
------- transpiled in 155.0 ms -------
```

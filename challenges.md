# Challenges with the Singular language


(1) (problem will disappear) With the grammar/scanner rules as implemented in Singular, the input
```
proc f(int i)
{
    if (100 > i)
    {
        i;
    }
    else
    {
        adf+&block /@#$% of &$*( garbage
    }
};
```
will result in `f(0)`,...,`f(99)` running perfectly fine. One only discovers the syntax error when _running_ `f(100)`.

(2) Every semicolon is a potential print command. Even though the definitions of `g` are the same in each case, only the semicolon in the second example causes a print.
```
proc g() {f();};
proc f() {3; return();};
g();
```
and
```
proc g() {f();};
proc f() {3; return(4);};
g();
```

(3) (this syntax will be banned) The `parameter` keyword is impossible to handle.
```
proc f()
{
    parameter int i;
    if (i > 5)
    {
        parameter int j;
    };
    (i, j);
    return(0);
};
```
```
> int j = 5; f(2, 3);
2 5
// ** too many arguments for f
0
> f(6, 3);
6 3
0
```

(4) Singular's assignment operator is unpredictable: `f(1, 2)` prints `(2, 2)` while `g(1, 2)` prints `(2, 1)`.
```
proc f(A, B)
{
    int a = A;
    int b = B;
    a, b = b, a;
    (a, b);
}

proc g(A, B)
{
    int a = A;
    int b = B;
    a, b = b + 0, a + 0;
    (a, b);
}
```

(5) Singular allows local variables to be declared with different types.
```
proc f()
{
    ideal i = (x^2, y^2);
    i;
    ring r = 0, (a, b, c), dp;
    poly i = a + b;
    i;
    ring s = 0, (s, t), dp;
    int i = 7;
    i;
};

ring r = 0, (x, y, z), dp;
f();
```

(6) Singular automatically splats tuples. This is a call to `f` with four arguments.
```
proc g(int i)
{
    if (i == 0)
    {
        return(i);
    }
    else
    {
        return(i, i);
    }
};
f(1, g(2), 3);
```

(7) Singular plays fast and loose with unknown identifiers.

(7.1) Running `f();` is an error and running `g();` is not.
```
proc f() {return(x););
proc g() {return(1, x););
```

(7.2) The behaviour of `x(1)` at runtime seems to be:
1. The `x` starts out life as an unknown identifier with name "x"
    * This can be though of as a special UNKNOWN type that is used by the interpreter but is not available to the user.
2. The name "x" is looked up in the order:
    * a local variable (w.r.t. a procedure),
    * a local ring variable (w.r.t. the current basering locally set in a procedure),
    * a global variable,
    * a global ring variable (w.r.t. the current basering)
    * a monomial consisting of local ring variables written without operators,
    * a monomial consisting of global ring variables written without operators.
3. If the name "x" is found in this lookup then the `x` portion of the input `x(1)` evaluates to one of these standard types.
    * Otherwise, _the evaluator leaves it as this UNKOWN type_.
4. The '(' operator then has the following behaviour when applied to evaluated expression `E1` and `E2`:
    * If E1 is of `proc` type, then `E1(E2)` evaluates to a function call.
    * If E1 is of `map` type, then `E1(E2)` calls special evaluation code for maps.
    * If E1 is of `UNKOWN` type, then `E1(E2)` evaluates to another UNKNOWN type with a longer name.

(7.3) The ring constructor dynamically introduces new identifiers into the current lexical scope.
      I have no idea how this could be done in julia without a complete rewrite of the interpreter that takes advantage of _none_ of the dynamic features of julia.



(8) (no big deal) Besides the second-class types instantiated in unknown identifiers and tuples, there is a "nothing" that can be passed around.
```
> proc f() {return();};
> list k; k[10]=0;
> list l = 1,2,3; l;
[1]:
   1
[2]:
   2
[3]:
   3
> l[3]=f();
// ** right side is not a datum, assignment ignored
// ** in line >>return();<<
> l;
[1]:
   1
[2]:
   2
> l[2]=k[1];
> l;
[1]:
   1
```

(9) (huge unresolved problem) Lists can be either ring-dependent or ring-independent and thus disappear and reappear in the list of local variables w.r.t. a procedure.

```
> proc f(int b, def R, def S)
> {
>     list l = 1, 2, 3; // l is ring-independent (1)
>     if (b)
>     {
>         setring R;
>         l[1] = x*y; // l is ring-dependent (2)
>     }
>     setring S;
>     l; // (1) l is 1,2,3, or (2) l is something called "l" in S or an error
> };

> ring r = 0, (x, y, z), lp;
> ring s = 0, (u, v, w), lp;
> list l = u, v, w;

> f(0, r, s);
[1]:
   1
[2]:
   2
[3]:
   3

> f(1, r, s);
[1]:
   u
[2]:
   v
[3]:
   w
```

(10) (not implemented in julia) The ring-dependence/independence of a list is of course applied recursively, so the getindex function needs some very special treatment.
```
> ring r;
> list l = list(list(1,2,3), list(4,5,6), list(7,8,9));
> listvar(r);
// r                              [0]  *ring
> l[2][2]=x;
> listvar(r);
// r                              [0]  *ring
// l                              [0]  list, size: 3
> l[2][2]=55;
> listvar(r);
// r                              [0]  *ring
```


(11) Variables declared poly need not be poly's. Therefore, _we have no type information on ring dependent types inside of a procedure_.
```
> proc f(def R, def S)
> {
>     setring R;
>     poly p = x*y;
>     setring S;
>     typeof(p);    // it will be an ideal
> };
> ring r = 0,(x,y,z),lp;
> ring s = 0,(u,v,w),lp;
> ideal p = (u,v,w);
> f(r, s);
ideal
```


(12) A proc that looks like it calls itself may in fact not call itself.
```
> proc f(int n) {if (n <= 1) {return(n);} else {return(f(n - 1) + f(n - 2));}};
> proc g(int n) {return(n*n);};
> proc h = f; f = g; g = h; // swap f and g
> g(5); // this is 4*4 + 3*3, not the fifth Fibonacci number
```

(13) (no big deal - fun curiousity) Singular allows polys to have the same names as ring variable names.
```
> ring r = 0, (x, y, z), lp;
> x + y + z;
x+y+z
> x = y + z;
   ? error in assign: left side is not an l-value
   ? error occurred in or before STDIN line 3: `x = y + z;`
> poly x = y + z;
> x + y + z;
2y+2z
> var(1) + var(2) + var(3);
x+y+z
```

(14) (no big deal - fun curiousity) The type of the coefficient ring is not discernible from the ring declaration
`ring r = (real, i, j), (x, y), dp;`. Compare three possible environments.

```
> int i = 8;
> ring r = (real, i, j), (x, y), dp;
> r;
// coefficients: real[j](complex:8 digits, additional 8 digits)/(j^2+1)
// number of vars : 2
//        block   1 : ordering dp
//                  : names    x y
//        block   2 : ordering C
```

```
> int i, j = 7, 8;
> ring r = (real, i, j), (x, y), dp;
> r;
// coefficients: Float(7,8)
// number of vars : 2
//        block   1 : ordering dp
//                  : names    x y
//        block   2 : ordering C
```

```
> int real = 7;
> ring r = (real, i, j), (x, y), dp;
> r;
// coefficients: ZZ/7(i, j)
// number of vars : 2
//        block   1 : ordering dp
//                  : names    x y
//        block   2 : ordering C
```

(15) (no big deal - `par` keyword addresses this) If there is a global variable `int j` (or any other ring
indep type) defined, there does not seem to be a way for `g` to use the
imaginary unit `j` declared in `f` (without passing it as a parameter).
```
> int j = 7;
> proc f()
> {
>     ring r = (complex, 10, 20, j), (x, y), dp;
>     g()
> };
> proc g()
> {
>     1 + 2*j;
>     typeof(1 + 2*j);
> };
> f();
15
int
```
compare with:
```
> int j = 7;
> proc f()
> {
>     ring r = (complex, 10, 20, j), (x, y), dp;
>     g(j)
> };
> proc g(number j)
> {
>     1 + 2*j;
>     typeof(1 + 2*j);
> };
> f();
(1+j*2)
number
```
and without `j` defined:
```
> proc f()
> {
>     ring r = (complex, 10, 20, j), (x, y), dp;
>     g()
> };
> proc g()
> {
>     1 + 2*j;
>     typeof(1 + 2*j);
> };
> f();
(1+j*2)
number
```

(16) (no big deal) The thingy `_` is supposed to mean the "value of expression displayed last"
but its behaviour is quite unpredictable.

expected:
```
> 2; int a = 3;
2
> _;
2
```
unexpected:
```
> 1, 2;
1 2
> _;
1
```
unexpected:
```
> proc f(){1;};
> 2;
2
> f();
1
> _;
   ? ...parse error
   ? error occurred in or before STDIN line 4: `_;`
```
simply calling a proc leads to unexpected behaviour:
```
> proc f(){return(2);};
> 1; int a = f();
1
> _;
   ? ...parse error
   ? error occurred in or before STDIN line 3: `_;`
```

(17) (should fix) The grammar of singular is terribly ambiguous. https://www.gnu.org/software/bison/manual/html_node/Reduce_002fReduce.html
If the following behaviour is the desired one, the current grammar.y is providing this behaviour seemingly _only by accident_.

```
list(a, b);  // construct a list then print it
list a, b;   // declare two lists
```

Here is a parse tree following grammar.y and ending with `list(a, b);` as a declaration.

```
|                          pprompt                         |
|                declare_ip_variable                   | ; |
| ROOT_DECL_LIST |              elemexpr               | ; |
| ROOT_DECL_LIST | '(' |        exprlist         | ')' | ; |
| ROOT_DECL_LIST | '(' | exprlist | , | expr     | ')' | ; |
| ROOT_DECL_LIST | '(' | expr     | , | expr     | ')' | ; |
| ROOT_DECL_LIST | '(' | elemexpr | , | elemexpr | ')' | ; |
      list          (      a        ,      b        )    ;
```

Here is a parse tree following the same grammar.y and ending with `list(a, b);` as a construction and print.

```
|                           pprompt                          |
|                       command                          | ; |
|                       typecmd                          | ; |
|                       exprlist                         | ; |
|                         expr                           | ; |
|                       elemexpr                         | ; |
|   ROOT_DECL_LIST | '(' |         exprlist        | ')' | ; |
|   ROOT_DECL_LIST | '(' | exprlist | , |   expr   | ')' | ; |
|   ROOT_DECL_LIST | '(' | expr     | , |   expr   | ')' | ; |
|   ROOT_DECL_LIST | '(' | elemexpr | , | elemexpr | ')' | ; |
      list            (     a         ,      b        )    ;
```

"fixing" this issue alone drops the number of reduce/reduce conflicts by 40.


(18) (executes compilation hope) `execute`

**`execute` and backticks do not need to be agressively removed from libraries**

`execute` is usually used to get around the limited syntax for constructing rings.
If you are constructing a ring, you are probably changing the current ring.
If you are changing the current ring, all ring dependent types will be slow anyways.

Other uses of execute are awkward and should be removed. https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/ellipticcovers.lib#L492
```
proc lsum(list L)
{
    def s = L[1];
    for (int j = 2; j <= size(L); j++)
    {
        s = s + L[j];
    }
    return(s);
}
```
Both of these functions suffer from an error on `lsum(list(5, bigint(6)))`
because the variable `s` is bound to the type of the first element of `L`. If
someone wanted an "improved" version that totals arbitrary types and handles
the empty list, they would have to write this nonsense.
```
proc lsum(list L)
{
    int s; // its zero
    for (int j = 1; j <= size(L); j++)
    {
        def t = s + L[j];
        kill s;
        def s = t;
        kill t;
    }
    return(s);
}
```

This brings us to the main curiosity of the Singular language:

**Interpreter types are not even needed at all.**

Of course the objects themselves have types, but there is no good reason for
the type restriction on the binding of identifiers. Half of the language deals
with these functionless restrictions on types, and the other half of the
language is meant to circumvent the difficulties and limitations caused by the
first half. Interpreter types do:

* give the lanaguage a superficial resemblance to C.

* govern the operation of pure assignments `a=b` where the new value of `a`
  depends on both the old value of `a` and the value of `b`. This is a terrible
  feature anyways because its complexities ripples across the entire
  implementation of the language, and it makes code harder to understand.
```
intmat m[2][3]; // m is [0 0 0; 0 0 0]
m = 1, 2, 3, 4; // m is [1 2 3; 4 0 0]
```

* generate errors and warnings when an attempt to assign the wrong type to a
  variable is made. This is not always desired, hence `kill`.

* give the progammer a hint about what type was roughly intended to be held in
  an identifier. This is only a hint as the existence of constructs such as
  `execute`, backticks, `kill`  and the current ring in the language mean that
  the mere presense of an `int i` or a `list l` in code has no bearing on
  other `i`'s or other `l`'s in the same code.



`execute` seems to be broken with respect to `return`.
```
> proc f(int n) {execute("-n; return(n);"); return(0);};
> f(5);
-5
> typeof(f(5));
-5
   ? error occurred in or before STDIN line 3: `-n; return(n);`
   ? last reserved name was `return`
   skipping text from `;` error at token `)`
fxn call error 0
> 1+f(5);
fxn call error 0
```

(19) (should fix c) singular has problems with ring dependent members of newstructs.
When a ring dependent member from a ring other than the current ring is used, singular does not catch this and essentially crashes.

```
> newstruct("foo", "poly p");
> ring r = 0,(x,y),lp;
> foo f; f.p = x+y; f.p;
x+y
> ring s = 7,(u,v); dp;
   ? error occurred in or before STDIN line 4: `ring s = 7,(u,v); dp;`
   ? expected ring-expression. type 'help ring;'
   ? last reserved name was `ring`
 error at token `;`
   ? `dp` is undefined
   ? error occurred in or before STDIN line 4: `ring s = 7,(u,v); dp;`
> ring s = 7,(u,v), dp;
> f.p^2;
-3+gen(-1111928496)-3*gen(2071110304)
```


(20) (obliterates the notion of compilation) `` ` ` `` the _sneaky execute_
The backtick is used to take an object of type `string` and essentially insert it into the code as if the user had typed the identifier herself.
This metaprogramming construction is so bad it makes one wish execute were used instead.

On left hand sides it is a pathological (but allowed!) case.

```
> string s = "i";
> int `s` = 6;
> i;
6
```

It is also quite uncomfortable on the right hand side because it is _a function that can return a name_.
```
> ring r = 0,(x,y,z),lp;
> poly p = x + y^2 + z^3;
> ring R = 0,(X,Y,Z),lp;
> imap(r, p);       // imap and fetch operate on names (not objects) as arguments
0
> fetch(r, p);
X+Y2+Z3
> string a = "r";
> string b = "p";
> fetch(`a`, `b`);  // calls fetch(r, p)
X+Y2+Z3
```

It is also possible to use backticks for the variables of ring declarations.

Due to a limitation of the parser, the backticks do not work to call kernel commands.
This is a good thing because kernel commands can be deduced from lexical analysis.
```
> proc f() {1+2;};
> string s = "f";
> `s`();
3
> s = "execute";
> `s`("1+2;");
   ? `execute` is not defined
fxn call error 0
   ? error occurred in or before STDIN line 5: ``s`("1+2;");`
```


offending libraries:

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/deform.lib#L123

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/finitediff.lib#L197

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/finitediff.lib#L267

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/finvar.lib#L566

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/finvar.lib#L702

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/general.lib#L371

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/graphics.lib#L234

oh no! it can return a tuple of names too https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/hnoether.lib#L2463

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/inout.lib#L373

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/KVequiv.lib#L442

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/latex.lib#L686

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/modstd.lib#L645

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/ncModslimgb.lib#L484

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/normaliz.lib#L111

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/ring.lib#L590

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/ring.lib#L793

what? https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/solve.lib#L657

https://github.com/Singular/Sources/blob/spielwiese/Singular/LIB/standard.lib#L680


(21) packages. package-qualified identifiers have unpredictable behaviour

Packages give a prefix on identifers to help avoid naming conflicts.
Identifiers without such a prefix use the "Current" package, which is
    - the package `Top` at the global level
    - the package of the procedure when inside a proc

This means that each proc has an associated package.
    - proc's declared through the LIB command probably get their package through the name of the library
    - proc declared elsewise inherit their package?


Why the following behaviour?
```
> int i = 7;
> int Test::i = 6;
Test of type 'ANY'. Trying load.
   ? 'Test' no such package
   ? error occurred in or before STDIN line 2: `int Test::i = 6;`
   ? wrong type declaration. type 'help int;'
> i;
7
> listvar(Test);
   ? Test is undefined
   ? error occurred in or before STDIN line 4: `listvar(Test);`
> package Test;
> i;
7
> int Test::i = 6;
// ** redefining i (int Test::i = 6;)
> i;
   ? `i` is undefined
   ? error occurred in or before STDIN line 8: `i;`
> package Top;
   ? identifier `Top` in use
   ? error occurred in or before STDIN line 9: `package Top;`
> i;
   ? `i` is undefined
   ? error occurred in or before STDIN line 10: `i;`
> package Current;
   ? identifier `Top` in use
   ? error occurred in or before STDIN line 11: `package Current;`
> Current;
 Top (T)

```

Unfortunately, it is possible to declare local variables with a prefix.
```
> package Test;
> proc f() {int Test::i = 5; return(Test::i);};
> f();
5
> listvar(Test);
// Test                           [0]  package Test (N)
```

However, the only way the Current package can change is through proc calls.
Therefore, local variables with a prefix are quite useless unless they are exported.



-------------------------------

Conclusion: The Singular language is completely different from C or Julia.
Singular's identifier resolution is the death of compilation, and further
difficulties arise because variable declarations leak outside of blocks.

```
proc f(...) {
    ...
    if (...) {
        int i;
    }
    i; // it is that int OR whatever it was before
    ...
}
```

In order to maintain compatibility with the Singular language, the Julia interpreter
currently maintains _all_ variables (local and global) in a lookup table.
With an `int i` inside a procedure, the julia code could go faster if there was,
instead of an entry in a table, a `local i::Int` directly in the julia code.
However, the correctness of such a transformation can only be determined through
difficult code analysis.


In terms of the local variables of a procedure, the lexical presence of any of
the following commands in a procedure will immediately prevent _every local variable_
from going faster. This list is probably not complete.

- `execute` https://www.singular.uni-kl.de/Manual/4-0-3/sing_289.htm#SEC328

- backticks https://www.singular.uni-kl.de/Manual/4-0-3/sing_36.htm#IDX106

- `kill` https://www.singular.uni-kl.de/Manual/4-0-3/sing_325.htm#SEC364

The following keywords simply cannot be dealt with and will be considered a syntax error.

- `parameter`

- `keepring`

The following commands will immediately prevent _every ring dependent local variable_
from going faster. This list is probably also not complete.

- Any command that changes the current basering `ring r = `, `setring r`, ect.

- `imap`, `fetch` https://www.singular.uni-kl.de/Manual/4-0-3/sing_295.htm#SEC334


There are probably more commands that are immediate showstoppers. Other strange
commands with unknown effects:

- `defined` The main problem is that `defined` can take a string argument. https://www.singular.uni-kl.de/Manual/4-0-3/sing_275.htm#SEC314

- `nameof` https://www.singular.uni-kl.de/Manual/4-0-3/sing_355.htm#SEC394

- `eval` https://www.singular.uni-kl.de/Manual/4-0-3/sing_286.htm#SEC325

- `getdump` https://www.singular.uni-kl.de/Manual/4-0-3/sing_306.htm#SEC345

- `killattrib` https://www.singular.uni-kl.de/Manual/4-0-3/sing_326.htm#SEC365

- `monitor` https://www.singular.uni-kl.de/Manual/4-0-3/sing_349.htm#SEC388

- `names` https://www.singular.uni-kl.de/Manual/4-0-3/sing_356.htm#SEC395



----------------------------------------------

examples of fast/slow variables.


`i` gets the slow treament everywhere (even with real code analysis):
```
proc f(...) {
    ...
    if (...)  {
        i;
    } else {
        int i = 5;
    }
    i;
}
```

`i` could get the fast treament after the declaration, but we will not support mixing fast/slow variables, so it will actually get the slow treatment everywhere.
```
proc f(...) {
    ...
    i;          // slow
    ...

    int i;      // this sets i to 0
    if (...) {
        i;      // could be fast
    } else {
        i;      // could be fast
    }
    i;          // could be fast
}
```

Determining that `i` can be fast everywhere here would require real code analysis:
```
proc f(...) {
    if (...) {
        for (int i = 0, i < ..., i++) {
            ...
        }
    } else {
        for (int i = 0, i < ..., i++) {
            ...
        }
    }
    ...
}
```

Rewriting the previous example as follows gives `i` the fast treatment everywhere with easy code analysis:
```
proc f(...) {
    int i;
    if (...) {
        for (i = 0, i < ..., i++) {
            ... // fast i in here
        }
    } else {
        for (i = 0, i < ..., i++) {
            ... // fast i in here
        }
    }
    ... // fast i in here
}
```


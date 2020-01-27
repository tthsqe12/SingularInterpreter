# benchmarks

```
| task            | singular  |    julia  |   julia'  |
recursive calls and int arithmetic:
| fib1(12)        |        7  |        1  |       58  |
| fib1(15)        |       21  |        4  |        3  |
| fib1(18)        |       70  |       17  |       12  |
| fib1(21)        |      288  |       78  |       54  |
| fib1(24)        |     1209  |      316  |      216  |
| fib1(27)        |     5132  |     1262  |      856  |
for loops with bigint add:
| fib2(  1000)    |        7  |        9  |       59  |
| fib2( 10000)    |       78  |       36  |        4  |
| fib2( 40000)    |      324  |      264  |      133  |
| fib2(160000)    |     1523  |      900  |      391  |
for loops with int arithmetic:
| fib2m(  1000)   |        9  |        4  |        0  |
| fib2m( 10000)   |       92  |       34  |        0  |
| fib2m( 40000)   |      341  |      125  |        1  |
| fib2m(160000)   |     1359  |      474  |        3  |
| fib2m(640000)   |     5442  |     1849  |        8  |
bigint mul:
| fib3(10^3)      |        0  |        6  |      208  |
| fib3(10^4)      |        0  |        1  |        1  |
| fib3(10^5)      |        1  |        1  |        1  |
| fib3(10^6)      |       10  |       18  |       14  |
| fib3(10^7)      |      137  |      199  |      201  |
recursively list all n! permutations:
| permute(3)      |        0  |        1  |       58  |
| permute(4)      |        2  |       37  |       39  |
| permute(5)      |       14  |       38  |       36  |
| permute(6)      |       90  |       74  |       51  |
| permute(7)      |      678  |      285  |      131  |
| permute(8)      |     5869  |     2310  |      950  |
Stanley-Reisner:
| Rina 9 vars     |   872000  |   330000  |   122000  |
| Rina 10 vars    |  2683000  |           |   377000  |
```

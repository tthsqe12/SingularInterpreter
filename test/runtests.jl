using SingularInterpreter

#include("basics.jl")

for a in ("assign", "int", "intvec", "intmat", "bigintmat", "list", "poly", "proc")
    SingularInterpreter.reset_runtime()
    println("running ", a, ".sing")
    execute(read(a*".sing", String))
end

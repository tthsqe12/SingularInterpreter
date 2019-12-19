using SingularInterpreter

include("basics.jl")

for a in ("assign", "int", "intvec", "intmat", "bigintmat", "list", "poly", "proc")
    SingularInterpreter.reset_runtime()
    println("running ", a, ".sing")
    execute(read(joinpath(dirname(@__FILE__), a * ".sing"), String))
end

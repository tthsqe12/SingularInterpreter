using Test

using SingularInterpreter
using SingularInterpreter: rtcolon, rtequalequal, rtnot, rtand, rtor, SIntVec, SString

for a in ["assign", "int", "intvec", "intmat", "bigintmat", "list",
          "tuple", "proc", "poly", "ideal", "ring", "commands", "string"]
    SingularInterpreter.reset_runtime()
    jlfile = joinpath(dirname(@__FILE__), a * ".jl")
    if isfile(jlfile)
        println("running ", a, ".jl")
        include(jlfile)
    end
    println("running ", a, ".sing")
    execute(read(joinpath(dirname(@__FILE__), a * ".sing"), String))
end

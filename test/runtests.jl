using Test

using SingularInterpreter
using SingularInterpreter: rtcolon, rtequalequal, rtnot, rtand, rtor, Sintvec, Sstring

for a in ["int", "string", "intvec", "intmat", "bigintmat", "list", "ring",
          "number", "poly", "vector", "ideal", "module", "matrix", "map",
          "assign", "tuple", "proc", "resolution", "commands", "sleftv"]
    SingularInterpreter.reset_runtime()
    jlfile = joinpath(dirname(@__FILE__), a * ".jl")
    if isfile(jlfile)
        println("running ", a, ".jl")
        include(jlfile)
    end

    singfile = joinpath(dirname(@__FILE__), a * ".sing")
    if isfile(singfile)
        for opt in (false, true)
            SingularInterpreter.reset_runtime()
            SingularInterpreter.rtGlobal.optimize_locals = opt
            println("running ", a, ".sing [optimize_locals = $opt]")
            execute(read(singfile, String))
        end
    end
end

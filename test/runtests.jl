using Test

using SingularInterpreter
using SingularInterpreter: rtcolon, rtequalequal, rtnot, rtand, rtor, SIntVec, SString

for a in ["assign", "int", "intvec", "intmat", "bigintmat", "list",
          "tuple", "proc", "poly", "vector", "ideal", "ring", "commands", "string",
          "sleftv", "number"]
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

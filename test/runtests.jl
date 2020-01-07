using SingularInterpreter

#include("basics.jl")

for a in ("basics", "proc", "list")
    SingularInterpreter.reset_runtime()
    println("running ", a, ".sing")
    execute(read(a*".sing", String))
end

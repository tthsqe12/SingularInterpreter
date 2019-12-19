using SingularInterpreter

include("basics.jl")
execute(read(joinpath(dirname(@__FILE__), "basics.sing"), String))

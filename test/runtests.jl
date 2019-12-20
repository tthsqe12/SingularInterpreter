using SingularInterpreter

include("basics.jl")
execute(read("basics.sing", String))
execute(read("proc.sing", String))
execute(read("list.sing", String))

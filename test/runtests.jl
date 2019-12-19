using SingularInterpreter

include("basics.jl")

println("""\n\nexecute'int "basics.sing" file:\n""")

execute(read(joinpath(dirname(@__FILE__), "basics.sing"), String))

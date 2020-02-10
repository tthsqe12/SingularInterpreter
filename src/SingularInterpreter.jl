module SingularInterpreter

import Base: abs, checkbounds, deepcopy, deepcopy_internal,
             denominator, div, divrem, exponent,
             gcd, gcdx, getindex, inv, isequal, isless, lcm, length,
             mod, numerator, one, reduce, rem, setindex!, show,
             zero, +, -, *, ==, ^, &, |, <<, >>, ~, <=, >=, <, >, //,
             /, !=

import Libdl

export execute

using ReplMaker

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libsingular = joinpath(pkgdir, "local", "lib", "libSingular")

prefix = realpath(joinpath(@__DIR__, "..", "local"))

function __init__()
    # Initialise Singular
    binSingular = joinpath(prefix, "bin", "Singular")
    ENV["SINGULAR_EXECUTABLE"] = binSingular
    libSingular.siInit(binSingular)

    s = split(get(ENV, "SINGULARPATH", ""), ":")
    push!(s, realpath(joinpath(@__DIR__, "..", "deps", "Singular" ,"Singular", "LIB")))
    rtGlobal.SearchPath = filter(isdir, s)

    if isinteractive() # Base.active_repl not defined otherwise
        initrepl(SingularInterpreter.execute,
                 prompt_text  = "Sing> ",
                 prompt_color = :blue,
                 start_key    = '}',
                 mode_name    = :singular_mode,
                 startup_text = false)
    end
end

include("LibSingular.jl")

include("types.jl")
include("tables.jl")
include("transpiler.jl")
include("runtime_declare.jl")
include("runtime_basic.jl")
include("runtime_ops.jl")
include("runtime_cmds.jl")

end # module

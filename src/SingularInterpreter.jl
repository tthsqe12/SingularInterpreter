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
        @async begin
            iter = 0
            # wait for active_repl to exist
            while !isdefined(Base, :active_repl) && iter < 20
                sleep(0.05)
                iter += 1
            end
            if isdefined(Base, :active_repl)
                initrepl(SingularInterpreter.execute,
                         prompt_text  = "sing> ",
                         prompt_color = :yellow,
                         start_key    = '}',
                         mode_name    = :singular_mode,
                         startup_text = false,
                         )
            else
                @warn "REPL initialization for Singular mode failed"
            end
        end
    end
end

include("LibSingular.jl")

include("types.jl")
include("runtime_global.jl")
include("tables.jl")
include("transpiler.jl")
include("runtime_basic.jl")
include("runtime_declare.jl")
include("runtime_convert.jl")
include("runtime_assign.jl")
include("runtime_index.jl")
include("runtime_print.jl")
include("runtime_ops.jl")
include("runtime_cmds.jl")
include("runtime_bridge.jl")

end # module

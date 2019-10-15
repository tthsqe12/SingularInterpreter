module SingularInterpreter

import Base: abs, checkbounds, deepcopy, deepcopy_internal,
             denominator, div, divrem, exponent,
             gcd, gcdx, getindex, inv, isequal, isless, lcm, length,
             mod, numerator, one, reduce, rem, setindex!, show,
             zero, +, -, *, ==, ^, &, |, <<, >>, ~, <=, >=, <, >, //,
             /, !=

export execute

const pkgdir = realpath(joinpath(dirname(@__FILE__), ".."))
const libsingular = joinpath(pkgdir, "local", "lib", "libSingular")

prefix = realpath(joinpath(@__DIR__, "..", "local"))

function __init__()
   # Initialise Singular
   binSingular = joinpath(prefix, "bin", "Singular")
   ENV["SINGULAR_EXECUTABLE"] = binSingular
   libSingular.siInit(binSingular)
end

include("LibSingular.jl")
include("Transpiler.jl")

end # module

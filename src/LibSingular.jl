module libSingular

import Libdl
using CxxWrap
@wrapmodule(realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularwrap." * Libdl.dlext)))

function __init__()
   @initcxx
end

include("libsingular/LibSingularTypes.jl")


function n_Init(b::BigInt, r::ring)
    return n_InitMPZ_internal(pointer_from_objref(b), r)
end


function lookupIdentifierInRing(s::String, r::ring)
    ok, p = p_mInit_helper(Base.Vector{UInt8}(s*"\0"), r)
    if ok == 0
        return false, p
    end
    if p == Ptr{Nothing}(0)
        return true, nInit_zero_helper()
    elseif p_IsConstant(p, r) != 0
        return true, pGetConstantCoeff_helper(p, r)
    else
        return true, p
    end
end


function createRing(coeff::Array{Any, 1}, vars::Array{String, 1}, ord::Array{OrderingEntry,1})
    b = Cint[length(ord)]
    offset = 0
    c_count = 0
    l = 0;
    for i in ord
        l += 1;
        if i.order == ringorder_c || i.order == ringorder_C
            if c_count == 0
                push!(b, i.order)
                push!(b, 0)
                push!(b, 0)
                push!(b, 0)
            else
                error("more than one ordering c/C specified")
            end
        else
            blocksize = i.blocksize
            if i.order == ringorder_wp ||
               i.order == ringorder_ws ||
               i.order == ringorder_Wp ||
               i.order == ringorder_Ws
                if blocksize <= 0 || length(i.weights) != blocksize
                    error("internal error")
                end
            elseif i.order == ringorder_M
                if blocksize <= 0 || length(i.weights) != blocksize*blocksize
                    error("internal error")
                end
            elseif i.order == ringorder_lp ||
                    i.order == ringorder_rp ||
                    i.order == ringorder_dp ||
                    i.order == ringorder_Dp ||
                    i.order == ringorder_ls ||
                    i.order == ringorder_ds ||
                    i.order == ringorder_Ds
                if length(i.weights) != 0
                    error("internal error")
                end
                if blocksize <= 0
                    blocksize = 1
                end
                if l == length(ord)
                    if length(vars) - offset >= blocksize
                        blocksize = length(vars) - offset
                    else
                        error("mismatch of number of vars and ordering")
                    end
                end
            else
                error("unknown ordering specified")
            end
            push!(b, i.order)
            push!(b, offset + 1)
            offset += blocksize
            push!(b, offset)
            push!(b, length(i.weights))
            for j in i.weights
                push!(b, j)
            end
        end
    end
    if length(vars) != offset
        error("mismatch of number of vars (", length(vars), ") and ordering (", offset, " vars)")
    end
    if c_count == 0
        b[1] += 1
        push!(b, ringorder_C)
        push!(b, 0)
        push!(b, 0)
        push!(b, 0)
    end

    if coeff[1] isa Int
        if length(coeff) > 1
            cf = nInitChar_transcendental_helper(coeff[1], [pointer(Base.Vector{UInt8}(string(s)*"\0")) for s in coeff[2:end]])
        else
            cf = nInitChar_simple_helper(coeff[1])
        end
    elseif coeff[1] == "real" || coeff[1] == "complex"
        complex = (coeff[1] == "complex")
        imag_unit = "i"
        f1 = f2 = 0
        l = 2
        if l <= length(coeff) && isa(coeff[l], Int)
            f1 = f2 = coeff[l]
            l += 1
            if l <= length(coeff) && isa(coeff[l], Int)
                f2 = coeff[l]
                l += 1
            end
        end
        if l <= length(coeff) && isa(coeff[l], String)
            complex = true
            imag_unit = coeff[l]
        end
        if complex
            cf = nInitChar_complex_helper(f1, f2, Base.Vector{UInt8}(string(image_unit)*"\0"))
        else
            cf = nInitChar_real_helper(f1, f2)
        end
    else
        error("bad coeffs")
    end

    return rDefault_weighted_helper(cf, [pointer(Base.Vector{UInt8}(string(s)*"\0")) for s in vars], b)
end

end # module

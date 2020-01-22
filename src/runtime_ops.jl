#=
the transpiler DOES NOT produce names for any arguments of these functions
    SINGULAR    JULIA
    a[i]        rtgetindex(a, i)
    a[i] = b    rtsetindex_more(a, i, b)
    a[i, j]     rtgetindex(a, i, j)
    a[i, j] = b rtsetindex_more(a, i, j, b)
    a + b       rtplus(a, b)
    -a          rtminus(a)
    a - b       rtminus(a, b)
    a*b         rttimes(a, b)
    a/b         rtdivide(a, b)
    a / b       rtdivide(a, b)
    a div b     rtdiv(a, b)
    a % b       rtmod(a, b)
    a mod b     rtmod(a, b)
    a^b         rtpower(a, b)
    a == b      rtequalequal(a, b)
    a != b      rtnotequal(a, b)
    a >= b      rtgreaterequal(a, b)
    a > b       rtgreater(a, b)
    a <= b      rtlessequal(a, b)
    a < b       rtless(a, b)
    a && b      rtand(a, b)
    a and b     rtand(a, b)
    a || b      rtor(a, b)
    a or b      rtor(a, b)
    !a          rtnot(a)
    not a       rtnot(a)
    a .. b      rtdotdot(a, b)
    a : b       rtcolon(a, b)
=#

#### list get/setindex ####

rtgetindex(a::_List, i::Union{Int, _IntVec}) = rtgetindex(rt_ref(a), rt_ref(i))

function rtgetindex(a::SListData, i::Int)
    @expensive_assert object_is_ok(a)
    b = a.data[i]
    if isa(b, SList)
        r = b.list
        r.back = a
        return r
    else
        return rt_ref(b)
    end
end

function rtgetindex(a::SListData, i::Vector{Int})
    r = Any[rtgetindex(a, t) for t in i]
    return length(r) == 1 ? r[1] : STuple(r)
end


rtsetindex_more(a::_List, i::Union{Int, _IntVec}, b)= rtsetindex_more(rt_ref(a), rt_ref(i), b)

function rtsetindex_more(a::SListData, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return empty_tuple
end

function rtsetindex_more(a::SListData, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    rt_setindex(a, i, popfirst!(b.list))
    return b
end

function rtsetindex_more(a::SListData, i::Vector{Int}, b)
    @assert !isa(b, STuple)
    if length(i) == 1
        rt_setindex(a, i[1], b)
        return empty_tuple
    else
        @error_check(!isempty(i), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::SListData, i::Vector{Int}, b::STuple)
    n = length(i)
    @error_check(length(b.list) >= n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i[t], b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end

rtsetindex_last(a::_List, i::Union{Int, _IntVec}, b)= rtsetindex_more(rt_ref(a), rt_ref(i), b)

function rtsetindex_last(a::SListData, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return
end

function rtsetindex_last(a::SListData, i::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    rt_setindex(a, i, b.list[1])
    return
end

function rtsetindex_last(a::SListData, i::Vector{Int}, b)
    @assert !isa(b, STuple)
    if length(i) == 1
        rt_setindex(a, i[1], b)
    else
        @error_check(!isempty(i), "argument mismatch in assignment")
    end
    return
end

function rtsetindex_last(a::SListData, i::Vector{Int}, b::STuple)
    n = length(i)
    @error_check(length(b.list) == n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i[t], b.list[t])
    end
    return
end


function rt_setindex(a::SListData, i::Int, b)
    @expensive_assert object_is_ok(a)
    bcopy = rt_copy(b) # copy before the possible resize
    r = a.data
    count_change = 0
    if isa(bcopy, Nothing)
        if i > length(r)
            return
        end
        count_change = -Int(rt_is_ring_dep(r[i]))
        r[i] = nothing
        # putting nothing at the end pops the list
        while !isempty(r) && isa(r[end], Nothing)
            pop!(r)
        end
    else
        # nothing fills out a list when we assign past the end
        org_len = length(r)
        if i > org_len
            resize!(r, i)
            while org_len + 1 < i
                r[org_len + 1] = nothing
                org_len += 1
            end
            count_change = Int(rt_is_ring_dep(bcopy))
        else
            count_change = Int(rt_is_ring_dep(bcopy)) - Int(rt_is_ring_dep(r[i]))
        end
        r[i] = bcopy
    end
    if count_change != 0
        rt_fix_setindex(a, count_change)
    end
    @expensive_assert object_is_ok(a)
    return
end

# we should at least maintain the integrity of the list data structure
function rt_fix_setindex(a::SListData, count_change::Int)
    new_parent = a.parent
    a.ring_dep_count += count_change
    if a.ring_dep_count > 0
        if !new_parent.valid
            new_parent = rt_basering()  # try to get a valid ring from somewhere
            new_parent.valid || rt_warn("list has ring dependent elements but no basering")
        end
    else
        new_parent = rtInvalidRing
    end
    new_count_change = Int(new_parent.valid) - Int(a.parent.valid)
    a.parent = new_parent
    if new_count_change != 0
        rt_fix_setindex(a.back, new_count_change)
    end
end

# move a name of a global list when its ring independence status has changed
function rt_fix_setindex(a::Symbol, count_change::Int)
    if count_change > 0
        # name became ring dependent
        # move the name from the current package to the current ring
        # TODO: might get the package data from somewhere else
        @assert count_change == 1
        first = true
        for p in (rtGlobal.callstack[end].current_package, :Top)
            if haskey(rtGlobal.vars, p) && haskey(rtGlobal.vars[p], a)
                b = rtGlobal.vars[p][a]
                if isa(b, SList)
                    R = rt_basering()
                    if R.valid
                        if haskey(R.vars, a)
                            rt_warn("overwriting name " * string(a.name) * " when moving global list into basering")
                        end
                        R.vars[a] = b
                        delete!(rtGlobal.vars[p], a)
                        return
                    else
                        rt_error("global list became ring dependent but there is no basering")
                    end
                else
                    rt_error("global list became ring dependent but its name no longer points to a list")
                end
            else
                first || rt_error("global list became ring dependent but its name is not in the package " * string(p))
            end
            first = false
        end
    elseif count_change < 0
        # name became ring independent
        # move the name from the current ring to the current package
        @assert count_change == -1
        R = rt_basering()
        if R.valid && haskey(R.vars, a)
            b = R.vars[a]
            if isa(b, SList)
                p = rtGlobal.callstack[end].current_package
                if haskey(rtGlobal.vars, p)
                    d = rtGlobal.vars[p]
                    if haskey(d, a)
                        rt_warn("overwriting name " * string(a.name) * " when moving global list out of basering")
                    end
                    d[a] = b
                else
                    rtGlobal.vars[p] = Dict{Symbol, Any}[a => b]
                end
                delete!(R.vars, a)
                return
            else
                rt_error("global list became ring independent but its name in basering no longer points to a list")
            end
        else
            rt_error("global list became ring independent but its name is not in basering")
        end
    end
end

function rt_fix_setindex(a::Nothing, count_change::Int)
    return
end

function rt_fix_setindex(a, count_change::Int)
    error("internal error in rt_fix_setindex: back member needs to be Nothing|Symbol|SListData")
end


#### intvec get/setindex ####

rtgetindex(a::_IntVec, i::Union{Int, _IntVec}) = rtgetindex(rt_ref(a), rt_ref(i))

function rtgetindex(a::Vector{Int}, i::Int)
    return a[i]
end

function rtgetindex(a::Vector{Int}, i::Vector{Int})
    r = Any[a[t] for t in i]
    return length(r) == 1 ? r[1] : STuple(r)
end

rtsetindex_more(a::_IntVec, i::Union{Int, _IntVec}, b) = rtgetindex(rt_ref(a), rt_ref(i), b)

function rtsetindex_more(a::Vector{Int}, i::Int, b)
    @assert !isa(b, STuple)
    a[i] = rt_convert2int(b)
    return empty_tuple
end

function rtsetindex_more(a::Vector{Int}, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    a[i] = rt_convert2int(popfirst!(b))
    return b
end

function rtsetindex_more(a::Vector{Int}, i::Vector{Int}, b)
    @assert !isa(b, STuple)
    if length(i) == 1
        a[i[1]] = rt_convert2int(b)
        return empty_tuple
    else
        @error_check(!isempty(i), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::Vector{Int}, i::Vector{Int}, b::STuple)
    n = length(i)
    @error_check(length(b.data) >= n, "argument mismatch in assignment")
    if a === i
        i = deepcopy(i)
    end
    for t in 1:n
        a[i[t]] = rt_convert2int(b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end


#### intmat/bigintmat get/setindex ####

rtgetindex(a::Union{_IntMat, _BigIntMat},
           i::Union{Int, _IntVec},
           j::Union{Int, _IntVec}) =
    rtgetindex(rt_ref(a), rt_ref(i), rt_ref(j))

function rtgetindex(a::Union{Array{Int, 2}, Array{BigInt, 2}},
                    i::Union{Int, Vector{Int}},
                    j::Union{Int, Vector{Int}})
    r = Any[]
    for s in i
        for t in j
            push!(r, a[s, t])
        end
    end
    return length(r) == 1 ? r[1] : STuple(r)
end


rtsetindex_more(a::Union{_IntMat, _BigIntMat},
           i::Union{Int, _IntVec},
           j::Union{Int, _IntVec},
           b) =
    rtsetindex_more(rt_ref(a), rt_ref(i), rt_ref(j), b)

function rtsetindex_more(a::Union{Array{Int, 2}, Array{BigInt, 2}},
                    i::Union{Int, Vector{Int}},
                    j::Union{Int, Vector{Int}},
                    b)
    @assert !isa(b, STuple)
    first = true
    for s in i
        for t in j
            @error_check(first, "argument mismatch in assignment")
            if isa(a, Array{Int, 2})
                a[s, t] = rt_convert2int(b)
            else
                a[s, t] = rt_convert2bigint(b)
            end
            first = false
        end
    end
    return first ? b : empty_tuple
end

function rtsetindex_more(a::Union{Array{Int, 2}, Array{BigInt, 2}},
                    i::Union{Int, Vector{Int}},
                    j::Union{Int, Vector{Int}},
                    b::STuple)
    for s in i
        for t in j
            @error_check(!isempty(b.list), "argument mismatch in assignment")
            if isa(a, Array{Int, 2})
                a[s, t] = rt_convert2int(popfirst!(b.list))
            else
                a[s, t] = rt_convert2bigint(popfirst!(b.list))
            end
        end
    end
    return b
end



#### ideal get/setindex ####

rtgetindex(a::SIdeal, i::Int) = rtgetindex(a.ideal, i)

function rtgetindex(a::SIdealData, i::Int)
    n = Int(libSingular.ngens(a.ideal_ptr))
    @error_check(1 <= i <= n, "ideal index out of range")
    r1 = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
    r2 = libSingular.p_Copy(r1, a.parent.ring_ptr)
    return SPoly(r2, a.parent)
end

rtsetindex_more(a::SIdeal, i::Int, b) = rtsetindex_more(a.ideal, i, b)

function rtsetindex_more(a::SIdealData, i::Int, b)
    @error_check(i > 0, "ideal index must be positive for assignment")
    libSingular.id_setindex_fancy(a.ideal_ptr, Cint(i), rt_convert2poly_ptr(b, a.parent), a.parent.ring_ptr)
    return empty_tuple
end





function rtplus(a::_List, b::_List)
    A = rt_edit(a)
    B = rt_edit(b)
    if A.parent.valid
        newparent = A.parent
        @warn_check(!B.parent.valid || newparent == B.parent, "funny thing happened while adding lists")
    else
        newparent = B.parent
    end
    return SList(SListData(vcat(A.data, B.data), newparent,
                                 A.ring_dep_count + B.ring_dep_count, nothing))
end

rtplus(a::Int, b::Int) = Base.checked_add(a, b)
rtplus(a::Int, b::BigInt) = a + b
rtplus(a::BigInt, b::Int) = a + b
rtplus(a::BigInt, b::BigInt) = a + b

rtminus(a::Int) = Base.checked_neg(a)
rtminus(a::BigInt) = -a

rtminus(a::Int, b::Int) = Base.checked_sub(a, b)
rtminus(a::Int, b::BigInt) = a - b
rtminus(a::BigInt, b::Int) = a - b
rtminus(a::BigInt, b::BigInt) = a - b

rttimes(a::Int, b::Int) = Base.checked_mul(a, b)
rttimes(a::Int, b::BigInt) = a * b
rttimes(a::BigInt, b::Int) = a * b
rttimes(a::BigInt, b::BigInt) = a * b

# op(number, number)

function rtplus(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    r1 = libSingular.n_Add(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "negating outside of basering")
    r1 = libSingular.n_Neg(a.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    r1 = libSingular.n_Sub(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.n_Mult(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(poly, poly)

function rtplus(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.p_Copy(b.poly_ptr, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly)
    rt_warn(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "negating outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    r1 = libSingular.p_Neg(a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.p_Copy(b.poly_ptr, b.parent.ring_ptr)
    r1 = libSingular.p_Sub(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.pp_Mult_qq(a.poly_ptr, b.poly_ptr, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(ideal, ideal)

function rtplus(a::_Ideal, b::_Ideal)
    A::SIdealData = rt_ref(a)
    B::SIdealData = rt_ref(b)
    @error_check(A.parent.ring_ptr.cpp_object == B.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(A.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    r1 = libSingular.id_Add(A.ideal_ptr, B.ideal_ptr, A.parent.ring_ptr)
    return SIdeal(SIdealData(r1, a.parent))
end

function rtminus(a::_Ideal)
    return rttimes(a, -1)
end

function rtminus(a::_Ideal, b::_Ideal)
    rt_error("cannot subtract ideals")
    return rt_defaultconstructor_ideal()
end

function rttimes(a::_Ideal, b::_Ideal)
    A::SIdealData = rt_ref(a)
    B::SIdealData = rt_ref(b)
    @error_check(A.parent.ring_ptr.cpp_object == B.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(A.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.id_Mult(A.ideal_ptr, B.ideal_ptr, A.parent.ring_ptr)
    return SIdeal(SIdealData(r1, A.parent))
end

# op(ideal, number|poly)

function rtplus(a::SIdeal, b::Union{BigInt, Int, SNumber, SPoly})
    return rtplus(a.ideal, b)
end

function rtplus(a::SIdealData, b::Union{BigInt, Int, SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Add(a.ideal_ptr, b2, a.parent.ring_ptr)
    libSingular.id_Delete(b2, a.parent.ring_ptr) # id_Add did not consume b2
    return SIdeal(SIdealData(r1, a.parent))
end

function rttimes(a::SIdeal, b::Union{BigInt, Int, SNumber, SPoly})
    return rttime(a.ideal, b)
end

function rttimes(a::SIdealData, b::Union{BigInt, Int, SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Mult(a.ideal_ptr, b2, a.parent.ring_ptr)
    libSingular.id_Delete(b2, a.parent.ring_ptr) # id_Mult did not consume b2
    return SIdeal(SIdealData(r1, a.parent))
end


# op(number, int)

function rtplus(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Add(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Sub(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Mult(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(int, number)

function rtplus(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Add(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Sub(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Mult(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(poly, int)

function rtplus(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Sub(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(poly, number)

function rtplus(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Sub(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(int, poly)

function rtplus(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Sub(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(number, poly)

function rtplus(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Sub(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end




function rtplus(a::STuple, b)
    @assert !isa(b, STuple)
    a.list[1] = rt_copy(rtplus(a.list[1], b))
    return a
end

function rtplus(a, b::STuple)
    @assert !isa(a, STuple)
    b.list[1] = rt_copy(rtplus(a, b.list[1]))
    return b
end

function rtplus(a::STuple, b::STuple)
    return STuple(Any[rt_copy(rtplus(a.list[i], b.list[i])) for i in 1:min(length(a.list), length(b.list))])
end

function rtplus(a::_IntVec, b::_IntVec)
    A = rt_ref(a)
    B = rt_ref(b)
    return SIntVec([Base.checked_add(i <= length(A) ? A[i] : 0,
                                     i <= length(B) ? B[i] : 0)
                                   for i in 1:max(length(A), length(B))])
end

function rtplus(a::_IntVec, b::Int)
    A = rt_ref(a)
    return SIntVec([rtplus(A[i], b) for i in 1:length(A)])
end

rtplus(a::Int, b::_IntVec) = rtplus(b, a)

function rtplus(a::_IntMat, b::Int)
    A = rt_edit(a)
    nrows, ncols = size(A)
    for i in 1:min(nrows, ncols)
        A[i, i] = rtplus(A[i, i], b)
    end
    return SIntMat(A)
end

function rtplus(a::Int, b::_IntMat)
    B = rt_edit(b)
    nrows, ncols = size(B)
    for i in 1:min(nrows, ncols)
        B[i, i] = rtplus(a, B[i, i])
    end
    return SIntMat(B)
end

function rtplus(a::_IntMat, b::_IntMat)
    return SIntMat(rt_ref(a) + rt_ref(b))
end

function rtplus(a::SString, b::SString)
    return SString(a.string * b.string)
end

function stimes(a::_BigIntMat, b::_BigIntMat)
    return SBigIntMat(rt_ref(a) * rt_ref(b))
end

function stimes(a::Int, b::_BigIntMat)
    return SBigIntMat(a*rt_ref(b))
end

rtpower(a::Int, b::Int) = a ^ b
rtpower(a::Int, b::BigInt) = a ^ b
rtpower(a::BigInt, b::Int) = a ^ b
rtpower(a::BigInt, b::BigInt) = a ^ b

function rtpower(a::SNumber, b::Int)
    absb = abs(b)
    @error_check(absb <= typemax(Cint), "number power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    if b < 0
        @error_check(!libSingular.n_IsZero(a.number_ptr, a.parent.ring_ptr), "cannot divide by zero")
        ai = libSingular.n_Invers(a.number_ptr, a.parent.ring_ptr)
        r1 = libSingular.n_Power(ai, Cint(absb), a.parent.ring_ptr)
        libSingular.n_Delete(ai, a.parent.ring_ptr)
    else
        r1 = libSingular.n_Power(a.number_ptr, Cint(absb), a.parent.ring_ptr)
    end
    return SNumber(r1, a.parent)
end

function rtpower(a::SPoly, b::Int)
    @error_check(0 <= b <= typemax(Cint), "polynomial power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = Cint(b)
    r1 = libSingular.p_Power(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtpower(a::SIdeal, b::Int)
    return rtpower(a.ideal, b)
end

function rtpower(a::SIdealData, b::Int)
    @error_check(0 <= b <= typemax(Cint), "ideal power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    r1 = libSingular.id_Power(a.ideal_ptr, Cint(b), a.parent.ring_ptr)
    return SIdeal(SIdealData(r1, a.parent))
end


function rtdivide(a::Union{Int, BigInt}, b::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "integer division using `/` without a basering; use `div` instead")
    b1 = libSingular.n_Init(b, R.ring_ptr)
    if libSingular.n_IsZero(b1, R.ring_ptr)
        libSingular.n_Delete(b1, R.ring_ptr)
        rt_error("cannot divide be zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, R.ring_ptr)
    r1 = libSingular.n_Div(a1, b1, R.ring_ptr)
    libSingular.n_Delete(a1, R.ring_ptr)
    libSingular.n_Delete(b1, R.ring_ptr)
    return SNumber(r1, R)
end

function rtdivide(a::Union{Int, BigInt}, b::SNumber)
    @warn_check(b.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    if libSingular.n_IsZero(b.number_ptr, b.parent.ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, b.parent.ring_ptr)
    r1 = libSingular.n_Div(a1, b.number_ptr, b.parent.ring_ptr)
    libSingular.n_Delete(a1, b.parent.ring_ptr)
    return SNumber(r1, b.parent)
end

function rtdivide(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    if libSingular.n_IsZero(b1, rt_basering().ring_ptr)
        libSingular.n_Delete(b1, rt_basering().ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtdivide(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot divide from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    if libSingular.n_IsZero(b.number_ptr, b.parent.ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end


rtdiv(a::Int, b::Int) = Base.checked_div(a, b)
rtdiv(a::Int, b::BigInt) = div(a, b)
rtdiv(a::BigInt, b::Int) = div(a, b)
rtdiv(a::BigInt, b::BigInt) = div(a, b)

rtmod(a::Int, b::Int) = Base.checked_mod(a, b)
rtmod(a::Int, b::BigInt) = mod(a, b)
rtmod(a::BigInt, b::Int) = mod(a, b)
rtmod(a::BigInt, b::BigInt) = mod(a, b)


rtequalequal(a::STuple, b) = rtequalequal(a.list[1], b)
rtequalequal(a, b::STuple) = rtequalequal(b, a)

rtequalequal(a::STuple, b::STuple) =
    Int(all(rtequalequal(x, y) != 0 for (x, y) in zip(a, b)))

rtequalequal(a::Int, b::Int) = Int(a == b)
rtequalequal(a::Int, b::BigInt) = Int(a == b)
rtequalequal(a::BigInt, b::Int) = Int(a == b)
rtequalequal(a::BigInt, b::BigInt) = Int(a == b)

rtequalequal(a::SString, b::SString) = Int(a.string == b.string)

rtequalequal(a::_IntVec, b::_IntVec) = Int(rt_ref(a) == rt_ref(b))

rtequalequal(a::Union{Int, BigInt}, b::SNumber) = rtequalequal(b, a)

function rtequalequal(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "comparing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r = Int(libSingular.n_Equal(a.number_ptr, b1, a.parent.ring_ptr))
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return r
end

function rtequalequal(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot compare from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "comparing outside of basering")
    return Int(libSingular.n_Equal(a.number_ptr, b.number_ptr, a.parent.ring_ptr))
end

rtequalequal(a::Union{Int, BigInt, Number}, b::SPoly) = rtequalequal(b, a)

function rtequalequal(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "comparing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r = Int(libSingular.p_EqualPolys(a.poly_ptr, b2, a.parent.ring_ptr))
    libSingular.p_Delete(b2, a.parent.ring_ptr)
    return r
end

function rtequalequal(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot compare from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "comparing outside of basering")
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r = Int(libSingular.p_EqualPolys(a.poly_ptr, b2, a.parent.ring_ptr))
    libSingular.p_Delete(b2, a.parent.ring_ptr)
    return r
end

function rtequalequal(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot compare from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "comparing outside of basering")
    return Int(libSingular.p_EqualPolys(a.poly_ptr, b.poly_ptr, a.parent.ring_ptr))
end

rtequalequal(a::SIdeal, b::Int) = rtequalequal(rt_ref(a), b)

function rtequalequal(a::SIdealData, b::Union{Int, BigInt})
    # compare a and b as matrices!
    a1 = a.ideal_ptr
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    b3 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(b3, b2, 0)
    r = Int(libSingular.mp_Equal(a1, b3, a.parent.ring_ptr))
    libSingular.id_Delete(b3, a.parent.ring_ptr)
    return r
end


rtequalequal(a::_List, b::_List) = rtequalequal(rt_ref(a), rt_ref(b))

function rtequalequal(a::SListData, b::SListData)
    n = length(a.data)
    if n != length(b.data)
        return 0
    end
    for i in 1:n
        if rtequalequal(a.data[i], b.data[i]) == 0
            return 0
        end
    end
    return 1
end

rtnotequal(a, b) = rtequalequal(a, b) == 0 ? 1 : 0

rtless(a::Int, b::Int) = Int(a < b)
rtless(a::Int, b::BigInt) = Int(a < b)
rtless(a::BigInt, b::Int) = Int(a < b)
rtless(a::BigInt, b::BigInt) = Int(a < b)

rtlessequal(a::Int, b::Int) = Int(a <= b)
rtlessequal(a::Int, b::BigInt) = Int(a <= b)
rtlessequal(a::BigInt, b::Int) = Int(a <= b)
rtlessequal(a::BigInt, b::BigInt) = Int(a <= b)

rtgreater(a::Int, b::Int) = Int(a > b)
rtgreater(a::Int, b::BigInt) = Int(a > b)
rtgreater(a::BigInt, b::Int) = Int(a > b)
rtgreater(a::BigInt, b::BigInt) = Int(a > b)

rtgreaterequal(a::Int, b::Int) = Int(a >= b)
rtgreaterequal(a::Int, b::BigInt) = Int(a >= b)
rtgreaterequal(a::BigInt, b::Int) = Int(a >= b)
rtgreaterequal(a::BigInt, b::BigInt) = Int(a >= b)

# int only functions

rtor(a::Int, b::Int) = a == b == 0 ? 0 : 1
rtand(a::Int, b::Int) = a == 0 || b == 0 ? 0 : 1

rtnot(a::Int) = a == 0 ? 1 : 0
rtnot(a) = rt_error("not `$(rt_typestring(a))` failed, expected ! `int`")

rtdotdot(a::Int, b::Int) = SIntVec(a <= b ? (a:1:b) : (a:-1:b))

function rtcolon(a::Int, b::Int)
    b < 0 && rt_error("`$a .. $b` failed, second argument must be >= 0")
    SIntVec(collect(Iterators.repeated(a, b)))
end

for (fun, name) in [:rtor => "||", :rtand => "&&", :rtdotdot => "..", :rtcolon => ":"]
    @eval $fun(a, b) =
        rt_error(string("`$(rt_typestring(a))` ", $name, "`$(rt_typestring(b))` failed, ",
                        "expected `int` ", $name, " `int`"))
end

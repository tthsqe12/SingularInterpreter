#=
the transpiler DOES NOT produce names for any arguments of these functions

    SINGULAR        JULIA
    a[i]            rtgetindex(a, i)
    a[i, j]         rtgetindex(a, i, j)
    a[i][j]         rtgetindex(rtgetindex(a, i), j)
    a[i] = b        rtsetindex_last(a, i, b)
    a[i, j] = b     rtsetindex_last(a, i, j, b)
    a[i], b[j] = c  rtsetindex_last(b, j, rtsetindex_more(a, i, c))
=#

#### list get/setindex ####

function rtgetindex(a::Slist, i::Int)
    @expensive_assert object_is_ok(a)
    b = a.value[i]
    if isa(b, Slist)
        b.back = a
    end
    @expensive_assert object_is_own(b)
    return b
end

function rtgetindex(a::Slist, i::Sintvec)
    if length(i.value) == 1
        return rtgetindex(a, i.value[1])
    else
        # the singular code a[i][j] = b is transpiled as
        #   rtsetindex_last(rtgetindex(a, i), j, b)
        # and singular errs in this case. Therefore, it is ok to return an
        # STuple and let julia err in rtsetindex_last(::STuple, ...) in this case
        return STuple(Any[rt_copy_tmp(rtgetindex(a, t)) for t in i.value])
    end
end


function rtsetindex_more(a::Slist, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return empty_tuple
end

function rtsetindex_more(a::Slist, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    rt_setindex(a, i, popfirst!(b.list))
    return b
end

function rtsetindex_more(a::Slist, i::Sintvec, b)
    @assert !isa(b, STuple)
    if length(i.value) == 1
        rt_setindex(a, i.value[1], b)
        return empty_tuple
    else
        @error_check(isempty(i.value), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::Slist, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) >= n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end

function rtsetindex_last(a::Slist, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return
end

function rtsetindex_last(a::Slist, i::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    rt_setindex(a, i, b.list[1])
    return
end

function rtsetindex_last(a::Slist, i::Sintvec, b)
    @assert !isa(b, STuple)
    if length(i.value) == 1
        rt_setindex(a, i.value[1], b)
    else
        @error_check(isempty(i.value), "argument mismatch in assignment")
    end
    return
end

function rtsetindex_last(a::Slist, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) == n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
    return
end


function rt_setindex(a::Slist, i::Int, b)
    @expensive_assert object_is_ok(a)
    A = a.value
    count_change = Int(rt_is_ring_dep(b))
    if isa(b, Nothing)
        if i > length(A)
            return
        end
        count_change = -Int(rt_is_ring_dep(A[i]))
        A[i] = nothing
        # putting nothing at the end pops the list
        while !isempty(A) && isa(A[end], Nothing)
            pop!(A)
        end
    else
        B = rt_copy_own(b) # copy before the possible resize
        org_len = length(A)
        if i > org_len
            # nothing fills out a list when we assign past the end
            resize!(A, i)
            while org_len + 1 < i
                A[org_len + 1] = nothing
                org_len += 1
            end
        else
            count_change -= Int(rt_is_ring_dep(A[i]))
        end
        A[i] = B
    end
    if count_change != 0
        rt_fix_setindex(a, count_change)
    end
    @expensive_assert object_is_ok(a)
    return
end

# we should at least maintain the integrity of the list data structure
function rt_fix_setindex(a::Slist, count_change::Int)
    new_parent = a.parent
    a.ring_dep_count += count_change
    if a.ring_dep_count > 0
        if !new_parent.valid
            new_parent = rt_basering()  # try to get a valid ring from somewhere
            @warn_check(new_parent.valid, "list has ring dependent elements but no basering")
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
                if isa(b, Slist)
                    R = rt_basering()
                    if R.valid
                        @warn_check(!haskey(R.vars, a), "overwriting name " * string(a.name) * " when moving global list into basering")
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
                    @warn_check(!haskey(d, a), "overwriting name " * string(a.name) * " when moving global list out of basering")
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

function rtgetindex(a::Sintvec, i::Int)
    return a.value[i]
end

function rtgetindex(a::Sintvec, i::Sintvec)
    r = Any[a.value[t] for t in i.value]
    return length(r) == 1 ? r[1] : STuple(r)
end

function rtsetindex_more(a::Sintvec, i::Int, b)
    @assert !isa(b, STuple)
    a.value[i] = rt_convert2int(b)
    return empty_tuple
end

function rtsetindex_more(a::Sintvec, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    a.value[i] = rt_convert2int(popfirst!(b.list))
    return b
end

function rtsetindex_more(a::Sintvec, i::Sintvec, b)
    @assert !isa(b, STuple)
    if length(i.value) == 1
        a[i.value[1]] = rt_convert2int(b)
        return empty_tuple
    else
        @error_check(isempty(i.value), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::Sintvec, i::Sintvec, b::STuple)
    iv = i.value
    n = length(iv)
    @error_check(length(b.data) >= n, "argument mismatch in assignment")
    if a === i
        iv = copy(i.value)
    end
    for t in 1:n
        a.value[iv[t]] = rt_convert2int(b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end

function rtsetindex_last(a::Sintvec, i::Int, b)
    @assert !isa(b, STuple)
    a.value[i] = rt_convert2int(b)
    return
end

function rtsetindex_last(a::Sintvec, i::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    a.value[i] = rt_convert2int(b.list[1])
    return
end

function rtsetindex_last(a::Sintvec, i::Sintvec, b)
    @assert !isa(b, STuple)
    @error_check(length(i.value) == 1, "argument mismatch in assignment")
    a.value[i.value[1]] = rt_convert2int(b)
    return
end

function rtsetindex_last(a::Sintvec, i::Sintvec, b::STuple)
    iv = i.value
    n = length(iv)
    @error_check(length(b.list) == n, "argument mismatch in assignment")
    if a === i
        iv = copy(i.value)
    end
    for t in 1:n
        a.value[iv[t]] = rt_convert2int(b.list[t])
    end
    return
end



#### intmat/bigintmat/matrix get/setindex ####

indexvalues(i::Sintvec) = i.value
indexvalues(i::Int) = i

Base.size(a::libSingular.matrix) = (libSingular.nrows(a), libSingular.ncols(a))

function rtgetindex(a::Union{Sintmat, Sbigintmat, Smatrix},
                    i::Union{Int, Sintvec},
                    j::Union{Int, Sintvec})
    nrows, ncols = size(a.value)
    r = Any[]
    for s in indexvalues(i)
        for t in indexvalues(j)
            @error_check(1 <= s <= nrows && 1 <= t <= ncols, "matrix index out of range")
            if isa(a, Smatrix)
                r1 = libSingular.mp_getindex(a.value, s, t)
                r2 = libSingular.p_Copy(r1, a.parent.value) # we did not own r1
                push!(r, Spoly(r2, a.parent))
            else
                push!(r, a.value[s, t])
            end
        end
    end
    return length(r) == 1 ? r[1] : STuple(r)
end

function rt_setindex(a::Sintmat, i::Int, j::Int, b)
    a.value[i, j] = rt_convert2int(b)
end

function rt_setindex(a::Sbigintmat, i::Int, j::Int, b)
    a.value[i, j] = rt_convert2bigint(b)
end

function rt_setindex(a::Smatrix, i::Int, j::Int, b)
    libSingular.mp_setindex(a.value, i, j, rt_convert2poly_ptr(b, a.parent), a.parent.value)
end

function rtsetindex_more(a::Union{Sintmat, Sbigintmat, Smatrix},
                         i::Union{Int, Sintvec},
                         j::Union{Int, Sintvec},
                         b)
    @assert !isa(b, STuple)
    nrows, ncols = size(a.value)
    first = true
    for s in indexvalues(i)
        for t in indexvalues(j)
            @error_check(first, "argument mismatch in assignment")
            @error_check(1 <= s <= nrows && 1 <= t <= ncols, "matrix index out of range")
            rt_setindex(a, s, t, b)
            first = false
        end
    end
    return first ? b : empty_tuple
end

function rtsetindex_more(a::Union{Sintmat, Sbigintmat, Smatrix},
                    i::Union{Int, Sintvec},
                    j::Union{Int, Sintvec},
                    b::STuple)
    nrows, ncols = size(a.value)
    for s in indexvalues(i)
        for t in indexvalues(j)
            @error_check(!isempty(b.list), "argument mismatch in assignment")
            @error_check(1 <= s <= nrows && 1 <= t <= ncols, "matrix index out of range")
            rt_setindex(a, s, t, popfirst!(b.list))
        end
    end
    return b
end

function rtsetindex_last(a::Union{Sintmat, Sbigintmat, Smatrix},
                         i::Union{Int, Sintvec},
                         j::Union{Int, Sintvec},
                         b)
    @assert !isa(b, STuple)
    nrows, ncols = size(a.value)
    first = true
    for s in indexvalues(i)
        for t in indexvalues(j)
            @error_check(first, "argument mismatch in assignment")
            @error_check(1 <= s <= nrows && 1 <= t <= ncols, "matrix index out of range")
            rt_setindex(a, s, t, b)
            first = false
        end
    end
    @error_check(!first, "argument mismatch in assignment")
    return
end

function rtsetindex_last(a::Union{Sintmat, Sbigintmat, Smatrix},
                         i::Union{Int, Sintvec},
                         j::Union{Int, Sintvec},
                         b::STuple)
    nrows, ncols = size(a.value)
    for s in indexvalues(i)
        for t in indexvalues(j)
            @error_check(!isempty(b.list), "argument mismatch in assignment")
            @error_check(1 <= s <= nrows && 1 <= t <= ncols, "matrix index out of range")
            rt_setindex(a, s, t, popfirst!(b.list))
        end
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return
end



#### ideal/module get/setindex ####

function rtgetindex(a::Union{Sideal, Smodule}, i::Int)
    n = Int(libSingular.ngens(a.value))
    @error_check(1 <= i <= n, "ideal index out of range")
    r1 = libSingular.getindex(a.value, Cint(i - 1))
    r2 = libSingular.p_Copy(r1, a.parent.value)
    return isa(a, Sideal) ? Spoly(r2, a.parent) : Svector(r2, a.parent)
end

function rtgetindex(a::Union{Sideal, Smodule}, i::Sintvec)
    r = Any[rtgetindex(a, t) for t in i.value]
    return length(r) == 1 ? r[1] : STuple(r)
end

function rt_setindex(a::Sideal, i::Int, b)
    @assert !isa(b, STuple)
    @error_check(i > 0, "ideal index must be positive for assignment")
    b1 = rt_convert2poly_ptr(b, a.parent)
    libSingular.id_setindex_fancy(a.value, Cint(i), b1, a.parent.value)
    return
end

function rt_setindex(a::Smodule, i::Int, b)
    @assert !isa(b, STuple)
    @error_check(i > 0, "ideal index must be positive for assignment")
    b1 = rt_convert2vector_ptr(b, a.parent)
    libSingular.mo_setindex_fancy(a.value, Cint(i), b1, a.parent.value)
    return
end

function rtsetindex_more(a::Union{Sideal, Smodule}, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return empty_tuple
end

function rtsetindex_more(a::Union{Sideal, Smodule}, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    rt_setindex(a, i, popfirst!(b.list))
    return b
end

function rtsetindex_more(a::Union{Sideal, Smodule}, i::Sintvec, b)
    @assert !isa(b, STuple)
    if length(i.value) == 1
        rt_setindex(a, i.value[1], b)
        return empty_tuple
    else
        @error_check(isempty(i.value), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::Union{Sideal, Smodule}, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) >= n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end

function rtsetindex_last(a::Union{Sideal, Smodule}, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return
end

function rtsetindex_last(a::Union{Sideal, Smodule}, i::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    rt_setindex(a, i, b.list[1])
    return
end

function rtsetindex_last(a::Union{Sideal, Smodule}, i::Sintvec, b)
    @assert !isa(b, STuple)
    @error_check(length(i.value) == 1, "argument mismatch in assignment")
    rt_setindex(a, i.value[1], b)
    return
end

function rtsetindex_last(a::Union{Sideal, Smodule}, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) == n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
end

#=
the transpiler DOES NOT produce names for any arguments of these functions

    SINGULAR        JULIA
    a[i]            rtgetindex(a, i)
    a[i] = b        rtsetindex_last(a, i, b)
    a[i, j]         rtgetindex(a, i, j)
    a[i, j] = b     rtsetindex_last(a, i, j, b)
    a[i], b[j] = c  rtsetindex_last(b, j, rtsetindex_more(a, i, c))

    SINGULAR    JULIA
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
    r = Any[rtgetindex(a, t) for t in i.value]
    return length(r) == 1 ? r[1] : STuple(map(rt_copy_tmp, r))
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



#### ideal get/setindex ####

function rtgetindex(a::Sideal, i::Int)
    n = Int(libSingular.ngens(a.value))
    @error_check(1 <= i <= n, "ideal index out of range")
    r1 = libSingular.getindex(a.value, Cint(i - 1))
    r2 = libSingular.p_Copy(r1, a.parent.value)
    return Spoly(r2, a.parent)
end

function rtgetindex(a::Sideal, i::Sintvec)
    r = Any[rtgetindex(a, t) for t in i.value]
    return length(r) == 1 ? r[1] : STuple(r)
end

function rt_setindex(a::Sideal, i::Int, b)
    @assert !isa(b, STuple)    
    @error_check(i > 0, "ideal index must be positive for assignment")
    libSingular.id_setindex_fancy(a.value, Cint(i), rt_convert2poly_ptr(b, a.parent), a.parent.value)
    return
end

function rtsetindex_more(a::Sideal, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return empty_tuple
end

function rtsetindex_more(a::Sideal, i::Int, b::STuple)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    rt_setindex(a, i, popfirst!(b.list))
    return b
end

function rtsetindex_more(a::Sideal, i::Sintvec, b)
    @assert !isa(b, STuple)
    if length(i.value) == 1
        rt_setindex(a, i.value[1], b)
        return empty_tuple
    else
        @error_check(isempty(i.value), "argument mismatch in assignment")
        return b
    end
end

function rtsetindex_more(a::Sideal, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) >= n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
    deleteat!(b.list, 1:n)
    return b
end

function rtsetindex_last(a::Sideal, i::Int, b)
    @assert !isa(b, STuple)
    rt_setindex(a, i, b)
    return
end

function rtsetindex_last(a::Sideal, i::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    rt_setindex(a, i, b.list[1])
    return
end

function rtsetindex_last(a::Sideal, i::Sintvec, b)
    @assert !isa(b, STuple)
    @error_check(length(i.value) == 1, "argument mismatch in assignment")
    rt_setindex(a, i.value[1], b)
    return
end

function rtsetindex_last(a::Sideal, i::Sintvec, b::STuple)
    n = length(i.value)
    @error_check(length(b.list) == n, "argument mismatch in assignment")
    for t in 1:n
        rt_setindex(a, i.value[t], b.list[t])
    end
end


#########################################


function rtplus(a::Slist, b::Slist)
    if a.parent.valid
        newparent = a.parent
        @warn_check(!b.parent.valid || newparent == b.parent, "funny thing happened while adding lists")
    else
        newparent = b.parent
    end
    A = object_is_tmp(a) ? a.value : map(rt_copy_own, a.value)
    B = object_is_tmp(b) ? b.value : map(rt_copy_own, b.value)
    return Slist(vcat(A, B), newparent, a.ring_dep_count + b.ring_dep_count, nothing, true)
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

function rtplus(a::Snumber, b::Snumber)
    @error_check_rings(a.parent, rt_basering(), "cannot add from different basering")
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    r1 = libSingular.n_Add(a.value, b.value, a.parent.value)
    return Snumber(r1, a.parent)
end

function rtminus(a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "negating outside of basering")
    r1 = libSingular.n_Neg(a.value, a.parent.value)
    return Snumber(r1, a.parent)
end

function rtminus(a::Snumber, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot subtract from different basering")
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    r1 = libSingular.n_Sub(a.value, b.value, a.parent.value)
    return Snumber(r1, a.parent)
end

function rttimes(a::Snumber, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot multiply from different basering")
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    r1 = libSingular.n_Mult(a.parent, b.parent, a.parent.value)
    return Snumber(r1, a.parent)
end

# op(poly, poly)

function rtplus(a::Spoly, b::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot add from different basering")
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.p_Copy(b.value, b.parent.value)
    r1 = libSingular.p_Add_q(a1, b1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "negating outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    r1 = libSingular.p_Neg(a1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(a::Spoly, b::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot subtract from different basering")
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.p_Copy(b.value, b.parent.value)
    r1 = libSingular.p_Sub(a1, b1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rttimes(a::Spoly, b::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot multiply from different basering")
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    r1 = libSingular.pp_Mult_qq(a.value, b.value, a.parent.value)
    return Spoly(r1, a.parent)
end

# op(ideal, ideal)

function rtplus(a::Sideal, b::Sideal)
    @error_check_rings(a.parent, b.parent, "cannot add from different basering")
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    r1 = libSingular.id_Add(a.value, b.value, a.parent.value)
    return Sideal(r1, a.parent, true)
end

function rtminus(a::Sideal)
    return rttimes(a, -1)
end

function rtminus(a::Sideal, b::Sideal)
    rt_error("cannot subtract ideals")
    return rt_defaultconstructor_ideal()
end

function rttimes(a::Sideal, b::Sideal)
    @error_check_rings(a.parent, b.parent, "cannot multiply from different basering")
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    r1 = libSingular.id_Mult(a.value, b.value, a.parent.value)
    return Sideal(r1, a.parent, true)
end

# op(ideal, number|poly)

function rtplus(a::Sideal, b::Union{BigInt, Int, Snumber, Spoly})
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Add(a.value, b2, a.parent.value)
    libSingular.id_Delete(b2, a.parent.value) # id_Add did not consume b2
    return Sideal(r1, a.parent, true)
end

function rttimes(a::Sideal, b::Union{BigInt, Int, Snumber, Spoly})
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Mult(a.value, b2, a.parent.value)
    libSingular.id_Delete(b2, a.parent.value) # id_Mult did not consume b2
    return Sideal(r1, a.parent, true)
end


# op(number, int)

function rtplus(a::Snumber, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Add(a.value, b1, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

function rtminus(a::Snumber, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Sub(a.value, b1, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

function rttimes(a::Snumber, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Mult(a.value, b1, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

# op(int, number)

function rtplus(b::Union{Int, BigInt}, a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Add(b1, a.value, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Sub(b1, a.value, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r1 = libSingular.n_Mult(b1, a.value, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return SNumber(r1, a.parent)
end

# op(poly, int)

function rtplus(a::Spoly, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(a::Spoly, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Sub(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

function rttimes(a::Spoly, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

# op(poly, number)

function rtplus(a::Spoly, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot add from different basering")
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(a::Spoly, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot subtract from different basering")
    @warn_check_rings(a.parent, rt_basering(), "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Sub(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

function rttimes(a::Spoly, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot multiply from different basering")
    @warn_check_rings(a.parent, rt_basering(), "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.value)
    return Spoly(r1, a.parent)
end

# op(int, poly)

function rtplus(b::Union{Int, BigInt}, a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Sub(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end

# op(number, poly)

function rtplus(b::Snumber, a::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot add from different basering")
    @warn_check_rings(a.parent, rt_basering(), "adding outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtminus(b::Snumber, a::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot subtract from different basering")
    @warn_check_rings(a.parent, rt_basering(), "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Sub(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rttimes(b::Snumber, a::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot multiply from different basering")
    @warn_check_rings(a.parent, rt_basering(), "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.value)
    return Spoly(r1, a.parent)
end




function rtplus(a::STuple, b)
    @assert !isa(b, STuple)
    a.list[1] = rt_copy_tmp(rtplus(a.list[1], b))
    return a
end

function rtplus(a, b::STuple)
    @assert !isa(a, STuple)
    b.list[1] = rt_copy_tmp(rtplus(a, b.list[1]))
    return b
end

function rtplus(a::STuple, b::STuple)
    return STuple(Any[rt_copy_tmp(rtplus(a.list[i], b.list[i])) for i in 1:min(length(a.list), length(b.list))])
end

function rtplus(a::Sintvec, b::Sintvec)
    A = a.value
    B = b.value
    return SIintvec([Base.checked_add(i <= length(A) ? A[i] : 0,
                                     i <= length(B) ? B[i] : 0)
                                   for i in 1:max(length(A), length(B))], true)
end

function rtplus(a::Sintvec, b::Int)
    A = rt_copy_tmp(a)
    for i in 1:length(A.value)
        A.value[i] = Base.checked_add(A.value[i], b)
    end
    return A
end

rtplus(a::Int, b::Sintvec) = rtplus(b, a)


function rtplus(a::Sintmat, b::Int)
    A = rt_copy_tmp(a)
    nrows, ncols = size(A.value)
    for i in 1:min(nrows, ncols)
        A.value[i, i] = Base.checked_add(A.value[i, i], b)
    end
    return A
end

function rtplus(a::Int, b::Sintmat)
    B = rt_copy_tmp(b)
    nrows, ncols = size(B.value)
    for i in 1:min(nrows, ncols)
        B.value[i, i] = rtplus(a, B.value[i, i])
    end
    return B
end

function rtplus(a::Sintmat, b::Sintmat)
    return Sintmat(a.value + b.value, true)
end

function rtplus(a::Sstring, b::Sstring)
    return Sstring(a.value * b.value)
end

function stimes(a::Sbigintmat, b::Sbigintmat)
    return Sbigintmat(a.value * b.value, true)
end

function stimes(a::Int, b::Sbigintmat)
    B = rt_copy_tmp(b)
    B.value .*= a
    return B
end

rtpower(a::Int, b::Int) = a ^ b
rtpower(a::Int, b::BigInt) = a ^ b
rtpower(a::BigInt, b::Int) = a ^ b
rtpower(a::BigInt, b::BigInt) = a ^ b

function rtpower(a::Snumber, b::Int)
    absb = abs(b)
    @error_check(absb <= typemax(Cint), "number power is out of range")
    @warn_check_rings(a.parent, rt_basering(), "powering outside of basering")
    if b < 0
        @error_check(!libSingular.n_IsZero(a.value, a.parent.value), "cannot divide by zero")
        ai = libSingular.n_Invers(a.value, a.parent.value)
        r1 = libSingular.n_Power(ai, Cint(absb), a.parent.value)
        libSingular.n_Delete(ai, a.parent.value)
    else
        r1 = libSingular.n_Power(a.value, Cint(absb), a.parent.value)
    end
    return Snumber(r1, a.parent)
end

function rtpower(a::Spoly, b::Int)
    @error_check(0 <= b <= typemax(Cint), "polynomial power is out of range")
    @warn_check_rings(a.parent, rt_basering(), "powering outside of basering")
    a1 = libSingular.p_Copy(a.value, a.parent.value)
    b1 = Cint(b)
    r1 = libSingular.p_Power(a1, b1, a.parent.value)
    return Spoly(r1, a.parent)
end

function rtpower(a::Sideal, b::Int)
    @error_check(0 <= b <= typemax(Cint), "ideal power is out of range")
    @warn_check_rings(a.parent, rt_basering(), "powering outside of basering")
    r1 = libSingular.id_Power(a.value, Cint(b), a.parent.value)
    return Sideal(r1, a.parent, true)
end


function rtdivide(a::Union{Int, BigInt}, b::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "integer division using `/` without a basering; use `div` instead")
    b1 = libSingular.n_Init(b, R.value)
    if libSingular.n_IsZero(b1, R.value)
        libSingular.n_Delete(b1, R.value)
        rt_error("cannot divide be zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, R.value)
    r1 = libSingular.n_Div(a1, b1, R.value)
    libSingular.n_Delete(a1, R.value)
    libSingular.n_Delete(b1, R.value)
    return Snumber(r1, R)
end

function rtdivide(a::Union{Int, BigInt}, b::Snumber)
    @warn_check_rings(b.parent, rt_basering(), "dividing outside of basering")
    if libSingular.n_IsZero(b.value, b.parent.value)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, b.parent.value)
    r1 = libSingular.n_Div(a1, b.value, b.parent.value)
    libSingular.n_Delete(a1, b.parent.value)
    return Snumber(r1, b.parent)
end

function rtdivide(a::Snumber, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "dividing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    if libSingular.n_IsZero(b1, a.parent.value)
        libSingular.n_Delete(b1, a.parent.value)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a1, a.value, a.parent.value)
    libSingular.n_Delete(b1, a.parent.value)
    return Snumber(r1, a.parent)
end

function rtdivide(a::Snumber, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot divide from different basering")
    @warn_check_rings(a.parent, rt_basering(), "dividing outside of basering")
    if libSingular.n_IsZero(b.value, b.parent.value)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a.value, b.value, a.parent.value)
    return Snumber(r1, a.parent)
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

rtequalequal(a::Sstring, b::Sstring) = Int(a.value == b.value)

rtequalequal(a::Sintvec, b::Sintvec) = Int(a.value == b.value)

rtequalequal(a::Union{Int, BigInt}, b::Snumber) = rtequalequal(b, a)

function rtequalequal(a::Snumber, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "comparing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    r = Int(libSingular.n_Equal(a.value, b1, a.parent.value))
    libSingular.n_Delete(b1, a.parent.value)
    return r
end

function rtequalequal(a::Snumber, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot compare from different basering")
    @warn_check_rings(a.parent, rt_basering(), "comparing outside of basering")
    return Int(libSingular.n_Equal(a.value, b.value, a.parent.value))
end

rtequalequal(a::Union{Int, BigInt, Number}, b::Spoly) = rtequalequal(b, a)

function rtequalequal(a::Spoly, b::Union{Int, BigInt})
    @warn_check_rings(a.parent, rt_basering(), "comparing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    r = Int(libSingular.p_EqualPolys(a.value, b2, a.parent.value))
    libSingular.p_Delete(b2, a.parent.value)
    return r
end

function rtequalequal(a::Spoly, b::Snumber)
    @error_check_rings(a.parent, b.parent, "cannot compare from different basering")
    @warn_check_rings(a.parent, rt_basering(), "comparing outside of basering")
    b1 = libSingular.n_Copy(b.value, b.parent.value)
    b2 = libSingular.p_NSet(b1, b.parent.value)
    r = Int(libSingular.p_EqualPolys(a.value, b2, a.parent.value))
    libSingular.p_Delete(b2, a.parent.value)
    return r
end

function rtequalequal(a::Spoly, b::Spoly)
    @error_check_rings(a.parent, b.parent, "cannot compare from different basering")
    @warn_check_rings(a.parent, rt_basering(), "comparing outside of basering")
    return Int(libSingular.p_EqualPolys(a.value, b.value, a.parent.value))
end

function rtequalequal(a::Sideal, b::Union{Int, BigInt})
    # compare a and b as matrices!
    b1 = libSingular.n_Init(b, a.parent.value)
    b2 = libSingular.p_NSet(b1, a.parent.value)
    b3 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(b3, b2, 0)
    r = Int(libSingular.mp_Equal(a.value, b3, a.parent.value))
    libSingular.id_Delete(b3, a.parent.value)
    return r
end


function rtequalequal(a::Slist, b::Slist)
    n = length(a.value)
    if n != length(b.value)
        return 0
    end
    for i in 1:n
        if rtequalequal(a.value[i], b.value[i]) == 0
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

rtdotdot(a::Int, b::Int) = Sintvec(a <= b ? (a:1:b) : (a:-1:b), true)

function rtcolon(a::Int, b::Int)
    b < 0 && rt_error("`$a : $b` failed, second argument must be >= 0")
    Sintvec(collect(Iterators.repeated(a, b)), true)
end

for (fun, name) in [:rtor => "||", :rtand => "&&", :rtdotdot => "..", :rtcolon => ":"]
    @eval $fun(a, b) =
        rt_error(string("`$(rt_typestring(a))` ", $name, "`$(rt_typestring(b))` failed, ",
                        "expected `int` ", $name, " `int`"))
end

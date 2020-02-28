###################### assignment #############################################
# in general the operation of the assignment a = b in Singular depends on the
# values of a and b Therefore, singular a = b becomes julia a = rt_assign(a, b)
# Actually, it is a bit more complicated due to the streaming properties of
# Singular's assignment operator:
#
#  SINGULAR     | JULIA
# --------------+-----------------------------
#  a = b        | a = rt_assign_last(a, b)
# --------------+--------------------
#  a, b, c = d  | a, t = rt_assign_more(a, d)
#               | b, t = rt_assign_more(b, t)
#               | c = rt_assign_last(c, t)

# The assignment to any variable "a" declared "def" must pass through rt_assign because:
#   (1) The initial value of "a" is Snone
#   (2) The first assignment to "a" with a non-Snone type on the rhs succeeds
#       and essentially determines the type of "a"
#   (3) Future assignments to "a" behave as if "a" had the type in (2)
# Since we don't know if an assignment is the first or not - and even if we did,
# we don't know the type of the rhs - all of this type checking is done by rt_assign

function rtassign_more(a::SName, b)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            newvalue, rest = rt_assign_more(vars[i].second, b)
            vars[i] = Pair(vars[i].first, newvalue)
            return rest
        end
    end

    # global ring dependent
    R = rtGlobal.callstack[end].current_ring    # same as rt_basering()
    if haskey(R.vars, a.name)
        if isa(R.vars[a.name], Slist)
            rt_assign_global_list_ring_dep(R, a.name, rt_convert2list(b))
            return empty_tuple
        else
            R.vars[a.name], rest = rt_assign_more(R.vars[a.name], b)
            return rest
        end
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                if isa(d[a.name], Slist)
                    rt_assign_global_list_ring_indep(d, a.name, rt_convert2list(b))
                    return empty_tuple
                else
                    d[a.name], rest = rt_assign_more(d[a.name], b)
                    return rest
                end
                return
            end
        end
    end

    rt_error("cannot assign to " * String(a.name))
end

function rtassign_last(a::SName, b)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            vars[i] = Pair(vars[i].first, rt_assign_last(vars[i].second, b))
            return
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        if isa(R.vars[a.name], Slist)
            rt_assign_global_list_ring_dep(R, a.name, rt_convert2list(b))
        else
            R.vars[a.name]= rt_assign_last(R.vars[a.name], b)
        end
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                if isa(d[a.name], Slist)
                    rt_assign_global_list_ring_indep(d, a.name, rt_convert2list(b))
                else
                    d[a.name] = rt_assign_last(d[a.name], b)
                end
                return
            end
        end
    end

    rt_error("cannot assign to " * String(a.name))
end


function rtassign_names_more(a::Vector{SName}, b)
    for i in a
        b = rtassign_more(i, b)
    end
    return b
end

function rtassign_names_last(a::Vector{SName}, b)
    n = length(a)
    if n > 0
        for i in 1:n-1
            b = rtassign_more(a[i], b)
        end
        rtassign_last(a[n], b)
    else
        @error_check(isa(b, STuple) && isempty(b.list), "argument mismatch in assignment")
    end
    return
end

# a = b, a lives in a ring independent table d
function rt_assign_global_list_ring_indep(d::Dict{Symbol, Any}, a::Symbol, b::Slist)
    @assert haskey(d, a)
    @assert isa(d[a], Slist)
    @assert object_is_own(b)
    if b.parent.valid
        # move the name to the ring of b, which is hopefully the current ring
        @warn_check(b.parent === rt_basering(), "moving list $(string(a)) to a ring other than the basering")
        @warn_check(!haskey(b.parent.vars, a), "overwriting name $(string(a)) when moving list to a ring")
        b.parent.vars[a] = b
        delete!(d, a)
    else
        # no need to move the name
        d[a] = b
    end
end

# a = b, a lives in ring r
function rt_assign_global_list_ring_dep(r::Sring, a::Symbol, b::Slist)
    @assert haskey(r.vars, a)
    @assert isa(r.vars[a], Slist)
    @assert object_is_own(b)
    if b.parent.valid
        # no need to move the name
        @warn_check(r === b.parent, "the list $(string(a)) might now contain ring dependent data from a ring other than basering")
        r.vars[a] = b
    else
        # move the name to the current package
        p = rtGlobal.callstack[end].current_package
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            @warn_check(!haskey(d, a), "overwriting name $(string(a)) when moving list out of ring")
            d[a] = b
        else
            rtGlobal.vars[p] = Dict{Symbol, Any}[a => b]
        end
        delete!(r.vars, a)
    end
end


function rt_incrementby(a::SName, b::Int)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            newvalue = rt_assign_last(vars[i].second, rtplus(vars[i].second, b))
            vars[i] = Pair(vars[i].first, newvalue)
            return
        end
    end

    # global ring dependent
    d = rtGlobal.callstack[n].current_ring.vars
    if haskey(d, a.name)
        d[a.name] = rt_assign_last(d[a.name], rtplus(d[a.name], b))
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                d[a.name] = rt_assign_last(d[a.name], rtplus(d[a.name], b))
                return
            end
        end
    end

    rt_error("cannot increment/decrement " * String(a.name))
end


#### assignment to Snone - used at least for the first set of a variable of type def
function rt_assign_more(a::Snone, b)
    @assert !isa(b, STuple)
    return rt_copy_own(b), empty_tuple
end

function rt_assign_more(a::Snone, b::STuple)
    @error_check(!isempty(b), "too few arguments to assignment on right hand side")
    return rt_copy_own(popfirst!(b.list)), b
end

function rt_assign_last(a::Snone, b)
    @assert !isa(b, STuple)
    return rt_copy_own(b)
end

function rt_assign_last(a::Snone, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_copy_own(b.list[1])
end


#### assignment to proc
function rt_assign_more(a::Sproc, b)
    @assert !isa(b, STuple)
    return rt_convert2proc(b), empty_tuple
end

function rt_assign_more(a::Sproc, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2proc(popfirst!(b.list)), b
end

function rt_assign_last(a::Sproc, b)
    @assert !isa(b, STuple)
    return rt_convert2proc(b)
end

function rt_assign_last(a::Sproc, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2proc(b.list[1])
end

#### assignment to int
function rt_assign_more(a::Int, b)
    @assert !isa(b, STuple)
    return rt_convert2int(b), empty_tuple
end

function rt_assign_more(a::Int, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2int(popfirst!(b.list)), b
end

function rt_assign_last(a::Int, b)
    @assert !isa(b, STuple)
    return rt_convert2int(b)
end

function rt_assign_last(a::Int, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2int(b.list[1])
end


#### assignment to bigint
function rt_assign_more(a::BigInt, b)
    @assert !isa(b, STuple)
    return rt_convert2bigint(b), empty_tuple
end

function rt_assign_more(a::BigInt, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2bigint(popfirst!(b.list)), b
end

function rt_assign_last(a::BigInt, b)
    @assert !isa(b, STuple)
    return rt_convert2bigint(b)
end

function rt_assign_last(a::BigInt, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2bigint(b.list[1])
end

#### assignment to string
function rt_assign_more(a::Sstring, b)
    @assert !isa(b, STuple)
    return rt_convert2string(b), empty_tuple
end

function rt_assign_more(a::Sstring, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2string(popfirst!(b.list)), b
end

function rt_assign_last(a::Sstring, b)
    @assert !isa(b, STuple)
    return rt_convert2string(b)
end

function rt_assign_last(a::Sstring, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2string(b.list[1])
end

#### assignment to intvec
function rt_assign_more(a::Sintvec, b)
    @expensive_assert object_is_own(a)
    return rt_convert2intvec(b), empty_tuple
end

function rt_assign_last(a::Sintvec, b)
    @expensive_assert object_is_own(a)
    return rt_convert2intvec(b)
end

#### assignment to intmat
function rt_assign_more(a::Sintmat, b::Union{Sintmat, Sbigintmat})
    @expensive_assert object_is_own(a)
    return rt_convert2intmat(b), empty_tuple
end

function rt_assign_more(a::Sintmat, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    a.value[1, 1] = rt_convert2int(b)
    return a, empty_tuple
end

function rt_assign_more(a::Sintmat, b::STuple)
    @expensive_assert object_is_own(a)
    A = a.value
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    while !isempty(b.list)
        A[row_idx, col_idx] = rt_convert2int(popfirst!(b.list))
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return a, b
end

function rt_assign_last(a::Sintmat, b::Union{Sintmat, Sbigintmat})
    @expensive_assert object_is_own(a)
    return rt_convert2intmat(b)
end

function rt_assign_last(a::Sintmat, b)
    @assert !isa(b, Union{Sintmat, Sbigintmat})
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    a.value[1, 1] = rt_convert2int(b)
    return A
end

function rt_assign_last(a::Sintmat, b::STuple)
    @expensive_assert object_is_own(a)
    A = a.value
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    while !isempty(b.list)
        A[row_idx, col_idx] = rt_convert2int(popfirst!(b.list))
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return a
end

#### assignment to bigintmat
function rt_assign_more(a::Sbigintmat, b::Union{Sintmat, Sbigintmat})
    return rt_convert2bigintmat(b), empty_tuple
end

function rt_assign_more(a::Sbigintmat, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    a.value[1, 1] = rt_convert2bigint(b)
    return a, empty_tuple
end

function rt_assign_more(a::Sbigintmat, b::STuple)
    @expensive_assert object_is_own(a)
    A = a.value
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    while !isempty(b.list)
        A[row_idx, col_idx] = rt_convert2bigint(popfirst!(b.list))
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return a, b
end

function rt_assign_last(a::Sbigintmat, b::Union{Sintmat, Sbigintmat})
    @expensive_assert object_is_own(a)
    return rt_convert2bigintmat(b)
end

function rt_assign_last(a::Sbigintmat, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    a.value[1, 1] = rt_convert2bigint(b)
    return a
end

function rt_assign_last(a::Sbigintmat, b::STuple)
    @expensive_assert object_is_own(a)
    A = a.value
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    while !isempty(b.list)
        A[row_idx, col_idx] = rt_convert2bigint(popfirst!(b.list))
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return a
end

#### assignment to list
function rt_assign_more(a::Slist, b)
    @expensive_assert object_is_own(a)
    return rt_convert2list(b), empty_tuple
end

function rt_assign_last(a::Slist, b)
    @expensive_assert object_is_own(a)
    return rt_convert2list(b)
end

#### assignment to ring
function rt_assign_more(a::Sring, b)
    @assert !isa(b, STuple)
    return rt_convert2ring(b), empty_tuple
end

function rt_assign_more(a::Sring, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2ring(popfirst!(b.list)), b
end

function rt_assign_last(a::Sring, b)
    @assert !isa(b, STuple)
    return rt_convert2ring(b)
end

function rt_assign_last(a::Sring, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2ring(b.list[1])
end

#### assignment to number
function rt_assign_more(a::Snumber, b)
    @assert !isa(b, STuple)
    return rt_convert2number(b), empty_tuple
end

function rt_assign_more(a::Snumber, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2number(popfirst!(b.list)), b
end

function rt_assign_last(a::Snumber, b)
    @assert !isa(b, STuple)
    return rt_convert2number(b)
end

function rt_assign_last(a::Snumber, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2number(b.list[1])
end

#### assignment to poly
function rt_assign_more(a::Spoly, b)
    @assert !isa(b, STuple)
    return rt_convert2poly(b), empty_tuple
end

function rt_assign_more(a::Spoly, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2poly(popfirst!(b.list)), b
end

function rt_assign_last(a::Spoly, b)
    @assert !isa(b, STuple)
    return rt_convert2poly(b)
end

function rt_assign_last(a::Spoly, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2poly(b.list[1])
end

#### assignment to vector
function rt_assign_more(a::Svector, b)
    @assert !isa(b, STuple)
    return rt_convert2vector(b), empty_tuple
end

function rt_assign_more(a::Svector, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2vector(popfirst!(b.list)), b
end

function rt_assign_last(a::Svector, b)
    @assert !isa(b, STuple)
    return rt_convert2vector(b)
end

function rt_assign_last(a::Svector, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2vector(b.list[1])
end

#### assignment to resolution
function rt_assign_more(a::Sresolution, b)
    @assert !isa(b, STuple)
    return rt_convert2resolution(b), empty_tuple
end

function rt_assign_more(a::Sresolution, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2resolution(popfirst!(b.list)), b
end

function rt_assign_last(a::Sresolution, b)
    @assert !isa(b, STuple)
    return rt_convert2resolution(b)
end

function rt_assign_last(a::Sresolution, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2resolution(b.list[1])
end

#### assignment to ideal
function rt_assign_more(a::Sideal, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    return rt_convert2ideal(b), empty_tuple
end

function rt_assign_more(a::Sideal, b::STuple)
    @expensive_assert object_is_own(a)
    libSingular.id_Delete(a.value, a.parent.value)
    a.value = libSingular.idInit(0, 1)
    empty!(a.attributes)
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Sideal})
        i = popfirst!(b.list)
        libSingular.id_append(a.value, rt_convert2ideal_ptr(i, a.parent), r.parent.value)
    end
    return a, b
end

function rt_assign_last(a::Sideal, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    return rt_convert2ideal(b)
end

function rt_assign_last(a::Sideal, b::STuple)
    @expensive_assert object_is_own(a)
    libSingular.id_Delete(a.value, a.parent.value)
    a.value = libSingular.idInit(0, 1)
    empty!(a.attributes)
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Sideal})
        i = popfirst!(b.list)
        libSingular.id_append(a.value, rt_convert2ideal_ptr(i, a.parent), a.parent.value)
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return a
end

#### assignment to module
function rt_assign_more(a::Smodule, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    return rt_convert2module(b), empty_tuple
end

function rt_assign_more(a::Smodule, b::STuple)
    @expensive_assert object_is_own(a)
    libSingular.id_Delete(a.value, a.parent.value)
    a.value = libSingular.idInit(0, 1)
    empty!(a.attributes)
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Svector, Sideal, Smodule})
        i = popfirst!(b.list)
        libSingular.mo_append(a.value, rt_convert2module_ptr(i, a.parent), r.parent.value)
    end
    return a, b
end

function rt_assign_last(a::Smodule, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    return rt_convert2module(b)
end

function rt_assign_last(a::Smodule, b::STuple)
    @expensive_assert object_is_own(a)
    libSingular.id_Delete(a.value, a.parent.value)
    a.value = libSingular.idInit(0, 1)
    empty!(a.attributes)
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Svector, Sideal, Smodule})
        i = popfirst!(b.list)
        libSingular.mo_append(a.value, rt_convert2module_ptr(i, a.parent), a.parent.value)
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return a
end

#### assignment to matrix
function rt_assign_more(a::Smatrix, b)
    @assert !isa(b, STuple)
    rt_error("assignment to matrix not implemented\n")
    return rt_defaultconstructor_matrix(), empty_tuple
end

function rt_assign_more(a::Smatrix, b::STuple)
    rt_error("assignment to matrix not implemented\n")
    return rt_defaultconstructor_matrix(), empty_tuple
end

function rt_assign_last(a::Smatrix, b)
    @expensive_assert object_is_own(a)
    @assert !isa(b, STuple)
    # if b is "like a matrix" then the new value of a should be the matrix version of b
    if isa(b, Smatrix)
        return rt_copy_own(b)
    elseif isa(b, Union{Sintvec, Sintmat, Smodule})
        return Smatrix(rt_convert2matrix_ptr(b, a.parent), a.parent, false)
    # else b is converted to a stream of poly and fed into a row-by-row without changing the size of a
    # Note: Placing the Svector here and the Sintvec above matches the behaviour of singular,
    #       but this makes no sense from the point of view of consistency.
    else
        libSingular.mp_zero(a.value, a.parent.value)
        libSingular.mp_append(a.value, 0, rt_convert2matrix_ptr(b, a.parent), a.parent.value)
        return a
    end
end

function rt_assign_last(a::Smatrix, b::STuple)
    @expensive_assert object_is_own(a)
    if length(b.list) == 1
        return rt_assign_last(a, b.list[1])
    else
        # a is zeroed; b is converted to a stream of poly and fed into a row-by-row
        libSingular.mp_zero(a.value, a.parent.value)
        index = Cint(0)
        while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Sintvec, Sintmat, Snumber, Spoly, Svector, Sideal, Smodule, Smatrix})
            i = popfirst!(b.list)
            index = libSingular.mp_append(a.value, index, rt_convert2matrix_ptr(i, a.parent), a.parent.value)
        end
        return a
    end
end


#### assignment to map
function rt_assign_more(a::Smap, b)
    @assert !isa(b, STuple)
    rt_error("assignment to map not implemented\n")
    return rt_defaultconstructor_map(), empty_tuple
end

function rt_assign_more(a::Smap, b::STuple)
    rt_error("assignment to map not implemented\n")
    return rt_defaultconstructor_map(), empty_tuple
end

function rt_assign_last(a::Smap, b)
    @assert !isa(b, STuple)
    @expensive_assert object_is_own(a)
    return rt_convert2map(b)
end

function rt_assign_last(a::Smap, b::STuple)
    @expensive_assert object_is_own(a)
    @error_check(!isempty(b.list), "argument mismatch in assignment")
    if length(b.list) == 1
        return rt_convert2map(b.list[1])
    else
        @error_check(isa(b.list[1], Sring), "assignment to map expects a ring first")
        libSingular.ma_Delete(a.value, a.parent.value)
        a.source = popfirst!(b.list)
        a.value = libSingular.maInit(0)
        while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Sintvec, Sintmat, Snumber, Spoly, Svector, Sideal, Smodule, Smatrix})
            i = popfirst!(b.list)
            libSingular.ma_append_matrix(a.value, rt_convert2matrix_ptr(i, a.parent), a.parent.value)
        end
        @error_check(isempty(b.list), "argument mismatch in assignment")
        return a
    end
end



##################### system vars ########################

#### degBound
function rt_get_degBound()
    @error_check(rt_basering().valid, "no ring active")
    return Int(libSingular.get_Kstd1_deg())
end

function rt__set_degBound(a)
    @error_check(rt_basering().valid, "no ring active")
    b = rt_convert2int(a)
    libSingular.set_Kstd1_deg(b)
    opt1 = libSingular.get_si_opt_1()
    if b != 0
        opt1 |= OPT_DEGBOUND_MASK
    else
        opt1 &= ~OPT_DEGBOUND_MASK
    end
    libSingular.set_si_opt_1(opt1)
end

#### multBound
function rt_get_multBound()
    @error_check(rt_basering().valid, "no ring active")
    return Int(libSingular.get_Kstd1_mu())
end

function rt__set_multBound(a)
    @error_check(rt_basering().valid, "no ring active")
    b = rt_convert2int(a)
    libSingular.set_Kstd1_mu(b)
    opt1 = libSingular.get_si_opt_1()
    if b != 0
        opt1 |= OPT_MULTBOUND_MASK
    else
        opt1 &= ~OPT_MULTBOUND_MASK
    end
    libSingular.set_si_opt_1(opt1)
end

#### minpoly
function rt_get_minpoly()
    R = rt_basering()
    @error_check(R.valid, "no ring active")
    return Snumber(libSingular.rGetMinpoly(R.value), R)
end

function rt__set_minpoly(a::Snumber)
    R = rt_basering()
    @error_check(R.valid, "no ring active")
    if libSingular.rSetMinpoly(R.value, a.value) != 0
        rt_error("could not set minpoly")
    end
    return
end

#### noether
function rt_get_noether()
    R = rt_basering()
    @error_check(R.valid, "no ring active")
    return Spoly(libSingular.rGetNoether(R.value), R)
end

function rt__set_noether(a)
    R = rt_basering()
    @error_check(R.valid, "no ring active")
    libSingular.rSetNoether(R.value, rt_convert2poly_ptr(a, R))
    return
end

#### short
function rt_get_short()
    R = rt_basering()
    if R.valid
        return Int(libSingular.rGetShortOut(R.value))
    else
        return 0
    end
end

function rt__set_short(a)
    R = rt_basering()
    if R.valid
        libSingular.rSetShortOut(R.value, rt_convert2int(a))
    end
end

#### echo
function rt_get_echo()
    return rtGlobal.si_echo
end

function rt__set_echo(a)
    rtGlobal.si_echo = rt_convert2int(a)
    return
end

#### pagewidth
function rt_get_pagewidth()
    return rtGlobal.colmax
end

function rt__set_pagewidth(a)
    rtGlobal.colmax = rt_convert2int(a)
    return
end

#### printlevel
function rt_get_printlevel()
    return rtGlobal.printlevel
end

function rt__set_printlevel(a)
    rtGlobal.printlevel = rt_convert2int(a)
    return
end

#### rtimer
function rt_get_rtimer()
    t = time_ns()
    if t >= rtGlobal.rtimer_base
        return Int(div(t - rtGlobal.rtimer_base, rtGlobal.rtimer_scale))
    else
        return -Int(div(rtGlobal.rtimer_base - t, rtGlobal.rtimer_scale))
    end
end

function rt__set_rtimer(a)
    a1 = rt_convert2int(a)
    rtGlobal.rtimer_base = time_ns() - a1*rtGlobal.rtimer_scale
end

#### timer TODO
const rt_get_timer = rt_get_rtimer

const rt__set_timer = rt__set_rtimer

#### TRACE
function rt_get_TRACE()
    return rtGlobal.traceit
end

function rt__set_TRACE(a)
    rtGlobal.traceit = rt_convert2int(a)
    return
end


for name in ("degBound", "multBound", "minpoly", "noether", "short",
             "echo", "pagewidth", "printlevel", "rtimer", "timer", "TRACE")
    n = Symbol("rt__set_", name)
    nmore = Symbol("rt_set_", name, "_more")
    nlast = Symbol("rt_set_", name, "_last")
    @eval begin
        function $nmore(a)
            @assert !isa(a, STuple)
            $n(a)
            return empty_tuple
        end

        function $nmore(a::STuple)
            @error_check(!isempty(a), "argument mismatch in assignment")
            $n(popfirst!(a.list))
            return a
        end

        function $nlast(a)
            @assert !isa(a, STuple)
            $n(a)
            return
        end

        function $nlast(a::STuple)
            @error_check(length(a.list) == 1, "argument mismatch in assignment")
            $n(a.list[1])
            return
        end
    end
end

#### voice
function rt_get_voice()
    return length(rtGlobal.callstack)
end

rt_set_voice_more(a) = rt_set_voice_last(a)

function rt_set_voice_last(a)
    rt_error("cannot assign to system variable `voice`")
end

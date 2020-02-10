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
#   (1) The initial value of "a" is nothing
#   (2) The first assignment to "a" with a non-nothing type on the rhs succeeds
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


#### assignment to nothing - used at least for the first set of a variable of type def
function rt_assign_more(a::Nothing, b)
    @assert !isa(b, STuple)
    return rt_copy_own(b), empty_tuple
end

function rt_assign_more(a::Nothing, b::STuple)
    @error_check(!isempty(b), "too few arguments to assignment on right hand side")
    return rt_copy_own(popfirst!(b.list)), b
end

function rt_assign_last(a::Nothing, b)
    @assert !isa(b, STuple)
    return rt_copy_own(b)
end

function rt_assign_last(a::Nothing, b::STuple)
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
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Svector, Sideal, Smodule})
        i = popfirst!(b.list)
        libSingular.id_append(a.value, rt_convert2module_ptr(i, a.parent), r.parent.value)
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
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, Snumber, Spoly, Svector, Sideal, Smodule})
        i = popfirst!(b.list)
        libSingular.id_append(a.value, rt_convert2module_ptr(i, a.parent), a.parent.value)
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
    rt_error("assignment to matrix not implemented\n")
    return rt_defaultconstructor_matrix()
end

function rt_assign_last(a::Smatrix, b::STuple)
    rt_error("assignment to matrix not implemented\n")
    return rt_defaultconstructor_matrix()
end


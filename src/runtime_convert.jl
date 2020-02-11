########### type conversions ##################################################
# each rt_convert2T(a) returns an OWNED object of type T, usually for an assignment
# each rt_convert2T(a) is a UNIARY function with no known exceptions
# each rt_cast2T(a...) is used when the type name T is used as a function, i.e. string(1), or list(1,2,3)

# Singular maintains bools as ints, julia needs real bools for control flow

function rt_asbool(a::Int)
    return a != 0
end

function rt_asbool(a)
    rt_error("expected `int` for boolean expression")
    return false
end

#### def

function rt_convert2def(a)
    @assert !isa(a, STuple)
    return rt_copy_own(a)
end

function rt_convert2def(a::STuple)
    @error_check(length(a.list) == 1, "cannot convert `$(rt_typestring(a))` to `def`")
    return rt_convert2def(a.list[1])
end


#### proc

function rt_convert2proc(a::Sproc)
    return a
end

function rt_convert2proc(a::STuple)
    @error_check(length(a.list) == 1, "cannot convert `$(rt_typestring(a))` to `proc`")
    return rt_convert2proc(a.list[1])
end

function rt_convert2proc(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `proc`")
    return defaultconstructor_proc()
end

#### int

function rt_convert2int(a::Int)
    return a
end

function rt_convert2int(a::BigInt)
    return Int(a)   # will throw if BigInt -> Int conversion fails
end

function rt_convert2int(a::STuple)
    @error_check(length(a.list) == 1, "cannot convert `$(rt_typestring(a))` to `int`")
    return rt_convert2int(a.list[1])
end

function rt_convert2int(a)
    rt_error("cannot convert a $(rt_typestring(a)) to an int")
    return Int(0)
end

const rt_cast2int = rt_convert2int

#### bigint

function rt_convert2bigint(a::Int)
    return BigInt(a)
end

function rt_convert2bigint(a::BigInt)
    return a
end

function rt_convert2bigint(a::STuple)
    @error_check(length(a.list) == 1, "cannot convert `$(rt_typestring(a))` to `bigint`")
    return rt_convert2bigint(a.list[1])
end

function rt_convert2bigint(a)
    rt_error("cannot convert `$(rt_typestring(a))` to a `bigint`")
    return BigInt(0)
end

const rt_cast2bigint = rt_convert2bigint

#### string

function rt_convert2string(a::Sstring)
    return a
end

function rt_convert2string(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `string`")
    return Sstring("")
end

function rt_cast2string(a::STuple)
    return Sstring(join([rt_print(i) for i in a.list], "\n"))
end

function rt_cast2string(a...)
    #TODO low priority: singular prints the bodies of proc's
    return Sstring(join([rt_print(i) for i in a], "\n"))
end

#### intvec

function rt_convert2intvec(a::Sintvec)
    return rt_copy_own(a)
end

function rt_convert2intvec(a::STuple)
    v = Int[]
    for i in a.list
        if i isa Sintvec
            append!(v, i.value)
        else
            push!(v, rt_convert2int(i))
        end
    end
    if isempty(v)
        push!(v, 0)
    end
    return Sintvec(v, false)
end

function rt_convert2intvec(a)
    rt_error("cannot convert to intvec")
    return rt_defaultconstructor_intvec()
end

function rt_cast2intvec(a...)
    v = Int[]
    for i in a
        if i isa Sintvec
            append!(v, i.value)
        else
            push!(v, rt_convert2int(i))
        end
    end
    if isempty(v)
        push!(v, 0)
    end
    return Sintvec(v, true)
end

#### intmat

function rt_convert2intmat(a::Sintmat)
    return rt_copy_own(a)
end

function rt__cast2intmat(a::Vector{Int}, nrows::Int, ncols::Int)
    @error_check(nrows >= 0 && ncols >= 0, "nrows and ncols of matrix cannot be negative")
    mat = zeros(Int, nrows, ncols)
    k = 1
    for i in 1:nrows
        for j in 1:ncols
            if k > length(a)
                break
            end
            mat[i, j] = a[k]
            k += 1
        end
    end
    return Sintmat(mat, true)
end

function rt_cast2intmat(a::Sintmat)
    return a
end

function rt_cast2intmat(a::Sintmat, nrows::Int, ncols::Int)
    return rt__cast2intmat(vec(a.value), nrows, ncols)
end

function rt_cast2intmat(a::Sintvec)
    return rt__cast2intmat(a.value, length(a.value), 1)
end

function rt_cast2intmat(a::Sintvec, nrows::Int, ncols::Int)
    return rt__cast2intmat(a.value, nrows, ncols)
end

function rt_cast2intmat(a::Sbigintmat)
    return rt__cast2intmat(map(Int, vec(a.value)), size(a.value)...)
end

function rt_cast2intmat(a::Sbigintmat, nrows::Int, ncols::Int)
    return rt__cast2intmat(map(Int, vec(a.value)), nrows, ncols)
end


#### bigintmat

function rt_convert2bigintmat(a::Sbigintmat)
    return rt_copy_own(a)
end

function rt_convert2bigintmat(a::Sintmat)
    return Sbigintmat(map(BigInt, a.value), false)
end

function rt_cast2bigintmat(a::Sbigintmat)
    return a
end

function rt_cast2bigintmat(a::Sintmat)
    return Sbigintmat(map(BigInt, a.value), true)
end

#### list

function rt_convert2list(a::Slist)
    return rt_copy_own(a)
end

function rt_convert2list(a::Union{Int, BigInt, Sproc, Sintvec, Sintmat, Sbigintmat})
    return Slist(Any[a], rtInvalidRing, 0, nothing, false)
end

function rt_convert2list(a::Union{Snumber, Spoly, Svector})
    @warn_check_rings(a.parent, rt_basering(), "object encountered from a foreign ring")
    return Slist(Any[a], a.parent, 1, nothing, false)
end

function rt_convert2list(a::STuple)
    data = Any[rt_copy_own(x) for x in a.list]
    count = 0
    for i in data
        count += rt_is_ring_dep(i)
    end
    return Slist(data, count == 0 ? rtInvalidRing : rt_basering(), count, nothing, false)
end

function rt_convert2list(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `list`")
    return rt_defaultconstructor_list()
end

function rt_cast2list(a...)
    data = Any[rt_copy_own(x) for x in a]
    count = 0
    for i in data
        count += rt_is_ring_dep(i)
    end
    return Slist(data, count == 0 ? rtInvalidRing : rt_basering(), count, nothing, true)
end

#### ring

function rt_convert2ring(a::Sring)
    return a
end

function rt_convert2ring(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `ring`")
    return rtInvalidRing
end

#### number

function rt_convert2number(a::Snumber)
    return a
end

function rt_convert2number(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to a number when no basering is active")
    r = libSingular.n_Init(a, R.value)
    return Snumber(r, R)
end

function rt_convert2number(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `number`")
    return rt_defaultconstructor_number()
end

#### poly

# return a new libSingular.poly not owned by any instance of a SingularType
function rt_convert2poly_ptr(a::Union{Int, BigInt}, R::Sring)
    @error_check(R.valid, "cannot convert to a polynomial when no basering is active")
    r = libSingular.n_Init(a, R.value)
    return libSingular.p_NSet(r, R.value)
end

function rt_convert2poly_ptr(a::Snumber, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a polynomial from a different basering")
    r = libSingular.n_Copy(a.value, a.parent.value)
    return libSingular.p_NSet(r, a.parent.value)
end

function rt_convert2poly_ptr(a::Spoly, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a polynomial from a different basering")
    return libSingular.p_Copy(a.value, a.parent.value)
end

function rt_convert2poly(a::Union{Int, BigInt})
    R = rt_basering()
    r = rt_convert2poly_ptr(a, R)
    return Spoly(r, R)
end

function rt_convert2poly(a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "converting to a polynomial outside of basering")
    r = rt_convert2poly_ptr(a, a.parent)
    return Spoly(r, a.parent)
end

function rt_convert2poly(a::Spoly)
    return a
end

function rt_convert2poly(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `poly`")
    return rt_defaultconstructor_poly()
end

#### vector

function rt_convert2vector_ptr(a::Union{Int, BigInt, Snumber, Spoly}, R::Sring)
    @error_check(R.valid, "cannot convert to a vector when no basering is active")
    r = rt_convert2poly_ptr(a, R)
    libSingular.p_SetCompP(r, 1, R.value)       # mutate r inplace
    return r
end

function rt_convert2vector_ptr(a::Svector, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a vector from a different basering")
    return libSingular.p_Copy(a.value, a.parent.value)
end

function rt_convert2vector(a::Union{Int, BigInt})
    R = rt_basering()
    r = rt_convert2poly_ptr(a, R.parent)
    libSingular.p_SetCompP(r, 1, R.parent.value)        # mutate r inplace
    return Svector(r, R)
end

function rt_convert2vector(a::Union{Snumber, Spoly})
    @warn_check_rings(a.parent, rt_basering(), "converting to a vector outside of basering")
    r = rt_convert2poly_ptr(a, a.parent)
    libSingular.p_SetCompP(r, 1, a.parent.value)        # mutate r inplace
    return Svector(r, a.parent)
end

function rt_convert2vector(a::Svector)
    return a
end

function rt_convert2vector(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `vector`")
    return rt_defaultconstructor_vector()
end

function rt_cast2vector(a...)
    rt_error("vector(...) is unavailable; use brackets [...] for `vector` cast")
    return rt_defaultconstructor_vector()

end

#### ideal

function rt_convert2ideal_ptr(a::Union{Int, BigInt, Snumber, Spoly}, R::Sring)
    p = rt_convert2poly_ptr(a, R)
    r = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r, p, 0) # p is consumed
    return r
end

function rt_convert2ideal_ptr(a::Sideal, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a ideal from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.idInit(0, 1)
    else
        r = libSingular.id_Copy(a.value, a.parent.value)
    end
    return r
end

function rt_convert2ideal(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to an ideal when no basering is active")
    r = rt_convert2ideal_ptr(a, R)
    return Sideal(r, R, false)
end

function rt_convert2ideal(a::Union{Snumber, Spoly})
    @warn_check_rings(a.parent, rt_basering(), "converting to a ideal outside of basering")
    r = rt_convert2ideal_ptr(a, a.parent)
    return Sideal(r, a.parent, false)
end

function rt_convert2ideal(a::Sideal)
    return rt_copy_own(a)
end

function rt_convert2ideal(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `ideal`")
    return rt_defaultconstructor_ideal()
end

function rt_cast2ideal(a...)
    # answer must be wrapped in Sideal at all times because rt_convert2ideal_ptr might throw
    r::Sideal = rt_new_empty_ideal()
    for i in a
        libSingular.id_append(r.value, rt_convert2ideal_ptr(i, r.parent), r.parent.value)
    end
    return r
end


#### module

function rt_convert2module_ptr(a::Union{Int, BigInt, Snumber, Spoly, Svector}, R::Sring)
    @error_check(R.valid, "cannot convert to a module when no basering is active")
    r1 = rt_convert2vector_ptr(a, R)
    r2 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return r2
end

function rt_convert2module_ptr(a::Sideal, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a module from a different basering")
    r1 = rt_convert2ideal_ptr(a, R)
    r2 = libSingular.id_Matrix2Module(r1, R.value)  # r1 is consumed
    return r2
end

function rt_convert2module_ptr(a::Smodule, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a module from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.idInit(0, 1)
    else
        r = libSingular.id_Copy(a.value, a.parent.value)
    end
    return r
end

function rt_convert2module_ptr(a::Smatrix, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a module from a different basering")
    r1 = rt_convert2matrix_ptr(a, R)
    r2 = libSingular.id_Matrix2Module(r1, R.value)  # r1 is consumed
    return r2
end

function rt_convert2module(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to a module when no basering is active")
    r = rt_convert2module_ptr(a, R)
    return Smodule(r, R, false)
end

function rt_convert2module(a::Union{Snumber, Spoly, Svector, Sideal})
    @warn_check_rings(a.parent, rt_basering(), "converting to a module outside of basering")
    r = rt_convert2module_ptr(a, a.parent)
    return Smodule(r, a.parent)
end

function rt_convert2module(a::Smodule)
    return rt_copy_own(a)
end

function rt_convert2module(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `module`")
    return rt_defaultconstructor_module()
end

function rt_cast2module(a...)
    # answer must be wrapped in Smodule at all times because rt_convert2module_ptr might throw
    r::Smodule = rt_new_empty_module()
    for i in a
        libSingular.id_append(r.value, rt_convert2module_ptr(i, r.parent), r.parent.value)
    end
    return r
end


#### matrix

function rt_convert2matrix_ptr(a::Union{Int, BigInt, Snumber, Spoly}, R::Sring)
    p = rt_convert2poly_ptr(a, R)
    r = libSingular.mpNew(1, 1)
    libSingular.mp_setindex(r, 1, 1, p, R.value) # p is consumed
    return r
end

function rt_convert2matrix_ptr(a::Sintvec, R::Sring)
    @error_check(R.valid, "cannot convert to a matrix when no basering is active")
    nrows = length(a.value)
    r = libSingular.mpNew(nrows, 1)
    for i in 1:nrows
        libSingular.mp_setindex(r, i, 1, libSingular.p_ISet(a.value[i], R.value), R.value)
    end
    return r
end

function rt_convert2matrix_ptr(a::Sintmat, R::Sring)
    @error_check(R.valid, "cannot convert to a matrix when no basering is active")
    nrows, ncols = size(a.value)
    r = libSingular.mpNew(nrows, ncols)
    for i in 1:nrows
        for j in 1:ncols
            libSingular.mp_setindex(r, i, j, libSingular.p_ISet(a.value[i, j], R.value), R.value)
        end
    end
    return r
end

function rt_convert2matrix_ptr(a::Svector, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a matrix from a different basering")
    # mp_from_vector (really id_Vec2Ideal) does not modify its input :)
    return libSingular.mp_from_vector(a.value, a.parent.value)
end

function rt_convert2matrix_ptr(a::Sideal, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a matrix from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.idInit(0, 1)
    else
        r = libSingular.id_Copy(a.value, a.parent.value)
    end
    return libSingular.mp_from_ideal(r)   # this is just a pointer cast
end

function rt_convert2matrix_ptr(a::Smodule, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a matrix from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.idInit(0, 1)
    else
        r = libSingular.id_Copy(a.value, a.parent.value)
    end
    return libSingular.id_Module2Matrix(r, a.parent.value) # consume r
end

function rt_convert2matrix_ptr(a::Smatrix, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a matrix from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.mpNew(0, 0)
    else
        r = libSingular.mp_Copy(a.value, a.parent.value)
    end
    return r
end

function rt_convert2matrix(a::Union{Int, BigInt, Sintvec, Sintmat})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to a module when no basering is active")
    r = rt_convert2matrix_ptr(a, R)
    return Smatrix(r, R, false)
end

function rt_convert2matrix(a::Union{Snumber, Spoly, Svector, Sideal, Smodule})
    @warn_check_rings(a.parent, rt_basering(), "converting to a module outside of basering")
    r = rt_convert2matrix_ptr(a, a.parent)
    return Smatrix(r, a.parent, false)
end

function rt_convert2matrix(a::Smatrix)
    return rt_copy_own(a)
end


function rt_convert2matrix(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `matrix`")
    return rt_defaultconstructor_matrix()
end

function rt_cast2matrix(a...)
    rt_error("matrix cast not implemented")
    return rt_defaultconstructor_matrix()
end



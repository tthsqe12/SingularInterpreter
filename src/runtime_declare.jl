########### declarers and default constructors ################################
# each type T has a
#   rt_parameter_T:          used for putting the arguments of a proc into the new scope
#   rt_declare_T:            may print a warning/error on redeclaration
#   rt_defaultconstructor_T: can only fail for ringdep types when there is no basering

function rt_declare_warnerror(old_value::Any, x::Symbol, t)
    if old_value isa t
        rt_warn("redeclaration of " * rt_typestring(old_value) * " " * string(x))
    else
        rt_error("identifier " * string(x) * " in use as a " * rt_typestring(old_value))
    end
end

# return does not matter, new entry symbol => value will be simply pushed onto rtGlobal.local_vars
function rt_check_declaration_local(a::Symbol, typ)
    n = length(rtGlobal.callstack)
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a
            rt_declare_warnerror(vars[i].second, a, typ)
        end
    end
end

# supposed to return a Dict{Symbol, Any} where we can store the variable
function rt_check_declaration_global_ring_indep(a::Symbol, typ)
    n = length(rtGlobal.callstack)
    p = rtGlobal.callstack[n].current_package
    R = rtGlobal.callstack[n].current_ring

    # first make sure that current ring does not have this entry
    if R.valid && haskey(R.vars, a)
        rt_declare_warnerror(R.vars[a], a, typ)
    end

    # make sure the current package does not have this entry
    if haskey(rtGlobal.vars, p)
        d = rtGlobal.vars[p]
        if haskey(d, a)
            rt_declare_warnerror(d[a], a, typ)
        end
        return d
    else
        # uncommon (impossible?) case where the current package does not have an entry in rtGlobal.vars
        d = Dict{Symbol, Any}()
        rtGlobal.vars[p] = d
        return d
    end
end

# supposed to return a Dict{Symbol, Any} where we can store the variable
function rt_check_declaration_global_ring_dep(a::Symbol, typ)
    n = length(rtGlobal.callstack)
    p = rtGlobal.callstack[n].current_package
    R = rtGlobal.callstack[n].current_ring

    # first make sure the current package does not have this entry
    if haskey(rtGlobal.vars, p)
        d = rtGlobal.vars[p]
        if haskey(d, a)
            rt_declare_warnerror(d[a], a, typ)
        end
    else
        # uncommon (impossible?) case where the current package does not have an entry in rtGlobal.vars
    end

    # make sure that current ring does not have this entry
    @error_check(R.valid, "cannot declare a ring-dependent type without a basering")

    if haskey(R.vars, a)
        rt_declare_warnerror(R.vars[a], a, typ)
    end

    return R.vars
end

function rt_local_identifier_exists(a::Symbol)
    n = length(rtGlobal.callstack)
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a
            return true
        end
    end
    return false
end

#### def

function rt_defaultconstructor_def()
    return nothing
end

function rt_declare_def(a::Vector{SName})
    for i in a
        rt_declare_def(i)
    end
end

function rt_declare_def(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Any)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_def()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Any)
        d[a.name] = rt_defaultconstructor_def()
    end
end

function rt_parameter_def(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2def(b)))
end

#### proc
function rt_empty_proc(v...) # only used by rt_defaultconstructor_proc
    rt_error("cannot call empty proc")
end

function rt_defaultconstructor_proc()
    return Sproc(rt_empty_proc, "empty proc", :Top)
end

function rt_declare_proc(a::Vector{SName})
    for i in a
        rt_declare_proc(i)
    end
end

function rt_declare_proc(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sproc)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_proc()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sproc)
        d[a.name] = rt_defaultconstructor_proc()
    end
end

function rt_parameter_proc(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2proc(b)))
end

#### int
function rt_defaultconstructor_int()
    return Int(0)
end

function rt_declare_int(a::Vector{SName})
    for i in a
        rt_declare_int(i)
    end
end

function rt_declare_int(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Int)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_int()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Int)
        d[a.name] = rt_defaultconstructor_int()
    end
end

function rt_parameter_int(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2int(b)))
end

#### bigint
function rt_defaultconstructor_bigint()
    return BigInt(0)
end

function rt_declare_bigint(a::Vector{SName})
    for i in a
        rt_declare_bigint(i)
    end
end

function rt_declare_bigint(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, BigInt)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_bigint()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, BigInt)
        d[a.name] = rt_defaultconstructor_bigint()
    end
end

function rt_parameter_bigint(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2bigint(b)))
end

#### string
function rt_defaultconstructor_string()
    return Sstring("")
end

function rt_declare_string(a::Vector{SName})
    for i in a
        rt_declare_string(i)
    end
end

function rt_declare_string(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sstring)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_string()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sstring)
        d[a.name] = rt_defaultconstructor_string()
    end
end

function rt_parameter_string(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2string(b)))
end

#### intvec
function rt_defaultconstructor_intvec()
    return Sintvec(Int[0], false)
end

function rt_declare_intvec(a::Vector{SName})
    for i in a
        rt_declare_intvec(i)
    end
end

function rt_declare_intvec(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sintvec)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_intvec()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sintvec)
        d[a.name] = rt_defaultconstructor_intvec()
    end
end

function rt_parameter_intvec(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intvec(b)))
end

#### intmat
function rt_defaultconstructor_intmat(nrows::Int = 1, ncols::Int = 1)
    return Sintmat(zeros(Int, nrows, ncols), false)
end

function rt_declare_intmat(a::Vector{SName}, nrows::Int = 1, ncols::Int = 1)
    for i in a
        rt_declare_intmat(i, nrows, ncols)
    end
end

function rt_declare_intmat(a::SName, nrows::Int = 1, ncols::Int = 1)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sintmat)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_intmat(nrows, ncols)))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sintmat)
        d[a.name] = rt_defaultconstructor_intmat(nrows, ncols)
    end
end

function rt_parameter_intmat(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intmat(b)))
end

#### bigintmat
function rt_defaultconstructor_bigintmat(nrows::Int = 1, ncols::Int = 1)
    return Sbigintmat(zeros(BigInt, nrows, ncols), false)
end

function rt_declare_bigintmat(a::Vector{SName}, nrows::Int = 1, ncols::Int = 1)
    for i in a
        rt_declare_bigintmat(i, nrows, ncols)
    end
end

function rt_declare_bigintmat(a::SName, nrows::Int = 1, ncols::Int = 1)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sbigintmat)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_bigintmat(nrows, ncols)))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sbigintmat)
        d[a.name] = rt_defaultconstructor_bigintmat(nrows, ncols)
    end
    return nothing
end

function rt_parameter_bigintmat(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2bigintmat(b)))
end

#### list
function rt_defaultconstructor_list()
    return Slist(Any[], rtInvalidRing, 0, nothing, false)
end

function rt_declare_list(a::Vector{SName})
    for i in a
        rt_declare_list(i)
    end
end

function rt_declare_list(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Slist)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_list()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Slist)
        d[a.name] = rt_defaultconstructor_list()
    end
    return nothing
end

function rt_parameter_list(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2list(b)))
end

#### ring
function rt_defaultconstructor_ring()
    return rtInvalidRing
end

# declaring a ring requires special treatment in transpiler.jl

function rt_parameter_ring(a::SName, b)
    #rt_warn("rings are not allowed as parameters for some reason")
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2ring(b)))
end

#### number
function rt_defaultconstructor_number()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a number when no basering is active")
    r1 = libSingular.n_Init(0, R.value)
    return Snumber(r1, R)
end

function rt_declare_number(a::Vector{SName})
    for i in a
        rt_declare_number(i)
    end
end

function rt_declare_number(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SNumber)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_number()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Snumber)
        d[a.name] = rt_defaultconstructor_number()
    end
    return nothing
end

function rt_parameter_number(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2number(b)))
end

#### poly
function rt_defaultconstructor_poly()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a polynomial when no basering is active")
    r1 = libSingular.p_null_helper()
    return Spoly(r1, R)
end

function rt_declare_poly(a::Vector{SName})
    for i in a
        rt_declare_poly(i)
    end
end

function rt_declare_poly(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Spoly)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_poly()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Spoly)
        d[a.name] = rt_defaultconstructor_poly()
    end
    return nothing
end

function rt_parameter_poly(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2poly(b)))
end

#### vector
function rt_defaultconstructor_vector()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a vector when no basering is active")
    r1 = libSingular.p_null_helper()
    return Svector(r1, R)
end

# special constructor via [poly...]
function rt_bracket_constructor(v...)
    R = rt_basering()
    r = Svector(libSingular.p_null_helper(), R)
    for i in 1:length(v)
        p = rt_convert2poly_ptr(v[i], R)
        libSingular.p_SetCompP(p, i, R.value)               # mutate p inplace
        r.value = libSingular.p_Add_q(r.value, p, R.value)  # consume both summands
    end
    return r
end

function rt_declare_vector(a::Vector{SName})
    for i in a
        rt_declare_vector(i)
    end
end

function rt_declare_vector(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Svector)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_vector()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Svector)
        d[a.name] = rt_defaultconstructor_vector()
    end
    return nothing
end

function rt_parameter_vector(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2vector(b)))
end

#### ideal
function rt_defaultconstructor_ideal()
    R = rt_basering()
    @error_check(R.valid, "cannot construct an ideal when no basering is active")
    id = libSingular.idInit(1,1)
    libSingular.setindex_internal(id, libSingular.p_null_helper(), 0)
    return Sideal(id, R, false)
end

function rt_new_empty_ideal(temp::Bool = true)
    R = rt_basering()
    @error_check(R.valid, "cannot construct an ideal when no basering is active")
    h = libSingular.idInit(0, 1)
    return Sideal(h, R, temp)
end

function rt_declare_ideal(a::Vector{SName})
    for i in a
        rt_declare_ideal(i)
    end
end

function rt_declare_ideal(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sideal)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_ideal()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Sideal)
        d[a.name] = rt_defaultconstructor_ideal()
    end
    return nothing
end

function rt_parameter_ideal(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2ideal(b)))
end

#### module
function rt_defaultconstructor_module()
    R = rt_basering()
    @error_check(R.valid, "cannot construct an module when no basering is active")
    id = libSingular.idInit(1,1)
    libSingular.setindex_internal(id, libSingular.p_null_helper(), 0)
    return Smodule(id, R, false)
end

function rt_new_empty_module(temp::Bool = true)
    R = rt_basering()
    @error_check(R.valid, "cannot construct an module when no basering is active")
    h = libSingular.idInit(0, 1)
    return Smodule(h, R, temp)
end

function rt_declare_module(a::Vector{SName})
    for i in a
        rt_declare_module(i)
    end
end

function rt_declare_module(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Smodule)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_module()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Smodule)
        d[a.name] = rt_defaultconstructor_module()
    end
    return nothing
end

function rt_parameter_module(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2module(b)))
end

#### matrix
function rt_defaultconstructor_matrix(nrows::Int = 1, ncols::Int = 1)
    R = rt_basering()
    @error_check(R.valid, "cannot construct a matrix when no basering is active")
    m = libSingular.mpNew(nrows, ncols)
    return Smatrix(m, R, false)
end

function rt_declare_matrix(a::Vector{SName}, nrows::Int = 1, ncols::Int = 1)
    for i in a
        rt_declare_matrix(i, nrows, ncols)
    end
end

function rt_declare_matrix(a::SName, nrows::Int = 1, ncols::Int = 1)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Smatrix)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_matrix(nrows, ncols)))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Smatrix)
        d[a.name] = rt_defaultconstructor_matrix(nrows, ncols)
    end
end

function rt_parameter_matrix(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2matrix(b)))
end

#### map
function rt_defaultconstructor_map()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a map when no basering is active")
    ma = libSingular.maInit(1)
    return Smap(ma, R, R, false)
end

function rt_new_empty_map(S::Sring, temp::Bool = true)
    R = rt_basering()
    @error_check(R.valid, "cannot construct a map when no basering is active")
    ma = libSingular.ma_Init(0)
    return Smap(ma, S, R, temp)
end

function rt_declare_map(a::Vector{SName})
    for i in a
        rt_declare_map(i)
    end
end

function rt_declare_map(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Smap)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_map()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, Smap)
        d[a.name] = rt_defaultconstructor_map()
    end
    return nothing
end

function rt_parameter_map(a::SName, b)
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2map(b)))
end


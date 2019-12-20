#=
basic functions needed for each type T in order to work with the runtime:
    copy/reference
    declare/parameter
    defaultconstructor
    convert/cast
    print

the full installer for a new type is in rt_convert_newstruct_decl below

rt = singular runtime, prefix for functions used at runtime.

rt prefix generally means the function corresponds to a singular cmd/operator
rt_ prefix generally means it used internally and/or does not correspond to a cmd/operator
    SINGULAR        JULIA
    print(a)        rtprint(a)
    a + b + c       rtplus(rtplus(a, b), c)
    a;              rt_printout(a)
    minpoly = p;    rt_set_minpoly(p)
    p + minpoly     rtplus(p, rt_get_minpoly())
=#


# all of the singular types have trivial iterators - will be used because all arguments to functions are automatically splatted
# TODO: more meta, less typing
Base.iterate(a::SName) = iterate(a, 0)
Base.iterate(a::SName, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Nothing) = iterate(a, 0)
Base.iterate(a::Nothing, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SProc) = iterate(a, 0)
Base.iterate(a::SProc, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SString) = iterate(a, 0)
Base.iterate(a::SString, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIntVec) = iterate(a, 0)
Base.iterate(a::SIntVec, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIntMat) = iterate(a, 0)
Base.iterate(a::SIntMat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SBigIntMat) = iterate(a, 0)
Base.iterate(a::SBigIntMat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SList) = iterate(a, 0)
Base.iterate(a::SList, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SRing) = iterate(a, 0)
Base.iterate(a::SRing, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SPoly) = iterate(a, 0)
Base.iterate(a::SPoly, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIdeal) = iterate(a, 0)
Base.iterate(a::SIdeal, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SMatrix) = iterate(a, 0)
Base.iterate(a::SMatrix, state) = (state == 0 ? (a, 1) : nothing)


########################## copying, ect. ######################################

# TODO: get rid of dictionary
function Base.deepcopy_internal(a::SProc, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SIntVec, dict::IdDict)
    return SIntVec(deepcopy(a.vector))
end

function Base.deepcopy_internal(a::SIntMat, dict::IdDict)
    return SIntMat(deepcopy(a.matrix))
end

function Base.deepcopy_internal(a::SBigIntMat, dict::IdDict)
    return SBigIntMat(deepcopy(a.matrix))
end

function Base.deepcopy_internal(a::SListData, dict::IdDict)
    return SListData(deepcopy(a.data), a.parent, a.ring_dep_count, nothing)
end

function Base.deepcopy_internal(a::SList, dict::IdDict)
    return SList(deepcopy(a.list))
end

function Base.deepcopy_internal(a::SRing, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SNumber, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SPoly, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SIdealData, dict::IdDict)
    id = libSingular.id_Copy(a.ideal_ptr, a.parent.ring_ptr)
    return SIdealData(id, a.parent)
end

function Base.deepcopy_internal(a::SIdeal, dict::IdDict)
    return SIdeal(deepcopy(a.ideal))
end

# copiers returning SingularType, usually so that we can assign it somewhere
# we have to copy stuff, and usually the stuff to copy is allowed to be a tuple
# rt_copy_allow_tuple will be called on stuff inside (), i.e. if the object (a,f(b),c)
# needs to be constructed, it might be constructed in julia as
# tuple(a, rt_copy_allow_tuple(f(b))..., c)

# if f(b) returns a tuple t, then rt_copy_allow_tuple(t) will simply return t
# if f(b) returns a SBigIntMat m, then rt_copy_allow_tuple(m) will simply return m and the iterator is trivial
# if f(b) returns a Array{BigInt, 2} m, then rt_copy_allow_tuple(m) makes a deepcopy and returns a SBigIntMat, whose iterator is trivial

# rt_copy: copy with an error on tuples
# rt_copy_allow_tuple: copy everything rt_copy can copy and also allow tuples through

# rt_copy is probably only used internally since anything the transpiler would want to copy could be a tuple

rt_copy(a::Nothing) = a
rt_copy_allow_tuple(a::Nothing) = a

rt_copy(a::SProc) = a
rt_copy_allow_tuple(a::SProc) = a

rt_copy(a::SName) = error("internal error: The name $a leaked through. Please report this.")
rt_copy_allow_tuple(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_copy(a::Int) = a
rt_copy_allow_tuple(a::Int) = a

rt_copy(a::BigInt) = a
rt_copy_allow_tuple(a::BigInt) = a

rt_copy(a::SString) = a
rt_copy_allow_tuple(a::SString) = a

rt_copy(a::Vector{Int}) = SIntVec(deepcopy(a))
rt_copy(a::SIntVec) = a
rt_copy_allow_tuple(a::Vector{Int}) = SIntVec(deepcopy(a))
rt_copy_allow_tuple(a::SIntVec) = a

rt_copy(a::Array{Int, 2}) = SIntMat(deepcopy(a))
rt_copy(a::SIntMat) = a
rt_copy_allow_tuple(a::Array{Int, 2}) = SIntMat(deepcopy(a))
rt_copy_allow_tuple(a::SIntMat) = a

rt_copy(a::Array{BigInt, 2}) = SBigIntMat(deepcopy(a))
rt_copy(a::SBigIntMat) = a
rt_copy_allow_tuple(a::Array{BigInt, 2}) = SBigIntMat(deepcopy(a))
rt_copy_allow_tuple(a::SBigIntMat) = a

rt_copy(a::SListData) = SList(deepcopy(a))
rt_copy(a::SList) = a
rt_copy_allow_tuple(a::SListData) = SList(deepcopy(a))
rt_copy_allow_tuple(a::SList) = a

rt_copy(a::SRing) = a
rt_copy_allow_tuple(a::SRing) = a

rt_copy(a::SNumber) = a
rt_copy_allow_tuple(a::SNumber) = a

rt_copy(a::SPoly) = a
rt_copy_allow_tuple(a::SPoly) = a

rt_copy(a::SIdealData) = SIdeal(deepcopy(a))
rt_copy(a::SIdeal) = a
rt_copy_allow_tuple(a::SIdealData) = SIdeal(deepcopy(a))
rt_copy_allow_tuple(a::SIdeal) = a

rt_copy(a::Tuple{Vararg{Any}}) = error("internal error: The tuple $a leaked through. Please report this.")
rt_copy_allow_tuple(a::Tuple{Vararg{Any}}) = a


# copiers returning non SingularType, usually so that we can mutate it
# only used internally for convenience by the runtime, and should not be output by transpiler

rt_edit(a::Vector{Int}) = deepcopy(a)
rt_edit(a::SIntVec) = a.vector

rt_edit(a::Array{Int, 2}) = deepcopy(a)
rt_edit(a::SIntMat) = a.matrix

rt_edit(a::Array{BigInt, 2}) = deepcopy(a)
rt_edit(a::SBigIntMat) = a.matrix

rt_edit(a::SListData) = deepcopy(a)
rt_edit(a::SList) = a.list


# get the underlying mutable object if it exists

rt_ref(a::Nothing) = a

rt_ref(a::SProc) = a

rt_ref(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_ref(a::Int) = a

rt_ref(a::BigInt) = a

rt_ref(a::SString) = a

rt_ref(a::Vector{Int}) = a
rt_ref(a::SIntVec) = a.vector

rt_ref(a::Array{Int, 2}) = a
rt_ref(a::SIntMat) = a.matrix

rt_ref(a::Array{BigInt, 2}) = a
rt_ref(a::SBigIntMat) = a.matrix

rt_ref(a::SListData) = a
rt_ref(a::SList) = a.list

rt_ref(a::SRing) = a

rt_ref(a::SPoly) = a

rt_ref(a::SIdealData) = a
rt_ref(a::SIdeal) = a.ideal


# rt_ringof has to be used for .r_... members of newstruct, which are read-only
function rt_ringof(a)
    if isa(a, _List)
        r = rt_ref(a).parent
        r.valid || rt_error("sorry, this list does not have a basering")
        return r
    elseif isa(a, _SingularRingType)
        return rt_ref(a).parent
    else
        rt_error("type " * rt_typestring(a) * " does not have a basering")
        return rtInvalidRing
    end
end


function rt_is_ring_dep(a)
    if isa(a, _List)
        return rt_ref(a).parent.valid
    else
        return isa(a, _SingularRingType)
    end
end


function object_is_ok(a::SListData)
    count = 0
    for i in a.data
        count += rt_is_ring_dep(i)
        if isa(i, SListData)
            println("list does not own one of its sublists")
            return false
        elseif isa(i, SName)
            println("list contains a name")
            return false
        elseif isa(i, Tuple)
            println("list contains a tuple")
            return false
        end
        if !object_is_ok(i)
            println("list contains a bad element")
            return false
        end
    end
    if count != a.ring_dep_count
        println("list has incorrect count $(a.ring_dep_count); correct is $(count)")
        return false
    end
    if count > 0
        if !a.parent.valid
            println("list has ring dependent elements but parent is not valid")
        end
    else
        if a.parent.valid
            println("list has no ring dependent elements but parent is valid")
        end
    end
    return true
end

function object_is_ok(a::SList)
    object_is_ok(a.list)
end

function object_is_ok(a)
    return true
end



function rt_basering()
    return rtGlobal.callstack[end].current_ring
end


function rt_search_locals(a::Symbol)
    n = length(rtGlobal.callstack)
    R = rtGlobal.callstack[n].current_ring
    for i in rtGlobal.callstack[n].start_local_vars:length(rtGlobal.local_vars)
        if rtGlobal.local_vars[i].first == a
            if isa(a, SingularRingType)
                if a.parent === R
                    return true, i
                end
            else
                return true, i
            end
        end
    end
    return false, 0
end


########################## make and friends ###################################

function rt_box_it_with_ring(n::libSingular.number, r::SRing)
    return SNumber(n, r)
end

function rt_box_it_with_ring(p::libSingular.poly, r::SRing)
    return SPoly(p, r)
end


# make takes a name and looks it up according to singular's resolution rules
# this function is named make in the c singular interpreter code
function rt_make(a::SName, allow_unknown::Bool = false)

    # local
    b, i = rt_search_locals(a.name)
    if b
        # local lists are expected to not know their names after make
        # TODO: make another function rt_ref_local that does all of this in one function
        v = rt_ref(rtGlobal.local_vars[i].second)
        if isa(v, SListData)
            v.list.back = nothing
        end
        return v
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                # global lists are expected to known their names after make
                v = d[a.name]
                if isa(v, SList)
                    v.list.back = a.name
                    return v.list
                else
                    return rt_ref(v)
                end
            end
        end
    end

    # global ring dependent
    R = rtGlobal.callstack[end].current_ring
    if haskey(R.vars, a.name)
        # ditto comment
        v = R.vars[a.name]
        if isa(b, SList)
            v.list.back = a.name
            return v.list
        else
            return rt_ref(v)
        end
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        return rt_box_it_with_ring(p, R)
    end

    allow_unknown || rt_error(String(a.name) * " is undefined")

    return a
end

function rtdefined(a::SName)

    # local
    b, i = rt_search_locals(a.name)
    if b
        return size(rtGlobal.callstack)
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                return 1
            end
        end
    end

    # global ring dependent
    R = rtGlobal.callstack[end].current_ring
    if haskey(R.vars, a.name)
        return 1
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        rt_box_it_with_ring(p, R) # consume p  TODO clean this up
        return -1
    end

    return 0
end

function rtdefined(a)
    return -1
end

function rtkill(a::SName)

    # local
    found, i = rt_search_locals(a.name)
    if found
        rtGlobal.local_vars[i] = rtGlobal.local_vars[end]
        pop!(rtGlobal.local_vars)
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                delete!(d, a.name)
                return
            end
        end
    end

    # global ring dependent
    R = rt_basering()
    if haskey(R.vars, a.name)
        delete!(R.vars, a.name)
        return
    end

    # hmm, where does this go
    if string(a.name) == "basering"
        rtGlobal.callstack[end].current_ring = rtInvalidRing
        return
    end

    rt_error("cannot kill " * String(a.name))
    return
end


function rt_backtick(a::SString)
    return makeunknown(a.string)
end

function rt_backtick(a)
    rt_error("string expected between backticks")
end


function rt_enterfunction(package::Symbol)
    i = length(rtGlobal.local_vars) + 1
    n = length(rtGlobal.callstack)
    push!(rtGlobal.callstack, rtCallStackEntry(i, rtGlobal.callstack[n].current_ring, package))
end

function rt_leavefunction()
    n = length(rtGlobal.callstack)
    @assert n > 1
    i = rtGlobal.callstack[n].start_local_vars - 1
    @assert length(rtGlobal.local_vars) >= i
    resize!(rtGlobal.local_vars, i)
    pop!(rtGlobal.callstack)
end



function rtcall(allow_name_ret::Bool, f::SProc, v...)
    return f.func(v...)
end

function rtcall(allow_name_ret::Bool, a::SName, v...)

    # local
    b, i = rt_search_locals(a.name)
    if b
        return rtcall(false, rtGlobal.local_vars[i].second, v...)
    end

    # global ring independent - proc
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                return rtcall(false, d[a.name], v...)
            end
        end
    end

    # global ring dependent - probably map
    if haskey(rt_basering().vars, a.name)
        return rtcall(false, rt_basering().vars[a.name], v...)
    end

    # newstruct constructors
    if haskey(rtGlobal.newstruct_casts, String(a.name))
        return rtGlobal.newstruct_casts[String(a.name)](v...)
    end

    # indexed variable constructor
    return rtcall(allow_name_ret, [String(a.name)], v...)
end

function rtcall(allow_name_ret::Bool, a::Array{String}, v...)
    # will take the cross product of a and V
    V = Int[]
    for i in v
        if isa(i, Int)
            push!(V, i)
        elseif isa(i, _IntVec)
            append!(V, rt_ref(i))
        else
            rt_error("bad indexed variable construction")
        end
    end

    isempty(a) && rt_error("bad indexed variable construction")
    isempty(V) && rt_error("bad indexed variable construction")

    if allow_name_ret
        r = Any[]
        for b in a
            for i in V
                c = rt_make(SName(Symbol(b * "(" * string(i) * ")")), true)
                if isa(c, SProc)    # TODO extend this to a list of "callable" types
                    push!(r, rt_copy(c))
                else
                    R = String[]
                    for B in a
                        for I in V
                            push!(R, B * "(" * string(I) * ")")
                        end
                    end
                    return R
                end
            end
        end
        return length(r) == 1 ? r[1] : Tuple(r)
    else
        r = Any[]
        for b in a
            for i in V
                c = rt_make(SName(Symbol(b * "(" * string(i) * ")")), true)
                if isa(c, SName)
                    rt_error("bad indexed variable construction")
                else
                    push!(r, rt_copy(c))
                end
            end
        end
        return length(r) == 1 ? r[1] : Tuple(r)
    end
end

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
    found, i = rt_search_locals(a)
    if found
        rt_declare_warnerror(rtGlobal.local_vars[i].second, a, typ)
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
    if R.valid
        if haskey(R.vars, a)
            rt_declare_warnerror(R.vars[a], a, typ)
        end
    else
        rt_error("cannot declare a ring-dependent type when no basering is active")
    end

    return R.vars
end

function rt_local_identifier_does_not_exist(a::Symbol)
    return length(rtGlobal.callstack) > 1 && !(rt_search_locals(a)[1])
end

#### def

function rt_defaultconstructor_def()
    return nothing
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
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2def(b)))
end

#### proc
function rt_empty_proc(v...) # only used by rt_defaultconstructor_proc
    rt_error("cannot call empty proc")
end

function rt_defaultconstructor_proc()
    return SProc(rt_empty_proc, "empty proc", :Top)
end

function rt_declare_proc(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SProc)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_proc()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SProc)
        d[a.name] = rt_defaultconstructor_proc()
    end
end

function rt_parameter_proc(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2proc(b)))
end

#### int
function rt_defaultconstructor_int()
    return Int(0)
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
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2int(b)))
end

#### bigint
function rt_defaultconstructor_bigint()
    return BigInt(0)
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
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2bigint(b)))
end

#### string
function rt_defaultconstructor_string()
    return SString("")
end

function rt_declare_string(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SString)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_string()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SString)
        d[a.name] = rt_defaultconstructor_string()
    end
end

function rt_parameter_string(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2string(b)))
end

#### intvec
function rt_defaultconstructor_intvec()
    return SIntVec(Int[0])
end

function rt_declare_intvec(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SIntVec)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_intvec()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SIntVec)
        d[a.name] = rt_defaultconstructor_intvec()
    end
end

function rt_parameter_intvec(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intvec(b)))
end

#### intmat
function rt_defaultconstructor_intmat(nrows::Int = 1, ncols::Int = 1)
    return SIntMat(zeros(Int, nrows, ncols))
end

function rt_declare_intmat(a::SName, nrows::Int = 1, ncols::Int = 1)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SIntMat)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_intmat(nrows, ncols)))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SIntMat)
        d[a.name] = rt_defaultconstructor_intmat(nrows, ncols)
    end
end

function rt_parameter_intmat(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intmat(b)))
end

#### bigintmat
function rt_defaultconstructor_bigintmat(nrows::Int = 1, ncols::Int = 1)
    return SBigIntMat(zeros(BigInt, nrows, ncols))
end

function rt_declare_bigintmat(a::SName, nrows::Int = 1, ncols::Int = 1)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SBigIntMat)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_bigintmat(nrows, ncols)))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SBigIntMat)
        d[a.name] = rt_defaultconstructor_bigintmat(nrows, ncols)
    end
    return nothing
end

function rt_parameter_bigintmat(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2bigintmat(b)))
end

#### list
function rt_defaultconstructor_list()
    return SList(SListData(Any[], rtInvalidRing, 0, nothing))
end

function rt_declare_list(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SList)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_list()))
    else
        d = rt_check_declaration_global_ring_indep(a.name, SList)
        d[a.name] = rt_defaultconstructor_list()
    end
    return nothing
end

function rt_parameter_list(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2list(b)))
end

#### number
function rt_defaultconstructor_number()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a number when no basering is active")
    r1 = libSingular.n_Init(0, R.ring_ptr)
    return SNumber(r1, R)
end

function rt_declare_number(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SNumber)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_number()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, SNumber)
        d[a.name] = rt_defaultconstructor_number()
    end
    return nothing
end

function rt_parameter_number(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2number(b)))
end

#### poly
function rt_defaultconstructor_poly()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a polynomial when no basering is active")
    r1 = libSingular.p_null_helper()
    return SPoly(r1, R)
end

function rt_declare_poly(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SPoly)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_poly()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, SPoly)
        d[a.name] = rt_defaultconstructor_poly()
    end
    return nothing
end

function rt_parameter_poly(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2poly(b)))
end

#### ideal
function rt_defaultconstructor_ideal()
    R = rt_basering()
    @error_check(R.valid, "cannot construct an ideal when no basering is active")
    id = libSingular.idInit(1,1)
    libSingular.setindex_internal(id, libSingular.p_null_helper(), 0)
    return SIdeal(SIdealData(id, R))
end

function rt_declare_ideal(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, SIdeal)
        push!(rtGlobal.local_vars, Pair(a.name, rt_defaultconstructor_ideal()))
    else
        d = rt_check_declaration_global_ring_dep(a.name, SIdeal)
        d[a.name] = rt_defaultconstructor_ideal()
    end
    return nothing
end

function rt_parameter_ideal(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2ideal(b)))
end

########### type conversions ##################################################
# each rt_convert2T(a) returns an object of type T, usually for an assignment
# each rt_convert2T(a) is a UNIARY function with no known exceptions
# each rt_cast2T(a...) is used when the type name T is used as a function, i.e. string(1), or list(1,2,3)

# Singular maintains bools as ints, julia needs real bools for control flow

function rt_asbool(a::Int)
    return a != 0
end

function rt_asbool(a)
    rt_error("expected int for boolean expression")
    return false
end

#### def

function rt_convert2def(a)
    return rt_copy(a)
end

function rt_convert2def(a...)
    rt_error("cannot convert $a to a def")
    return a
end


#### proc

function rt_convert2proc(a::SProc)
    return a
end

function rt_convert2proc(a...)
    rt_error("cannot convert $a to a proc")
    return defaultconstructor_proc()
end

#### int

function rt_convert2int(a::Int)
    return a
end

function rt_convert2int(a::BigInt)
    return Int(a)   # will throw if BigInt -> Int conversion fails
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

function rt_convert2bigint(a...)
    rt_error("cannot convert $a to a bigint")
    return BigInt(0)
end

const rt_cast2bigint = rt_convert2bigint

#### string

function rt_convert2string(a::SString)
    return a
end

function rt_convert2string(a...)
    rt_error("cannot convert $a to a string")
    return SString("")
end

function rt_cast2string(a::Int)
    return SString(string(a))
end

function rt_cast2string(a::SProc)
    return SString("proc "*string(a.name)) #TODO low priority: this is not how singular prints procs
end

function rt_cast2string(a...)
    error("cannot cast $a to a string")
    return SString("")
end

#### intvec

function rt_convert2intvec(a::SIntVec)
    return a
end

function rt_convert2intvec(a::Array{Int})
    return SIntVec(deepcopy(a))
end

function rt_convert2intvec(a::Tuple{Vararg{Any}})
    v = Int[]
    for i in a
        if i isa SIntVec
            append!(v, i.vector)
        else
            push!(v, rt_convert2int(i))
        end
    end
    if isempty(v)
        push!(v, 0)
    end
    return SIntVec(v)
end

function rt_convert2intvec(a)
    rt_error("cannot convert to intvec")
    return SIntVec(Int[])
end

function rt_cast2intvec(a...)
    return rt_convert2intvec(a)
end

#### intmat

function rt_convert2intmat(a::SIntMat)
    return a
end

function rt_convert2intmat(a::Array{Int, 2})
    return SIntMat(deepcopy(a))
end

function rt_convert2intmat(a::Tuple{Vararg{Any}}, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(Int, nrows, ncols)
    row_idx = col_idx = 1
    for i in a
        mat[row_idx, col_idx] = rt_convert2int(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SIntMat(mat)
end

#### bigintmat

function rt_convert2bigintmat(a::SBigIntMat)
    return a
end

function rt_convert2bigintmat(a::Array{BigInt, 2})
    return SBigIntMat(deepcopy(a))
end

function rt_convert2bigintmat(a::Tuple{Vararg{Any}}, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(BigInt, nrows, ncols)
    row_idx = col_idx = 1
    for i in a
        mat[row_idx, col_idx] = rt_convert2bigint(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SBigIntMat(mat)
end

#### list

function rt_convert2list(a::SList)
    return a
end

function rt_convert2list(a::SListData)
    return SList(deepcopy(a))
end

function rt_convert2list(a::Tuple{Vararg{Any}})
    data::Vector{Any} = collect(a)
    count = 0
    for i in data
        count += rt_is_ring_dep(i)
    end
    return SList(SListData(data, count == 0 ? rtInvalidRing : rt_basering(), count, nothing))
end

function rt_convert2list(a)
    rt_error("cannot convert a $(rt_typestring(a)) to an int")
    return rt_defaultconstructor_list()
end

function rt_cast2list(a...)
    data::Vector{Any} = [rt_copy(j) for j in a]
    count = 0
    for i in data
        count += rt_is_ring_dep(i)
    end
    return SList(SListData(data, count == 0 ? rtInvalidRing : rt_basering(), count, nothing))
end

#### number

function rt_convert2number(a::SNumber)
    return a
end

function rt_convert2number(a::Union{Int, BigInt})
    rtGlobal.currentring.valid || rt_error("cannot convert to a number when no basering is active")
    r1 = libSingular.n_Init(a.number_ptr, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rt_convert2number(a)
    rt_error("cannot convert $a to a number")
    return rt_defaultconstructor_number()
end

#### poly

# return a new libSingular.poly not owned by any instance of a SingularType
function rt_convert2poly_ptr(a::Union{Int, BigInt}, b::SRing)
    @error_check(b.valid, "cannot convert to a polynomial when no basering is active")
    r1 = libSingular.n_Init(a, b.ring_ptr)
    return libSingular.p_NSet(r1, b.ring_ptr)
end

function rt_convert2poly_ptr(a::SNumber, b::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == b.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    r1 = libSingular.n_Copy(a.number_ptr, a.parent.ring_ptr)
    return libSingular.p_NSet(r1, a.parrent.ring_ptr)
end

function rt_convert2poly_ptr(a::SPoly, b::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == b.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    return libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
end

function rt_convert2poly_ptr(a, b::SRing)
    rt_error("cannot convert $a to a polynomial")
    return libSingular.p_null_helper()
end

function rt_convert2poly(a::SPoly)
    return a
end

function rt_convert2poly(a::Union{Int, BigInt})
    R = rt_basering()
    r1 = rt_convert2poly_ptr(a, R)
    return SPoly(r1, R)
end

function rt_convert2poly(a::SNumber)
    @warn_check(a.apprent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    return SPoly(r1, a.parent)
end

function rt_convert2poly(a)
    rt_error("cannot convert $a to a polynomial")
    return rt_defaultconstructor_poly()
end


#### ideal

function rt_convert2ideal(a::_Ideal)
    return rt_copy(a)
end

function rt_convert2ideal(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to an ideal when no basering is active")
    r1 = rt_convert2poly_ptr(a, R)
    r2 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return SIdeal(SIdealData((r2, R)))
end

function rt_convert2ideal(a::Union{SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    r2 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return SIdeal(SIdealData(r2, a.parent))
end

function rt_convert2ideal(a::Tuple{Vararg{Any}})
    # just convert everything to an ideal and add them up
    # answer must be wrapped in SIdeal at all times because we might throw
    r::SIdeal = rt_defaultconstructor_ideal()
    for i in a
        @error_check(isa(i, Union{Int, BigInt, SNumber, SPoly, SIdeal}), "cannot convert $i to an ideal")
        r = rtplus(r, i)
    end
    return r
end

function rt_convert2ideal(a)
    rt_error("cannot convert $a to an ideal")
    return rt_defaultconstructor_ideal()
end

function rt_cast2ideal(a...)
    return rt_convert2ideal(a)
end


############ printing #########################################################

function rt_indenting_print(a::Nothing, indent::Int)
    return ""
end

function rt_indenting_print(a::SName, indent::Int)
    return rt_indenting_print(rt_make(a), indent)
end

function rt_indenting_print(a::SProc, indent::Int)
    return " "^indent * "procname: " * string(a.name)
end

function rt_indenting_print(a::Union{Int, BigInt}, indent::Int)
    return " "^indent * string(a)
end

function rt_indenting_print(a::SString, indent::Int)
    return " "^indent * a.string
end

function rt_indenting_print(A::Union{Array{Int, 2}, Array{BigInt, 2}}, indent::Int)
    s = ""
    nrows, ncols = size(A)
    for i in 1:nrows
        s *= " "^indent
        for j in 1:ncols
            s *= string(A[i,j])
            if j < ncols
                s *= ", " # TODO low priority: align columns
            end
        end
        if i < nrows
            s *= ",\n"
        end
    end
    return s
end

function rt_indenting_print(a::Union{SIntMat, SBigIntMat}, indent::Int)
    return rt_indenting_print(rt_ref(a))
end

function rt_indenting_print(a::SIntVec, indent::Int)
    return rt_indenting_print(a.vector, indent)
end

function rt_indenting_print(a::Vector{Int}, indent::Int)
    return " "^indent * join(map((x) -> string(x), a), ", ")
end

function rt_indenting_print(a::SList, indent::Int)
    return rt_indenting_print(rt_ref(a), indent)
end

function rt_indenting_print(a::SListData, indent::Int)
    s = ""
    A = a.data
    for i in 1:length(A)
        s *= " "^indent * "[" * string(i) * "]:\n"
        if A[i] isa Nothing
            continue
        end
        s *= rt_indenting_print(A[i], indent + 3)
        if i < length(A)
            s *= "\n"
        end
    end
    return s
end

function rt_indenting_print(a::SRing, indent::Int)
    s = libSingular.rPrint_helper(a.ring_ptr)
    i = " "^indent
    return i * join(split(s, r"\n|\r|\0"), "\n"*i)
end

function rt_indenting_print(a::SNumber, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a number outside of basering")
    libSingular.StringSetS("")
    libSingular.n_Write(a.number_ptr, a.parent.ring_ptr)
    return " "^indent * libSingular.StringEndS()
end


function rt_indenting_print(a::SPoly, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a polynomial outside of basering")
    s = libSingular.p_String(a.poly_ptr, a.parent.ring_ptr)
    return " "^indent * s
end

function rt_indenting_print(a::SIdeal, indent::Int)
    return rt_indenting_print(a.ideal, indent)
end

function rt_indenting_print(a::SIdealData, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing an ideal outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.ideal_ptr))
    for i in 1:n
        p = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.ring_ptr)
        s *= " "^indent * "[" * string(i) * "]: " * t * (i < n ? "\n" : "")
    end
    return s
end

function rt_indenting_print(a::Tuple{Vararg{Any}}, indent::Int)
    s = ""
    for b in a
        s *= rt_indenting_print(b, indent) * "\n"
    end
    return s
end

# the "print" function in Singular returns a string and does not print
function rtprint(::Nothing)
    return ""
end

function rtprint(a)
    return SString(rt_indenting_print(a, 0))
end

# the semicolon in Singular is the method to actually print something
function rt_printout(::Nothing)
    return  # we will probably be printing nothing often - very important to not print anything in this case
end

function rt_printout(a)
    rtGlobal.last_printed = rt_copy_allow_tuple(a)
    println(rt_indenting_print(a, 0))
end

function rt_get_last_printed()
    return rtGlobal.last_printed
end

# type ...; will call rt_printouttype. no idea how this is supposed to work
function rt_printouttype(a)
    println("add correct type printing here")
end

##################### typeof ##################################################

rt_typedata(::Nothing)     = "none"
rt_typedata(::SProc)       = "proc"
rt_typedata(::Int)         = "int"
rt_typedata(::BigInt)      = "bigint"
rt_typedata(::SString)     = "string"
rt_typedata(::_IntVec)     = "intvec"
rt_typedata(::_IntMat)     = "intmat"
rt_typedata(::_BigIntMat)  = "bigintmat"
rt_typedata(::_List)       = "list"
rt_typedata(::SRing)       = "ring"
rt_typedata(::SNumber)     = "number"
rt_typedata(::SPoly)       = "poly"
rt_typedata(::_Ideal)      = "ideal"
rt_typedata(a::Tuple{Vararg{Any}}) = String[rt_typedata(i) for i in a]

rt_typedata_to_singular(a::String) = SString(a)
rt_typedata_to_singular(a::Vector{String}) = Tuple([SString(i) for i in a])

rt_typedata_to_string(a::String) = a
rt_typedata_to_string(a::Vector{String}) = string('(', join(a, ", "), ')')

rttypeof(a) = rt_typedata_to_singular(rt_typedata(a))

rt_typestring(a) = rt_typedata_to_string(rt_typedata(a))


###################### assignment #############################################
# in general the operation of the assignment a = b in Singular depends on the
# values of a and b Therefore, singular a = b becomes julia a = rt_assign(a, b)

# The assignment to any variable "a" declared "def" must pass through rt_assign because:
#   (1) The initial value of "a" is nothing
#   (2) The first assignment to "a" with a non-nothing type on the rhs succeeds
#       and essentially determines the type of "a"
#   (3) Future assignments to "a" behave as if "a" had the type in (2)
# Since we don't know if an assignment is the first or not - and even if we did,
# we don't know the type of the rhs - all of this type checking is done by rt_assign

function rtassign(a::SName, b)

    # local
    ok, i = rt_search_locals(a.name)
    if ok
        l = rtGlobal.local_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, b))
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                if isa(d[a.name], SList)
                    rt_assign_global_list_ring_indep(d, a.name, rt_convert2list(b))
                else
                    d[a.name] = rt_assign(d[a.name], b)
                end
                return
            end
        end
    end

    # global ring dependent
    R = rtGlobal.callstack[end].current_ring    # same as rt_basering()
    if haskey(R.vars, a.name)
        if isa(R.vars[a.name], SList)
           rt_assign_global_list_ring_dep(R, a.name, rt_convert2list(b))
        else
            R.vars[a.name] = rt_assign(R.vars[a.name], b)
        end
        return
    end

    rt_error("cannot assign to " * String(a.name))
end

# a = b, a lives in a ring independent table d
function rt_assign_global_list_ring_indep(d::Dict{Symbol, Any}, a::Symbol, B::SList)
    @assert haskey(d, a)
    @assert isa(d[a], SList)
    b = B.list
    if b.parent.valid
        # move the name to the ring of b, which is hopefully the current ring
        b.parent === rt_basering() || rt_warn("moving a list with name " * string(a.name) * " to a ring other than the basering")
        if haskey(b.parent.vars, a)
            rt_warn("overwriting name " * string(a.name) * " when moving list to a ring")
        end
        b.parent.vars[a] = B
        delete!(d, a)
    else
        # no need to move the name
        d[a] = B
    end
end

# a = b, a lives in ring r
function rt_assign_global_list_ring_dep(r::SRing, a::Symbol, b::SList)
    @assert haskey(r.vars, a)
    @assert isa(r.vars[a], SList)
    b = B.list
    if b.parent.valid
        # no need to move the name
        r === rt_ring_of(b) || rt_warn("the list " * string(a.name) * " might now contain ring dependent data from a ring other than basering")
        r.vars[a] = B
    else
        # move the name to the current package
        p = rtGlobal.callstack[end].current_package
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a)
                rt_warn("overwriting name " * string(a.name) * " when moving list out of ring")
            end
            d[a] = B
        else
            rtGlobal.vars[p] = Dict{Symbol, Any}[a => b]
        end
        delete!(r.vars, a)
    end
end


function rt_incrementby(a::SName, b::Int)

    # local
    ok, i = rt_search_locals(a.name)
    if ok
        l = rtGlobal.local_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, rtplus(l[i].second, b)))
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                d[a.name] = rt_assign(d[a.name], rtplus(d[a.name], b))
                return
            end
        end
    end

    # global ring dependent
    d = rtGlobal.callstack[end].current_ring.vars
    if haskey(d, a.name)
        d[a.name] = rt_assign(d[a.name], rtplus(d[a.name], b))
        return
    end

    rt_error("cannot increment/decrement " * String(a.name))
end


#### assignment to nothing - used for the first set of a variable of type def
function rt_assign(a::Nothing, b)
    return rt_copy(b)
end

#### assignment to proc
function rt_assign(a::SProc, b)
    return rt_convert2proc(b)
end

#### assignment to int
function rt_assign(a::Int, b)
    return rt_convert2int(b)
end

#### assignment to bigint
function rt_assign(a::BigInt, b)
    return rt_convert2bigint(b)
end

#### assignment to string
function rt_assign(a::SString, b)
    return rt_convert2string(b)
end

#### assignment to intvec
function rt_assign(a::SIntVec, b)
    return rt_convert2intvec(b)
end

#### assignment to intmat
function rt_assign(a::_IntMat, b::_IntMat)
    return rt_copy(b)
end

function rt_assign(a::_IntMat, b::Tuple{Vararg{Any}})
    A = rt_edit(a)
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    for i in b
        A[row_idx, col_idx] = rt_convert2int(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SIntMat(A)
end

function rt_assign(a::_IntMat, b)
    rt_error("cannot assign $(rt_typestring(b)) to intmat")
end

#### assignment to bigintmat
function rt_assign(a::_BigIntMat, b::_BigIntMat)
    return rt_copy(b)
end

function rt_assign(a::_BigIntMat, b::Tuple{Vararg{Any}})
    A = rt_edit(a)
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    for i in b
        A[row_idx, col_idx] = rt_convert2bigint(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SBigIntMat(A)
end

function rt_assign(a::_BigIntMat, b)
    rt_error("cannot assign $b to bigintmat")
end

#### assignment to list
function rt_assign(a::_List, b::_List)
    return rt_copy(b)
end

function rt_assign(a::_List, b)
    return rt_convert2list(b)
end

#### assignment to poly
function rt_assign(a::SPoly, b)
    return rt_convert2poly(b)
end

#### assignment to ideal
function rt_assign(a::SIdeal, b)
    return rt_convert2ideal(b)
end



########################### newstruct installer ###############################

# newstructs are allowed to be created inside a proc, hence no choice but eval(code)
function rtnewstruct(a::SString, b::SString)
    @error_check(!haskey(rtGlobal.newstruct_casts, a.string), "redefinition of newstruct " * a.string)
    code = rt_convert_newstruct_decl(a.string, b.string)
    eval(code)
    return
end

function filter_lineno(ex::Expr)
   filter!(ex.args) do e
       isa(e, LineNumberNode) && return false
       if isa(e, Expr)
           (e::Expr).head === :line && return false
           filter_lineno(e::Expr)
       end
       return true
   end
   return ex
end

function rt_convert_newstruct_decl(newtypename::String, args::String)
    sp = split(args, ",")
    sp = [filter!(x->x != "", split(i," ")) for i in sp]
    newreftype  = Symbol(newstructrefprefix * newtypename)
    newtype     = Symbol(newstructprefix * newtypename)

    r = Expr(:block)

    # struct definition
    b = Expr(:block)
    for i in sp
        @error_check(length(i) == 2, "invalid newstruct")
        push!(b.args, Expr(:(::), Symbol(i[2]), convert_typestring_tosymbol(String(i[1]))))
    end
    push!(r.args, Expr(:struct, true, newreftype, b))

    b = Expr(:block, Expr(:(::), :data, newreftype))
    push!(r.args, Expr(:struct, false, newtype, b))

    # deepcopy
    dpcpi = Expr(:(.), :Base, QuoteNode(:deepcopy_internal))
    idict = Expr(:(::), :dict, :IdDict)
    c = Expr(:call, newreftype)
    for i in sp
        push!(c.args, Expr(:call, :deepcopy, Expr(:(.), :f, QuoteNode(Symbol(i[2])))))
    end
    push!(r.args, Expr(:function, Expr(:call, dpcpi, Expr(:(::), :f, newreftype), idict),
        Expr(:return, c)
    ))

    push!(r.args, Expr(:function, Expr(:call, dpcpi, Expr(:(::), :f, newtype), idict),
        Expr(:return,
            Expr(:call, newtype,
                Expr(:call, :deepcopy,
                    Expr(:(.), :f, QuoteNode(:data))
                )
            )
        )
    ))

    # rt_copy
    push!(r.args, Expr(:function, Expr(:call, :rt_copy, Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy, Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy_allow_tuple, Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy_allow_tuple, Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    # rt_ref
    push!(r.args, Expr(:function, Expr(:call, :rt_ref, Expr(:(::), :f, newreftype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_ref, Expr(:(::), :f, newtype)),
        Expr(:return, Expr(:(.), :f, QuoteNode(:data)))
    ))

    # rt_convert2T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), :f),
        Expr(:call, :error, "cannot convert to a " * newtypename * " from ", :f)
    ))

    # rt_cast2T
    c = Expr(:call, Symbol("rt_cast2"*newtypename))
    d = Expr(:call, newreftype)
    for i in sp
        push!(c.args, Symbol(i[2]))
        push!(d.args, Expr(:call, Symbol("rt_convert2"*i[1]), Symbol(i[2])))
    end
    push!(r.args, Expr(:function, c, Expr(:return, Expr(:call, newtype, d))))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_cast2"*newtypename), Expr(:(...), :f)),
        Expr(:call, :error, "cannot construct a " * newtypename * " from ", :f)
    ))

    push!(r.args, Expr(:call, :setindex!, Expr(:(.), :rtGlobal, QuoteNode(:newstruct_casts)),
                                          Symbol("rt_cast2"*newtypename),
                                          newtypename))

    # rt_defaultconstructor_T
    d = Expr(:call, newreftype)
    for i in sp
        push!(d.args, Expr(:call, Symbol("rt_defaultconstructor_"*i[1])))
    end
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_defaultconstructor_"*newtypename)),
        Expr(:return, Expr(:call, newtype, d))
    ))

    # rt_declare_T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_declare_"*newtypename), Expr(:(::), :a, :SName)),
        filter_lineno(quote
            n = length(rtGlobal.callstack)
            if n > 1
                rt_check_declaration_local(a.name, $(newtype))
                push!(rtGlobal.local_vars, Pair(a.name, $(Symbol("rt_defaultconstructor_"*newtypename))()))
            else
                d = rt_check_declaration_global_ring_indep(true, a.name, $(newtype))
                d[a.name] = $(Symbol("rt_defaultconstructor_"*newtypename))()
            end
        end)
    ))

    # rt_parameter_T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_parameter_"*newtypename), Expr(:(::), :a, :SName), :b),
        filter_lineno(quote
            push!(rtGlobal.local_vars, Pair(a.name, $(Symbol("rt_convert2"*newtypename))(b)))
        end)
    ))

    # rt_assign  - all errors should be handled by rt_convert2something
    push!(r.args, Expr(:function, Expr(:call, :rt_assign,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        :b),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), :b))
    ))

    # print
    b = Expr(:block, Expr(:(=), :s, ""))
    for i in 1:length(sp)
        push!(b.args, Expr(:(*=), :s, Expr(:call, :(*), Expr(:call, :(^), " ", :indent), "." * sp[i][2] * ":\n")))
        push!(b.args, Expr(:(*=), :s, Expr(:call, :rt_indenting_print, Expr(:(.), :f, QuoteNode(Symbol(sp[i][2]))), Expr(:call, :(+), :indent, 3))))
        if i < length(sp)
            push!(b.args, Expr(:(*=), :s, "\n"))
        end
    end
    push!(b.args, Expr(:return, :s))
    push!(r.args, Expr(:function, Expr(:call, :rt_indenting_print,
                                                Expr(:(::), :f, newreftype),
                                                Expr(:(::), :indent, :Int)),
        b
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_indenting_print,
                                                Expr(:(::), :f, newtype),
                                                Expr(:(::), :indent, :Int)),
        Expr(:return, Expr(:call, :rt_indenting_print, Expr(:(.), :f, QuoteNode(:data)), :indent))
    ))

    # rt_typedata
    push!(r.args, Expr(:function, Expr(:call, :rt_typedata,
                                        Expr(:(::), :f, Expr(:curly, :Union, newtype, newreftype))),
        Expr(:return, newtypename)
    ))

    push!(r.args, :nothing)
    return r
end


################ tuples ########################################################
#
# all splatting is done (hopefully!) at transpile time
#function rt_maketuple(v...)
#    g = (x isa Tuple ? x : (x,) for x in v)
#    r = tuple(Iterators.flatten(g)...)
#    return r
#end

function rt_checktuplelength(a::Tuple{Vararg{Any}}, n::Int)
    if length(a) != n
        rt_error("expected " * string(n) * " arguments in expression list; got " * string(length(a)))
    end
end

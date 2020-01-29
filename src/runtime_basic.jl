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
# special case for STuple, which iterates over its elements
Base.iterate(a::STuple) = iterate(a.list)
Base.iterate(a::STuple, state) = iterate(a.list, state)



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
# rt_maketuple(a, rt_copy_allow_tuple(f(b))..., c)

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

rt_copy(a::STuple) = error("internal error: The tuple $a leaked through. Please report this.")
rt_copy_allow_tuple(a::STuple) = a


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

# unsafe promotion

rt_promote(a::Nothing) = a

rt_promote(a::SProc) = a

rt_promote(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_promote(a::Int) = a

rt_promote(a::BigInt) = a

rt_promote(a::SString) = a

rt_promote(a::Vector{Int}) = SIntVec(a)
rt_promote(a::SIntVec) = a

rt_promote(a::Array{Int, 2}) = SIntMat(a)
rt_promote(a::SIntMat) = a

rt_promote(a::Array{BigInt, 2}) = SBigIntMat(a)
rt_promote(a::SBigIntMat) = a

rt_promote(a::SListData) = SList(a)
rt_promote(a::SList) = a

rt_promote(a::SRing) = a

rt_promote(a::SPoly) = a

rt_promote(a::SIdealData) = SIdeal(a)
rt_promote(a::SIdeal) = a



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

function object_is_ok(a::STuple)
    for i in
        if isa(i, Tuple)
            println("list contains a tuple")
            return false
        end
        if !object_is_ok(i)
            println("tuple contains a bad element")
            return false
        end
    end
    return true
end

function object_is_ok(a)
    return true
end



function rt_basering()
    return rtGlobal.callstack[end].current_ring
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
function rt_make(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return rt_ref(vars[i].second)
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        # global lists are expected to know their names after make
        v = R.vars[a.name]
        if isa(v, SList)
            v.list.back = a.name
            return v.list
        else
            return rt_ref(v)
        end
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                # global lists are expected to know their names after make
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

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        return rt_box_it_with_ring(p, R)
    end

    rt_error(String(a.name) * " is undefined")
end

# Since our local variables are going to disappear after we return, we can avoid
# the extra copy in the code sequence return rt_copy_allow_tuple(rt_ref(localvar))
function rt_make_return(a::SName)
    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return vars[i].second
        end
    end

    return rt_copy(rt_make(a)) # global variables must be copied
end

# same as make but we just return a if nothing was found
function rt_make_allow_name_ret(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return rt_ref(vars[i].second)
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        # ditto comment
        v = R.vars[a.name]
        if isa(v, SList)
            v.list.back = a.name
            return v.list
        else
            return rt_ref(v)
        end
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                # global lists are expected to know their names after make
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

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        return rt_box_it_with_ring(p, R)
    end

    return a
end



function rtdefined(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return Int(n)
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        return 1
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                return 1
            end
        end
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        rt_box_it_with_ring(p, R) # consume p  TODO clean this up
        return -1
    end

    return 0
end

function rtdefined(a::Vector{SName})
    r = map(rtdefined, a)
    return length(r) == 1 ? r[1] : STuple(r)
end

function rtdefined(a::STuple)
    n = length(a.list)
    return n == 1 ? -1 : STuple(collect(Iterators.repeated(-1, n)))
end

function rtdefined(a)
    @assert !isa(a, STuple)
    return -1
end


function rtkill(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            vars[i] = vars[end]
            pop!(vars)
            return
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        delete!(R.vars, a.name)
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                delete!(d, a.name)
                return
            end
        end
    end

    # hmm, where does this go
    if string(a.name) == "basering"
        rt_set_current_ring(rtInvalidRing)
        return
    end

    rt_error("cannot kill " * String(a.name))
    return
end

function rtkill(a::Vector{SName})
    for i in a
        rtkill(i)
    end
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
    push!(rtGlobal.callstack, rtCallStackEntry(i, i, rtGlobal.callstack[n].current_ring, package))
end

function rt_leavefunction()
    n = length(rtGlobal.callstack)
    @expensive_assert n > 1
    i = rtGlobal.callstack[n].start_all_locals - 1
    @expensive_assert length(rtGlobal.local_vars) >= i
    resize!(rtGlobal.local_vars, i)
    pop!(rtGlobal.callstack)
end

function rt_set_current_ring(a::SRing)
    # call the user an idiot if changing basering would create a name conflict
    vars_in_both = intersect(Set(keys(rtGlobal.vars[:Top])), Set(keys(a.vars)))
    if !isempty(vars_in_both)
        rt_error("new basering shadows the global variable(s) " *
                 join(map(string, collect(vars_in_both)), ", ")  *
                 " from Top; your code is probably broken")
        return
    end
    n = length(rtGlobal.callstack)
    if n > 1
        # rearrange the local variables, who cares how fast it is
        new_hidden_vars = Pair{Symbol, Any}[]
        new_current_vars = Pair{Symbol, Any}[]
        vars = rtGlobal.local_vars
        for i in rtGlobal.callstack[n].start_all_locals:length(rtGlobal.local_vars)
            hidden = false
            value = vars[i].second
            if isa(value, _List)
                @assert rt_ref(value).back === nothing
                p = rt_ref(value).parent
                if p.valid && !(p === a)
                    hidden = true
                end
            elseif isa(value, _SingularRingType)
                p = rt_ref(value).parent
                @assert p.valid
                if !(p === a)
                    hidden = true
                end
            end
            if hidden
               push!(new_hidden_vars, vars[i])
            else
               push!(new_current_vars, vars[i])
            end
        end
        local_vars_in_both = Symbol[]
        s = Set{Symbol}()
        for i in new_current_vars
            if in(i.first, s)
                push!(local_vars_in_both, i.first)
            else
                push!(s, i.first)
            end
        end
        if !isempty(local_vars_in_both)
            rt_error("new basering shadows the local variable(s) " *
                     join(map(string, local_vars_in_both), ", ")  *
                     "; your code is probably broken")
            return
        end
        # locals are good to go
        rtGlobal.callstack[n].start_current_locals =
               rtGlobal.callstack[n].start_all_locals + length(new_hidden_vars)
        resize!(rtGlobal.local_vars, rtGlobal.callstack[n].start_all_locals - 1)
        append!(rtGlobal.local_vars, new_hidden_vars)
        append!(rtGlobal.local_vars, new_current_vars)
        # also check the current package like :Top above
        pack = rtGlobal.callstack[n].current_package
        vars_in_both = intersect(Set(keys(rtGlobal.vars[pack])), Set(keys(a.vars)))
        if !isempty(vars_in_both)
            rt_error("new basering shadows the global variable(s) " *
                     join(map(string, collect(vars_in_both)), ", ")  *
                     " from " * string(pack) * "; your code is probably broken")
            return
        end
    end
    rtGlobal.callstack[n].current_ring = a
end

function rtcall(allow_name_ret::Bool, f::SProc, v...)
    return f.func(v...)
end

function rtcall(allow_name_ret::Bool, f, v...)
    @assert !isa(f, SProc)
    @assert !isa(f, SName)
    rt_error("objects of type `$(rt_typestring(f))` are not callable")
    return nothing
end

function rtcall(allow_name_ret::Bool, a::SName, v...)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return rtcall(false, vars[i].second, v...)
        end
    end

    # global ring dependent - probably map
    if haskey(rt_basering().vars, a.name)
        return rtcall(false, rt_basering().vars[a.name], v...)
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

    # newstruct constructors
    if haskey(rtGlobal.newstruct_casts, String(a.name))
        return rtGlobal.newstruct_casts[String(a.name)](v...)
    end

    # indexed variable constructor
    return rtcall(allow_name_ret, SName[a], v...)
end

function rtcall(allow_name_ret::Bool, a::Vector{SName}, v...)
    av = rt_name_cross(a, v...)
    !isempty(av) || rt_error("bad indexed variable construction")
    if allow_name_ret
        r = Any[]
        for s in av
            c = rt_make_allow_name_ret(s)
            if isa(c, SProc)    # TODO extend this to a list of "callable" types
                push!(r, rt_copy(c))
            else
                return av
            end
        end
        return length(r) == 1 ? r[1] : STuple(r)
    else
        r = Any[]
        for s in av
            c = rt_make_allow_name_ret(s)
            if isa(c, SName)
                rt_error("bad indexed variable construction")
            else
                push!(r, rt_copy(c))
            end
        end
        return length(r) == 1 ? r[1] : STuple(r)
    end
end

function rt_name_cross(a::Vector{SName}, v...)
    r = SName[]
    for b in a
        for i in v
            if isa(i, Int)
                push!(r, makeunknown(String(b.name)*"("*string(i)*")"))
            elseif isa(i, _IntVec)
                for j in rt_ref(i)
                    push!(r, makeunknown(String(b.name)*"("*string(j)*")"))
                end
            else
                rt_error("bad indexed variable construction")
            end
        end
    end
    return r
end

function rt_name_cross(a::SName, v...)
    return rt_name_cross(SName[a], v...)
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
    if R.valid
        if haskey(R.vars, a)
            rt_declare_warnerror(R.vars[a], a, typ)
        end
    else
        rt_error("cannot declare a ring-dependent type when no basering is active")
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
    return SProc(rt_empty_proc, "empty proc", :Top)
end

function rt_declare_proc(a::Vector{SName})
    for i in a
        rt_declare_proc(i)
    end
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
    return SString("")
end

function rt_declare_string(a::Vector{SName})
    for i in a
        rt_declare_string(i)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2string(b)))
end

#### intvec
function rt_defaultconstructor_intvec()
    return SIntVec(Int[0])
end

function rt_declare_intvec(a::Vector{SName})
    for i in a
        rt_declare_intvec(i)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intvec(b)))
end

#### intmat
function rt_defaultconstructor_intmat(nrows::Int = 1, ncols::Int = 1)
    return SIntMat(zeros(Int, nrows, ncols))
end

function rt_declare_intmat(a::Vector{SName}, nrows::Int = 1, ncols::Int = 1)
    for i in a
        rt_declare_intmat(i, nrows, ncols)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2intmat(b)))
end

#### bigintmat
function rt_defaultconstructor_bigintmat(nrows::Int = 1, ncols::Int = 1)
    return SBigIntMat(zeros(BigInt, nrows, ncols))
end

function rt_declare_bigintmat(a::Vector{SName}, nrows::Int = 1, ncols::Int = 1)
    for i in a
        rt_declare_bigintmat(i, nrows, ncols)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
    push!(rtGlobal.local_vars, Pair(a.name, rt_convert2bigintmat(b)))
end

#### list
function rt_defaultconstructor_list()
    return SList(SListData(Any[], rtInvalidRing, 0, nothing))
end

function rt_declare_list(a::Vector{SName})
    for i in a
        rt_declare_list(i)
    end
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
    r1 = libSingular.n_Init(0, R.ring_ptr)
    return SNumber(r1, R)
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
        d = rt_check_declaration_global_ring_dep(a.name, SNumber)
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
    return SPoly(r1, R)
end

function rt_declare_poly(a::Vector{SName})
    for i in a
        rt_declare_poly(i)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
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

function rt_new_empty_ideal()
    R = rt_basering()
    @error_check(R.valid, "cannot construct an ideal when no basering is active")
    h = libSingular.idInit(0, 1)
    return SIdeal(SIdealData(h, R))
end

function rt_declare_ideal(a::Vector{SName})
    for i in a
        rt_declare_ideal(i)
    end
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
    @expensive_assert !rt_local_identifier_exists(a.name)
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

function rt_convert2intvec(a::STuple)
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
    return rt_defaultconstructor_intvec()
end

function rt_cast2intvec(a...)
    return rt_convert2intvec(STuple([a...]))
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

function rt_convert2list(a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "polynomial encountered from a foreign ring")
    return SList(SListData(Any[a], a.parent, 1, nothing))
end

function rt_convert2list(a::STuple)
    count = 0
    for i in a.list
        count += rt_is_ring_dep(i)
    end
    return SList(SListData(a.list, count == 0 ? rtInvalidRing : rt_basering(), count, nothing))
end

function rt_convert2list(a)
    rt_error("cannot convert a $(rt_typestring(a)) to a list")
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

#### ring

function rt_convert2ring(a::SRing)
    return a
end

function rt_convert2ring(a)
    rt_error("cannot convert a $(rt_typestring(a)) to a ring")
    return rtInvalidRing
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
function rt_convert2poly_ptr(a::Union{Int, BigInt}, R::SRing)
    @error_check(R.valid, "cannot convert to a polynomial when no basering is active")
    r1 = libSingular.n_Init(a, R.ring_ptr)
    return libSingular.p_NSet(r1, R.ring_ptr)
end

function rt_convert2poly_ptr(a::SNumber, R::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == R.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    r1 = libSingular.n_Copy(a.number_ptr, a.parent.ring_ptr)
    return libSingular.p_NSet(r1, a.parent.ring_ptr)
end

function rt_convert2poly_ptr(a::SPoly, R::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == R.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    return libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
end

function rt_convert2poly_ptr(a, R::SRing)
    rt_error("cannot convert $(rt_typestring(a)) to a poly")
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
    rt_error("cannot convert $(rt_typestring(a)) to a poly")
    return rt_defaultconstructor_poly()
end


#### ideal

function rt_convert2ideal_ptr(a::Union{Int, BigInt, SNumber, SPoly}, R::SRing)
    p = rt_convert2poly_ptr(a, R)
    r = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r, p, 0) # p is consumed
    return r
end

function rt_convert2ideal_ptr(a::SIdealData, R::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == R.ring_ptr.cpp_object, "cannot convert to a ideal from a different basering")
    libSingular.id_Copy(a.ideal_ptr, a.parent.ring_ptr)
end

function rt_convert2ideal_ptr(a::SIdeal, R::SRing)
    @error_check(a.ideal.parent.ring_ptr.cpp_object == R.ring_ptr.cpp_object, "cannot convert to a ideal from a different basering")
    # we may steal a.ideal.ideal_ptr because no one else cares about it
    r = a.ideal.ideal_ptr
    a.ideal.ideal_ptr = libSingular.idInit(1, 1)
    return r
end

function rt_convert2ideal_ptr(a, R::SRing)
    rt_error("cannot convert $(rt_typestring(a)) to an ideal")
    return libSingular.idInit(1, 1)
end


function rt_convert2ideal(a::SIdealData)
    h = libSingular.id_Copy(a.ideal_ptr, a.parent.ring_ptr)
    return SIdeal(SIdealData(h, a.parent))
end

function rt_convert2ideal(a::SIdeal)
    return a
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

function rt_cast2ideal(a...)
    # answer must be wrapped in SIdeal at all times because rt_convert2ideal_ptr might throw
    r::SIdeal = rt_new_empty_ideal()
    for i in a
        libSingular.id_append(r.ideal.ideal_ptr,
                              rt_convert2ideal_ptr(i, r.ideal.parent),
                              r.ideal.parent.ring_ptr)
    end
    return r
end

function rt_convert2ideal(a)
    rt_error("cannot convert $(rt_typestring(a)) to an ideal")
    return rt_defaultconstructor_ideal()
end


############ printing #########################################################

function rt_print(a::Nothing)
    return ""
end

function rt_print(a::SName)
    return rt_print(rt_make(a))
end

function rt_print(a::SProc)
    return "package:  " * string() * "\n" *
           "procname: " * string(a.name)
end

function rt_print(a::Union{Int, BigInt})
    return string(a)
end

function rt_print(a::SString)
    return a.string
end

function rt_print(A::Union{Array{Int, 2}, Array{BigInt, 2}})
    s = ""
    nrows, ncols = size(A)
    for i in 1:nrows
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

function rt_print(a::Union{SIntMat, SBigIntMat})
    return rt_print(rt_ref(a))
end

function rt_print(a::SIntVec)
    return rt_print(a.vector)
end

function rt_print(a::Vector{Int})
    return join(map((x) -> string(x), a), ", ")
end

function rt_print(a::SList)
    return rt_print(rt_ref(a))
end

function rt_print(a::SListData)
    s = ""
    A = a.data
    first = true
    for i in 1:length(A)
        s *= (first ? "list[" : "    [") * string(i) * "]:\n"
        if A[i] isa Nothing
            continue
        end
        s *= rt_print(A[i])
        if i < length(A)
            s *= "\n"
        end
        first = false
    end
    if first
        s = "empty list"
    end
    return s
end

function rt_print(a::SRing)
    return libSingular.rPrint_helper(a.ring_ptr)
end

function rt_print(a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a number outside of basering")
    libSingular.StringSetS("")
    libSingular.n_Write(a.number_ptr, a.parent.ring_ptr)
    return libSingular.StringEndS()
end


function rt_print(a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a polynomial outside of basering")
    s = libSingular.p_String(a.poly_ptr, a.parent.ring_ptr)
    return s
end

rt_print(a::SIdeal) = rt_print(a.ideal)

function rt_print(a::SIdealData)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing an ideal outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.ideal_ptr))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.ring_ptr)
        s *= (first ? "ideal[" : "     [") * string(i) * "]: " * t * (i < n ? "\n" : "")
        first = false
    end
    if first
        s = "empty ideal"
    end
    return s
end

function rt_print(a::STuple)
    return join([rt_print(i) for i in a.list], "\n")
end

# the "print" function in Singular returns a string and does not print
function rtprint(::Nothing)
    return ""
end

function rtprint(a)
    return SString(rt_print(a))
end

# the semicolon in Singular is the method to actually print something
function rt_printout(::Nothing)
    return  # we will probably be printing nothing often - very important to not print anything in this case
end

function rt_printout(a)
    rtGlobal.last_printed = rt_copy_allow_tuple(a)
    println(rt_print(a))
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
rt_typedata(a::STuple) = String[rt_typedata(i) for i in a.list]

rt_typedata_to_singular(a::String) = SString(a)
rt_typedata_to_singular(a::Vector{String}) = STuple([SString(i) for i in a])

rt_typedata_to_string(a::String) = a
rt_typedata_to_string(a::Vector{String}) = string('(', join(a, ", "), ')')

rttypeof(a) = rt_typedata_to_singular(rt_typedata(a))

rt_typestring(a) = rt_typedata_to_string(rt_typedata(a))


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
#  a, b, c = d  | t = rt_assign_more(a, d)
#               | t = rt_assign_more(b, t)
#               | rt_assign_last(c, t)

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
        if isa(R.vars[a.name], SList)
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
                if isa(d[a.name], SList)
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
        if isa(R.vars[a.name], SList)
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
                if isa(d[a.name], SList)
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
function rt_assign_global_list_ring_dep(r::SRing, a::Symbol, B::SList)
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
    return rt_copy(b), empty_tuple
end

function rt_assign_more(a::Nothing, b::STuple)
    @error_check(!isempty(b), "too few arguments to assignment on right hand side")
    return popfirst!(b.list), b
end

function rt_assign_last(a::Nothing, b)
    @assert !isa(b, STuple)
    return rt_copy(b)
end

function rt_assign_last(a::Nothing, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return b.list[1]
end


#### assignment to proc
function rt_assign_more(a::SProc, b)
    @assert !isa(b, STuple)
    return rt_convert2proc(b), empty_tuple
end

function rt_assign_more(a::SProc, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2proc(popfirst!(b.list)), b
end

function rt_assign_last(a::SProc, b)
    @assert !isa(b, STuple)
    return rt_convert2proc(b)
end

function rt_assign_last(a::SProc, b::STuple)
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
function rt_assign_more(a::SString, b)
    @assert !isa(b, STuple)
    return rt_convert2string(b), empty_tuple
end

function rt_assign_more(a::SString, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2string(popfirst!(b.list)), b
end

function rt_assign_last(a::SString, b)
    @assert !isa(b, STuple)
    return rt_convert2string(b)
end

function rt_assign_last(a::SString, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2string(b.list[1])
end

#### assignment to intvec
function rt_assign_more(a::SIntVec, b)
    return rt_convert2intvec(b), empty_tuple
end

function rt_assign_last(a::SIntVec, b)
    return rt_convert2intvec(b)
end

#### assignment to intmat
function rt_assign_more(a::_IntMat, b::Union{_IntMat, _BigIntMat})
    return rt_convert2intmat(b), empty_tuple
end

function rt_assign_more(a::_IntMat, b)
    @assert !isa(b, STuple)
    A = rt_edit(a)
    A[1, 1] = rt_convert2int(b)
    return A, empty_tuple
end

function rt_assign_more(a::_IntMat, b::STuple)
    A = rt_edit(a)
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
    return SIntMat(A), b
end

function rt_assign_last(a::_IntMat, b::Union{_IntMat, _BigIntMat})
    return rt_convert2intmat(b)
end

function rt_assign_last(a::_IntMat, b)
    @assert !isa(b, STuple)
    A = rt_edit(a)
    A[1, 1] = rt_convert2int(b)
    return A
end

function rt_assign_last(a::_IntMat, b::STuple)
    A = rt_edit(a)
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
    return SIntMat(A)
end

#### assignment to bigintmat
function rt_assign_more(a::_BigIntMat, b::Union{_IntMat, _BigIntMat})
    return rt_convert2bigintmat(b), empty_tuple
end

function rt_assign_more(a::_BigIntMat, b)
    @assert !isa(b, STuple)
    A = rt_edit(a)
    A[1, 1] = rt_convert2bigint(b)
    return A, empty_tuple
end

function rt_assign_more(a::_BigIntMat, b::STuple)
    A = rt_edit(a)
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
    return SIntMat(A), b
end

function rt_assign_last(a::_BigIntMat, b::Union{_IntMat, _BigIntMat})
    return rt_convert2bigintmat(b)
end

function rt_assign_last(a::_BigIntMat, b)
    @assert !isa(b, STuple)
    A = rt_edit(a)
    A[1, 1] = rt_convert2bigint(b)
    return A
end

function rt_assign_last(a::_BigIntMat, b::STuple)
    A = rt_edit(a)
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
    return SIntMat(A)
end

#### assignment to list
function rt_assign_more(a::_List, b)
    return rt_convert2list(b), empty_tuple
end

function rt_assign_last(a::_List, b)
    return rt_convert2list(b)
end

#### assignment to ring
function rt_assign_more(a::SRing, b)
    @assert !isa(b, STuple)
    return rt_convert2ring(b), empty_tuple
end

function rt_assign_more(a::SRing, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2ring(popfirst!(b.list)), b
end

function rt_assign_last(a::SRing, b)
    @assert !isa(b, STuple)
    return rt_convert2ring(b)
end

function rt_assign_last(a::SRing, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2ring(b.list[1])
end

#### assignment to poly
function rt_assign_more(a::SPoly, b)
    @assert !isa(b, STuple)
    return rt_convert2poly(b), empty_tuple
end

function rt_assign_more(a::SPoly, b::STuple)
    @error_check(!isempty(b), "argument mismatch in assignment")
    return rt_convert2poly(popfirst!(b.list)), b
end

function rt_assign_last(a::SPoly, b)
    @assert !isa(b, STuple)
    return rt_convert2poly(b)
end

function rt_assign_last(a::SPoly, b::STuple)
    @error_check(length(b.list) == 1, "argument mismatch in assignment")
    return rt_convert2poly(b.list[1])
end

#### assignment to ideal
function rt_assign_more(a::SIdeal, b)
    @assert !isa(b, STuple)
    return rt_convert2ideal(b), empty_tuple
end

function rt_assign_more(a::SIdeal, b::STuple)
    r::SIdeal = rt_new_empty_ideal()
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, SNumber, SPoly, SIdeal})
        i = popfirst!(b.list)
        libSingular.id_append(r.ideal.ideal_ptr,
                              rt_convert2ideal_ptr(i, r.ideal.parent),
                              r.ideal.parent.ring_ptr)
    end
    return r, b
end

function rt_assign_last(a::SIdeal, b)
    @assert !isa(b, STuple)
    return rt_convert2ideal(b)
end

function rt_assign_last(a::SIdeal, b::STuple)
    r::SIdeal = rt_new_empty_ideal()
    while !isempty(b.list) && isa(b.list[1], Union{Int, BigInt, SNumber, SPoly, SIdeal})
        i = popfirst!(b.list)
        libSingular.id_append(r.ideal.ideal_ptr,
                              rt_convert2ideal_ptr(i, r.ideal.parent),
                              r.ideal.parent.ring_ptr)
    end
    @error_check(isempty(b.list), "argument mismatch in assignment")
    return r
end



########################### newstruct installer ###############################

# newstructs are allowed to be created inside a proc, hence no choice but eval(code)
function rtnewstruct(a::SString, b::SString)
    @error_check(!haskey(rtGlobal.newstruct_casts, a.string), "redefinition of newstruct $(a.string)")
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
        if i[1] == "qring"
            i[1] = "ring"
        end
        push!(b.args, Expr(:(::), Symbol(i[2]), convert_typestring_to_symbol(String(i[1]))))
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

    # rt_promote
    push!(r.args, Expr(:function, Expr(:call, :rt_promote, Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, :f))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_promote, Expr(:(::), :f, newtype)),
        Expr(:return, :f)
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
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_declare_"*newtypename), Expr(:(::), :a, Expr(:curly, :Vector, :SName))),
        filter_lineno(quote
            for i in a
                $(Symbol("rt_declare_"*newtypename))(i)
            end
        end)
    ))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_declare_"*newtypename), Expr(:(::), :a, :SName)),
        filter_lineno(quote
            n = length(rtGlobal.callstack)
            if n > 1
                rt_check_declaration_local(a.name, $(newtype))
                push!(rtGlobal.local_vars, Pair(a.name, $(Symbol("rt_defaultconstructor_"*newtypename))()))
            else
                d = rt_check_declaration_global_ring_indep(a.name, $(newtype))
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

    # rt_assign - all errors should be handled by rt_convert2T
    push!(r.args, Expr(:function, Expr(:call, :rt_assign_more,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        :b),
        Expr(:return, Expr(:tuple, Expr(:call, Symbol("rt_convert2"*newtypename), :b), :empty_tuple))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_more,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        Expr(:(::), :b, :STuple)),
        Expr(:return, Expr(:tuple, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:call, :popfirst!, :b)), :b))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_last,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        :b),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), :b))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_last,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        Expr(:(::), :b, :STuple)),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:ref, Expr(:(.), :b, QuoteNode(:list)), 1), :b))
    ))
    # print
    b = Expr(:block, Expr(:(=), :s, ""))
    for i in 1:length(sp)
        push!(b.args, Expr(:(*=), :s, Expr(:call, :(*), "." * sp[i][2] * ":\n")))
        push!(b.args, Expr(:(*=), :s, Expr(:call, :rt_print, Expr(:(.), :f, QuoteNode(Symbol(sp[i][2]))))))
        if i < length(sp)
            push!(b.args, Expr(:(*=), :s, "\n"))
        end
    end
    push!(b.args, Expr(:return, :s))
    push!(r.args, Expr(:function, Expr(:call, :rt_print, Expr(:(::), :f, newreftype)),
        b
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_print, Expr(:(::), :f, newtype)),
        Expr(:return, Expr(:call, :rt_print, Expr(:(.), :f, QuoteNode(:data))))
    ))

    # rt_typedata
    push!(r.args, Expr(:function, Expr(:call, :rt_typedata,
                                        Expr(:(::), :f, Expr(:curly, :Union, newtype, newreftype))),
        Expr(:return, newtypename)
    ))

    # trivial iterator
    bit = Expr(:(.), :Base, QuoteNode(:iterate))
    push!(r.args, Expr(:function, Expr(:call, bit, Expr(:(::), :a, newtype)),
        Expr(:block, Expr(:call, :iterate, :a, 0))
    ))
    push!(r.args, Expr(:function, Expr(:call, bit, Expr(:(::), :a, newtype), :state),
        Expr(:block, Expr(:if, Expr(:call, :(==), :state, 0), Expr(:tuple, :a, 1), :nothing))
    ))

    push!(r.args, :nothing)
    return r
end


################ tuples ########################################################

# all splatting is done at transpile time, we just need to put the arguments
# into an array and then wrap it in STuple
function rt_maketuple(v...)
    a = Any[v...]
    if length(a) == 1
        return a[1]
    else
        return STuple(a)
    end
end

#=
function rt_checktuplelength(a::Tuple{Vararg{Any}}, n::Int)
    if length(a) != n
        rt_error("expected " * string(n) * " arguments in expression list; got " * string(length(a)))
    end
end

function rt_check_empty_tuple(a::STuple)
    @error_check(isempty(a.list), "too many arguments to assignment on right hand side")
end

function rt_check_empty_tuple(a)
    @error_check(!isa(a, STuple) || isempty(a.list), "too many arguments to assignment on right hand side")
end
=#

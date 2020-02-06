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
Base.iterate(a::Sproc) = iterate(a, 0)
Base.iterate(a::Sproc, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sstring) = iterate(a, 0)
Base.iterate(a::Sstring, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sintvec) = iterate(a, 0)
Base.iterate(a::Sintvec, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sintmat) = iterate(a, 0)
Base.iterate(a::Sintmat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sbigintmat) = iterate(a, 0)
Base.iterate(a::Sbigintmat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Slist) = iterate(a, 0)
Base.iterate(a::Slist, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sring) = iterate(a, 0)
Base.iterate(a::Sring, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Spoly) = iterate(a, 0)
Base.iterate(a::Spoly, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sideal) = iterate(a, 0)
Base.iterate(a::Sideal, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Smatrix) = iterate(a, 0)
Base.iterate(a::Smatrix, state) = (state == 0 ? (a, 1) : nothing)
# special case for STuple, which iterates over its elements
Base.iterate(a::STuple) = iterate(a.list)
Base.iterate(a::STuple, state) = iterate(a.list, state)



########################## copying, ect. ######################################

# copiers returning tmp/own objects, usually so that we can put it in a tuple/assign it somewhere
# we have to copy stuff, and usually the stuff to copy is allowed to be a tuple
# rt_copy_tmp be called on stuff inside (), i.e. if the object (a,f(b),c)
# needs to be constructed, it might be constructed in julia as
# rt_maketuple(a, rt_copy_tmp(f(b))..., c)

# if f(b) returns a tuple t, then rt_copy_tmp(t) will simply return t
# if f(b) returns a temp intmat m, then rt_copy_tmp(m) will simply return m and the iterator is trivial
# if f(b) returns an owned intmat m, then rt_copy_tmp(m) makes a deepcopy and returns a new temp intmat, which has a trivial iterator

# second class types

object_is_tmp(a::Nothing) = true
object_is_own(a::Nothing) = true
rt_copy_tmp(a::Nothing) = a
rt_copy_own(a::Nothing) = a

object_is_tmp(a::SName) = error("internal error: The name $a leaked through. Please report this.")
object_is_own(a::SName) = error("internal error: The name $a leaked through. Please report this.")
rt_copy_tmp(a::SName) = error("internal error: The name $a leaked through. Please report this.")
rt_copy_own(a::SName) = error("internal error: The name $a leaked through. Please report this.")

object_is_tmp(a::STuple) = true
object_is_own(a::STuple) = error("internal error: The tuple $a leaked through. Please report this.")
rt_copy_tmp(a::STuple) = a
rt_copy_own(a::STuple) = error("internal error: The tuple $a leaked through. Please report this.")

# immutable types

object_is_tmp(a::Union{Sproc, Int, BigInt, Sstring, Sring, Snumber, Spoly, Svector}) = true
object_is_own(a::Union{Sproc, Int, BigInt, Sstring, Sring, Snumber, Spoly, Svector}) = true

rt_copy_tmp(a::Union{Sproc, Int, BigInt, Sstring, Sring, Snumber, Spoly, Svector}) = a
rt_copy_own(a::Union{Sproc, Int, BigInt, Sstring, Sring, Snumber, Spoly, Svector}) = a

# mutable types

object_is_tmp(a::Union{Sintvec, Sintmat, Sbigintmat, Slist, Sideal, Smatrix}) = a.tmp
object_is_own(a::Union{Sintvec, Sintmat, Sbigintmat, Slist, Sideal, Smatrix}) = !a.tmp

function rt_copy_tmp(a::Union{Sintvec, Sintmat, Sbigintmat})
    if object_is_tmp(a)
        return a
    else
        return typeof(a)(copy(a.value), true)
    end
end

function rt_copy_own(a::Union{Sintvec, Sintmat, Sbigintmat})
    if object_is_tmp(a)
        return typeof(a)(a.value, false)
    else
        return typeof(a)(copy(a.value), false)
    end
end

function rt_copy_tmp(a::Slist)
    if object_is_tmp(a)
        return a
    else
        return Slist(map(rt_copy_own, a.value), a.parent, a.ring_dep_count, nothing, true)
    end
end

function rt_copy_own(a::Slist)
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return Slist(map(rt_copy_own, a.value), a.parent, a.ring_dep_count, nothing, false)
    end
end

function rt_copy_tmp(a::Sideal)
    if object_is_tmp(a)
        return a
    else
        return Sideal(libSingular.id_Copy(a.value, a.parent.value), a.parent, true)
    end
end

function rt_copy_own(a::Sideal)
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return Sideal(libSingular.id_Copy(a.value, a.parent.value), a.parent, false)
    end
end

function rt_copy_tmp(a::Smatrix)
    if object_is_tmp(a)
        return a
    else
        return Smatrix(libSingular.mp_Copy(a.value, a.parent.value), a.parent, true)
    end
end

function rt_copy_own(a::Smatrix)
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return Smatrix(libSingular.mp_Copy(a.value, a.parent.value), a.parent, false)
    end
end


# unsafe promotion to tmp object

rt_promote(a::Nothing) = a

rt_promote(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_promote(a::Sproc) = a

rt_promote(a::Int) = a

rt_promote(a::BigInt) = a

rt_promote(a::Sstring) = a

function rt_promote(a::Union{Sintvec, Sintmat, Sbigintmat})
    return typeof(a)(a.value, true)
end

rt_promote(a::Sring) = a

rt_promote(a::Snumber) = a

rt_promote(a::Spoly) = a

rt_promote(a::Svector) = a

function rt_promote(a::Union{Slist, Sideal, Smatrix})
    a.tmp = true
    return a
end


# rt_ringof has to be used for .r_... members of newstruct, which are read-only
function rt_ringof(a)
    if isa(a, Slist)
        @error_check(a.parent.valid, "sorry, this list does not have a basering")
        return a.parent
    elseif isa(a, SingularRingType)
        return a.parent
    else
        rt_error("type `$(rt_typestring(a))` does not have a basering")
        return rtInvalidRing
    end
end


function rt_is_ring_dep(a)
    if isa(a, Slist)
        return a.parent.valid
    else
        return isa(a, SingularRingType)
    end
end


function object_is_ok(a::Slist)
    count = 0
    for i in a.value
        count += rt_is_ring_dep(i)
        if isa(i, SName)
            println("list contains a name")
            return false
        end
        if isa(i, STuple)
            println("list contains a tuple")
            return false
        end
        if !object_is_own(i)
            println("list contains a non-owned object")
            return false
        end
        if !object_is_ok(i)
            println("list contains a bad element")
            return false
        end
    end
    if !isempty(a.value) && isa(a.value[end], Nothing)
        println("list has a nothing on the end")
        return false
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

function object_is_ok(a::STuple)
    for i in
        if isa(i, SName)
            println("list contains a name")
            return false
        end
        if isa(i, Tuple)
            println("tuple contains a tuple")
            return false
        end
        if !object_is_tmp(i)
            println("tuple contains a non-temporary object")
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

function rt_box_it_with_ring(n::libSingular.number, r::Sring)
    return Snumber(n, r)
end

function rt_box_it_with_ring(p::libSingular.poly, r::Sring)
    return Spoly(p, r)
end


# make takes a name and looks it up according to singular's resolution rules
# this function is named make in the c singular interpreter code
function rt_make(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        @expensive_assert object_is_own(vars[i].second)
        if vars[i].first == a.name
            return vars[i].second
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        # global lists are expected to know their names after make
        v = R.vars[a.name]
        @expensive_assert object_is_own(v)
        if isa(v, Slist)
            v.back = a.name
        end
        return v
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                # global lists are expected to know their names after make
                v = d[a.name]
                @expensive_assert object_is_own(v)
                if isa(v, Slist)
                    v.back = a.name
                end
                return v
            end
        end
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.value)
    if ok
        return rt_box_it_with_ring(p, R)
    end

    rt_error(String(a.name) * " is undefined")
end

# Since our local variables are going to disappear after we return, we can avoid
# the extra copy in the code sequence return rt_copy_tmp(localvar)
function rt_make_return(a::SName)
    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        if vars[i].first == a.name
            return rt_promote(vars[i].second)
        end
    end

    return rt_copy_tmp(rt_make(a)) # global variables must be copied
end

# same as make but we just return a if nothing was found
function rt_make_allow_name_ret(a::SName)

    n = length(rtGlobal.callstack)

    # local
    vars = rtGlobal.local_vars
    for i in rtGlobal.callstack[n].start_current_locals:length(rtGlobal.local_vars)
        @expensive_assert object_is_own(vars[i].second)
        if vars[i].first == a.name
            return vars[i].second
        end
    end

    R = rtGlobal.callstack[n].current_ring

    # global ring dependent
    if haskey(R.vars, a.name)
        # global lists are expected to know their names after make
        v = R.vars[a.name]
        @expensive_assert object_is_own(v)
        if isa(v, Slist)
            v.back = a.name
        end
        return v
    end

    # global ring independent
    for p in (rtGlobal.callstack[n].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                # global lists are expected to know their names after make
                v = d[a.name]
                @expensive_assert object_is_own(v)
                if isa(v, Slist)
                    v.back = a.name
                end
                return v
            end
        end
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.value)
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
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.value)
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


function rt_backtick(a::Sstring)
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

function rt_set_current_ring(a::Sring)
    # call the user an idiot if changing basering would create a name conflict
    vars_in_both = intersect(Set(keys(rtGlobal.vars[:Top])), Set(keys(a.vars)))
    if !isempty(vars_in_both)
        rt_error("new basering shadows the global variable(s) " *
                 join(map(string, collect(vars_in_both)), ", ")  *
                 " from Top")
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
            if isa(value, Slist)
                @assert value.back === nothing
                p = value.parent
                if p.valid && !(p === a)
                    hidden = true
                end
            elseif isa(value, SingularRingType)
                p = value.parent
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
                     join(map(string, local_vars_in_both), ", "))
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
                     " from " * string(pack))
            return
        end
    end
    rtGlobal.callstack[n].current_ring = a
end

function rtcall(allow_name_ret::Bool, f::Sproc, v...)
    return f.func(v...)
end

function rtcall(allow_name_ret::Bool, f, v...)
    @assert !isa(f, Sproc)
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
    @error_check(!isempty(av), "bad indexed variable construction")
    if allow_name_ret
        r = Any[]
        for s in av
            c = rt_make_allow_name_ret(s)
            if isa(c, Sproc)    # TODO extend this to a list of "callable" types
                push!(r, rt_copy_tmp(c))
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
                push!(r, rt_copy_tmp(c))
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
            elseif isa(i, Sintvec)
                for j in i.value
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
    return SVector(r1, R)
end

# special constructor via [poly...]
function rt_bracket_constructor(v...)
    R = rt_basering()
    r = Svector(libSingular.p_null_helper(), R)
    for i in 1:length(v)
        p = rt_convert2poly_ptr(v[i], R)
        libSingular.p_SetCompP(p, i, R.value)                            # mutate p inplace
        r.vector_ptr = libSingular.p_Add_q(r.vector_ptr, p, R.value)     # consume both summands
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
    data::Vector{Any} = map(rt_copy_own, a.list)
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
    data::Vector{Any} = [rt_copy_own(j) for j in a]
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
    r1 = libSingular.n_Init(a, R.value)
    return Snumber(r1, R)
end

function rt_convert2number(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `number`")
    return rt_defaultconstructor_number()
end

#### poly

# return a new libSingular.poly not owned by any instance of a SingularType
function rt_convert2poly_ptr(a::Union{Int, BigInt}, R::Sring)
    @error_check(R.valid, "cannot convert to a polynomial when no basering is active")
    r1 = libSingular.n_Init(a, R.value)
    return libSingular.p_NSet(r1, R.value)
end

function rt_convert2poly_ptr(a::Snumber, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a polynomial from a different basering")
    r1 = libSingular.n_Copy(a.value, a.parent.value)
    return libSingular.p_NSet(r1, a.parent.value)
end

function rt_convert2poly_ptr(a::Spoly, R::Sring)
    @error_check_rings(a.parent, R, "cannot convert to a polynomial from a different basering")
    return libSingular.p_Copy(a.value, a.parent.value)
end

function rt_convert2poly_ptr(a, R::Sring)
    rt_error("cannot convert `$(rt_typestring(a))` to `poly`")
    return libSingular.p_null_helper()
end

function rt_convert2poly(a::Spoly)
    return a
end

function rt_convert2poly(a::Union{Int, BigInt})
    R = rt_basering()
    r1 = rt_convert2poly_ptr(a, R)
    return Spoly(r1, R)
end

function rt_convert2poly(a::Snumber)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    return Spoly(r1, a.parent)
end

function rt_convert2poly(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `poly`")
    return rt_defaultconstructor_poly()
end

#### vector

function rt_convert2vector(a::Union{Int, BigInt})
    R = rt_basering()
    r1 = rt_convert2poly_ptr(a, R.parent)
    libSingular.p_SetCompP(r1, 1, R.parent.value)       # mutate r1 in place
    return SVector(r1, R)
end

function rt_convert2vector(a::Union{Snumber, Spoly})
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "converting to a vector outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    libSingular.p_SetCompP(r1, 1, a.parent.value)       # mutate r1 in place
    return SVector(r1, a.parent)
end

function rt_convert2vector(a::Svector)
    return a
end

function rt_convert2vector(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `vector`")
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
    @error_check(a.parent.value.cpp_object == R.value.cpp_object, "cannot convert to a ideal from a different basering")
    if object_is_tmp(a)
        # we may steal a.value
        r = a.value
        a.value = libSingular.idInit(0, 1)
    else
        r = libSingular.id_Copy(a.value, a.parent.value)
    end
    return r
end

function rt_convert2ideal_ptr(a, R::Sring)
    rt_error("cannot convert `$(rt_typestring(a))` to `ideal`")
    return libSingular.idInit(1, 1)
end


function rt_convert2ideal(a::Sideal)
    return rt_copy_own(a)
end

function rt_convert2ideal(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to an ideal when no basering is active")
    r1 = rt_convert2poly_ptr(a, R)
    r2 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return Sideal(r2, R, false)
end

function rt_convert2ideal(a::Union{Snumber, Spoly})
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    r2 = libSingular.idInit(1, 1)
    libSingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return Sideal(r2, a.parent, false)
end

function rt_cast2ideal(a...)
    # answer must be wrapped in Sideal at all times because rt_convert2ideal_ptr might throw
    r::Sideal = rt_new_empty_ideal()
    for i in a
        libSingular.id_append(r.value, rt_convert2ideal_ptr(i, r.parent), r.parent.value)
    end
    return r
end

function rt_convert2ideal(a)
    rt_error("cannot convert `$(rt_typestring(a))` to `ideal`")
    return rt_defaultconstructor_ideal()
end


#### matrix

function rt_convert2matrix(a...)
    rt_error("matrix conversion not implemented")
    return rt_defaultconstructor_matrix()
end

function rt_cast2matrix(a...)
    rt_error("matrix cast not implemented")
    return rt_defaultconstructor_matrix()
end


############ printing #########################################################
# Printing seems to be a mess in singular. For now we just have rt_printout,
# rt_print, and rt_cast2string all produce nice 2-dimensional output

function rt_indent_string(s::String, indent::Int)
    join(split(s, r"\n|\r|\0"), "\n" * " "^indent)
end

function rt_format_matrix(a::Array{String, 2})
    nrows, ncols = size(a)
    b = map(s->split(s, r"\n|\r|\0"), a) # matrix of arrays of substrings
    col_widths = [(j < ncols ? 1 : 0) + maximum([maximum(map(length, b[i,j])) for i in 1:nrows]) for j in 1:ncols]
    row_heights = [maximum(map(length, b[i,1:end])) for i in 1:nrows]
    r = String[]
    for i in 1:nrows
        for k in 1:row_heights[i]
            for j in 1:ncols
                push!(r, rpad(k <= length(b[i,j]) ? b[i,j][k] : "", col_widths[j]))
            end
            if i < nrows || k < row_heights[i]
                push!(r, "\n")
            end
        end
    end
    return join(r)
end

function rt_print(a::Nothing)
    return ""
end

function rt_print(a::SName)
    return rt_print(rt_make(a))
end

function rt_print(a::Sproc)
    return "package:  " * string(a.package) * "\n" *
           "procname: " * a.name
end

function rt_print(a::Union{Int, BigInt})
    return string(a)
end

function rt_print(a::Sstring)
    return a.value
end

function rt_print(a::Union{Sintmat, Sbigintmat})
    return rt_format_matrix(map(string, a.value))
end

function rt_print(a::Sintvec)
    return join(map(string, a.value), ", ")
end

function rt_print(a::Slist)
    s = ""
    A = a.value
    first = true
    for i in 1:length(A)
        h = (first ? "list[" : "    [") * string(i) * "]: "
        s *= h
        s *= rt_indent_string(rt_print(A[i]), length(h)) * (i < length(A) ? "\n" : "")
        first = false
    end
    if first
        s = "empty list"
    end
    return s
end

function rt_print(a::Sring)
    return libSingular.rPrint_helper(a.value)
end

function rt_print(a::Snumber)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "printing a number outside of basering")
    libSingular.StringSetS("")
    libSingular.n_Write(a.value, a.parent.value)
    return libSingular.StringEndS()
end

function rt_print(a::Spoly)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "printing a polynomial outside of basering")
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Svector)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "printing a vector outside of basering")
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Sideal)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "printing an ideal outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = (first ? "ideal[" : "     [") * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
    end
    if first
        s = "empty ideal"
    end
    return s
end

function rt_print(a::Smatrix)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "printing an ideal outside of basering")
    s = ""
    nrows = libSingular.nrows(a.value)
    ncols = libSingular.ncols(a.value)
    first = true
    for i in 1:nrows
        for j in 1:ncols
            p = libSingular.mp_getindex(a.value, i, j)
            t = libSingular.p_String(p, a.parent.value)
            h = (first ? "matrix[" : "      [") * string(i) *", " * string(j) * "]: "
            s *= h * t * ((i < nrows || j < ncols) ? "\n" : "")
            first = false
        end
    end
    if first
        s = "empty matrix"
    end
    return s
end

# just for fun - rtprint and rt_printout have special cases for tuples
function rt_print(a::STuple)
    return join([rt_print(i) for i in a.list], "\n")
end

# the "print" function in Singular returns a string and does not print
function rtprint(::Nothing)
    return ""
end

function rtprint(a)
    @assert !isa(a, STuple)
    return Sstring(rt_print(a))
end

function rtprint(a::STuple)
    return STuple([Sstring(rt_print(i)) for i in a.list])
end

# the semicolon in Singular is the method to actually print something
function rt_printout(::Nothing)
    return  # we will probably be printing nothing often - very important to not print anything in this case
end

function rt_printout(a)
    @assert !isa(a, STuple)
    @assert !isa(a, Nothing)
    rtGlobal.last_printed = rt_copy_own(a)
    println(rt_print(a))
end

function rt_printout(a::STuple)
    n = length(a.list)
    for i in 1:n
        if i == n
            rtGlobal.last_printed = rt_copy_own(a.list[i])
        end
        println(rt_print(a.list[i]))
    end
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
rt_typedata(::Sproc)       = "proc"
rt_typedata(::Int)         = "int"
rt_typedata(::BigInt)      = "bigint"
rt_typedata(::Sstring)     = "string"
rt_typedata(::Sintvec)     = "intvec"
rt_typedata(::Sintmat)     = "intmat"
rt_typedata(::Sbigintmat)  = "bigintmat"
rt_typedata(::Slist)       = "list"
rt_typedata(::Sring)       = "ring"
rt_typedata(::Snumber)     = "number"
rt_typedata(::Spoly)       = "poly"
rt_typedata(::Svector)     = "vector"
rt_typedata(::Sideal)      = "ideal"
rt_typedata(::Smatrix)     = "matrix"
rt_typedata(a::STuple) = String[rt_typedata(i) for i in a.list]

rt_typedata_to_singular(a::String) = Sstring(a)
rt_typedata_to_singular(a::Vector{String}) = STuple([Sstring(i) for i in a])

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


########################### newstruct installer ###############################

# newstructs are allowed to be created inside a proc, hence no choice but eval(code)
function rtnewstruct(a::Sstring, b::Sstring)
    @error_check(!haskey(rtGlobal.newstruct_casts, a.value), "redefinition of newstruct $(a.value)")
    code = rt_convert_newstruct_decl(a.value, b.value)
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
    newtype = Symbol(newstructprefix * newtypename)

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
    push!(b.args, Expr(:(::), :tmp, :Bool))
    push!(r.args, Expr(:struct, true, newtype, b))

    # object_is_tmp
    push!(r.args, Expr(:function, Expr(:call, :object_is_tmp, Expr(:(::), :a, newtype)),
        Expr(:return, Expr(:(.), :a, QuoteNode(:tmp)))
    ))

    # object_is_own
    push!(r.args, Expr(:function, Expr(:call, :object_is_own, Expr(:(::), :a, newtype)),
        Expr(:return, Expr(:call, :(!), Expr(:(.), :a, QuoteNode(:tmp))))
    ))

    #object_is_ok
    # TODO

    # rt_copy_tmp
    c = Expr(:call, newtype)
    for i in sp
        push!(c.args, Expr(:call, :rt_copy_own, Expr(:(.), :a, QuoteNode(Symbol(i[2])))))
    end
    push!(c.args, true)
    push!(r.args, Expr(:function, Expr(:call, :rt_copy_tmp, Expr(:(::), :a, newtype)),
        Expr(:if,
            Expr(:call, :object_is_tmp, :a),
            Expr(:return, :a),
            Expr(:return, c)
        )
    ))

    # rt_copy_own
    c = Expr(:call, newtype)
    for i in sp
        push!(c.args, Expr(:call, :rt_copy_own, Expr(:(.), :a, QuoteNode(Symbol(i[2])))))
    end
    push!(c.args, false)
    push!(r.args, Expr(:function, Expr(:call, :rt_copy_own, Expr(:(::), :a, newtype)),
        Expr(:if,
            Expr(:call, :object_is_tmp, :a),
            Expr(:block,
                Expr(:(=), Expr(:(.), :a, QuoteNode(:tmp)), false),
                Expr(:return, :a)
            ),
            Expr(:return, c)
        )
    ))

    # rt_promote
    push!(r.args, Expr(:function, Expr(:call, :rt_promote, Expr(:(::), :a, newtype)),
        Expr(:block,
            Expr(:(=), Expr(:(.), :a, QuoteNode(:tmp)), true),
            Expr(:return, :a)
        )
    ))

    # rt_convert2T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:(::), :a, newtype)),
        Expr(:return, Expr(:call, :rt_copy_own, :a))
    ))

    # rt_cast2T
    c = Expr(:call, Symbol("rt_cast2"*newtypename))
    d = Expr(:call, newtype)
    for i in sp
        push!(c.args, Symbol(i[2]))
        push!(d.args, Expr(:call, Symbol("rt_convert2"*i[1]), Symbol(i[2])))
    end
    push!(d.args, true)
    push!(r.args, Expr(:function, c, Expr(:return, d)))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_cast2"*newtypename), Expr(:(...), :a)),
        Expr(:call, :error, "cannot construct a " * newtypename * " from ", :a)
    ))

    push!(r.args, Expr(:call, :setindex!, Expr(:(.), :rtGlobal, QuoteNode(:newstruct_casts)),
                                          Symbol("rt_cast2"*newtypename),
                                          newtypename))

    # rt_defaultconstructor_T
    d = Expr(:call, newtype)
    for i in sp
        push!(d.args, Expr(:call, Symbol("rt_defaultconstructor_"*i[1])))
    end
    push!(d.args, false)
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_defaultconstructor_"*newtypename)),
        Expr(:return, d)
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
                                        Expr(:(::), :a, newtype),
                                        :b),
        Expr(:return, Expr(:tuple, Expr(:call, Symbol("rt_convert2"*newtypename), :b), :empty_tuple))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_more,
                                        Expr(:(::), :a, newtype),
                                        Expr(:(::), :b, :STuple)),
        Expr(:return, Expr(:tuple, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:call, :popfirst!, :b)), :b))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_last,
                                        Expr(:(::), :a, newtype),
                                        :b),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), :b))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_assign_last,
                                        Expr(:(::), :a, newtype),
                                        Expr(:(::), :b, :STuple)),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:ref, Expr(:(.), :b, QuoteNode(:list)), 1), :b))
    ))
    # print
    b = Expr(:block, Expr(:(=), :s, ""))
    for i in 1:length(sp)
        if i == 1
            push!(b.args, Expr(:(*=), :s, newtypename * "." * sp[i][2] * ": "))
        else
            push!(b.args, Expr(:(*=), :s, " "^length(newtypename) * "." * sp[i][2] * ": "))
        end
        push!(b.args, Expr(:(*=), :s,
                            Expr(:call, :rt_indent_string,
                                    Expr(:call, :rt_print, Expr(:(.), :f, QuoteNode(Symbol(sp[i][2])))),
                                    length(newtypename) + 1 + length(sp[i][2]) + 2
                                )
                          ))
        if i < length(sp)
            push!(b.args, Expr(:(*=), :s, "\n"))
        end
    end
    push!(b.args, Expr(:return, :s))
    push!(r.args, Expr(:function, Expr(:call, :rt_print, Expr(:(::), :f, newtype)),
        b
    ))

    # rt_typedata
    push!(r.args, Expr(:function, Expr(:call, :rt_typedata,
                                        Expr(:(::), :f, newtype)),
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


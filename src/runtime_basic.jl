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
Base.iterate(a::Svector) = iterate(a, 0)
Base.iterate(a::Svector, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Sideal) = iterate(a, 0)
Base.iterate(a::Sideal, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Smodule) = iterate(a, 0)
Base.iterate(a::Smodule, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Smatrix) = iterate(a, 0)
Base.iterate(a::Smatrix, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::Smap) = iterate(a, 0)
Base.iterate(a::Smap, state) = (state == 0 ? (a, 1) : nothing)
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

object_is_tmp(a::Union{Sintvec, Sintmat, Sbigintmat, Slist, Sideal, Smodule, Smatrix, Smap}) = a.tmp
object_is_own(a::Union{Sintvec, Sintmat, Sbigintmat, Slist, Sideal, Smodule, Smatrix, Smap}) = !a.tmp

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
        return Slist(Any[rt_copy_own(x) for x in a.value],
                     a.parent, a.ring_dep_count, nothing, true)
    end
end

function rt_copy_own(a::Slist)
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return Slist(Any[rt_copy_own(x) for x in a.value],
                     a.parent, a.ring_dep_count, nothing, false)
    end
end

function rt_copy_tmp(a::Union{Sideal, Smodule})
    if object_is_tmp(a)
        return a
    else
        return typeof(a)(libSingular.id_Copy(a.value, a.parent.value), a.parent, true)
    end
end

function rt_copy_own(a::Union{Sideal, Smodule})
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return typeof(a)(libSingular.id_Copy(a.value, a.parent.value), a.parent, false)
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

function rt_copy_tmp(a::Smap)
    if object_is_tmp(a)
        return a
    else
        return Smap(libSingular.maCopy(a.value, a.parent.value), a.source, a.parent, true)
    end
end

function rt_copy_own(a::Smap)
    if object_is_tmp(a)
        a.tmp = false
        return a
    else
        return Smap(libSingular.maCopy(a.value, a.parent.value), a.source, a.parent, false)
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

function rt_promote(a::Union{Slist, Sideal, Smodule, Smatrix, Smap})
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

function rtcall(allow_name_ret::Bool, f::Sproc, a::SName)
    return f.func(rt_make(a.name))
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
rt_typedata(::Smodule)     = "module"
rt_typedata(::Smatrix)     = "matrix"
rt_typedata(::Smap)        = "map"
rt_typedata(a::STuple) = String[rt_typedata(i) for i in a.list]

rt_typedata_to_singular(a::String) = Sstring(a)
rt_typedata_to_singular(a::Vector{String}) = STuple([Sstring(i) for i in a])

rt_typedata_to_string(a::String) = a
rt_typedata_to_string(a::Vector{String}) = string('(', join(a, ", "), ')')

rttypeof(a) = rt_typedata_to_singular(rt_typedata(a))

rt_typestring(a) = rt_typedata_to_string(rt_typedata(a))


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

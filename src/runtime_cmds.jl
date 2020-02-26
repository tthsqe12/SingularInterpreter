#### attrib/killattrib ####

function rtattrib(a)
    first = true
    if isa(a, SingularAttributeType)
        for i in a.attributes
            println("attr:" * i.first * ", type " * rt_typestring(i.second))
            first = false
        end
    end
    if first
        println("no attributes")
    end
    return rtnothing
end

function rtattrib(a, b::Sstring)
    if isa(a, SingularAttributeType)
        return a.attributes[b.value]
    else
        return Sstring("")
    end
end

function rtattrib(a, b::Sstring, c)
    if isa(a, SingularAttributeType)
        a.attributes[b.value] = c
    else
        rt_error("Sorry, type `$(rt_typestring(a))` does not attributes implemented.")
    end
    return rtnothing
end

function rtkillattrib(a)
    if isa(a, SingularAttributeType)
        empty!(a.attributes)
    end
    return rtnothing
end

function rtkillattrib(a, b::Sstring)
    if isa(a, SingularAttributeType)
        delete!(a.attributes, b.value)
    end
    return rtnothing
end


#### insert ####

# insert(a, b, i) is supposed to return a tmp list with b inserted at position i+1
function rtinsert(a::Slist, b, i::Int)
    @assert !isa(b, STuple)
    @assert !isa(b, Snone)
    B = rt_copy_own(b)
    A = rt_copy_tmp(a)
    @expensive_assert object_is_ok(A)
    if i >= length(A.value)
        append!(A.value, collect(Iterators.repeated(rtnothing, i - length(A.value))))
        push!(A.value, B)
    else
        insert!(A.value, i + 1, B)
    end
    if rt_is_ring_dep(B)
        A.ring_dep_count += 1
        if !A.parent.valid
            A.parent = rt_basering()  # try to get a valid ring from somewhere
            @warn_check(A.parent.valid, "list has ring dependent elements but no basering")
        end
    end
    @expensive_assert object_is_ok(A)
    return A
end

function rtinsert(a::Slist, b::Snone, i::Int)
    A = rt_copy_tmp(a)
    @expensive_assert object_is_ok(A)
    if i >= length(A.value)
        return A
    else
        insert!(A.value, i + 1, rtnothing)
    end
    @expensive_assert object_is_ok(A)
    return A
end

function rtinsert(a::Slist, b::STuple, i::Int)
    @error_check(length(b.list == 1), "cannot insert a tuple into a list")
    return rtinsert(a, b.list[1], i)
end


#### delete ####

function rtdelete(a::Slist, i::Int)
    A = rt_copy_tmp(a)
    change = Int(rt_is_ring_dep(A.value[i]))
    deleteat!(A.value, i)
    # remove nothings on the end
    while !isempty(A.value) && isa(A.value[end], Snone)
        pop!(A.value)
    end
    A.ring_dep_count -= change
    if A.ring_dep_count <= 0
        A.parent = rtInvalidRing
    end
    @expensive_assert object_is_ok(A)
    return A
end


#### deg ####

function rtdeg(a::STuple)
    return STuple(Any[rtdeg(i) for i in a.list])
end

function rtdeg(a::STuple, b)
    @assert !isa(b, STuple)
    return rtdeg(a.list[1], b)
end

function rtdeg(a, b::STuple)
    @assert !isa(a, STuple)
    return rtdeg(a.list[1], b)
end

function rtdeg(a::STuple, b::STuple)
    return rtdeg(a.list[1], b.list[1])
end

function rtdeg(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "deg(`$(rt_typestring(a))`) failed without a basering")
    a1 = libSingular.n_Init(a, R.value)
    a2 = libSingular.p_NSet(a1, R.value)
    d = Int(libSingular.pLDeg(a2, R.value))
    libSingular.p_Delete(a2, R.value)
    return d
end

function rtdeg(a::Snumber)
    a1 = libSingular.n_Copy(a.value, a.parent.value)
    a2 = libSingular.p_NSet(a1, a.parent.value)
    d = Int(libSingular.pLDeg(a2, a.value))
    libSingular.p_Delete(a2, a.value)
    return d
end

function rtdeg(a::Spoly)
    return Int(libSingular.pLDeg(a.value, a.parent.value))
end

function rtdeg(a::Union{Int, BigInt}, b::Sintvec)
    R = rt_basering()
    @error_check(R.valid, "deg(`$(rt_typestring(a))`) failed without a basering")
    a1 = libSingular.n_Init(a, R.value)
    a2 = libSingular.p_NSet(a1, R.value)
    d = Int(libSingular.p_DegW(a2, b.value, R.value))
    libSingular.p_Delete(a2, R.value)
    return d
end

function rtdeg(a::Snumber, b::Sintvec)
    a1 = libSingular.n_Copy(a.value, a.parent.value)
    a2 = libSingular.p_NSet(a1, a.parent.value)
    d = Int(libSingular.p_DegW(a2, b.value, a.value))
    libSingular.p_Delete(a2, a.parent.value)
    return d
end

function rtdeg(a::Spoly, b::Sintvec)
    return Int(libSingular.p_DegW(a.value, b.value, a.parent.value))
end

### var ###

rtvar(a::STuple) = STuple(Any[rtvar(i) for i in a.list])

function rtvar(i::Int)
    R = rt_basering()
    @error_check(R.valid, "var(`int`) failed without a basering")
    n::Int = libSingular.rVar(R.value)
    @error_check(1 <= i <= n, "var number $i out of range 1..$n")
    p = libSingular.p_One(R.value)
    libSingular.p_SetExp(p, i, 1, R.value)
    libSingular.p_Setm(p, R.value)
    return Spoly(p, R)
end

### variables ###

function rtvariables(a::STuple)
    return STuple(Any[rtvariables(i) for i in a.list])
end

function rtvariables(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "variables(`$(rt_typestring(a))`) failed without a basering")
    return Sideal(libSingular.idInit(1,1), R, true)
end

function rtvariables(a::Snumber)
    return Sideal(libSingular.idInit(1,1), a.parent, true)
end

function rtvariables(a::Spoly)
    r = libSingular.p_Variables(a.value, a.parent.value)
    return Sideal(r, a.parent, true)
end

function rtvariables(a::Sideal)
    r = libSingular.id_Variables(a.value, a.parent.value)
    return Sideal(r, a.parent, true)
end


#### maxideal

function rtmaxideal(a::STuple)
    return STuple(Any[rtmaxideal(i) for i in a.list])
end

function rtmaxideal(a::Int)
    R = rt_basering()
    @error_check(R.valid, "maxideal(`int`) failed without a basering")
    return Sideal(libSingular.id_MaxIdeal(Cint(a), R.value), R, true)
end


#### std ####

function rtstd(a::Sideal)
    r = libSingular.id_Std(a.value, a.parent.value, false)
    at = SAttributes()
    if (rtGlobal.si_opt_1 & OPT_DEGBOUND_MASK) == 0
        at["isSB"] = Int(1)
    end
    return Sideal(r, a.parent, true, at)
end


#### size ####

function rtsize(a::Int)
    return Int(a != 0)
end

function rtsize(a::BigInt)
    return Int(a.size)
end

function rtsize(a::Union{Sintvec, Sintmat, Sbigintmat, Slist})
    return Int(length(a.value))
end

function rtsize(a::Spoly)
    return Int(libSingular.pLength(a.value))
end

function rtsize(a::Sideal)
    return Int(libSingular.idElem(a.value))
end


#### nrows ####

function rtnrows(a::Sintvec)
    return Int(length(a.value))
end

function rtnrows(a::Union{Sintmat, Sbigintmat})
    return size(a.value)[1]
end

function rtnrows(a::Smatrix)
    return Int(libSingular.nrows(a.value))
end


#### ncols ####

function rtncols(a::STuple)
    return STuple(Any[rtncols(i) for i in a.list])
end

function rtncols(a::Union{Sintmat, Sbigintmat})
    return size(a.value)[2]
end

function rtncols(a::Union{Sideal, Smodule})
    return Int(libSingular.id_ncols(a.value))
end

function rtncols(a::Smatrix)
    return Int(libSingular.ncols(a.value))
end

#### nvars ####

function rtnvars(a::STuple)
    return STuple(Any[rtnvars(i) for i in a.list])
end

function rtnvars(a::Sring)
    return Int(libSingular.rVar(a.value))
end

#### leadexp ####

function rtleadexp(a::STuple)
    return STuple(Any[rtleadexp(i) for i in a.list])
end

function rtleadexp(a::Spoly)
    return Sintvec(libSingular.p_leadexp(a.value, a.parent.value), true)
end


#### kbase ####

function rtkbase(a::Sideal)
    return Sideal(libSingular.id_kbase(a.value, -1, a.parent.value), a.parent, true)
end

function rtkbase(a::Sideal, b::Int)
    return Sideal(libSingular.id_kbase(a.value, Cint(b), a.parent.value), a.parent, true)
end

### lead ###

rtlead(a::STuple) = STuple(Any[rtlead(i) for i in a.list])

### rvar ###

rtrvar(a::STuple) = STuple(Any[rtrvar(i) for i in a.list])

# defined on ANY_TYPE
rtrvar_auto(a) = 0

##################### system stuff ########################

#### voice
function rt_get_voice()
    return length(rtGlobal.callstack)
end

rt_set_voice_more(a) = rt_set_voice_last(a)

function rt_set_voice_last(a)
    rt_error("cannot assign to system variable `voice`")
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
    b = rt_convert2int(a)
    rtGlobal.rtimer_base = time_ns() - b*rtGlobal.rtimer_scale
end

function rt_set_rtimer_more(a)
    @assert !isa(a, STuple)
    rt__set_rtimer(a)
    return empty_tuple
end

function rt_set_rtimer_more(a::STuple)
    @error_check(!isempty(a), "argument mismatch in assignment")
    rt__set_rtimer(popfirst!(a.list))
    return a
end

function rt_set_rtimer_last(a)
    @assert !isa(a, STuple)
    rt__set_rtimer(a)
    return
end

function rt_set_rtimer_last(a::STuple)
    @error_check(length(a.list) == 1, "argument mismatch in assignment")
    rt__set_rtimer(a.list[1])
    return
end

#### degBound
function rt_get_degBound()
    @error_check(rt_basering().valid, "no ring active")
    return rtGlobal.Kstd1_deg
end

function rt__set_degBound(a)
    @error_check(rt_basering().valid, "no ring active")
    b = rt_convert2int(a)
    rtGlobal.Kstd1_deg = b
    if b != 0
        rtGlobal.si_opt_1 |= OPT_DEGBOUND_MASK
    else
        rtGlobal.si_opt_1 &= ~OPT_DEGBOUND_MASK
    end
end

function rt_set_degBound_more(a)
    @assert !isa(a, STuple)
    rt__set_degBound(a)
    return empty_tuple
end

function rt_set_degBound_more(a::STuple)
    @error_check(!isempty(a), "argument mismatch in assignment")
    rt__set_degBound(popfirst!(a.list))
    return a
end

function rt_set_degBound_last(a)
    @assert !isa(a, STuple)
    rt__set_degBound(a)
    return
end

function rt_set_degBound_last(a::STuple)
    @error_check(length(a.list) == 1, "argument mismatch in assignment")
    rt__set_degBound(a.list[1])
    return
end

#### multBound
function rt_get_multBound()
    @error_check(rt_basering().valid, "no ring active")
    return rtGlobal.Kstd1_mu
end

function rt__set_multBound(a)
    @error_check(rt_basering().valid, "no ring active")
    b = rt_convert2int(a)
    rtGlobal.Kstd1_mu = b
    if b != 0
        rtGlobal.si_opt_1 |= OPT_MULTBOUND_MASK
    else
        rtGlobal.si_opt_1 &= ~OPT_MULTBOUND_MASK
    end
end

function rt_set_multBound_more(a)
    @assert !isa(a, STuple)
    rt__set_multBound(a)
    return empty_tuple
end

function rt_set_multBound_more(a::STuple)
    @error_check(!isempty(a), "argument mismatch in assignment")
    rt__set_multBound(popfirst!(a.list))
    return a
end

function rt_set_multBound_last(a)
    @assert !isa(a, STuple)
    rt__set_multBound(a)
    return
end

function rt_set_multBound_last(a::STuple)
    @error_check(length(a.list) == 1, "argument mismatch in assignment")
    rt__set_multBound(a.list[1])
    return
end



function rtsystem(a::Sstring, b...)
    if a.value == "--ticks-per-sec"
        return rtsystem_ticks_per_sec(b...)
    elseif a.value == "install"
        return rtsystem_install(b...)
    else
        rt_error("system($(a.name), ...) not implemented")
    end
    return rtnothing
end

function rtsystem_ticks_per_sec(b...)
    if isempty(b)
        return Int(div(UInt64(10)^9, rtGlobal.rtimer_scale))
    else
        # TODO adjust rtimer_base as well
        b1 = rt_convert2int(b[1])
        @error_check(b1 > 0, "--ticks-per-sec must be larger than 0")
        rtGlobal.rtimer_scale = max(1, div(UInt64(10)^9, UInt64(b1)))
        return rtnothing
    end
end

function rtsystem_install(typ_::Sstring, cmd_::Sstring, proc::Sproc, nargs::Int)
    typ = typ_.value
    cmd = cmd_.value
    if cmd == "print" && nargs == 1
        newtype  = Symbol(newstructprefix * typ)
        eval(Expr(:function, Expr(:call, :rt_print, Expr(:(::), :f, newtype)),
                    Expr(:return,
                        Expr(:(.),
                            Expr(:call,
                                :rt_convert2string,
                                Expr(:call, proc.func, :f)
                                ),
                            QuoteNode(:value)
                            )
                        )
                 ))
    else
        rt_error("system install failed")
    end
    return rtnothing
end

function rtbasering()
    R = rt_basering()
    if R.valid
        return R
    else
        return rt_lookup(SName(:basering))
    end
end

function rtread(a::Sstring)
    # this function is a can of worms
    path = a.value
    @error_check(!isempty(path), "cannot read empty path")
    if path[1] != '.' || path[1] != '/' || !isfile(path)
        for s in rtGlobal.SearchPath
            if isfile(joinpath(s, path))
                path = joinpath(s, path)
                break
            end
        end
    end
    @error_check(isfile(path), "cannot find path $path")
    return Sstring(read(path, String))
end


################## assertions/errors/messages #################################

function rt_warn(s::String)
    @warn s
end

function rt_error(s::String)
    @error s
    error("runtime error")
end


function rtERROR(s::Sstring, leaving::String)
    @error s.string * "\nleaving " * leaving
    error("runtime error")
    return rtnothing
end

function rtERROR(v...)
    rt_error("ERROR should be called with a string")
    return rtnothing
end

function rt_assume(a::Int, message::String)
    if a == 0
        rt_error(message)
    end
    return rtnothing
end

function rt_assume(a, message::String)
    rt_error("expected int for boolean expression in ASSUME")
    return rtnothing
end

################### call back to the transpiler ###############################

function rtload(a::Sstring)
    rt_load(false, a.string)
    return rtnothing
end

function rt_load(export_names::Bool, path::String)
    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))

    @error_check(!isempty(path), "cannot load empty path")
    if path[1] != '.' || path[1] != '/' || !isfile(path)
        for s in rtGlobal.SearchPath
            if isfile(joinpath(s, path))
                path = joinpath(s, path)
                break
            end
        end
    end
    @error_check(isfile(path), "cannot find path $path")

    libname = basename(path)
    libname = splitext(libname)[1]
    libname = uppercase(libname[1])*lowercase(libname[2:end])

    package = Symbol(libname)

    # return if the library is already loaded, TODO more robust "already loaded" check
    if haskey(rtGlobal.vars, package) && !isempty(rtGlobal.vars[package])
        return
    end
    # if not, add package
    rtGlobal.vars[package] = Dict{Symbol, Any}()

    s = read(path, String)

    ast::AstNode = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $s)

    if ast.rule == @RULE_SYNTAX_ERROR
        rt_error("syntax error around line "*string(ast.child[1]::Int)*" of "*Base.Filesystem.basename(path))
    else
#        println("library ast:")
#        astprint(ast.child[1], 0)
#        t0 = time()
        loadenv = AstLoadEnv(export_names, package)
        loadconvert_toplines(ast, loadenv)
#        t1 = time()
#        println()
#        println("------- library loaded in ", trunc(1000*(t1 - t0)), " ms -------")
#        println()
    end
    return rtnothing
end


# singular's execute does not act like a function and only returns nothing.
# what happens to return inside of execute? current c singular has error,
# but we allow it in julia to be a real return from the enclosing function
# TODO: does rtexecute work well recursively?
# SINGULAR      JULIA
# execute(s)    a, b = execute(s); if b; return a; end;
function rtexecute(s::Sstring)
    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))
    # the trailing semicolon may be omitted in exectue
    ast::AstNode = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $(s.value*";"))
    if ast.rule == @RULE_SYNTAX_ERROR
        rt_error("syntax error around line "*string(ast.child[1]::Int)*" of execute")
    else
        # if callstack management changes, this will need significant changes
        n = length(rtGlobal.callstack)
        env = AstEnv(rtGlobal.callstack[n].current_package, "execute",
                     false, # branchTo is not allowed
                     false, # have not seen branchTo yet
                     n > 1, # return is allowed <=> we inside a proc
                     true,  # at top
                     true, true,    # everything is screwed (and it should also have been screwed in the calling env)
                     Set{String}(),
                     Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast, env)
        r = eval(expr)
        return r, n > length(rtGlobal.callstack)
    end
    return nothing, false
end

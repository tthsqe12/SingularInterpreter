#### insert ####

rtinsert(a::_List, b, i::Int) = rtinsert(rt_ref(a), b, i)

function rtinsert(a::SListData, b, i::Int)
    @assert !isa(b, STuple)
    bcopy = rt_copy(b)
    r = rt_edit(a)
    if i > length(r.data)
        resize!(r.data, i + 1)
        r.data[i + 1] = bcopy
    else
        insert!(r.data, i + 1, bcopy)
    end
    # remove nothings on the end
    while !isempty(r.data) && r.data[end] == nothing
        pop!(r.data)
    end
    if rt_is_ring_dep(bcopy)
        r.ring_dep_count += 1
        if !r.parent.valid
            r.parent = rt_basering()  # try to get a valid ring from somewhere
            @warn_check(r.parent.valid, "list has ring dependent elements but no basering")
        end
    end
    @assert object_is_ok(r)
    return SList(r)
end

function rtinsert(a::_List, b::STuple, i::Int)
    if length(b.list == 1)
        return rtinsert(a, b.list[1], i)
    else
        rt_error("cannot insert a tuple into a list")
        return rt_defaultconstructor_list()
    end
end


#### delete ####

rtdelete(a::_List, b, i::Int) = rtinsert(rt_ref(a), b, i)

function rtdelete(a::SListData, i::Int)
    r = rt_edit(a)
    change = Int(rt_is_ring_dep(r.data[i]))
    deleteat!(r.data, i)
    # remove nothings on the end
    while !isempty(r.data) && r.data[end] == nothing
        pop!(r.data)
    end
    r.ring_dep_count -= change
    if r.ring_dep_count <= 0
        r.parent = rtInvalidRing
    end
    @assert object_is_ok(r)
    return SList(r)
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
    r = rt_basering()
    r.valid || rt_error("deg(`$(rt_typestring(a))`) failed without a basering")
    a1 = libSingular.n_Init(a, r.ring_ptr)
    a2 = libSingular.p_NSet(a1, r.ring_ptr)
    d = Int(libSingular.pLDeg(a2, r.ring_ptr))
    libSingular.p_Delete(a2, r.ring_ptr)
    return d
end

function rtdeg(a::SNumber)
    a1 = libSingular.n_Copy(a.number_ptr, a.parent.ring_ptr)
    a2 = libSingular.p_NSet(a1, a.parent.ring_ptr)
    d = Int(libSingular.pLDeg(a2, a.ring_ptr))
    libSingular.p_Delete(a2, a.ring_ptr)
    return d
end

function rtdeg(a::SPoly)
    return Int(libSingular.pLDeg(a.poly_ptr, a.parent.ring_ptr))
end

function rtdeg(a::Union{Int, BigInt}, b::_IntVec)
    r = rt_basering()
    r.valid || rt_error("deg(`$(rt_typestring(a))`) failed without a basering")
    a1 = libSingular.n_Init(a, r.ring_ptr)
    a2 = libSingular.p_NSet(a1, r.ring_ptr)
    d = Int(libSingular.p_DegW(a2, rt_ref(b), r.ring_ptr))
    libSingular.p_Delete(a2, r.ring_ptr)
    return d
end

function rtdeg(a::SNumber, b::_IntVec)
    a1 = libSingular.n_Copy(a.number_ptr, a.parent.ring_ptr)
    a2 = libSingular.p_NSet(a1, a.parent.ring_ptr)
    d = Int(libSingular.p_DegW(a2, rt_ref(b), a.ring_ptr))
    libSingular.p_Delete(a2, a.parent.ring_ptr)
    return d
end

function rtdeg(a::SPoly, b::_IntVec)
    return Int(libSingular.p_DegW(a.poly_ptr, rt_ref(b), a.parent.ring_ptr))
end


### variables ###

function rtvariables(a::STuple)
    return STuple(Any[rtvariables(i) for i in a.list])
end

function rtvariables(a::Union{Int, BigInt})
    R = rt_basering()
    R.valid || rt_error("variables(`$(rt_typestring(a))`) failed without a basering")
    return SIdeal(SIdealData(libSingular.idInit(1,1), R))
end

function rtvariables(a::SNumber)
    return SIdeal(SIdealData(libSingular.idInit(1,1), a.parent))
end

function rtvariables(a::SPoly)
    r = libSingular.p_Variables(a.poly_ptr, a.parent.ring_ptr)
    return SIdeal(SIdealData(r, a.parent))
end

rtvariables(a::SIdeal) = rtvariables(rt_ref(a))

function rtvariables(a::SIdealData)
    r = libSingular.id_Variables(a.ideal_ptr, a.parent.ring_ptr)
    return SIdeal(SIdealData(r, a.parent))
end


#### std ####

rtstd(a::SIdeal) = rtstd(rt_ref(a))

function rtstd(a::SIdealData)
    r = libSingular.id_Std(a.ideal_ptr, a.parent.ring_ptr, false)
    return SIdeal(SIdealData(r, a.parent))
end


#### size ####

function rtsize(a::Int)
    return Int(a != 0)
end

function rtsize(a::BigInt)
    return Int(a.size)
end

function rtsize(a::_IntVec)
    return Int(length(rt_ref(a)))
end

function rtsize(a::Union{_IntMat, _BigIntMat})
    nrows, ncols = size(rt_ref(a))
    return Int(nrows * ncols)
end

function rtsize(a::_List)
    return Int(length(rt_ref(a).data))
end

function rtsize(a::SPoly)
    return Int(libSingular.pLength(a.poly_ptr))
end

function rtsize(a::_Ideal)
    return Int(libSingular.idElem(rt_ref(a).ideal_ptr))
end


#### ncols ####

function rtncols(a::STuple)
    return STuple(Any[rtncols(i) for i in a.list])
end

function rtncols(a::Union{_IntMat, _BigIntMat})
    nrows, ncols = size(rt_ref(a))
    return ncols
end

function rtncols(a::_Ideal)
    return Int(libSingular.id_ncols(rt_ref(a).ideal_ptr))
end

function rtncols(a)
    rt_error("ncols(`$(rt_typestring(a))`) failed")
    return 0
end


#### nvars ####

function rtnvars(a::STuple)
    return STuple(Any[rtnvars(i) for i in a.list])
end

function rtnvars(a::SRing)
    return Int(libSingular.rVar(a.ring_ptr))
end

function rtnvars(a)
    rt_error("nvars(`$(rt_typestring(a))`) failed, expected nvars(`ring`)")
    return 0
end


#### leadexp ####

function rtleadexp(a::STuple)
    return STuple(Any[rtleadexp(i) for i in a.list])
end

function rtleadexp(a::SPoly)
    return SIntVec(libSingular.p_leadexp(a.poly_ptr, a.parent.ring_ptr))
end

function rtleadexp(a)
    rt_error("leadexp(`$(rt_typestring(a))`) failed, expected leadexp(`poly`)")
    return 0
end


#### kbase ####

rtkbase(a::SIdeal) = rtkbase(rt_ref(a))

function rtkbase(a::SIdealData)
    return SIdeal(SIdealData(libSingular.id_kbase(a.ideal_ptr, -1, a.parent.ring_ptr), a.parent))
end

rtkbase(a::SIdeal, b::Int) = rtkbase(rt_ref(a), b)

function rtkbase(a::SIdealData, b::Int)
    return SIdeal(SIdealData(libSingular.id_kbase(a.ideal_ptr, Cint(b), a.parent.ring_ptr), a.parent))
end


##################### system stuff ########################

function rt_get_rtimer()
    t = time_ns()
    if t >= rtGlobal.rtimer_base
        return Int(div(t - rtGlobal.rtimer_base, rtGlobal.rtimer_scale))
    else
        return -Int(div(rtGlobal.rtimer_base - t, rtGlobal.rtimer_scale))
    end
end


function rtsystem(a::SString, b)
    if a.string == "--ticks-per-sec"
        # TODO adjust rtimer_base as well
        rtGlobal.rtimer_scale = div(UInt64(1000000000), UInt64(abs(rt_convert2int(b))))
    else
        rt_error("system($(a.name), ...) not implemented")
    end
    return nothing
end

function rt_get_voice()
    return length(rtGlobal.callstack)
end

function rtbasering()
    R = rt_basering()
    if R.valid
        return R
    else
        return rt_make(SName(:basering))
    end
end


################## assertions/errors/messages #################################

function rt_warn(s::String)
    @warn s
end

function rt_error(s::String)
    @error s
    error("runtime error")
end


function rtERROR(s::SString, leaving::String)
    @error s.string * "\nleaving " * leaving
    error("runtime error")
end

function rtERROR(v...)
    rt_error("ERROR should be called with a string")
end

function rt_assume(a::Int, message::String)
    if a == 0
        rt_error(message)
    end
end

function rt_assume(a, message::String)
    rt_error("expected int for boolean expression in ASSUME")
end

################### call back to the transpiler ###############################

function rtload(a::SString)
    rt_load(false, a.string)
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
end


# singular's execute does not act like a function and only returns nothing.
# what happens to return inside of execute? current c singular has error,
# but we allow it in julia to be a real return from the enclosing function
# TODO: does rtexecute work well recursively?
# SINGULAR      JULIA
# execute(s)    a, b = execute(s); if b; return a; end;
function rtexecute(s::SString)
    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))
    # the trailing semicolon may be omitted in exectue
    ast::AstNode = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $(s.string*";"))
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
                     Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast, env)
        r = eval(expr)
        return r, n > length(rtGlobal.callstack)
    end
    return nothing, false
end

rtintert(a::SName, b::SName) = rtsystem(rt_make(a), rt_make(b))
rtinsert(a::SName, b) = rtsystem(rt_make(a), b)
rtinsert(a, b::SName) = rtsystem(a, rt_make(b))

function rtinsert(a::_List, b, i::Int)
    bcopy = rt_copy(b)
    r = rt_edit(a);
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
    return SList(r)
end



rtdelete(a::SName, b::SName) = rtdelete(rt_make(a), rt_make(b))
rtdelete(a::SName, b) = rtdelete(rt_make(a), b)
rtdelete(a, b::SName) = rtdelete(a, rt_make(b))


function rtdelete(a::_List, i::Int)
    r = rt_edit(a)
    deleteat!(r.data, i)
    # remove nothings on the end
    while !isempty(r.data) && r.data[end] == nothing
        pop!(r.data)
    end
    return SList(r)
end


function rt_get_rtimer()
    t = time_ns()
    if t >= rtGlobal.rtimer_base
        return Int(div(t - rtGlobal.rtimer_base, rtGlobal.rtimer_scale))
    else
        return -Int(div(rtGlobal.rtimer_base - t, rtGlobal.rtimer_scale))
    end
end


rtsystem(a::SName, b::SName) = rtsystem(rt_make(a), rt_make(b))
rtsystem(a::SName, b) = rtsystem(rt_make(a), b)
rtsystem(a, b::SName) = rtsystem(a, rt_make(b))


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


rtsize(a::SName) = rtsize(rt_make(a))

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

################## assertions/errors/messages #################################


function rt_warn(s::String)
    @warn s
end

function rt_error(s::String)
    @error s
    error("runtime error")
end


rtERROR(s::SName, leaving::String) = rtERROR(rt_make(s), leaving)

function rtERROR(s::SString, leaving::String)
    @error s.string * "\nleaving " * leaving
    error("runtime error")
end

function rtERROR(v...)
    rt_error("ERROR should be called with a string")
end


function rt_assume_level_ok(a::Int)
    # TODO
    return true
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

rtload(a::SName) = rtload(rt_make(a))
function rtload(a::SString)
    rt_load(false, a.string)
end

function rt_load(export_names::Bool, path::String)
    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))

    libname = Base.Filesystem.basename(path)
    libname = Base.Filesystem.splitext(libname)[1]
    libname = uppercase(libname[1])*lowercase(libname[2:end])

    package = Symbol(libname)

    # return if the library is already loaded, TODO more robust "already loaded" check
    if haskey(rtGlobal.vars, package) && !isempty(rtGlobal.vars[package])
        return
    end
    # if not, add package
    rtGlobal.vars[package] = Dict{Symbol, Any}()

    s = read(path, String)

    ast = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $s)

    if isa(ast, String)
        rt_error("syntax error in load")
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

rtexecute(a::SName) = rtexecute(rt_make(a))


# singular's execute does not act like a function and only returns nothing.
# what happens to return inside of execute? current c singular has error,
# but we allow it in julia to be a real return from the enclosing function
# SINGULAR      JULIA
# execute(s)    a, b = execute(s); if b; return a; end;
function rtexecute(s::SString)
    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))
    # the trailing semicolon may be omitted in exectue
    ast = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $(s.string*";"))
    if isa(ast, String)
        rt_error("syntax error in execute")
    else
        # if callstack management changes, this will need significant changes
        n = length(rtGlobal.callstack)
        env = AstEnv(n > 1, rtGlobal.callstack[n].current_package, "execute",
                     true, true, true, Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast, env)
        r = eval(expr)
        return r, n > length(rtGlobal.callstack)
    end
    return nothing, false
end

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

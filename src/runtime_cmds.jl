#### insert ####

# insert(a, b, i) is supposed to return a tmp list with b inserted at position i+1
function rtinsert(a::Slist, b, i::Int)
    @assert !isa(b, STuple)
    @assert !isa(b, Nothing)
    B = rt_copy_own(b)
    A = rt_copy_tmp(a)
    @expensive_assert object_is_ok(A)
    if i >= length(A.value)
        append!(A.value, collect(Iterators.repeated(nothing, i - length(A.value))))
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

function rtinsert(a::Slist, b::Nothing, i::Int)
    A = rt_copy_tmp(a)
    @expensive_assert object_is_ok(A)
    if i >= length(A.value)
        return A
    else
        insert!(A.value, i + 1, nothing)
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
    while !isempty(A.value) && isa(A.value[end], Nothing)
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
    return Sideal(r, a.parent, true)
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


#### ncols ####

function rtncols(a::STuple)
    return STuple(Any[rtncols(i) for i in a.list])
end

function rtncols(a::Union{Sintmat, Sbigintmat})
    nrows, ncols = size(a.value)
    return ncols
end

function rtncols(a::Sideal)
    return Int(libSingular.id_ncols(a.value))
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


##################### the lazy way: use sleftv's ##########

set_arg(x::Int, i; kw...) = libSingular.set_leftv_arg_i(x, i)

function set_arg(x::Union{Spoly,Svector,Sideal,Snumber}, i; withcopy, withname=false)
    libSingular.rChangeCurrRing(sing_ring(x).value)
    libSingular.set_leftv_arg_i(x.value, Int(type_id(x)), i, withcopy)
end

function set_arg(x::Sring, i; withcopy=false, withname=false)
    libSingular.set_leftv_arg_i(x.value, i, withcopy)
end

function set_arg(x::Sstring, i; withcopy=false, withname=false)
    # TODO: handle gracefully when basering is not valid
    # (not that Singular would handle that gracefully...)
    libSingular.rChangeCurrRing(rt_basering().value)
    libSingular.set_leftv_arg_i(x.value, i, withname)
end

function set_arg(x::Union{Sintvec, Sintmat}, i; withcopy=false, withname=false)
    x = x.value
    libSingular.set_leftv_arg_i(vec(x), x isa Matrix, size(x, 1), size(x, 2), i)
end

set_arg1(x; withcopy=false, withname=false) = set_arg(x, 1; withcopy=withcopy, withname=withname)
set_arg2(x; withcopy=false, withname=false) = set_arg(x, 2; withcopy=withcopy, withname=withname)

get_res() = libSingular.get_leftv_res()

get_res(::Type{Int}, ring=nothing) = Int(get_res())

get_res(T::Type{<:Union{Spoly,Svector}}, r::Sring) =
    T(libSingular.internal_void_to_poly_helper(get_res()), r)

get_res(::Type{Snumber}, r::Sring) =
    Snumber(libSingular.internal_void_to_number_helper(get_res()), r)

get_res(::Type{Sideal}, r::Sring) =
    Sideal(libSingular.internal_void_to_ideal_helper(get_res()), r, true)

function get_res(::Type{Sintvec}, ring=nothing)
    d = libSingular.lvres_array_get_dim(1)
    iv = Vector{Int}(undef, d)
    libSingular.lvres_to_jlarray(iv)
    Sintvec(iv, true)
end

function get_res(::Type{Sintmat}, ring=nothing)
    d = libSingular.lvres_array_get_dim.((1, 2))
    im = Matrix{Int}(undef, d)
    libSingular.lvres_to_jlarray(vec(im))
    Sintmat(im, true)
end

function get_res(::Type{STuple}, ring=nothing)
    a = Any[]
    while true
        t, p = libSingular.get_leftv_res_next()
        p == C_NULL && return STuple(a)
        if t == Int(STRING_CMD)
            push!(a, Sstring(unsafe_string(Ptr{Cchar}(p))))
        else
            rt_error("unknown type in the result of last command")
        end
    end
end

get_res(::Type{Sstring}, ring=nothing) = Sstring(unsafe_string(Ptr{Cchar}(get_res())))

function maybe_get_res(err, T)
    if err == 0
        get_res(T...)
    else
        rt_error("failed operation")
    end
end

# return true when no-error
cmd1(cmd::Union{Int,CMDS,Char}, T...) = maybe_get_res(libSingular.iiExprArith1(Int(cmd)), T)
cmd2(cmd::Union{Int,CMDS,Char}, T...) = maybe_get_res(libSingular.iiExprArith2(Int(cmd)), T)

result_type(::Sintvec, ::Sintvec) = Sintvec
result_type(::Sintvec, ::Int) = Sintvec
result_type(::Int, ::Sintvec) = Sintvec

result_type(::Sintmat, ::Sintmat) = Sintmat
result_type(::Sintmat, ::Int) = Sintmat
result_type(::Int, ::Sintmat) = Sintmat

### lead ###

rtlead(a::STuple) = STuple(Any[rtlead(i) for i in a.list])

### rvar ###

rtrvar(a::STuple) = STuple(Any[rtrvar(i) for i in a.list])

# defined on ANY_TYPE
rtrvar_auto(a) = 0

function rtminus(x, y)
        set_arg1(x, withcopy=!(x isa Sring))
        set_arg2(y, withcopy=!(y isa Sring))
        cmd2('-', result_type(x, y))
end

### comparisons ###

for (op, code) in (:rtless => '<',
                   :rtgreater => '>',
                   :rtlessequal => LE,
                   :rtgreaterequal => GE,
                   :rtequalequal => EQUAL_EQUAL)
    @eval function $op(x, y)
        set_arg1(x, withcopy=!(x isa Sring))
        set_arg2(y, withcopy=!(y isa Sring))
        cmd2($code, Int)
    end
end

function rtgetindex(x::Sstring, y)
    set_arg1(x, withname=(y isa Sintvec))
    set_arg2(y, withcopy=!(y isa Sring))
    cmd2('[', y isa Sintvec ? STuple : Sstring)
end

# types which can currently be sent/fetched as sleftv to/from Singular
const convertible_types = Dict{CMDS, Type}(
    INT_CMD    => Int,
    BIGINT_CMD => BigInt,
    STRING_CMD => Sstring,
    INTVEC_CMD => Sintvec,
    INTMAT_CMD => Sintmat,
    RING_CMD   => Sring,
    NUMBER_CMD => Snumber,
    POLY_CMD   => Spoly,
    IDEAL_CMD  => Sideal,
    VECTOR_CMD => Svector,
)
# NOTE: ANY_TYPE is used only for result types automatically (this has to be done
# on a case by case basis for input, as in most cases the name of the variable is
# needed)
push!(convertible_types, ANY_TYPE => Union{values(convertible_types)...})

const _types_to_id = Dict(t => id for (id, t) in convertible_types)

function type_id(x)
    xt = get(_types_to_id, typeof(x), nothing)
    if xt === nothing
        for (t, id) in _types_to_id
            id == ANY_TYPE && continue
            if x isa t
                _types_to_id[typeof(x)] = id
                xt = id
                break
            end
        end
    end
    @assert xt !== nothing
    xt
end

const error_expected_types = Dict(
    "nvars" => "ring",
    "leadexp" => "poly",
)

let seen = Set{Int}()
    i = 0
    valid_types = Int.(keys(convertible_types))
    while true
        (cmd, res, arg) = libSingular.dArith1(i)
        cmd == 0 && break # end of dArith1
        i += 1

        res in valid_types && arg in valid_types || continue

        res = CMDS(res)
        arg = CMDS(arg)

        arg == ANY_TYPE && continue # handled differently

        name = something(get(cmd_to_string, cmd, nothing),
                         get(op_to_string, cmd, nothing),
                         "")
        name == "" && continue

        Sres = convertible_types[res]
        Sarg = convertible_types[arg]

        rtname = Symbol(:rt, name)
        rtauto = Symbol(:rt, name, :_auto)
        expected = get(error_expected_types, name, "")
        if expected != ""
            expected = ", expected $name(`$expected`)"
        end

        if !(cmd in seen)
            # fall-back to rtauto so that definitions here don't overwrite
            # these which are manually implemented
            @eval begin
                $rtname(x) = $rtauto(x)

                if !($name in ("rvar",)) # TODO: fix this ugly hack (`rtrvar_auto` already implemented manually)
                    $rtauto(x) = rt_error(string($name, "(`$(rt_typestring(x))`) failed", $expected))
                end
            end
            push!(seen, cmd)
        end

        @eval function $rtauto(x::$Sarg)
            set_arg1(x, withcopy=(x isa Union{Spoly,Sideal,Svector,Sring}))
            cmd1($cmd, $Sres, sing_ring(x))
        end
    end
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


function rtsystem(a::Sstring, b...)
    if a.value == "--ticks-per-sec"
        return rtsystem_ticks_per_sec(b...)
    elseif a.value == "install"
        return rtsystem_install(b...)
    else
        rt_error("system($(a.name), ...) not implemented")
    end
    return nothing
end

function rtsystem_ticks_per_sec(b...)
    if isempty(b)
        return Int(div(UInt64(10)^9, rtGlobal.rtimer_scale))
    else
        # TODO adjust rtimer_base as well
        b1 = rt_convert2int(b[1])
        @error_check(b1 > 0, "--ticks-per-sec must be larger than 0")
        rtGlobal.rtimer_scale = max(1, div(UInt64(10)^9, UInt64(b1)))
        return nothing
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

function rtload(a::Sstring)
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
                     Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast, env)
        r = eval(expr)
        return r, n > length(rtGlobal.callstack)
    end
    return nothing, false
end

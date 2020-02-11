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

function get_res(expectedtype::CMDS; clear_curr_ring=true)
    t, d = libSingular.get_leftv_res(clear_curr_ring)
    @assert t == Int(expectedtype)
    d
end

get_res(::Type{Int}, ring=nothing, data=get_res(INT_CMD)) = Int(data)

get_res(T::Type{<:Union{Spoly,Svector}}, r::Sring) =
    T(libSingular.internal_void_to_poly_helper(get_res(_types_to_id[T])), r)

get_res(::Type{Snumber}, r::Sring) =
    Snumber(libSingular.internal_void_to_number_helper(get_res(NUMBER_CMD)), r)

get_res(::Type{Sideal}, r::Sring, data=get_res(IDEAL_CMD)) =
    Sideal(libSingular.internal_void_to_ideal_helper(data), r, true)

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

function get_res(::Type{Slist}, ring=nothing, data=nothing)
    data = something(data, get_res(LIST_CMD, clear_curr_ring=false)) # TODO: clear_curr_ring later when possible
    n = libSingular.list_length(data)
    a = Vector{Any}(undef, n)
    cnt = 0
    for i = 1:n
        (t, d) = libSingular.list_elt_i(data, i)
        @assert d != C_NULL
        T = convertible_types[CMDS(t)]
        a[i] = get_res(T, ring, d)
        cnt += rt_is_ring_dep(a[i])
    end

    Slist(a, cnt == 0 ? rtInvalidRing : something(ring), cnt, nothing, true)
end

function get_res(::Type{STuple}, ring=nothing)
    a = Any[]
    next = C_NULL
    while true
        t, p, next = libSingular.get_leftv_res_next(next)
        @assert p != C_NULL
        if t == Int(STRING_CMD)
            push!(a, Sstring(unsafe_string(Ptr{Cchar}(p))))
        else
            rt_error("unknown type in the result of last command")
        end
        next == C_NULL && return STuple(a)
    end
end

get_res(::Type{Sstring}, ring=nothing) = Sstring(unsafe_string(Ptr{Cchar}(get_res(STRING_CMD))))

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
    LIST_CMD   => Slist,
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

let seen = Set{Int}([Int(PRINT_CMD)])
    # seen initially contain commands which alreay implement a catch-all method (e.g. `rtprint(::Any)`)
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

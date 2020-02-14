##################### the lazy way: use sleftv's ##########

const _sleftvs = Ptr{Cvoid}[]

function sleftv(i::Int)
    if isempty(_sleftvs)
        libSingular.allocate_sleftv_array(resize!(_sleftvs, 2))
    end
    _sleftvs[i]
end


set_arg(lv, x::Int; kw...) = libSingular.set_sleftv(lv, x)

function set_arg(lv, x::BigInt; withcopy=false, withname=false)
    GC.@preserve x libSingular.set_sleftv_bigint(lv, pointer_from_objref(x))
end

function set_arg(lv, x::Union{Spoly,Svector,Sideal,Smatrix,Snumber}; withcopy=true, withname=false)
    libSingular.rChangeCurrRing(sing_ring(x).value)
    libSingular.set_sleftv(lv, x.value, Int(type_id(typeof(x))), withcopy)
end

function set_arg(lv, x::Sring; withcopy=true, withname=false)
    libSingular.set_sleftv(lv, x.value, withcopy)
end

function set_arg(lv, x::Sstring; withcopy=false, withname=false)
    # TODO: handle gracefully when basering is not valid
    # (not that Singular would handle that gracefully...)
    libSingular.rChangeCurrRing(rt_basering().value)
    libSingular.set_sleftv(lv, x.value, withname)
end

function set_arg(lv, x::Union{Sintvec, Sintmat}; withcopy=false, withname=false)
    x = x.value
    libSingular.set_sleftv(lv, vec(x), x isa Matrix, size(x, 1), size(x, 2))
end

function set_arg(lv, x::Sbigintmat; withcopy=false, withname=false)
    a = Array{Any}(x.value) # TODO: optimize this method to avoid copying
    GC.@preserve a libSingular.set_sleftv_bigintmat(lv, vec(a), size(a, 1), size(a, 2))
end

function set_arg(lv, x::Slist; kwargs...)
    m::Ptr{Cvoid}, sz::Int = libSingular.set_sleftv_list(lv, length(x.value))
    for (i, elt) in enumerate(x.value)
        set_arg(m+(i-1)*sz, elt, withcopy=true)
    end
end

set_arg1(x; withcopy=false, withname=false) = set_arg(sleftv(1), x; withcopy=withcopy, withname=withname)
set_arg2(x; withcopy=false, withname=false) = set_arg(sleftv(2), x; withcopy=withcopy, withname=withname)

function get_res(expectedtype::CMDS; clear_curr_ring=true)
    t, d = libSingular.get_leftv_res(clear_curr_ring)
    @assert t == Int(expectedtype)
    d
end

function get_res(::Type{Any}, ring=nothing; clear_curr_ring=true)
    t, d = libSingular.get_leftv_res(clear_curr_ring)
    get_res(convertible_types[CMDS(t)], ring, d)
end

get_res(::Type{Int}, ring=nothing, data=get_res(INT_CMD)) = Int(data)

function get_res(::Type{BigInt}, ring=nothing, data=get_res(BIGINT_CMD))
    d = Int(data)
    if d & 1 != 0 # immediate int
        BigInt(d >> 2)
    else
        Base.GMP.MPZ.set(unsafe_load(Ptr{BigInt}(data))) # makes a copy of internals
    end
end

get_res(T::Type{<:Union{Spoly,Svector}}, r::Sring) =
    T(libSingular.internal_void_to_poly_helper(get_res(type_id(T))), r)

get_res(::Type{Snumber}, r::Sring) =
    Snumber(libSingular.internal_void_to_number_helper(get_res(NUMBER_CMD)), r)

get_res(::Type{Sideal}, r::Sring, data=get_res(IDEAL_CMD)) =
    Sideal(libSingular.internal_void_to_ideal_helper(data), r, true)

get_res(::Type{Smatrix}, r::Sring, data=get_res(MATRIX_CMD)) =
    Smatrix(libSingular.internal_void_to_matrix_helper(data), r, true)

function get_res(::Type{Sintvec}, ring=nothing, data=get_res(INTVEC_CMD))
    d = libSingular.lvres_array_get_dims(data, Int(INTVEC_CMD))[1]
    iv = Vector{Int}(undef, d)
    libSingular.lvres_to_jlarray(iv, data, Int(INTVEC_CMD))
    Sintvec(iv, true)
end

function get_res(::Type{Sintmat}, ring=nothing, data=get_res(INTMAT_CMD))
    d = libSingular.lvres_array_get_dims(data, Int(INTMAT_CMD))
    im = Matrix{Int}(undef, d)
    libSingular.lvres_to_jlarray(vec(im), data, Int(INTMAT_CMD))
    Sintmat(im, true)
end

function get_res(::Type{Sbigintmat}, ring=nothing, data=get_res(BIGINTMAT_CMD))
    r, c = libSingular.lvres_array_get_dims(data, Int(BIGINTMAT_CMD))
    bim = Matrix{BigInt}(undef, r, c)
    for i=1:r, j=1:c
        bim[i,j] = get_res(BigInt, nothing,
                           libSingular.lvres_bim_get_elt_ij(data, Int(BIGINTMAT_CMD), i,j))
    end
    Sbigintmat(bim, true)
end

function get_res(::Type{Slist}, ring=nothing, data=nothing)
    clear_curr_ring = isnothing(data) # WARNING: only the top level call to get_res must clear the currRing
                                      # (and not the recursive calls)
                                      # ==> check this correct behavior is maintained when refactoring
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

    clear_curr_ring && libSingular.clear_currRing()
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
cmd1(cmd::Union{Int,CMDS,Char}, T...) =
    maybe_get_res(libSingular.iiExprArith1(Int(cmd), sleftv(1)), T)

cmd2(cmd::Union{Int,CMDS,Char}, T...) =
    maybe_get_res(libSingular.iiExprArith2(Int(cmd), sleftv(1), sleftv(2)), T)

result_type(::Sintvec, ::Sintvec) = Sintvec
result_type(::Sintvec, ::Int) = Sintvec
result_type(::Int, ::Sintvec) = Sintvec

result_type(::Sintmat, ::Sintmat) = Sintmat
result_type(::Sintmat, ::Int) = Sintmat
result_type(::Int, ::Sintmat) = Sintmat

function rtgetindex(x::Sstring, y)
    set_arg1(x, withname=(y isa Sintvec))
    set_arg2(y, withcopy=!(y isa Sring))
    cmd2('[', y isa Sintvec ? STuple : Sstring)
end

const unimplemented_input = [ANY_TYPE]
const unimplemented_output = [RING_CMD]

# types which can currently be sent/fetched as sleftv to/from Singular, modulo the
# unimplemented lists above
const convertible_types = Dict{CMDS, Type}(
    INT_CMD       => Int,
    BIGINT_CMD    => BigInt,
    BIGINTMAT_CMD => Sbigintmat,
    STRING_CMD    => Sstring,
    INTVEC_CMD    => Sintvec,
    INTMAT_CMD    => Sintmat,
    MATRIX_CMD    => Smatrix,
    RING_CMD      => Sring,  # return type not implemented
    NUMBER_CMD    => Snumber,
    POLY_CMD      => Spoly,
    IDEAL_CMD     => Sideal,
    VECTOR_CMD    => Svector,
    LIST_CMD      => Slist,
    ANY_TYPE      => Any,   # migth be better to put `SingularType` ?
)
# NOTE: ANY_TYPE is used only for result types automatically (this has to be done
# on a case by case basis for input, as in most cases the name of the variable is
# needed)

for (id, T) in convertible_types
    id == ANY_TYPE && continue
    @eval type_id(::Type{$T}) = $id
end

const error_expected_types = Dict(
    "nvars" => "ring",
    "leadexp" => "poly",
)

const type_conversions = Dict{Int,Vector{Int}}()

let i = 0
    while true
        (it, ot) = libSingular.dConvertTypes(i)
        it == 0 && break
        its = push!(get!(type_conversions, ot, Int[ot]), it)
        i += 1
    end
end

let seen = Set{Tuple{Int,Int}}([(Int(PRINT_CMD), 1),
                                (Int(':'), 2)])
    # seen initially contain commands which alreay implement a catch-all method (e.g. `rtprint(::Any)`)
    valid_input_types = Int.(setdiff(keys(convertible_types), unimplemented_input))
    valid_output_types = Int.(setdiff(keys(convertible_types), unimplemented_output))

    todo = Dict{Pair{Int,                      # cmd
                     Union{Int,                # arg for 1-arg cmds
                           Tuple{Int,Int}}},   # arg1 & arg2
                Union{Int,                     # res when explicitly in the table
                      Vector{Int}}}()          # possible res resulting from conversions

    i = 0
    while true
        (cmd, res, arg) = libSingular.dArith1(i)
        cmd == 0 && break # end of dArith1
        i += 1
        todo[cmd => arg] = res # unconditional, might overwrite a previous entry resulting from
                               # conversion(s)
        for argi in get(type_conversions, arg, ())
            # conversions work according to the table order, so the first one might be the correct one,
            # but at run-time, it might fail and try other possibilities, so we keep them all
            restypes = get!(todo, cmd => argi, Int[])
            if restypes isa Vector # if not, it's an Int which is then the only admissible "res" type
                push!(restypes, res)
            end
        end
    end
    i = 0
    while true
        (cmd, res, arg1, arg2) = libSingular.dArith2(i)
        cmd == 0 && break # end of dArith2
        i += 1
        todo[cmd => (arg1, arg2)] = res
        for arg1i in get(type_conversions, arg1, (arg1,))
            for arg2i in get(type_conversions, arg2, (arg2,))
                restypes = get!(todo, cmd => (arg1i, arg2i), Int[])
                if restypes isa Vector
                    push!(restypes, res)
                end
            end
        end
    end

    # the todo table has to first be created without consideration for what we support yet,
    # in order to get the conversion business right (as is intended in Singular)
    # once the "extended" table (from table.h, extended with conversion entries) is created,
    # we can remove as yet unsupported entries
    filter!(todo) do ((cmd, args), res)
        if !(res isa Vector)
            res = [res]
        end
        filter!(in(valid_output_types), res)
        !isempty(res) &&
            all(in(valid_input_types), args)
    end

    for ((cmd, args), res) in todo
        if res isa Int
            res = [res]
        else
            unique!(res)
        end
        if args isa Int
            args = (args,)
        end
        @assert !isempty(res)
        @assert issubset(res, valid_output_types) && issubset(args, valid_input_types)
        res = CMDS.(res)
        args = CMDS.(args)

        name = something(get(cmd_to_string, cmd, nothing),
                         get(op_to_string, cmd, nothing),
                         "")
        name == "" && continue

        Sres = length(res) == 1 ? convertible_types[res[1]] : Any

        Sargs = [convertible_types[arg] for arg in args]

        rtname = Symbol(:rt, name)
        rtauto = Symbol(:rt, name, :_auto)
        expected = get(error_expected_types, name, "")
        if expected != ""
            expected = ", expected $name(`$expected`)"
        end

        if !((cmd, length(args)) in seen)
            # fall-back to rtauto so that definitions here don't overwrite
            # these which are manually implemented
            if length(args) == 1
                @eval begin
                    $rtname(x) = $rtauto(x)

                    if !($name in ("rvar",)) # TODO: fix this ugly hack (`rtrvar_auto` already implemented manually)
                        $rtauto(x) = rt_error(string($name, "(`$(rt_typestring(x))`) failed", $expected))
                    end
                end
            elseif length(args) == 2
                @eval begin
                    $rtname(x, y) = $rtauto(x, y)
                    $rtauto(x, y) = rt_error(string($name,
                                                    "(`$(rt_typestring(x))`, `$(rt_typestring(y))`) failed",
                                                    $expected))
                end
            end
            push!(seen, (cmd, length(args)))
        end
        if length(Sargs) == 1
            @eval function $rtauto(x::$(Sargs[1]))
                set_arg1(x, withcopy=(x isa Union{Spoly,Sideal,Svector,Sring,Smatrix}))
                cmd1($cmd, $Sres, sing_ring(x))
            end
        else
            @eval function $rtauto(x::$(Sargs[1]), y::$(Sargs[2]))
                ring = nothing
                if x isa SingularRingType
                    ring = sing_ring(x)
                    if y isa SingularRingType
                        rtname = $rtname
                        # TODO: check that it's really necessary to check, in other words can a situation
                        # happen in Singular where both objects don't depend on the same ring
                        @error_check_rings(ring, sing_ring(y), "binary command $rtname requires same base ring")
                    end
                elseif y isa SingularRingType
                    ring = sing_ring(y)
                end

                set_arg1(x, withcopy=(x isa Union{Spoly,Sideal,Svector,Sring,Smatrix}))
                set_arg2(y, withcopy=(y isa Union{Spoly,Sideal,Svector,Sring,Smatrix}))
                cmd2($cmd, $Sres, ring)
            end
        end
    end
end

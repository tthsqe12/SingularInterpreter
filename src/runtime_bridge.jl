##################### the lazy way: use sleftv's ##########
using .libSingular: Sleftv

# This decides whether we generate one method for each combination of arguments,
# or only catch-all methods. CATCH_ALL == true generates a lot fewer methods,
# but doesn't lead to significantly faster precompilation. But it can be
# convenient when some assertions fail to switch this to true as return
# types are then not checked against what is pretended in the table.h file
# (cf. "overrides" amending tables).
const CATCH_ALL = false

rChangeCurrRing(r::Sring) = libSingular.rChangeCurrRing(r.value)

function rChangeCurrRing(r::Ptr{Cvoid})
    libSingular.rChangeCurrRing(internal_void_to(Sring, r))
end

_copy(x::libSingular.ring) = libSingular.rCopy(x)
_copy(x::libSingular.resolution) = libSingular.syCopy(x)
_copy(x::libSingular.poly, ring) = libSingular.p_Copy(x, ring.value)
_copy(x::libSingular.ideal, ring) = libSingular.id_Copy(x, ring.value)
_copy(x::libSingular.matrix, ring) = libSingular.mp_Copy(x, ring.value)
_copy(x::libSingular.number, ring) = libSingular.n_Copy(x, ring.value)

_copy(x::Union{Sring,Sresolution}) = _copy(x.value)
_copy(x::Union{Spoly,Svector,Sideal,Smodule,Smatrix,Snumber}) = _copy(x.value, x.parent)

internal_void_to(::Type{<:Union{Spoly,Svector}}, ptr::Ptr) = libSingular.internal_void_to_poly_helper(ptr)
internal_void_to(::Type{Sring}, ptr::Ptr) = libSingular.internal_void_to_ring_helper(ptr)
internal_void_to(::Type{Snumber}, ptr::Ptr) = libSingular.internal_void_to_number_helper(ptr)
internal_void_to(::Type{<:Union{Sideal,Smodule}}, ptr::Ptr) = libSingular.internal_void_to_ideal_helper(ptr)
internal_void_to(::Type{Smatrix}, ptr::Ptr) = libSingular.internal_void_to_matrix_helper(ptr)
internal_void_to(::Type{Sresolution}, ptr::Ptr) =
    libSingular.internal_void_to_resolution_helper(ptr)

attributes(x) = nothing
attributes(x::Union{Sideal,Smodule}) = x.attributes


### sleftv ###

function Base.getproperty(lv::Sleftv, name::Symbol)
    if name == :next
        libSingular.sleftv_next(lv)
    elseif name == :data
        libSingular.sleftv_data(lv)
    elseif name == :rtyp
        libSingular.sleftv_type(lv)
    elseif name == :attribute
        libSingular.sleftv_attr(lv)
    elseif name == :flag
        libSingular.sleftv_flag(lv)
    elseif name == :Init
        () -> libSingular.sleftv_init(lv)
    elseif name == :CleanUp
        () -> libSingular.sleftv_cleanup(lv)
    elseif name == :cpp_object
        getfield(lv, :cpp_object)
    else
        error("type Sleftv has not field $name")
    end
end

function Base.setproperty!(lv::Sleftv, name::Symbol, x)
    if name == :next
        libSingular.sleftv_next(lv, x)
    elseif name == :data
        libSingular.sleftv_data(lv, x)
    elseif name == :rtyp
        libSingular.sleftv_type(lv, x)
    elseif name == :attribute
        libSingular.sleftv_attr(lv, x)
    elseif name == :flag
        libSingular.sleftv_flag(lv, x)
    else
        error("type Sleftv has not field $name")
    end
end

Base.propertynames(lv::Sleftv, private=false) = (:next, :data, :rtyp, :attribute, :flag,
                                                 :Init, :CleanUp, :cpp_object)

# shifted versions of the cpp couterparts
const FLAG_STD = Cuint(1) << 0
const FLAG_TWOSTD = Cuint(1) << 3
const FLAG_QRING = Cuint(1) << 4

function lv_init!(lv::Sleftv, typ, data, attr=nothing)
    lv.Init()
    lv.rtyp = Cint(typ)
    lv.data = data
    if attr !== nothing
        a = nothing
        for (name, val) in attr
            if name == "isSB"
                lv.flag |= FLAG_STD
                @assert val == 1
            elseif name == "qringNF"
                lv.flag |= FLAG_QRING
                @assert val == 1
            else
                if a === nothing
                    lv.attribute = a = libSingular.Sattr_cpp()
                else
                    # TODO: find a test for this branch, where more that 1 attribute are set
                    a = libSingular.sattr_next(a, libSingular.Sattr_cpp())
                end
                libSingular.sattr_init(a)
                libSingular.sattr_type(a, Int(type_id(typeof(val))))
                libSingular.sattr_data(a, make_data(val))
                libSingular.sattr_name(a, name)
            end
        end
    end
end

const _sleftvs = Sleftv[]

function get_sleftv(i::Int)
    while i >= length(_sleftvs)
        push!(_sleftvs, Sleftv())
    end
    _sleftvs[i+1]
end


### set_arg ###

function set_arg(lv, x; withname=false)
    lv_init!(lv, type_id(typeof(x)),
             make_data(x),
             attributes(x))
    if withname
        libSingular.make_idhdl_from(lv)
    end
    nothing
end

make_data(x::Int) = Ptr{Cvoid}(x)

function make_data(x::BigInt)
    n = GC.@preserve x libSingular.n_InitMPZ_internal(pointer_from_objref(x),
                                                      libSingular.coeffs_BIGINT())
    n.cpp_object
end

make_data(x::Union{Spoly,Svector,Sideal,Smodule,Smatrix,Snumber,Sring,Sresolution}) =
    _copy(x).cpp_object

make_data(x::Sstring) =
    GC.@preserve x libSingular.make_str(Ptr{Cvoid}(pointer(Base.unsafe_convert(Cstring, x.value))))

function make_data(x::Union{Sintvec, Sintmat})
    xv = x.value
    libSingular.make_intvec(vec(xv), x isa Sintmat, size(xv, 1), size(xv, 2))
end

function make_data(x::Sbigintmat)
    a = x.value
    d1, d2 = size(a)
    bim = libSingular.make_bigintmat_allocate(d1, d2)
    GC.@preserve a for i1=1:d1, i2=1:d2
        libSingular.make_bigintmat_init(bim, d1, d2,
                                        pointer_from_objref(a[i1, i2]), i1, i2)
    end
    bim
end

function make_data(x::Slist)
    list, m::Sleftv = libSingular.list_create(length(x.value))
    # m is in fact the first element of an array,
    # sleftv_at below allows to reach subsequent elements
    for (i, elt) in enumerate(x.value)
        set_arg(libSingular.sleftv_at(m, i - 1), elt)
    end
    list
end

set_arg1(x; withname=false) =
    set_arg(get_sleftv(1), x; withname=withname)

set_arg2(x; withname=false) =
    set_arg(get_sleftv(2), x; withname=withname)

set_arg3(x; withname=false) =
    set_arg(get_sleftv(3), x; withname=withname)

function set_argm(xs)
    @assert length(xs) > 0 # not implemented "yet", might not be necessary
    # have to use Sleftv_cpp, i.e. Singular-allocated sleftv objects,
    # because it deletes them, even if they are IDHDL (the .rtyp field,
    # at the end of the Singular routine, is set to 0 *before* .Cleanup()
    # is called, which means that Cleanup has no chance to avoid deleting
    # stuff because it doesn't see it's an IDHDL
    lv = lv1 = libSingular.Sleftv_cpp()
    set_arg(lv1, xs[1])
    for i=2:length(xs)
        lvi = libSingular.Sleftv_cpp()
        set_arg(lvi, xs[i])
        lv.next = lvi # by default set to 0, by a call to Init() in set_arg
        lv = lvi
    end
    lv1
end

### set_attribute ###

# copy attributes from an Sleftv `from` to the corresponding Julia object `x`

function set_attribute(x, from::Sleftv)
    attr = attributes(x)
    if attr === nothing && (from.flag != 0 || from.attribute.cpp_object != C_NULL)
        @warn "please some attributes have been lost (report as a bug)"
        return x
    end
    if from.flag & FLAG_STD != 0
        attr["isSB"] = 1
    end
    if from.flag & FLAG_QRING != 0
        attr["qringNF"] = 1
    end
    @assert from.flag & ~(FLAG_STD | FLAG_QRING) == 0
    at = from.attribute
    while  at.cpp_object != C_NULL
        T = convertible_types[CMDS(libSingular.sattr_type(at))]
        attr[unsafe_string(Ptr{Cchar}(libSingular.sattr_name(at)))] =
            construct(T, libSingular.sattr_data(at))
        at = libSingular.sattr_next(at)
    end
    return x
end

set_attribute(x, from::Ptr) = x


### get_res / construct ###

getdata(x::Sleftv) = x.data
getdata(x::Ptr) = x

# Singular functions iiExprArith1 and friends 0-initialize the res parameter immediately
# so the data there, if any, is not reclaimed
# TODO: cleanup result data when appropriate between calls
function get_res(expectedtype::CMDS)
    res = get_sleftv(0)

    @assert expectedtype == STUPLE_CMD || res.next.cpp_object == C_NULL ||
         expectedtype == ANY_TYPE && CATCH_ALL

    @assert expectedtype ∈ (ANY_TYPE, STUPLE_CMD) || res.rtyp == Int(expectedtype)
    res
end

# construct accepts (usually) either an Sleftv or directly a (void*) data
# when it's from an Sleftv, we "move" the data from it, i.e. we don't do
# a copy

function construct(::Type{T}, from) where T
    res = _construct(T, from)
    if from isa Sleftv
        from.CleanUp()
    end
    res
end

function _construct(::Type{Any}, from::Sleftv)
    @assert CATCH_ALL || from.next.cpp_object == C_NULL # TODO: handle when it's a tuple!
    if from.next.cpp_object != C_NULL
        construct(STuple, from)
    else
        construct(convertible_types[CMDS(from.rtyp)], from)
    end
end

_construct(::Type{Int}, from) = Int(getdata(from))

# from::Ptr hapens when called from construct(Sbigintmat, ...)
function _construct(::Type{BigInt}, from)
    data = getdata(from)

    d = Int(data)
    if d & 1 != 0 # immediate int
        BigInt(d >> 2)
    else
        Base.GMP.MPZ.set(unsafe_load(Ptr{BigInt}(data))) # makes a copy of internals
    end
end

# TODO: check that a copy is necessary, and if yes why not other types?
# cf. construct(Slist, ...)
function _construct(::Type{T}, from::Union{Ptr{Cvoid},Sleftv}
                   ) where T <: Union{Spoly,Svector,Snumber,Sideal,Smodule,
                                      Smatrix,Sresolution,Sring}

    r = rt_basering()
    x = internal_void_to(T, getdata(from))
    if from isa Sleftv
        from.data = C_NULL # needed because of the cleanup, as we steal the data
                           # (it's a "move", in c++ terms)
    else
        x = _copy(x, r)
    end
    res = T == Sideal || T == Smodule || T == Smatrix ?
              T(x, r, true) :
          T == Sring ?
              T(x) :
              T(x, r)
    set_attribute(res, from)
end

function _construct(::Type{Sintvec}, from)
    d = libSingular.lvres_array_get_dims(getdata(from), Int(INTVEC_CMD))[1]
    iv = Vector{Int}(undef, d)
    libSingular.lvres_to_jlarray(iv, getdata(from), Int(INTVEC_CMD))
    Sintvec(iv, true)
end

function _construct(::Type{Sintmat}, from)
    d = libSingular.lvres_array_get_dims(getdata(from), Int(INTMAT_CMD))
    im = Matrix{Int}(undef, d)
    libSingular.lvres_to_jlarray(vec(im), getdata(from), Int(INTMAT_CMD))
    Sintmat(im, true)
end

function _construct(::Type{Sbigintmat}, from)
    r, c = libSingular.lvres_array_get_dims(getdata(from), Int(BIGINTMAT_CMD))
    bim = Matrix{BigInt}(undef, r, c)
    for i=1:r, j=1:c
        bim[i,j] = _construct(BigInt,
                              libSingular.lvres_bim_get_elt_ij(getdata(from), Int(BIGINTMAT_CMD), i,j))
    end
    Sbigintmat(bim, true)
end

function _construct(::Type{Slist}, from)
    n::Int, lv0::Sleftv = libSingular.internal_void_to_lists(getdata(from))
    a = Vector{Any}(undef, n)
    cnt = 0
    for i = 1:n
        lv = libSingular.sleftv_at(lv0, i-1)
        typ = CMDS(lv.rtyp)
        T = convertible_types[typ]
        a[i] = rt_copy_own(construct(T, lv))
        cnt += rt_is_ring_dep(a[i])
    end
    ring = if cnt == 0
               rtInvalidRing
           else
               r = rt_basering()
               @assert r.valid
               r
           end
    Slist(a, ring, cnt, nothing, true)
end

function _construct(::Type{STuple}, from::Sleftv)
    a = Any[]
    next = C_NULL
    from = get_sleftv(0)
    while from.cpp_object != C_NULL
        @assert from.data != C_NULL
        if from.rtyp == Int(STRING_CMD)
            push!(a, _construct(Sstring, from))
        else
            rt_error("unknown type in the result of last command")
        end
        from = from.next
    end
    STuple(a)
end

_construct(::Type{Sstring}, from) =
    Sstring(unsafe_string(Ptr{Cchar}(getdata(from))))


### cmd ###

function maybe_get_res(err, T)
    # we assume the currRing didn't change on the Singular side
    if err == 0
        r = construct(T, get_res(type_id(T)))
        rChangeCurrRing(C_NULL)
        r
    else
        rChangeCurrRing(C_NULL)
        rt_error("failed operation")
    end
end

# return true when no-error
function cmd1(cmd::Union{Int,CMDS,Char}, T, x)
    # this sets the value to NULL if basering not defined
    rChangeCurrRing(rt_basering())
    set_arg1(x)
    maybe_get_res(libSingular.iiExprArith1(Int(cmd), get_sleftv(0), get_sleftv(1)),
                  T)
end

function cmd2(cmd::Union{Int,CMDS,Char}, T, x, y)
    rChangeCurrRing(rt_basering())
    set_arg1(x, withname=(y isa Sintvec && x isa Sstring))
    set_arg2(y)
    maybe_get_res(libSingular.iiExprArith2(Int(cmd), get_sleftv(0), get_sleftv(1), get_sleftv(2)),
                  T)
end

function cmd3(cmd::Union{Int,CMDS,Char}, T, x, y, z)
    rChangeCurrRing(rt_basering())
    set_arg1(x, withname=(y isa Sintvec && x isa Sstring))
    set_arg2(y)
    set_arg3(z)
    maybe_get_res(libSingular.iiExprArith3(Int(cmd), get_sleftv(0), get_sleftv(1),
                                           get_sleftv(2), get_sleftv(3)),
                  T)
end

function cmdm(cmd::Union{Int,CMDS,Char}, T, xs)
    rChangeCurrRing(rt_basering())
    lvs = set_argm(xs)
    maybe_get_res(libSingular.iiExprArithM(Int(cmd), get_sleftv(0), lvs), T)
end

### generating commands from tables ###

const unimplemented_input = [ANY_TYPE, STUPLE_CMD]
const unimplemented_output = [HANDLED_TYPES]

# types which can currently be sent/fetched as sleftv to/from Singular, modulo the
# unimplemented lists above
const convertible_types = Dict{CMDS, Type}(
    INT_CMD        => Int,
    BIGINT_CMD     => BigInt,
    BIGINTMAT_CMD  => Sbigintmat,
    STRING_CMD     => Sstring,
    INTVEC_CMD     => Sintvec,
    INTMAT_CMD     => Sintmat,
    MATRIX_CMD     => Smatrix,
    RING_CMD       => Sring,
    NUMBER_CMD     => Snumber,
    POLY_CMD       => Spoly,
    IDEAL_CMD      => Sideal,
    MODUL_CMD      => Smodule,
    VECTOR_CMD     => Svector,
    LIST_CMD       => Slist,
    RESOLUTION_CMD => Sresolution,
    HANDLED_TYPES  => Any,   # represents a union for input, like ANY_TYPE does for output
    ANY_TYPE       => Any,   # migth be better to put `SingularType` ?
    STUPLE_CMD     => STuple,
)
# NOTE: ANY_TYPE is used only for result types automatically (this has to be done
# on a case by case basis for input, as in most cases the name of the variable is
# needed)

for (id, T) in convertible_types
    id ∈ (HANDLED_TYPES,) && continue
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

# cf. table.jl, for now we just do that for resolution/lists/bigint, for which
# conversions are annoying to re-implement
const cmd_to_builtin_type_string_limited = Dict(
    Int(RESOLUTION_CMD) => "resolution",
    Int(LIST_CMD)       => "list",
    Int(BIGINT_CMD)     => "bigint",
)

let seen = Set{Tuple{Int,Int}}([(Int(PRINT_CMD), 1),
                                (Int(':'), 2)])
    # seen initially contain commands which alreay implement a catch-all method (e.g. `rtprint(::Any)`)

    # fix incorrectly specified return types in the table,
    # or set return type to Stuple, which is handled implicitly by Singular
    overrides = Dict{Tuple{Vararg{Int}}, Int}(
        Int.((FAC_CMD, IDEAL_CMD,  POLY_CMD,   INT_CMD))    => Int(ANY_TYPE),
        Int.(('[',     STRING_CMD, STRING_CMD, INTVEC_CMD)) => Int(STUPLE_CMD)
    )

    valid_input_types = Int.(setdiff(keys(convertible_types), unimplemented_input))
    valid_output_types = Int.(setdiff(keys(convertible_types), unimplemented_output))

    # overwrite the value for HANDLED_TYPES, for a more tight signature
    # (could be done earlier, but it's easy here)
    convertible_types[HANDLED_TYPES] = AnyST = # Any Singular Type
        Union{(convertible_types[CMDS(k)] for k in valid_input_types
                                              if k != Int(HANDLED_TYPES))...}

    todo = Dict{Pair{Int,                       # cmd
                     Union{Tuple{Vararg{Int}},  # args
                           Bool}},              # variable number of args, true == at least one
                Union{Int,                      # res when explicitly in the table
                      Vector{Int}}}()           # possible res resulting from conversions

    i = 0
    while true
        (cmd, res, arg, nc) = libSingular.dArith1(i) # nc = NO_CONVERSION, which currently concerns only
                                                     # dArith1 and dArith2
        cmd == 0 && break # end of dArith1
        i += 1
        res = get(overrides, (cmd, res, arg), res)
        todo[cmd => (arg,)] = res # unconditional, might overwrite a previous entry resulting from
                                  # conversion(s)
        if !nc
            for argi in get(type_conversions, arg, ())
                # conversions work according to the table order, so the first one might be the correct one,
                # but at run-time, it might fail and try other possibilities, so we keep them all
                restypes = get!(todo, cmd => (argi,), Int[])
                if restypes isa Vector # if not, it's an Int which is then the only admissible "res" type
                    push!(restypes, res)
                end
            end
        end
    end

    i = 0
    while true
        (cmd, res, arg1, arg2, nc) = libSingular.dArith2(i)
        cmd == 0 && break # end of dArith2
        i += 1
        res = get(overrides, (cmd, res, arg1, arg2), res)
        todo[cmd => (arg1, arg2)] = res

        if !nc
            for arg1i in get(type_conversions, arg1, (arg1,))
                for arg2i in get(type_conversions, arg2, (arg2,))
                    restypes = get!(todo, cmd => (arg1i, arg2i), Int[])
                    if restypes isa Vector
                        push!(restypes, res)
                    end
                end
            end
        end
    end

    i = 0
    while true
        (cmd, res, arg1, arg2, arg3) = libSingular.dArith3(i)
        cmd == 0 && break # end of dArith3
        i += 1
        res = get(overrides, (cmd, res, arg1, arg2, arg3), res)
        todo[cmd => (arg1, arg2, arg3)] = res
        for arg1i in get(type_conversions, arg1, (arg1,))
            for arg2i in get(type_conversions, arg2, (arg2,))
                for arg3i in get(type_conversions, arg3, (arg3,))
                    restypes = get!(todo, cmd => (arg1i, arg2i, arg3i), Int[])
                    if restypes isa Vector
                        push!(restypes, res)
                    end
                end
            end
        end
    end

    i = 0
    _any = Int(HANDLED_TYPES)
    overridesM = Dict(
        Int.((REDUCE_CMD, IDEAL_CMD, 4))  => Int(POLY_CMD),
        Int.((JET_CMD, POLY_CMD, 2))      => Int(ANY_TYPE),
        Int.((JET_CMD, POLY_CMD, 3))      => Int(ANY_TYPE),
        Int.((JET_CMD, POLY_CMD, 4))      => Int(ANY_TYPE),
        Int.((LIFTSTD_CMD, IDEAL_CMD, 2)) => Int(ANY_TYPE),
        Int.((LIFTSTD_CMD, IDEAL_CMD, 3)) => Int(ANY_TYPE),
        Int.((LIFTSTD_CMD, IDEAL_CMD, 4)) => Int(ANY_TYPE),
        Int.((REDUCE_CMD, IDEAL_CMD, 2))  => Int(ANY_TYPE),
        Int.((REDUCE_CMD, IDEAL_CMD, 3))  => Int(ANY_TYPE),
        Int.((REDUCE_CMD, IDEAL_CMD, 4))  => Int(ANY_TYPE),
        Int.((REDUCE_CMD, IDEAL_CMD, 5))  => Int(ANY_TYPE),
    )
    while true
        (cmd, res, nargs) = libSingular.dArithM(i)
        cmd == 0 && break
        i += 1
        res = get(overridesM, (cmd, res, nargs), res)
        if nargs < 0
            @assert nargs >= -2
            args = nargs == -2
        else
            args = ntuple(_ -> _any, nargs)
        end
        todo[cmd => args] = res
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
            (args isa Bool ||
             all(in(valid_input_types), args))
    end

    for ((cmd, args), res) in todo
        if res isa Int
            res = [res]
        else
            unique!(res)
        end

        @assert !isempty(res)
        @assert issubset(res, valid_output_types) && (args isa Bool || issubset(args, valid_input_types))
        res = CMDS.(res)
        if !(args isa Bool)
            args = CMDS.(args)
        end

        name = something(get(cmd_to_string, cmd, nothing),
                         get(op_to_string, cmd, nothing),
                         get(cmd_to_builtin_type_string_limited, cmd, nothing),
                         "")
        name == "" && continue

        Sres = length(res) == 1 ? convertible_types[res[1]] : Any

        rtname = Symbol(:rt, name)
        rtauto = Symbol(:rt, name, :_auto)
        expected = get(error_expected_types, name, "")
        if expected != ""
            expected = ", expected $name(`$expected`)"
        end

        if args isa Bool
            # here we don't use the `$rtauto` indirection, as the method must be a variadic catch-all,
            # we will rely on Julia warnings for the case where we overwrite a manually defined one
            @eval function $rtname(x...)
                $args && isempty(x) &&
                    rt_error(string($name, "() failed, at least one argument expected"))
                cmdm($cmd, $Sres, x)
            end
            continue
        end

        Sargs = [convertible_types[arg] for arg in args]

        if !((cmd, length(args)) in seen)
            # fall-back to rtauto so that definitions here don't overwrite
            # these which are manually implemented
            if length(args) == 1
                if CATCH_ALL
                    @eval $rtname(x::$AnyST) = cmd1($cmd, Any, x)
                else @eval begin
                    $rtname(x) = $rtauto(x)

                    if !($name in ("rvar",)) # TODO: fix this ugly hack (`rtrvar_auto` already implemented manually)
                        $rtauto(x) = rt_error(string($name, "(`$(rt_typestring(x))`) failed", $expected))
                    end
                end
                end
            elseif length(args) == 2
                if CATCH_ALL
                    @eval $rtname(x::$AnyST, y::$AnyST) = cmd2($cmd, Any, x, y)
                else @eval begin
                    $rtname(x, y) = $rtauto(x, y)
                    $rtauto(x, y) = rt_error(string($name,
                                        "(`$(rt_typestring(x))`, `$(rt_typestring(y))`) failed",
                                                    $expected))
                end
                end
            elseif length(args) == 3
                if CATCH_ALL
                    @eval $rtname(x::$AnyST, y::$AnyST, z::$AnyST) = cmd3($cmd, Any, x, y, z)
                else @eval begin
                    $rtname(x, y, z) = $rtauto(x, y, z)
                    $rtauto(x, y, z) = rt_error(string($name,
                                           "(`$(rt_typestring(x))`, `$(rt_typestring(y)), `$(rt_typestring(z))`) failed",
                                                    $expected))
                end
                end
            else
                @assert length(args) == 0 || length(args) ∈ 4:6
                length(args) == 0 && continue # TODO: check whether we need to implement those
            end
            push!(seen, (cmd, length(args)))
        end

        1 <= length(Sargs) <= 3 && CATCH_ALL && continue
        if length(Sargs) == 1
            @eval $rtauto(x::$(Sargs[1])) = cmd1($cmd, $Sres, x)
        elseif length(Sargs) == 2
            @eval $rtauto(x::$(Sargs[1]), y::$(Sargs[2])) = cmd2($cmd, $Sres, x, y)
        elseif length(Sargs) == 3
            @eval $rtauto(x::$(Sargs[1]), y::$(Sargs[2]), z::$(Sargs[3])) =
                cmd3($cmd, $Sres, x, y, z)
        elseif length(Sargs) == 4
            @eval $rtname(a::$AnyST, b::$AnyST, c::$AnyST, d::$AnyST) = cmdm($cmd, $Sres, (a, b, c, d))
        elseif length(Sargs) == 5
            @eval $rtname(a::$AnyST, b::$AnyST, c::$AnyST, d::$AnyST, e::$AnyST) = cmdm($cmd, $Sres, (a, b, c, d, e))
        elseif length(Sargs) == 6
            @eval $rtname(a::$AnyST, b::$AnyST, c::$AnyST, d::$AnyST, e::$AnyST, f::$AnyST) = cmdm($cmd, $Sres, (a, b, c, d, e, f))
        else
            @assert false
        end
    end
end

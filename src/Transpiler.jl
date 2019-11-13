#=

rt = singular runtime. If a function is going to be used at runtime, it should start with rt.

rt prefix generally means the function corresponds to a singular function/operator
rt_ prefix means it used internally
    ex: SINGULAR    JULIA
        print(a)    rtprint(a)
        a + b       rtplus(a, b)
        a;          rt_printout(a)


It is possible for elements of a Singular list to be "nothing", i.e. l[1] after
list l; l[2] = 0;

Functions can also return "nothing", i.e. the return value of
proc f() {return();};

Therefore we use Julia's :nothing for both of these "nothings" and do include Nothing in SingularType below.

This "nothing" is distinct from a zero-length tuple and is very distinct from the SName type defined below
For example, the statement
a, b = 1, f(), 1;
fails in the Singular interpreter because the right hand side has length 3. The statement
a, b, c = 1, f(), 1
fails in the Singular interpreter because something on the "right side is not a datum".

The Julia interpreter will fail in the first example because the length of the rhs tuple is checked before assignment.
The Julia interpreter will fail in the second example because the assignment to b is done via
b = convert2T(..)       # T is the stored type of b, which we won't allow to be Nothing
and the convert2T will throw an error on :nothing (unless b is nothing (by declaring it a "def"))

In general, it is allowed to pass nothing around in singular, i.e.
list k, l;
l[2] = 0;       // size(l) is 2, l[1] is nothing
k[1] = 0;       // size(k) is 1
k[1] = l[1];    // size(k) is 0

Therefore, the error must occur when trying to assign nothing to b, and not when constructing the tuple.

=#


###### these macros do not work without esc !!!!

macro warn_check(ex, msgs...)
    msg_body = isempty(msgs) ? ex : msgs[1]
    msg = string(msg_body)
    return :($(esc(ex)) ? nothing : rt_warn($msg))
end


macro error_check(ex, msgs...)
    msg_body = isempty(msgs) ? ex : msgs[1]
    msg = string(msg_body)
    return :($(esc(ex)) ? nothing : rt_error($msg))
end


#### singular type "?unknown type?", which is not avaliable to the user and will NOT appear in SingularTypes below
struct SName
    name::Symbol
end
makeunknown(s::String) = SName(Symbol(s))


########################## ring independent types #############################

##### singular type "proc"      immutable in the singular language
struct SProc
    func::Function
    name::String
    package::Symbol
end
procname_to_func(name::String) = Symbol("##"*name)
procname_to_func(f::Symbol) = procname_to_func(f.name)


#### singular type "int"        immutable in the singular language
# Int same


#### singular type "bigint"     immutable in the singular language
# BigInt same


#### singular type "string"     immutable in the singular language
# Singular splats all arguments inside () by default, so we need ... in Julia
# The julia String is iterable, so we need another type
struct SString
    string::String
end


#### singular type "intvec"     mutable in the singular language
struct SIntVec
    vector::Vector{Int}
end


#### singular type "intmat"     mutable in the singular language
struct SIntMat
    matrix::Array{Int, 2}
end


#### singular type "bigintmat"  immutable in the singular language
struct SBigIntMat
    matrix::Array{BigInt, 2}
end


#### singular type "list"       mutable in the singular language
mutable struct SListData # special type to wrap Vector{Any} to avoid exploding type inference
    data::Vector{Any}
end

struct SList
    list::SListData
end


#### singular type "ring"       immutable in the singular language, but also holds identifiers of ring-dependent types
mutable struct SRing
    ring_ptr::libSingular.ring
    refcount::Int
    level::Int                  # 1->created at global, 2->created in fxn called from global, ect..
    vars::Dict{Symbol, Any}     # global ring vars
    valid::Bool                 # valid==false <=> ring_ptr==NULL

    function SRing(valid_::Bool, ring_ptr_::libSingular.ring, level::Int)
        r = new(ring_ptr_, 1, level, Dict{Symbol, Any}(), valid_)
        finalizer(rt_ring_finalizer, r)
        return r
    end
end

function rt_ring_finalizer(a::SRing)
    a.refcount -= 1
    if a.refcount <= 0
        @assert a.refcount == 0
        libSingular.rDelete(a.ring_ptr)
    end
end

############################ ring dependent types ############################

# The constructor for T takes ownership of a raw pointer and stores in the member T_ptr

#### singular type "number"     immutable in the singular language
mutable struct SNumber
    number_ptr::libSingular.number
    parent::SRing

    function SNumber(number_ptr_::libSingular.number, parent_::SRing)
        a = new(number_ptr_, parent_)
        finalizer(rt_number_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

function rt_number_finalizer(a::SNumber)
    libSingular.n_Delete(a.number_ptr, a.parent.ring_ptr)
    rt_ring_finalizer(a.parent)
end


#### singular type "poly"       immutable in the singular language
mutable struct SPoly
    poly_ptr::libSingular.poly
    parent::SRing

    function SPoly(poly_ptr_::libSingular.poly, parent_::SRing)
        a = new(poly_ptr_, parent_)
        finalizer(rt_poly_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

function rt_poly_finalizer(a::SPoly)
    libSingular.p_Delete(a.poly_ptr, a.parent.ring_ptr)
    rt_ring_finalizer(a.parent)
end


#### singular type "ideal"      mutable like a list in the singular language
mutable struct SIdealData
    ideal_ptr::libSingular.ideal
    parent::SRing

    function SIdealData(ideal_ptr_::libSingular.ideal, parent_::SRing)
        a = new(ideal_ptr_, parent_)
        finalizer(rt_ideal_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

function rt_ideal_finalizer(a::SIdealData)
    libSingular.id_Delete(a.ideal_ptr, a.parent.ring_ptr)
    rt_ring_finalizer(a.parent)
end

struct SIdeal
    ideal::SIdealData
end


#### singular type "matrix"
mutable struct SMatrix
#    value::libSingular.matrix
    parent::SRing
end



# the underscore types include the underlying mutable containers
const _IntVec    = Union{SIntVec, Vector{Int}}
const _IntMat    = Union{SIntMat, Array{Int, 2}}
const _BigIntMat = Union{SBigIntMat, Array{BigInt, 2}}
const _List      = Union{SList, SListData}
const _Ideal     = Union{SIdeal, SIdealData}

# it is almost useless to have a list of singular types because of newstruct
#const SingularType = Union{Nothing, SProc, Int, BigInt, SString,
#                           SIntVec, SIntMat, SBigIntMat, SList,
#                           SRing, SNumber, SPoly, SIdeal}

# the set of possible ring dependent types is finite because newstruct creates ring indep types
const SingularRingType = Union{SNumber, SPoly, SIdeal}

function type_is_ring_dependent(t::String)
    return t == "number" || t == "poly" || t == "ideal" || t == "matrix"
end



#const _SingularType = Union{SingularType,
#                           Vector{Int}, Array{Int, 2}, Array{BigInt, 2}, SListData,
#                           SIdealData}


function rt_ringof(a::SingularRingType)
    return rt_ref(a).parent
end

function rt_ringof(a)
    rt_error("type " * rt_typestring(a) * " does not have a basering")
    return rtInvalidRing
end

# The CallStackEntry holds the "context" required by every function.
# This could be passed around as a first argument to _every_ rt function, but
# we take the simpler approach for now and manually manage a call stack in rtGlobal.callstack.
mutable struct rtCallStackEntry
    start_rindep_vars::Int      # index into rtGlobal.local_rindep_vars
    start_rdep_vars::Int        # index into rtGlobal.local_rdep_vars
    current_ring::SRing
    current_package::Symbol
end

mutable struct rtGlobalState
    optimize_locals::Bool
    last_printed::Any
    rtimer_base::UInt64
    rtimer_scale::UInt64
    vars::Dict{Symbol, Dict{Symbol, Any}}     # global ring indep vars
    callstack::Array{rtCallStackEntry}
    local_rindep_vars::Array{Pair{Symbol, Any}}
    local_rdep_vars::Array{Pair{Symbol, SingularRingType}}
end

const rtInvalidRing = SRing(false, libSingular.rDefault_null_helper(), 1)

const rtGlobal = rtGlobalState(false,
                               nothing,
                               time_ns(),
                               1000000000,
                               Dict(:Top => Dict{Symbol, Any}()),
                               rtCallStackEntry[rtCallStackEntry(1, 1, rtInvalidRing, :Top)],
                               Pair{Symbol, Any}[],
                               Pair{Symbol, SingularRingType}[])

function rt_basering()
    return rtGlobal.callstack[end].current_ring
end


function rt_search_callstack_rindep(a::Symbol)
    n = length(rtGlobal.callstack)
    for i in rtGlobal.callstack[n].start_rindep_vars:length(rtGlobal.local_rindep_vars)
        if rtGlobal.local_rindep_vars[i].first == a
            return true, i
        end
    end
    return false, 0
end

function rt_search_callstack_rdep(a::Symbol)
    n = length(rtGlobal.callstack)
    R = rtGlobal.callstack[n].current_ring
    for i in rtGlobal.callstack[n].start_rdep_vars:length(rtGlobal.local_rdep_vars)
        if rtGlobal.local_rdep_vars[i].first == a &&
           rtGlobal.local_rdep_vars[i].second.parent === R
            return true, i
        end
    end
    return false, 0
end



# all of the singular types have trivial iterators - will be used because all arguments to functions are automatically splatted

Base.iterate(a::Nothing) = iterate(a, 0)
Base.iterate(a::Nothing, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SProc) = iterate(a, 0)
Base.iterate(a::SProc, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SString) = iterate(a, 0)
Base.iterate(a::SString, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIntVec) = iterate(a, 0)
Base.iterate(a::SIntVec, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIntMat) = iterate(a, 0)
Base.iterate(a::SIntMat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SBigIntMat) = iterate(a, 0)
Base.iterate(a::SBigIntMat, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SList) = iterate(a, 0)
Base.iterate(a::SList, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SRing) = iterate(a, 0)
Base.iterate(a::SRing, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SPoly) = iterate(a, 0)
Base.iterate(a::SPoly, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SIdeal) = iterate(a, 0)
Base.iterate(a::SIdeal, state) = (state == 0 ? (a, 1) : nothing)
Base.iterate(a::SMatrix) = iterate(a, 0)
Base.iterate(a::SMatrix, state) = (state == 0 ? (a, 1) : nothing)

function Base.deepcopy_internal(a::SProc, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SIntVec, dict::IdDict)
    return SIntVec(deepcopy(a.vector))
end

function Base.deepcopy_internal(a::SIntMat, dict::IdDict)
    return SIntMat(deepcopy(a.matrix))
end

function Base.deepcopy_internal(a::SBigIntMat, dict::IdDict)
    return SBigIntMat(deepcopy(a.matrix))
end

function Base.deepcopy_internal(a::SListData, dict::IdDict)
    return SListData(deepcopy(a.data))
end

function Base.deepcopy_internal(a::SList, dict::IdDict)
    return SList(deepcopy(a.list))
end

function Base.deepcopy_internal(a::SRing, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SNumber, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SPoly, dict::IdDict)
    return a
end

function Base.deepcopy_internal(a::SIdealData, dict::IdDict)
    id = libSingular.id_Copy(a.ideal_ptr, a.parent.ring_ptr)
    return SIdealData(id, a.parent)
end

function Base.deepcopy_internal(a::SIdeal, dict::IdDict)
    return SIdeal(deepcopy(a.ideal))
end



########################## make and friends ###################################

function rt_box_it_with_ring(n::libSingular.number, r::SRing)
    return SNumber(n, r)
end

function rt_box_it_with_ring(p::libSingular.poly, r::SRing)
    return SPoly(p, r)
end


# make takes a name and looks it up according to singular's resolution rules
# this function is named make in the c singular interpreter code
function rt_make(a::SName, allow_unknown::Bool = false)

    # local ring independent
    b, i = rt_search_callstack_rindep(a.name)
    if b
        return rt_ref(rtGlobal.local_rindep_vars[i].second)
    end

    # local ring dependent
    b, i = rt_search_callstack_rdep(a.name)
    if b
        return rt_ref(rtGlobal.local_rdep_vars[i].second)
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                return rt_ref(d[a.name])
            end        
        end
    end

    # global ring dependent
    R = rtGlobal.callstack[end].current_ring
    if haskey(R.vars, a.name)
        return rt_ref(R.vars[a.name])
    end

    # monomials
    ok, p = libSingular.lookupIdentifierInRing(String(a.name), R.ring_ptr)
    if ok
        return rt_box_it_with_ring(p, rt_basering())
    end

    allow_unknown || rt_error(String(a.name) * " is undefined")

    return a
end

function rtkill(a::SName)

    # local ring independent
    b, i = rt_search_callstack_rindep(a.name)
    if b
        rtGlobal.local_rindep_vars[i] = rtGlobal.local_rindep_vars[end]
        pop!(rtGlobal.local_rindep_vars)
        return
    end

    # local ring dependent
    b, i = rt_search_callstack_rdep(a.name)
    if b
        rtGlobal.local_rdep_vars[i] = rtGlobal.local_rdep_vars[end]
        pop!(rtGlobal.local_rdep_vars)
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                delete!(d, a.name)
                return
            end        
        end
    end

    # global ring dependent
    R = rt_basering()
    if haskey(R.vars, a.name)
        delete!(R.vars, a.name)
        return
    end

    rt_error("cannot kill " * String(a.name))
    return
end


function rt_backtick(a::SString)
    return makeunknown(a.string)
end

function rt_backtick(a)
    rt_error("string expected between backticks")
end


function rt_enterfunction(package::Symbol)
    i1 = length(rtGlobal.local_rindep_vars) + 1
    i2 = length(rtGlobal.local_rdep_vars) + 1
    n = length(rtGlobal.callstack)
    push!(rtGlobal.callstack, rtCallStackEntry(i1, i2, rtGlobal.callstack[n].current_ring, package))
end

function rt_leavefunction()
    n = length(rtGlobal.callstack)
    i1 = rtGlobal.callstack[n].start_rindep_vars - 1
    i2 = rtGlobal.callstack[n].start_rdep_vars - 1
    @assert length(rtGlobal.local_rindep_vars) >= i1
    @assert length(rtGlobal.local_rdep_vars) >= i2
    resize!(rtGlobal.local_rindep_vars, i1)
    resize!(rtGlobal.local_rdep_vars, i2)
    pop!(rtGlobal.callstack)
end



function rtcall(allow_name_ret::Bool, f::SProc, v...)
    return f.func(v...)
end

function rtcall(allow_name_ret::Bool, a::SName, v...)

    # local ring independent - unlikely proc
    b, i = rt_search_callstack_rindep(a.name)
    if b
        return rtcall(false, rtGlobal.local_rindep_vars[i].second, v...)
    end

    # local ring dependent - probably map
    b, i = rt_search_callstack_rdep(a.name)
    if b
        return rtcall(false, rtGlobal.local_rdep_vars[i].second, v...)
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

    # global ring dependent - probably map
    if haskey(rt_basering().vars, a.name)
        return rtcall(false, rt_basering().vars[a.name], v...)
    end

    # newstruct constructors
    if haskey(rtGlobal_NewStructCasts, String(a.name))
        return rtGlobal_NewStructCasts[String(a.name)](v...)
    end

    # indexed variable constructor
    return rtcall(allow_name_ret, [String(a.name)], v...)
end

function rtcall(allow_name_ret::Bool, a::Array{String}, v...)
    length(v) == 1 || rt_error("bad indexed variable construction")
    v = v[1]

    V = Int[]
    if isa(v, Int)
        V = Int[v]
    elseif isa(v, _IntVec)
        V = rt_ref(v)
    else
        rt_error("bad indexed variable construction")
    end

    # TODO lookup a(v) in currentring vars/pars v is int or intvec

    R = rt_basering()

    r = Any[]
    ok = true
    for b in a
        if ok && R.valid
            for i in V
                ok, p = libSingular.lookupIdentifierInRing(b * "(" * string(i) * ")", R.ring_ptr)
                if ok
                    push!(r, rt_box_it_with_ring(p, R))
                else
                    break
                end
            end
        else
            ok = false
            break
        end
    end

    if ok
        return length(r) == 1 ? r[1] : Tuple(r)
    end

    allow_name_ret || rt_error("bad indexed variable construction")

    r = String[]
    for b in a
        for i in V
            push!(r, b * "(" * string(i) * ")")
        end
    end
    return r
end


# copiers returning SingularType, usually so that we can assign it somewhere
# we have to copy stuff, and usually the stuff to copy is allowed to be a tuple
# rt_copy_allow_tuple will be called on stuff inside (), i.e. if the object (a,f(b),c)
# needs to be constructed, it might be constructed in julia as
# tuple(a, rt_copy_allow_tuple(f(b))..., c)

# if f(b) returns a tuple t, then rt_copy_allow_tuple(t) will simply return t
# if f(b) returns a SBigIntMat m, then rt_copy_allow_tuple(m) will simply return m and the iterator is trivial
# if f(b) returns a Array{BigInt, 2} m, then rt_copy_allow_tuple(m) makes a deepcopy and returns a SBigIntMat, whose iterator is trivial

# rt_copy: copy with an error on tuples
# rt_copy_allow_tuple: copy everything rt_copy can copy and also allow tuples through

# rt_copy is probably only used internally since anything the transpiler would want to copy could be a tuple

rt_copy(a::Nothing) = a
rt_copy_allow_tuple(a::Nothing) = a

rt_copy(a::SProc) = a
rt_copy_allow_tuple(a::SProc) = a

rt_copy(a::SName) = error("internal error: The name $a leaked through. Please report this.")
rt_copy_allow_tuple(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_copy(a::Int) = a
rt_copy_allow_tuple(a::Int) = a

rt_copy(a::BigInt) = a
rt_copy_allow_tuple(a::BigInt) = a

rt_copy(a::SString) = a
rt_copy_allow_tuple(a::SString) = a

rt_copy(a::Vector{Int}) = SIntVec(deepcopy(a))
rt_copy(a::SIntVec) = a
rt_copy_allow_tuple(a::Vector{Int}) = SIntVec(deepcopy(a))
rt_copy_allow_tuple(a::SIntVec) = a

rt_copy(a::Array{Int, 2}) = SIntMat(deepcopy(a))
rt_copy(a::SIntMat) = a
rt_copy_allow_tuple(a::Array{Int, 2}) = SIntMat(deepcopy(a))
rt_copy_allow_tuple(a::SIntMat) = a

rt_copy(a::Array{BigInt, 2}) = SBigIntMat(deepcopy(a))
rt_copy(a::SBigIntMat) = a
rt_copy_allow_tuple(a::Array{BigInt, 2}) = SBigIntMat(deepcopy(a))
rt_copy_allow_tuple(a::SBigIntMat) = a

rt_copy(a::SListData) = SList(deepcopy(a))
rt_copy(a::SList) = a
rt_copy_allow_tuple(a::SListData) = SList(deepcopy(a))
rt_copy_allow_tuple(a::SList) = a

rt_copy(a::SRing) = a
rt_copy_allow_tuple(a::SRing) = a

rt_copy(a::SNumber) = a
rt_copy_allow_tuple(a::SNumber) = a

rt_copy(a::SPoly) = a
rt_copy_allow_tuple(a::SPoly) = a

rt_copy(a::SIdealData) = SIdeal(deepcopy(a))
rt_copy(a::SIdeal) = a
rt_copy_allow_tuple(a::SIdealData) = SIdeal(deepcopy(a))
rt_copy_allow_tuple(a::SIdeal) = a

rt_copy(a::Tuple{Vararg{Any}}) = error("internal error: The tuple $a leaked through. Please report this.")
rt_copy_allow_tuple(a::Tuple{Vararg{Any}}) = a



# copiers returning non SingularType, usually so that we can mutate it
# only used internally for convenience by the runtime, and should not be output by transpiler

rt_edit(a::Vector{Int}) = deepcopy(a)
rt_edit(a::SIntVec) = a.vector

rt_edit(a::Array{Int, 2}) = deepcopy(a)
rt_edit(a::SIntMat) = a.matrix

rt_edit(a::Array{BigInt, 2}) = deepcopy(a)
rt_edit(a::SBigIntMat) = a.matrix

rt_edit(a::SListData) = deepcopy(a)
rt_edit(a::SList) = a.list

# get the underlying mutable type if it exists

rt_ref(a::Nothing) = a

rt_ref(a::SProc) = a

rt_ref(a::SName) = error("internal error: The name $a leaked through. Please report this.")

rt_ref(a::Int) = a

rt_ref(a::BigInt) = a

rt_ref(a::SString) = a

rt_ref(a::Vector{Int}) = a
rt_ref(a::SIntVec) = a.vector

rt_ref(a::Array{Int, 2}) = a
rt_ref(a::SIntMat) = a.matrix

rt_ref(a::Array{BigInt, 2}) = a
rt_ref(a::SBigIntMat) = a.matrix

rt_ref(a::SListData) = a
rt_ref(a::SList) = a.list

rt_ref(a::SRing) = a

rt_ref(a::SPoly) = a

rt_ref(a::SIdealData) = a
rt_ref(a::SIdeal) = a.ideal


########### messages ##########################################################

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


########### declarers and default constructors ################################
# each type T has a
#   rt_parameter_T:          used for putting the arguments of a proc into the new scope
#   rt_declare_T:            may print a warning/error on redeclaration
#   rt_defaultconstructor_T: cannot fail

function is_valid_newstruct_member(s::String)
    if match(r"^[a-zA-Z][a-zA-Z0-9]*$", s) == nothing
        return false
    else
        return true
    end
end

function rt_declare_warnerror(allow_warn::Bool, old_value::Any, x::Symbol, t)
    if old_value isa t
        if allow_warn
            rt_warn("redeclaration of " * rt_typestring(old_value) * " " * string(x))
        else
            rt_error("redeclaration of " * rt_typestring(old_value) * " " * string(x))
        end
    else
        rt_error("identifier " * string(x) * " in use as a " * rt_typestring(old_value))
    end
end

function rt_check_declaration_local(rindep::Bool, a::Symbol, typ)
    found, i = rt_search_callstack_rindep(a)
    !found || rt_declare_warnerror(rindep, rtGlobal.local_rindep_vars[i].second, a, typ)
    found, i = rt_search_callstack_rdep(a)
    !found || rt_declare_warnerror(!rindep, rtGlobal.local_rdep_vars[i].second, a, typ)
end

# supposed to return a Dict{Symbol, Any} where we can store the variable
function rt_check_declaration_global(rindep::Bool, a::Symbol, typ)
    n = length(rtGlobal.callstack)
    p = rtGlobal.callstack[n].current_package
    if rindep
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a)
                rt_declare_warnerror(rindep, d[a], a, typ)
            end
            return d
        else
            # uncommon (impossible?) case where the current package does not have an entry in rtGlobal.vars
            d = Dict{Symbol, Any}()
            rtGlobal.vars[p] = d
            return d
        end
    else
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a)
                rt_declare_warnerror(rindep, d[a], a, typ)
            end
        end
        d = rtGlobal.callstack[n].current_ring.vars
        if haskey(d, a)
            rt_declare_warnerror(!rindep, d, a, typ)
        end
        return d
    end
end

function rt_local_identifier_does_not_exist(a::Symbol)
    return length(rtGlobal.callstack) > 1 &&
            !(rt_search_callstack_rindep(a)[1]) &&
            !(rt_search_callstack_rdep(a)[1])
end

#### def

function rt_defaultconstructor_def()
    return nothing
end

function rt_declare_def(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, Any)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_def()))
    else
        d = rt_check_declaration_global(true, a.name, Any)
        d[a.name] = rt_defaultconstructor_def()
    end
end

function rt_parameter_def(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2def(b)))
end

#### proc
function rt_empty_proc(v...) # only used by rt_defaultconstructor_proc
    rt_error("cannot call empty proc")
end

function rt_defaultconstructor_proc()
    return SProc(rt_empty_proc, "empty proc", :Top)
end

function rt_declare_proc(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SProc)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_proc()))
    else
        d = rt_check_declaration_global(true, a.name, SProc)
        d[a.name] = rt_defaultconstructor_proc()
    end
end

function rt_parameter_proc(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2proc(b)))
end

#### int
function rt_defaultconstructor_int()
    return Int(0)
end

function rt_declare_int(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, Int)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_int()))
    else
        d = rt_check_declaration_global(true, a.name, Int)
        d[a.name] = rt_defaultconstructor_int()
    end
end

function rt_parameter_int(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2int(b)))
end

#### bigint
function rt_defaultconstructor_bigint()
    return BigInt(0)
end

function rt_declare_bigint(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, BigInt)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_bigint()))
    else
        d = rt_check_declaration_global(true, a.name, BigInt)
        d[a.name] = rt_defaultconstructor_bigint()
    end
end

function rt_parameter_bigint(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2bigint(b)))
end

#### string
function rt_defaultconstructor_string()
    return SString("")
end

function rt_declare_string(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SString)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_string()))
    else
        d = rt_check_declaration_global(true, a.name, SString)
        d[a.name] = rt_defaultconstructor_string()
    end
end

function rt_parameter_string(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2string(b)))
end

#### intvec
function rt_defaultconstructor_intvec()
    return SIntVec(Int[])
end

function rt_declare_intvec(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SIntVec)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_intvec()))
    else
        d = rt_check_declaration_global(true, a.name, SIntVec)
        d[a.name] = rt_defaultconstructor_intvec()
    end
end

function rt_parameter_intvec(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2intvec(b)))
end

#### intmat
function rt_defaultconstructor_intmat()
    return SBigIntMat(zeros(Int, 1, 1))
end

function rt_declare_intmat(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SIntMat)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_intmat()))
    else
        d = rt_check_declaration_global(true, a.name, SIntMat)
        d[a.name] = rt_defaultconstructor_intmat()
    end
end

function rt_parameter_intmat(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2intmat(b)))
end

#### bigintmat
function rt_defaultconstructor_bigintmat()
    return SBigIntMat(zeros(BigInt, 1, 1))
end

function rt_declare_bigintmat(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SBigIntMat)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_bigintmat()))
    else
        d = rt_check_declaration_global(true, a.name, SBigIntMat)
        d[a.name] = rt_defaultconstructor_bigintmat()
    end
    return nothing
end

function rt_parameter_bigintmat(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2bigintmat(b)))
end

#### list
function rt_defaultconstructor_list()
    return SList(SListData(Any[]))
end

function rt_declare_list(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SList)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_defaultconstructor_list()))
    else
        d = rt_check_declaration_global(true, a.name, SList)
        d[a.name] = rt_defaultconstructor_list()
    end
    return nothing
end

function rt_parameter_list(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rindep_vars, Pair(a.name, rt_convert2list(b)))
end

#### number
function rt_defaultconstructor_number()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a number when no basering is active")
    r1 = libSingular.n_Init(0, R.ring_ptr)
    return SNumber(r1, R)
end

function rt_declare_number(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(false, a.name, SNumber)
        push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_defaultconstructor_number()))
    else
        d = rt_check_declaration_global(false, a.name, SNumber)
        d[a.name] = rt_defaultconstructor_number()
    end
    return nothing
end

function rt_parameter_number(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_convert2number(b)))
end

#### poly
function rt_defaultconstructor_poly()
    R = rt_basering()
    @error_check(R.valid, "cannot construct a polynomial when no basering is active")
    r1 = libSingular.p_null_helper()
    return SPoly(r1, R)
end

function rt_declare_poly(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(false, a.name, SPoly)
        push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_defaultconstructor_poly()))
    else
        d = rt_check_declaration_global(false, a.name, SPoly)
        d[a.name] = rt_defaultconstructor_poly()
    end
    return nothing
end

function rt_parameter_poly(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_convert2poly(b)))
end

#### ideal
function rt_defaultconstructor_ideal()
    R = rt_basering()
    @error_check(R.valid, "cannot construct an ideal when no basering is active")
    id = libSingular.idInit(1,1)
    libSingular.setindex_internal(id, libSingular.p_null_helper(), 0)
    return SIdeal(SIdealData(id, R))
end

function rt_declare_ideal(a::SName)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(false, a.name, SIdeal)
        push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_defaultconstructor_ideal()))
    else
        d = rt_check_declaration_global(false, a.name, SIdeal)
        d[a.name] = rt_defaultconstructor_ideal()
    end
    return nothing
end

function rt_parameter_ideal(a::SName, b)
    @assert rt_local_identifier_does_not_exist(a.name)
    push!(rtGlobal.local_rdep_vars, Pair(a.name, rt_convert2ideal(b)))
end



########### type conversions ##################################################
# each rt_convert2T returns an object of type T, usually for an assignment
# each rt_cast2T is used when the type name T is used as a function, i.e. string(1)

# Singular maintains bools as ints, julia needs real bools for control flow

function rt_asbool(a::Int)
    return a != 0
end

function rt_asbool(a)
    rt_error("expected int for boolean expression")
    return false
end

#### def

function rt_convert2def(a)
    return rt_copy(a)
end

function rt_convert2def(a...)
    rt_error("cannot convert $a to a def")
    return a
end


#### proc

function rt_convert2proc(a::SProc)
    return a
end

function rt_convert2proc(a...)
    rt_error("cannot convert $a to a proc")
    return defaultconstructor_proc()
end

#### int

function rt_convert2int(a::Int)
    return a
end

function rt_convert2int(a::BigInt)
    return Int(a)   # will throw if BigInt -> Int conversion fails
end

function rt_convert2int(a...)
    rt_error("cannot convert $a to an int")
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

function rt_convert2bigint(a...)
    rt_error("cannot convert $a to a bigint")
    return BigInt(0)
end

const rt_cast2bigint = rt_convert2bigint

#### string

function rt_convert2string(a::SString)
    return a
end

function rt_convert2string(a...)
    rt_error("cannot convert $a to a string")
    return SString("")
end

function rt_cast2string(a::Int)
    return SString(string(a))
end

function rt_cast2string(a::SProc)
    return SString("proc "*string(a.name)) #TODO low priority: this is not how singular prints procs
end

function rt_cast2string(a...)
    error("cannot cast $a to a string")
    return SString("")
end

#### intvec

function rt_convert2intvec(a::SIntVec)
    return a
end

function rt_convert2intvec(a::Array{Int})
    return SIntVec(deepcopy(a))
end

function rt_convert2intvec(a::Tuple{Vararg{Any}})
    v = Int[]
    for i in a
        if i isa SIntVec
            append!(v, i.vector)
        else
            push!(v, rt_convert2int(i))
        end
    end
    return SIntVec(v)
end

function rt_convert2intvec(a)
    rt_error("cannot convert to intvec")
    return SIntVec(Int[])
end

#### intmat

function rt_convert2intmat(a::SIntMat)
    return a
end

function rt_convert2intmat(a::Array{Int, 2})
    return SIntMat(deepcopy(a))
end

function rt_convert2intmat(a::Tuple{Vararg{Any}}, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(Int, nrows, ncols)
    row_idx = col_idx = 1
    for i in a
        mat[row_idx, col_idx] = rt_convert2int(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SIntMat(mat)
end

function rt_convert2intmat(a::_List, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(Int, nrows, ncols)
    row_idx = col_idx = 1
    for i in rtef(a).list.data
        mat[row_idx, col_idx] = rt_convert2int(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SIntMat(mat)
end

#### bigintmat

function rt_convert2bigintmat(a::SBigIntMat)
    return a
end

function rt_convert2bigintmat(a::Array{BigInt, 2})
    return SBigIntMat(deepcopy(a))
end

function rt_convert2bigintmat(a::Tuple{Vararg{Any}}, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(BigInt, nrows, ncols)
    row_idx = col_idx = 1
    for i in a
        mat[row_idx, col_idx] = rt_convert2bigint(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SBigIntMat(mat)
end

function rt_convert2bigintmat(a::_List, nrows::Int, ncols::Int)
    if nrows <= 0 || ncols <= 0
        rt_error("nrows and ncols must be positive")
    end
    mat = zeros(BigInt, nrows, ncols)
    row_idx = col_idx = 1
    for i in rtef(a).data
        mat[row_idx, col_idx] = i
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SBigIntMat(mat)
end

#### list

function rt_convert2list(a::SList)
    return a
end

function rt_convert2list(a::SListData)
    return SList(deepcopy(a))
end

function rt_convert2list(a::Tuple{Vararg{Any}})
    return SList(SListData(collect(a)))
end

function rt_convert2list(a)
    rt_error("cannot convert $a to a list")
    return SList(SListData(Any[]))
end

function rt_cast2list(a...)
    return SList(SListData([rt_copy(i) for i in a]))
end

#### number

function rt_convert2number(a::SNumber)
    return a
end

function rt_convert2number(a::Union{Int, BigInt})
    rtGlobal.currentring.valid || rt_error("cannot convert to a number when no basering is active")
    r1 = libSingular.n_Init(a.number_ptr, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rt_convert2number(a)
    rt_error("cannot convert $a to a number")
    return rt_defaultconstructor_number()
end

#### poly

# return a new libSingular.poly not owned by any instance of a SingularType
function rt_convert2poly_ptr(a::Union{Int, BigInt}, b::SRing)
    @error_check(b.valid, "cannot convert to a polynomial when no basering is active")
    r1 = libSingular.n_Init(a, b.ring_ptr)
    return libSingular.p_NSet(r1, b.ring_ptr)
end

function rt_convert2poly_ptr(a::SNumber, b::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == b.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    r1 = libSingular.n_Copy(a.number_ptr, a.parent.ring_ptr)
    return libSingular.p_NSet(r1, a.parrent.ring_ptr)
end

function rt_convert2poly_ptr(a::SPoly, b::SRing)
    @error_check(a.parent.ring_ptr.cpp_object == b.ring_ptr.cpp_object, "cannot convert to a polynomial from a different basering")
    return libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
end

function rt_convert2poly_ptr(a, b::SRing)
    rt_error("cannot convert $a to a polynomial")
    return libSingular.p_null_helper()
end

function rt_convert2poly(a::SPoly)
    return a
end

function rt_convert2poly(a::Union{Int, BigInt})
    R = rt_basering()
    r1 = rt_convert2poly_ptr(a, R)
    return SPoly(r1, R)
end

function rt_convert2poly(a::SNumber)
    @warn_check(a.apprent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    return SPoly(r1, a.parent)
end

function rt_convert2poly(a)
    rt_error("cannot convert $a to a polynomial")
    return rt_defaultconstructor_poly()
end


#### ideal

function rt_convert2ideal(a::_Ideal)
    return rt_copy(a)
end

function rt_convert2ideal(a::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "cannot convert to an ideal when no basering is active")
    r1 = rt_convert2poly_ptr(a, R)
    r2 = libSingular.idInit(1, 1)
    libsingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return SIdeal(r2, rtGlobal.currentring)
end

function rt_convert2ideal(a::Union{SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "converting to a polynomial outside of basering")
    r1 = rt_convert2poly_ptr(a, a.parent)
    r2 = libSingular.idInit(1, 1)
    libsingular.setindex_internal(r2, r1, 0) # r1 is consumed
    return SIdeal(r2, rtGlobal.currentring)
end

function rt_convert2ideal(a::Tuple{Vararg{Any}})
    # just convert everything to an ideal and add them up
    # answer must be wrapped in SIdeal at all times because we might throw
    r::SIdeal = rt_defaultconstructor_ideal()
    for i in a
        @error_check(isa(i, Union{Int, BigInt, SNumber, SPoly, SIdeal}), "cannot convert $i to an ideal")
        r = rtplus(r, i)
    end
    return r
end

function rt_convert2ideal(a)
    rt_error("cannot convert $a to an ideal")
    return rt_defaultconstructor_ideal()
end

function rt_cast2ideal(a...)
    return rt_convert2ideal(a)
end

############ printing ##########################################################

function rt_indenting_print(a::Nothing, indent::Int)
    return ""
end

function rt_indenting_print(a::SName, indent::Int)
    return rt_indenting_print(rt_make(a), indent)
end

function rt_indenting_print(a::SProc, indent::Int)
    return " "^indent * "procname: " * string(a.name)
end

function rt_indenting_print(a::Union{Int, BigInt}, indent::Int)
    return " "^indent * string(a)
end

function rt_indenting_print(a::SString, indent::Int)
    return " "^indent * a.string
end

function rt_indenting_print(a::Union{_IntMat, _BigIntMat}, indent::Int)
    s = ""
    A = rtef(a)
    nrows, ncols = size(A)
    for i in 1:nrows
        s *= " "^indent
        for j in 1:ncols
            s *= string(A[i,j])
            if j < ncols
                s *= ", " # TODO low priority: align columns
            end
        end
        if i < nrows
            s *= ",\n"
        end
    end
    return s;
end

function rt_indenting_print(a::SList, indent::Int)
    return rt_indenting_print(rt_ref(a), indent)
end

function rt_indenting_print(a::SListData, indent::Int)
    s = ""
    A = a.data
    for i in 1:length(A)
        s *= " "^indent * "[" * string(i) * "]:\n"
        if A[i] isa Nothing
            continue
        end
        s *= rt_indenting_print(A[i], indent + 3)
        if i < length(A)
            s *= "\n"
        end
    end
    return s
end

function rt_indenting_print(a::SRing, indent::Int)
    s = libSingular.rPrint_helper(a.ring_ptr)
    i = " "^indent
    return i * join(split(s, r"\n|\r|\0"), "\n"*i)
end

function rt_indenting_print(a::SNumber, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a number outside of basering")
    libSingular.StringSetS("")
    libSingular.n_Write(a.number_ptr, a.parent.ring_ptr)
    return " "^indent * libSingular.StringEndS()
end


function rt_indenting_print(a::SPoly, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing a polynomial outside of basering")
    s = libSingular.p_String(a.poly_ptr, a.parent.ring_ptr)
    return " "^indent * s
end

function rt_indenting_print(a::SIdeal, indent::Int)
    return rt_indenting_print(a.ideal, indent)
end

function rt_indenting_print(a::SIdealData, indent::Int)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "printing an ideal outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.ideal_ptr))
    for i in 1:n
        p = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.ring_ptr)
        s *= " "^indent * "[" * string(i) * "]: " * t * (i < n ? "\n" : "")
    end
    return s
end

function rt_indenting_print(a::Tuple{Vararg{Any}}, indent::Int)
    s = ""
    for b in a
        s *= rt_indenting_print(b, indent) * "\n"
    end
    return s
end

# the "print" function in Singular returns a string and does not print
function rtprint(::Nothing)
    return ""
end

function rtprint(a)
    return SString(rt_indenting_print(a, 0))
end

# the semicolon in Singular is the method to actually print something
function rt_printout(::Nothing)
    return  # we will probably be printing nothing often - very important to not print anything in this case
end

function rt_printout(a::SName)
    return rt_printout(rt_make(a))
end

function rt_printout(a)
    rtGlobal.last_printed = rt_copy_allow_tuple(a)
    println(rt_indenting_print(a, 0))
end

function rt_get_last_printed()
    return rtGlobal.last_printed
end

# type ...; will call rt_printouttype
function rt_printouttype(a)
    println("add correct type printing here")
end

########### mutatingish operations #############################################

# the transpiler is set up to not produce names for any arguments of getindex/setindex

#rt_getindex(a::SName, i) = rt_getindex(rt_make(a), i)
#rt_getindex(a::SName, i, j) = rt_getindex(rt_make(a), i, j)
#rt_setindex(a::SName, i, b::SName) = rt_setindex(rt_make(a), i, rt_make(b))
#rt_setindex(a::SName, i, b       ) = rt_setindex(rt_make(a), i,         b )
#rt_setindex(a       , i, b::SName) = rt_setindex(        a , i, rt_make(b))
#rt_setindex(a::SName, i, j, b::SName) = rt_setindex(rt_make(a), i, j, rt_make(b))
#rt_setindex(a::SName, i, j, b       ) = rt_setindex(rt_make(a), i, j,         b )
#rt_setindex(a       , i, j, b::SName) = rt_setindex(        a , i, j, rt_make(b))


# in general the operation of the assignment a = b in Singular depends on the
# values of a and b Therefore, a = b becomes a = rt_assign(a, b)

# The assignment to any variable "a" declared "def" must pass through rt_assign because:
#   (1) The initial value of "a" is nothing
#   (2) The first assignment to "a" with a non-nothing type on the rhs succeeds
#       and essentially determines the type of "a"
#   (3) Future assignments to "a" behave as if "a" had the type in (2)
# Since we don't know if an assignment is the first or not - and even if we did,
# we don't know the type of the rhs - all of this type checking is done by rt_assign

function rtassign(a::SName, b)

    # local ring independent
    ok, i = rt_search_callstack_rindep(a.name)
    if ok
        l = rtGlobal.local_rindep_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, b))
        return
    end

    # local ring dependent
    ok, i = rt_search_callstack_rdep(a.name)
    if ok
        l = rtGlobal.local_rdep_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, b))
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                d[a.name] = rt_assign(d[a.name], b)
                return
            end        
        end
    end

    # global ring dependent
    d = rtGlobal.callstack[end].current_ring.vars
    if haskey(d, a.name)
        d[a.name] = rt_assign(d[a.name], b)
        return
    end

    rt_error("cannot assign to " * String(a.name))
end

function rt_incrementby(a::SName, b::Int)

    # local ring independent
    ok, i = rt_search_callstack_rindep(a.name)
    if ok
        l = rtGlobal.local_rindep_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, rtplus(l[i].second, b)))
        return
    end

    # local ring dependent
    ok, i = rt_search_callstack_rdep(a.name)
    if ok
        l = rtGlobal.local_rdep_vars
        l[i] = Pair(l[i].first, rt_assign(l[i].second, rtplus(l[i].second, b)))
        return
    end

    # global ring independent
    for p in (rtGlobal.callstack[end].current_package, :Top)
        if haskey(rtGlobal.vars, p)
            d = rtGlobal.vars[p]
            if haskey(d, a.name)
                d[a.name] = rt_assign(d[a.name], rtplus(d[a.name], b))
                return
            end        
        end
    end

    # global ring dependent
    d = rtGlobal.callstack[end].current_ring.vars
    if haskey(d, a.name)
        d[a.name] = rt_assign(d[a.name], rtplus(d[a.name], b))
        return
    end

    rt_error("cannot increment/decrement " * String(a.name))
end



#### assignment to nothing - used for the first set of a variable of type def
function rt_assign(a::Nothing, b)
    return rt_copy(b)
end

#### assignment to proc
function rt_assign(a::SProc, b)
    return rt_convert2proc(b)
end

#### assignment to int
function rt_assign(a::Int, b)
    return rt_convert2int(b)
end

#### assignment to bigint
function rt_assign(a::BigInt, b)
    return rt_convert2bigint(b)
end

#### assignment to string
function rt_assign(a::SString, b)
    return rt_convert2string(b)
end

#### assignment to intmat
function rt_assign(a::_IntMat, b::_IntMat)
    return rt_copy(b)
end

function rt_assign(a::_IntMat, b::Tuple{Vararg{Any}})
    A = rt_edit(a)
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    for i in b
        A[row_idx, col_idx] = rt_convert2int(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SIntMat(A)
end

function rt_assign(a::_IntMat, b)
    rt_error("cannot assign $b to intmat")
end

#### assignment to bigintmat
function rt_assign(a::_BigIntMat, b::_BigIntMat)
    return rt_copy(b)
end

function rt_assign(a::_BigIntMat, b::Tuple{Vararg{Any}})
    A = rt_edit(a)
    nrows, ncols = size(A)
    row_idx = col_idx = 1
    for i in b
        A[row_idx, col_idx] = rt_convert2bigint(i)
        col_idx += 1
        if col_idx > ncols
            col_idx = 1
            row_idx += 1
            if row_idx > nrows
                break
            end
        end
    end
    return SBigIntMat(A)
end

function rt_assign(a::_BigIntMat, b)
    rt_error("cannot assign $b to bigintmat")
end

#### assignment to list
function rt_assign(a::_List, b::_List)
    return rt_copy(b)
end

function rt_assign(a::_List, b)
    return rt_convert2list(b)
end

#### assignment to poly
function rt_assign(a::SPoly, b)
    return rt_convert2poly(b)
end

#### assignment to ideal
function rt_assign(a::SIdeal, b)
    return rt_convert2ideal(b)
end


function rt_getindex(a::_IntVec, i::Int)
    return rt_ref(a)[i]
end

function rt_setindex(a::_IntVec, i::Int, b)
    rt_ref(a)[i] = rt_copy(b)
    return nothing
end


function rt_getindex(a::_BigIntMat, i::Int, j::Int)
    return rt_ref(a)[i, j]
end


function rt_setindex(a::_BigIntMat, i::Int, j::Int, b)
    rt_ref(a)[i, j] = rt_copy(b)
    return nothing
end


function rt_getindex(a::_List, i::Int)
    return rt_ref(rt_ref(a).data[i])
end

function rt_getindex(a::SIdeal, i::Int)
    return rt_getindex(a.ideal, i)
end

function rt_getindex(a::SIdealData, i::Int)
    n = Int(libSingular.ngens(a.ideal_ptr))
    1 <= i <= n || rt_error("ideal index out of range")
    r1 = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
    r2 = libSingular.p_Copy(r1, a.parent.ring_ptr)
    return SIdeal(SIdealData(r2, a.parent))
end

function rt_setindex(a::SIdeal, i::Int, b)
    return rt_setindex(a.ideal, i, b)
end

function rt_setindex(a::SIdealData, i::Int, b)
    n = Int(libSingular.ngens(a.ideal_ptr))
    1 <= i <= n || rt_error("ideal index out of range")
    b1 = rt_convert2poly_ptr(b, a.parent)
    p0 = libSingular.getindex(a.ideal_ptr, Cint(i - 1))
    if p0 != C_NULL
        libSingular.p_Delete(p0, a.parent.ring_ptr)
    end
    libSingular.setindex_internal(a.ideal_ptr, b1, Cint(i - 1))
    return nothing
end


function rt_setindex(a::SListData, i::Int, b)
    bcopy = rt_copy(b) # copy before the possible resize
    r = a.data
    if bcopy == nothing
        if i < length(r)
            r[i] = nothing
        # putting nothing at the end pops the list
        elseif i == length(r)
            pop!(r)
        end
    else
        # nothing fills out a list when we assign past the end
        org_len = length(r)
        if i > org_len
            resize!(r, i)
            while org_len + 1 < i
                r[org_len + 1] = nothing
                org_len += 1
            end
        end
        r[i] = bcopy
    end
    return nothing
end


function rt_setindex(a::SList, i::Int, b)
    return rt_setindex(rt_ref(a), i, b)
end


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




#####################################################




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

################ tuples ########################################################
#
# all splatting is done (hopefully!) at transpile time
#function rt_maketuple(v...)
#    g = (x isa Tuple ? x : (x,) for x in v)
#    r = tuple(Iterators.flatten(g)...)
#    return r
#end

function rt_checktuplelength(a::Tuple{Vararg{Any}}, n::Int)
    if length(a) != n
        rt_error("expected " * string(n) * " arguments in expression list; got " * string(length(a)))
    end
end


########### operations ##############################################

rt_typedata(::Nothing)     = "none"
rt_typedata(::SProc)       = "proc"
rt_typedata(::Int)         = "int"
rt_typedata(::BigInt)      = "bigint"
rt_typedata(::SString)     = "string"
rt_typedata(::_IntVec)     = "intvec"
rt_typedata(::_IntMat)     = "intmat"
rt_typedata(::_BigIntMat)  = "bigintmat"
rt_typedata(::_List)       = "list"
rt_typedata(::SRing)       = "ring"
rt_typedata(::SNumber)     = "number"
rt_typedata(::SPoly)       = "poly"
rt_typedata(::_Ideal)      = "ideal"
rt_typedata(a::Tuple{Vararg{Any}}) = String[rt_typeof(i) for i in a]

rt_typedata_to_singular(a::String) = SString(a)
rt_typedata_to_singular(a::Array{String}) = Tuple([SString(a) for i in a])

rt_typedata_to_string(a::String) = a
rt_typedata_to_string(a::Array{String}) = join(a, ", ")

rttypeof(a::SName) = rttypeof(rt_make(a))
rttypeof(a) = rt_typedata_to_singular(rt_typedata(a))

rt_typestring(a) = rt_typedata_to_string(rt_typedata(a))

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


# TODO instead of having stupid stuff like the following 3 methods, compile a list
# of commands (CMD) that never take a name as an argument and call rt_make in
# the transpiler in those cases
rtplus(a::SName, b::SName) = rtplus(rt_make(a), rt_make(b))
rtplus(a::SName, b) = rtplus(rt_make(a), b)
rtplus(a, b::SName) = rtplus(a, rt_make(b))

function rtplus(a::_List, b::_List)
    return SList(SListData(vcat(rt_edit(a).data, rt_edit(b).data)))
end


# op(int, int)

rtplus(a::Int, b::Int) = Base.checked_add(a, b)
rtplus(a::Int, b::BigInt) = a + b
rtplus(a::BigInt, b::Int) = a + b
rtplus(a::BigInt, b::BigInt) = a + b

rtminus(a::Int) = Base.checked_neg(a)
rtminus(a::BigInt) = -a

rtminus(a::Int, b::Int) = Base.checked_sub(a, b)
rtminus(a::Int, b::BigInt) = a - b
rtminus(a::BigInt, b::Int) = a - b
rtminus(a::BigInt, b::BigInt) = a - b

rttimes(a::Int, b::Int) = Base.checked_mul(a, b)
rttimes(a::Int, b::BigInt) = a * b
rttimes(a::BigInt, b::Int) = a * b
rttimes(a::BigInt, b::BigInt) = a * b

# op(number, number)

function rtplus(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    r1 = libSingular.n_Add(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rtGlobal.currentring.ring_ptr.cpp_object, "negating outside of basering")
    r1 = libSingular.n_Neg(a.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    r1 = libSingular.n_Sub(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.n_Mult(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(poly, poly)

function rtplus(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.p_Copy(b.poly_ptr, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly)
    rt_warn(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "negating outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    r1 = libSingular.p_Neg(a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.p_Copy(b.poly_ptr, b.parent.ring_ptr)
    r1 = libSingular.p_Sub_q(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.pp_Mult_qq(a.poly_ptr, b.poly_ptr, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(ideal, ideal)

function rtplus(a::_Ideal, b::_Ideal)
    A::SIdealData = rt_ref(a)
    B::SIdealData = rt_ref(b)
    @error_check(A.parent.ring_ptr.cpp_object == B.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(A.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    r1 = libSingular.id_Add(A.ideal_ptr, B.ideal_ptr, A.parent.ring_ptr)
    return SIdeal(SIdealData(r1, a.parent))
end

function rtminus(a::_Ideal)
    return rttimes(a, -1)
end

function rtminus(a::_Ideal, b::_Ideal)
    rt_error("cannot subtract ideals")
    return rt_defaultconstructor_ideal()
end

function rttimes(a::_Ideal, b::_Ideal)
    A::SIdealData = rt_ref(a)
    B::SIdealData = rt_ref(b)
    @error_check(A.parent.ring_ptr.cpp_object == B.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(A.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    r1 = libSingular.id_Mult(A.ideal_ptr, B.ideal_ptr, A.parent.ring_ptr)
    return SIdeal(SIdealData(r1, A.parent))
end

# op(ideal, number|poly)

function rtplus(a::SIdeal, b::Union{BigInt, Int, SNumber, SPoly})
    return rtplus(a.ideal, b)
end

function rtplus(a::SIdealData, b::Union{BigInt, Int, SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Add(a.ideal_ptr, b2, a.parent.ring_ptr)
    libSingular.id_Delete(b2, a.parent.ring_ptr) # id_Add did not consume b2
    return SIdeal(SIdealData(r1, a.parent))
end

function rttimes(a::SIdeal, b::Union{BigInt, Int, SNumber, SPoly})
    return rttime(a.ideal, b)
end

function rttimes(a::SIdealData, b::Union{BigInt, Int, SNumber, SPoly})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = rt_convert2poly_ptr(b, a.parent)
    b2 = libSingular.idInit(1,1)
    libSingular.setindex_internal(b2, b1, 0) # b1 is consumed
    r1 = libSingular.id_Mult(a.ideal_ptr, b2, a.parent.ring_ptr)
    libSingular.id_Delete(b2, a.parent.ring_ptr) # id_Mult did not consume b2
    return SIdeal(SIdealData(r1, a.parent))
end


# op(number, int)

function rtplus(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Add(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Sub(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Mult(a.number_ptr, b1, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(int, number)

function rtplus(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Add(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Sub(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::SNumber)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    r1 = libSingular.n_Mult(b1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

# op(poly, int)

function rtplus(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Sub_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(poly, number)

function rtplus(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Sub_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(a::SPoly, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(a1, b2, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(int, poly)

function rtplus(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Sub_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(b::Union{Int, BigInt}, a::SPoly)
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, a.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

# op(number, poly)

function rtplus(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot add from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "adding outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Add_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtminus(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot subtract from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "subtracting from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Sub_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rttimes(b::SNumber, a::SPoly)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot multiply from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "multiplying from outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = libSingular.n_Copy(b.number_ptr, b.parent.ring_ptr)
    b2 = libSingular.p_NSet(b1, b.parent.ring_ptr)
    r1 = libSingular.p_Mult_q(b2, a1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end




function rtplus(a::Tuple{Vararg{Any}}, b)
    return Tuple(i == 1 ? rtplus(a[i], b) : a[i] for i in 1:length(a));
end

function rtplus(a, b::Tuple{Vararg{Any}})
    return Tuple(i == 1 ? rtplus(a, b[i]) : b[i] for i in 1:length(b));
end

function rtplus(a::Tuple{Vararg{Any}}, b::Tuple{Vararg{Any}})
    return Tuple(rtplus(a[i], b[i]) for i in 1:min(length(a), length(b)));
end

function rtplus(a::_IntVec, b::_IntVec)
    A = rt_ref(a)
    B = rt_ref(b)
    return SIntVec([Base.checked_add(i <= length(A) ? A[i] : 0,
                                     i <= length(B) ? B[i] : 0)
                                   for i in 1:max(length(A), length(B))])
end

function rtplus(a::_IntVec, b::Int)
    A = rtef(a)
    return SIntVec([rtplus(A[i], b) for i in 1:length(A)])
end

function rtplus(a::Int, b::_IntVec)
    B = rt_ref(b)
    return SIntVec([rtplus(a, B[i]) for i in 1:length(B)])
end

function rtplus(a::_IntMat, b::Int)
    A = rt_edit(a)
    nrows, ncols = size(A)
    for i in 1:min(nrows, ncols)
        A[i, i] = rtplus(A[i, i], b)
    end
    return SIntMat(A)
end

function rtplus(a::Int, b::_IntMat)
    B = rt_edit(b)
    nrows, ncols = size(B)
    for i in 1:min(nrows, ncols)
        B[i, i] = rtplus(a, B[i, i])
    end
    return SIntMat(B)
end

function rtplus(a::_IntMat, b::_IntMat)
    return SIntMat(rt_ref(a) + rt_ref(b))
end

function rtplus(a::SString, b::SString)
    return SString(a.string * b.string)
end


rtminus(a::SName) = rtminus(rt_make(a))

rtminus(a::SName, b::SName) = rtminus(rt_make(a), rt_make(b))
rtminus(a::SName, b) = rtminus(rt_make(a), b)
rtminus(a, b::SName) = rtminus(a, rt_make(b))


rttimes(a::SName, b::SName) = rttimes(rt_make(a), rt_make(b))
rttimes(a::SName, b) = rttimes(rt_make(a), b)
rttimes(a, b::SName) = rttimes(a, rt_make(b))

function stimes(a::_BigIntMat, b::_BigIntMat)
    return SBigIntMat(rt_ref(a) * rt_ref(b))
end

function stimes(a::Int, b::_BigIntMat)
    return SBigIntMat(a*rt_ref(b))
end


rtpower(a::SName, b::SName) = rtpower(rt_make(a), rt_make(b))
rtpower(a::SName, b) = rtpower(rt_make(a), b)
rtpower(a, b::SName) = rtpower(a, rt_make(b))

rtpower(a::Int, b::Int) = a ^ b
rtpower(a::Int, b::BigInt) = a ^ b
rtpower(a::BigInt, b::Int) = a ^ b
rtpower(a::BigInt, b::BigInt) = a ^ b

function rtpower(a::SNumber, b::Int)
    absb = abs(b)
    @error_check(absb <= typemax(Cint), "number power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    if b < 0
        @error_check(!libSingular.n_IsZero(a.number_ptr, a.parent.ring_ptr), "cannot divide by zero")
        ai = libSingular.n_Invers(a.number_ptr, a.parent.ring_ptr)
        r1 = libSingular.n_Power(ai, Cint(absb), a.parent.ring_ptr)
        libSingular.n_Delete(ai, a.parent.ring_ptr)
    else
        r1 = libSingular.n_Power(a.number_ptr, Cint(absb), a.parent.ring_ptr)
    end
    return SNumber(r1, a.parent)
end

function rtpower(a::SPoly, b::Int)
    @error_check(0 <= b <= typemax(Cint), "polynomial power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    a1 = libSingular.p_Copy(a.poly_ptr, a.parent.ring_ptr)
    b1 = Cint(b)
    r1 = libSingular.p_Power(a1, b1, a.parent.ring_ptr)
    return SPoly(r1, a.parent)
end

function rtpower(a::SIdeal, b::Int)
    return rtpower(a.ideal, b)
end

function rtpower(a::SIdealData, b::Int)
    @error_check(0 <= b <= typemax(Cint), "ideal power is out of range")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "powering outside of basering")
    r1 = libSingular.id_Power(a.ideal_ptr, Cint(b), a.parent.ring_ptr)
    return SIdeal(SIdealData(r1, a.parent))
end


# SINGULAR  JULIA
# a/b       rtdivide(a, b)
# a / b     rtdivide(a, b)
# a div b   rtdiv(a, b)

rtdivide(a::SName, b::SName) = rtdivide(rt_make(a), rt_make(b))
rtdivide(a::SName, b) = rtdivide(rt_make(a), b)
rtdivide(a, b::SName) = rtdivide(a, rt_make(b))

function rtdivide(a::Union{Int, BigInt}, b::Union{Int, BigInt})
    R = rt_basering()
    @error_check(R.valid, "integer division using `/` without a basering; use `div` instead")
    b1 = libSingular.n_Init(b, R.ring_ptr)
    if libSingular.n_IsZero(b1, R.ring_ptr)
        libSingular.n_Delete(b1, R.ring_ptr)
        rt_error("cannot divide be zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, R.ring_ptr)
    r1 = libSingular.n_Div(a1, b1, R.ring_ptr)
    libSingular.n_Delete(a1, R.ring_ptr)
    libSingular.n_Delete(b1, R.ring_ptr)
    return SNumber(r1, R)
end

function rtdivide(a::Union{Int, BigInt}, b::SNumber)
    @warn_check(b.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    if libSingular.n_IsZero(b.number_ptr, b.parent.ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    a1 = libSingular.n_Init(a, b.parent.ring_ptr)
    r1 = libSingular.n_Div(a1, b.number_ptr, b.parent.ring_ptr)
    libSingular.n_Delete(a1, b.parent.ring_ptr)
    return SNumber(r1, b.parent)
end

function rtdivide(a::SNumber, b::Union{Int, BigInt})
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    b1 = libSingular.n_Init(b, a.parent.ring_ptr)
    if libSingular.n_IsZero(b1, rt_basering().ring_ptr)
        libSingular.n_Delete(b1, rt_basering().ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a1, a.number_ptr, a.parent.ring_ptr)
    libSingular.n_Delete(b1, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end

function rtdivide(a::SNumber, b::SNumber)
    @error_check(a.parent.ring_ptr.cpp_object == b.parent.ring_ptr.cpp_object, "cannot divide from different basering")
    @warn_check(a.parent.ring_ptr.cpp_object == rt_basering().ring_ptr.cpp_object, "dividing outside of basering")
    if libSingular.n_IsZero(b.number_ptr, b.parent.ring_ptr)
        rt_error("cannot divide by zero")
        return rt_defaultconstructor_number()
    end
    r1 = libSingular.n_Div(a.number_ptr, b.number_ptr, a.parent.ring_ptr)
    return SNumber(r1, a.parent)
end


rtdiv(a::SName, b::SName) = rtdiv(rt_make(a), rt_make(b))
rtdiv(a::SName, b) = rtdiv(rt_make(a), b)
rtdiv(a, b::SName) = rtdiv(a, rt_make(b))

rtdiv(a::Int, b::Int) = Base.checked_div(a, b)
rtdiv(a::Int, b::BigInt) = div(a, b)
rtdiv(a::BigInt, b::Int) = div(a, b)
rtdiv(a::BigInt, b::BigInt) = div(a, b)


rtmod(a::SName, b::SName) = rtmod(rt_make(a), rt_make(b))
rtmod(a::SName, b) = rtmod(rt_make(a), b)
rtmod(a, b::SName) = rtmod(a, rt_make(b))

rtmod(a::Int, b::Int) = Base.checked_mod(a, b)
rtmod(a::Int, b::BigInt) = mod(a, b)
rtmod(a::BigInt, b::Int) = mod(a, b)
rtmod(a::BigInt, b::BigInt) = mod(a, b)


rtequalequal(a::SName, b::SName) = rtequalequal(rt_make(a), rt_make(b))
rtequalequal(a::SName, b) = rtequalequal(rt_make(a), b)
rtequalequal(a, b::SName) = rtequalequal(a, rt_make(b))

rtequalequal(a::Int, b::Int) = Int(a == b)
rtequalequal(a::Int, b::BigInt) = Int(a == b)
rtequalequal(a::BigInt, b::Int) = Int(a == b)
rtequalequal(a::BigInt, b::BigInt) = Int(a == b)
rtequalequal(a::SString, b::SString) = Int(a == b)


rtless(a::SName, b::SName) = rtless(rt_make(a), rt_make(b))
rtless(a::SName, b) = rtless(rt_make(a), b)
rtless(a, b::SName) = rtless(a, rt_make(b))

rtless(a::Int, b::Int) = Int(a < b)
rtless(a::Int, b::BigInt) = Int(a < b)
rtless(a::BigInt, b::Int) = Int(a < b)
rtless(a::BigInt, b::BigInt) = Int(a < b)


rtlessequal(a::SName, b::SName) = rtlessequal(rt_make(a), rt_make(b))
rtlessequal(a::SName, b) = rtlessequal(rt_make(a), b)
rtlessequal(a, b::SName) = rtlessequal(a, rt_make(b))

rtlessequal(a::Int, b::Int) = Int(a <= b)
rtlessequal(a::Int, b::BigInt) = Int(a <= b)
rtlessequal(a::BigInt, b::Int) = Int(a <= b)
rtlessequal(a::BigInt, b::BigInt) = Int(a <= b)


rtgreater(a::SName, b::SName) = rtgreater(rt_make(a), rt_make(b))
rtgreater(a::SName, b) = rtgreater(rt_make(a), b)
rtgreater(a, b::SName) = rtgreater(a, rt_make(b))

rtgreater(a::Int, b::Int) = Int(a > b)
rtgreater(a::Int, b::BigInt) = Int(a > b)
rtgreater(a::BigInt, b::Int) = Int(a > b)
rtgreater(a::BigInt, b::BigInt) = Int(a > b)


rtgreaterequal(a::SName, b::SName) = rtgreaterequal(rt_make(a), rt_make(b))
rtgreaterequal(a::SName, b) = rtgreaterequal(rt_make(a), b)
rtgreaterequal(a, b::SName) = rtgreaterequal(a, rt_make(b))

rtgreaterequal(a::Int, b::Int) = Int(a >= b)
rtgreaterequal(a::Int, b::BigInt) = Int(a >= b)
rtgreaterequal(a::BigInt, b::Int) = Int(a >= b)
rtgreaterequal(a::BigInt, b::BigInt) = Int(a >= b)










rtnewstruct(a::SName, b) = rtnewstruct(rt_make(a), b)
rtnewstruct(a, b::SName) = rtnewstruct(a, rt_make(b))

function rtnewstruct(a::SString, b::SString)
    @error_check(!haskey(rtGlobal_NewStructCasts, a.string), "redefinition of newstruct " * a.string)
    code = convert_newstruct_decl(a.string, b.string)
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


function convert_newstruct_decl(newtypename::String, args::String)
    sp = split(args, ",")
    sp = [filter!(x->x != "", split(i," ")) for i in sp]
    newreftype  = Symbol(newstructrefprefix * newtypename)
    newtype     = Symbol(newstructprefix * newtypename)

    r = Expr(:block)

    # struct definition
    b = Expr(:block)
    for i in sp
        @error_check(length(i) == 2, "invalid newstruct")
        push!(b.args, Expr(:(::), Symbol(i[2]), convert_typestring_tosymbol(String(i[1]))))
    end
    push!(r.args, Expr(:struct, true, newreftype, b))

    b = Expr(:block, Expr(:(::), :data, newreftype))
    push!(r.args, Expr(:struct, false, newtype, b))

    # deepcopy
    dpcpi = Expr(:(.), :Base, QuoteNode(:deepcopy_internal))
    idict = Expr(:(::), :dict, :IdDict)
    c = Expr(:call, newreftype)
    for i in sp
        push!(c.args, Expr(:call, :deepcopy, Expr(:(.), :f, QuoteNode(Symbol(i[2])))))
    end
    push!(r.args, Expr(:function, Expr(:call, dpcpi, Expr(:(::), :f, newreftype), idict),
        Expr(:return, c)
    ))

    push!(r.args, Expr(:function, Expr(:call, dpcpi, Expr(:(::), :f, newtype), idict),
        Expr(:return,
            Expr(:call, newtype,
                Expr(:call, :deepcopy,
                    Expr(:(.), :f, QuoteNode(:data))
                )
            )
        )
    ))

    # rt_copy
    push!(r.args, Expr(:function, Expr(:call, :rt_copy, Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy, Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy_allow_tuple, Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_copy_allow_tuple, Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    # rt_ref
    push!(r.args, Expr(:function, Expr(:call, :rt_ref, Expr(:(::), :f, newreftype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_ref, Expr(:(::), :f, newtype)),
        Expr(:return, Expr(:(.), :f, QuoteNode(:data)))
    ))

    # rt_convert2T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:(::), :f, newreftype)),
        Expr(:return, Expr(:call, newtype, Expr(:call, :deepcopy, :f)))
    ))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), Expr(:(::), :f, newtype)),
        Expr(:return, :f)
    ))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_convert2"*newtypename), :f),
        Expr(:call, :error, "cannot convert to a " * newtypename * " from ", :f)
    ))

    # rt_cast2T
    c = Expr(:call, Symbol("rt_cast2"*newtypename))
    d = Expr(:call, newreftype)
    for i in sp
        push!(c.args, Symbol(i[2]))
        push!(d.args, Expr(:call, Symbol("rt_convert2"*i[1]), Symbol(i[2])))
    end
    push!(r.args, Expr(:function, c, Expr(:return, Expr(:call, newtype, d))))

    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_cast2"*newtypename), Expr(:(...), :f)),
        Expr(:call, :error, "cannot construct a " * newtypename * " from ", :f)
    ))

    push!(r.args, Expr(:call, :setindex!, :rtGlobal_NewStructCasts, Symbol("rt_cast2"*newtypename), newtypename))

    # rt_defaultconstructor_T
    d = Expr(:call, newreftype)
    for i in sp
        push!(d.args, Expr(:call, Symbol("rt_defaultconstructor_"*i[1])))
    end
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_defaultconstructor_"*newtypename)),
        Expr(:return, Expr(:call, newtype, d))
    ))

    # rt_declare_T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_declare_"*newtypename), Expr(:(::), :a, :SName)),
        filter_lineno(quote
            n = length(rtGlobal.callstack)
            if n > 1
                rt_check_declaration_local(true, a.name, $(newtype))
                push!(rtGlobal.local_rindep_vars, Pair(a.name, $(Symbol("rt_defaultconstructor_"*newtypename))()))
            else
                d = rt_check_declaration_global(true, a.name, $(newtype))
                d[a.name] = $(Symbol("rt_defaultconstructor_"*newtypename))()
            end
        end)
    ))

    # rt_parameter_T
    push!(r.args, Expr(:function, Expr(:call, Symbol("rt_parameter_"*newtypename), Expr(:(::), :a, :SName), :b),
        filter_lineno(quote
            push!(rtGlobal.local_rindep_vars, Pair(a.name, $(Symbol("rt_convert2"*newtypename))(b)))
        end)
    ))

    # rt_assign  - all errors should be handled by rt_convert2something
    push!(r.args, Expr(:function, Expr(:call, :rt_assign,
                                        Expr(:(::), :a, Expr(:curly, :Union, newtype, newreftype)),
                                        :b),
        Expr(:return, Expr(:call, Symbol("rt_convert2"*newtypename), :b))
    ))

    # print
    b = Expr(:block, Expr(:(=), :s, ""))
    for i in 1:length(sp)
        push!(b.args, Expr(:(*=), :s, Expr(:call, :(*), Expr(:call, :(^), " ", :indent), "." * sp[i][2] * ":\n")))
        push!(b.args, Expr(:(*=), :s, Expr(:call, :rt_indenting_print, Expr(:(.), :f, QuoteNode(Symbol(sp[i][2]))), Expr(:call, :(+), :indent, 3))))
        if i < length(sp)
            push!(b.args, Expr(:(*=), :s, "\n"))
        end
    end
    push!(b.args, Expr(:return, :s))
    push!(r.args, Expr(:function, Expr(:call, :rt_indenting_print,
                                                Expr(:(::), :f, newreftype),
                                                Expr(:(::), :indent, :Int)),
        b
    ))

    push!(r.args, Expr(:function, Expr(:call, :rt_indenting_print,
                                                Expr(:(::), :f, newtype),
                                                Expr(:(::), :indent, :Int)),
        Expr(:return, Expr(:call, :rt_indenting_print, Expr(:(.), :f, QuoteNode(:data)), :indent))
    ))

    # rt_typedata
    push!(r.args, Expr(:function, Expr(:call, :rt_typedata,
                                        Expr(:(::), :f, Expr(:curly, :Union, newtype, newreftype))),
        Expr(:return, newtypename)
    ))

    push!(r.args, :nothing)
    return r
end



###############################################################################

struct AstNode
    rule::Int32
    child::Vector{Any}
end

function AstNodeMake(h, l...)
    return AstNode(h, [l...])
end

struct TranspileError <: Exception
    name::String
end


mutable struct AstEnv
    in_proc::Bool
    package::Symbol
    fxn_name::String
    at_top::Bool
    everything_is_screwed::Bool                  # no local variables may go into local storage
    rings_are_screwed::Bool                     # no local ring dependent variables may go into local storage
    appeared_identifiers::Dict{String, Int}     # name => some data
    declared_identifiers::Dict{String, String}  # name => type
end

mutable struct AstLoadEnv
    export_names::Bool
    package::Symbol
end


rtGlobal_Proc = Dict{Symbol, SProc}()
rtGlobal_NewStructNames = String[]

rtGlobal_NewStructCasts = Dict{String, Function}()


Base.showerror(io::IO, er::TranspileError) = print(io, "transpilation error: ", er.name)

macro RULE_top_lines(i)            ;return(100 + i); end
macro RULE_top_pprompt(i)          ;return(200 + i); end
macro RULE_lines(i)                ;return(300 + i); end
macro RULE_pprompt(i)              ;return(400 + i); end
macro RULE_npprompt(i)             ;return(500 + i); end
macro RULE_flowctrl(i)             ;return(600 + i); end
macro RULE_example_dummy(i)        ;return(700 + i); end
macro RULE_command(i)              ;return(800 + i); end
macro RULE_assign(i)               ;return(900 + i); end
macro RULE_elemexpr(i)            ;return(1000 + i); end
macro RULE_exprlist(i)            ;return(1100 + i); end
macro RULE_expr(i)                ;return(1200 + i); end
macro RULE_quote_start(i)         ;return(1300 + i); end
macro RULE_assume_start(i)        ;return(1400 + i); end
macro RULE_quote_end(i)           ;return(1500 + i); end
macro RULE_expr_arithmetic(i)     ;return(1600 + i); end
macro RULE_left_value(i)          ;return(1700 + i); end
macro RULE_extendedid(i)          ;return(1800 + i); end
macro RULE_declare_ip_variable(i) ;return(1900 + i); end
macro RULE_stringexpr(i)          ;return(2000 + i); end
macro RULE_rlist(i)               ;return(2100 + i); end
macro RULE_ordername(i)           ;return(2200 + i); end
macro RULE_orderelem(i)           ;return(2300 + i); end
macro RULE_OrderingList(i)        ;return(2400 + i); end
macro RULE_ordering(i)            ;return(2500 + i); end
macro RULE_mat_cmd(i)             ;return(2600 + i); end
macro RULE_filecmd(i)             ;return(2700 + i); end
macro RULE_helpcmd(i)             ;return(2800 + i); end
macro RULE_examplecmd(i)          ;return(2900 + i); end
macro RULE_exportcmd(i)           ;return(3000 + i); end
macro RULE_killcmd(i)             ;return(3100 + i); end
macro RULE_listcmd(i)             ;return(3200 + i); end
macro RULE_ringcmd1(i)            ;return(3300 + i); end
macro RULE_ringcmd(i)             ;return(3400 + i); end
macro RULE_scriptcmd(i)           ;return(3500 + i); end
macro RULE_setrings(i)            ;return(3600 + i); end
macro RULE_setringcmd(i)          ;return(3700 + i); end
macro RULE_typecmd(i)             ;return(3800 + i); end
macro RULE_ifcmd(i)               ;return(3900 + i); end
macro RULE_whilecmd(i)            ;return(4000 + i); end
macro RULE_forcmd(i)              ;return(4100 + i); end
macro RULE_proccmd(i)             ;return(4200 + i); end
macro RULE_parametercmd(i)        ;return(4300 + i); end
macro RULE_returncmd(i)           ;return(4400 + i); end
macro RULE_procarglist(i)         ;return(4500 + i); end
macro RULE_procarg(i)             ;return(4600 + i); end

@enum CMDS begin
# must match deps/ast_generator/grammar.tab.h
  DOTDOT = 258
  EQUAL_EQUAL
  GE
  LE
  MINUSMINUS
  NOT
  NOTEQUAL
  PLUSPLUS
  COLONCOLON
  ARROW
  GRING_CMD
  BIGINTMAT_CMD
  INTMAT_CMD
  PROC_CMD
  STATIC_PROC_CMD
  RING_CMD
  BEGIN_RING
  BUCKET_CMD
  IDEAL_CMD
  MAP_CMD
  MATRIX_CMD
  MODUL_CMD
  NUMBER_CMD
  POLY_CMD
  RESOLUTION_CMD
  SMATRIX_CMD
  VECTOR_CMD
  BETTI_CMD
  E_CMD
  FETCH_CMD
  FREEMODULE_CMD
  KEEPRING_CMD
  IMAP_CMD
  KOSZUL_CMD
  MAXID_CMD
  MONOM_CMD
  PAR_CMD
  PREIMAGE_CMD
  VAR_CMD
  VALTVARS
  VMAXDEG
  VMAXMULT
  VNOETHER
  VMINPOLY
  END_RING
  CMD_1
  CMD_2
  CMD_3
  CMD_12
  CMD_13
  CMD_23
  CMD_123
  CMD_M
  ROOT_DECL
  ROOT_DECL_LIST
  RING_DECL
  RING_DECL_LIST
  EXAMPLE_CMD
  EXPORT_CMD
  HELP_CMD
  KILL_CMD
  LIB_CMD
  LISTVAR_CMD
  SETRING_CMD
  TYPE_CMD
  STRINGTOK
  INT_CONST
  UNKNOWN_IDENT
  RINGVAR
  PROC_DEF
  APPLY
  ASSUME_CMD
  BREAK_CMD
  CONTINUE_CMD
  ELSE_CMD
  EVAL
  QUOTE
  FOR_CMD
  IF_CMD
  SYS_BREAK
  WHILE_CMD
  RETURN
  PARAMETER
  QUIT_CMD
  SYSVAR
  UMINUS
#must match deps/ast_generator/tok.h
  ALIAS_CMD = 1000
  ALIGN_CMD
  ATTRIB_CMD
  BAREISS_CMD
  BIGINT_CMD
  BRANCHTO_CMD
  BRACKET_CMD
  BREAKPOINT_CMD
  CHARACTERISTIC_CMD
  CHARSTR_CMD
  CHAR_SERIES_CMD
  CHINREM_CMD
  CMATRIX_CMD
  CNUMBER_CMD
  CPOLY_CMD
  CLOSE_CMD
  COEFFS_CMD
  COEF_CMD
  COLS_CMD
  CONTENT_CMD
  CONTRACT_CMD
  COUNT_CMD
  CRING_CMD
  DBPRINT_CMD
  DEF_CMD
  DEFINED_CMD
  DEG_CMD
  DEGREE_CMD
  DELETE_CMD
  DENOMINATOR_CMD
  DET_CMD
  DIFF_CMD
  DIM_CMD
  DIVISION_CMD
  DUMP_CMD
  ELIMINATION_CMD
  END_GRAMMAR
  ENVELOPE_CMD
  ERROR_CMD
  EXECUTE_CMD
  EXPORTTO_CMD
  EXTGCD_CMD
  FAC_CMD
  FAREY_CMD
  FIND_CMD
  FACSTD_CMD
  FMD_CMD
  FRES_CMD
  FWALK_CMD
  FGLM_CMD
  FGLMQUOT_CMD
  FINDUNI_CMD
  GCD_CMD
  GETDUMP_CMD
  HIGHCORNER_CMD
  HILBERT_CMD
  HOMOG_CMD
  HRES_CMD
  IMPART_CMD
  IMPORTFROM_CMD
  INDEPSET_CMD
  INSERT_CMD
  INT_CMD
  INTDIV_CMD
  INTERPOLATE_CMD
  INTERRED_CMD
  INTERSECT_CMD
  INTVEC_CMD
  IS_RINGVAR
  JACOB_CMD
  JANET_CMD
  JET_CMD
  KBASE_CMD
  KERNEL_CMD
  KILLATTR_CMD
  KRES_CMD
  LAGSOLVE_CMD
  LEAD_CMD
  LEADCOEF_CMD
  LEADEXP_CMD
  LEADMONOM_CMD
  LIFTSTD_CMD
  LIFT_CMD
  LINK_CMD
  LIST_CMD
  LOAD_CMD
  LRES_CMD
  LU_CMD
  LUI_CMD
  LUS_CMD
  MEMORY_CMD
  MINBASE_CMD
  MINOR_CMD
  MINRES_CMD
  MODULO_CMD
  MONITOR_CMD
  MPRES_CMD
  MRES_CMD
  MSTD_CMD
  MULTIPLICITY_CMD
  NAMEOF_CMD
  NAMES_CMD
  NEWSTRUCT_CMD
  NCALGEBRA_CMD
  NC_ALGEBRA_CMD
  NEWTONPOLY_CMD
  NPARS_CMD
  NUMERATOR_CMD
  NVARS_CMD
  ORD_CMD
  OPEN_CMD
  OPPOSE_CMD
  OPPOSITE_CMD
  OPTION_CMD
  ORDSTR_CMD
  PACKAGE_CMD
  PARDEG_CMD
  PARENT_CMD
  PARSTR_CMD
  PFAC_CMD
  PRIME_CMD
  PRINT_CMD
  PRUNE_CMD
  QHWEIGHT_CMD
  QRING_CMD
  QRDS_CMD
  QUOTIENT_CMD
  RANDOM_CMD
  RANK_CMD
  READ_CMD
  REDUCE_CMD
  REGULARITY_CMD
  REPART_CMD
  RES_CMD
  RESERVEDNAME_CMD
  RESTART_CMD
  RESULTANT_CMD
  RINGLIST_CMD
  RING_LIST_CMD
  ROWS_CMD
  SBA_CMD
  SIMPLEX_CMD
  SIMPLIFY_CMD
  SLIM_GB_CMD
  SORTVEC_CMD
  SQR_FREE_CMD
  SRES_CMD
  STATUS_CMD
  STD_CMD
  STRING_CMD
  SUBST_CMD
  SYSTEM_CMD
  SYZYGY_CMD
  TENSOR_CMD
  TEST_CMD
  TRANSPOSE_CMD
  TRACE_CMD
  TWOSTD_CMD
  TYPEOF_CMD
  UNIVARIATE_CMD
  UNLOAD_CMD
  URSOLVE_CMD
  VANDER_CMD
  VARIABLES_CMD
  VARSTR_CMD
  VDIM_CMD
  WAIT1ST_CMD
  WAITALL_CMD
  WEDGE_CMD
  WEIGHT_CMD
  WRITE_CMD

  VECHO
  VCOLMAX
  VTIMER
  VRTIMER
  TRACE
  VOICE
  VSHORTOUT
  VPRINTLEVEL

  MAX_TOK
end




function astprint(a::Int, indent::Int)
    print(" "^indent)
    println(a)
end

function astprint(a::String, indent::Int)
    print(" "^indent)
    println(a)
end

function astprint(a::AstNode, indent::Int)
    print(" "^indent)
    if 100 < a.rule < 200
        print("RULE_top_lines ")
    elseif 200 < a.rule < 300
        print("RULE_top_pprompt ")
    elseif 300 < a.rule < 400
        print("RULE_lines ")
    elseif 400 < a.rule < 500
        print("RULE_pprompt ")
    elseif 500 < a.rule < 600
        print("RULE_npprompt ")
    elseif 600 < a.rule < 700
        print("RULE_flowctrl ")
    elseif 700 < a.rule < 800
        print("RULE_example_dummy ")
    elseif 800 < a.rule < 900
        print("RULE_command ")
    elseif 900 < a.rule < 1000
        print("RULE_assign ")
    elseif 1000 < a.rule < 1100
        print("RULE_elemexpr ")
    elseif 1100 < a.rule < 1200
        print("RULE_exprlist ")
    elseif 1200 < a.rule < 1300
        print("RULE_expr ")
    elseif 1300 < a.rule < 1400
        print("RULE_quote_start ")
    elseif 1400 < a.rule < 1500
        print("RULE_assume_start ")
    elseif 1500 < a.rule < 1600
        print("RULE_quote_end ")
    elseif 1600 < a.rule < 1700
        print("RULE_expr_arithmetic ")
    elseif 1700 < a.rule < 1800
        print("RULE_left_value ")
    elseif 1800 < a.rule < 1900
        print("RULE_extendedid ")
    elseif 1900 < a.rule < 2000
        print("RULE_declare_ip_variable ")
    elseif 2000 < a.rule < 2100
        print("RULE_stringexpr ")
    elseif 2100 < a.rule < 2200
        print("RULE_rlist ")
    elseif 2200 < a.rule < 2300
        print("RULE_ordername ")
    elseif 2300 < a.rule < 2400
        print("RULE_orderelem ")
    elseif 2400 < a.rule < 2500
        print("RULE_OrderingList ")
    elseif 2500 < a.rule < 2600
        print("RULE_ordering ")
    elseif 2600 < a.rule < 2700
        print("RULE_mat_cmd ")
    elseif 2700 < a.rule < 2800
        print("RULE_filecmd ")
    elseif 2800 < a.rule < 2900
        print("RULE_helpcmd ")
    elseif 2900 < a.rule < 3000
        print("RULE_examplecmd ")
    elseif 3000 < a.rule < 3100
        print("RULE_exportcmd ")
    elseif 3100 < a.rule < 3200
        print("RULE_killcmd ")
    elseif 3200 < a.rule < 3300
        print("RULE_listcmd ")
    elseif 3300 < a.rule < 3400
        print("RULE_ringcmd1 ")
    elseif 3400 < a.rule < 3500
        print("RULE_ringcmd ")
    elseif 3500 < a.rule < 3600
        print("RULE_scriptcmd ")
    elseif 3600 < a.rule < 3700
        print("RULE_setrings ")
    elseif 3700 < a.rule < 3800
        print("RULE_setringcmd ")
    elseif 3800 < a.rule < 3900
        print("RULE_typecmd ")
    elseif 3900 < a.rule < 4000
        print("RULE_ifcmd ")
    elseif 4000 < a.rule < 4100
        print("RULE_whilecmd ")
    elseif 4100 < a.rule < 4200
        print("RULE_forcmd ")
    elseif 4200 < a.rule < 4300
        print("RULE_proccmd ")
    elseif 4300 < a.rule < 4400
        print("RULE_parametercmd ")
    elseif 4400 < a.rule < 4500
        print("RULE_returncmd ")
    elseif 4500 < a.rule < 4600
        print("RULE_procarglist ")
    elseif 4600 < a.rule < 4700
        print("RULE_procarg ")
    else
        print("unknown ")
    end
    println(a.rule)
    for i in 1:length(a.child)
        astprint(a.child[i], indent + 4)
    end
end

function scan_extendedid(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_extendedid(0) < 100
    if a.rule == @RULE_extendedid(1)
        if a.child[1]::String == "_"
        elseif a.child[1]::String == "basering"
        else
            env.appeared_identifiers[a.child[1]::String] = 1
        end        
    elseif a.rule == @RULE_extendedid(2)
        env.everything_is_screwed = true
    else
        throw(TranspileError("internal error in scan_extendedid"))
    end
end


function convert_extendedid(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_extendedid(0) < 100
    if a.rule == @RULE_extendedid(1)
        if a.child[1]::String == "_"
            return Expr(:call, :rt_get_last_printed)
        elseif a.child[1]::String == "basering"
            return Expr(:call, :rtbasering)
        else
            s = a.child[1]::String
            if haskey(env.declared_identifiers, s)
                return Expr(:call, :rt_ref, Symbol(s))
            else
                return makeunknown(s)
            end
        end
    elseif a.rule == @RULE_extendedid(2)
        s = make_nocopy(convert_expr(a.child[1], env))
        return Expr(:call, :rt_backtick, s)
    else
        throw(TranspileError("internal error in convert_extendedid"))
    end
end

function we_know_splat_is_trivial(a)
    if a isa Expr && a.head == :call && length(a.args) == 2 &&
                            (a.args[1] == :rt_make || a.args[1] == :rt_ref)
        return true
    elseif a isa SName
        return true
    elseif a isa Int
        return true
    else
        return false
    end
end


# is the expression a SName at runtime?
function is_a_name(a)
    if isa(a, SName)
        return true
    end
    return (isa(a, Expr) && a.head == :call && !isempty(a.args) && a.args[1] == :rt_backtick)
end



# return array of generating non necessarily SingularTypes
#   useful probably only for passing to procs, where the values will be copied to new locations
# will not generate names!
# return is Array{Any}
function make_tuple_array_nocopy(a::Array{Any})
    r = Any[]
    for i in 1:length(a)
        if isa(a[i], Expr) && a[i].head == :tuple
            append!(r, a[i].args)   # each of a[i].args should already be copied and splatted
        elseif is_a_name(a[i])
            push!(r, Expr(:call, :rt_make, a[i]))
        elseif we_know_splat_is_trivial(a[i])
            push!(r, a[i])
        else
            push!(r, Expr(:(...), Expr(:call, :rt_copy_allow_tuple, a[i])))
        end
    end
    return r
end

# will not generate names!
function make_nocopy(a)
    if is_a_name(a)
        return Expr(:call, :rt_make, a)
    else
        return a
    end
end


# return array generating SingularTypes, can construct a singular tuple with Expr(:tuple, ...)
# will not generate names!
# return is Array{Any}
function make_tuple_array_copy(a::Array{Any})
    r = Any[]
    for i in 1:length(a)
        if isa(a[i], Expr) && a[i].head == :tuple
            append!(r, a[i].args)   # each of a[i].args should already be copied and splatted
        elseif is_a_name(a[i])
            push!(r, Expr(:call, :rt_copy, Expr(:call, :rt_make, a[i])))
        elseif we_know_splat_is_trivial(a[i])
            push!(r, Expr(:call, :rt_copy, a[i]))
        else
            push!(r, Expr(:(...), Expr(:call, :rt_copy_allow_tuple, a[i]))) # TODO opt: splat can be avoided somtimes
        end
    end
    return r
end

# will not generate names!
function make_copy(a)
    if is_a_name(a)
        return Expr(:call, :rt_copy, Expr(:call, :rt_make, a))
    else
        return Expr(:call, :rt_copy_allow_tuple, a)
    end
end


function convert_stringexpr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_stringexpr(0) < 100
    return SString(a.child[1])
end


const newstructprefix    = "SNewStruct_"
const newstructrefprefix = "SNewStructRef_"

function convert_typestring_tosymbol(s::String)
    if s == "proc"
        return :SProc
    elseif s == "int"
        return :Int
    elseif s == "bigint"
        return :BigInt
    elseif s == "string"
        return :SString
    elseif s == "intvec"
        return :SIntvec
    elseif s == "intmat"
        return :SIntMat
    elseif s == "bigintmat"
        return :SBigIntMat
    elseif s == "list"
        return :SList
    elseif s == "ring"
        return :SRing
    elseif s == "number"
        return :SNumber
    elseif s == "poly"
        return :SPoly
    elseif s == "ideal"
        return :SIdeal
    else
        return Symbol(newstructprefix * s)
    end
end




const system_var_to_string = Dict{Int, String}(
    Int(VMAXDEG)        => "degBound",
    Int(VECHO)          => "echo",
    Int(VMINPOLY)       => "minpoly",
    Int(VMAXMULT)       => "multBound",
    Int(VNOETHER)       => "noether",
    Int(VCOLMAX)        => "pagewidth",
    Int(VPRINTLEVEL)    => "printlevel",
    Int(VRTIMER)        => "rtimer",
    Int(VSHORTOUT)      => "short",
    Int(VTIMER)         => "timer",
    Int(TRACE)          => "TRACE",
    Int(VOICE)          => "voice"
)

const cmds_that_screw_everything = Set{Int}(Int(EXECUTE_CMD))

const cmd_to_string = Dict{Int, String}(
    Int(ALIGN_CMD)    => "align",
    Int(ATTRIB_CMD)    => "attrib",
    Int(BAREISS_CMD)    => "bareiss",
    Int(BETTI_CMD)    => "betti",
    Int(BRANCHTO_CMD)    => "branchTo",
    Int(BREAKPOINT_CMD)    => "breakpoint",
    Int(CHARACTERISTIC_CMD)    => "char",
    Int(CHAR_SERIES_CMD)    => "char_series",
    Int(CHARSTR_CMD)    => "charstr",
    Int(CHINREM_CMD)    => "chinrem",
    Int(CONTENT_CMD)    => "cleardenom",
    Int(CLOSE_CMD)    => "close",
    Int(COEF_CMD)    => "coef",
    Int(COEFFS_CMD)    => "coeffs",
    Int(CONTRACT_CMD)    => "contract",
    Int(NEWTONPOLY_CMD)    => "convhull",
    Int(DBPRINT_CMD)    => "dbprint",
    Int(DEFINED_CMD)    => "defined",
    Int(DEG_CMD)    => "deg",
    Int(DEGREE_CMD)    => "degree",
    Int(DELETE_CMD)    => "delete",
    Int(DENOMINATOR_CMD)    => "denominator",
    Int(DET_CMD)    => "det",
    Int(DIFF_CMD)    => "diff",
    Int(DIM_CMD)    => "dim",
    Int(DIVISION_CMD)    => "division",
    Int(DUMP_CMD)    => "dump",
    Int(EXTGCD_CMD)    => "extgcd",
    Int(ERROR_CMD)    => "ERROR",
    Int(ELIMINATION_CMD)    => "eliminate",
    Int(EXECUTE_CMD)    => "execute",
    Int(EXPORTTO_CMD)    => "exportto",
    Int(FACSTD_CMD)    => "facstd",
    Int(FMD_CMD)    => "factmodd",
    Int(FAC_CMD)    => "factorize",
    Int(FAREY_CMD)    => "farey",
    Int(FETCH_CMD)    => "fetch",
    Int(FGLM_CMD)    => "fglm",
    Int(FGLMQUOT_CMD)    => "fglmquot",
    Int(FIND_CMD)    => "find",
    Int(FINDUNI_CMD)    => "finduni",
    Int(FREEMODULE_CMD)    => "freemodule",
    Int(FRES_CMD)    => "fres",
    Int(FWALK_CMD)    => "frwalk",
    Int(E_CMD)    => "gen",
    Int(GETDUMP_CMD)    => "getdump",
    Int(GCD_CMD)    => "gcd",
    Int(GCD_CMD)    => "GCD",
    Int(HILBERT_CMD)    => "hilb",
    Int(HIGHCORNER_CMD)    => "highcorner",
    Int(HOMOG_CMD)    => "homog",
    Int(HRES_CMD)    => "hres",
    Int(IMAP_CMD)    => "imap",
    Int(IMPART_CMD)    => "impart",
    Int(IMPORTFROM_CMD)    => "importfrom",
    Int(INDEPSET_CMD)    => "indepSet",
    Int(INSERT_CMD)    => "insert",
    Int(INTERPOLATE_CMD)    => "interpolation",
    Int(INTERRED_CMD)    => "interred",
    Int(INTERSECT_CMD)    => "intersect",
    Int(JACOB_CMD)    => "jacob",
    Int(JANET_CMD)    => "janet",
    Int(JET_CMD)    => "jet",
    Int(KBASE_CMD)    => "kbase",
    Int(KERNEL_CMD)    => "kernel",
    Int(KILLATTR_CMD)    => "killattrib",
    Int(KOSZUL_CMD)    => "koszul",
    Int(KRES_CMD)    => "kres",
    Int(LAGSOLVE_CMD)    => "laguerre",
    Int(LEAD_CMD)    => "lead",
    Int(LEADCOEF_CMD)    => "leadcoef",
    Int(LEADEXP_CMD)    => "leadexp",
    Int(LEADMONOM_CMD)    => "leadmonom",
    Int(LIFT_CMD)    => "lift",
    Int(LIFTSTD_CMD)    => "liftstd",
    Int(LOAD_CMD)    => "load",
    Int(LRES_CMD)    => "lres",
    Int(LU_CMD)    => "ludecomp",
    Int(LUI_CMD)    => "luinverse",
    Int(LUS_CMD)    => "lusolve",
    Int(MAXID_CMD)    => "maxideal",
    Int(MEMORY_CMD)    => "memory",
    Int(MINBASE_CMD)    => "minbase",
    Int(MINOR_CMD)    => "minor",
    Int(MINRES_CMD)    => "minres",
    Int(MODULO_CMD)    => "modulo",
    Int(MONITOR_CMD)    => "monitor",
    Int(MONOM_CMD)    => "monomial",
    Int(MPRES_CMD)    => "mpresmat",
    Int(MULTIPLICITY_CMD)    => "mult",
    Int(MRES_CMD)    => "mres",
    Int(MSTD_CMD)    => "mstd",
    Int(NAMEOF_CMD)    => "nameof",
    Int(NAMES_CMD)    => "names",
    Int(NEWSTRUCT_CMD)    => "newstruct",
    Int(COLS_CMD)    => "ncols",
    Int(NPARS_CMD)    => "npars",
    Int(RES_CMD)    => "nres",
    Int(ROWS_CMD)    => "nrows",
    Int(NUMERATOR_CMD)    => "numerator",
    Int(NVARS_CMD)    => "nvars",
    Int(OPEN_CMD)    => "open",
    Int(OPTION_CMD)    => "option",
    Int(ORD_CMD)    => "ord",
    Int(ORDSTR_CMD)    => "ordstr",
    Int(PAR_CMD)    => "par",
    Int(PARDEG_CMD)    => "pardeg",
    Int(PARSTR_CMD)    => "parstr",
    Int(PREIMAGE_CMD)    => "preimage",
    Int(PRIME_CMD)    => "prime",
    Int(PFAC_CMD)    => "primefactors",
    Int(PRINT_CMD)    => "print",
    Int(PRUNE_CMD)    => "prune",
    Int(QHWEIGHT_CMD)    => "qhweight",
    Int(QRDS_CMD)    => "qrds",
    Int(QUOTIENT_CMD)    => "quotient",
    Int(RANDOM_CMD)    => "random",
    Int(RANK_CMD)    => "rank",
    Int(READ_CMD)    => "read",
    Int(REDUCE_CMD)    => "reduce",
    Int(REGULARITY_CMD)    => "regularity",
    Int(REPART_CMD)    => "repart",
    Int(RESERVEDNAME_CMD)    => "reservedName",
#    Int(RESERVEDNAMELIST_CMD)    => "reservedNameList",
    Int(RESULTANT_CMD)    => "resultant",
    Int(RESTART_CMD)    => "restart",
    Int(RINGLIST_CMD)    => "ringlist",
    Int(RING_LIST_CMD)    => "ring_list",
    Int(IS_RINGVAR)    => "rvar",
    Int(SBA_CMD)    => "sba",
    Int(SIMPLEX_CMD)    => "simplex",
    Int(SIMPLIFY_CMD)    => "simplify",
    Int(COUNT_CMD)    => "size",
    Int(SLIM_GB_CMD)    => "slimgb",
    Int(SORTVEC_CMD)    => "sortvec",
    Int(SQR_FREE_CMD)    => "sqrfree",
    Int(SRES_CMD)    => "sres",
    Int(STATUS_CMD)    => "status",
    Int(STD_CMD)    => "std",
    Int(SUBST_CMD)    => "subst",
    Int(SYSTEM_CMD)    => "system",
    Int(SYZYGY_CMD)    => "syz",
    Int(TENSOR_CMD)    => "tensor",
    Int(TEST_CMD)    => "test",
    Int(TRACE_CMD)    => "trace",
    Int(TRANSPOSE_CMD)    => "transpose",
    Int(TYPEOF_CMD)    => "typeof",
    Int(UNIVARIATE_CMD)    => "univariate",
    Int(URSOLVE_CMD)    => "uressolve",
    Int(VANDER_CMD)    => "vandermonde",
    Int(VAR_CMD)    => "var",
    Int(VARIABLES_CMD)    => "variables",
    Int(VARSTR_CMD)    => "varstr",
    Int(VDIM_CMD)    => "vdim",
    Int(WEDGE_CMD)    => "wedge",
    Int(WEIGHT_CMD)    => "weight",
    Int(WRITE_CMD)    => "write"
)


const cmd_to_builtin_type_string = Dict{Int, String}(
    Int(DEF_CMD) => "def",
    Int(PROC_CMD) => "proc",
    Int(INT_CMD) => "int",
    Int(BIGINT_CMD) => "bigint",
    Int(STRING_CMD) => "string",
    Int(INTVEC_CMD) => "int",
    Int(INTMAT_CMD) => "bigint",
    Int(BIGINTMAT_CMD) => "bigintmat",
    Int(LIST_CMD) => "list",
    Int(RING_CMD) => "ring",
    Int(NUMBER_CMD) => "number",
    Int(POLY_CMD) => "poly",
    Int(IDEAL_CMD) => "ideal"
)



function scan_elemexpr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(2)
        return scan_extendedid(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(4)
        scan_expr(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(5)
        scan_elemexpr(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(6)
        scan_elemexpr(a.child[1], env)
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(8)
    elseif a.rule == @RULE_elemexpr(9)
    elseif a.rule == @RULE_elemexpr(10)
    elseif a.rule == @RULE_elemexpr(12)
        scan_expr(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(13)
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(14)
    elseif a.rule == @RULE_elemexpr(15)
        scan_expr(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(16)
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(17)
    elseif a.rule == @RULE_elemexpr(18) || a.rule == @RULE_elemexpr(19) ||
                                           a.rule == @RULE_elemexpr(20) ||
                                           a.rule == @RULE_elemexpr(21)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(22) || a.rule == @RULE_elemexpr(23) ||
                                           a.rule == @RULE_elemexpr(24) ||
                                           a.rule == @RULE_elemexpr(25)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
    elseif a.rule == @RULE_elemexpr(26) || a.rule == @RULE_elemexpr(27) ||
                                           a.rule == @RULE_elemexpr(28) ||
                                           a.rule == @RULE_elemexpr(29)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
        scan_expr(a.child[4], env)
    elseif a.rule == @RULE_elemexpr(30)
    elseif a.rule == @RULE_elemexpr(31)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(37)
        scan_exprlist(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_elemexpr"*string(a.rule)))
    end
end

function convert_elemexpr(a::AstNode, env::AstEnv, nested::Bool = false)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(2)
        return convert_extendedid(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(4)
        c = a.child[2]
        c.child[1].rule == @RULE_extendedid(1) || throw(TranspileError("rhs of dot is no good"))
        s = c.child[1].child[1]::String
        doring = false
        if length(s) > 2 && s[1:2] == "r_"
            doring = true
            s = s[3:end]
        end
        is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
        b = convert_expr(a.child[1], env)
        b = Expr(:call, isa(b, SName) ? :rt_make : :rt_ref, b)
        t = Expr(:call, :rt_ref, Expr(:(.), b, QuoteNode(Symbol(s))))
        if doring
            return Expr(:call, :rt_ringof, t)
        else
            return t
        end
    elseif a.rule == @RULE_elemexpr(6) || a.rule == @RULE_elemexpr(5)
        if a.rule == @RULE_elemexpr(6)
            b = convert_exprlist(a.child[2], env)::Array{Any}
        else
            b = Any[]
        end
        c = a.child[1]
        # x(1)(2) => rtcall(false, rtcall(true, x, 1), 2)
        return Expr(:call, :rtcall, nested,
                                    convert_elemexpr(c, env, c.rule == @RULE_elemexpr(6)),
                                    make_tuple_array_nocopy(b)...)
    elseif a.rule == @RULE_elemexpr(8)
        x = parse(BigInt, a.child[1])
        if typemin(Int) <= x <= typemax(Int)
            return Int(x)
        else
            return x
        end
    elseif a.rule == @RULE_elemexpr(9)
        t = a.child[1]::Int
        haskey(system_var_to_string, t) || throw(TranspileError("internal error in convert_elemexpr 9"))
        return Expr(:call, Symbol("rt_get_" * system_var_to_string[t]))
    elseif a.rule == @RULE_elemexpr(10)
        return convert_stringexpr(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(12)
        b = convert_expr(a.child[2], env)
        t = a.child[1]::Int
        if t == Int(INT_CMD)
            return Expr(:call, :rt_cast2int, make_nocopy(b))
        elseif t == Int(BIGINT_CMD)
            return Expr(:call, :rt_cast2bigint, make_nocopy(b))
        else
            throw(TranspileError("internal error in convert_elemexpr 12"))
        end
    elseif a.rule == @RULE_elemexpr(13)
        t = a.child[1]::Int
        if t == Int(LIST_CMD)
            b = convert_exprlist(a.child[2], env)::Array{Any}
            return Expr(:call, :rt_cast2list, make_tuple_array_nocopy(b)...)
        elseif t == Int(STRING_CMD)
            b = convert_exprlist(a.child[2], env)::Array{Any}
            return Expr(:call, :rt_cast2string, make_tuple_array_nocopy(b)...)
        else
            throw(TranspileError("internal error in convert_elemexpr 13"))
        end
    elseif a.rule == @RULE_elemexpr(16)
        t = a.child[1]::Int
        if t == Int(IDEAL_CMD)
            b = convert_exprlist(a.child[2], env)::Array{Any}
            return Expr(:call, :rt_cast2ideal, make_tuple_array_nocopy(b)...)
        else
            throw(TranspileError("internal error in convert_elemexpr 13"))
        end
    elseif a.rule == @RULE_elemexpr(18) || a.rule == @RULE_elemexpr(19) ||
                                           a.rule == @RULE_elemexpr(20) ||
                                           a.rule == @RULE_elemexpr(21)
        t = a.child[1]::Int
        if (t == Int(ERROR_CMD))
            return Expr(:call, :rtERROR, convert_expr(a.child[2], env), String(env.package) * "::" * env.fxn_name)
        else
            haskey(cmd_to_string, t) || throw(TranspileError("internal error in convert_elemexpr 18|19|20|21"))
            return Expr(:call, Symbol("rt" * cmd_to_string[t]), convert_expr(a.child[2], env))
        end
    elseif a.rule == @RULE_elemexpr(22) || a.rule == @RULE_elemexpr(23) ||
                                           a.rule == @RULE_elemexpr(24) ||
                                           a.rule == @RULE_elemexpr(25)
        t = a.child[1]::Int
        haskey(cmd_to_string, t) || throw(TranspileError("internal error in convert_elemexpr 22|23|24|25"))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), convert_expr(a.child[2], env),
                                                            convert_expr(a.child[3], env))
    elseif a.rule == @RULE_elemexpr(26) || a.rule == @RULE_elemexpr(27) ||
                                           a.rule == @RULE_elemexpr(28) ||
                                           a.rule == @RULE_elemexpr(29)
        t = a.child[1]::Int
        haskey(cmd_to_string, t) || throw(TranspileError("internal error in convert_elemexpr 26|27|28|29"))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), convert_expr(a.child[2], env),
                                                            convert_expr(a.child[3], env),
                                                            convert_expr(a.child[4], env))
    elseif a.rule == @RULE_elemexpr(30) || a.rule == @RULE_elemexpr(31)
        if a.rule == @RULE_elemexpr(31)
            b = convert_exprlist(a.child[2], env)::Array{Any}
        else
            b = Any[]
        end
        t = a.child[1]::Int
        haskey(cmd_to_string, t) || throw(TranspileError("internal error in convert_elemexpr 30|31"))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), make_tuple_array_nocopy(b)...)
    elseif a.rule == @RULE_elemexpr(99)
        return convert_newstruct_decl(a.child[1], a.child[2])
    elseif a.rule == @RULE_elemexpr(37)
        b = convert_exprlist(a.child[1], env)
        if length(b) == 1
            return make_copy(b[1])
        else
            return Expr(:tuple, make_tuple_array_copy(b)...)
        end
    else
        throw(TranspileError("internal error in convert_elemexpr"*string(a.rule)))
    end
end



function scan_expr_arithmetic_incdec(a::AstNode, env::AstEnv)
    lhs::Array{AstNode} = AstNode[]
    if a.rule == @RULE_expr(2) && a.child[1].rule == @RULE_elemexpr(37)
        push_exprlist_expr!(lhs, a.child[1].child[1], env)
    else
        push!(lhs, a)
    end
    for L in lhs
        scan_expr(L, env)
        scan_assignment(L, env)
    end
end

function convert_expr_arithmetic_incdec(a::AstNode, b::Int, env::AstEnv)
    lhs::Array{AstNode} = AstNode[]
    r = Expr(:block)
    if a.rule == @RULE_expr(2) && a.child[1].rule == @RULE_elemexpr(37)
        push_exprlist_expr!(lhs, a.child[1].child[1], env)
    else
        push!(lhs, a)
    end
    for i in 1:length(lhs)
        push_incrementby!(r, lhs[i], b, env)
    end
    push!(r.args, :nothing)
    return r
end


function scan_expr_arithmetic(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr_arithmetic(0) < 100
    if a.rule == @RULE_expr_arithmetic(1) || a.rule == @RULE_expr_arithmetic(2)
        return scan_expr_arithmetic_incdec(a.child[1], env)
    elseif @RULE_expr_arithmetic(3) <= a.rule <= @RULE_expr_arithmetic(18) || a.rule == @RULE_expr_arithmetic(99)
        scan_expr(a.child[1], env)
        scan_expr(a.child[2], env)
    elseif @RULE_expr_arithmetic(19) <= a.rule <= @RULE_expr_arithmetic(20)
        scan_expr(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_expr_arithmetic "))
    end
end

function convert_expr_arithmetic(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr_arithmetic(0) < 100
    if a.rule == @RULE_expr_arithmetic(1)
        return convert_expr_arithmetic_incdec(a.child[1], 1, env)
    elseif a.rule == @RULE_expr_arithmetic(2)
        return convert_expr_arithmetic_incdec(a.child[1], -1, env)
    elseif a.rule == @RULE_expr_arithmetic(3)
        return Expr(:call, :rtplus, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(4)
        return Expr(:call, :rtminus, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(5)
        return Expr(:call, :rttimes, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(6)
        return Expr(:call, :rtmod, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(99)
        return Expr(:call, :rtdiv, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(7)
        return Expr(:call, :rtdivide, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(8)
        return Expr(:call, :rtpower, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(9)
        return Expr(:call, :rtgreaterequal, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(10)
        return Expr(:call, :rtlessequal, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(11)
        return Expr(:call, :rtgreater, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(12)
        return Expr(:call, :rtless, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(13)
        return Expr(:call, :rtand, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(14)
        return Expr(:call, :rtor, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(15)
        return Expr(:call, :rtnotequal, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(16)
        return Expr(:call, :rtequalequal, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(17)
        return Expr(:call, :rtdotdot, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(18)
        return Expr(:call, :rtcolon, convert_expr(a.child[1], env), convert_expr(a.child[2], env))
    elseif a.rule == @RULE_expr_arithmetic(19)
        return Expr(:call, :rtnot, convert_expr(a.child[1], env))
    elseif a.rule == @RULE_expr_arithmetic(20)
        return Expr(:call, :rtminus, convert_expr(a.child[1], env))
    else
        throw(TranspileError("internal error in convert_expr_arithmetic "))
    end
end


function scan_expr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(1)
        scan_expr_arithmetic(a.child[1], env)
    elseif a.rule == @RULE_expr(2)
        scan_elemexpr(a.child[1], env)
    elseif a.rule == @RULE_expr(3)
        scan_expr(a.child[1], env)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
    elseif a.rule == @RULE_expr(4)
        scan_expr(a.child[1], env)
        scan_expr(a.child[2], env)
    else
        throw(TranspileError("internal error in scan_expr"))
    end
end

function convert_expr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(1)
        return convert_expr_arithmetic(a.child[1], env)
    elseif a.rule == @RULE_expr(2)
        return convert_elemexpr(a.child[1], env)
    elseif a.rule == @RULE_expr(3)
        return Expr(:call, :rt_getindex, make_nocopy(convert_expr(a.child[1], env)),
                                         make_nocopy(convert_expr(a.child[2], env)),
                                         make_nocopy(convert_expr(a.child[3], env)))
    elseif a.rule == @RULE_expr(4)
        return Expr(:call, :rt_getindex, make_nocopy(convert_expr(a.child[1], env)),
                                         make_nocopy(convert_expr(a.child[2], env)))
    else
        throw(TranspileError("internal error in convert_expr"))
    end
end


function scan_exprlist(a::AstNode, env::AstEnv)
    for i = 1:length(a.child)
        scan_expr(a.child[i], env)
    end
end
# return is a Array{Any}
function convert_exprlist(a::AstNode, env::AstEnv)
    r = Any[]
    for i = 1:length(a.child)
        push!(r, convert_expr(a.child[i], env))
    end
    return r
end


function scan_returncmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_returncmd(0) < 100
    if a.rule == @RULE_returncmd(1)
        scan_exprlist(a.child[1], env)
    elseif a.rule == @RULE_returncmd(2)
    else
        throw(TranspileError("internal error in scan_returncmd"))
    end
end

function convert_returncmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_returncmd(0) < 100
    if a.rule == @RULE_returncmd(1)
        b::Array{Any} = convert_exprlist(a.child[1], env)
        t = gensym()
        r = Expr(:block)
        if length(b) == 1
            push!(r.args, Expr(:(=), t, make_copy(b[1])))
        else
            push!(r.args, Expr(:(=), t, Expr(:tuple, make_tuple_array_copy(b)...)))
        end
        push!(r.args, Expr(:call, :rt_leavefunction))
        push!(r.args, Expr(:return, t))
        return r;
    elseif a.rule == @RULE_returncmd(2)
        return Expr(:return, :nothing)
    else
        throw(TranspileError("internal error in convert_returncmd"))
    end
end

function scan_add_declaration(s::String, typ::String, env::AstEnv)
    if env.at_top
        if haskey(env.declared_identifiers, s)
            delete!(env.declared_identifiers, s)
        elseif !haskey(env.appeared_identifiers, s)
            env.declared_identifiers[s] = typ
        end
    else
        delete!(env.declared_identifiers, s)
    end
    env.appeared_identifiers[s] = 1    
end

function scan_add_appearance(s::String, env::AstEnv)
    env.appeared_identifiers[s] = 1    
end


function push_incrementby!(out::Expr, left::AstNode, right::Int, env::AstEnv)
    if left.rule == @RULE_expr(2) || left.rule == @RULE_elemexpr(2)
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(2)
            b = a.child[1]::AstNode
            @assert 0 < b.rule - @RULE_extendedid(0) < 100
            if b.rule == @RULE_extendedid(1)
                var = b.child[1]::String
                if haskey(env.declared_identifiers, var)
                    push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign, Symbol(var), Expr(:call, :rtplus, Symbol(var), right))))
                else
                    push!(out.args, Expr(:call, :rt_incrementby, makeunknown(var), right))
                end
            elseif b.rule == @RULE_extendedid(2)
                @assert is_empty(env.declared_identifiers)
                s = make_nocopy(convert_expr(b.child[1], env))
                push!(out.args, Expr(:call, :rt_incrementby, Expr(:call, :rt_backtick, s), right))
            else
                throw(TranspileError("cannot increment/decrement lhs"))
            end
        elseif a.rule == @RULE_elemexpr(4)
            b = convert_expr(a.child[1], env)
            c = a.child[2]
            c.child[1].rule == @RULE_extendedid(1) || throw(TranspileError("rhs of dot in assignment is no good"))
            s = c.child[1].child[1]::String
            length(s) < 2 || s[1:2] != "r_" || throw(TranspileError("cannot assign to r_ member of a newstruct"))
            is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
            if isa(b, Symbol)
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
            else
                t = gensym()
                push!(out.args, Expr(:(=), t, Expr(:call, isa(b, SName) ? :rt_make : :rt_ref, b)))    # make returns a reference
                b = Expr(:(.), t, QuoteNode(Symbol(s)))
            end
            push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign, b, Expr(:call, :rtplus, b, right))))
        else
            throw(TranspileError("cannot increment lhs"))
        end
    elseif left.rule == @RULE_extendedid(1)
        var = left.child[1]::String
        if haskey(env.declared_identifiers, var)
            push!(out.args, Expr(:(=), Symbol(var), Expr(:rt_assign, Symbol(var), Expr(:call, :rtplus, Symbol(var), right))))
        else
            push!(out.args, Expr(:call, :rt_incrementby, makeunknown(var), right))
        end
    elseif left.rule == @RULE_extendedid(2)
        @assert is_empty(env.declared_identifiers)
        s = make_nocopy(convert_expr(left.child[1], env))
        push!(out.args, Expr(:call, :rt_incrementby, Expr(:call, :rt_backtick, s), right))
    elseif left.rule == @RULE_expr(3)
        t1 = gensym()
        t2 = gensym()
        t3 = gensym()
        push!(out.args, Expr(:(=), t1, make_nocopy(convert_expr(left.child[1], env))))
        push!(out.args, Expr(:(=), t2, make_nocopy(convert_expr(left.child[2], env))))
        push!(out.args, Expr(:(=), t3, make_nocopy(convert_expr(left.child[3], env))))
        push!(out.args, Expr(:call, :rt_setindex, t1, t2, t3,
                            Expr(:call, :rtplus, Expr(:call, :rt_getindex, t1, t2, t3), right)))
    elseif left.rule == @RULE_expr(4)
        t1 = gensym()
        t2 = gensym()
        push!(out.args, Expr(:(=), t1, make_nocopy(convert_expr(left.child[1], env))))
        push!(out.args, Expr(:(=), t2, make_nocopy(convert_expr(left.child[2], env))))
        push!(out.args, Expr(:call, :rt_setindex, t1, t2,
                            Expr(:call, :rtplus, Expr(:call, :rt_getindex, t1, t2), right)))
    else
        throw(TranspileError("cannot increment/decrement lhs"))
    end
end

function scan_assignment(left::AstNode, env::AstEnv)
    if left.rule == @RULE_expr(2) || left.rule == @RULE_elemexpr(2)
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(2)
            b = a.child[1]::AstNode
            @assert 0 < b.rule - @RULE_extendedid(0) < 100
            if b.rule == @RULE_extendedid(1)
                scan_add_appearance(b.child[1]::String, env)
            elseif b.rule == @RULE_extendedid(2)
                empty!(env.declared_identifiers)
                env.everything_is_screwed = true
            end
        elseif a.rule == @RULE_elemexpr(4)
            scan_expr(a.child[1], env)
        elseif a.rule == @RULE_elemexpr(9)
        end
    elseif left.rule == @RULE_extendedid(1)
        scan_add_appearance(left.child[1]::String, env)
    elseif left.rule == @RULE_extendedid(2)
        empty!(env.declared_identifiers)
        env.everything_is_screwed = true
    elseif left.rule == @RULE_expr(3)
        scan_expr(left.child[1], env)
        scan_expr(left.child[2], env)
        scan_expr(left.child[3], env)
    elseif left.rule == @RULE_expr(4)
        scan_expr(left.child[1], env)
        scan_expr(left.child[2], env)
    else
        throw(TranspileError("internal error in scan_assignment"))
    end
end

function push_assignment!(out::Expr, left::AstNode, right, env::AstEnv)
    if left.rule == @RULE_expr(2) || left.rule == @RULE_elemexpr(2)
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(2)
            b = a.child[1]::AstNode
            @assert 0 < b.rule - @RULE_extendedid(0) < 100
            if b.rule == @RULE_extendedid(1)
                var = b.child[1]::String
                if haskey(env.declared_identifiers, var)
                    push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign, Symbol(var), right)))
                else
                    push!(out.args, Expr(:call, :rtassign, makeunknown(var), right))
                end
            elseif b.rule == @RULE_extendedid(2)
                @assert is_empty(env.declared_identifiers)
                s = make_nocopy(convert_expr(b.child[1], env))
                push!(out.args, Expr(:call, :rtassign, Expr(:call, :rt_backtick, s), right))
            else
                throw(TranspileError("cannot assign to lhs"))
            end
        elseif a.rule == @RULE_elemexpr(4)
            b = convert_expr(a.child[1], env)
            c = a.child[2]
            c.child[1].rule == @RULE_extendedid(1) || throw(TranspileError("rhs of dot in assignment is no good"))
            s = c.child[1].child[1]::String
            length(s) < 2 || s[1:2] != "r_" || throw(TranspileError("cannot assign to r_ member of a newstruct"))
            is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
            if isa(b, Symbol)
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
                push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign, b, right)))                
            else
                b = Expr(:call, isa(b, SName) ? :rt_make : :rt_ref, b)
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
                push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign, b, right)))
            end
        elseif a.rule == @RULE_elemexpr(9)
            t = a.child[1]::Int
            haskey(system_var_to_string, t) || throw(TranspileError("internal error push_assignment - elemexpr 9"))
            push!(out.args, Expr(:call, Symbol("rt_set_" * system_var_to_string[t]), right))
        else
            throw(TranspileError("cannot assign to lhs"))
        end
    elseif left.rule == @RULE_extendedid(1)
        var = left.child[1]::String
        if haskey(env.declared_identifiers, var)
            push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign, Symbol(var), right)))
        else
            push!(out.args, Expr(:call, :rtassign, makeunknown(var), right))
        end
    elseif left.rule == @RULE_extendedid(2)
        @assert is_empty(env.declared_identifiers)
        s = make_nocopy(convert_expr(left.child[1], env))
        push!(out.args, Expr(:call, :rtassign, Expr(:call, :rt_backtick, s), right))
    elseif left.rule == @RULE_expr(3)
        push!(out.args, Expr(:call, :rt_setindex, make_nocopy(convert_expr(left.child[1], env)),
                                                  make_nocopy(convert_expr(left.child[2], env)),
                                                  make_nocopy(convert_expr(left.child[3], env)),
                                                  make_nocopy(right)))
    elseif left.rule == @RULE_expr(4)
        push!(out.args, Expr(:call, :rt_setindex, make_nocopy(convert_expr(left.child[1], env)),
                                                  make_nocopy(convert_expr(left.child[2], env)),
                                                  make_nocopy(right)))
    else
        throw(TranspileError("cannot assign to lhs"))
    end
end

# recursive helper to flatten out exprlist
function push_exprlist_expr!(l::Array{AstNode}, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_exprlist(0) < 100
    for i in a.child
        if i.rule == @RULE_expr(2) && i.child[1].rule == @RULE_elemexpr(37)
            push_exprlist_expr!(l, i.child[1].child[1], env)
        else
            push!(l, i)
        end
    end
end


function scan_assign(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_assign(0) < 100
    if a.rule == @RULE_assign(1)
        scan_exprlist(a.child[2], env)
        left::AstNode = a.child[1]
        lhs::Array{AstNode} = AstNode[]
        if left.rule == @RULE_left_value(1)
            scan_declare_ip_variable!(lhs, left.child[1], env)
        elseif left.rule == @RULE_left_value(2)
            push_exprlist_expr!(lhs, left.child[1], env)
        else
            throw(TranspileError("internal error in scan_assign 1"))
        end
        for L in lhs
            scan_assignment(L, env)
        end
    else
        throw(TranspileError("internal error in scan_assign"))
    end
end
# return is a block
function convert_assign(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_assign(0) < 100
    if a.rule == @RULE_assign(1)
        left::AstNode = a.child[1]
        lhs::Array{AstNode} = AstNode[]
        rhs::Array{Any} = convert_exprlist(a.child[2], env)
        r = Expr(:block)
        if left.rule == @RULE_left_value(1)
            r = convert_declare_ip_variable!(lhs, left.child[1], env)
        elseif left.rule == @RULE_left_value(2)
            push_exprlist_expr!(lhs, left.child[1], env)
        else
            throw(TranspileError("internal error in convert_assign 1"))
        end
        if length(lhs) == 1
            if length(rhs) == 1
                push_assignment!(r, lhs[1], make_copy(rhs[1]), env)
            else
                push_assignment!(r, lhs[1], Expr(:tuple, make_tuple_array_copy(rhs)...), env)
            end
        else
            t = gensym()
            push!(r.args, Expr(:(=), t, Expr(:tuple, make_tuple_array_copy(rhs)...)))
            push!(r.args, Expr(:call, :rt_checktuplelength, t, length(lhs))) # TODO opt: runtime check can sometimes be avoided
            for i in 1:length(lhs)
                push_assignment!(r, lhs[i], Expr(:ref, t, i), env)
            end
        end
        return r
    else
        throw(TranspileError("internal error in convert_assign"))
    end
end


function scan_typecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_typecmd(0) < 100
    if a.rule == @RULE_typecmd(1)
        scan_expr(a.child[1], env)
    elseif a.rule == @RULE_typecmd(2)
        scan_exprlist(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_typecmd"))
    end
end

function convert_typecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_typecmd(0) < 100
    t = Expr(:block)
    if a.rule == @RULE_typecmd(1)
        b = convert_expr(a.child[1], env)
        push!(t.args, Expr(:call, :rt_printouttype, b))
    elseif a.rule == @RULE_typecmd(2)
        for b in convert_exprlist(a.child[1], env)
            if b isa Expr && b.head == :block && length(b.args) > 0 && b.args[length(b.args)] == :nothing
                push!(t.args, b)
            else
                push!(t.args, Expr(:call, :rt_printout, b))
            end
        end
    else
        throw(TranspileError("internal error in convert_typecmd"))
    end
    return t
end


function push_rlist_expr!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(2) && a.child[1].rule == @RULE_elemexpr(2) &&
                        a.child[1].child[1].rule == @RULE_extendedid(1)
        push!(r.args, makeunknown(a.child[1].child[1].child[1]::String))
    elseif a.rule == @RULE_expr(2) && a.child[1].rule == @RULE_elemexpr(37)
        for b in a.child[1].child
            push_rlist_expr!(r, b, env)
        end
    else
        push!(r.args, convert_expr(a, env))
    end
end

function make_rlist(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_rlist(0) < 100
    r = Expr(:vect)
    if a.rule == @RULE_rlist(1)
        push_rlist_expr!(r, a.child[1], env)
    elseif a.rule == @RULE_rlist(2)
        push_rlist_expr!(r, a.child[1], env::AstEnv)
        for b in a.child[2].child
            push_rlist_expr!(r, b, env::AstEnv)
        end
    else
        throw(TranspileError("internal error in make_rlist"))
    end
    return r
end

function push_ordering_orderelem!(r::Expr, a::AstNode, anv::AstEnv)
    @assert 0 < a.rule - @RULE_orderelem(0) < 100
    if a.rule == @RULE_orderelem(1)
        push!(r.args, Expr(:vect, a.child[1].child[1]::String))
    elseif a.rule == @RULE_orderelem(2)
        b = convert_exprlist(a.child[2])
        push!(r.args, Expr(:vect, a.child[1].child[1]::String, make_tuple_array_copy(b)...))
    else
        throw(TranspileError("internal error in push_ordering_orderelem"))
    end
end

function push_ordering_OrderingList!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_OrderingList(0) < 100
    if a.rule == @RULE_OrderingList(1)
        push_ordering_orderelem(r, a.child[1], env)
    elseif a.rule == @RULE_OrderingList(2)
        push_ordering_orderelem(r, a.child[1], env)
        push_ordering_OrderingList!(r, a.child[2], env)
    else
        throw(TranspileError("internal error in push_ordering_OrderingList"))
    end
end

function make_ordering(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ordering(0) < 100
    r = Expr(:vect)
    if a.rule == @RULE_ordering(1)
        push_ordering_orderelem!(r, a.child[1], env)
    elseif a.rule == @RULE_ordering(2)
        push_ordering_OrderingList!(r, a.child[1], env)
    else
        throw(TranspileError("internal error in make_ring_ordering"))
    end
    return r
end


function rt_parse_coeff(coeff)
    r = Any[]
    length(coeff) > 0 || rt_error("bad coefficient specification")
    a = coeff[1]
    if isa(a, SName)
        if a.name == :real || a.name == :complex
            a = String(a.name)
        else
            a = rt_make(a)
            isa(a, Int) || rt_error("bad coefficient specification")
        end
    else
        isa(a, Int) || rt_error("bad coefficient specification")
    end
    push!(r, a)
    for a in coeff[2:end]
        if isa(a, SName)
            a = rt_make(a, true)
            if isa(a, SName)
                a = String(a.name)
            else
                isa(a, Int) || rt_error("bad coefficient specification")
            end
        else
            isa(a, Int) || rt_error("bad coefficient specification")
        end
        push!(r, a)
    end
    return r
end

function rt_parse_var(var)
    r = String[]
    length(var) > 0 || rt_error("bad variable specification")
    for a in var
        if isa(a, SName)
            push!(r, String(a.name))
        else
            rt_error("bad variable specification")
        end
    end
    return r
end

function rt_flatten_ord_weights(w::Array{Int, 1}, a::Any)
    if isa(a, Int)
        push!(w, a)
    elseif isa(a, SIntVec)
        append!(w, a.vector)
    elseif isa(a, SIntMat)
        append!(w, vec(a.matrix))
    else
        rt_error("bad order specification")
    end
end

function rt_blocksize_simple(w::Array{Int, 1})
    blocksize = 0
    if length(w) == 1
        blocksize = w[1]
    elseif length(w) != 0
        rt_error("bad order specification")
    end
    return blocksize
end

function rt_parse_ord(ord)
    isa(ord[1], String) || rt_error("bad order specification")
    order = libSingular.ringorder_no
    blocksize = 0
    weights = Int[]
    w = Int[]
    for a in ord[2:end]
        rt_flatten_ord_weights!(w, a)
    end
    if ord[1] == "lp"
        order = libSingular.ringorder_lp
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "rp"
        order = libSingular.ringorder_rp
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "dp"
        order = libSingular.ringorder_dp
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "Dp"
        order = libSingular.ringorder_Dp
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "ls"
        order = libSingular.ringorder_ls
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "ds"
        order = libSingular.ringorder_ds
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "Ds"
        order = libSingular.ringorder_Ds
        blocksize = rt_blocksize_simple(w)
    elseif ord[1] == "wp"
        order = libSingular.ringorder_wp
        blocksize, weights = rt_blocksize_weights(w)
    elseif ord[1] == "ws"
        order = libSingular.ringorder_ws
        blocksize, weights = rt_blocksize_weights(w)
    elseif ord[1] == "Wp"
        order = libSingular.ringorder_Wp
        blocksize, weights = rt_blocksize_weights(w)
    elseif ord[1] == "Ws"
        order = libSingular.ringorder_Ws
        blocksize, weights = rt_blocksize_weights(w)
    elseif ord[1] == "M"
        order = libSingular.ringorder_M
        blocksize = isqrt(length(w))
        weights = w
        (blocksize > 0 && blocksize*blocksize == length(w)) || rt_error("bad order specification")
    else
        rt_error("bad order specification")
    end
    return libSingular.OrderingEntry(order, blocksize, weights)
end


function rt_declare_assign_ring(a::SName, coeff, var, ord)
    coeff = rt_parse_coeff(coeff)
    var = rt_parse_var(var)
    @error_check(length(ord) > 0, "bad variable specification")
    ord = [rt_parse_ord(a) for a in ord]
    r = SRing(true, libSingular.createRing(coeff, var, ord), length(rtGlobal.callstack))
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(true, a.name, SRing)
        push!(rtGlobal.local_rindep_vars, Pair(a.name, r))
    else
        d = rt_check_declaration_global(true, a.name, SRing)
        d[a.name] = r
    end
    rtGlobal.callstack[n].current_ring = r
    return
end


function scan_ringcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ringcmd(0) < 100
    env.everything_is_screwed = true
end

function convert_ringcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ringcmd(0) < 100
    r = Expr(:block)
    if a.rule == @RULE_ringcmd(1)
        m = a.child[1]
        (m.rule == @RULE_elemexpr(2) && m.child[1].rule == @RULE_extendedid(1)) || throw(TranspileError("declaration expects identifer name"))
        push!(r.args, Expr(:call, :rt_declare_assign_ring,
                                        makeunknown(m.child[1].child[1]::String),
                                        make_rlist(a.child[2], env),
                                        make_rlist(a.child[3], env),
                                        make_ordering(a.child[4], env)))
        return r
    else
        throw(TranspileError("internal error in convert_ringcmd"))
    end
end



function prepend_killelem!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(2) && a.child[1].rule == @RULE_extendedid(1)
        push!(r.args, Expr(:call, :rtkill, makeunknown(a.child[1].child[1]::String)))
    else
        throw(TranspileError("bad argument to kill"))
    end
end

function scan_killcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_killcmd(0) < 100
    empty!(env.declared_identifiers)
    env.everything_is_screwed = true
end

function convert_killcmd(a::AstNode, env::AstEnv)
    r = Expr(:block)
    while true
        @assert 0 < a.rule - @RULE_killcmd(0) < 100
        if a.rule == @RULE_killcmd(1)
            prepend_killelem!(r, a.child[1], env)
            break
        elseif a.rule == @RULE_killcmd(2)
            prepend_killelem!(r, a.child[2], env)
            a = a.child[1]
        else
            throw(TranspileError("internal error in convert_killcmd"))
        end
    end
    return r
end

function scan_scriptcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_scriptcmd(0) < 100
    if a.rule == @RULE_scriptcmd(1)
        empty!(env.declared_identifiers)
        env.everything_is_screwed = true
    else
        throw(TranspileError("internal error in scan_scriptcmd"))
    end
end

function convert_scriptcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_scriptcmd(0) < 100
    if a.rule == @RULE_scriptcmd(1)
        t = a.child[1]::Int
        if t == Int(LIB_CMD)
            return Expr(:call, :rt_load, true, a.child[2].child[1]::String)
        else
            throw(TranspileError("invalid script command"))
        end
    else
        throw(TranspileError("internal error in convert_scriptcmd"))
    end
end

function scan_command(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_command(0) < 100
    if a.rule == @RULE_command(1)
        return scan_assign(a.child[1], env)
    elseif a.rule == @RULE_command(3)
        return scan_killcmd(a.child[1], env)
    elseif a.rule == @RULE_command(6)
        return scan_ringcmd(a.child[1], env)
    elseif a.rule == @RULE_command(7)
        return scan_scriptcmd(a.child[1], env)
    elseif a.rule == @RULE_command(9)
        return scan_typecmd(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_command"))
    end
end

function convert_command(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_command(0) < 100
    if a.rule == @RULE_command(1)
        return convert_assign(a.child[1], env)
    elseif a.rule == @RULE_command(3)
        return convert_killcmd(a.child[1], env)
    elseif a.rule == @RULE_command(6)
        return convert_ringcmd(a.child[1], env)
    elseif a.rule == @RULE_command(7)
        return convert_scriptcmd(a.child[1], env)
    elseif a.rule == @RULE_command(9)
        return convert_typecmd(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_command"))
    end
end



function scan_declared_var(v::AstNode, typ::String, env::AstEnv)
    @assert 0 < v.rule - @RULE_extendedid(0) < 100
    if v.rule == @RULE_extendedid(1)
        scan_add_declaration(v.child[1]::String, typ, env)
        return
    else v.rule == @RULE_extendedid(2)
        empty!(env.declared_identifiers)
        env.everything_is_screwed = true
    end
end

function convert_declared_var(v::AstNode, typ::String, env::AstEnv, extra_args...)
    @assert 0 < v.rule - @RULE_extendedid(0) < 100
    if v.rule == @RULE_extendedid(1)
        s = v.child[1]::String
        if haskey(env.declared_identifiers, s)
            @assert env.declared_identifiers[s] == typ
            return Expr(:(=), Symbol(s), Expr(:call, Symbol("rt_defaultconstructor_"*typ), extra_args...))
        else
            return Expr(:call, Symbol("rt_declare_"*typ), makeunknown(s), extra_args...)
        end
    else v.rule == @RULE_extendedid(2)
        @assert is_empty(env.declared_identifiers)
        s = make_nocopy(convert_expr(v.child[1], env))
        return Expr(:call, Symbol("rt_declare_"*typ), Expr(:call, :rt_backtick, s), extra_args...)
    end
end


function scan_declare_ip_variable!(vars::Array{AstNode}, a::AstNode, env::AstEnv)
    while true
        @assert 0 < a.rule - @RULE_declare_ip_variable(0) < 100
        if @RULE_declare_ip_variable(1) <= a.rule <= @RULE_declare_ip_variable(4) ||
                                               a.rule == @RULE_declare_ip_variable(8)
            pushfirst!(vars, a.child[2])
            haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in scan_declare_ip_variable"))
            typ = cmd_to_builtin_type_string[a.child[1]::Int]
            for v in vars
                scan_declared_var(v, typ, env)
            end
            return
        elseif a.rule == @RULE_declare_ip_variable(99)
            pushfirst!(vars, a.child[2])
            typ = a.child[1]::String
            for v in vars
                scan_declared_var(v, typ, env)
            end
            return
        elseif a.rule == @RULE_declare_ip_variable(5) || a.rule == @RULE_declare_ip_variable(6)
            if a.rule == @RULE_declare_ip_variable(5)
                scan_expr(a.child[3], env)
                scan_expr(a.child[4], env)
            end
            pushfirst!(vars, a.child[2])
            t::AstNode = a.child[1]
            if t.rule == @RULE_mat_cmd(2)
                for v in vars
                    scan_declared_var(v, "intmat", env)
                end
            elseif t.rule == @RULE_mat_cmd(3)
                for v in vars
                    scan_declared_var(v, "bigintmat", env)
                end
            else
                throw(TranspileError("internal error in scan_declare_ip_variable 5"))
            end
            return
        elseif a.rule == @RULE_declare_ip_variable(7)
            pushfirst!(vars, a.child[2])
            a = a.child[1]
        else
            throw(TranspileError("internal error in scan_declare_ip_variable "*string(a.rule)))
        end
    end    
end

# return is always a block
function convert_declare_ip_variable!(vars::Array{AstNode}, a::AstNode, env::AstEnv)
    while true
        @assert 0 < a.rule - @RULE_declare_ip_variable(0) < 100
        if @RULE_declare_ip_variable(1) <= a.rule <= @RULE_declare_ip_variable(4) ||
                                               a.rule == @RULE_declare_ip_variable(8)
            haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in convert_declare_ip_variable"))
            typ = cmd_to_builtin_type_string[a.child[1]::Int]
            pushfirst!(vars, a.child[2])
            r = Expr(:block)
            for v in vars
                push!(r.args, convert_declared_var(v, typ, env))
            end
            return r
        elseif a.rule == @RULE_declare_ip_variable(99)
            typ = a.child[1]::String
            pushfirst!(vars, a.child[2])
            r = Expr(:block)
            for v in vars
                push!(r.args, convert_declared_var(v, typ, env))
            end
            return r
        elseif a.rule == @RULE_declare_ip_variable(5) || a.rule == @RULE_declare_ip_variable(6)
            if a.rule == @RULE_declare_ip_variable(5)
                numrows = convert_expr(a.child[3], env)
                numcols = convert_expr(a.child[4], env)
            else
                numrows = numcols = 1 # default matrix size is 1x1
            end
            pushfirst!(vars, a.child[2])
            t::AstNode = a.child[1]
            r = Expr(:block)
            if t.rule == @RULE_mat_cmd(2)
                for v in vars
                    push!(r.args, convert_declared_var(v, "intmat", env, numrows, numcols))
                    numrows = numcols = 1 # the rest of the matrices are 1x1
                end
            elseif t.rule == @RULE_mat_cmd(3)
                for v in vars
                    push!(r.args, convert_declared_var(v, "bigintmat", env, numrows, numcols))
                    numrows = numcols = 1 # the rest of the matrices are 1x1
                end
            else
                throw(TranspileError("internal error in convert_declare_ip_variable 5|6"))
            end
            return r
        elseif a.rule == @RULE_declare_ip_variable(7)
            pushfirst!(vars, a.child[2])
            a = a.child[1]
        else
            throw(TranspileError("internal error in convert_declare_ip_variable "*string(a.rule)))
        end
    end
end


function join_blocks!(a::Expr, b::Expr)
    for c in b.args
        if c isa Expr && c.head == :block
            join_blocks!(a, c)
        elseif c != :nothing
            push!(a.args, c)
        end
    end
end


function block_append!(t::Expr, b)
    if b isa Expr && b.head == :block
        join_blocks!(t, b)
    elseif b != :nothing
        push!(t.args, b)
    end
end


function scan_ifcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ifcmd(0) < 100
    if a.rule == @RULE_ifcmd(1)
        scan_expr(a.child[1], env)
        scan_lines(a.child[2], env, false)
    elseif a.rule == @RULE_ifcmd(2)
        scan_lines(a.child[1], env, false)
    elseif a.rule == @RULE_ifcmd(3)
        scan_expr(a.child[1], env)
    elseif a.rule == @RULE_ifcmd(4)
    elseif a.rule == @RULE_ifcmd(5)
    else
        throw(TranspileError("internal error in convert_ifcmd"))
    end
end

function convert_ifcmd(a::AstNode, env::AstEnv) #perfect
    @assert 0 < a.rule - @RULE_ifcmd(0) < 100
    if a.rule == @RULE_ifcmd(1)
        test = convert_expr(a.child[1], env)
        body = convert_lines(a.child[2], env)
        return Expr(:if, Expr(:call, :rt_asbool, test), body)
    elseif a.rule == @RULE_ifcmd(2)
        # if the "else" were correctly paired with an "if", if should have been handled by find_if_else
        throw(TranspileError("else without if"))
    elseif a.rule == @RULE_ifcmd(3)
        test = convert_expr(a.child[1], env)
        return Expr(:if, Expr(:call, :rt_asbool, test), Expr(:break))
    elseif a.rule == @RULE_ifcmd(4)
        return Expr(:break)
    elseif a.rule == @RULE_ifcmd(5)
        return Expr(:continue)
    else
        throw(TranspileError("internal error in convert_ifcmd"))
    end
end


function scan_whilecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_whilecmd(0) < 100
    if a.rule == @RULE_whilecmd(1)
        scan_expr(a.child[1], env)
        scan_lines(a.child[2], env, false)
    else
        throw(TranspileError("internal error in scan_whilecmd"))
    end
end

function convert_whilecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_whilecmd(0) < 100
    if a.rule == @RULE_whilecmd(1)
        test = convert_expr(a.child[1], env)
        return Expr(:while, Expr(:call, :rt_asbool, test), convert_lines(a.child[2], env))
    else
        throw(TranspileError("internal error in convert_whilecmd"))
    end
end


function scan_forcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_forcmd(0) < 100
    if a.rule == @RULE_forcmd(1)
        scan_npprompt(a.child[1], env)
        scan_lines(a.child[4], env, false)
        scan_expr(a.child[2], env)
        scan_npprompt(a.child[3], env)
    else
        throw(TranspileError("internal error in scan_whilecmd"))
    end
end

function convert_forcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_forcmd(0) < 100
    if a.rule == @RULE_forcmd(1)
        r = Expr(:block)
        body = Expr(:block)
        init = convert_npprompt(a.child[1], env)
        test = convert_expr(a.child[2], env)
        block_append!(r, init)
        block_append!(body, convert_lines(a.child[4], env))
        block_append!(body, convert_npprompt(a.child[3], env))
        push!(r.args, Expr(:while, Expr(:call, :rt_asbool, test), body))
        return r
    else
        throw(TranspileError("internal error in convert_whilecmd"))
    end
end


#return (false, 0) or (true, ifexpr)
function find_if_else(a::AstNode, i::Int, env::AstEnv)

    if i >= length(a.child)
        return false, 0
    end

    b = a.child[i]
    if b.rule != @RULE_pprompt(1) && b.rule != @RULE_top_pprompt(1)
        return false, 0
    end
    b = b.child[1]
    if b.rule != @RULE_flowctrl(1)
        return false, 0
    end
    b = b.child[1]
    if b.rule != @RULE_ifcmd(1)
        return false, 0
    end

    c = a.child[i + 1]
    if c.rule != @RULE_pprompt(1) && c.rule != @RULE_top_pprompt(1)
        return false, 0
    end
    c = c.child[1]
    if c.rule != @RULE_flowctrl(1)
        return false, 0
    end
    c = c.child[1]
    if c.rule != @RULE_ifcmd(2)
        return false, 0
    end

    return true, Expr(:if, Expr(:call, :rt_asbool, convert_expr(b.child[1], env)),
                           convert_lines(b.child[2], env),
                           convert_lines(c.child[1], env))
end


function scan_procarglist(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_procarglist(0) < 100
    for i in a.child
        scan_procarg(i, env)
    end
end

function convert_proc_prologue(body::Expr, env::AstEnv)
    empty!(body.args)
    push!(body.args, Expr(:call, :rt_enterfunction, QuoteNode(env.package)))
    for v in env.declared_identifiers
        push!(body.args, Expr(:local, Expr(:(::), Symbol(v[1]), convert_typestring_tosymbol(v[2]))))
    end
end

function convert_procarglist!(arglist::Vector{Symbol}, body::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_procarglist(0) < 100
    for i in a.child
        convert_procarg!(arglist, body, i, env)
    end
end

function scan_procarg(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_procarg(0) < 100
    if a.rule == @RULE_procarg(1)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        t = a.child[1]::String
        s = b.child[1]::String
        !haskey(env.declared_identifiers, s) || throw(TranspileError("duplicate argument name"))
        env.declared_identifiers[s] = t
    elseif @RULE_procarg(2) <= a.rule <= @RULE_procarg(7)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in scan_procarg"))
        t = cmd_to_builtin_type_string[a.child[1]::Int]
        s = b.child[1]::String
        !haskey(env.declared_identifiers, s) || throw(TranspileError("duplicate argument name"))
        env.declared_identifiers[s] = t
    else
        throw(TranspileError("internal error in scan_procarg"))
    end
end

function convert_procarg!(arglist::Vector{Symbol}, body::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_procarg(0) < 100
    if a.rule == @RULE_procarg(1)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        t = a.child[1]::String
        s = b.child[1]::String
        if haskey(env.declared_identifiers, s)
            push!(body.args, Expr(:(=), Symbol(s), Expr(:call, Symbol("rt_convert2"*t), Symbol("#"*s))))
        else
            push!(body.args, Expr(:call, Symbol("rt_parameter_"*t), makeunknown(s), Symbol("#"*s)))
        end
        push!(arglist, Symbol("#"*s))
    elseif @RULE_procarg(2) <= a.rule <= @RULE_procarg(7)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in scan_procarg"))
        t = cmd_to_builtin_type_string[a.child[1]::Int]
        s = b.child[1]::String
        if haskey(env.declared_identifiers, s)
            push!(body.args, Expr(:(=), Symbol(s), Expr(:call, Symbol("rt_convert2"*t), Symbol("#"*s))))
        else
            push!(body.args, Expr(:call, Symbol("rt_parameter_"*t), makeunknown(s), Symbol("#"*s)))
        end
        push!(arglist, Symbol("#"*s))
    else
        throw(TranspileError("internal error in convert_procarg"))
    end
end

function scan_proccmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_proccmd(0) < 100
    if a.rule == @RULE_proccmd(3) || a.rule == @RULE_proccmd(2) ||
       a.rule == @RULE_proccmd(13) || a.rule == @RULE_proccmd(12)
    else
        throw(TranspileError("internal error in scan_proccmd"))
    end
end

function convert_proccmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_proccmd(0) < 100
    if a.rule == @RULE_proccmd(3) || a.rule == @RULE_proccmd(2) ||
       a.rule == @RULE_proccmd(13) || a.rule == @RULE_proccmd(12)
        s = a.child[1]::String
        internalfunc = procname_to_func(s)
        args = Symbol[]
        body = Expr(:block)
        newenv = AstEnv(true, env.package, s, true, false, false, Dict{String, Int}(), Dict{String, String}())
        if a.rule == @RULE_proccmd(3) || a.rule == @RULE_proccmd(13)
            scan_procarglist(a.child[2], newenv)
            scan_lines(a.child[3], newenv, true)
            convert_proc_prologue(body, newenv)
            convert_procarglist!(args, body, a.child[2], newenv)
            join_blocks!(body, convert_lines(a.child[3], newenv))
        else
            # empty args
            scan_lines(a.child[2], newenv, true)
            convert_proc_prologue(body, newenv)
            join_blocks!(body, convert_lines(a.child[2], newenv))
        end
        #procedures return nothing by default
        push!(body.args, Expr(:call, :rt_leavefunction))
        push!(body.args, Expr(:return, :nothing))
        r = Expr(:block)
        push!(r.args, Expr(:call, :rt_declare_proc, makeunknown(s)))
        push!(r.args, Expr(:function, Expr(:call, internalfunc, args...), body))
        push!(r.args, Expr(:call, :rtassign, makeunknown(s), Expr(:call, :SProc, internalfunc, s, QuoteNode(env.package))))
        return r
    else
        throw(TranspileError("internal error in convert_proccmd"))
    end
end


function scan_flowctrl(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(1)
        scan_ifcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(2)
        scan_whilecmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(4)
        scan_forcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(5)
        scan_proccmd(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_flowctrl"))
    end
end

function convert_flowctrl(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(1)
        return convert_ifcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(2)
        return convert_whilecmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(4)
        return convert_forcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(5)
        return convert_proccmd(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_flowctrl"))
    end
end


function scan_pprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_pprompt(0) < 100
    if a.rule == @RULE_pprompt(1)
        scan_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_pprompt(2)
        scan_command(a.child[1], env)
    elseif a.rule == @RULE_pprompt(3)
        vars = AstNode[]
        scan_declare_ip_variable!(vars, a.child[1], env)
    elseif a.rule == @RULE_pprompt(4)
        scan_returncmd(a.child[1], env)
    elseif a.rule == @RULE_pprompt(6)
    else
        throw(TranspileError("internal error in scan_pprompt"))
    end    
end

function convert_pprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_pprompt(0) < 100
    if a.rule == @RULE_pprompt(1)
        return convert_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_pprompt(2)
        return convert_command(a.child[1], env)
    elseif a.rule == @RULE_pprompt(3)
        vars = AstNode[]
        return convert_declare_ip_variable!(vars, a.child[1], env)
    elseif a.rule == @RULE_pprompt(4)
        return convert_returncmd(a.child[1], env)
    elseif a.rule == @RULE_pprompt(6)
        return :nothing
    else
        throw(TranspileError("internal error in convert_pprompt"))
    end
end


function scan_npprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_npprompt(0) < 100
    if a.rule == @RULE_npprompt(1)
        scan_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_npprompt(2)
        scan_command(a.child[1], env)
    elseif a.rule == @RULE_npprompt(3)
        vars = AstNode[]
        scan_declare_ip_variable!(vars, a.child[1], env)
    elseif a.rule == @RULE_npprompt(4)
        scan_returncmd(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_pprompt"))
    end
end

function convert_npprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_npprompt(0) < 100
    if a.rule == @RULE_npprompt(1)
        return convert_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_npprompt(2)
        return convert_command(a.child[1], env)
    elseif a.rule == @RULE_npprompt(3)
        vars = AstNode[]
        return convert_declare_ip_variable!(vars, a.child[1], env)
    elseif a.rule == @RULE_npprompt(4)
        return convert_returncmd(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_pprompt"))
    end
end


function scan_top_pprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_top_pprompt(0) < 100
    for i in a.child
        scan_top_pprompt(i, env)
    end
end

function convert_top_pprompt(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_top_pprompt(0) < 100
    if a.rule == @RULE_top_pprompt(1)
        return convert_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(2)
        return convert_command(a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(3)
        vars = AstNode[] # unused
        return convert_declare_ip_variable!(vars, a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(5)
        return :nothing
    elseif a.rule == @RULE_top_pprompt(5)
        return :nothing
    else
        throw(TranspileError("internal error in convert_top_pprompt"))
    end
end

function scan_lines(a::AstNode, env::AstEnv, at_top::Bool)
    @assert 0 < a.rule - @RULE_lines(0) < 100
    if !rtGlobal.optimize_locals
        empty!(env.declared_identifiers)
        return
    end
    for i in a.child
        env.at_top = at_top
        scan_pprompt(i, env)
    end
    if at_top
        if env.everything_is_screwed
            empty!(env.declared_identifiers)
        elseif env.rings_are_screwed
            env.declared_identifiers = filter(x->(!type_is_ring_dependent(last(x))), env.declared_identifiers)
        end
    end
end

# return is always a block
function convert_lines(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_lines(0) < 100
    t = Expr(:block)
    i = 1
    while i <= length(a.child)
        have_if_else, b = find_if_else(a, i, env)
        if have_if_else
            i += 1
        else
            b = convert_pprompt(a.child[i], env)
        end
        block_append!(t, b)
        i += 1
    end
    return t
end


function scan_toplines(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_top_lines(0) < 100
    for i in a.child
        scan_top_pprompt(i, env)
    end
end

# return is always a toplevel
function convert_toplines(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_top_lines(0) < 100
    r = Expr(:toplevel)
    i = 1
    while i <= length(a.child)
        have_if_else, b = find_if_else(a, i, env)
        if have_if_else
            i += 1
        else
            b = convert_top_pprompt(a.child[i], env)
        end
        block_append!(r, b)
        i += 1
    end
    return r
end

import Libdl

function execute(s::String; debuglevel::Int = 0)

    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))

    ast = @eval ccall((:singular_parse, $libpath), Any,
                    (Cstring, Ptr{Ptr{UInt8}}, UInt),
                    $s, $rtGlobal_NewStructNames, $(length(rtGlobal_NewStructNames)))

    if isa(ast, String)
        throw(TranspileError(ast))
    else
#        println("new strings: ", ast.child[2].child)
#        append!(rtGlobal_NewStructNames, ast.child[2].child)
#        println("rtGlobal_NewStructNames: ", rtGlobal_NewStructNames)

#        println("singular ast:")
#        astprint(ast.child[1], 0)

        t0 = time()

        env = AstEnv(false, :Top, "", true, true, true, Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast.child[1], env)
        t1 = time()

#        if debuglevel > 0
            println()
            println("---------- transpiled code ----------")
            for i in expr.args; println(i); end;
            println("------- transpiled in ", trunc(1000*(t1 - t0)), " ms -------")
            println()
#        end

        # these need to be corrected in the case that a previous eval threw
        empty!(rtGlobal.local_rindep_vars)
        empty!(rtGlobal.local_rdep_vars)
        @assert length(rtGlobal.callstack) >= 1
        resize!(rtGlobal.callstack, 1)
        eval(expr)
        return nothing
    end
end




##########################################################


function loadconvert_proccmd(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_proccmd(0) < 100
    if a.rule == @RULE_proccmd(3) || a.rule == @RULE_proccmd(2) ||
       a.rule == @RULE_proccmd(13) || a.rule == @RULE_proccmd(12)
        static = (a.rule == @RULE_proccmd(13) || a.rule == @RULE_proccmd(12))
        s = a.child[1]::String
        internalfunc = procname_to_func(s)
        args = Symbol[]
        body = Expr(:block)
        newenv = AstEnv(true, env.package, s, true, false, false, Dict{String, Int}(), Dict{String, String}())
        if a.rule == @RULE_proccmd(3) || a.rule == @RULE_proccmd(13)
            scan_procarglist(a.child[2], newenv)
            scan_lines(a.child[3], newenv, true)
            convert_proc_prologue(body, newenv)
            convert_procarglist!(args, body, a.child[2], newenv)
            join_blocks!(body, convert_lines(a.child[3], newenv))
        else
            # empty args
            scan_lines(a.child[2], newenv, true)
            convert_proc_prologue(body, newenv)
            join_blocks!(body, convert_lines(a.child[2], newenv))
        end

        #procedures return nothing by default
        push!(body.args, Expr(:call, :rt_leavefunction))
        push!(body.args, Expr(:return, :nothing))

        jfunction = eval(Expr(:function, Expr(:call, internalfunc, args...), body))

        our_proc_object = SProc(jfunction, s, env.package)

        export_packages = [env.package]
        if !static && env.export_names
            push!(export_packages, :Top)
        end
        for p in export_packages
            if haskey(rtGlobal.vars, p)
                d = rtGlobal.vars[p]
                if haskey(d, a)
                    rt_declare_warnerror(false, d[a], a, typ)
                end
            else
                d = Dict{Symbol, Any}()
                rtGlobal.vars[p] = d
            end
            d[Symbol(s)] = our_proc_object
        end
    else
        throw(TranspileError("internal error in convert_proccmd"))
    end
end


function loadconvert_example_dummy(a::AstNode, env::AstLoadEnv)
    return
end

function loadconvert_examplecmd(a::AstNode, env::AstLoadEnv)
    return
end


function loadconvert_flowctrl(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(3)
        loadconvert_example_dummy(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(5)
        loadconvert_proccmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(8)
        loadconvert_examplecmd(a.child[1], env)
    else
        rt_error("error in loadconvert_flowctrl")
    end
end


function loadconvert_assign(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_assign(0) < 100
    if a.rule == @RULE_assign(1)
        # find lhs UNKNOWN_IDEN
        b = a.child[1]
        @error_check(b.rule == @RULE_left_value(2), "???")
        b = b.child[1]
        @error_check(b.rule == @RULE_exprlist(1), "???")
        b = b.child[1]
        @error_check(b.rule == @RULE_expr(2), "???")
        b = b.child[1]
        @error_check(b.rule == @RULE_elemexpr(2), "???")
        b = b.child[1]
        @error_check(b.rule == @RULE_extendedid(1), "???")
        b = b.child[1]::String
        # find rhs stringexpr
        c = a.child[2]
        @error_check(c.rule == @RULE_exprlist(1), "???")
        c = c.child[1]
        @error_check(c.rule == @RULE_expr(2), "???")
        c = c.child[1]
        @error_check(c.rule == @RULE_elemexpr(10), "???")
        c = c.child[1]
        @error_check(c.rule == @RULE_stringexpr(1), "???")
        c = c.child[1]::String
        println(b, " -> ", c)
    else
        rt_error("internal error in loadconvert_assign")
    end
end

function loadconvert_scriptcmd(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_scriptcmd(0) < 100
    if a.rule == @RULE_scriptcmd(1)
        t = a.child[1]::Int
        if t == Int(LIB_CMD)
            rt_load(true, a.child[2].child[1]::String)
        else
            rt_error("invalid script command")
        end
    else
        rt_error("internal error in loadconvert_scriptcmd")
    end
end

function loadconvert_command(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_command(0) < 100
    if a.rule == @RULE_command(1)
        loadconvert_assign(a.child[1], env)
    elseif a.rule == @RULE_command(7)
        loadconvert_scriptcmd(a.child[1], env)
    else
        rt_error("error in loadconvert_command")
    end
end



function loadconvert_top_pprompt(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_top_pprompt(0) < 100
    if a.rule == @RULE_top_pprompt(1)
        loadconvert_flowctrl(a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(2)
        loadconvert_command(a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(5)
    else
        rt_error("error in loadconvert_top_pprompt")
    end
end


function loadconvert_toplines(a::AstNode, env::AstLoadEnv)
    for i in a.child
        loadconvert_top_pprompt(i, env)
    end
    return
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

    ast = @eval ccall((:singular_parse, $libpath), Any,
                    (Cstring, Ptr{Ptr{UInt8}}, UInt),
                    $s, $rtGlobal_NewStructNames, $(length(rtGlobal_NewStructNames)))

    if isa(ast, String)
        rt_error("syntax error in load")
    else
#        println("library ast:")
#        astprint(ast.child[1], 0)

        t0 = time()
        loadenv = AstLoadEnv(export_names, package)
        loadconvert_toplines(ast.child[1], loadenv)
        t1 = time()

#        println()
#        println("------- library loaded in ", trunc(1000*(t1 - t0)), " ms -------")
#        println()
    end
end

rtload(a::SName) = rtload(rt_make(a))
function rtload(a::SString)
    rt_load(false, a.string)
end

#= "second class" data types employed by singular

#### Tuples

The only way to construct a tuple in singular is via the syntax
    a, b, c
Tuples are also called expression lists in the singular grammar/documentation.
There are no variables of type tuple.

#### Nothing

There are many different kinds of nothing in Singular with distinct behaviours,
but we conflate them all into the single Julia nothing and hope for the best.

First, it is possible for elements of a Singular list to be nothing: l[1] after
    list l; l[2] = 0;

Second, functions can also return "nothing": the return value of
    proc f() {return();};

Third, variables declared "def" in Singular start out with a value of nothing.

There may be more nothings in Singular...

All of these nothings are distinct from a zero-length tuple and are very distinct
from the SName type defined below: the statement
    a, b = 1, f(), 1;
fails in the Singular interpreter because the right hand side has length 3. The statement
    a, b, c = 1, f(), 1;
fails in the Singular interpreter because something on the "right side is not a datum".

The Julia interpreter will fail in the first example because the length of the rhs tuple is checked.
The Julia interpreter will fail in the second example because the assignment to b is done via
    b = convert2T(..)       # T is the stored type of b
and the convert2T will throw an error on :nothing (unless b is nothing, where T would behave like def)

In general, it is allowed to pass nothing around in singular:
list k, l;
l[2] = 0;       // size(l) is 2, l[1] is nothing
k[1] = 0;       // size(k) is 1
k[1] = l[1];    // size(k) is 0

Therefore, the error must occur when trying to assign nothing to b, and not when constructing the tuple.

#### Names

The four letters in the singular code
    a = f(b, c);
start out life as names SName(:a), SName(:f), ect.
When needed, the names are looked up at runtime via a function called make.

Due to a bug in the current c singular, we can see what the interpreter thinks the type of these names is:
> proc f() {return(1,x)};
> typeof(f());
int ?unknown type?

There are no variables of type name.

=#

####################### types unavailable to the user ###########################

#### singular type expression list
# note: expression lists cannot have expression lists as elements: everything is
#       always auto splatted. See the function object_is_ok for a precise definition.
struct STuple
    list::Vector{Any}
end

#### singular type nothing
# Nothing same

#### singular type ?unknown type?
# TODO: possibly make this the same as Symbol. makeunknown would become a quote
struct SName
    name::Symbol
end
makeunknown(s::String) = SName(Symbol(s))

show(io::IO, a::SName) = print(io, ":"*string(a.name))


########################## ring independent types #############################

##### singular type "proc"      immutable in the singular language
struct Sproc
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
struct Sstring
    value::String
end


#### singular type "intvec"     mutable in the singular language
struct Sintvec
    value::Vector{Int}
    tmp::Bool
end

function Sintvec(value::Vector{Int})
    return Sintvec(value, true)
end

sing_array(x::Sintvec) = x.value

#### singular type "intmat"     mutable in the singular language
struct Sintmat
    value::Array{Int, 2}
    tmp::Bool
end

function Sintmat(value::Array{Int, 2})
    return Sintmat(value, true)
end

sing_array(x::Sintmat) = x.value

#### singular type "bigintmat"  mutable in the singular language
struct Sbigintmat
    value::Array{BigInt, 2}
    tmp::Bool
end

function Sbigintmat(value::Array{BigInt, 2})
    return Sbigintmat(value, true)
end

sing_array(x::Sbigintmat) = x.value


#### singular type "ring"       immutable in the singular language, but also holds identifiers of ring-dependent types
mutable struct Sring
    value::libSingular.ring
    refcount::Int
    level::Int                  # 1->created at global, 2->created in fxn called from global, ect..
    vars::Dict{Symbol, Any}     # global ring vars
    valid::Bool                 # valid==false <=> value==NULL

    function Sring(valid_::Bool, value_::libSingular.ring, level::Int)
        r = new(value_, 1, level, Dict{Symbol, Any}(), valid_)
        finalizer(rt_ring_finalizer, r)
        return r
    end
end

function rt_ring_finalizer(a::Sring)
    a.refcount -= 1
    if a.refcount <= 0
        @assert a.refcount == 0
        libSingular.rDelete(a.value)
    end
end


#### singular type "list"       mutable in the singular language
# note: Lists can have anything in them - including polynomials from different
#       rings. The parent, ring_dep_count, and back members are for maintaining
#       backwards compatibility with singular, where the content of a list can
#       change the location of its name.
#       The integrity of this structure can be checked with object_is_ok
mutable struct Slist
    value::Vector{Any}
    parent::Sring           # parent.valid <=> list is considered ring dependent
    ring_dep_count::Int     # count of ring dependent elements
    back::Any               # pointer to data that possibly needs changing when ring dependence changes
    tmp::Bool
end


############################ ring dependent types ############################
# The constructor for T takes ownership of a raw pointer

sing_ring(x) = nothing

#### singular type "number"     immutable in the singular language
mutable struct Snumber
    value::libSingular.number    
    parent::Sring

    function Snumber(value_::libSingular.number, parent_::Sring)
        a = new(value_, parent_)
        finalizer(rt_number_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

function rt_number_finalizer(a::Snumber)
    libSingular.n_Delete(a.value, a.parent.value)
    rt_ring_finalizer(a.parent)
end


#### singular type "poly"       immutable in the singular language
mutable struct Spoly
    value::libSingular.poly     # singly linked list of terms
    parent::Sring

    function Spoly(value_::libSingular.poly, parent_::Sring)
        a = new(value_, parent_)
        finalizer(rt_poly_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

sing_ring(p::Spoly) = p.parent
sing_ptr(p::Spoly) = p.value

function rt_poly_finalizer(a::Spoly)
    libSingular.p_Delete(a.value, a.parent.value)
    rt_ring_finalizer(a.parent)
end


#### singular type "vector"     immutable in the singular language
mutable struct Svector
    vector_ptr::libSingular.poly    # singly linked list of terms*gen(i), like a sparse array of poly
    parent::Sring

    function SVector(value_::libSingular.poly, parent_::Sring)
        a = new(value_, parent_)
        finalizer(rt_vector_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

sing_ring(p::Svector) = p.parent
sing_ptr(p::Svector) = p.value

function rt_vector_finalizer(a::Svector)
    libSingular.p_Delete(a.value, a.parent.value)
    rt_ring_finalizer(a.parent)
end


#### singular type "ideal"      mutable like a 1d array of polys in the singular language
mutable struct Sideal
    value::libSingular.ideal        # dense 1d array of poly
    parent::Sring
    tmp::Bool

    function Sideal(value_::libSingular.ideal, parent_::Sring, tmp_::Bool)
        a = new(value_, parent_, tmp_)
        finalizer(rt_ideal_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

sing_ptr(i::Sideal) = i.value
sing_ring(i::Sideal) = i.parent

function rt_ideal_finalizer(a::Sideal)
    libSingular.id_Delete(a.value, a.parent.value)
    rt_ring_finalizer(a.parent)
end


#### singular type "matrix"     mutable like a 2d array of polys in the singular language
mutable struct Smatrix
    value::libSingular.matrix       # dense 2d array of poly
    parent::Sring
    tmp::Bool

    function Smatrix(value_::libSingular.matrix, parent_::Sring, tmp_::Bool)
        a = new(value_, parent_, tmp_)
        finalizer(rt_matrix_finalizer, a)
        parent_.refcount += 1
        @assert parent_.refcount > 1
        return a
    end
end

sing_ptr(a::Smatrix) = a.value
sing_ring(a::Smatrix) = a.parent

function rt_matrix_finalizer(a::Smatrix)
    libSingular.mp_Delete(a.value, a.parent.value)
    rt_ring_finalizer(a.parent)
end


# the types that are always ring dependent, i.e. the .parent member is always valid
# Slist is not included. lists are just special.
const SingularRingType = Union{Snumber, Spoly, Svector, Sideal, Smatrix}


# TODO: a SingularType encompassing all types including newstruct's


######################### user defined types ##################################

const newstructprefix = "Snewstruct_"

function is_valid_newstruct_member(s::String)
    if match(r"^[a-zA-Z][a-zA-Z0-9]*$", s) == nothing
        return false
    else
        return true
    end
end

###############################################################################
########################## transpiler types ###################################

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

Base.showerror(io::IO, er::TranspileError) = print(io, "transpilation error: ", er.name)

mutable struct AstEnv
    package::Symbol
    fxn_name::String
    ok_to_branchto::Bool    # is cmd branchTo allowed?
    branchto_appeared::Bool # have we seen a branchTo yet?
    ok_to_return::Bool      # is return allowed?
    at_top::Bool
    everything_is_screwed::Bool                 # no local variables may go into local storage
    rings_are_screwed::Bool                     # no local ring dependent variables may go into local storage
    appeared_identifiers::Dict{String, Int}     # name => some data
    declared_identifiers::Dict{String, String}  # name => type
end

mutable struct AstLoadEnv
    export_names::Bool
    package::Symbol
end


######################## runtime global state #################################

# The CallStackEntry holds the "context" required by every function.
# This could be passed around as a first argument to _every_ rt function, but
# we take the simpler approach for now and manually manage a call stack in rtGlobal.callstack.
mutable struct rtCallStackEntry
#=
    Should always have
        start_all_locals <= start_current_locals <= length(rtGlobal.local_vars) + 1

    Variables in [start_current_locals, length(rtGlobal.local_vars)] are our
    local vars, including the ring independent vars and the ring dependent
    vars from the current ring.

    Variables in [start_all_locals, start_current_locals) are our hidden local
    ring dependent vars. They are hidden by the fact that their ring is not
    the current ring.

    Obviously, this makes changing the current ring inside a function an
    expensive operation that involves rearranging the whole interval
        [start_all_locals, length(rtGlobal.local_vars)]
    and setting start_current_locals appropriately.
=#
    start_all_locals::Int       # index into rtGlobal.local_vars
    start_current_locals::Int   # index into rtGlobal.local_vars
    current_ring::Sring
    current_package::Symbol
end

mutable struct rtGlobalState
    SearchPath::Vector{String}
    optimize_locals::Bool
    last_printed::Any
    rtimer_base::UInt64
    rtimer_scale::UInt64
    vars::Dict{Symbol, Dict{Symbol, Any}}     # global ring indep vars
    callstack::Array{rtCallStackEntry}
    local_vars::Array{Pair{Symbol, Any}}
    newstruct_casts::Dict{String, Function}   # available newstruct's and their cast operators
end

# when there is no current ring, the current ring is "invalid"
const rtInvalidRing = Sring(false, libSingular.rDefault_null_helper(), 1)

const rtGlobal = rtGlobalState(String[],
                               true,
                               nothing,
                               time_ns(),
                               1000000000,
                               Dict(:Top => Dict{Symbol, Any}()),
                               rtCallStackEntry[rtCallStackEntry(1, 1, rtInvalidRing, :Top)],
                               Pair{Symbol, Any}[],
                               Dict{String, Function}())

const empty_tuple = STuple(Any[])

function reset_runtime()
    rtGlobal.optimize_locals = true
    rtGlobal.last_printed = nothing
    rtGlobal.rtimer_base = time_ns()
    rtGlobal.rtimer_scale = 1000000000
    rtGlobal.vars = Dict(:Top => Dict{Symbol, Any}())
    rtGlobal.callstack = rtCallStackEntry[rtCallStackEntry(1, 1, rtInvalidRing, :Top)]
    rtGlobal.local_vars = Pair{Symbol, Any}[]
    rtGlobal.newstruct_casts = Dict{String, Function}()
end


###### these macros do not work without esc !!!!

macro warn_check(cond, msg)
    return :($(esc(cond)) ? nothing : rt_warn($(esc(msg))))
end

macro error_check(cond, msg)
    return :($(esc(cond)) ? nothing : rt_error($(esc(msg))))
end

macro expensive_assert(cond)
    return nothing
#    return :($(esc(cond)) ? nothing : rt_error("expensive assertion failed"))
end

macro warn_check_rings(ringa, ringb, msg)
    return :($(esc(ringa)) === $(esc(ringb)) ? nothing : rt_warn($(esc(msg))))
end

macro error_check_rings(ringa, ringb, msg)
    return :($(esc(ringa)) === $(esc(ringb)) ? nothing : rt_error($(esc(msg))))
end


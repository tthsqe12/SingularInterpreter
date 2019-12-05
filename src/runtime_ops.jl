#=
the transpiler may produce names for any arguments of these functions
    SINGULAR    JULIA
    a[i, j]     rt_getindex(a, i, j)
    a[i, j] = b rt_setindex(a, i, j, b)
    a + b       rtplus(a, b)
    -a          rtminus(a)
    a - b       rtminus(a, b)
    a*b         rttimes(a, b)
    a/b         rtdivide(a, b)
    a / b       rtdivide(a, b)
    a div b     rtdiv(a, b)
    a % b       rtmod(a, b)
    a mod b     rtmod(a, b)
    a^b         rtpower(a, b)
    a == b      rtequalequal(a, b)
    a != b      rtnotequal(a, b)
    a >= b      rtgreaterequal(a, b)
    a > b       rtgreater(a, b)
    a <= b      rtlessequal(a, b)
    a < b       rtless(a, b)
    a && b      rtand(a, b)
    a and b     rtand(a, b)
    a || b      rtor(a, b)
    a or b      rtor(a, b)
    !a          rtnot(a)
    not a       rtnot(a)
    a .. b      rtdotdot(a, b)
    a : b       rtcolon(a, b)
=#


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



# TODO instead of having stupid stuff like the following 3 methods, compile a list
# of commands (CMD) that never take a name as an argument and call rt_make in
# the transpiler in those cases
rtplus(a::SName, b::SName) = rtplus(rt_make(a), rt_make(b))
rtplus(a::SName, b) = rtplus(rt_make(a), b)
rtplus(a, b::SName) = rtplus(a, rt_make(b))

function rtplus(a::_List, b::_List)
    return SList(SListData(vcat(rt_edit(a).data, rt_edit(b).data)))
end

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


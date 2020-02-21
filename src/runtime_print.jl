############ printing #########################################################
# Printing seems to be a mess in singular. For now we just have rt_printout,
# rt_print, and rt_cast2string, which all produce nice 2-dimensional output

function rt_indent_string(s::String, indent::Int)
    join(split(s, r"\n|\r|\0"), "\n" * " "^indent)
end

function rt_format_matrix(a::Array{String, 2})
    nrows, ncols = size(a)
    b = map(s->split(s, r"\n|\r|\0"), a) # matrix of arrays of substrings
    col_widths = [(j < ncols ? 1 : 0) + maximum([maximum(map(length, b[i,j])) for i in 1:nrows]) for j in 1:ncols]
    row_heights = [maximum(map(length, b[i,1:end])) for i in 1:nrows]
    r = String[]
    for i in 1:nrows
        for k in 1:row_heights[i]
            for j in 1:ncols
                push!(r, rpad(k <= length(b[i,j]) ? b[i,j][k] : "", col_widths[j]))
            end
            if i < nrows || k < row_heights[i]
                push!(r, "\n")
            end
        end
    end
    return join(r)
end

function rt_print(a::Snone)
    return ""
end

function rt_print(a::SName)
    return rt_print(rt_lookup(a))
end

function rt_print(a::Sproc)
    return "package:  " * string(a.package) * "\n" *
           "procname: " * a.name
end

function rt_print(a::Union{Int, BigInt})
    return string(a)
end

function rt_print(a::Sstring)
    return a.value
end

function rt_print(a::Union{Sintmat, Sbigintmat})
    return rt_format_matrix(map(string, a.value))
end

function rt_print(a::Sintvec)
    return join(map(string, a.value), ", ")
end

function rt_print(a::Slist)
    s = ""
    A = a.value
    first = true
    for i in 1:length(A)
        h = (first ? "list[" : "    [") * string(i) * "]: "
        s *= h
        s *= rt_indent_string(rt_print(A[i]), length(h)) * (i < length(A) ? "\n" : "")
        first = false
    end
    if first
        s = "empty list"
    end
    return s
end

function rt_print(a::Sring)
    return libSingular.rPrint_helper(a.value)
end

function rt_print(a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "printing a number outside of basering")
    libSingular.StringSetS("")
    libSingular.n_Write(a.value, a.parent.value)
    return libSingular.StringEndS()
end

function rt_print(a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "printing a polynomial outside of basering")
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Svector)
    @warn_check_rings(a.parent, rt_basering(), "printing a vector outside of basering")
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Sresolution)
    @warn_check_rings(a.parent, rt_basering(), "printing a resolution outside of basering")
    s = libSingular.syPrint(a.value, "?R?") # TODO let Sring store a name
    return s
end

function rt_print(a::Sideal)
    @warn_check_rings(a.parent, rt_basering(), "printing an ideal outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = (first ? "ideal[" : "     [") * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
    end
    if first
        s = "empty ideal"
    end
    return s
end

function rt_print(a::Smodule)
    @warn_check_rings(a.parent, rt_basering(), "printing a module outside of basering")
    s = ""
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = (first ? "module[" : "      [") * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
    end
    if first
        s = "empty module"
    end
    return s
end

function rt_print(a::Smatrix)
    @warn_check_rings(a.parent, rt_basering(), "printing a matrix outside of basering")
    s = ""
    nrows = libSingular.nrows(a.value)
    ncols = libSingular.ncols(a.value)
    first = true
    for i in 1:nrows
        for j in 1:ncols
            p = libSingular.mp_getindex(a.value, i, j)
            t = libSingular.p_String(p, a.parent.value)
            h = (first ? "matrix[" : "      [") * string(i) * ", " * string(j) * "]: "
            s *= h * t * ((i < nrows || j < ncols) ? "\n" : "")
            first = false
        end
    end
    if first
        s = "empty matrix"
    end
    return s
end

function rt_print(a::Smap)
    @warn_check_rings(a.parent, rt_basering(), "printing a map outside of basering")
    s = ""
    n = Int(libSingular.ma_ncols(a.value))
    first = true
    for i in 1:n
        p = libSingular.ma_getindex0(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = (first ? "map[" : "   [") * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
    end
    if first
        s = "empty map"
    end
    return s
end

# just for fun - rtprint and rt_printout have special cases for tuples
function rt_print(a::STuple)
    return join([rt_print(i) for i in a.list], "\n")
end

# the "print" function in Singular returns a string and does not print
function rtprint(::Snone)
    return ""
end

function rtprint(a)
    @assert !isa(a, STuple)
    return Sstring(rt_print(a))
end

function rtprint(a::STuple)
    return STuple([Sstring(rt_print(i)) for i in a.list])
end

# the semicolon in Singular is the method to actually print something
function rt_printout(::Snone)
    return  # we will probably be printing nothing often - very important to not print anything in this case
end

function rt_printout(a)
    @assert !isa(a, STuple)
    @assert !isa(a, Snone)
    rtGlobal.last_printed = rt_copy_own(a)
    println(rt_print(a))
end

function rt_printout(a::STuple)
    n = length(a.list)
    for i in 1:n
        if i == n
            rtGlobal.last_printed = rt_copy_own(a.list[i])
        end
        println(rt_print(a.list[i]))
    end
end

function rt_get_last_printed()
    return rtGlobal.last_printed
end

# type ...; will call rt_printouttype. no idea how this is supposed to work
function rt_printouttype(a)
    println("add correct type printing here")
end


############ printing #########################################################
# Printing seems to be a mess in singular. For now we just have rt_printout,
# rt_print, and rt_cast2string, which all produce nice 2-dimensional output

function rt_indent_string(s::String, indent::Int)
    join(split(s, r"\n|\r|\0"), "\n" * " "^indent)
end

function rt_format_matrix(a::Array{String, 2})
    isempty(a) && return ""
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
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "list" : name
    s = ""
    A = a.value
    first = true
    for i in 1:length(A)
        h = name * "[" * string(i) * "]: "
        s *= h
        s *= rt_indent_string(rt_print(A[i]), length(h)) * (i < length(A) ? "\n" : "")
        first = false
        name = " "^length(name)
    end
    if first
        s = "empty list"
    end
    return s
end

function rt_print(a::Sring)
    sync_begin()    # for options
    return libSingular.rPrint_helper(a.value)
end

function rt_print(a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "printing a number outside of basering")
    sync_begin()    # for options
    libSingular.StringSetS("")
    libSingular.n_Write(a.value, a.parent.value)
    return libSingular.StringEndS()
end

function rt_print(a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "printing a polynomial outside of basering")
    sync_begin()    # for options
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Svector)
    @warn_check_rings(a.parent, rt_basering(), "printing a vector outside of basering")
    sync_begin()    # for options
    s = libSingular.p_String(a.value, a.parent.value)
    return s
end

function rt_print(a::Sresolution)
    @warn_check_rings(a.parent, rt_basering(), "printing a resolution outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a.parent))
    name = isempty(name) ? "ring" : name
    s = libSingular.syPrint(a.value, a.parent.value, name)
    return s
end

function rt_print(a::Sideal)
    @warn_check_rings(a.parent, rt_basering(), "printing an ideal outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "ideal" : name
    s = ""
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
        name = " "^length(name)
    end
    if first
        s = "empty ideal"
    end
    return s
end

function rt_print(a::Smodule)
    @warn_check_rings(a.parent, rt_basering(), "printing a module outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "module" : name
    s = ""
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
        name = " "^length(name)
    end
    if first
        s = "empty module"
    end
    return s
end

function rt_print(a::Smatrix)
    @warn_check_rings(a.parent, rt_basering(), "printing a matrix outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "matrix" : name
    s = ""
    nrows = libSingular.nrows(a.value)
    ncols = libSingular.ncols(a.value)
    first = true
    for i in 1:nrows
        for j in 1:ncols
            p = libSingular.mp_getindex(a.value, i, j)
            t = libSingular.p_String(p, a.parent.value)
            h = name * "[" * string(i) * ", " * string(j) * "]: "
            s *= h * t * ((i < nrows || j < ncols) ? "\n" : "")
            first = false
            name = " "^length(name)
        end
    end
    if first
        s = "empty matrix"
    end
    return s
end

function rt_print(a::Smap)
    @warn_check_rings(a.parent, rt_basering(), "printing a map outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "map" : name
    s = ""
    n = Int(libSingular.ma_ncols(a.value))
    first = true
    for i in 1:n
        p = libSingular.ma_getindex0(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        s *= h * t * (i < n ? "\n" : "")
        first = false
        name = " "^length(name)
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
    if pretty_output.enabled
        push!(pretty_output.vals, print_pretty(a))
    end
    println(rt_print(a))
end

function rt_printout(a::STuple)
    n = length(a.list)
    for i in 1:n
        if i == n
            rtGlobal.last_printed = rt_copy_own(a.list[i])
        end
        if pretty_output.enabled
            push!(pretty_output.vals, print_pretty(a.list[i]))
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

###########################################

# ad hoc conversion from singular's polynomial printing to latex
# it works on vectors too!
# example:
#   format_pretty_poly("1+(a(1)^2+b)x(1,2)(3)")  -> 1+(a_{1}^2+b)x_{1,2,3}
#   format_pretty_poly("1+x(a(1)^2+b)x(1,2)(3)") -> 1+x_{a_{1}^2+b}x_{1,2,3}
# The output is junk if the input has mismashed ()
# TODO: do we want to distinguish x(1,2)(3) and x(1)(2)(3) in the output?
function format_pretty_poly(s::String)
    bracket_stack = Char[]
    r = Char[]
    for c in s
        if c == '('
            if !isempty(r) && isletter(r[end])
                # this ( should open a new subscript
                push!(r, '_')
                push!(r, '{')
                push!(bracket_stack, '{')
            elseif !isempty(r) && r[end] == '}'
                # this ( should continue a previous subscript
                r[end] = ','
                push!(bracket_stack, '{')
            else
                push!(r, '(')
                push!(bracket_stack, '(')
            end
        elseif c == ')'
            if !isempty(bracket_stack) && bracket_stack[end] == '{'
                # this ) closes a _{
                push!(r, '}')
                pop!(bracket_stack)
            else
                if !isempty(bracket_stack) && bracket_stack[end] == '('
                    pop!(bracket_stack)
                end
                push!(r, ')')
            end
        elseif c == '*'
        else
            push!(r, c)
        end
    end
    return join(r)
end

function format_pretty_matrix(a::Array{String, 2})
    nrows, ncols = size(a)
    if !(nrows > 0 && ncols > 0)
        return "empty matrix"
    end
    s = String[]
    push!(s, "\\left( \\begin{array}{" * "c"^ncols * "}\n")
    for i in 1:nrows
        for j in 1:ncols
            push!(s, a[i, j])
            if j < ncols
                push!(s, " & ")
            end
        end
        if i < nrows
            push!(s, " \\\\\n")
        end
    end
    push!(s, "\n\\end{array} \\right)")
    return join(s)
end

function format_pretty_newstruct(typename::String, a::Vector{String})
    n = length(a)
    @assert(n > 0)
    @assert((n % 2) == 0)
    s = String[]
    push!(s, "\\begin{array}{l}\n")
    push!(s, "\\text{" * typename * "} \\\\\n")
    push!(s, "\\left[ \\begin{array}{ll}\n")
    for i in 1:2:n
        push!(s, "\\text{")
        push!(s, a[i])
        push!(s, ": } & ")
        push!(s, a[i + 1])
        if i + 1 < n
            push!(s, " \\\\\n")
        end
    end
    push!(s, "\n\\end{array} \\right.")
    push!(s, "\\end{array}\n")
    return join(s)
end

function print_pretty(a::Union{Int, BigInt})
    return string(a)
end

function print_pretty(a::Sintvec)
    s = "\\left[ \\begin{array}{c}\n"
    s *= join(map(string, a.value), " \\\\\n")
    s *= "\n\\end{array} \\right]"
    return s
end

function print_pretty(a::Union{Sintmat, Sbigintmat})
    return format_pretty_matrix(map(string, a.value))
end

function print_pretty(a::Sring)
    name = string(rt_reverse_lookup(a))
    return isempty(name) ? "\\text{some ring}" : "\\text{ring }" * name
end

function print_pretty(a::Slist)
    s = "\\left\\{ \\begin{array}{l}"
    first = true
    for i in a.value
        if !first
            s *= " \\\\\n"
        end
        s *= print_pretty(i)
        first = false
    end
    if first
        return "\\text{empty list}"
    end
    s *= "\\end{array} \\right."
end

function print_pretty(a::Union{Spoly, Svector})
    s = libSingular.p_String(a.value, a.parent.value)
    return format_pretty_poly(s)
end

function print_pretty(a::Union{Sideal, Smodule})
    s = "\\left\\langle "
    n = Int(libSingular.ngens(a.value))
    first = true
    for i in 1:n
        if !first
            s *= ","
        end
        s *= print_pretty(rtgetindex(a, i))
        first = false
    end
    s *= " \\right\\rangle"
    return s
end

function print_pretty(a::Smatrix)
    nrows = libSingular.nrows(a.value)
    ncols = libSingular.ncols(a.value)
    m = Array{String, 2}(undef, nrows, ncols)
    for i in 1:nrows
        for j in 1:ncols
            m[i, j] = print_pretty(rtgetindex(a, i, j))
        end
    end
    return format_pretty_matrix(m)
end


function print_pretty(a)
    return "???"
end


function Base.show(io::IO, ::MIME"text/latex", a::PrintReaper)
    s = "\\begin{equation}\n" *
        "\\begin{array}{l}\n"
    first = true
    for i in a.vals
        if !first
            s *= " \\\\\n"
        end
        s *= i
        first = false
    end
    s *= "\\end{array}\n" *
         "\\end{equation}\n"
    print(io, s)
end

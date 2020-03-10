############ printing #########################################################
# Printing seems to be a mess in singular. For now we just have show
# and rt_cast2string, which all produce nice 2-dimensional output

function rt_indent_string(s::String, indent::Int)
    join(split(s, r"\n|\r|\0"), "\n" * " "^indent)
end

function Base.show(io::IO, a::Union{Sintmat, Sbigintmat})
    isempty(a.value) && return
    nrows, ncols = size(a)
    b = map(s->split(string(s), r"\n|\r|\0"), a.value) # matrix of arrays of substrings
    col_widths = [(j < ncols ? 1 : 0) + maximum([maximum(map(length, b[i,j])) for i in 1:nrows]) for j in 1:ncols]
    row_heights = [maximum(map(length, b[i,1:end])) for i in 1:nrows]
    for i in 1:nrows
        for k in 1:row_heights[i]
            for j in 1:ncols
                print(io, rpad(k <= length(b[i,j]) ? b[i,j][k] : "", col_widths[j]))
            end
            if i < nrows || k < row_heights[i]
                print(io, "\n")
            end
        end
    end
end

show(io::IO, a::Snone) = nothing

show(io::IO, a::Sproc) = print(io,
                               "package:  ", a.package, "\n",
                               "procname: ", a.name)

show(io::IO, a::Sstring) = print(io, a.value)

show(io::IO, a::Sintvec) = join(io, a.value, ", ")

function Base.show(io::IO, a::Slist)
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "list" : name
    A = a.value
    isempty(A) && return print(io, "empty list")
    for i in 1:length(A)
        h = name * "[" * string(i) * "]: "
        print(io, h)
        print(io, rt_indent_string(string(A[i]), length(h)) * (i < length(A) ? "\n" : ""))
        name = " "^length(name)
    end
end

function Base.show(io::IO, a::Sring)
    sync_begin()    # for options
    print(io, libSingular.rPrint_helper(a.value))
end

function Base.show(io::IO, a::Snumber)
    @warn_check_rings(a.parent, rt_basering(), "printing a number outside of basering")
    sync_begin()    # for options
    libSingular.StringSetS("")
    libSingular.n_Write(a.value, a.parent.value)
    print(io, libSingular.StringEndS())
end

function Base.show(io::IO, a::Spoly)
    @warn_check_rings(a.parent, rt_basering(), "printing a polynomial outside of basering")
    sync_begin()    # for options
    print(io, libSingular.p_String(a.value, a.parent.value))
end

function Base.show(io::IO, a::Svector)
    @warn_check_rings(a.parent, rt_basering(), "printing a vector outside of basering")
    sync_begin()    # for options
    print(io, libSingular.p_String(a.value, a.parent.value))
end

function Base.show(io::IO, a::Sresolution)
    @warn_check_rings(a.parent, rt_basering(), "printing a resolution outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a.parent))
    name = isempty(name) ? "ring" : name
    print(io, libSingular.syPrint(a.value, a.parent.value, name))
end

function Base.show(io::IO, a::Sideal)
    @warn_check_rings(a.parent, rt_basering(), "printing an ideal outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "ideal" : name
    n = Int(libSingular.ngens(a.value))
    n < 1 && return print(io, "empty ideal")
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        print(io, h, t, i < n ? "\n" : "")
        name = " "^length(name)
    end
end

function Base.show(io::IO, a::Smodule)
    @warn_check_rings(a.parent, rt_basering(), "printing a module outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "module" : name
    n = Int(libSingular.ngens(a.value))
    n < 1 && return print(io, "empty module")
    for i in 1:n
        p = libSingular.getindex(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        print(io, h, t, i < n ? "\n" : "")
        name = " "^length(name)
    end
end

function Base.show(io::IO, a::Smatrix)
    @warn_check_rings(a.parent, rt_basering(), "printing a matrix outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "matrix" : name
    nrows = libSingular.nrows(a.value)
    ncols = libSingular.ncols(a.value)
    nrows < 1 && return print(io, "empty matrix")
    for i in 1:nrows
        for j in 1:ncols
            p = libSingular.mp_getindex(a.value, i, j)
            t = libSingular.p_String(p, a.parent.value)
            h = name * "[" * string(i) * ", " * string(j) * "]: "
            print(io, h, t, (i < nrows || j < ncols) ? "\n" : "")
            name = " "^length(name)
        end
    end
end

function Base.show(io::IO, a::Smap)
    @warn_check_rings(a.parent, rt_basering(), "printing a map outside of basering")
    sync_begin()    # for options
    name = string(rt_reverse_lookup(a))
    name = isempty(name) ? "map" : name
    n = Int(libSingular.ma_ncols(a.value))
    n < 1 && return print(io, "empty map")
    for i in 1:n
        p = libSingular.ma_getindex0(a.value, Cint(i - 1))
        t = libSingular.p_String(p, a.parent.value)
        h = name * "[" * string(i) * "]: "
        print(io, h, t, i < n ? "\n" : "")
        name = " "^length(name)
    end
end

# just for fun - rtprint and rt_printout have special cases for tuples
show(io::IO, a::STuple) = join(io, a.list, "\n")

function rtprint(a)
    @assert !isa(a, STuple)
    return Sstring(string(a))
end

# TODO: not matching original Singular
rtprint(a::STuple) = STuple(Any[Sstring(string(i)) for i in a.list])

# the semicolon in Singular is the method to actually print something
# we will probably be printing nothing often - very important to not print anything in this case
rt_printout(::Snone) = nothing

function rt_printout(a)
    @assert !isa(a, STuple)
    @assert !isa(a, Snone)
    rtGlobal.last_printed = rt_copy_own(a)
    display(a)
end

function rt_printout(a::STuple)
    foreach(display, a.list)
    rtGlobal.last_printed = rt_copy_own(a.list[end])
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

function show_latex(io::IO, a::Union{Smatrix,Sintmat,Sbigintmat})
    nrows, ncols = size(a)
    !(nrows > 0 && ncols > 0) && return print(io, raw"\text{empty matrix}")
    print(io, "\\left( \\begin{array}{" * "c"^ncols * "}\n")
    for i in 1:nrows
        for j in 1:ncols
            show_latex(io, a[i, j])
            if j < ncols
                print(io, " & ")
            end
        end
        if i < nrows
            print(io, " \\\\\n")
        end
    end

    print(io, "\n\\end{array} \\right)")
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

function show_latex(io::IO, a::Sintvec)
    print(io, "\\left[ \\begin{array}{c}\n")
    join(io, a.value, " \\\\\n")
    print(io, "\n\\end{array} \\right]")
end

function show_latex(io::IO, a::Sring)
    name = string(rt_reverse_lookup(a))
    print(io, isempty(name) ? "\\text{some ring}" : "\\text{ring }" * name)
end

function show_latex(io::IO, a::Slist)
    isempty(a.value) && return print(io, "\\text{empty list}")
    print(io, "\\left\\{ \\begin{array}{l}\n")
    join(io, (sprint(show_latex, x, context=io) for x in a.value),
         "\\\\\n")
    print(io, "\\end{array} \\right.")
end

function show_latex(io::IO, a::Union{Spoly, Svector})
    s = libSingular.p_String(a.value, a.parent.value)
    print(io, format_pretty_poly(s))
end

function show_latex(io::IO, a::Union{Sideal, Smodule})
    print(io, raw"\left\langle ")
    n = Int(libSingular.ngens(a.value))
    join(io, (sprint(show_latex, rtgetindex(a, i), context=io) for i=1:n), ',')
    print(io, " \\right\\rangle")
end

show_latex(io::IO, a::Union{Int,BigInt}) = print(io, a)

# TODO: improve
show_latex(io::IO, a::Union{Sstring,Sproc}) = print(io, "\\text{", a, "}")
show_latex(io::IO, a::Smap) = show(io, a)

function Base.show(io::IO, ::MIME"text/latex", a::Union{Sproc,Sideal,Smodule,Spoly,Svector,Slist,Sring,Sintvec,Smatrix,Sintmat,Sbigintmat})
    latex_math = get(io, :latex_math, false)
    if !latex_math
        print(io, raw"\[")
        io = IOContext(io, :latex_math => true)
    end
    show_latex(io, a)
    !latex_math && print(io, raw"\]")
end

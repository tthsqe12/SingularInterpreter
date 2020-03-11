# grammar rules are communicated via integer codes, not strings
macro RULE_SYNTAX_ERROR()          ;return(-1); end
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


######################### scan / convert #####################################
# transpilation proceeds with two depth-first passes over the ast
# scan: collect candidate local variables for local storage, i.e. local i::Int in the julia code
# convert: use info from scan to produce the final code


function we_know_splat_is_trivial(a)
    if a isa Expr && a.head == :call && length(a.args) == 2 && a.args[1] == :rt_lookup
        return true
    elseif a isa Symbol
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
    elseif isa(a, Expr) && a.head == :call && !isempty(a.args) && a.args[1] == :rt_backtick
        return true
    else
        return false
    end
end



# return array of generating non necessarily SingularTypes
#   useful probably only for passing to procs, where the values will be copied to new locations
# will not generate names!
# return is Array{Any}
function make_tuple_array_nocopy(a::Array{Any})
    r = Any[]
    for b in a
        if isa(b, Expr) && b.head == :call && !isempty(b.args) && b.args[1] == :rt_maketuple
            append!(r, b.args[2:end])
        elseif is_a_name(b)
            push!(r, Expr(:call, :rt_lookup, b))
        elseif we_know_splat_is_trivial(b)
            push!(r, b)
        else
            push!(r, Expr(:(...), Expr(:call, :rt_copy_tmp, b)))
        end
    end
    return r
end

# will not generate names!
function make_nocopy(a)
    if is_a_name(a)
        return Expr(:call, :rt_lookup, a)
    else
        return a
    end
end


# return array generating SingularTypes, can construct a singular tuple with Expr(:tuple, ...)
# will not generate names!
# return is Array{Any}
function make_tuple_array_copy(a::Array{Any})
    r = Any[]
    for b in a
        if isa(b, Expr) && b.head == :call && !isempty(b.args) && b.args[1] == :rt_maketuple
            append!(r, b.args[2:end])
        elseif is_a_name(b)
            push!(r, Expr(:call, :rt_copy_tmp, Expr(:call, :rt_lookup, b)))
        elseif we_know_splat_is_trivial(b)
            push!(r, Expr(:call, :rt_copy_tmp, b))
        else
            push!(r, Expr(:(...), Expr(:call, :rt_copy_tmp, b)))
        end
    end
    return r
end

# will not generate names!
function make_copy(a)
    if is_a_name(a)
        return Expr(:call, :rt_copy_tmp, Expr(:call, :rt_lookup, a))
    else
        return Expr(:call, :rt_copy_tmp, a)
    end
end

function convert_stringexpr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_stringexpr(0) < 100
    return Sstring(a.child[1])
end


function convert_typestring_to_symbol(s::String)
    return get(builtin_typestring_to_symbol, s, Symbol(newstructprefix * s))
end

# commands in convert_elemexpr that require special constructs

function convert_DEFINED_CMD(arg1, env::AstEnv)
    @assert 0 < arg1.rule - @RULE_expr(0) < 100
    l = Any[]
    if arg1.rule == @RULE_expr(2) && arg1.child[1].rule == @RULE_elemexpr(37)
        push_exprlist_expr!(l, arg1.child[1].child[1], env)
    else
        push!(l, arg1)
    end
    r = Any[]
    for a in l
        if a.rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(arg1.child[1], env)
            if ok
                if isa(b, SName) && haskey(env.declared_identifiers, String(b.name))
                    @warn "transpilation warning: variable "*String(b.name)*" is trivially defined"
                    push!(r, Expr(:call, :rt_get_voice))
                else
                    push!(r, Expr(:call, :rtdefined, b))
                end
                continue
            end
        else
            push!(r, convert_expr(arg1, env))
        end
    end
    return Expr(:call, :rt_maketuple, make_tuple_array_copy(r)...)
end


function convert_ERROR_CMD(arg1, env::AstEnv)
    arg1 = convert_expr(arg1, env)
    arg1 = make_nocopy(arg1)
    return Expr(:call, :rtERROR, arg1, String(env.package) * "::" * env.fxn_name)
end


function convert_EXECUTE_CMD(arg1, env::AstEnv)
    arg1 = convert_expr(arg1, env)
    arg1 = make_nocopy(arg1)
    t1 = gensym()
    t2 = gensym()
    return Expr(:block,
                Expr(:(=), Expr(:tuple, t1, t2), Expr(:call, :rtexecute, arg1)),
                Expr(:if, t2, Expr(:return, t1)))
end


function convert_BRANCHTO_CMD(args, env::AstEnv)    # args has already been converted
    @assert env.branchto_appeared
    env.ok_to_branchto || throw(TranspileError("branchTo not allowed in this context"))
    t_array = gensym()
    t_length = gensym()
    t_i = gensym()
    t_ok = gensym()
    t_return = gensym()
    r = Expr(:block)
    push!(r.args, Expr(:(=), t_array, Expr(:tuple, make_tuple_array_copy(args)...)))
    push!(r.args, Expr(:(=), t_length, Expr(:call, :length, t_array)))
    # TODO: fix this disgusting mess with some quotation
    push!(r.args,
        Expr(:if,
            Expr(:call,
                :(==),
                Expr(:call, :length, Symbol("##")),
                Expr(:call, :(-), t_length, 1)
            ),
            Expr(:block,
                Expr(:(=), t_ok, true),
                Expr(:for,
                    Expr(:(=),
                        t_i,
                        Expr(:call, :(:), 1, Expr(:call, :(-), t_length, 1))
                    ),
                    Expr(:block,
                        Expr(:if,
                            Expr(
                                :call,
                                :(!=),
                                Expr(:call, :rt_typedata, Expr(:ref, Symbol("##"), t_i)),
                                Expr(:(.), Expr(:ref, t_array, t_i), QuoteNode(:string))
                            ),
                            Expr(:(=), t_ok, false)
                        )
                    )
                ),
                Expr(:if,
                    t_ok,
                    Expr(:block,
                        Expr(:(=),
                            t_return,
                            Expr(:call,
                                :rtcall,
                                false,
                                Expr(:ref, t_array, t_length),
                                Expr(:(...), Symbol("##"))
                            )
                        ),
                        Expr(:call, :rt_leavefunction),
                        Expr(:return, t_return)
                    )
                )
            )
        )
    )
    push!(r.args, nothing)
    return r
end


function scan_OPTION_CMD(l::Vector{AstNode}, env::AstEnv)
    if length(l) == 0
        return
    elseif length(l) == 1
        if l[1].rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(l[1].child[1], env)
            if ok
                return
            end
        end
        throw(TranspileError("first argument to option is not a name"))
    elseif length(l) == 2
        if l[1].rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(l[1].child[1], env)
            if ok && isa(b, SName) && string(b.name) == "set"
                scan_expr(l[2], env)
                return
            end
        end
        throw(TranspileError("first argument to option is not the name set"))
    else
        throw(TranspileError("too many arguments to option"))
    end
end

function convert_OPTION_CMD(l::Vector{AstNode}, env::AstEnv)
    if length(l) == 0
        return Expr(:call, :rt_option_string)
    elseif length(l) == 1
        if l[1].rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(l[1].child[1], env)
            if ok && isa(b, SName)
                return string(b.name) == "get" ? Expr(:call, :rt_option_getvec) :
                                                 Expr(:call, :rt_option_set, string(b.name))
            end
        end
        throw(TranspileError("first argument to option is not a name"))
    elseif length(l) == 2
        if l[1].rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(l[1].child[1], env)
            if ok && isa(b, SName) && string(b.name) == "set"
                return Expr(:call, :rt_option_setvec, make_nocopy(convert_expr(l[2], env)))
            end
        end
        throw(TranspileError("first argument to option is not the name 'set'"))
    else
        throw(TranspileError("too many arguments to option"))
    end
end


function scan_FETCH_CMD_IMAP_CMD(t::Int, l::Array{AstNode}, env::AstEnv)
    @assert t == Int(IMAP_CMD) || t == Int(FETCH_CMD)
    if length(l) < 2
        throw(TranspileError(cmd_to_string[t] * " needs at least 2 arguments"))
    end
    scan_expr(l[1], env)
    if l[2].rule == @RULE_expr(2)
        b, ok = scan_elemexpr_name_call(l[2].child[1], env)
        if ok
            if isa(b, SName)
                push!(env.screwed_names, string(b.name))
            end
            for i in 3:length(l)
                scan_expr(l[i], env)
            end
            return
        end
    end
    throw(TranspileError(cmd_to_string[t] * " needs a name in the second argument"))
end

function convert_FETCH_CMD_IMAP_CMD(t::Int, l::Array{AstNode}, env::AstEnv)
    @assert t == Int(IMAP_CMD) || t == Int(FETCH_CMD)
    if length(l) < 2
        throw(TranspileError(cmd_to_string[t] * " needs at least 2 arguments"))
    end
    r = Expr(:call, Symbol("rt" * cmd_to_string[t]))
    push!(r.args, make_nocopy(convert_expr(l[1], env)))
    if l[2].rule == @RULE_expr(2)
        b, ok = convert_elemexpr_name_call(l[2].child[1], env)
        if ok
            push!(r.args, b)
            for i in 3:length(l)
                push!(r.args, make_nocopy(convert_expr(l[i], env)))
            end
            return r
        end
    end
    throw(TranspileError(cmd_to_string[t] * " needs a name in the second argument"))
end


function scan_elemexpr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        if a.child[1]::String == "_"
        elseif a.child[1]::String == "basering"
        else
            env.appeared_identifiers[a.child[1]::String] = 1
        end
    elseif a.rule == @RULE_elemexpr(98)
        scan_expr(a.child[1], env)
        env.everything_is_screwed = true
    elseif a.rule == @RULE_elemexpr(4)
        scan_expr(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(5)
        scan_elemexpr(a.child[1], env)
    elseif a.rule == @RULE_elemexpr(6)
        scan_elemexpr(a.child[1], env)
        b = a.child[2].child
        if length(b) == 1 && b[1].rule == @RULE_expr(2)
            b, ok = scan_elemexpr_name_call(b[1].child[1], env)
            if ok && isa(b, SName)
                push!(env.screwed_names, string(b.name))
                return
            end
        end
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(7)
        scan_exprlist(a.child[1], env)
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
    elseif @RULE_elemexpr(18) <= a.rule <= @RULE_elemexpr(21)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
    elseif @RULE_elemexpr(22) <= a.rule <= @RULE_elemexpr(25)
        t = a.child[1]::Int
        if t == Int(FETCH_CMD) || t == Int(IMAP_CMD)
            scan_FETCH_CMD_IMAP_CMD(t, AstNode[a.child[2], a.child[3]], env)
            return
        end
        env.everything_is_screwed |= in(t, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
    elseif @RULE_elemexpr(26) <= a.rule <= @RULE_elemexpr(29)
        env.everything_is_screwed |= in(a.child[1]::Int, cmds_that_screw_everything)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
        scan_expr(a.child[4], env)
    elseif a.rule == @RULE_elemexpr(30)
    elseif a.rule == @RULE_elemexpr(31)
        t = a.child[1]::Int
        l = AstNode[]
        if a.rule == @RULE_elemexpr(31)
            push_exprlist_expr!(l, a.child[2], env)
        end
        if t == Int(OPTION_CMD)
            scan_OPTION_CMD(l, env)
            return
        elseif t == Int(FETCH_CMD) || t == Int(IMAP_CMD)
            scan_FETCH_CMD_IMAP_CMD(t, l, env)
            return
        end
        env.branchto_appeared |= (t == Int(BRANCHTO_CMD))
        env.everything_is_screwed |= in(t, cmds_that_screw_everything)
        scan_exprlist(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(32)
        scan_expr(a.child[2], env)
        scan_expr(a.child[3], env)
        scan_expr(a.child[4], env)
    elseif a.rule == @RULE_elemexpr(33)
        scan_expr(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(34)
        scan_rlist(a.child[2], env)
        scan_rlist(a.child[3], env)
        scan_ordering(a.child[4], env)
    elseif a.rule == @RULE_elemexpr(35)
        scan_expr(a.child[2], env)
    elseif a.rule == @RULE_elemexpr(37)
        scan_exprlist(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_elemexpr"*string(a.rule)))
    end
end


function convert_elemexpr(a::AstNode, env::AstEnv, nested::Bool = false)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        if a.child[1]::String == "_"
            return Expr(:call, :rt_get_last_printed)
        elseif a.child[1]::String == "basering"
            return Expr(:call, :rtbasering)
        else
            s = a.child[1]::String
            if haskey(env.declared_identifiers, s)
                return Symbol(s)
            else
                return makeunknown(s)
            end
        end
    elseif a.rule == @RULE_elemexpr(98)
        s = make_nocopy(convert_expr(a.child[1], env))
        return Expr(:call, :rt_backtick, s)
    elseif a.rule == @RULE_elemexpr(4)
        a.child[2].rule == @RULE_elemexpr(99) || throw(TranspileError("rhs of dot is no good"))
        s = a.child[2].child[1]::String
        doring = false
        if length(s) > 2 && s[1:2] == "r_"
            doring = true
            s = s[3:end]
        end
        is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
        b = make_nocopy(convert_expr(a.child[1], env))
        c = Expr(:(.), b, QuoteNode(Symbol(s)))
        if doring
            return Expr(:call, :rt_ringof, c)
        else
            return c
        end
    elseif a.rule == @RULE_elemexpr(5)
        b = Any[]
        h = a.child[1]
        return Expr(:call, :rtcall, nested, convert_elemexpr(h, env, h.rule == @RULE_elemexpr(6)))
    elseif a.rule == @RULE_elemexpr(6)
        h = convert_elemexpr(a.child[1], env, a.child[1].rule == @RULE_elemexpr(6))
        b = a.child[2].child
        c = convert_exprlist(a.child[2], env)
        if length(b) == 1 && b[1].rule == @RULE_expr(2)
            b, ok = convert_elemexpr_name_call(b[1].child[1], env)
            if ok
                # we could eval to a map because in syntax we are a fxn of one argument
                t = gensym()
                r = Expr(:block,
                        Expr(:(=), t, Expr(:call, :rt_try_lookup_call, h)),
                        Expr(:if, Expr(:call, :isa, t, :Smap),
                            Expr(:call, :rtcall, nested, t, b),
                            Expr(:call, :rtcall, nested, t, make_tuple_array_nocopy(c)...)
                        )
                    )
                return r
            end
        end
        # x(1)(2) => rtcall(false, rtcall(true, x, 1), 2)
        return Expr(:call, :rtcall, nested, h, make_tuple_array_nocopy(c)...)
    elseif a.rule == @RULE_elemexpr(7)
        b = convert_exprlist(a.child[1], env)::Array{Any}
        return Expr(:call, :rt_bracket_constructor, make_tuple_array_nocopy(b)...)
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
    elseif @RULE_elemexpr(11) <= a.rule && a.rule <= @RULE_elemexpr(17)
        # construction of a builtin type T via T(...)
        t = a.child[1]::Int
        haskey(cmd_to_builtin_type_string, t) || throw(TranspileError("internal error in convert_elemexpr 11-17"))
        s = Symbol("rt_cast2" * cmd_to_builtin_type_string[t])
        if a.rule == @RULE_elemexpr(14) || a.rule == @RULE_elemexpr(17)
            return Expr(:call, s)
        elseif a.rule == @RULE_elemexpr(13) || a.rule == @RULE_elemexpr(16)
            b = convert_exprlist(a.child[2], env)::Array{Any}
            return Expr(:call, s, make_tuple_array_nocopy(b)...)
        else
            b = convert_expr(a.child[2], env)
            return Expr(:call, s, make_nocopy(b))
        end
    elseif @RULE_elemexpr(18) <= a.rule <= @RULE_elemexpr(21)
        t = a.child[1]::Int
        if t == Int(DEFINED_CMD)
            return convert_DEFINED_CMD(a.child[2], env)
        elseif t == Int(ERROR_CMD)
            return convert_ERROR_CMD(a.child[2], env)
        elseif t == Int(EXECUTE_CMD)
            return convert_EXECUTE_CMD(a.child[2], env)
        end
        arg1 = make_nocopy(convert_expr(a.child[2], env))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), arg1)
    elseif @RULE_elemexpr(22) <= a.rule <= @RULE_elemexpr(25)
        t = a.child[1]::Int
        if t == Int(FETCH_CMD) || t == Int(IMAP_CMD)
            return convert_FETCH_CMD_IMAP_CMD(t, AstNode[a.child[2], a.child[3]], env)
        end
        arg1 = make_nocopy(convert_expr(a.child[2], env))
        arg2 = make_nocopy(convert_expr(a.child[3], env))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), arg1, arg2)
    elseif @RULE_elemexpr(26) <= a.rule <= @RULE_elemexpr(29)
        t = a.child[1]::Int
        arg1 = make_nocopy(convert_expr(a.child[2], env))
        arg2 = make_nocopy(convert_expr(a.child[3], env))
        arg3 = make_nocopy(convert_expr(a.child[4], env))
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), arg1, arg2, arg3)
    elseif a.rule == @RULE_elemexpr(30) || a.rule == @RULE_elemexpr(31)
        t = a.child[1]::Int
        # prepare to convert arguments using special evaluation rules (for names)
        l = AstNode[]
        if a.rule == @RULE_elemexpr(31)
            push_exprlist_expr!(l, a.child[2], env)
        end
        if t == Int(OPTION_CMD)
            return convert_OPTION_CMD(l, env)
        elseif t == Int(FETCH_CMD) || t == Int(IMAP_CMD)
            return convert_FETCH_CMD_IMAP_CMD(t, l, env)
        end
        # convert arguments using normal evaluation rules
        args = Any[]
        if a.rule == @RULE_elemexpr(31)
            args = convert_exprlist(a.child[2], env)::Array{Any}
        end
        if t == Int(BRANCHTO_CMD)
            return convert_BRANCHTO_CMD(args, env)
        end
        args = make_tuple_array_nocopy(args)
        return Expr(:call, Symbol("rt" * cmd_to_string[t]), args...)
    elseif a.rule == @RULE_elemexpr(32)
        typ = cmd_to_builtin_type_string[a.child[1].child[1]::Int]
        return Expr(:call, Symbol("rt_cast2"*typ), make_nocopy(a.child[2]),
                                                   make_nocopy(a.child[3]),
                                                   make_nocopy(a.child[4]))
    elseif a.rule == @RULE_elemexpr(33)
        typ = cmd_to_builtin_type_string[a.child[1].child[1]::Int]
        return Expr(:call, Symbol("rt_cast2"*typ), make_nocopy(a.child[2]))
    elseif a.rule == @RULE_elemexpr(34)
        return Expr(:call, :rt_make_ring, convert_rlist(a.child[2], env),
                                          convert_rlist(a.child[3], env),
                                          convert_ordering(a.child[4], env))
    elseif a.rule == @RULE_elemexpr(35)
        return Expr(:call, :rt_make_ring_from_ringlist, make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_elemexpr(37)
        b = convert_exprlist(a.child[1], env)
        if length(b) == 1
            return make_copy(b[1])
        else
            return Expr(:call, :rt_maketuple, make_tuple_array_copy(b)...)
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
        return Expr(:call, :rtplus, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(4)
        return Expr(:call, :rtminus, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(5)
        return Expr(:call, :rttimes, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(6)
        return Expr(:call, :rtmod, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(99)
        return Expr(:call, :rtdiv, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(7)
        return Expr(:call, :rtdivide, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(8)
        return Expr(:call, :rtpower, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(9)
        return Expr(:call, :rtgreaterequal, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(10)
        return Expr(:call, :rtlessequal, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(11)
        return Expr(:call, :rtgreater, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(12)
        return Expr(:call, :rtless, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(13)
        return Expr(:call, :rtand, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(14)
        return Expr(:call, :rtor, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(15)
        return Expr(:call, :rtnotequal, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(16)
        return Expr(:call, :rtequalequal, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(17)
        return Expr(:call, :rtdotdot, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(18)
        return Expr(:call, :rtcolon, make_nocopy(convert_expr(a.child[1], env)), make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr_arithmetic(19)
        return Expr(:call, :rtnot, make_nocopy(convert_expr(a.child[1], env)))
    elseif a.rule == @RULE_expr_arithmetic(20)
        return Expr(:call, :rtminus, make_nocopy(convert_expr(a.child[1], env)))
    else
        throw(TranspileError("internal error in convert_expr_arithmetic "))
    end
end


function rt_assume_level_ok(a::Int)
    level = rt_try_lookup(SName(:assumeLevel))
    if isa(level, SName)
        # assumeLevel is undefined
        return a == 0
    elseif isa(level, Int)
        # assumeLevel is an int
        return a <= level
    else
        rt_error("assumeLevel, if defined, must be an int in ASSUME")
        return false
    end
end

function rt_assume_level_ok(a)
    rt_error("first argument of ASSUME must be an int")
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
    elseif a.rule == @RULE_expr(13)
        env.appeared_identifiers["assumeLevel"] = 1
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
        return Expr(:call, :rtgetindex, make_nocopy(convert_expr(a.child[1], env)),
                                        make_nocopy(convert_expr(a.child[2], env)),
                                        make_nocopy(convert_expr(a.child[3], env)))
    elseif a.rule == @RULE_expr(4)
        return Expr(:call, :rtgetindex, make_nocopy(convert_expr(a.child[1], env)),
                                        make_nocopy(convert_expr(a.child[2], env)))
    elseif a.rule == @RULE_expr(13)
        level = make_nocopy(convert_expr(a.child[1], env))
        if haskey(env.declared_identifiers, "assumeLevel")
            env.declared_identifiers["assumeLevel"] == "int" || throw(TranspileError("assumeLevel should be declared int"))
            cond = Expr(:call, :(<), Expr(:(::), level, :Int), Symbol("assumeLevel"))
        else
            cond = Expr(:call, :rt_assume_level_ok, level)
        end
        return Expr(:if, cond, Expr(:call, :rt_assume, make_nocopy(convert_expr(a.child[2], env)),
                                                       "assumption "*astprint_pretty(a.child[2], env)*" failed"),
                               :rtnothing)
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
    env.ok_to_return || throw(TranspileError("cannot return from the top level"))
    r = Expr(:block)
    if a.rule == @RULE_returncmd(1)
        b::Array{Any} = convert_exprlist(a.child[1], env)
        t = gensym()
        if length(b) == 1
            c = b[1]
            if isa(c, Symbol)
                @assert haskey(env.declared_identifiers, string(c))
                push!(r.args, Expr(:(=), t, Expr(:call, :rt_promote, c)))
            elseif is_a_name(c)
                push!(r.args, Expr(:(=), t, Expr(:call, :rt_lookup_return, c)))
            else
                push!(r.args, Expr(:(=), t, Expr(:call, :rt_copy_tmp, c)))
            end
        else
            push!(r.args, Expr(:(=), t, Expr(:call, :rt_maketuple, make_tuple_array_copy(b)...)))
        end
    elseif a.rule == @RULE_returncmd(2)
        t = :rtnothing
    else
        throw(TranspileError("internal error in convert_returncmd"))
    end
    push!(r.args, Expr(:call, :rt_leavefunction))
    push!(r.args, Expr(:return, t))
    return r
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


function scan_elemexpr_name_call(a::AstNode, env::AstEnv)
    @assert @RULE_elemexpr(0) < a.rule < @RULE_elemexpr(100)
    if a.rule == @RULE_elemexpr(99)
        scan_add_appearance(a.child[1]::String, env)
        return makeunknown(a.child[1]::String), true
    elseif a.rule == @RULE_elemexpr(98)
        env.everything_is_screwed = true
        scan_expr(a.child[1], env)
        return nothing, true
    elseif a.rule == @RULE_elemexpr(6)
        head, ok = scan_elemexpr_name_call(a.child[1], env)
        if ok
            scan_exprlist(a.child[2], env)
            return nothing, true
        end
    end
    return nothing, false
end

function convert_elemexpr_name_call(a::AstNode, env::AstEnv)
    @assert @RULE_elemexpr(0) < a.rule < @RULE_elemexpr(100)
    if a.rule == @RULE_elemexpr(99)
        return makeunknown(a.child[1]::String), true
    elseif a.rule == @RULE_elemexpr(98)
        s = make_nocopy(convert_expr(b.child[1], env))
        return Expr(:call, :rt_backtick, s), true
    elseif a.rule == @RULE_elemexpr(6)
        head, ok = convert_elemexpr_name_call(a.child[1]::AstNode, env)
        if ok
            arg = convert_exprlist(a.child[2]::AstNode, env)
            return Expr(:call, :rt_name_cross, head, make_tuple_array_nocopy(arg)...), true
        end
    end
    return nothing, false
end


function scan_extendedid_name_call(a::AstNode, env::AstEnv)
    @assert @RULE_extendedid(0) < a.rule < @RULE_extendedid(100)
    env.everything_is_screwed = true
    if a.rule == @RULE_extendedid(1)
        scan_add_appearance(a.child[1]::String, env)
    elseif a.rule == @RULE_extendedid(2)
        scan_expr(a.child[1], env)
    elseif a.rule == @RULE_extendedid(3)
        scan_extendedid_name_call(a.child[1], env)
        scan_exprlist(a.child[2], env)
    else
        throw(TranspileError("bad name construction"))
    end
end

function convert_extendedid_name_call(a::AstNode, env::AstEnv)
    @assert @RULE_extendedid(0) < a.rule < @RULE_extendedid(100)
    @assert isempty(env.declared_identifiers)
    if a.rule == @RULE_extendedid(1)
        return makeunknown(a.child[1]::String)
    elseif a.rule == @RULE_extendedid(2)
        s = make_nocopy(convert_expr(b.child[1], env))
        return Expr(:call, :rt_backtick, s)
    elseif a.rule == @RULE_extendedid(3)
        head = convert_extendedid_name_call(a.child[1]::AstNode, env)
        arg = convert_exprlist(a.child[2]::AstNode, env)
        return Expr(:call, :rt_name_cross, head, make_tuple_array_nocopy(arg)...)
    else
        throw(TranspileError("bad name construction"))
    end
end

function push_incrementby!(out::Expr, left::AstNode, right::Int, env::AstEnv)
    if left.rule == @RULE_expr(2) || 0 < left.rule - @RULE_elemexpr(0) < 100
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(99)
            var = a.child[1]::String
            if haskey(env.declared_identifiers, var)
                push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign_last, Symbol(var), Expr(:call, :rtplus, Symbol(var), right))))
            else
                push!(out.args, Expr(:call, :rt_incrementby, makeunknown(var), right))
            end
        elseif a.rule == @RULE_elemexpr(98)
            @assert isempty(env.declared_identifiers)
            s = make_nocopy(convert_expr(b.child[1], env))
            push!(out.args, Expr(:call, :rt_incrementby, Expr(:call, :rt_backtick, s), right))
        elseif a.rule == @RULE_elemexpr(4)
            b = make_nocopy(convert_expr(a.child[1], env))
            c = a.child[2]
            c.child[1].rule == @RULE_extendedid(1) || throw(TranspileError("rhs of dot in assignment is no good"))
            s = c.child[1].child[1]::String
            length(s) < 2 || s[1:2] != "r_" || throw(TranspileError("cannot assign to r_ member of a newstruct"))
            is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
            if isa(b, Symbol)
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
            else
                t = gensym()
                push!(out.args, Expr(:(=), t, b))
                b = Expr(:(.), t, QuoteNode(Symbol(s)))
            end
            push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign_last, b, Expr(:call, :rtplus, b, right))))
        elseif a.rule == @RULE_elemexpr(6)
            @assert isempty(env.declared_identifiers)
            s, ok = convert_elemexpr_name_call(a, env)
            ok || throw(TranspileError("bad name construction"))
            push!(out.args, Expr(:call, :rt_incrementby, s, right))
        else
            throw(TranspileError("cannot increment/decrement lhs"))
        end
    elseif left.rule == @RULE_extendedid(1)
        var = left.child[1]::String
        if haskey(env.declared_identifiers, var)
            push!(out.args, Expr(:(=), Symbol(var), Expr(:rt_assign_last, Symbol(var), Expr(:call, :rtplus, Symbol(var), right))))
        else
            push!(out.args, Expr(:call, :rt_incrementby, makeunknown(var), right))
        end
    elseif left.rule == @RULE_extendedid(2)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_expr(left.child[1], env))
        push!(out.args, Expr(:call, :rt_incrementby, Expr(:call, :rt_backtick, s), right))
    elseif left.rule == @RULE_extendedid(3)
        @assert isempty(env.declared_identifiers)
        s = convert_extendedid_name_call(left, env)
        push!(out.args, Expr(:call, :rt_incrementby, s, right))
    elseif left.rule == @RULE_expr(3)
        t1 = gensym()
        t2 = gensym()
        t3 = gensym()
        push!(out.args, Expr(:(=), t1, make_nocopy(convert_expr(left.child[1], env))))
        push!(out.args, Expr(:(=), t2, make_nocopy(convert_expr(left.child[2], env))))
        push!(out.args, Expr(:(=), t3, make_nocopy(convert_expr(left.child[3], env))))
        push!(out.args, Expr(:call, :rtsetindex_laste, t1, t2, t3,
                            Expr(:call, :rtplus, Expr(:call, :rtgetindex, t1, t2, t3), right)))
    elseif left.rule == @RULE_expr(4)
        t1 = gensym()
        t2 = gensym()
        push!(out.args, Expr(:(=), t1, make_nocopy(convert_expr(left.child[1], env))))
        push!(out.args, Expr(:(=), t2, make_nocopy(convert_expr(left.child[2], env))))
        push!(out.args, Expr(:call, :rtsetindex_last, t1, t2,
                            Expr(:call, :rtplus, Expr(:call, :rtgetindex, t1, t2), right)))
    else
        throw(TranspileError("cannot increment/decrement lhs"))
    end
end

function scan_assignment(left::AstNode, env::AstEnv)
    if left.rule == @RULE_expr(2) || @RULE_elemexpr(0) < left.rule < @RULE_elemexpr(100)
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(99)
            scan_add_appearance(a.child[1]::String, env)
        elseif a.rule == @RULE_elemexpr(98)
            scan_expr(a.child[1], env)
            env.everything_is_screwed = true
        elseif a.rule == @RULE_elemexpr(4)
            scan_expr(a.child[1], env)
            a.child[2].rule == @RULE_elemexpr(99) || throw(TranspileError("rhs of dot in assignment is no good"))
        elseif a.rule == @RULE_elemexpr(9)
        elseif a.rule == @RULE_elemexpr(6)
            h, ok = scan_elemexpr_name_call(a, env)
            ok || throw(TranspileError("bad name construction"))
        end
    elseif left.rule == @RULE_extendedid(1)
        scan_add_appearance(left.child[1]::String, env)
    elseif left.rule == @RULE_extendedid(2)
        scan_expr(left.child[1], env)
        env.everything_is_screwed = true
    elseif left.rule == @RULE_extendedid(3)
        scan_extendedid_name_call(left, env)
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

function push_assignment!(rest::Symbol, last::Bool, out::Expr, left::AstNode, right, env::AstEnv)
    if left.rule == @RULE_expr(2) || @RULE_elemexpr(0) < left.rule < @RULE_elemexpr(100)
        a::AstNode = left.rule == @RULE_expr(2) ? left.child[1] : left
        @assert 0 < a.rule - @RULE_elemexpr(0) < 100
        if a.rule == @RULE_elemexpr(99)
            var = a.child[1]::String
            if haskey(env.declared_identifiers, var)
                if last
                    push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign_last, Symbol(var), right)))
                else
                    push!(out.args, Expr(:(=), Expr(:tuple, Symbol(var), rest), Expr(:call, :rt_assign_more, Symbol(var), right)))
                end
            else
                if last
                    push!(out.args, Expr(:call, :rtassign_last, makeunknown(var), right))
                else
                    push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_more, makeunknown(var), right)))
                end
            end
        elseif a.rule == @RULE_elemexpr(98)
            @assert isempty(env.declared_identifiers)
            s = make_nocopy(convert_expr(a.child[1], env))
            if last
                push!(out.args, Expr(:call, :rtassign_last, Expr(:call, :rt_backtick, s), right))
            else
                push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_more, Expr(:call, :rt_backtick, s), right)))
            end
        elseif a.rule == @RULE_elemexpr(4)
            b = make_nocopy(convert_expr(a.child[1], env))
            c = a.child[2]
            c.rule == @RULE_elemexpr(99) || throw(TranspileError("rhs of dot in assignment is no good"))
            s = c.child[1]::String
            length(s) < 2 || s[1:2] != "r_" || throw(TranspileError("cannot assign to r_ member of a newstruct"))
            is_valid_newstruct_member(s) || throw(TranspileError(s * " is not a valid newstruct member name"))
            if isa(b, Symbol)
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
                if last
                    push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign_last, b, right)))
                else
                    push!(out.args, Expr(:(=), Expr(:tuple, b, rest), Expr(:call, :rt_assign_more, b, right)))
                end
            else
                b = Expr(:(.), b, QuoteNode(Symbol(s)))
                if last
                    push!(out.args, Expr(:(=), b, Expr(:call, :rt_assign_last, b, right)))
                else
                    push!(out.args, Expr(:(=), Expr(:tuple, b, rest), Expr(:call, :rt_assign_more, b, right)))
                end
            end
        elseif a.rule == @RULE_elemexpr(9)
            t = a.child[1]::Int
            haskey(system_var_to_string, t) || throw(TranspileError("internal error push_assignment - elemexpr 9"))
            if last
                push!(out.args, Expr(:call, Symbol("rt_set_" * system_var_to_string[t] * "_last"), right))
            else
                push!(out.args, Expr(:(=), rest, Expr(:call, Symbol("rt_set_" * system_var_to_string[t] * "_more"), right)))
            end
        elseif a.rule == @RULE_elemexpr(6)
            @assert isempty(env.declared_identifiers)
            s, ok = convert_elemexpr_name_call(a, env)
            ok || throw(TranspileError("bad name construction"))
            if last
                push!(out.args, Expr(:call, :rtassign_names_last, s, right))
            else
                push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_names_more, s, right)))
            end
        else
            throw(TranspileError("cannot assign to lhs"))
        end
    elseif left.rule == @RULE_extendedid(1)
        var = left.child[1]::String
        if haskey(env.declared_identifiers, var)
            if last
                push!(out.args, Expr(:(=), Symbol(var), Expr(:call, :rt_assign_last, Symbol(var), right)))
            else
                push!(out.args, Expr(:(=), Expr(:tuple, Symbol(var), rest), Expr(:call, :rt_assign_more, Symbol(var), right)))
            end
        else
            if last
                push!(out.args, Expr(:call, :rtassign_last, makeunknown(var), right))
            else
                push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_more, makeunknown(var), right)))
            end
        end
    elseif left.rule == @RULE_extendedid(2)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_expr(left.child[1], env))
        if last
            push!(out.args, Expr(:call, :rtassign_last, Expr(:call, :rt_backtick, s), right))
        else
            push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_more, Expr(:call, :rt_backtick, s), right)))
        end
    elseif left.rule == @RULE_extendedid(3)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_extendedid_name_call(left, env))
        if last
            push!(out.args, Expr(:call, :rtassign_names_last, s, right))
        else
            push!(out.args, Expr(:(=), rest, Expr(:call, :rtassign_names_more, s, right)))
        end
    elseif left.rule == @RULE_expr(3)
        if last
            push!(out.args, Expr(:call, :rtsetindex_last, make_nocopy(convert_expr(left.child[1], env)),
                                                          make_nocopy(convert_expr(left.child[2], env)),
                                                          make_nocopy(convert_expr(left.child[3], env)),
                                                          make_nocopy(right)))

        else
            push!(out.args, Expr(:(=), rest, Expr(:call, :rtsetindex_more, make_nocopy(convert_expr(left.child[1], env)),
                                                                           make_nocopy(convert_expr(left.child[2], env)),
                                                                           make_nocopy(convert_expr(left.child[3], env)),
                                                                           make_nocopy(right))))
        end
    elseif left.rule == @RULE_expr(4)
        if last
            push!(out.args, Expr(:call, :rtsetindex_last, make_nocopy(convert_expr(left.child[1], env)),
                                                          make_nocopy(convert_expr(left.child[2], env)),
                                                          make_nocopy(right)))
        else
            push!(out.args, Expr(:(=), rest, Expr(:call, :rtsetindex_more, make_nocopy(convert_expr(left.child[1], env)),
                                                                           make_nocopy(convert_expr(left.child[2], env)),
                                                                           make_nocopy(right))))
        end
    else
        throw(TranspileError("cannot assign to lhs 3"))
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

function rt_make_ring_from_ringlist(a::Slist)
    error("rt_make_ring_from_ringlist not implement")
    return rtInvalidRing
end

function rt_make_ring(coeff, var, ord)
    coeff = rt_parse_coeff(coeff)
    var = rt_parse_var(var)
    @error_check(length(ord) > 0, "bad ordering specification")
    ord = [rt_parse_ord(a) for a in ord]
    return Sring(libSingular.createRing(coeff, var, ord))
end

rt_make_qring(a::Sring) = a

function rt_make_qring(a::Sideal)
    @warn_check(a.parent.value.cpp_object == rt_basering().value.cpp_object, "constructing qring outside of basering")
    r = libSingular.new_qring(a.value, a.parent.value)
    if r.cpp_object == C_NULL
        rt_error("qring construction failed")
        return rtInvalidRing
    else
        return Sring(r)
    end
end

function rt_declare_assign_ring(a::SName, b::Sring)
    n = length(rtGlobal.callstack)
    if n > 1
        rt_check_declaration_local(a.name, Sring)
        push!(rtGlobal.local_vars, Pair(a.name, b))
    else
        d = rt_check_declaration_global_ring_indep(a.name, Sring)
        d[a.name] = b
    end
    rt_set_current_ring(b)
    return
end

function rt_declare_assign_ring(a::Vector{SName}, b::Sring)
    @error_check(length(a) == 1, "ring construction expects one indexed name")
    rt_declare_assign_ring(a[1], b)
    return
end

function scan_assign_qring(a::AstNode, b::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_extendedid(0) < 100
    @assert 0 < b.rule - @RULE_exprlist(0) < 100
    scan_exprlist(b, env)
    env.everything_is_screwed = true    # change of basering
    if a.rule == @RULE_extendedid(1)
        scan_add_declaration(a.child[1]::String, "ring", env)
    elseif a.rule == @RULE_extendedid(2)
        scan_expr(b.child[1], env)
    elseif a.rule == @RULE_extendedid(3)
        scan_extendedid_name_call(a, env)
    else
        throw(TranspileError("internal error in scan_assign_qring"))
    end
end

function convert_assign_qring(a::AstNode, b::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_extendedid(0) < 100
    @assert 0 < b.rule - @RULE_exprlist(0) < 100
    rhs::Array{Any} = convert_exprlist(b, env)
    r = Expr(:block)
    @assert isempty(env.declared_identifiers)   # change of basering
    if a.rule == @RULE_extendedid(1)
        lhs = makeunknown(a.child[1]::String)
    elseif a.rule == @RULE_extendedid(2)
        lhs = Expr(:call, :rt_backtick, make_nocopy(convert_expr(a.child[1], env)))
    elseif a.rule == @RULE_extendedid(3)
        lhs = convert_extendedid_name_call(a, env)
    else
        throw(TranspileError("internal error in convert_assign_qring"))
    end
    push!(r.args, Expr(:call, :rt_declare_assign_ring, lhs, Expr(:call, :rt_make_qring, make_tuple_array_nocopy(rhs)...)))
    push!(r.args, :nothing)
    return r
end

function scan_assign(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_assign(0) < 100
    if a.rule == @RULE_assign(1)
        left::AstNode = a.child[1]
        if left.rule == @RULE_left_value(1) && left.child[1].child[1] === Int(QRING_CMD)
            scan_assign_qring(left.child[1].child[2], a.child[2], env)
            return
        end
        lhs::Array{AstNode} = AstNode[]
        scan_exprlist(a.child[2], env)
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
        if left.rule == @RULE_left_value(1) && left.child[1].child[1] === Int(QRING_CMD)
            return convert_assign_qring(left.child[1].child[2], a.child[2], env)
        end
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
        rest = gensym()
        if length(rhs) == 1
            rhsexpr = make_copy(rhs[1])
        else
            rhsexpr = Expr(:call, :rt_maketuple, make_tuple_array_copy(rhs)...)
        end
        for i in 1:length(lhs)
            push_assignment!(rest, i >= length(lhs), r, lhs[i], rhsexpr, env)
            rhsexpr = rest
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
                push!(t.args, Expr(:call, :rt_printout, make_nocopy(b)))
            end
        end
    else
        throw(TranspileError("internal error in convert_typecmd"))
    end
    return t
end

######################### ring constructor syntax ############################
#=
one syntax for constructing a ring is
    ring elemexpr = rlist, rlist, ordering

the code output for the two rlists will generated at runtime a ragged array of
SName objects which will be passed to rt_parse_coeff/rt_parse_var, which are
then passed to the low level ring constructor.

if the rlist looks like

    (x, y(i), (z(j), `s`(k)(l)))

i, j, k, l must evaluate to Int|Sintvec and s must evaluate to a Sstring

first the nested expr lists are flattened

[
 x,
 y(i),
 z(j),
 `s`(k)(l)
]

Then each of the four elements is either converted to an expression or code
that will generate a 1D array of SName opbjects.

[
    SName(:x),
    rt_name_cross([SName(:x)], i),
    rt_name_cross([SName(:z)], j),
    rt_name_cross(rt_name_cross(rt_backtick(s), k), l)
]

None of this has to be particularly fast because if you are constructing a ring
like this, your code is probably already screwed anyways.

=#

function scan_rlist_expr_head(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        return
    elseif a.rule == @RULE_elemexpr(98)
        scan_expr(a.child[1], env)
        env.everything_is_screwed = true
        return
    elseif a.rule == @RULE_elemexpr(6)
        scan_rlist_expr_head(a.child[1]::AstNode, env)
        scan_exprlist(a.child[2]::AstNode, env)
        return
    else
        throw(TranspileError("bad ring list construction"))
    end
end

function convert_rlist_expr_head(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        return Expr(:vect, makeunknown(a.child[1]::String))
    elseif a.rule == @RULE_elemexpr(98)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_expr(a.child[1], env))
        return Expr(:vect, Expr(:call, :rt_backtick, s))
    elseif a.rule == @RULE_elemexpr(6)
        head = convert_rlist_expr_head(a.child[1]::AstNode, env)
        arg = convert_exprlist(a.child[2]::AstNode, env)
        return Expr(:call, :rt_name_cross, head, make_tuple_array_nocopy(arg)...)
    else
        throw(TranspileError("bad ring list construction"))
    end
end

function scan_rlist_expr(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(2)
        b = a.child[1]
        if b.rule == @RULE_elemexpr(37)
            for c in b.child[1].child
                scan_rlist_expr(c, env)
            end
            return
        elseif b.rule == @RULE_elemexpr(99)
            return
        elseif b.rule == @RULE_extendedid(98)
            scan_expr(b.child[1], env)
            env.everything_is_screwed = true
            return
        elseif b.rule == @RULE_elemexpr(6)
            scan_rlist_expr_head(b, env)
            return
        else
            scan_elemexpr(b, env)
            return
        end
    else
        throw(TranspileError("bad ring list construction"))
    end
end

function push_rlist_expr!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(2)
        b = a.child[1]
        if b.rule == @RULE_elemexpr(37)
            for c in b.child[1].child
                push_rlist_expr!(r, c, env)
            end
            return
        elseif b.rule == @RULE_elemexpr(99)
            push!(r.args, makeunknown(b.child[1]::String))
            return
        elseif b.rule == @RULE_elemexpr(98)
            @assert isempty(env.declared_identifiers)
            s = make_nocopy(convert_expr(b.child[1], env))
            push!(r.args, Expr(:call, :rt_backtick, s))
            return
        elseif b.rule == @RULE_elemexpr(6)
            push!(r.args, convert_rlist_expr_head(b, env))
            return
        else
            push!(r.args, make_copy(convert_elemexpr(b, env)))
            return
        end
    else
        throw(TranspileError("bad ring list construction"))
    end
end

function scan_rlist(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_rlist(0) < 100
    if a.rule == @RULE_rlist(1)
        scan_rlist_expr(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_rlist"))
    end
end

function convert_expr_names(a::AstNode, env::AstEnv)
    r = Expr(:vect)
    push_rlist_expr!(r, a.child[1], env)
    return r
end

function convert_rlist(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_rlist(0) < 100
    if a.rule == @RULE_rlist(1)
        return convert_expr_names(a::AstNode, env::AstEnv)
    else
        throw(TranspileError("internal error in convert_rlist"))
    end
    return r
end

function scan_ordering_orderelem(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_orderelem(0) < 100
    if a.rule == @RULE_orderelem(1)
        return
    elseif a.rule == @RULE_orderelem(2)
        scan_exprlist(a.child[2], env)
    else
        throw(TranspileError("internal error in scan_ordering_orderelem"))
    end
end

function push_ordering_orderelem!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_orderelem(0) < 100
    if a.rule == @RULE_orderelem(1)
        push!(r.args, Expr(:vect, a.child[1].child[1]::String))
    elseif a.rule == @RULE_orderelem(2)
        b = convert_exprlist(a.child[2], env)
        push!(r.args, Expr(:vect, a.child[1].child[1]::String, make_tuple_array_copy(b)...))
    else
        throw(TranspileError("internal error in push_ordering_orderelem"))
    end
end

function scan_ordering_OrderingList(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_OrderingList(0) < 100
    if a.rule == @RULE_OrderingList(1)
        scan_ordering_orderelem(a.child[1], env)
    elseif a.rule == @RULE_OrderingList(2)
        scan_ordering_orderelem(a.child[1], env)
        scan_ordering_OrderingList(a.child[2], env)
    else
        throw(TranspileError("internal error in scan_ordering_OrderingList"))
    end
end

function push_ordering_OrderingList!(r::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_OrderingList(0) < 100
    if a.rule == @RULE_OrderingList(1)
        push_ordering_orderelem!(r, a.child[1], env)
    elseif a.rule == @RULE_OrderingList(2)
        push_ordering_orderelem!(r, a.child[1], env)
        push_ordering_OrderingList!(r, a.child[2], env)
    else
        throw(TranspileError("internal error in push_ordering_OrderingList"))
    end
end

function scan_ordering(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ordering(0) < 100
    if a.rule == @RULE_ordering(1)
        scan_ordering_orderelem(a.child[1], env)
    elseif a.rule == @RULE_ordering(2)
        scan_OrderingList(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_ordering"))
    end
end

function convert_ordering(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ordering(0) < 100
    r = Expr(:vect)
    if a.rule == @RULE_ordering(1)
        push_ordering_orderelem!(r, a.child[1], env)
    elseif a.rule == @RULE_ordering(2)
        push_ordering_OrderingList!(r, a.child[1], env)
    else
        throw(TranspileError("internal error in convert_ordering"))
    end
    return r
end


# make an array of String|Int to pass to libSingular.createRing
# this is just as messy as the singular coefficient specification :(
function rt_parse_coeff(coeff)
    coeff = collect(Iterators.flatten(coeff))
    @error_check(!isempty(coeff), "empty coefficient specification")
    r = Any[]
    a = coeff[1]
    if isa(a, SName)
        if a.name == :real || a.name == :complex
            a = String(a.name)
        else
            a = rt_lookup(a)
            isa(a, Int) || rt_error("bad coefficient specification")
        end
    else
        isa(a, Int) || rt_error("bad coefficient specification")
    end
    push!(r, a)
    for a in coeff[2:end]
        if isa(a, SName)
            a = rt_try_lookup(a)
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

# make an array of String to pass to libSingular.createRing
function rt_parse_var(var)
    var = collect(Iterators.flatten(var))
    @error_check(!isempty(var), "empty variable specification")
    r = String[]
    for a in var
        if isa(a, SName)
            push!(r, String(a.name))
        else
            rt_error("bad variable specification")
        end
    end
    return r
end

function rt_flatten_ord_weights!(w::Array{Int, 1}, a::Any)
    if isa(a, Int)
        push!(w, a)
    elseif isa(a, Sintvec)
        append!(w, a.value)
    elseif isa(a, Sintmat)
        append!(w, vec(transpose(a.value)))
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

function rt_blocksize_weights(w::Array{Int, 1})
    blocksize = length(w)
    if length(w) > 0
        return blocksize, w
    elseif length(w) != 0
        rt_error("bad order specification")
    end
end

function rt_parse_ord(ord)
    !isempty(ord) && isa(ord[1], String) || rt_error("bad order specification")
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

function scan_ringcmd_lhs(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        scan_add_declaration(a.child[1]::String, "ring", env)
    elseif a.rule == @RULE_elemexpr(98)
        scan_expr(a.child[1], env)
        env.everything_is_screwed = true
    elseif a.rule == @RULE_elemexpr(6)
        h, ok = scan_elemexpr_name_call(a, env)
        ok || throw(TranspileError("bad name construction"))
    else
        throw(TranspileError("bad name of ring"))
    end
end

function convert_ringcmd_lhs(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(99)
        s = a.child[1]::String
        if haskey(env.declared_identifiers, s)
            @assert env.declared_identifiers[s] == "ring"
            return Symbol(s), true
        else
            return makeunknown(s), false
        end
    elseif a.rule == @RULE_elemexpr(98)
        @assert isempty(env.declared_identifiers)
        return Expr(:call, :rt_backtick, make_nocopy(convert_expr(a.child[1], env))), false
    elseif a.rule == @RULE_elemexpr(6)
        b, ok = convert_elemexpr_name_call(a, env)
        ok || throw(TranspileError("bad name construction"))
        return b, false
    else
        throw(TranspileError("bad name of ring"))
    end
end

function scan_ringcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ringcmd(0) < 100
    if a.rule == @RULE_ringcmd(1)
        scan_rlist(a.child[2], env)
        scan_rlist(a.child[3], env)
        scan_ordering(a.child[4], env)
        scan_ringcmd_lhs(a.child[1], env)
    elseif a.rule == @RULE_ringcmd(2)
        scan_ringcmd_lhs(a.child[1], env)
    elseif a.rule == @RULE_ringcmd(3)
        scan_elemexpr(a.child[2], env)
        scan_ringcmd_lhs(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_ringcmd"))
    end
    env.everything_is_screwed = true # change of basering
end

function convert_ringcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_ringcmd(0) < 100
    r = Expr(:block)
    if a.rule == @RULE_ringcmd(1)
        ring = Expr(:call, :rt_make_ring, convert_rlist(a.child[2], env),
                                          convert_rlist(a.child[3], env),
                                          convert_ordering(a.child[4], env))
        var, use_local = convert_ringcmd_lhs(a.child[1], env)
    elseif a.rule == @RULE_ringcmd(2)
        ring = Expr(:call, :rt_make_ring, [32003],
                                          [makeunknown("x"), makeunknown("y"), makeunknown("z")],
                                          [["dp"]])
        var, use_local = convert_ringcmd_lhs(a.child[1], env)
    elseif a.rule == @RULE_ringcmd(3)
        ring = make_nocopy(convert_elemexpr(a.child[2], env))
        var, use_local = convert_ringcmd_lhs(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_ringcmd"))
    end
    if use_local
        @assert false   # nothing should be fast because basering is changing
        push!(r.args, Expr(:(=), var, ring))
        push!(r.args, Expr(:call, :rt_set_current_ring, var))
    else
        push!(r.args, Expr(:call, :rt_declare_assign_ring, var, ring))
    end
    return r
end

function prepend_killelem!(r::Expr, a::AstNode, env::AstEnv)
    if a.rule == @RULE_expr(2)
        a = a.child[1]
    end
    if a.rule == @RULE_elemexpr(99)
        s = a.child[1]::String
        @assert !haskey(env.declared_identifiers, s)
        push!(r.args, Expr(:call, :rtkill, makeunknown(s)))
    elseif a.rule == @RULE_elemexpr(98)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_expr(a.child[1], env))
        push!(r.args, Expr(:call, :rtkill, Expr(:call, :rt_backtick, s)))
    elseif a.rule == @RULE_elemexpr(6)
        @assert isempty(env.declared_identifiers)
        s, ok = convert_elemexpr_name_call(a, env)
        ok || throw(TranspileError("bad name construction"))
        push!(r.args, Expr(:call, :rtkill, s))
    elseif a.rule == @RULE_elemexpr(37)
        l = AstNode[]
        push_exprlist_expr!(l, a.child[1], env)
        for i in l
            prepend_killelem!(r, i, env)
        end
    else
        throw(TranspileError("bad argument to kill 2"))
    end
end

function scan_killcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_killcmd(0) < 100
    env.everything_is_screwed = true
    while true
        @assert 0 < a.rule - @RULE_killcmd(0) < 100
        if a.rule == @RULE_killcmd(1)
            scan_elemexpr(a.child[1], env)
            break
        elseif a.rule == @RULE_killcmd(2)
            scan_elemexpr(a.child[2], env)
            a = a.child[1]
        else
            throw(TranspileError("internal error in convert_killcmd"))
        end
    end
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

function scan_exportcmd(a::AstNode, env::AstEnv)
    scan_exprlist(a.child[1], env)
end

function convert_exportcmd(a::AstNode, env::AstEnv)
    l = AstNode[]
    push_exprlist_expr!(l, a.child[1], env)
    r = Expr(:block)
    for b::AstNode in l
        if b.rule == @RULE_expr(2)
            b = b.child[1]
        end
        if b.rule == @RULE_elemexpr(99)
            s = b.child[1]::String
            if haskey(env.declared_identifiers, s)
                push!(r.args, Expr(:call, :rt_export, makeunknown(s), Symbol(s)))
            else
                push!(r.args, Expr(:call, :rtexport, makeunknown(s)))
            end
        elseif b.rule == @RULE_elemexpr(98)
            s = make_nocopy(convert_expr(a.child[1], env))
            push!(r.args, Expr(:call, :rtexport, Expr(:call, :rt_backtick, s)))
        elseif b.rule == @RULE_elemexpr(6)
            c, ok = convert_elemexpr_name_call(b, env)
            ok || throw(TranspileError("bad name construction"))
            push!(r.args, Expr(:call, :rtexport, c))
        else
            throw(TranspileError("bad argument to export"))
        end
    end
    return r
end


function scan_scriptcmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_scriptcmd(0) < 100
    if a.rule == @RULE_scriptcmd(1)
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
        scan_assign(a.child[1], env)
    elseif a.rule == @RULE_command(2)
        scan_exportcmd(a.child[1], env)
    elseif a.rule == @RULE_command(3)
        scan_killcmd(a.child[1], env)
    elseif a.rule == @RULE_command(6)
        scan_ringcmd(a.child[1], env)
    elseif a.rule == @RULE_command(7)
        scan_scriptcmd(a.child[1], env)
    elseif a.rule == @RULE_command(8)
        b = a.child[1]
        if b.child[1].rule == @RULE_setrings(1)
            scan_expr(b.child[2], env)
            env.everything_is_screwed = true    # change of basering
        elseif b.child[1].rule == @RULE_setrings(2)
            throw(TranspileError("keepring is not allowed"))
        else
            throw(TranspileError("internal error in scan_command 8"))
        end
    elseif a.rule == @RULE_command(9)
        scan_typecmd(a.child[1], env)
    else
        throw(TranspileError("internal error in scan_command"*string(a.rule)))
    end
end

function convert_command(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_command(0) < 100
    if a.rule == @RULE_command(1)
        return convert_assign(a.child[1], env)
    elseif a.rule == @RULE_command(2)
        return convert_exportcmd(a.child[1], env)
    elseif a.rule == @RULE_command(3)
        return convert_killcmd(a.child[1], env)
    elseif a.rule == @RULE_command(6)
        return convert_ringcmd(a.child[1], env)
    elseif a.rule == @RULE_command(7)
        return convert_scriptcmd(a.child[1], env)
    elseif a.rule == @RULE_command(8)
        b = a.child[1]
        if b.child[1].rule == @RULE_setrings(1)
            return Expr(:call, :rt_set_current_ring, make_nocopy(convert_expr(b.child[2], env)))
        elseif b.child[1].rule == @RULE_setrings(2)
            throw(TranspileError("keepring is not allowed"))
        else
            throw(TranspileError("internal error in convert_command 8"))
        end
    elseif a.rule == @RULE_command(9)
        return convert_typecmd(a.child[1], env)
    else
        throw(TranspileError("internal error in convert_command"*string(a.rule)))
    end
end



function scan_declared_var(v::AstNode, typ::String, env::AstEnv)
    @assert 0 < v.rule - @RULE_extendedid(0) < 100
    if v.rule == @RULE_extendedid(1)
        scan_add_declaration(v.child[1]::String, typ, env)
    elseif v.rule == @RULE_extendedid(2)
        scan_expr(v.child[1], env)
        env.everything_is_screwed = true
    elseif v.rule == @RULE_extendedid(3)
        scan_extendedid_name_call(v, env)
    else
        throw(TranspileError("internal error in scan_declared_var"*string(v.rule)))
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
    elseif v.rule == @RULE_extendedid(2)
        @assert isempty(env.declared_identifiers)
        s = make_nocopy(convert_expr(v.child[1], env))
        return Expr(:call, Symbol("rt_declare_"*typ), Expr(:call, :rt_backtick, s), extra_args...)
    elseif v.rule == @RULE_extendedid(3)
        @assert isempty(env.declared_identifiers)
        b = convert_extendedid_name_call(v, env)
        return Expr(:call, Symbol("rt_declare_"*typ), b, extra_args...)
    else
        throw(TranspileError("internal error in convert_declared_var"*string(v.rule)))
    end
end


function scan_declare_ip_variable!(vars::Array{AstNode}, a::AstNode, env::AstEnv)
    while true
        @assert 0 < a.rule - @RULE_declare_ip_variable(0) < 100
        if @RULE_declare_ip_variable(1) <= a.rule <= @RULE_declare_ip_variable(4) ||
                                               a.rule == @RULE_declare_ip_variable(8)
            pushfirst!(vars, a.child[2])
            haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in scan_declare_ip_variable 1|2|3|4|8"))
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
            typ = cmd_to_builtin_type_string[a.child[1].child[1]::Int]
            for v in vars
                scan_declared_var(v, typ, env)
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
            haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in convert_declare_ip_variable 1|2|3|4|8"))
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
                numrows = make_nocopy(convert_expr(a.child[3], env))
                numcols = make_nocopy(convert_expr(a.child[4], env))
            else
                numrows = numcols = 1 # default matrix size is 1x1
            end
            pushfirst!(vars, a.child[2])
            r = Expr(:block)
            typ = cmd_to_builtin_type_string[a.child[1].child[1]::Int]
            for v in vars
                push!(r.args, convert_declared_var(v, typ, env, numrows, numcols))
                numrows = numcols = 1 # the rest of the matrices are 1x1
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
        test = make_nocopy(convert_expr(a.child[1], env))
        body = convert_lines(a.child[2], env)
        return Expr(:if, Expr(:call, :rt_asbool, test), body)
    elseif a.rule == @RULE_ifcmd(2)
        # if the "else" were correctly paired with an "if", it should have been handled by find_if_else
        throw(TranspileError("else without if"))
    elseif a.rule == @RULE_ifcmd(3)
        test = make_nocopy(convert_expr(a.child[1], env))
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
        test = make_nocopy(convert_expr(a.child[1], env))
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
        test = make_nocopy(convert_expr(a.child[2], env))
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

    return true, Expr(:if, Expr(:call, :rt_asbool, make_nocopy(convert_expr(b.child[1], env))),
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
        push!(body.args, Expr(:local, Expr(:(::), Symbol(v[1]), convert_typestring_to_symbol(v[2]))))
    end
end

function convert_procarglist!(arglist::Vector{Any}, body::Expr, a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_procarglist(0) < 100
    for i in a.child
        convert_procarg!(arglist, body, i, env, i === a.child[end])
    end
    if env.branchto_appeared
        push!(arglist, Expr(:(...), Symbol("##")))
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

function convert_procarg!(arglist::Vector{Any}, body::Expr, a::AstNode, env::AstEnv, at_end::Bool)
    @assert 0 < a.rule - @RULE_procarg(0) < 100
    if a.rule == @RULE_procarg(1)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        t = a.child[1]::String
    elseif @RULE_procarg(2) <= a.rule <= @RULE_procarg(7)
        b = a.child[2]
        b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
        haskey(cmd_to_builtin_type_string, a.child[1]::Int) || throw(TranspileError("internal error in convert_procarg"))
        t = cmd_to_builtin_type_string[a.child[1]::Int]
    else
        throw(TranspileError("internal error in convert_procarg"))
    end
    b.rule == @RULE_extendedid(1) || throw(TranspileError("proc argument must be a name"))
    s = b.child[1]::String
    # arguments are eaten with rt_convert2T, NOT with rt_cast2T
    if s == "#"
        !env.branchto_appeared || throw(TranspileError("proc argument # not allowed with branchTo"))
        at_end || throw(TranspileError("proc argument # only allowed at the end"))
        # our argument tuple might contain uncopied references
        # the copy will turn the tuple into a bona fide singular object, which is expected by rt_convert2T
        inside = Expr(:vect, Expr(:(...), Symbol("#"*s)))
        inside = Expr(:call, STuple, Expr(:call, :map, :rt_copy_tmp, inside))
        inside = Expr(:call, Symbol("rt_convert2"*t), inside)
        if haskey(env.declared_identifiers, s)
            push!(body.args, Expr(:(=), Symbol(s), inside))
        else
            push!(body.args, Expr(:call, Symbol("rt_parameter_"*t), makeunknown(s), inside))
        end
        push!(arglist, Expr(:(...), Symbol("#"*s)))
    else
        if haskey(env.declared_identifiers, s)
            push!(body.args, Expr(:(=), Symbol(s), Expr(:call, Symbol("rt_convert2"*t), Symbol("#"*s))))
        else
            push!(body.args, Expr(:call, Symbol("rt_parameter_"*t), makeunknown(s), Symbol("#"*s)))
        end
        push!(arglist, Symbol("#"*s))
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
    if a.rule == @RULE_proccmd(1) || a.rule == @RULE_proccmd(2)
        s = a.child[2]::String
        internalfunc = procname_to_func(s)
        args = Any[]
        body = Expr(:block)
        newenv = AstEnv(env.package, s,
                        true,   # branchTo is allowed
                        false,  # have not seen branchTo yet
                        true,   # return is allowed
                        true,   # at top
                        false, false, # nothing is screwed yet
                        Set{String}(),
                        Dict{String, Int}(), Dict{String, String}())
        if a.rule == @RULE_proccmd(2)
            fxnargs = a.child[3]
            fxnbody = a.child[4]
        else
            # empty args
            fxnargs = AstNodeMake(@RULE_procarglist(1))
            fxnbody = a.child[3]
        end
        scan_procarglist(fxnargs, newenv)
        scan_lines(fxnbody, newenv, true)
        convert_proc_prologue(body, newenv)
        convert_procarglist!(args, body, fxnargs, newenv)
        join_blocks!(body, convert_lines(fxnbody, newenv))
        # procedures return nothing by default
        push!(body.args, Expr(:call, :rt_leavefunction))
        push!(body.args, Expr(:return, :rtnothing))
        r = Expr(:block)
        push!(r.args, Expr(:function, Expr(:call, internalfunc, args...), body))
        procobj = Expr(:call, :Sproc, internalfunc, s, QuoteNode(env.package))
        if haskey(env.declared_identifiers, s)
            @assert env.declared_identifers[s] == "proc"
            push!(r.args, Expr(:(=), Symbol(s), procobj))

        else
            push!(r.args, Expr(:call, :rt_declare_proc, makeunknown(s)))
            push!(r.args, Expr(:call, :rtassign_last, makeunknown(s), procobj))
            return r
        end
    else
        throw(TranspileError("internal error in convert_proccmd"))
    end
end

function scan_filecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_filecmd(0) < 100
    if a.rule == @RULE_filecmd(1)
        env.everything_is_screwed = true    # execute
    else
        throw(TranspileError("internal error in scan_filecmd"))
    end
end

function convert_filecmd(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_filecmd(0) < 100
    if a.rule == @RULE_filecmd(1)
        arg1 = Expr(:call, :rtread, convert_stringexpr(a.child[1], env))
        t1 = gensym()
        t2 = gensym()
        return Expr(:block,
                    Expr(:(=), Expr(:tuple, t1, t2), Expr(:call, :rtexecute, arg1)),
                    Expr(:if, t2, Expr(:return, t1)))
    else
        throw(TranspileError("internal error in convert_filecmd"))
    end
end

function scan_flowctrl(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(1)
        scan_ifcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(2)
        scan_whilecmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(3)
    elseif a.rule == @RULE_flowctrl(4)
        scan_forcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(5)
        scan_proccmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(6)
        scan_filecmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(8)
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
    elseif a.rule == @RULE_flowctrl(3)
        return Expr(:block)
    elseif a.rule == @RULE_flowctrl(4)
        return convert_forcmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(5)
        return convert_proccmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(6)
        return convert_filecmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(8)
        return Expr(:block)
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
    elseif a.rule == @RULE_top_pprompt(99)
        return convert_returncmd(a.child[1], env)
    elseif a.rule == @RULE_top_pprompt(5)
        return :nothing
    elseif a.rule == @RULE_top_pprompt(5)
        return :nothing
    else
        throw(TranspileError("internal error in convert_top_pprompt"))
    end
end

function typestring_could_be_ring_dep(s::String)
    if s == "def" || s == "list"
        return true
    end
    if !haskey(builtin_typestring_to_symbol, s)
        return false
    end
    return eval(builtin_typestring_to_symbol[s]) <: SingularRingType
end

function scan_lines(a::AstNode, env::AstEnv, at_top::Bool)
    @assert 0 < a.rule - @RULE_lines(0) < 100
    for i in a.child
        env.at_top = at_top
        scan_pprompt(i, env)
    end
    if at_top
        if env.everything_is_screwed || !rtGlobal.optimize_locals
            empty!(env.declared_identifiers)
        elseif env.rings_are_screwed
            env.declared_identifiers = filter(
                                x->(!typestring_could_be_ring_dep(last(x))),
                                                     env.declared_identifiers)
        end
        for v in env.screwed_names
            delete!(env.declared_identifiers, v)
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

# return is a toplevel or block
function convert_toplines(a::AstNode, env::AstEnv)
    @assert 0 < a.rule - @RULE_top_lines(0) < 100
    r = Expr(env.ok_to_return ? :block : :toplevel)
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

# this is the external interface to the transpiler, not rtexecute!
function execute(s::String; debuglevel::Int = 0)

    libpath = realpath(joinpath(@__DIR__, "..", "local", "lib", "libsingularparse." * Libdl.dlext))
    # as with rtexecute, we allow the trailing semicolon to be omitted
    ast::AstNode = @eval ccall((:singular_parse, $libpath), Any, (Cstring,), $(s*";"))

    if ast.rule == @RULE_SYNTAX_ERROR
        error("syntax error around line "*string(ast.child[1]::Int)*" of top level input")
    else

#        println("singular ast:")
#        astprint(ast.child[1], 0)

        t0 = time()

        # no need to call scan because everything is by definition screwed at the top level
        env = AstEnv(:Top, "",
                     false, # branchTo not allowed
                     false, # branchTo not seen yet
                     false, # return not allowed
                     true,  # at top
                     true, true,    # everthing is screwed
                     Set{String}(),
                     Dict{String, Int}(), Dict{String, String}())
        expr = convert_toplines(ast, env)
        t1 = time()

        if debuglevel > 0
            println()
            println("---------- transpiled code ----------")
            for i in expr.args; println(i); end;
            println("------- transpiled in ", trunc(1000*(t1 - t0)), " ms -------")
            println()
        end

        # these need to be corrected in the case that a previous eval threw

        @assert length(rtGlobal.callstack) >= 1
        resize!(rtGlobal.callstack, 1)
        empty!(rtGlobal.local_vars)

        eval(expr)
    end
end


################### library loader ############################################


function loadconvert_proccmd(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_proccmd(0) < 100
    if a.rule == @RULE_proccmd(1) || a.rule == @RULE_proccmd(2)
        @assert a.child[1] == 0 || a.child[1] == 1
        static = (a.child[1] != 0)
        s = a.child[2]::String
        internalfunc = procname_to_func(s)
        args = Any[]
        body = Expr(:block)
        newenv = AstEnv(env.package, s,
                        true,   # branchTo is allowed
                        false,  # have not seen branchTo yet
                        true,   # return is allowed
                        true,   # at top
                        false, false,   # nothing is screwed yet
                        Set{String}(),
                        Dict{String, Int}(), Dict{String, String}())
        if a.rule == @RULE_proccmd(2)
            fxnargs = a.child[3]
            fxnbody = a.child[4]
        else
            # empty args
            fxnargs = AstNodeMake(@RULE_procarglist(1))
            fxnbody = a.child[3]
        end
        scan_procarglist(fxnargs, newenv)
        scan_lines(fxnbody, newenv, true)
        convert_proc_prologue(body, newenv)
        convert_procarglist!(args, body, fxnargs, newenv)
        join_blocks!(body, convert_lines(fxnbody, newenv))
        # procedures return nothing by default
        push!(body.args, Expr(:call, :rt_leavefunction))
        push!(body.args, Expr(:return, :rtnothing))

        jfunction = eval(Expr(:function, Expr(:call, internalfunc, args...), body))
        our_proc_object = Sproc(jfunction, s, env.package)

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


function loadconvert_flowctrl(a::AstNode, env::AstLoadEnv)
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(3)
    elseif a.rule == @RULE_flowctrl(5)
        loadconvert_proccmd(a.child[1], env)
    elseif a.rule == @RULE_flowctrl(8)
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
        @error_check(b.rule == @RULE_elemexpr(99), "???")
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
        #println(b, " -> ", c)
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



############### ast printer  ##################################################




function astprint_top_lines(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_top_lines(0) < 100
    join([astprint_top_pprompt(i, env, indent) for i in a.child])
end

function astprint_top_pprompt(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_top_pprompt(0) < 100
    if a.rule == @RULE_top_pprompt(1)
        return astprint_flowctrl(a.child[1], env, indent)
    elseif a.rule == @RULE_top_pprompt(2)
        return astprint_command(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_top_pprompt(3)
        return astprint_declare_ip_variable(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_top_pprompt(99)
        return astprint_returncmd(a.child[1], env, indent)
    elseif a.rule == @RULE_top_pprompt(4)
        return "~"
    elseif a.rule == @RULE_top_pprompt(5)
        return ";"
    else
        throw(TranspileError("internal error in astprint_top_pprompt"))
    end
end

function astprint_lines(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_lines(0) < 100
    return join([astprint_pprompt(i) for i in a.child], "\n")*"\n"
end

function astprint_pprompt(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_pprompt(0) < 100
    if a.rule == @RULE_pprompt(1)
        return astprint_flowctrl(a.child[1], env, indent)
    elseif a.rule == @RULE_pprompt(2)
        return astprint_command(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_pprompt(3)
        return astprint_declare_ip_variable(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_pprompt(4)
        return astprint_returncmd(a.child[1], env, indent)
    elseif a.rule == @RULE_pprompt(5)
        return "~"
    elseif a.rule == @RULE_pprompt(6)
        return ";"
    else
        throw(TranspileError("internal error in astprint_pprompt"))
    end
end

function astprint_npprompt(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_npprompt(0) < 100
    if a.rule == @RULE_npprompt(1)
        return astprint_flowctrl(a.child[1], env, indent)
    elseif a.rule == @RULE_npprompt(2)
        return astprint_command(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_npprompt(3)
        return astprint_declare_ip_variable(a.child[1], env, indent)*";"
    elseif a.rule == @RULE_npprompt(4)
        return astprint_returncmd(a.child[1], env, indent)
    elseif a.rule == @RULE_npprompt(5)
        return "~"
    else
        throw(TranspileError("internal error in astprint_npprompt"))
    end
end

function astprint_flowctrl(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_flowctrl(0) < 100
    if a.rule == @RULE_flowctrl(1)
        return astprint_ifcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(2)
        return astprint_whilecmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(3)
        return astprint_example_dummy(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(4)
        return astprint_forcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(5)
        return astprint_proccmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(6)
        return astprint_filecmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(7)
        return astprint_helpcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_flowctrl(8)
        return astprint_examplecmd(a.child[1], env, indent)
    else
        throw(TranspileError("internal error in astprint_flowctrl"))
    end
end

function astprint_example_dummy(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_example_dummy(0) < 100
    if a.rule == @RULE_example_dummy(1)
        return "example {" * astprint_lines(a.child[1], env, indent) * "}"
    else
        throw(TranspileError("internal error in example_dummy"))
    end
end

function astprint_command(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_command(0) < 100
    if a.rule == @RULE_command(1)
        return astprint_assign(a.child[1], env, indent)
    elseif a.rule == @RULE_command(2)
        return astprint_exportcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(3)
        return astprint_kill(a.child[1], env, indent)
    elseif a.rule == @RULE_command(4)
        return astprint_listcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(5)
        return astprint_parametercmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(6)
        return astprint_ringcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(7)
        return astprint_scriptcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(8)
        return astprint_setringcmd(a.child[1], env, indent)
    elseif a.rule == @RULE_command(9)
        return astprint_typecmd(a.child[1], env, indent)
    else
        throw(TranspileError("internal error in astprint_command"))
    end
end

function astprint_assign(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_assign(0) < 100
    if a.rule == @RULE_assign(1)
        return astprint_leftvalue(a.child[1], env, indent) * astprint_exprlist(a.child[1], env, indent)
    else
        throw(TranspileError("internal error in astprint_assign"))
    end
end

function astprint_elemexpr(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_elemexpr(0) < 100
    if a.rule == @RULE_elemexpr(1)
        return a.child[1]
    elseif a.rule == @RULE_elemexpr(99)
        return a.child[1]
    elseif a.rule == @RULE_elemexpr(98)
        return "`" * astprint_expr(a.child[1]) * "`"
    elseif a.rule == @RULE_elemexpr(3)
        return astprint_elemexpr(a.child[1], env, indent) * "::" * astprint_elemexpr(a.child[2], env, 0)
    elseif a.rule == @RULE_elemexpr(4)
        return astprint_expr(a.child[1], env, indent) * "." * astprint_elemexpr(a.child[2], env, 0)
    elseif a.rule == @RULE_elemexpr(5)
        return astprint_elemexpr(a.child[1], env, indent) * "()"
    elseif a.rule == @RULE_elemexpr(6)
        return astprint_elemexpr(a.child[1], env, indent) * "(" * astprint_exprlist(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(7)
        return "[" * astprint_exprlist(a.child[1], env, indent) * "]"
    elseif a.rule == @RULE_elemexpr(8)
        return a.child[1]
    elseif a.rule == @RULE_elemexpr(9)
        return cmd_to_string[a.child[1]]
    elseif a.rule == @RULE_elemexpr(10)
        return astprint_stringexpr(a.child[1], env, indent)
    elseif a.rule == @RULE_elemexpr(11)
        return "proc(" * astprint_expr(a.child[1], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(12)
        return cmd_to_builtin_type_string[a.child[1]] * "(" * astprint_expr(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(13)
        return cmd_to_builtin_type_string[a.child[1]] * "(" * astprint_exprlist(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(14)
        return cmd_to_builtin_type_string[a.child[1]] * "()"
    elseif a.rule == @RULE_elemexpr(15)
        return cmd_to_builtin_type_string[a.child[1]] * "(" * astprint_expr(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(16)
        return cmd_to_builtin_type_string[a.child[1]] * "(" * astprint_exprlist(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(17)
        return cmd_to_builtin_type_string[a.child[1]] * "()"
    elseif @RULE_elemexpr(18) <= a.rule <= @RULE_elemexpr(21)
        return cmd_to_string[a.child[1]] * "(" * astprint_expr(a.child[2], env, indent) * ")"
    elseif @RULE_elemexpr(22) <= a.rule <= @RULE_elemexpr(25)
        return cmd_to_string[a.child[1]] * "(" * astprint_expr(a.child[2], env, indent) * ", " * astprint_expr(a.child[3], env, indent) * ")"
    elseif @RULE_elemexpr(26) <= a.rule <= @RULE_elemexpr(29)
        return cmd_to_string[a.child[1]] * "(" * astprint_expr(a.child[2], env, indent) * ", " * astprint_expr(a.child[3], env, indent) * ", " * astprint_expr(a.child[4], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(30)
        return cmd_to_string[a.child[1]] * "()"
    elseif a.rule == @RULE_elemexpr(31)
        return cmd_to_string[a.child[1]] * "(" * astprint_exprlist(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(32)
        return astprint_mat_cmd(a.child[1], env, indent) * "(" * astprint_expr(a.child[2], env, indent) * ", " * astprint_expr(a.child[3], env, indent) * ", " * astprint_expr(a.child[4], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(33)
        return astprint_mat_cmd(a.child[1], env, indent) * "(" * astprint_expr(a.child[2], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(34)
        return "ring(" * astprint_rlist(a.child[1], env, indent) * ", " * astprint_rlist(a.child[2], env, indent) * ", " * astprint_ordering(a.child[3], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(35)
        return "ring(" * astprint_expr(a.child[1], env, indent) * ")"
    elseif a.rule == @RULE_elemexpr(36)
        return astprint_extendedid(a.child[1], env, indent) * " -> {" * astprint_lines(a.child[2], env, indent) * "}"
    elseif a.rule == @RULE_elemexpr(37)
        return "(" * astprint_exprlist(a.child[1], env, indent) * ")"
    else
        throw(TranspileError("internal error in astprint_elemexpr"))
    end
end

function astprint_exprlist(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_exprlist(0) < 100
    return join([astprint_expr(i, env, 0) for i in a.child], ", ")
end

function astprint_expr(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_expr(0) < 100
    if a.rule == @RULE_expr(1)
        return astprint_expr_arithmetic(a.child[1], env, indent)
    elseif a.rule == @RULE_expr(2)
        return astprint_elemexpr(a.child[1], env, indent)
    elseif a.rule == @RULE_expr(3)
        return astprint_expr(a.child[1], env, indent) * "[" * astprint_expr(a.child[2], env, 0) * ", " * astprint_expr(a.child[3], env, 0) * "]"
    elseif a.rule == @RULE_expr(4)
        return astprint_expr(a.child[1], env, indent) * "[" * astprint_expr(a.child[2], env, 0) * "]"
    elseif @RULE_expr(5) <= a.rule <= @RULE_expr(9)
        return "apply(" * astprint_expr(a.child[1], env, 0) * ", " * cmd_to_string[a.child[2]] * ")"
    elseif a.rule == @RULE_expr(10)
        return "apply(" * astprint_expr(a.child[1], env, 0) * ", " * astprint_expr(a.child[2], env, 0) * ")"
    elseif a.rule == @RULE_expr(11)
        return "?????????????"
    elseif a.rule == @RULE_expr(12)
        return "?????????????"
    elseif a.rule == @RULE_expr(13)
        return "ASSUME(" * astprint_expr(a.child[1], env, 0) * ", " * astprint_expr(a.child[2], env, 0) * ")"
    elseif a.rule == @RULE_expr(14)
        return "?????????????"
    else
        throw(TranspileError("internal error in astprint_expr"))
    end
end

function astprint_quote_start(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_quote_start(0) < 100
    if a.rule == @RULE_quote_start(1)
        return "quote("
    else
        throw(TranspileError("internal error in astprint_quote_start"))
    end
end

function astprint_assume_start(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_assume_start(0) < 100
    if a.rule == @RULE_assume_start(1)
        return "ASSUME("
    else
        throw(TranspileError("internal error in astprint_assume_start"))
    end
end

function astprint_quote_end(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_quote_end(0) < 100
    if a.rule == @RULE_quote_end(1)
        return ")"
    else
        throw(TranspileError("internal error in astprint_quote_end"))
    end
end

function astprint_expr_arithmetic(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_expr_arithmetic(0) < 100
    if a.rule == @RULE_expr_arithmetic(1)
        return astprint_expr(a.child[1], env, 0) * "++"
    elseif a.rule == @RULE_expr_arithmetic(2)
        return astprint_expr(a.child[1], env, 0) * "--"
    elseif a.rule == @RULE_expr_arithmetic(3)
        return astprint_expr(a.child[1], env, 0) * " + " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(4)
        return astprint_expr(a.child[1], env, 0) * " - " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(5)
        return astprint_expr(a.child[1], env, 0) * "*" * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(6)
        return astprint_expr(a.child[1], env, 0) * "%" * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(7)
        return astprint_expr(a.child[1], env, 0) * "/" * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(8)
        return astprint_expr(a.child[1], env, 0) * "^" * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(9)
        return astprint_expr(a.child[1], env, 0) * " >= " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(10)
        return astprint_expr(a.child[1], env, 0) * " <= " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(11)
        return astprint_expr(a.child[1], env, 0) * " > " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(12)
        return astprint_expr(a.child[1], env, 0) * " < " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(13)
        return astprint_expr(a.child[1], env, 0) * " && " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(14)
        return astprint_expr(a.child[1], env, 0) * " || " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(15)
        return astprint_expr(a.child[1], env, 0) * " |= " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(16)
        return astprint_expr(a.child[1], env, 0) * " == " * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(17)
        return astprint_expr(a.child[1], env, 0) * ".." * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(18)
        return astprint_expr(a.child[1], env, 0) * ":" * astprint_expr(a.child[2], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(19)
        return "!" * astprint_expr(a.child[1], env, 0)
    elseif a.rule == @RULE_expr_arithmetic(20)
        return "-" * astprint_expr(a.child[1], env, 0)
    else
        throw(TranspileError("internal error in astprint_expr_arithmetic"))
    end
end

function astprint_left_value(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_left_value(0) < 100
    if a.rule == @RULE_left_value(1)
        return astprint_declare_ip_variable(a.child[1], env, 0) * " = "
    elseif a.rule == @RULE_left_value(2)
        return astprint_exprlist(a.child[1], env, 0) * " = "
    else
        throw(TranspileError("internal error in astprint_command"))
    end
end

function astprint_extendedid(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_extendedid(0) < 100
    if a.rule == @RULE_extendedid(1)
        return a.child[1]
    elseif a.rule == @RULE_extendedid(2)
        return "`" * astprint_expr(a.child[1], env, 0) * "`"
    elseif a.rule == @RULE_extendedid(3)
        return astprint_extendedid(a.child[1], env, 0) * "(" * astprint_exprlist(a.child[1]) * ")"
    else
        throw(TranspileError("internal error in astprint_extendedid"))
    end
end

function astprint_declare_ip_variable(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_declare_ip_variable(0) < 100
    if @RULE_declare_ip_variable(1) <= a.rule <= @RULE_declare_ip_variable(4)
        return cmd_to_string[a.child[1]] * " " * astprint_extendedid(a.child[1], env, 0)
    elseif a.rule == @RULE_declare_ip_variable(99)
        return a.child[1] * " " * astprint_extendedid(a.child[1], env, 0)
    elseif a.rule == @RULE_declare_ip_variable(5)
        return astprint_mat_cmd(a.child[1], env, 0) * " " * astpring_extendedid(a.child[2], env, 0) * "[" * astprint_expr(a.child[3], env, 0) * ", " * astprint_expr(a.child[4], env, 0) * "]"
    elseif a.rule == @RULE_declare_ip_variable(6)
        return astprint_mat_cmd(a.child[1], env, 0) * " " * astpring_extendedid(a.child[2], env, 0)
    elseif a.rule == @RULE_declare_ip_variable(7)
        return astprint_declare_ip_variable(a.child[1], env, 0) * ", " * astpring_extendedid(a.child[2], env, 0)
    elseif a.rule == @RULE_declare_ip_variable(8)
        return "proc " * astpring_extendedid(a.child[2], env, 0)
    else
        throw(TranspileError("internal error in astprint_declare_ip_variable"))
    end
end

function astprint_stringexpr(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_stringexpr(0) < 100
    if a.rule == @RULE_stringexpr(1)
        return a.child[1]
    else
        throw(TranspileError("internal error in astprint_stringexpr"))
    end
end

function astprint_rlist(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_rlist(0) < 100
    if a.rule == @RULE_rlist(1)
        return astprint_expr(a.child[1], env, 0)
    else
        throw(TranspileError("internal error in astprint_rlist"))
    end
end

function astprint_ordername(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_ordername(0) < 100
    if a.rule == @RULE_ordername(1)
        return a.child[1]
    else
        throw(TranspileError("internal error in astprint_ordername"))
    end
end

function astprint_orderelem(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_orderelem(0) < 100
    if a.rule == @RULE_orderelem(1)
        return astprint_ordername(a.child[1], env, 0)
    elseif a.rule == @RULE_orderelem(2)
        return astprint_ordername(a.child[1], env, 0) * "(" * astprint_exprlist(a.child[2], env, 0) * ")"
    else
        throw(TranspileError("internal error in astprint_ordername"))
    end
end

function astprint_OrderingList(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_OrderingList(0) < 100
    if a.rule == @RULE_OrderingList(1)
        return astprint_orderelem(a.child[1], env, 0)
    elseif a.rule == @RULE_OrderingList(1)
        return astprint_orderelem(a.child[1], env, 0) * ", " * astprint_OrderingList(a.child[2], env, 0)
    else
        throw(TranspileError("internal error in astprint_OrderingList"))
    end
end

function astprint_ordering(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_ordering(0) < 100
    if a.rule == @RULE_ordering(1)
        return astprint_orderelem(a.child[1], env, 0)
    elseif a.rule == @RULE_ordering(1)
        return "(" * astprint_OrderingList(a.child[1], env, 0) * ")"
    else
        throw(TranspileError("internal error in astprint_ordering"))
    end
end

function astprint_mat_cmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_mat_cmd(0) < 100
    if a.rule == @RULE_mat_cmd(1)
        return "matrix"
    elseif a.rule == @RULE_mat_cmd(2)
        return "intmat"
    elseif a.rule == @RULE_mat_cmd(3)
        return "bigintmat"
    else
        throw(TranspileError("internal error in astprint_mat_cmd"))
    end
end

function astprint_filecmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_filecmd(0) < 100
    if a.rule == @RULE_filecmd(1)
        return "<" * astprint_stringexpr(a.child[1], env, 0)
    else
        throw(TranspileError("internal error in astprint_filecmd"))
    end
end

function astprint_helpcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_helpcmd(0) < 100
    if a.rule == @RULE_helpcmd(1)
        return "help " * a.child[1] * ";"
    elseif a.rule == @RULE_helpcmd(2)
        return "help;"
    else
        throw(TranspileError("internal error in astprint_helpcmd"))
    end
end

function astprint_examplecmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_examplecmd(0) < 100
    if a.rule == @RULE_examplecmd(1)
        return "example " * a.child[1] * ";"
    else
        throw(TranspileError("internal error in astprint_examplecmd"))
    end
end

function astprint_exportcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_exportcmd(0) < 100
    if a.rule == @RULE_exportcmd(1)
        return "export " * astprint_exprlist(a.child[1])
    else
        throw(TranspileError("internal error in astprint_exportcmd"))
    end
end

function astprint_killcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_killcmd(0) < 100
    if a.rule == @RULE_killcmd(1)
        return "kill " * astprint_elemexpr(a.child[1])
    elseif a.rule == @RULE_killcmd(2)
        return astprint_killcmd(a.child[1], env, 0) * ", " * astprint_elemexpr(a.child[1])
    else
        throw(TranspileError("internal error in astprint_killcmd"))
    end
end

function astprint_listcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_listcmd(0) < 100
    if @RULE_listcmd(1) <= a.rule <= @RULE_listcmd(5)
        return "listvar(" * cmd_to_string[a.child[1]] * ")"
    elseif a.rule == @RULE_listcmd(6)
        return "listvar(" * astprint_mat_cmd(a.child[1], env, 0) * ")"
    elseif a.rule == @RULE_listcmd(7)
        return "listvar(" * "proc" * ")"
    elseif a.rule == @RULE_listcmd(8)
        return "listvar(" * astprint_elemexpr(a.child[1], env, 0) * ")"
    elseif @RULE_listcmd(9) <= a.rule <= @RULE_listcmd(13)
        return "listvar(" * astprint_elemexpr(a.child[1], env, 0) * ", " * cmd_to_string[a.child[2]] * ")"
    elseif a.rule == @RULE_listcmd(14)
        return "listvar(" * astprint_elemexpr(a.child[1], env, 0) * ", " * astprint_mat_cmd(a.child[2], env, 0) * ")"
    elseif a.rule == @RULE_listcmd(15)
        return "listvar(" * astprint_elemexpr(a.child[1], env, 0) * ", " * "proc" * ")"
    elseif a.rule == @RULE_listcmd(16)
        return "listvar()"
    else
        throw(TranspileError("internal error in astprint_listcmd"))
    end
end

function astprint_ringcmd1(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_ringcmd1(0) < 100
    if a.rule == @RULE_ringcmd1(1)
        return "ring"
    else
        throw(TranspileError("internal error in astprint_ringcmd1"))
    end
end

function astprint_ringcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_ringcmd(0) < 100
    if a.rule == @RULE_ringcmd(1)
        return "ring " * astprint_elemexpr(a.child[1], env, 0) * " = " * astprint_rlist(a.child[2], env, 0) * ", " * astprint_rlist(a.child[3], env, 0) * ", " * astprint_ordering(a.child[4], env, 0)
    elseif a.rule == @RULE_ringcmd(2)
        return "ring " * astprint_elemexpr(a.child[1], env, 0)
    elseif a.rule == @RULE_ringcmd(3)
        return "ring " * astprint_elemexpr(a.child[1], env, 0) * " = " * astprint_rlist(a.child[2], env, 0)
    elseif a.rule == @RULE_ringcmd(4)
        return "ring " * astprint_elemexpr(a.child[1], env, 0) * " = " * astprint_elemexpr(a.child[2], env, 0) * "[" * astpring_exprlist(a.child[3], env, 0) * "]"
    else
        throw(TranspileError("internal error in astprint_ringcmd"))
    end
end

function astprint_scriptcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_scriptcmd(0) < 100
    if a.rule == @RULE_scriptcmd(1)
        return cmd_to_string[a.child[1]] * " " * astprint_stringexpr(a.child[2], env, 0)
    else
        throw(TranspileError("internal error in astprint_scriptcmd"))
    end
end

function astprint_setrings(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_setrings(0) < 100
    if a.rule == @RULE_setrings(1)
        return "setring"
    elseif a.rule == @RULE_setrings(2)
        return "keepring"
    else
        throw(TranspileError("internal error in astprint_setrings"))
    end
end

function astprint_setringcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_setringcmd(0) < 100
    if a.rule == @RULE_setringcmd(1)
        return astprint_setrings(a.child[1], env, 0) * " " * astprint_expr(a.child[2], env, 0)
    else
        throw(TranspileError("internal error in astprint_setringcmd"))
    end
end

function astprint_typecmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_typecmd(0) < 100
    if a.rule == @RULE_typecmd(1)
        return "type " * astprint_expr(a.child[1], env, 0)
    elseif a.rule == @RULE_typecmd(2)
        return astprint_exprlist(a.child[1], env, 0)
    else
        throw(TranspileError("internal error in astprint_typecmd"))
    end
end

function astprint_ifcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_ifcmd(0) < 100
    if a.rule == @RULE_ifcmd(1)
        return "if (" * astprint_expr(a.child[1], env, 0) * ") {" * astprint_lines(a.child[2], env, 0) * "}"
    elseif a.rule == @RULE_ifcmd(2)
        return "else {" * astprint_lines(a.child[1], env, 0) * "}"
    elseif a.rule == @RULE_ifcmd(3)
        return "if (" * astprint_expr(a.child[1], env, 0) * ") break"
    elseif a.rule == @RULE_ifcmd(4)
        return "break"
    elseif a.rule == @RULE_ifcmd(5)
        return "continue"
    else
        throw(TranspileError("internal error in astprint_typecmd"))
    end
end

function astprint_whilecmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_whilecmd(0) < 100
    if a.rule == @RULE_whilecmd(1)
        return "while (" * astprint_expr(a.child[1], env, 0) * ") {" * astprint_lines(a.child[2], env, 0) * "}"
    else
        throw(TranspileError("internal error in astprint_whilecmd"))
    end
end

function astprint_forcmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_forcmd(0) < 100
    if a.rule == @RULE_forcmd(1)
        return "for (" * astprint_npprompt(a.child[1], env, 0) * "; " * astprint_expr(a.child[2], env, 0) * "; " * astprint_expr(a.child[3], env, 0) * ") {" * astprint_lines(a.child[4], env, 0) * "}"
    else
        throw(TranspileError("internal error in astprint_forcmd"))
    end
end

function astprint_proccmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_proccmd(0) < 100
    if a.rule == @RULE_proccmd(1)
        return "proc " * a.child[2] * "() {" * astprint_lines(a.child[3], env, 0) * "}"
    elseif a.rule == @RULE_proccmd(2)
        return "proc " * a.child[2] * "(" * procarglist(a.child[3], env, 0) * ") {" * astprint_lines(a.child[4], env, 0) * "}"
    else
        throw(TranspileError("internal error in astprint_typecmd"))
    end
end

function astprint_parametercmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_parametercmd(0) < 100
    if a.rule == @RULE_parametercmd(1)
    elseif a.rule == @RULE_parametercmd(2)
    else
        throw(TranspileError("internal error in astprint_parametercmd"))
    end
end

function astprint_returncmd(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_returncmd(0) < 100
    if a.rule == @RULE_returncmd(1)
    elseif a.rule == @RULE_returncmd(2)
    else
        throw(TranspileError("internal error in astprint_returncmd"))
    end
end

function astprint_procarglist(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_procarglist(0) < 100
    return join([astprint_procarg(i) for i in a.child], ",")
end

function astprint_procarg(a::AstNode, env::AstEnv, indent::Int)::String
    @assert 0 < a.rule - @RULE_procarg(0) < 100
    if a.rule == @RULE_procarg(1)
        return a.child[1] * " " * astprint_extendedid(a.child[2], env, 0)
    elseif @RULE_procarg(2) <= a.rule <= @RULE_procarg(5)
        return cmd_to_builtin_type_string[a.child[1]] * " " * astprint_extendedid(a.child[2], env, 0)
    elseif a.rule == @RULE_procarg(6)
        return "proc " * astprint_extendedid(a.child[2], env, 0)
    elseif a.rule == @RULE_procarg(7)
        return astprint_extendedid(a.child[2], env, 0)
    else
        throw(TranspileError("internal error in astprint_procarg"))
    end
end

function astprint_pretty(a::AstNode, env::AstEnv)
    if 100 < a.rule < 200
        return astprint_top_lines(a, env, 0)
    elseif 200 < a.rule < 300
        return astprint_top_pprompt(a, env, 0)
    elseif 300 < a.rule < 400
        return astprint_lines(a, env, 0)
    elseif 400 < a.rule < 500
        return astprint_pprompt(a, env, 0)
    elseif 500 < a.rule < 600
        return astprint_npprompt(a, env, 0)
    elseif 600 < a.rule < 700
        return astprint_flowctrl(a, env, 0)
    elseif 700 < a.rule < 800
        return astprint_example_dummy(a, env, 0)
    elseif 800 < a.rule < 900
        return astprint_command(a, env, 0)
    elseif 900 < a.rule < 1000
        return astprint_assign(a, env, 0)
    elseif 1000 < a.rule < 1100
        return astprint_elemexpr(a, env, 0)
    elseif 1100 < a.rule < 1200
        return astprint_exprlist(a, env, 0)
    elseif 1200 < a.rule < 1300
        return astprint_expr(a, env, 0)
    elseif 1300 < a.rule < 1400
        return astprint_quote_start(a, env, 0)
    elseif 1400 < a.rule < 1500
        return astprint_assume_start(a, env, 0)
    elseif 1500 < a.rule < 1600
        return astprint_quote_end(a, env, 0)
    elseif 1600 < a.rule < 1700
        return astprint_expr_arithmetic(a, env, 0)
    elseif 1700 < a.rule < 1800
        return astprint_left_value(a, env, 0)
    elseif 1800 < a.rule < 1900
        return astprint_extendedid(a, env, 0)
    elseif 1900 < a.rule < 2000
        return astprint_declare_ip_variable(a, env, 0)
    elseif 2000 < a.rule < 2100
        return astprint_stringexpr(a, env, 0)
    elseif 2100 < a.rule < 2200
        return astprint_rlist(a, env, 0)
    elseif 2200 < a.rule < 2300
        return astprint_ordername(a, env, 0)
    elseif 2300 < a.rule < 2400
        return astprint_orderelem(a, env, 0)
    elseif 2400 < a.rule < 2500
        return astprint_OrderingList(a, env, 0)
    elseif 2500 < a.rule < 2600
        return astprint_ordering(a, env, 0)
    elseif 2600 < a.rule < 2700
        return astprint_mat_cmd(a, env, 0)
    elseif 2700 < a.rule < 2800
        return astprint_filecmd(a, env, 0)
    elseif 2800 < a.rule < 2900
        return astprint_helpcmd(a, env, 0)
    elseif 2900 < a.rule < 3000
        return astprint_examplecmd(a, env, 0)
    elseif 3000 < a.rule < 3100
        return astprint_exportcmd(a, env, 0)
    elseif 3100 < a.rule < 3200
        return astprint_killcmd(a, env, 0)
    elseif 3200 < a.rule < 3300
        return astprint_listcmd(a, env, 0)
    elseif 3300 < a.rule < 3400
        return astprint_ringcmd1(a, env, 0)
    elseif 3400 < a.rule < 3500
        return astprint_ringcmd(a, env, 0)
    elseif 3500 < a.rule < 3600
        return astprint_scriptcmd(a, env, 0)
    elseif 3600 < a.rule < 3700
        return astprint_setrings(a, env, 0)
    elseif 3700 < a.rule < 3800
        return astprint_setringcmd(a, env, 0)
    elseif 3800 < a.rule < 3900
        return astprint_typecmd(a, env, 0)
    elseif 3900 < a.rule < 4000
        return astprint_ifcmd(a, env, 0)
    elseif 4000 < a.rule < 4100
        return astprint_whilecmd(a, env, 0)
    elseif 4100 < a.rule < 4200
        return astprint_forcmd(a, env, 0)
    elseif 4200 < a.rule < 4300
        return astprint_proccmd(a, env, 0)
    elseif 4300 < a.rule < 4400
        return astprint_parametercmd(a, env, 0)
    elseif 4400 < a.rule < 4500
        return astprint_returncmd(a, env, 0)
    elseif 4500 < a.rule < 4600
        return astprint_procarglist(a, env, 0)
    elseif 4600 < a.rule < 4700
        return astprint_procarg(a, env, 0)
    else
        return "???????????"
    end
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

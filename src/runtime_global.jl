
function reset_runtime()
    rtGlobal.optimize_locals = true
    rtGlobal.last_printed = rtnothing
    rtGlobal.rtimer_base = time_ns()
    rtGlobal.rtimer_scale = 1000000000
    rtGlobal.Kstd1_deg = 0
    rtGlobal.Kstd1_mu = 32000
    rtGlobal.si_echo = 0
    rtGlobal.colmax = 80
    rtGlobal.printlevel = 0
    rtGlobal.traceit = 0
    rtGlobal.si_opt_1 = 0x00000000
    rtGlobal.si_opt_2 = 0x00002851
    rtGlobal.vars = Dict(:Top => Dict{Symbol, Any}())
    rtGlobal.callstack = rtCallStackEntry[rtCallStackEntry(1, 1, rtInvalidRing, :Top)]
    rtGlobal.local_vars = Pair{Symbol, Any}[]
    rtGlobal.newstruct_casts = Dict{String, Function}()
    sync_begin()
end

function rt_basering()
    return rtGlobal.callstack[end].current_ring
end

function sync_begin(a = rt_basering())
    libSingular.rChangeCurrRing(a.value)
    libSingular.set_si_opt_1(rtGlobal.si_opt_1)
    libSingular.set_si_opt_2(rtGlobal.si_opt_2)
    libSingular.set_Kstd1_deg(rtGlobal.Kstd1_deg)
    libSingular.set_Kstd1_mu(rtGlobal.Kstd1_mu)
end

function sync_end()
    rtGlobal.si_opt_1 = libSingular.get_si_opt_1()
    rtGlobal.si_opt_2 = libSingular.get_si_opt_2()
    rtGlobal.Kstd1_deg = libSingular.get_Kstd1_deg()
    rtGlobal.Kstd1_mu = libSingular.get_Kstd1_mu()
    rChangeCurrRing(C_NULL)
end

function rt_option_string()
    r = String["//options:"]
    if rtGlobal.si_opt_1 != 0 || rtGlobal.si_opt_2 != 0
        tmp = rtGlobal.si_opt_1
        for i in test_options
            if (tmp & i.second) != 0
                push!(r, i.first)
                tmp &= ~i.second
            end
        end
        for i in 0:31
            if (tmp & (UInt32(1) << i)) != 0
                push!(r, string(i))
            end
        end
        tmp = rtGlobal.si_opt_2
        for i in verbose_options
            if (tmp & i.second) != 0
                push!(r, i.first)
                tmp &= ~i.second
            end
        end
        for i in 1:31
            if (tmp & (UInt32(1) << i)) != 0
                push!(r, string(i + 32))
            end
        end
    else
        push!(r, "none")
    end
    return Sstring(join(r, " "))
end

function rt_option_set(s::String)
    nos = (length(s) > 2 && s[1:2] == "no") ? s[3:end] : ""
    if s == "none"
        rtGlobal.si_opt_1 = 0
        rtGlobal.si_opt_2 = 0
    else
        for i in test_options
            if s == i.first
                if (i.second & valid_test_options) != 0
                    rtGlobal.si_opt_1 |= i.second
                    if i.second == OPT_OLDSTD_MASK
                        rtGlobal.si_opt_1 &= ~OPT_REDTHROUGH_MASK
                    end
                else
                    rt_warn("cannot set option")
                end
                return rtnothing
            elseif nos == i.first
                if (i.second & valid_test_options) != 0
                    rtGlobal.si_opt_1 &= ~i.second
                else
                    rt_warn("cannot set option")
                end
                return rtnothing
            end
        end
        for i in verbose_options
            if s == i.first
                rtGlobal.si_opt_2 |= i.second
                return rtnothing
            elseif nos == i.first
                rtGlobal.si_opt_2 &= ~i.second
                return rtnothing
            end
        end
        rt_error("unknown option `$(s)`")
    end
    return rtnothing
end

function rt_option_getvec()
    return Sintvec(Int[rtGlobal.si_opt_1 % Int, rtGlobal.si_opt_2 % Int])
end

function rt_option_setvec(a::Sintvec)
    @error_check(length(a.value) == 2, "option vector must have length 2")
    rtGlobal.si_opt_1 = a.value[1] % UInt32
    rtGlobal.si_opt_2 = a.value[2] % UInt32
    return rtnothing
end

function rt_set_current_ring(a::Sring)
    # call the user an idiot if changing basering would create a name conflict
    vars_in_both = intersect(Set(keys(rtGlobal.vars[:Top])), Set(keys(a.vars)))
    if !isempty(vars_in_both)
        rt_error("new basering shadows the global variable(s) " *
                 join(map(string, collect(vars_in_both)), ", ")  *
                 " from Top")
        return
    end
    n = length(rtGlobal.callstack)
    if n > 1
        # rearrange the local variables, who cares how fast it is
        new_hidden_vars = Pair{Symbol, Any}[]
        new_current_vars = Pair{Symbol, Any}[]
        vars = rtGlobal.local_vars
        for i in rtGlobal.callstack[n].start_all_locals:length(rtGlobal.local_vars)
            hidden = false
            value = vars[i].second
            if isa(value, Slist)
                @assert value.back === nothing
                p = value.parent
                if p.valid && !(p === a)
                    hidden = true
                end
            elseif isa(value, SingularRingType)
                p = value.parent
                @assert p.valid
                if !(p === a)
                    hidden = true
                end
            end
            if hidden
               push!(new_hidden_vars, vars[i])
            else
               push!(new_current_vars, vars[i])
            end
        end
        local_vars_in_both = Symbol[]
        s = Set{Symbol}()
        for i in new_current_vars
            if in(i.first, s)
                push!(local_vars_in_both, i.first)
            else
                push!(s, i.first)
            end
        end
        if !isempty(local_vars_in_both)
            rt_error("new basering shadows the local variable(s) " *
                     join(map(string, local_vars_in_both), ", "))
            return
        end
        # locals are good to go
        rtGlobal.callstack[n].start_current_locals =
               rtGlobal.callstack[n].start_all_locals + length(new_hidden_vars)
        resize!(rtGlobal.local_vars, rtGlobal.callstack[n].start_all_locals - 1)
        append!(rtGlobal.local_vars, new_hidden_vars)
        append!(rtGlobal.local_vars, new_current_vars)
        # also check the current package like :Top above
        pack = rtGlobal.callstack[n].current_package
        vars_in_both = intersect(Set(keys(rtGlobal.vars[pack])), Set(keys(a.vars)))
        if !isempty(vars_in_both)
            rt_error("new basering shadows the global variable(s) " *
                     join(map(string, collect(vars_in_both)), ", ")  *
                     " from " * string(pack))
            return
        end
    end
    rtGlobal.callstack[n].current_ring = a
    # we are only using libSingular here to see what Singular would do to our global options
    # no sync_begin as neither of us have the true state
    libSingular.set_si_opt_1(rtGlobal.si_opt_1)
    libSingular.rChangeCurrRing(a.value)
    sync_end()
end


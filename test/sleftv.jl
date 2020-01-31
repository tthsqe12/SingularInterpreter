using SingularInterpreter: execute

@testset "check errors handling in Singular" begin
    # NOTE: must be updated to always use operations handled by the sleftv
    # mechanism, i.e. here: `"a"[1]` which succeeds, and  `string` == `int`
    # which fails
    @test nothing === execute(""" "a"[1] == "a" """)
    @test_throws ErrorException execute(""" "a"[1] == 1 """)
    @test nothing === execute(""" "a"[1] == "a" """)
end

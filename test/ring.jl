using SingularInterpreter: rt_make_ring, rt_set_current_ring, rtvar, makeunknown,
      SPoly, STuple

@testset "ring" begin
    R = rt_make_ring(0, makeunknown("x"), [["dp"]])
    rt_set_current_ring(R)
    @test rtvar(1) isa SPoly
    @test_throws ErrorException rtvar(0)
    @test_throws ErrorException rtvar(2)
    @test_throws ErrorException rtvar(STuple(Any[1, 4]))
end

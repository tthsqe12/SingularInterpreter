@testset "resolution" begin
    @test_throws ErrorException SingularInterpreter.execute("ring r; resolution r = list(1, 2);")
end

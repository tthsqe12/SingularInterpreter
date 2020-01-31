@testset "number" begin
    # no ring was declared:
    @test_throws ErrorException SingularInterpreter.execute("number n;")
end

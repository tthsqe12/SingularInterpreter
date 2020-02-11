@testset "number" begin
    # no ring was declared:
    @test_throws ErrorException SingularInterpreter.execute("number n;")
    @test_throws ErrorException SingularInterpreter.execute("number(123);")
end

@testset "bigint" begin
    @test_throws ErrorException SingularInterpreter.execute("ring r = (0,a),x,lp; bigint(number(0));")
    @test_throws ErrorException SingularInterpreter.execute("ring s; bigint(x);")
end

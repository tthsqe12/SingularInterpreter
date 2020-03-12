@testset "bigint" begin
    @test_throws ErrorException SingularInterpreter.execute("ring r = (0,a),x,lp; bigint(number(0));")
    @test_throws ErrorException SingularInterpreter.execute("ring s; bigint(x);")
    @test_throws ErrorException SingularInterpreter.execute("bigint(1+x);") # still uses `ring s`
end

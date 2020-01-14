@testset "int" begin
    @test rtequalequal(rtnot(0), 1) == 1
    @test_throws ErrorException rtnot(big(1))
    @test_throws ErrorException rtnot(SString("1"))
    @test_throws ErrorException rtand(big(1), 2)
    @test_throws ErrorException rtor(big(1), 2)
end

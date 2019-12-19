using Test

using SingularInterpreter: rtcolon, rtequalequal, rtnot, rtand, rtor, SIntVec, SString

@testset "int" begin
    @test rtequalequal(rtnot(0), 1) == 1
    @test_throws ErrorException rtnot(big(1))
    @test_throws ErrorException rtnot(SString("1"))
    @test_throws ErrorException rtand(big(1), 2)
    @test_throws ErrorException rtor(big(1), 2)
end

@testset "intvec" begin
    @test rtequalequal(rtcolon(1, 3), SIntVec([1, 1, 1])) == 1
    @test_throws ErrorException rtcolon(1, -1)
    @test_throws ErrorException rtcolon(BigInt(2), 2)
end

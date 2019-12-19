using Test

using SingularInterpreter: rtcolon, rtequalequal, rtnot, SIntVec, SString

@testset "int" begin
    @test rtequalequal(rtnot(0), 1) == 1
    @test_throws ErrorException rtnot(big(1))
    @test_throws ErrorException rtnot(SString("1"))
end

@testset "intvec" begin
    @test rtequalequal(rtcolon(1, 3), SIntVec([1, 1, 1])) == 1
    @test_throws ErrorException rtcolon(1, -1)
    @test_throws ErrorException rtcolon(BigInt(2), 2)
end

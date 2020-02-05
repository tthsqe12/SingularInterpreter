@testset "intvec" begin
    @test rtequalequal(rtcolon(1, 3), Sintvec([1, 1, 1])) == 1
    @test_throws ErrorException rtcolon(1, -1)
    @test_throws ErrorException rtcolon(BigInt(2), 2)
end

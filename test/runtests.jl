using Rolling
using Test

@testset "basics" begin
    moo_result = moo()
    @test moo_result == "hello"
    @test moo_result != "meow"
end
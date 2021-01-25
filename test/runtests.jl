using Rolling
using Test

@testset "WindowState" begin
    @testset "empty" begin
        for T in [Float64, Bool, Array{Float64, 1}]
            state = empty_state(T)
            @test state.data == T[]
            @test state.i == 0
        end
    end

    @testset "add_value!" begin
        for initial in [42, 42.0, true, [1, 2, 3]]
            state = empty_state(typeof(initial))
            @test state.i == 0
            add_value!(state, initial)
            @test state.data == [initial]
            @test state.i == 1
        end
    end
end
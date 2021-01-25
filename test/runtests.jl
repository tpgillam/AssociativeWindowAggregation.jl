using Rolling
using Test

@testset "FixedWindowState" begin
    @testset "empty" begin
        for T in [Float64, Bool, Array{Float64, 1}]
            state = FixedWindowState{T}(5)
            @test state.data == T[]
            @test state.i == 0
        end
    end

    @testset "push!" begin
        for initial in [42, 42.0, true, [1, 2, 3]]
            state = FixedWindowState{typeof(initial)}(5)
            @test state.i == 0
            push!(state, initial)
            @test state.data == [initial]
            @test state.i == 1
        end
    end
end
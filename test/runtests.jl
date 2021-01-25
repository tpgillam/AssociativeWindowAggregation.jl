using Rolling
using Test

@testset "FixedWindowState" begin
    @testset "empty" begin
        for T in [Float64, Bool, Array{Float64, 1}]
            for capacity in [1, 2, 3]
                state = FixedWindowState{T}(capacity)
                @test state.data == T[]
                @test state.i == 0
                @test state.capacity == capacity
            end
        end
    end

    @testset "push!" begin
        for initial in [42, 42.0, true, [1, 2, 3]]
            state = FixedWindowState{typeof(initial)}(5)
            @test state.i == 0
            push!(state, initial)
            @test state.data == [initial]
            @test state.i == 1
            @test state.capacity == 5

            push!(state, initial, initial)
            @test state.data == [initial, initial, initial]
            @test state.i == 3
            @test state.capacity == 5
        end
    end

end
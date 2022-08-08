@testset "WindowedAssociativeOp" begin
    @testset "empty" begin
        for T in [Float64, Bool, Array{Float64,1}]
            for op in [+, -, *]
                state = WindowedAssociativeOp{T,op}()
                @test state.previous_cumsum == T[]
                @test state.ri_previous_cumsum == 0
                @test state.values == T[]
            end
        end
    end

    @testset "simple" begin
        state = WindowedAssociativeOp{Int64,+}()
        @test window_size(state) == 0

        push!(state, 1)
        @test window_size(state) == 1
        @test window_value(state) == 1

        push!(state, 2)
        push!(state, 3, 4)
        @test window_size(state) == 4
        @test window_value(state) == 10

        popfirst!(state)
        @test window_size(state) == 3
        @test window_value(state) == 9

        popfirst!(state, 2)
        @test window_size(state) == 1
        @test window_value(state) == 4
        @test_throws ArgumentError popfirst!(state, 2)
        @test window_size(state) == 1
        @test window_value(state) == 4

        popfirst!(state, 1)
        @test window_size(state) == 0
    end
end

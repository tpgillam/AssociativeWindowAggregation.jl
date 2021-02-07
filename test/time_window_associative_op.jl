@testset "TimeWindowAssociativeOp" begin
    @testset "trivial" begin
        T = Int64
        op = +
        window = 2
        state = TimeWindowAssociativeOp{T, typeof(window), typeof(window)}(op, window)

        @test update_state!(state, 0, 3) == state
        @test !window_full(state)
        @test window_size(state) == 1
        @test window_value(state) == 3

        @test update_state!(state, 1, 4) == state
        @test !window_full(state)
        @test window_size(state) == window
        @test window_value(state) == 7

        @test update_state!(state, 2, 4) == state
        @test window_full(state)
        @test window_size(state) == window
        @test window_value(state) == 8

        @test update_state!(state, 3, -5) == state
        @test window_full(state)
        @test window_size(state) == window
        @test window_value(state) == -1
    end
end

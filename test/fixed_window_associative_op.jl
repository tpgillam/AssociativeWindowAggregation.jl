function test_fixed_window(values, op; approximate_equality::Bool=false)
    T = typeof(first(values))
    @test_throws ArgumentError FixedWindowAssociativeOp{T,op}(0)

    for window in 1:2 * length(values)
        state = FixedWindowAssociativeOp{T,op}(window)
        for (i, value) in enumerate(values)
            @test update_state!(state, value) == state

            received = window_value(state)
            # This is the expected range of the input values over which we are reducing.
            i_start = max(1, i - window + 1)
            i_stop = i
            expected = reduce(op, values[i_start:i_stop])
            if approximate_equality
                @test received ≈ expected
            else
                @test received == expected
            end

            if i < window
                @test !window_full(state)
                @test window_size(state) == i
            else
                @test window_full(state)
                @test window_size(state) == window
            end
        end
    end
end

@testset "FixedWindowAssociativeOp" begin
    @testset "trivial" begin
        T = Int64
        op = +
        window = 2
        state = FixedWindowAssociativeOp{T,op}(window)

        @test update_state!(state, 3) == state
        @test !window_full(state)
        @test window_size(state) == 1
        @test window_value(state) == 3

        @test update_state!(state, 4) == state
        @test window_full(state)
        @test window_size(state) == window
        @test window_value(state) == 7

        @test update_state!(state, 4) == state
        @test window_full(state)
        @test window_size(state) == window
        @test window_value(state) == 8

        @test update_state!(state, -5) == state
        @test window_full(state)
        @test window_size(state) == window
        @test window_value(state) == -1
    end

    @testset "integral" begin
        for op in (+, *, max, min)
            test_fixed_window(1:20, op)
        end
    end

    @testset "random float" begin
        values = rand(20)
        for op in (+, *, max, min)
            test_fixed_window(values, op; approximate_equality=true)
        end
    end

    @testset "random matrix multiply" begin
        # This isn't commutative.
        values = [rand(-5:5, (2, 2)) for _ in 1:20]
        test_fixed_window(values, *)
    end

    @testset "set union" begin
        values = [Set([x]) for x in 1:20]
        test_fixed_window(values, union)
    end
end

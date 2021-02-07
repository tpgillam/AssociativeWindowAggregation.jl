function test_time_window(times, values, windows, op; approximate_equality::Bool=false)
    # Work out what types we should be using for times and values
    Value = typeof(first(values))
    Time = typeof(first(times))
    TimeDiff = typeof(first(windows))

    for window in windows
        state = TimeWindowAssociativeOp{Value,Time,TimeDiff}(op, window)
        for (i, (time, value)) in enumerate(zip(times, values))
            @test update_state!(state, time, value) == state

            received = window_value(state)
            # This is the expected range of the input values over which we are reducing.
            i_start = searchsortedlast(times, time - window) + 1
            i_stop = i
            @test window_size(state) == i_stop - i_start + 1
            expected = reduce(op, values[i_start:i_stop])
            if approximate_equality
                @test received ≈ expected
            else
                @test received == expected
            end

            @test window_full(state) == (first(times) <= time - window)
        end
    end
end

@testset "TimeWindowAssociativeOp" begin
    @testset "trivial" begin
        T = Int64
        op = +
        window = 2
        state = TimeWindowAssociativeOp{T,typeof(window),typeof(window)}(op, window)

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

    @testset "integral" begin
        for op in (+, *, max, min)
            test_time_window(1:20, 1:20, 1:20, op)
            test_time_window(
                [Dates.DateTime(2000, 1, x) for x in 1:20],
                1:20,
                [Dates.Day(x) for x in 1:30],
                op
            )
        end
    end

    # TODO: more tests
    # TODO test that we raise an exception on out-of-order times
end

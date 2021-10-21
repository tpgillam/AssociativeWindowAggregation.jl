function test_time_window(
    times, values, windows, op; op_bang=nothing, approximate_equality::Bool=false
)
    # Work out what types we should be using for times and values
    Value = typeof(first(values))
    Time = typeof(first(times))

    for window in windows
        state = if isnothing(op_bang)
            TimeWindowAssociativeOp{Value,op,Time}(window)
        else
            TimeWindowAssociativeOp{Value,op,op_bang,Time}(window)
        end
        for (i, (time, value)) in enumerate(zip(times, values))
            @test update_state!(state, time, value) == state

            # Passing the same time in twice is illegal, since it is not monotonically
            # increasing.
            @test_throws ArgumentError update_state!(state, time, value)

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
        state = TimeWindowAssociativeOp{T,op,typeof(window)}(window)

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

    @testset "incompatible time type" begin
        # Time is of type Int64, but window is given as a Float64 -> this should throw.
        @test_throws ArgumentError TimeWindowAssociativeOp{Float64,+,Int64}(10.0)
    end

    @testset "integral" begin
        for op in (+, *, max, min)
            test_time_window(1:20, 1:20, 1:20, op)
            test_time_window(
                [Dates.DateTime(2000, 1, x) for x in 1:20],
                1:20,
                [Dates.Day(x) for x in 1:30],
                op,
            )
        end
    end

    @testset "random matrix multiply" begin
        times = [DateTime(2000, 1, x) for x in 1:20]
        values = [rand(-5:5, (2, 2)) for _ in 1:20]
        windows = [Dates.Day(x) for x in 1:30]
        test_time_window(times, values, windows, *)
    end

    @testset "mutating" begin
        times = [DateTime(2000, 1, x) for x in 1:20]
        values = [Data(1, rand(-5:5, (2, 2))) for _ in 1:20]
        windows = [Dates.Day(x) for x in 1:30]
        test_time_window(times, values, windows, merge)
        test_time_window(times, values, windows, merge; op_bang=merge!)
    end
end

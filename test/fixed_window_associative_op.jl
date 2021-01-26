
function test_fixed_window(values, op; approximate_equality::Bool=false)
    T = typeof(first(values))
    for emit_early in [true, false]
        @test_throws ArgumentError FixedWindowAssociativeOp{T}(op, 0; emit_early=emit_early)

        for window in 1:2 * length(values)
            state = FixedWindowAssociativeOp{T}(op, window; emit_early=emit_early)
            for (i, value) in enumerate(values)
                received = update_state!(state, value)
                if !emit_early && i < window
                    @test isnothing(received)
                else
                    # This is the expected range of the input values over which we are
                    # reducing.
                    i_start = max(1, i - window + 1)
                    i_stop = i
                    expected = reduce(op, values[i_start:i_stop])
                    if approximate_equality
                        @test received ≈ expected
                    else
                        @test received == expected
                    end
                end
            end
        end
    end
end

@testset "FixedWindowAssociativeOp" begin
    @testset "trivial" begin
        T = Int64
        op = +
        window = 2
        state = FixedWindowAssociativeOp{T}(op, window)
        @test isnothing(update_state!(state, 3))
        @test update_state!(state, 4) == 7
        @test update_state!(state, 4) == 8
        @test update_state!(state, -5) == -1
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

    @testset "set union" begin
        values = [Set([x]) for x in 1:20]
        test_fixed_window(values, union)
    end
end

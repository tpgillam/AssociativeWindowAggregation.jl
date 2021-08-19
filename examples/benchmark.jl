using AssociativeWindowAggregation
using BenchmarkTools

function run_example(window::Integer, num_points::Integer)
    state = FixedWindowAssociativeOp{Int,+}(window)
    for _ in 1:num_points
        update_state!(state, 1)
    end
    return window_value(state)
end

@benchmark run_example(100, 10000)

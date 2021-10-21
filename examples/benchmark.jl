using AssociativeWindowAggregation
using BenchmarkTools
using RollingFunctions

function run_example(window::Integer, data::Vector{Int})
    state = FixedWindowAssociativeOp{Int,+}(window)
    result = Vector{Int}(undef, length(data) - (window - 1))
    i = 1
    for x in data
        update_state!(state, x)  # Do work
        window_full(state) || continue  # Only record numbers when the window is full
        @inbounds result[i] = window_value(state)  # Extract mean
        i += 1
    end
    return result
end

run_rolling(window::Integer, data::Vector{Int}) = rolling(sum, data, window)

data = rand(-100:100, 100000)
window = 200

@assert run_example(window, data) == run_rolling(window, data)

@benchmark run_example(window, data)
@benchmark run_rolling(window, data)

# Observations on an M1 MacBook Air, running Julia 1.6.2:
#
# Currently this package is faster for windows >= 20, but is slower for smaller windows.
# This is because we have better complexity [O(1) vs O(n) for RollingFunctions], however we
# incur some additional overhead that results in worse constant factors.

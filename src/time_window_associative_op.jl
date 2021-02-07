using DataStructures: Deque

# TODO: Need to add checks / declare undefined behaviour if times provided to update_state!
#   are not strictly increasing.

"""
    TimeWindowAssociativeOp{Value, Time, TimeDiff}

State necessary for accumulation over a rolling window of fixed size, in terms of time.

# Fields
- `window_state::WindowedAssociativeOp{Value}`: The underlying general-window state.
- `window::TimeDiff`: The window, as a difference between two times.
- `times::Deque{Time}`: The same length as the values stored in `window_state`, and
    representing the times of those observations.
- `window_full::Bool`: For internal use - will be set to true once a point has dropped out
    of the window.
"""
mutable struct TimeWindowAssociativeOp{Value,Time,TimeDiff}
    window_state::WindowedAssociativeOp{Value}
    window::TimeDiff
    times::Deque{Time}
    window_full::Bool
end

function TimeWindowAssociativeOp{Value,Time,TimeDiff}(
    op::Function,
    window::TimeDiff
) where {Value,Time,TimeDiff}
    if window <= zero(TimeDiff)
        throw(ArgumentError("Got window $window, but it must be positive."))
    end
    return TimeWindowAssociativeOp{Value,Time,TimeDiff}(
        WindowedAssociativeOp{Value}(op),
        window,
        Deque{Time}(),
        false
    )
end

function update_state!(
    state::TimeWindowAssociativeOp{Value,Time,TimeDiff},
    time,
    value
)::TimeWindowAssociativeOp{Value,Time,TimeDiff} where {Value,Time,TimeDiff}
    push!(state.times, time)

    # Drop off times from the front of the deque, keeping track of how many values we need
    # to remove from the window state.
    # This is a linear search
    num_dropped_from_window = 0
    while first(state.times) <= time - state.window
        popfirst!(state.times)
        num_dropped_from_window += 1
    end

    update_state!(state.window_state, value, num_dropped_from_window)

    if !state.window_full && num_dropped_from_window > 0
        # The window has now filled; record this for use in `window_full` below.
        state.window_full = true
    end

    return state
end

window_value(state::TimeWindowAssociativeOp) = window_value(state.window_state)
window_size(state::TimeWindowAssociativeOp)::Int = window_size(state.window_state)

"""
    window_full(state::TimeWindowAssociativeOp)::Bool

# Returns:
- `Bool`: true iff the given `state` has had at least one value drop out of the window,
    indicating that the window is now full.
"""
window_full(state::TimeWindowAssociativeOp)::Bool = state.window_full

using DataStructures: Deque

"""
    TimeWindowAssociativeOp{Value, Time, TimeDiff}

State necessary for accumulation over a rolling window of fixed size, in terms of time.

When presented with a new time t', we guarantee that all times t remaining in the window
satisfy:

    t > t' - w

That is, at time t' this window represents the open-closed time interval (t' - w, t']

# Fields
- `window_state::WindowedAssociativeOp{Value}`: The underlying general-window state.
- `window::TimeDiff`: The window, as a difference between two times.
- `times::Deque{Time}`: The same length as the values stored in `window_state`, and
    representing the times of those observations.
- `window_full::Bool`: For internal use - will be set to true once a point has dropped out
    of the window.
"""
mutable struct TimeWindowAssociativeOp{Value,Op,Time,TimeDiff}
    window_state::WindowedAssociativeOp{Value,Op}
    window::TimeDiff
    times::Deque{Time}
    window_full::Bool

    function TimeWindowAssociativeOp{Value,Op,Time,TimeDiff}(
        window::TimeDiff
    ) where {Value,Op,Time,TimeDiff}
        if window <= zero(TimeDiff)
            throw(ArgumentError("Got window $window, but it must be positive."))
        end
        return new(WindowedAssociativeOp{Value,Op}(), window, Deque{Time}(), false)
    end
end

"""
    update_state!(
        state::TimeWindowAssociativeOp{Value,Time,TimeDiff},
        time,
        value
    )::TimeWindowAssociativeOp{Value,Time,TimeDiff} where {Value,Time,TimeDiff}

Add the specified `value` to the state with associated `time`, and drop any values that
are no longer in the time window.

# Arguments
- `state::TimeWindowAssociativeOp{Value,Time,TimeDiff}`:
- `time`: The time to which `value` corresponds.
- `value`: The value to add to the window.

# Returns
- `::TimeWindowAssociativeOp{Value,Time,TimeDiff}`: `state`, which has been mutated.
"""
function update_state!(state::TimeWindowAssociativeOp, time, value)
    if !isempty(state.times) && time <= last(state.times)
        throw(
            ArgumentError(
                "Got out-of-order time $time. Previous time was $(last(state.times))"
            ),
        )
    end

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

Returns true iff the given `state` has had at least one value drop out of the window,
indicating that the window is now full.
"""
window_full(state::TimeWindowAssociativeOp)::Bool = state.window_full

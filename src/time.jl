using DataStructures: Deque

"""
    TimeWindowAssociativeOp{Value,Op,Op!,Time}(window::TimeDiff)
    TimeWindowAssociativeOp{Value,Op,Time}(window::TimeDiff)

State necessary for accumulation over a rolling window of fixed size, in terms of time.

When presented with a new time t', we guarantee that all times t remaining in the window
satisfy:

    t > t' - w

That is, at time t' this window represents the open-closed time interval (t' - w, t']

We require that `window` be of a type that, when added to a `Time`, gives a `Time`.

# Fields
- `window_state::WindowedAssociativeOp{Value}`: The underlying general-window state.
- `window::TimeDiff`: The window, as a difference between two times.
- `times::Deque{Time}`: The same length as the values stored in `window_state`, and
    representing the times of those observations.
- `window_full::Bool`: For internal use - will be set to true once a point has dropped out
    of the window.
"""
mutable struct TimeWindowAssociativeOp{Value,Op,Op!,Time,TimeDiff}
    window_state::WindowedAssociativeOp{Value,Op,Op!}
    window::TimeDiff
    times::Deque{Time}
    window_full::Bool

    function TimeWindowAssociativeOp{Value,Op,Op!,Time}(
        window::TimeDiff
    ) where {Value,Op,Op!,Time,TimeDiff}
        # Verify that TimeDiff and Time are compatible.
        ret_types = Base.return_types(+, (Time, TimeDiff))
        isempty(ret_types) && throw(ArgumentError("Incompatible: $Time and $TimeDiff"))
        only(ret_types) == Time || throw(ArgumentError("Incompatible: $Time and $TimeDiff"))

        if window <= zero(TimeDiff)
            throw(ArgumentError("Got window $window, but it must be positive."))
        end
        return new{Value,Op,Op!,Time,TimeDiff}(
            WindowedAssociativeOp{Value,Op,Op!}(), window, Deque{Time}(), false
        )
    end
end

function TimeWindowAssociativeOp{T,Op,Time}(window) where {T,Op,Time}
    return TimeWindowAssociativeOp{T,Op,Op,Time}(window)
end

"""
    update_state!(state::TimeWindowAssociativeOp, time, value) -> state

Add the specified `value` to the state with associated `time`, and drop any values that
are no longer in the time window.

# Arguments
- `state::TimeWindowAssociativeOp`:
- `time`: The time to which `value` corresponds.
- `value`: The value to add to the window.

# Returns
- `::TimeWindowAssociativeOp`: `state`, which has been mutated.
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
    while (first(state.times) + state.window) <= time
        popfirst!(state.times)
        num_dropped_from_window += 1
    end

    @inbounds popfirst!(state.window_state, num_dropped_from_window)
    push!(state.window_state, value)

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

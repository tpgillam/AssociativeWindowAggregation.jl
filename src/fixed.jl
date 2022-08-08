using DataStructures: CircularBuffer

"""
    FixedWindowAssociativeOp{T,Op,Op!}(window)
    FixedWindowAssociativeOp{T,Op}(window)

State necessary for accumulation over a rolling window of fixed size.

# Fields
- `window_state::WindowedAssociativeOp{T,Op}`: The underlying general-window state.
- `remaining_window::Int`: How much of the window remains to be filled. Initially this will
    be set to the window size, and will then reduce for every value added until it reaches
    zero.
"""
mutable struct FixedWindowAssociativeOp{T,Op,Op!}
    window_state::WindowedAssociativeOp{T,Op,Op!,CircularBuffer{T}}
    remaining_window::Int

    function FixedWindowAssociativeOp{T,Op,Op!}(window::Integer) where {T,Op,Op!}
        window < 1 && throw(ArgumentError("Got window $window, but it must be positive."))
        window_state = WindowedAssociativeOp{T,Op,Op!,CircularBuffer{T}}(
            CircularBuffer{T}(window - 1), CircularBuffer{T}(window)
        )
        return new(window_state, window)
    end
end

function FixedWindowAssociativeOp{T,Op}(window) where {T,Op}
    return FixedWindowAssociativeOp{T,Op,Op}(window)
end

"""
    update_state!(state::FixedWindowAssociativeOp, value) -> state

Add the specified `value` to the `state`. Drop a value from the window iff the window is
full.

# Returns
- `::FixedWindowAssociativeOp`: The instance `state` that was passed in.
"""
function update_state!(state::FixedWindowAssociativeOp, value)
    num_dropped_from_window = if state.remaining_window > 0
        state.remaining_window -= 1
        0
    else
        1
    end

    # With @inbounds, we assert that num_dropped_from_window will never exceed the size of
    # the window.
    @inbounds popfirst!(state.window_state, num_dropped_from_window)
    push!(state.window_state, value)
    return state
end

window_value(state::FixedWindowAssociativeOp) = window_value(state.window_state)
window_size(state::FixedWindowAssociativeOp)::Int = window_size(state.window_state)

"""
    window_full(state::FixedWindowAssociativeOp)::Bool

Returns true iff the given `state` has a full window.
"""
window_full(state::FixedWindowAssociativeOp)::Bool = state.remaining_window == 0

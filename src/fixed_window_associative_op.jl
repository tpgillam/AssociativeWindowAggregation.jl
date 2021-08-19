"""
    FixedWindowAssociativeOp{T,Op}

State necessary for accumulation over a rolling window of fixed size.

# Fields
- `window_state::WindowedAssociativeOp{T,Op}`: The underlying general-window state.
- `remaining_window::Int`: How much of the window remains to be filled. Initially this will
    be set to the window size, and will then reduce for every value added until it reaches
    zero.
"""
mutable struct FixedWindowAssociativeOp{T,Op}
    window_state::WindowedAssociativeOp{T,Op}
    remaining_window::Int

    """
        FixedWindowAssociativeOp{T,Op}

    Construct a new empty instance of `FixedWindowAssociativeOp`.

    # Arguments
    - `window::Integer`: The fixed window size.
    """
    function FixedWindowAssociativeOp{T,Op}(window::Integer) where {T,Op}
        if window < 1
            throw(ArgumentError("Got window $window, but it must be positive."))
        end
        return new(WindowedAssociativeOp{T,Op}(), window)
    end
end

"""
    update_state!(state::FixedWindowAssociativeOp, value)

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

    update_state!(state.window_state, value, num_dropped_from_window)
    return state
end

window_value(state::FixedWindowAssociativeOp) = window_value(state.window_state)
window_size(state::FixedWindowAssociativeOp)::Int = window_size(state.window_state)

"""
    window_full(state::FixedWindowAssociativeOp)::Bool

Returns true iff the given `state` has a full window.
"""
window_full(state::FixedWindowAssociativeOp)::Bool = state.remaining_window == 0

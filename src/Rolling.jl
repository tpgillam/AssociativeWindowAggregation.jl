module Rolling

export FixedWindowAssociativeOp, WindowedAssociativeOpState
export update_state!, window_full, window_size, window_value

"""
    WindowedAssociativeOpState{T}

State associated with a windowed aggregation of a binary associative operator,
in a numerically accurate fashion.

Wherever summation is discussed, we can consider any alternative binary, associative,
operator. For example: `+, *, max, min, &&, union`

NB. It is interesting to observe that commutativity is *not* required by this algorithm,
which is one of the reasons that it enjoys stable numerical performance.

Conceptually the window is maintained in two buffers:

        [---- A ---)[----- B ------)
            <                      >    <-- current window finishes at the end of B, and
                                            starts somewhere in A.

`A` is stored as a sequence of cumulative sums, such that as the "<" advances we merely pick
out the correct element:

        x_i,   x_i-1 + x_i,  x_i-2 + x_i-1 + x_i

`B` is stored as both:
- The sequence of values seen:  `x_i+1,  x_i+2,  x_i+3,  ...`
- The total of that sequence:  `x_i+1 + x_i+2 + x_i+3 + ...`

When the "<" advances from `A` to `B`, we discard `A`, and the subset of `B` remaining after
`<` becomes the new `A`. In becoming `A`, we transform its representation into that of the
cumulative sums. We create a new, empty, `B`.

`O(1)` amortized runtime complexity, and `O(L)` space complexity, where `L` is the typical
window length.

# Fields
- `op::Function`: Any binary, associative, function.
- `previous_cumsum::Array{T, 1}`: Corresponds to array `A` above.
- `ri_previous_cumsum::Int`: A reverse index into `previous_cumsum`, once it contains
    values. It should be subtracted from `end` in order to obtain the appropriate index.
- `values::Array{T, 1}`: Corresponds to array `B` above.
- `sum::Union{Nothing, T}`: The sum of the elements in values.
"""
mutable struct WindowedAssociativeOpState{T}
    op::Function
    previous_cumsum::Array{T,1}
    ri_previous_cumsum::Int
    values::Array{T,1}
    sum::Union{Nothing,T}
end

"""
    WindowedAssociativeOpState{T}

Create a new, empty, instance of WindowedAssociativeOpState.

# Arguments
- `op::Function`: Any binary, associative, function.

# Returns
- `WindowedAssociativeOpState{T}`: An empty instance.
"""
function WindowedAssociativeOpState{T}(op::Function) where T
    return WindowedAssociativeOpState(op, T[], 0, T[], nothing)
end

"""
    update_state!(
        state::WindowedAssociativeOpState{T},
        value,
        num_dropped_from_window::Integer
    )::T where T

Add the specified value to the state, drop some number of elements from the start of the
window, and return the aggregated quantity.

# Arguments
- `state::WindowedAssociativeOpState{T}`: The state to update (will be mutated).
- `value`: The value to add to the end of the window - must be convertible to a `T`.
- `num_dropped_from_window::Integer`: The number of elements to remove from the front of
    the window.

# Returns
- `::WindowedAssociativeOpState{T}`: The instance `state` that was passed in.
"""
function update_state!(
    state::WindowedAssociativeOpState{T},
    value,
    num_dropped_from_window::Integer
)::WindowedAssociativeOpState{T} where T
    # Our index into previous_cumsum is advanced by the number of values we drop from the
    # window.
    state.ri_previous_cumsum += num_dropped_from_window

    # If this has taken us out-of-range of the _previous_cumsum values, we must recompute
    # them.
    elements_remaining = length(state.previous_cumsum) - (state.ri_previous_cumsum + 1)

    if elements_remaining < 0
        # We have overshot the end of previous_cumsum.

        # We may also need to discard elements from values. This could happen if
        # num_dropped_from_window > 1.
        num_values_to_remove = - elements_remaining - 1
        if num_values_to_remove > length(state.values)
            throw(ArgumentError(
                "num_dropped_from_window = $num_dropped_from_window is out of range"
            ))
        end

        # TODO: Is there a copy here that we could avoid?
        trimmed_reversed_values = state.values[end:-1:1 + num_values_to_remove]

        # We now generate the partial sum, and set our index back to zero. values is also
        # emptied, since its information is now reflected in previous_cumsum.
        # NOTE: We need to take care here in the case of non-commutation. In accumulate, we
        # will be getting:
        #
        #    (x0, op(x0, x1), op(op(x0, x1), x2), ...)
        #
        # but we actually want:
        #
        #    (x0, op(x1, x0), op(x2, op(x1, x0)), ...)
        state.previous_cumsum = accumulate(
            (x, y) -> state.op(y, x),
            trimmed_reversed_values
        )
        state.ri_previous_cumsum = 0
        state.values = T[]
        # state.sum is now garbage, but we are not going to use it before we recompute it.
    end

    # Include the new value in sum and values.
    state.sum = length(state.values) == 0 ? value : state.op(state.sum, value)
    push!(state.values, value)

    return state
end


"""
    window_value(state::WindowedAssociativeOpState{T})::T where T

Get the value currently represented by the state.

# Arguments:
- `state::WindowedAssociativeOpState{T}`: The state to query.

# Returns:
- `T`: The result of aggregating over the values in the window.
"""
function window_value(state::WindowedAssociativeOpState{T})::T where T
    if length(state.previous_cumsum) == 0
        # The A buffer is empty, so we need only worry about the 'B' buffer.
        return state.sum
    else
        # Include contributions both from A and B buffers.
        # Remember that we are indexing from the back.
        index = length(state.previous_cumsum) - state.ri_previous_cumsum
        return state.op(state.previous_cumsum[index], state.sum)
    end
end

"""
    function window_size(state::WindowedAssociativeOpState{T})::Int where T

Get the current size of the window in `state`.

# Arguments:
- `state::WindowedAssociativeOpState{T}`: The state to query.

# Returns:
- `Int`: The current size of the window.
"""
function window_size(state::WindowedAssociativeOpState{T})::Int where T
    if length(state.previous_cumsum) == 0
        # The A buffer is empty, so we need only worry about the 'B' buffer.
        return length(state.values)
    else
        # Include contributions both from A and B buffers.
        # Remember that we are indexing from the back.
        index = length(state.previous_cumsum) - state.ri_previous_cumsum
        return length(state.values) + index
    end
end

"""
    FixedWindowAssociativeOp{T}

State necessary for accumulation over a rolling window of fixed size.

# Fields
- `window_state::WindowedAssociativeOpState{T}`: The underlying general-window state.
- `remaining_window::Int`: How much of the window remains to be filled. Initially this will
    be set to the window size, and will then reduce for every value added until it reaches
    zero.
"""
mutable struct FixedWindowAssociativeOp{T}
    window_state::WindowedAssociativeOpState{T}
    remaining_window::Int
end

"""
    FixedWindowAssociativeOp{T}

Construct a new empty instance of `FixedWindowAssociativeOp`.

# Arguments
- `op::Function`: Any binary, associative, function.
- `window::Integer`: The fixed window size.
"""
function FixedWindowAssociativeOp{T}(op::Function, window::Integer) where T
    if window < 1
        throw(ArgumentError("Got window $window, but it must be positive."))
    end
    return FixedWindowAssociativeOp{T}(WindowedAssociativeOpState{T}(op), window)
end

"""
    update_state!(
        state::FixedWindowAssociativeOp{T},
        value
    )::Union{T, Nothing} where T

Add the specified `value` to the `state`. Drop a value from the window iff the window is
full.

# Returns
- `::FixedWindowAssociativeOp{T}`: The instance `state` that was passed in.
"""
function update_state!(
    state::FixedWindowAssociativeOp{T},
    value
)::FixedWindowAssociativeOp{T} where T
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

# Returns:
- `Bool`: true iff the given `state` has a full window.
"""
window_full(state::FixedWindowAssociativeOp)::Bool = state.remaining_window == 0


end # module

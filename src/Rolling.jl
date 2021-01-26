module Rolling

export FixedWindowAssociativeOp, WindowedAssociativeOpState, update_state!

# TODO improve docstring.
"""
    WindowedAssociativeOpState{T}

State associated with a windowed aggregation of a binary associative operator.

# Fields
- `value_count::Int`
- `op::Function`:  # (T, T) -> T
- `previous_cumsum::Array{T, 1}`
- `ri_previous_cumsum::Int`: A reverse index into previous_cumsum, once it contains values.
    It should be subtracted from `end` in order to obtain the appropriate index.
- `values::Array{T, 1}`
- `sum::Union{Nothing, T}`
"""
mutable struct WindowedAssociativeOpState{T}
    value_count::Int
    op::Function
    previous_cumsum::Array{T, 1}
    ri_previous_cumsum::Int
    values::Array{T, 1}
    sum::Union{Nothing, T}
end

function WindowedAssociativeOpState{T}(op::Function) where T
    return WindowedAssociativeOpState(0, op, T[], 0, T[], nothing)
end


# TODO docstring

function update_state!(
    state::WindowedAssociativeOpState{T},
    value,
    num_dropped_from_window::Integer
)::T where T
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

        # TODO Is there a copy here that we could avoid?
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

    if length(state.previous_cumsum) == 0
        # The A buffer is empty, so we need only worry about the 'B' buffer.
        state.value_count = length(state.values)
        return state.sum
    else
        # Include contributions both from A and B buffers.
        # Remember that we are indexing from the back.
        index = length(state.previous_cumsum) - state.ri_previous_cumsum
        state.value_count = length(state.values) + index
        return state.op(state.previous_cumsum[index], state.sum)
    end
end


mutable struct FixedWindowAssociativeOp{T}
    window_state::WindowedAssociativeOpState{T}
    remaining_window::Int
    emit_early::Bool
end

function FixedWindowAssociativeOp{T}(
    op::Function, window::Integer; emit_early::Bool=false
) where T
    if window < 1
        throw(ArgumentError("Got window $window, but it must be positive."))
    end
    return FixedWindowAssociativeOp{T}(
        WindowedAssociativeOpState{T}(op), window, emit_early
    )
end

function update_state!(
    state::FixedWindowAssociativeOp{T},
    value
)::Union{T, Nothing} where T
    num_dropped_from_window = if state.remaining_window > 0
        state.remaining_window -= 1
        0
    else
        1
    end

    result = update_state!(state.window_state, value, num_dropped_from_window)
    if state.emit_early || state.remaining_window == 0
        return result
    else
        return nothing
    end
end

end # module

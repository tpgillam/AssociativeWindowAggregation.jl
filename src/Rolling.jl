module Rolling

export FixedWindowState, push!

mutable struct FixedWindowState{T}
    data::Array{T, 1}
    i::Int64
    capacity::Int64
end

FixedWindowState{T}(capacity::Int64) where T = FixedWindowState(T[], 0, capacity)

function Base.push!(state::FixedWindowState{T}, value::T) where T
    push!(state.data, value)
    if state.i + 1 < state.capacity
        state.i += 1
    end
    return state
end

end # module

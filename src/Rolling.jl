module Rolling

export WindowState, add_value!, empty_state

mutable struct WindowState{T}
    data::Array{T, 1}
    i::Int64
end

empty_state(T::Type) = WindowState{T}(T[], 0)
# empty_state(value::T) = WindowState{T}([value], 1)

function add_value!(window_state::WindowState, value)
    push!(window_state.data, value)
    window_state.i += 1
end

end # module

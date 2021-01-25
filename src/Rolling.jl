module Rolling

export moo

struct WindowState{T, N}
    data::Array{T, N}
end

moo() = "hello"

end # module

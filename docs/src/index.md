# Rolling.jl Documentation

```@example mean
using Plots
using Rolling

x = range(1, 10; length=100)
y = sin.(x) + 0.5 * rand(length(x))

plot(x, y; label="raw", title="Rolling means")

for window in [5, 10, 20]
    state = FixedWindowAssociativeOp{Float64}(+, window; emit_early=false)

    z = []
    for value in y
        new_value = update_state!(state, value)
        if !isnothing(new_value)
            push!(z, new_value / window)
        else
            push!(z, NaN)
        end
    end

    plot!(x, z; label="mean $window", lw=2)
end
current()
```

```@autodocs
Modules = [Rolling]
```


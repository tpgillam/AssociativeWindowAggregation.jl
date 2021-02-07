# Rolling.jl

## Examples

```@example mean
using Plots
using Rolling

x = range(1, 10; length=100)
y = sin.(x) + 0.5 * rand(length(x))

plot(x, y; label="raw", title="Rolling means")

for window in [5, 10, 20]
    state = FixedWindowAssociativeOp{Float64}(+, window)

    z = []
    for value in y
        update_state!(state, value)
        if window_full(state)
            push!(z, window_value(state) / window)
        else
            push!(z, NaN)
        end
    end

    plot!(x, z; label="mean $window", lw=2)
end
current()
```

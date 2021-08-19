# Examples

## Rolling mean
Here we show a computation of the rolling mean over fixed windows. We use a 
`FixedWindowAssociativeOp` to keep track of a rolling sum, then divide by the window
length, only including values where the window has filled.

```@example mean
using AssociativeWindowAggregation
using Plots

x = range(1, 10; length=100)
y = sin.(x) + 0.5 * rand(length(x))

plot(x, y; label="raw", title="Rolling means")

for window in [5, 10, 20]
    # Use this to keep track of a windowed sum.
    state = FixedWindowAssociativeOp{Float64, +}(window)

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
savefig("mean-plot.svg"); nothing # hide
```

![](mean-plot.svg)

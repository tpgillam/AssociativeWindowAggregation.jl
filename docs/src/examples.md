# Examples

## Rolling mean
Here we show a computation of the rolling mean over fixed windows. We use a 
`FixedWindowAssociativeOp` to keep track of a rolling sum, then divide by the window
length, only including values where the window has filled.

```@example mean; continued=true
using AssociativeWindowAggregation
using Plots

x = range(1, 10; length=100)
y = sin.(x) + 0.5 * rand(length(x))

plot(x, y; label="raw", title="Rolling means")

for window in [5, 10, 20]
    # Use this to keep track of a windowed sum.
    state = FixedWindowAssociativeOp{Float64,+}(window)

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

If we were to be using very large windows, we should be nervous with the implementation
above due to potential loss of precision. Here is an example where we store a mean and a
count, which will be more numerically stable.

```@example mean
struct MeanValue
    n::Int64
    mean::Float64
end

"""
    merge(x::MeanValue, y::MeanValue) -> MeanValue

Combine two `MeanValue` objects into a new `MeanValue`.
"""
function merge(x::MeanValue, y::MeanValue)
    n = x.n + y.n
    return MeanValue(n, (x.n / n) * x.mean + (y.n / n) * y.mean)
end
MeanValue(x::Real) = MeanValue(1, x)

plot(x, y; label="raw", title="Rolling means")
for window in [5, 10, 20]
    # Use this to keep track of a windowed sum.
    state = FixedWindowAssociativeOp{MeanValue,merge}(window)

    z = []
    for value in y
        update_state!(state, MeanValue(value))
        if window_full(state)
            push!(z, window_value(state).mean)
        else
            push!(z, NaN)
        end
    end

    plot!(x, z; label="mean $window", lw=2)
end
savefig("mean-plot-2.svg"); nothing # hide
```

![](mean-plot-2.svg)
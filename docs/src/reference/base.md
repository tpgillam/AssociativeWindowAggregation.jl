# General window

A state to represent a window of arbitrarily variable capacity.

We push new values onto the window with [`Base.push!`](@ref).
We can remove old values from the window with [`Base.popfirst!`](@ref).

```@autodocs
Modules = [AssociativeWindowAggregation, Base]
Pages = ["base.jl"]
```
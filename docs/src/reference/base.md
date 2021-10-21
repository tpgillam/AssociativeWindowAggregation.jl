# General window

A state to represent a window of aribtrarily variable capacity.

Every time a new value is pushed onto the end of the window, we must specify how many values are removed from the front of the window.

```@autodocs
Modules = [AssociativeWindowAggregation]
Pages = ["base.jl"]
```
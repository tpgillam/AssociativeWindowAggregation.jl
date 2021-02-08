# Time window

A state to represent a window with fixed _time_ capacity.

Every value pushed onto the state has an associated time, and time is taken to be strictly increasing. 
The window is taken to be fixed in terms of time duration rather than a fixed number of values.

```@autodocs
Modules = [AssociativeWindowAggregation]
Pages = ["time_window_associative_op.jl"]
```
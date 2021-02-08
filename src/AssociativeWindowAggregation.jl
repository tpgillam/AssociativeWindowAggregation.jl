module AssociativeWindowAggregation

export FixedWindowAssociativeOp, TimeWindowAssociativeOp, WindowedAssociativeOp
export update_state!, window_full, window_size, window_value

include("windowed_associative_op.jl")
include("fixed_window_associative_op.jl")
include("time_window_associative_op.jl")

end # module

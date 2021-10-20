module AssociativeWindowAggregation

export FixedWindowAssociativeOp, TimeWindowAssociativeOp, WindowedAssociativeOp
export update_state!, window_full, window_size, window_value

include("base.jl")
include("fixed.jl")
include("time.jl")

end # module

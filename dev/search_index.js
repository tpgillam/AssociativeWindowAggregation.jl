var documenterSearchIndex = {"docs":
[{"location":"reference/windowed_associative_op.html","page":"General window","title":"General window","text":"Modules = [Rolling]\nPages = [\"windowed_associative_op.jl\"]","category":"page"},{"location":"reference/windowed_associative_op.html#Rolling.WindowedAssociativeOp","page":"General window","title":"Rolling.WindowedAssociativeOp","text":"WindowedAssociativeOp{T}\n\nState associated with a windowed aggregation of a binary associative operator, in a numerically accurate fashion.\n\nWherever summation is discussed, we can consider any alternative binary, associative, operator. For example: +, *, max, min, &&, union\n\nNB. It is interesting to observe that commutativity is not required by this algorithm, which is one of the reasons that it enjoys stable numerical performance.\n\nConceptually the window is maintained in two buffers:\n\n    [---- A ---)[----- B ------)\n        <                      >    <-- current window finishes at the end of B, and\n                                        starts somewhere in A.\n\nA is stored as a sequence of cumulative sums, such that as the \"<\" advances we merely pick out the correct element:\n\n    x_i,   x_i-1 + x_i,  x_i-2 + x_i-1 + x_i\n\nB is stored as both:\n\nThe sequence of values seen:  x_i+1,  x_i+2,  x_i+3,  ...\nThe total of that sequence:  x_i+1 + x_i+2 + x_i+3 + ...\n\nWhen the \"<\" advances from A to B, we discard A, and the subset of B remaining after < becomes the new A. In becoming A, we transform its representation into that of the cumulative sums. We create a new, empty, B.\n\nO(1) amortized runtime complexity, and O(L) space complexity, where L is the typical window length.\n\nFields\n\nop::Function: Any binary, associative, function.\nprevious_cumsum::Array{T, 1}: Corresponds to array A above.\nri_previous_cumsum::Int: A reverse index into previous_cumsum, once it contains   values. It should be subtracted from end in order to obtain the appropriate index.\nvalues::Array{T, 1}: Corresponds to array B above.\nsum::Union{Nothing, T}: The sum of the elements in values.\n\n\n\n\n\n","category":"type"},{"location":"reference/windowed_associative_op.html#Rolling.WindowedAssociativeOp-Union{Tuple{Function}, Tuple{T}} where T","page":"General window","title":"Rolling.WindowedAssociativeOp","text":"WindowedAssociativeOp{T}\n\nCreate a new, empty, instance of WindowedAssociativeOp.\n\nArguments\n\nop::Function: Any binary, associative, function.\n\nReturns\n\nWindowedAssociativeOp{T}: An empty instance.\n\n\n\n\n\n","category":"method"},{"location":"reference/windowed_associative_op.html#Rolling.update_state!-Union{Tuple{T}, Tuple{WindowedAssociativeOp{T},Any,Integer}} where T","page":"General window","title":"Rolling.update_state!","text":"update_state!(\n    state::WindowedAssociativeOp{T},\n    value,\n    num_dropped_from_window::Integer\n)::WindowedAssociativeOp{T} where T\n\nAdd the specified value to the state, drop some number of elements from the start of the window, and return the aggregated quantity.\n\nArguments\n\nstate::WindowedAssociativeOp{T}: The state to update (will be mutated).\nvalue: The value to add to the end of the window - must be convertible to a T.\nnum_dropped_from_window::Integer: The number of elements to remove from the front of   the window.\n\nReturns\n\n::WindowedAssociativeOp{T}: The instance state that was passed in.\n\n\n\n\n\n","category":"method"},{"location":"reference/windowed_associative_op.html#Rolling.window_size-Union{Tuple{WindowedAssociativeOp{T}}, Tuple{T}} where T","page":"General window","title":"Rolling.window_size","text":"function window_size(state::WindowedAssociativeOp{T})::Int where T\n\nGet the current size of the window in state.\n\nArguments:\n\nstate::WindowedAssociativeOp{T}: The state to query.\n\nReturns:\n\nInt: The current size of the window.\n\n\n\n\n\n","category":"method"},{"location":"reference/windowed_associative_op.html#Rolling.window_value-Union{Tuple{WindowedAssociativeOp{T}}, Tuple{T}} where T","page":"General window","title":"Rolling.window_value","text":"window_value(state::WindowedAssociativeOp{T})::T where T\n\nGet the value currently represented by the state.\n\nArguments:\n\nstate::WindowedAssociativeOp{T}: The state to query.\n\nReturns:\n\nT: The result of aggregating over the values in the window.\n\n\n\n\n\n","category":"method"},{"location":"reference/fixed_window_associative_op.html","page":"Fixed window","title":"Fixed window","text":"Modules = [Rolling]\nPages = [\"fixed_window_associative_op.jl\"]","category":"page"},{"location":"reference/fixed_window_associative_op.html#Rolling.FixedWindowAssociativeOp","page":"Fixed window","title":"Rolling.FixedWindowAssociativeOp","text":"FixedWindowAssociativeOp{T}\n\nState necessary for accumulation over a rolling window of fixed size.\n\nFields\n\nwindow_state::WindowedAssociativeOp{T}: The underlying general-window state.\nremaining_window::Int: How much of the window remains to be filled. Initially this will   be set to the window size, and will then reduce for every value added until it reaches   zero.\n\n\n\n\n\n","category":"type"},{"location":"reference/fixed_window_associative_op.html#Rolling.FixedWindowAssociativeOp-Union{Tuple{T}, Tuple{Function,Integer}} where T","page":"Fixed window","title":"Rolling.FixedWindowAssociativeOp","text":"FixedWindowAssociativeOp{T}\n\nConstruct a new empty instance of FixedWindowAssociativeOp.\n\nArguments\n\nop::Function: Any binary, associative, function.\nwindow::Integer: The fixed window size.\n\n\n\n\n\n","category":"method"},{"location":"reference/fixed_window_associative_op.html#Rolling.update_state!-Union{Tuple{T}, Tuple{FixedWindowAssociativeOp{T},Any}} where T","page":"Fixed window","title":"Rolling.update_state!","text":"update_state!(\n    state::FixedWindowAssociativeOp{T},\n    value\n)::FixedWindowAssociativeOp{T} where T\n\nAdd the specified value to the state. Drop a value from the window iff the window is full.\n\nReturns\n\n::FixedWindowAssociativeOp{T}: The instance state that was passed in.\n\n\n\n\n\n","category":"method"},{"location":"reference/fixed_window_associative_op.html#Rolling.window_full-Tuple{FixedWindowAssociativeOp}","page":"Fixed window","title":"Rolling.window_full","text":"window_full(state::FixedWindowAssociativeOp)::Bool\n\nReturns:\n\nBool: true iff the given state has a full window.\n\n\n\n\n\n","category":"method"},{"location":"reference/time_window_associative_op.html","page":"Time window","title":"Time window","text":"Modules = [Rolling]\nPages = [\"time_window_associative_op.jl\"]","category":"page"},{"location":"reference/time_window_associative_op.html#Rolling.TimeWindowAssociativeOp","page":"Time window","title":"Rolling.TimeWindowAssociativeOp","text":"TimeWindowAssociativeOp{Value, Time, TimeDiff}\n\nState necessary for accumulation over a rolling window of fixed size, in terms of time.\n\nFields\n\nwindow_state::WindowedAssociativeOp{Value}: The underlying general-window state.\nwindow::TimeDiff: The window, as a difference between two times.\ntimes::Deque{Time}: The same length as the values stored in window_state, and   representing the times of those observations.\nwindow_full::Bool: For internal use - will be set to true once a point has dropped out   of the window.\n\n\n\n\n\n","category":"type"},{"location":"reference/time_window_associative_op.html#Rolling.window_full-Tuple{TimeWindowAssociativeOp}","page":"Time window","title":"Rolling.window_full","text":"window_full(state::TimeWindowAssociativeOp)::Bool\n\nReturns:\n\nBool: true iff the given state has had at least one value drop out of the window,   indicating that the window is now full.\n\n\n\n\n\n","category":"method"},{"location":"index.html#Rolling.jl","page":"Home","title":"Rolling.jl","text":"","category":"section"},{"location":"index.html#Examples","page":"Home","title":"Examples","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"using Plots\nusing Rolling\n\nx = range(1, 10; length=100)\ny = sin.(x) + 0.5 * rand(length(x))\n\nplot(x, y; label=\"raw\", title=\"Rolling means\")\n\nfor window in [5, 10, 20]\n    state = FixedWindowAssociativeOp{Float64}(+, window)\n\n    z = []\n    for value in y\n        update_state!(state, value)\n        if window_full(state)\n            push!(z, window_value(state) / window)\n        else\n            push!(z, NaN)\n        end\n    end\n\n    plot!(x, z; label=\"mean $window\", lw=2)\nend\ncurrent()","category":"page"}]
}

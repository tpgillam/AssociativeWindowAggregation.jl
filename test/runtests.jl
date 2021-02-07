using Rolling
using Test

@testset "Rolling" begin
    # FIXME:
    # include("windowed_associative_op.jl")
    # include("fixed_window_associative_op.jl")
    include("time_window_associative_op.jl")
end

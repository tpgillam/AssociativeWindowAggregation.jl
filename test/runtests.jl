using Dates
using AssociativeWindowAggregation
using Test

@testset "AssociativeWindowAggregation" begin
    include("base.jl")
    include("fixed.jl")
    include("time.jl")
end

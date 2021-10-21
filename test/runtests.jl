using Dates
using AssociativeWindowAggregation
using Test

# Mutable object for use in tests involving mutating combination.
mutable struct Data
    count::Int
    value::Matrix{Float64}
end

Base.:(==)(x::Data, y::Data) = x.count == y.count && x.value == y.value

function merge(x::Data, y::Data)
    return Data(x.count + y.count, x.value * y.value)
end

function merge!(x::Data, y::Data)
    x.count += y.count
    x.value *= y.value
    return x
end

@testset "AssociativeWindowAggregation" begin
    include("base.jl")
    include("fixed.jl")
    include("time.jl")
end

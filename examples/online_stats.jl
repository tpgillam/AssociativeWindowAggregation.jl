using AssociativeWindowAggregation
using OnlineStatsBase
using Plots
using Statistics

struct WindowedStat{Stat} <: OnlineStat{Stat}
    state::FixedWindowAssociativeOp{Stat,merge,merge!}

    function WindowedStat{Stat}(window::Int) where {Stat<:OnlineStat}
        return new{Stat}(FixedWindowAssociativeOp{Stat,merge,merge!}(window))
    end
end

function OnlineStatsBase.fit!(x::WindowedStat{Stat}, v) where {Stat}
    # Create a single-observation instance of the statistic.
    wrapped = Stat()
    fit!(wrapped, v)
    update_state!(x.state, wrapped)
    return x
end

OnlineStatsBase.value(x::WindowedStat) = window_value(x.state)
OnlineStatsBase.nobs(x::WindowedStat) = window_size(x.state)

function Base.show(io::IO, o::WindowedStat{Stat}) where {Stat}
    nobs(o) == 0 && return print(io, "WindowStat{$Stat}()")
    return invoke(show, Tuple{IO,OnlineStat}, io, o)
end

x = WindowedStat{Variance}(100)
values = rand(1000) .- 0.5
output = [std(value(fit!(x, v))) for v in values]

begin
    plot(values; alpha=0.4, label="Input")
    plot!(output; label="std (window=100)")
end

using Documenter, AssociativeWindowAggregation

# This is inspired by the following, to prevent a `gksqt` process blocking (and needing
# manual termination) for every plot when generating documentation on MacOS.
# https://discourse.julialang.org/t/deactivate-plot-display-to-avoid-need-for-x-server/19359/2
# Another choice could be "100":
# https://discourse.julialang.org/t/generation-of-documentation-fails-qt-qpa-xcb-could-not-connect-to-display/60988
# Empirically, both choices seem to work.
withenv("GKSwstype" => "nul") do
    makedocs(
        format=Documenter.HTML(
            prettyurls=get(ENV, "CI", "false") == "true"
        ),
        modules=[AssociativeWindowAggregation],
        sitename="AssociativeWindowAggregation.jl",
        pages=[
            "Home" => "index.md",
            "examples.md",
            "Reference" => [
                "General window" => "reference/base.md",
                "Fixed window" => "reference/fixed.md",
                "Time window" => "reference/time.md",
            ]
        ]
    )
end

deploydocs(
    repo="github.com/tpgillam/AssociativeWindowAggregation.jl.git",
    devbranch="main"
)

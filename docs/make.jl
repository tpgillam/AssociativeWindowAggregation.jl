using Documenter, AssociativeWindowAggregation

makedocs(
    format=Documenter.HTML(prettyurls=false),
    modules=[AssociativeWindowAggregation],
    sitename="AssociativeWindowAggregation.jl",
    pages=[
        "Home" => "index.md",
        "examples.md",
        "Reference" => [
            "General window" => "reference/windowed_associative_op.md",
            "Fixed window" => "reference/fixed_window_associative_op.md",
            "Time window" => "reference/time_window_associative_op.md",
        ]
    ]
)

deploydocs(
    repo="github.com/tpgillam/AssociativeWindowAggregation.jl.git",
    devbranch="main"
)

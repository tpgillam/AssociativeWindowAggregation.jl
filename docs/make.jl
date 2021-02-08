using Documenter, Rolling

makedocs(
    format=Documenter.HTML(prettyurls=false),
    modules=[Rolling],
    sitename="Rolling.jl",
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
    repo="github.com/tpgillam/Rolling.jl.git",
    devbranch="main"
)

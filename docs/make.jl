using Documenter, Rolling

makedocs(
    modules=[Rolling],
    sitename="Rolling.jl"
)

deploydocs(
    repo="github.com/tpgillam/Rolling.jl.git",
    devbranch="main"
)

using Documenter, Rolling

makedocs(sitename="Rolling.jl")
deploydocs(
    repo="github.com/tpgillam/Rolling.jl.git",
    devbranch = "main"
)

using PiecewiseLinearFunctions
using Documenter
using Literate

DocMeta.setdocmeta!(
    PiecewiseLinearFunctions,
    :DocTestSetup,
    :(using PiecewiseLinearFunctions);
    recursive=true,
)

tuto_jl_file = joinpath(@__DIR__, "src", "literate", "index.jl")
tuto_md_dir = joinpath(@__DIR__, "src")
Literate.markdown(tuto_jl_file, tuto_md_dir; documenter=true, execute=false)

makedocs(;
    modules=[PiecewiseLinearFunctions],
    authors="BatyLeo and contributors",
    sitename="PiecewiseLinearFunctions.jl",
    format=Documenter.HTML(;
        canonical="https://BatyLeo.github.io/PiecewiseLinearFunctions.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md", "API" => "api.md"],
)

rm(joinpath(@__DIR__, "src", "index.md"))

deploydocs(; repo="github.com/BatyLeo/PiecewiseLinearFunctions.jl", devbranch="main")

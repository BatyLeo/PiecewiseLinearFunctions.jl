using PiecewiseLinearFunctions
using Documenter

DocMeta.setdocmeta!(PiecewiseLinearFunctions, :DocTestSetup, :(using PiecewiseLinearFunctions); recursive=true)

makedocs(;
    modules=[PiecewiseLinearFunctions],
    authors="BatyLeo and contributors",
    sitename="PiecewiseLinearFunctions.jl",
    format=Documenter.HTML(;
        canonical="https://BatyLeo.github.io/PiecewiseLinearFunctions.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/BatyLeo/PiecewiseLinearFunctions.jl",
    devbranch="main",
)

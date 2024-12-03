var documenterSearchIndex = {"docs":
[{"location":"api/","page":"API","title":"API","text":"CurrentModule = PiecewiseLinearFunctions","category":"page"},{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/","page":"API","title":"API","text":"Modules = [PiecewiseLinearFunctions]","category":"page"},{"location":"api/#PiecewiseLinearFunctions.PiecewiseLinearFunction","page":"API","title":"PiecewiseLinearFunctions.PiecewiseLinearFunction","text":"struct PiecewiseLinearFunction{T<:AbstractFloat}\n\nFields\n\nx::Vector{T} where T<:AbstractFloat: x coordinates of the breakpoints\ny::Vector{T} where T<:AbstractFloat: y coordinates of the breakpoints\nleft_slope::AbstractFloat: slope of the function to the left of the first breakpoint\nright_slope::AbstractFloat: slope of the function to the right of the last breakpoint\n\n\n\n\n\n","category":"type"},{"location":"api/#PiecewiseLinearFunctions.PiecewiseLinearFunction-Tuple{Any}","page":"API","title":"PiecewiseLinearFunctions.PiecewiseLinearFunction","text":"Evaluate the piecewise linear function f at x.\n\n\n\n\n\n","category":"method"},{"location":"api/#PiecewiseLinearFunctions.compose-Union{Tuple{T}, Tuple{PiecewiseLinearFunction{T}, PiecewiseLinearFunction{T}}} where T","page":"API","title":"PiecewiseLinearFunctions.compose","text":"compose(\n    f::PiecewiseLinearFunction{T},\n    g::PiecewiseLinearFunction{T};\n    postprocess_breakpoints\n) -> PiecewiseLinearFunction\n\n\nCompute the composition f ∘ g of two piecewise linear functions. By default, the function removes redundant breakpoints in the output as a post processing step.\n\nThis method can also be called using Base.∘\n\n\n\n\n\n","category":"method"},{"location":"api/#PiecewiseLinearFunctions.compute_slopes-Tuple{PiecewiseLinearFunction}","page":"API","title":"PiecewiseLinearFunctions.compute_slopes","text":"compute_slopes(\n    f::PiecewiseLinearFunction\n) -> Vector{<:AbstractFloat}\n\n\nCompute all the slopes of the piecewise linear function, from left to right.\n\n\n\n\n\n","category":"method"},{"location":"api/#PiecewiseLinearFunctions.convex_meet-Union{Tuple{T}, Tuple{PiecewiseLinearFunction{T}, PiecewiseLinearFunction{T}}} where T","page":"API","title":"PiecewiseLinearFunctions.convex_meet","text":"convex_meet(\n    f::PiecewiseLinearFunction{T},\n    g::PiecewiseLinearFunction{T}\n) -> PiecewiseLinearFunction\n\n\nCompute the convex meet of two piecewise linear functions, i.e. the tightest convex lower bound. Both functions need to be convex.\n\n\n\n\n\n","category":"method"},{"location":"api/#PiecewiseLinearFunctions.is_convex-Tuple{PiecewiseLinearFunction}","page":"API","title":"PiecewiseLinearFunctions.is_convex","text":"is_convex(f::PiecewiseLinearFunction) -> Any\n\n\nCheck if a piecewise linear function is convex.\n\n\n\n\n\n","category":"method"},{"location":"api/#PiecewiseLinearFunctions.remove_redundant_breakpoints-Tuple{PiecewiseLinearFunction}","page":"API","title":"PiecewiseLinearFunctions.remove_redundant_breakpoints","text":"remove_redundant_breakpoints(\n    f::PiecewiseLinearFunction;\n    atol\n) -> PiecewiseLinearFunction\n\n\nReturn a new piecewise linear function with redundant breakpoints removed.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"EditURL = \"literate/index.jl\"","category":"page"},{"location":"#PiecewiseLinearFunctions.jl","page":"Home","title":"PiecewiseLinearFunctions.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"PiecewiseLinearFunctions.jl is a small package for creating and manipulating piecewise linear (continuous) functions","category":"page"},{"location":"","page":"Home","title":"Home","text":"One can instantiate a piecewise linear function by providing the x and y coordinates of the breakpoints, as well as the slopes of the function to the left of the first breakpoint and to the right of the last breakpoint.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PiecewiseLinearFunctions\nf = PiecewiseLinearFunction([0.0, 1.0, 2.0], [0.0, 2.0, 1.0], -1.0, 0.5)","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can visualize it with Plots:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Plots\ng = PiecewiseLinearFunction([0.0, 1.5, 2.1], [1.0, 3.0, 0.5], 1.0, 3.0)\nplot(f; label=\"f\")\nplot!(g; label=\"g\")","category":"page"},{"location":"#Basic-operations","page":"Home","title":"Basic operations","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We can perform basic operations on piecewise linear functions, such as addition, subtraction.","category":"page"},{"location":"","page":"Home","title":"Home","text":"plot(-f; label=\"-f\")\nplot!(f + g; label=\"f + g\")\nplot!(f - g; label=\"f - g\")\nplot!(2f - 3; label=\"2f - 3\")","category":"page"},{"location":"#Min-and-max","page":"Home","title":"Min and max","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Minimum and maximum operations are also supported.","category":"page"},{"location":"","page":"Home","title":"Home","text":"plot(min(f, g); label=\"min(f, g)\")\nplot!(max(f, g); label=\"max(f, g)\")","category":"page"},{"location":"#Composition","page":"Home","title":"Composition","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We can also compose piecewise linear functions.","category":"page"},{"location":"","page":"Home","title":"Home","text":"plot(f ∘ g; label=\"f ∘ g\")","category":"page"},{"location":"#Convexity","page":"Home","title":"Convexity","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We can check if a piecewise linear function is convex.","category":"page"},{"location":"","page":"Home","title":"Home","text":"is_convex(f)","category":"page"},{"location":"","page":"Home","title":"Home","text":"And compute the convex meet between two convex functions, i.e. the tightest convex lower bound.","category":"page"},{"location":"","page":"Home","title":"Home","text":"f = PiecewiseLinearFunction([-0.5, 0.0, 0.5], [0.5, 0.25, 0.5], -1.0, 1.0)\ng = PiecewiseLinearFunction([0.0, 0.5, 1.0], [0.5, 0.4, 0.5], -0.5, 2.0)","category":"page"},{"location":"","page":"Home","title":"Home","text":"is_convex(f), is_convex(g)","category":"page"},{"location":"","page":"Home","title":"Home","text":"h = convex_meet(f, g)\nplot(f; label=\"f\")\nplot!(g; label=\"g\")\nplot!(h; label=\"convex_meet(f, g)\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"This page was generated using Literate.jl.","category":"page"}]
}

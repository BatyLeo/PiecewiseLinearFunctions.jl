module PiecewiseLinearFunctionsPlotExt
using DocStringExtensions: TYPEDSIGNATURES
using PiecewiseLinearFunctions
using Plots

"""
$TYPEDSIGNATURES

Plot input `PiecewiseLinearFunction` `f` with an offset `δ` on the x-axis on both sides of the breakpoints.
"""
@recipe function Plots.plot(f::PiecewiseLinearFunction, δ=1.0)
    X = vcat(f.x[1] - δ, f.x, f.x[end] + δ)
    Y = f.(X)
    return X, Y
end
end

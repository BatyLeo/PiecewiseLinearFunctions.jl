module PiecewiseLinearFunctionsPlotExt
using DocStringExtensions: TYPEDSIGNATURES
using PiecewiseLinearFunctions
using Plots

"""
$TYPEDSIGNATURES

Plot input `PiecewiseLinearFunction` `f` with an offset `δ` on the x-axis on both sides of the breakpoints.
"""
@recipe function Plots.plot(f::PiecewiseLinearFunction, δ=1.0)
    x0 = f.x[1] - δ
    xinf = f.x[end] + δ
    X = vcat(x0, f.x, xinf)
    Y = vcat(f(x0), f.y, f(xinf))
    return X, Y
end
end

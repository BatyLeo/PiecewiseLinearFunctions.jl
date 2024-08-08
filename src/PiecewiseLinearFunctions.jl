module PiecewiseLinearFunctions

using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

"""
$TYPEDEF

# Fields
$TYPEDFIELDS
"""
struct PiecewiseLinearFunction{T<:Real}
    "x coordinates of the breakpoints"
    x::Vector{T}
    "y coordinates of the breakpoints"
    y::Vector{T}
    "slope of the function to the left of the first breakpoint"
    left_slope::T
    "slope of the function to the right of the last breakpoint"
    right_slope::T
end

function (f::PiecewiseLinearFunction)(x::Real)
    i = searchsortedlast(f.x, x)
    if i == 0
        return f.left_slope * (x - f.x[1]) + f.y[1]
    elseif i == length(f.x)
        return f.right_slope * (x - f.x[end]) + f.y[end]
    else
        return (f.y[i + 1] - f.y[i]) / (f.x[i + 1] - f.x[i]) * (x - f.x[i]) + f.y[i]
    end
end

function +(f₁::PiecewiseLinearFunction, f₂::PiecewiseLinearFunction)
    new_x = vcat(f₁.x, f₂.x)
    unique!(new_x)
    sort!(new_x)
    new_y = [f₁(x) + f₂(x) for x in new_x]
    return PiecewiseLinearFunction(
        new_x, new_y, f₁.left_slope + f₂.left_slope, f₁.right_slope + f₂.right_slope
    )
end

export PiecewiseLinearFunction

end

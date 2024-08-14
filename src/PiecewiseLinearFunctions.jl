module PiecewiseLinearFunctions

using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES

"""
$TYPEDEF

# Fields
$TYPEDFIELDS
"""
struct PiecewiseLinearFunction{T<:AbstractFloat}
    "x coordinates of the breakpoints"
    x::Vector{T}
    "y coordinates of the breakpoints"
    y::Vector{T}
    "slope of the function to the left of the first breakpoint"
    left_slope::T
    "slope of the function to the right of the last breakpoint"
    right_slope::T
end

function (f::PiecewiseLinearFunction)(x)
    i = searchsortedlast(f.x, x)
    if i == 0
        return f.left_slope * (x - f.x[1]) + f.y[1]
    elseif i == length(f.x)
        return f.right_slope * (x - f.x[end]) + f.y[end]
    else
        return (f.y[i + 1] - f.y[i]) / (f.x[i + 1] - f.x[i]) * (x - f.x[i]) + f.y[i]
    end
end

# Outputs breakpoints (x₁, y₁), (x₂, y₂) associated with interval index `i`.
function get_breakpoints(f::PiecewiseLinearFunction, i::Int)
    if i == 0
        return -Inf, -sign(f.left_slope) * Inf, f.x[1], f.y[1]
    elseif i == length(f.x)
        return f.x[end], f.y[end], Inf, sign(f.right_slope) * Inf
    end
    # else
    return f.x[i], f.y[i], f.x[i + 1], f.y[i + 1]
end

function compute_slope_and_intercept(f::PiecewiseLinearFunction{T}, i::Int) where {T}
    if i == 0
        x = f.x[1]
        y = f.y[1]
        α = y - f(x - one(T))
        β = y - α * x
        return α, β
    elseif i == length(f.x)
        x = f.x[end]
        y = f.y[end]
        α = f(x + one(T)) - y
        β = y - α * x
        return α, β
    end
    # else
    x₁, y₁, x₂, y₂ = get_breakpoints(f, i)
    α = (y₂ - y₁) / (x₂ - x₁)
    β = y₁ - α * x₁
    return α, β
end

function Base.:+(f₁::PiecewiseLinearFunction, f₂::PiecewiseLinearFunction)
    new_x = vcat(f₁.x, f₂.x)
    unique!(new_x)
    sort!(new_x)
    new_y = [f₁(x) + f₂(x) for x in new_x]
    return PiecewiseLinearFunction(
        new_x, new_y, f₁.left_slope + f₂.left_slope, f₁.right_slope + f₂.right_slope
    )
end

function Base.:+(f::PiecewiseLinearFunction, y::Real)
    return PiecewiseLinearFunction(copy(f.x), f.y .+ y, f.left_slope, f.right_slope)
end
Base.:+(y::Real, f::PiecewiseLinearFunction) = f + y
Base.:-(f::PiecewiseLinearFunction, y::Real) = f + (-y)
Base.:-(y::Real, f::PiecewiseLinearFunction) = y + (-f)

function Base.:-(f::PiecewiseLinearFunction)
    return PiecewiseLinearFunction(copy(f.x), -f.y, -f.left_slope, -f.right_slope)
end

function Base.:-(f₁::PiecewiseLinearFunction, f₂::PiecewiseLinearFunction)
    return f₁ + (-f₂)
end

function Base.:*(f::PiecewiseLinearFunction, y::Real)
    return PiecewiseLinearFunction(copy(f.x), f.y .* y, f.left_slope * y, f.right_slope * y)
end

function Base.:*(y::Real, f::PiecewiseLinearFunction)
    return f * y
end

function search_left_intersection(f1::PiecewiseLinearFunction, f2::PiecewiseLinearFunction)
    x = min(f1.x[1], f2.x[1])
    y1 = f1(x)
    y2 = f2(x)
    slope1 = f1.left_slope
    slope2 = f2.left_slope

    if slope1 == slope2 || y1 < y2 && slope1 > slope2 || y1 > y2 && slope1 < slope2
        return false, x
    end

    # else
    b1 = y1 - slope1 * x
    b2 = y2 - slope2 * x
    return true, (b2 - b1) / (slope1 - slope2)
end

function search_right_intersection(f1::PiecewiseLinearFunction, f2::PiecewiseLinearFunction)
    x = max(f1.x[end], f2.x[end])
    y1 = f1(x)
    y2 = f2(x)
    slope1 = f1.right_slope
    slope2 = f2.right_slope

    if slope1 == slope2 || y1 < y2 && slope1 < slope2 || y1 > y2 && slope1 > slope2
        return false, x
    end

    # else
    b1 = y1 - slope1 * x
    b2 = y2 - slope2 * x
    return true, (b2 - b1) / (slope1 - slope2)
end

# Search if `f1` and `f2` intersect inside the interval `]i1, i1 + 1[ ∩ ]i2, i2 + 1[`.
# Returns also the recommended increments for the breakpoints when computing min.
function search_intersection(
    f1::PiecewiseLinearFunction{T}, f2::PiecewiseLinearFunction{T}, i1::Int, i2::Int
) where {T}
    # Special case when we're on the leftmost or rightmost breakpoint for both intervals
    if i1 == 0 && i2 == 0
        new_i1, new_i2 = if f1.x[1] < f2.x[1]
            1, 0
        elseif f2.x[1] < f1.x[1]
            0, 1
        else
            1, 1
        end
        a, b = search_left_intersection(f1, f2)
        return a, b, new_i1, new_i2
    end
    if i1 == length(f1.x) && i2 == length(f2.x)
        new_i1, new_i2 = i1 + 1, i2 + 1
        a, b = search_right_intersection(f1, f2)
        return a, b, new_i1, new_i2
    end

    x11, y11, x12, y12 = get_breakpoints(f1, i1)
    x21, y21, x22, y22 = get_breakpoints(f2, i2)
    # Adjust if we're on a border
    if i1 == 0
        x11 = x21
        y11 = f1(x11)
    elseif i1 == length(f1.x)
        x12 = x22
        y12 = f1(x12)
    elseif i2 == 0
        x21 = x11
        y21 = f2(x21)
    elseif i2 == length(f2.x)
        x22 = x12
        y22 = f2(x22)
    end

    new_i1, new_i2 = if x12 < x22
        i1 + 1, i2
    elseif x22 < x12
        i1, i2 + 1
    else # x12 == x22
        i1 + 1, i2 + 1
    end

    new_i1 = min(new_i1, length(f1.x))
    new_i2 = min(new_i2, length(f2.x))

    if x12 <= x21 || x22 <= x11  # intervals are disjoint
        return false, zero(T), new_i1, new_i2
    end

    # Interval where the functions could intersect
    x1 = max(x11, x21)
    x2 = min(x12, x22)
    sign1 = sign(f1(x1) - f2(x1))
    sign2 = sign(f1(x2) - f2(x2))

    # If signs are both positive or both negative, there is no intersection
    if sign1 * sign2 == 1
        return false, zero(T), new_i1, new_i2
    end

    # Intersection at the leftmost point, therefore not inside the interval
    if sign1 == 0
        return false, x1, new_i1, new_i2
    end

    # else, there is an intersection inside the interval
    a1 = (y12 - y11) / (x12 - x11)
    b1 = y11 - a1 * x11
    a2 = (y22 - y21) / (x22 - x21)
    b2 = y21 - a2 * x21
    return true, (b2 - b1) / (a1 - a2), new_i1, new_i2
end

function Base.min(f₁::PiecewiseLinearFunction{T}, f₂::PiecewiseLinearFunction{T}) where {T}
    new_right_slope = min(f₁.right_slope, f₂.right_slope)
    new_left_slope = max(f₁.left_slope, f₂.left_slope)
    new_x = vcat(f₁.x, f₂.x)
    i₁_max, i₂_max = length(f₁.x) + 1, length(f₂.x) + 1
    i₁, i₂ = 0, 0
    while i₁ < i₁_max && i₂ < i₂_max
        intersect, x, i₁, i₂ = search_intersection(f₁, f₂, i₁, i₂)
        if intersect
            push!(new_x, x)
        end
    end
    unique!(new_x)
    sort!(new_x)
    new_y = T[min(f₁(x), f₂(x)) for x in new_x]
    return PiecewiseLinearFunction(new_x, new_y, new_left_slope, new_right_slope)
end

function Base.max(f₁::PiecewiseLinearFunction{T}, f₂::PiecewiseLinearFunction{T}) where {T}
    return -min(-f₁, -f₂)
end

function compose(f::PiecewiseLinearFunction{T}, g::PiecewiseLinearFunction{T}) where {T}
    new_x = T[]
    I = length(g.x)
    J = length(f.x)
    for i in 0:I
        for j in 0:J
            # First check if intervals intersect
            x₁, _, x₂, _ = get_breakpoints(g, i)
            y₁, _, y₂, _ = get_breakpoints(f, j)
            αg, βg = compute_slope_and_intercept(g, i)
            if αg == 0
                x, y = 1, -1
                if βg >= y₁ && βg <= y₂
                    x, y = x₁, x₂
                end
            else
                x, y = if αg > 0
                    (y₁ - βg) / αg, (y₂ - βg) / αg
                elseif αg < 0
                    (y₂ - βg) / αg, (y₁ - βg) / αg
                end
                x, y = max(x₁, x), min(x₂, y)
            end
            # @info x
            intersect = x <= y
            if intersect
                x > -Inf && push!(new_x, x)
                y < Inf && push!(new_x, y)
            end
        end
    end
    unique!(new_x)  # remove duplicates
    sort!(new_x)    # sort breakpoints
    new_y = [f(g(x)) for x in new_x]
    new_right_slope = f(g(new_x[end] + one(T))) - new_y[end]
    new_left_slope = new_y[1] - f(g(new_x[1] - one(T)))
    return PiecewiseLinearFunction(new_x, new_y, new_left_slope, new_right_slope)
end

function Base.:∘(f::PiecewiseLinearFunction, g::PiecewiseLinearFunction)
    return compose(f, g)
end

export PiecewiseLinearFunction

end

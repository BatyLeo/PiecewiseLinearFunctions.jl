module PiecewiseLinearFunctions

using DocStringExtensions: TYPEDEF, TYPEDFIELDS, TYPEDSIGNATURES
using RecipesBase: @recipe

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

"""
$TYPEDSIGNATURES

Evaluate the piecewise linear function `f` at `x`.
"""
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

@recipe function f(ff::PiecewiseLinearFunction)
    return x -> ff(x)
end

@recipe function f(ff::PiecewiseLinearFunction, xs)
    return x -> ff(x), xs
end

function Base.:(==)(
    f1::PiecewiseLinearFunction{T}, f2::PiecewiseLinearFunction{T}
) where {T}
    return f1.x == f2.x &&
           f1.y == f2.y &&
           f1.left_slope == f2.left_slope &&
           f1.right_slope == f2.right_slope
end

"""
$TYPEDSIGNATURES

Compute all the slopes of the piecewise linear function, from left to right.
"""
function compute_slopes(f::PiecewiseLinearFunction)
    slopes = fill(f.left_slope, length(f.x) + 1)
    for i in eachindex(f.x)
        if i == length(f.x)
            slopes[i + 1] = f.right_slope
        else
            slopes[i + 1] = (f.y[i + 1] - f.y[i]) / (f.x[i + 1] - f.x[i])
        end
    end
    return slopes
end

"""
$TYPEDSIGNATURES

Return a new piecewise linear function with redundant breakpoints removed.
"""
function remove_redundant_breakpoints(f::PiecewiseLinearFunction; atol=1e-12)
    slopes = compute_slopes(f)
    N = length(f.x)
    to_remove = falses(N)
    for i in 1:N
        if isapprox(slopes[i], slopes[i + 1]; atol)
            to_remove[i] = true
        end
        if isnan(slopes[i + 1])  # slope is NaN when x[i] == x[i + 1], duplicate break point
            to_remove[i] = true
        end
    end
    if isapprox(slopes[end - 1], slopes[end]; atol)
        to_remove[end] = true
    end
    if all(to_remove) # case where all breakpoints are redundant, keep only the first one
        return PiecewiseLinearFunction([f.x[1]], [f.y[1]], f.left_slope, f.right_slope)
    end
    return PiecewiseLinearFunction(
        f.x[.!to_remove], f.y[.!to_remove], f.left_slope, f.right_slope
    )
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
    end
    if i2 == 0
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

    # Intersection at the leftmost point, therefore not inside the intervals
    if sign1 == 0
        return false, x1, new_i1, new_i2
    end

    # Intersection at the rightmost point, therefore not inside the intervals
    if sign2 == 0
        return false, x2, new_i1, new_i2
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
    return remove_redundant_breakpoints(
        PiecewiseLinearFunction(new_x, new_y, new_left_slope, new_right_slope)
    )
end

function Base.max(f₁::PiecewiseLinearFunction{T}, f₂::PiecewiseLinearFunction{T}) where {T}
    return -min(-f₁, -f₂)
end

function old_compose(
    f::PiecewiseLinearFunction{T},
    g::PiecewiseLinearFunction{T};
    postprocess_breakpoints=true,
) where {T}
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
                else
                    @error "Unexpected slope" αg f g
                end
                x, y = max(x₁, x), min(x₂, y)
            end
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
    new_right_slope = if g.right_slope >= 0
        g.right_slope * f.right_slope
    else # g.right_slope < 0
        g.right_slope * f.left_slope
    end
    new_left_slope = if g.left_slope >= 0
        g.left_slope * f.left_slope
    else # g.left_slope < 0
        g.left_slope * f.right_slope
    end
    fcircg = PiecewiseLinearFunction(new_x, new_y, new_left_slope, new_right_slope)
    if postprocess_breakpoints
        return remove_redundant_breakpoints(fcircg)
    end
    return fcircg
end

function extract_segments(f::PiecewiseLinearFunction)
    n = length(f.y)

    segments = map(1:(n - 1)) do i
        x1, y1 = f.x[i], f.y[i]
        x2, y2 = f.x[i + 1], f.y[i + 1]
        a = (y2 - y1) / (x2 - x1)
        b = y1 - a * x1
        return min(y1, y2), max(y1, y2), a, b
    end
    push!(
        segments,
        (
            min(f.y[end], f.right_slope * Inf),
            max(f.y[end], f.right_slope * Inf),
            f.right_slope,
            f.y[end] - f.right_slope * f.x[end],
        ),
    )
    pushfirst!(
        segments,
        (
            min(f.y[1], f.left_slope * -Inf),
            max(f.y[1], f.left_slope * -Inf),
            f.left_slope,
            f.y[1] - f.left_slope * f.x[1],
        ),
    )
    return segments
end

"""
$TYPEDSIGNATURES

Compute the composition f ∘ g of two piecewise linear functions.
By default, the function checks for and removes redundant breakpoints in the output as a post processing step.
For faster computation, set `postprocess_breakpoints=false`.

This method can also be called using Base.∘
"""
function compose(
    f::PiecewiseLinearFunction, g::PiecewiseLinearFunction; postprocess_breakpoints=true
)
    # All breakpoinsts of g are breakpoints of f ∘ g
    new_x = copy(g.x)
    # For each breakpoint of f, check if they create new breakpoints in f ∘ g
    g_segments = extract_segments(g)
    for (y1, y2, a, b) in g_segments
        for x in f.x
            if x < y1 || x > y2
                continue
            end
            if a != 0.0
                xf = (x - b) / a
                push!(new_x, xf)
            end
        end
    end
    unique!(new_x)  # remove duplicates
    sort!(new_x)    # sort breakpoints
    new_y = [f(g(x)) for x in new_x]

    # Compute the slopes of the new function
    new_right_slope = if g.right_slope >= 0
        g.right_slope * f.right_slope
    else # g.right_slope < 0
        g.right_slope * f.left_slope
    end
    new_left_slope = if g.left_slope >= 0
        g.left_slope * f.left_slope
    else # g.left_slope < 0
        g.left_slope * f.right_slope
    end

    fcircg = PiecewiseLinearFunction(new_x, new_y, new_left_slope, new_right_slope)
    return postprocess_breakpoints ? remove_redundant_breakpoints(fcircg) : fcircg
end

function Base.:∘(f::PiecewiseLinearFunction, g::PiecewiseLinearFunction)
    return compose(f, g)
end

"""
$TYPEDSIGNATURES

Check if a piecewise linear function is convex.
"""
function is_convex(f::PiecewiseLinearFunction; eps=1e-12)
    slopes = compute_slopes(f)
    return all(diff(slopes) .>= -eps)
end

function compute_slope(x₁, y₁, x₂, y₂)
    return (y₂ - y₁) / (x₂ - x₁)
end

"""
$TYPEDSIGNATURES

Compute the convex meet of two piecewise linear functions, i.e. the tightest convex lower bound.
"""
function old_convex_meet(
    f::PiecewiseLinearFunction{T}, g::PiecewiseLinearFunction{T}
) where {T}
    return convex_lower_bound(min(f, g))
end

"""
$TYPEDSIGNATURES

Check if the sequence of points (p1, p2, p3) forms a convex sequence.
"""
function is_convex_sequence(f, i1, i2, i3)
    x₁, y₁ = f.x[i1], f.y[i1]
    x₂, y₂ = f.x[i2], f.y[i2]
    x₃, y₃ = f.x[i3], f.y[i3]

    cross = (x₂ - x₁) * (y₃ - y₁) - (y₂ - y₁) * (x₃ - x₁)
    return cross > 0
end

"""
$TYPEDSIGNATURES

Compute the tightest convex lower bound of a piecewise linear function, using a convex hull algorithm.
"""
function convex_lower_bound(f::PiecewiseLinearFunction{T}) where {T}
    n = length(f.x) # number of breakpoints
    hull = Int[]
    for i in 1:n
        while length(hull) >= 2 && !is_convex_sequence(f, hull[end - 1], hull[end], i)
            pop!(hull)
        end
        push!(hull, i)
    end
    # Second pass to remove points not compatible with left and right slopes
    h = PiecewiseLinearFunction(f.x[hull], f.y[hull], f.left_slope, f.right_slope)
    slopes = compute_slopes(h)
    imin = findfirst(x -> x > slopes[1], slopes)
    imax = findlast(x -> x < slopes[end], slopes)
    if isnothing(imin) || isnothing(imax)
        i = argmin(h.y)
        return PiecewiseLinearFunction([h.x[i]], [h.y[i]], h.left_slope, h.right_slope)
    end
    imin -= 1
    return PiecewiseLinearFunction(
        h.x[imin:imax], h.y[imin:imax], h.left_slope, h.right_slope
    )
end

"""
$TYPEDSIGNATURES

A faster version of `convex_meet` that only works on convex functions.
!!! warning
    This function does not check if the input functions are convex.
"""
function convex_meet(f::PiecewiseLinearFunction, g::PiecewiseLinearFunction)
    x = vcat(f.x, g.x)
    y = vcat(f.y, g.y)
    perm = sortperm(x)
    x = x[perm]
    y = y[perm]

    n = length(x)
    indices = trues(n)
    for i in 2:n
        if x[i] == x[i - 1]
            indices[i] = false
        end
    end
    for i in 2:n
        if !indices[i]
            value = min(y[i], y[i - 1])
            y[i] = value
            y[i - 1] = value
        end
    end
    x = x[indices]
    y = y[indices]

    h = PiecewiseLinearFunction(
        x, y, max(f.left_slope, g.left_slope), min(f.right_slope, g.right_slope)
    )
    res = convex_lower_bound(h)
    return res
end

export PiecewiseLinearFunction
export compute_slopes, compose, remove_redundant_breakpoints
export is_convex, convex_meet, convex_lower_bound

end

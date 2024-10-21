# # PiecewiseLinearFunctions.jl

# `PiecewiseLinearFunctions.jl` is a small package for creating and manipulating piecewise linear (continuous) functions

# One can instantiate a piecewise linear function by providing the x and y coordinates of the breakpoints, as well as the slopes of the function to the left of the first breakpoint and to the right of the last breakpoint.
using PiecewiseLinearFunctions
f = PiecewiseLinearFunction([0.0, 1.0, 2.0], [0.0, 2.0, 1.0], -1.0, 0.5)

# We can visualize it with Plots:
using Plots
g = PiecewiseLinearFunction([0.0, 1.5, 2.1], [1.0, 3.0, 0.5], 1.0, 3.0)
plot(f; label="f")
plot!(g; label="g")

# ## Basic operations

# We can perform basic operations on piecewise linear functions, such as addition, subtraction.
plot(-f; label="-f")
plot!(f + g; label="f + g")
plot!(f - g; label="f - g")
plot!(2f - 3; label="2f - 3")

# ## Min and max
# Minimum and maximum operations are also supported.
plot(min(f, g); label="min(f, g)")
plot!(max(f, g); label="max(f, g)")

# ## Composition
# We can also compose piecewise linear functions.
plot(f ∘ g; label="f ∘ g")

# ## Convexity
# We can check if a piecewise linear function is convex.
is_convex(f)
# And compute the convex meet between two convex functions, i.e. the tightest convex lower bound.
f = PiecewiseLinearFunction([-0.5, 0.0, 0.5], [0.5, 0.25, 0.5], -1.0, 1.0)
g = PiecewiseLinearFunction([0.0, 0.5, 1.0], [0.5, 0.4, 0.5], -0.5, 2.0)
#
is_convex(f), is_convex(g)
#
h = convex_meet(f, g)
plot(f; label="f")
plot!(g; label="g")
plot!(h; label="convex_meet(f, g)")

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

# We can perform basic operations on piecewise linear functions, such as addition, subtraction, and negation.
plot(-f; label="-f")
plot!(f + g; label="f + g")
plot!(f - g; label="f - g")

# ## Min and max
# Minimum and maximum operations are also supported.
plot(f; label="f")
plot!(g; label="g")
plot!(min(f, g); label="min(f, g)")
plot!(max(f, g); label="max(f, g)")

# ## Composition
# Finally, we can also compose piecewise linear functions.
plot(f ∘ g; label="h = f ∘ g")

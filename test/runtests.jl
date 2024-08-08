using PiecewiseLinearFunctions
using Test
using Aqua
using JET

@testset "PiecewiseLinearFunctions.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(PiecewiseLinearFunctions)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PiecewiseLinearFunctions; target_defined_modules = true)
    end
    # Write your tests here.
end

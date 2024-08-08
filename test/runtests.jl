using PiecewiseLinearFunctions
using Test
using Aqua
using Documenter
using JET
using JuliaFormatter

@testset "PiecewiseLinearFunctions.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            PiecewiseLinearFunctions; ambiguities=false, deps_compat=(check_extras = false)
        )
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(
            PiecewiseLinearFunctions; target_modules=[PiecewiseLinearFunctions]
        )
    end
    @testset "JuliaFormatter" begin
        @test JuliaFormatter.format(
            PiecewiseLinearFunctions; verbose=false, overwrite=false
        )
    end
    @testset "Documenter" begin
        Documenter.doctest(PiecewiseLinearFunctions)
    end
end

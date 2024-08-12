using PiecewiseLinearFunctions
using Test
using Aqua
using Documenter
using JET
using JuliaFormatter
using StableRNGs

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

    @testset "Basic operations" begin
        rng = StableRNG(67)

        nb_tests = 100
        for seed in 1:nb_tests
            rng = StableRNG(seed)
            r(n=50, m=10) = sort(rand(rng, n) .* m)
            X = -5:0.01:15
            f1 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f2 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)

            f4 = f1 - f2
            f5 = f1 + f2
            f6 = -f1

            @test all(f4.(X) .≈ [f1(x) - f2(x) for x in X])
            @test all(f5.(X) .≈ [f1(x) + f2(x) for x in X])
            @test all(f6.(X) .≈ [-f1(x) for x in X])
        end
    end

    @testset "Min and max" begin
        rng = StableRNG(67)

        nb_tests = 100
        for seed in 1:nb_tests
            rng = StableRNG(seed)
            r(n=50, m=10) = sort(rand(rng, n) .* m)
            X = -5:2:15
            f1 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f2 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f3 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)

            f7 = min(f1, f2)
            f7p = max(f1, f2)
            f8 = minimum([f1, f2, f3])

            @test all([f7(x) for x in X] .≈ [min(f1(x), f2(x)) for x in X])
            @test all([f8(x) for x in X] .≈ [min(f1(x), f2(x), f3(x)) for x in X])
            @test all([f7p(x) for x in X] .≈ [max(f1(x), f2(x)) for x in X])
        end
    end
end

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
            X = -15:0.01:15
            f1 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f2 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)

            f4 = f1 - f2
            f5 = f1 + f2
            f6 = -f1
            f7 = f1 * 10

            @test all(f4.(X) .≈ [f1(x) - f2(x) for x in X])
            @test all(f5.(X) .≈ [f1(x) + f2(x) for x in X])
            @test all(f6.(X) .≈ [-f1(x) for x in X])
            @test all(f7.(X) .≈ [10 * f1(x) for x in X])
        end
    end

    @testset "Min and max" begin
        rng = StableRNG(67)

        nb_tests = 100
        for seed in 1:nb_tests
            rng = StableRNG(seed)
            r(n=50, m=10) = sort(rand(rng, n) .* m)
            X = -15:2:15
            f1 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f2 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f3 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)

            f4 = min(f1, f2)
            f4p = max(f1, f2)
            f5 = minimum([f1, f2, f3])

            @test all([f4(x) for x in X] .≈ [min(f1(x), f2(x)) for x in X])
            @test all([f5(x) for x in X] .≈ [min(f1(x), f2(x), f3(x)) for x in X])
            @test all([f4p(x) for x in X] .≈ [max(f1(x), f2(x)) for x in X])
        end
    end

    @testset "Composition" begin
        rng = StableRNG(67)

        nb_tests = 100
        for seed in 1:nb_tests
            rng = StableRNG(seed)
            r(n=50, m=10) = sort(rand(rng, n) .* m)
            X = -15:2:15
            f1 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)
            f2 = PiecewiseLinearFunction(r(), r(), rand(rng) * 10 - 5, rand(rng) * 10 - 5)

            f = f1 ∘ f2

            @test all([f(x) for x in X] .≈ [f1(f2(x)) for x in X])
        end
    end

    @testset "Edge cases" begin
        f1 = PiecewiseLinearFunction([5.0, 9.0, 14.0], [1.0, 5.0, 20.0], 0.0, 2.0)
        f2 = PiecewiseLinearFunction([0.0], [0.0], 0.0, 2.0)

        computed_min = min(f1, f2)
        true_min = PiecewiseLinearFunction(
            [0.0, 0.5, 5.0, 9.0, 14.0], [0.0, 1.0, 1.0, 5.0, 20.0], 0.0, 2.0
        )
        @test all(computed_min.x .== true_min.x)
        @test all(computed_min.y .== true_min.y)
        @test all(computed_min.left_slope .== true_min.left_slope)
        @test all(computed_min.right_slope .== true_min.right_slope)

        f = PiecewiseLinearFunction([0.0, 1.0, 2.0], [1.0, 1.0, 1.0], 0.0, 1.0)
        @test remove_redundant_breakpoints(f) ==
            PiecewiseLinearFunction{Float64}([2.0], [1.0], 0.0, 1.0)
        @test compose(f, f; postprocess_breakpoints=false) ==
            PiecewiseLinearFunction([0.0, 1.0, 2.0, 3.0], [1.0, 1.0, 1.0, 1.0], 0.0, 1.0)
        f = PiecewiseLinearFunction([0.0], [0.0], 0.0, 0.0)
        @test remove_redundant_breakpoints(f) == f

        f = PiecewiseLinearFunction{Float64}(
            [
                7.624249546967501,
                11.568437399386351,
                11.568437399386355,
                19.13414562966562,
                67.6242495469675,
                79.13414562966562,
                171.96764602573944,
                172.6242495469675,
                184.1341456296656,
            ],
            [
                0.0,
                94.67541567566263,
                94.67541567566273,
                276.2810081028071,
                2652.6626406709174,
                4045.5775772676507,
                21965.25009748379,
                22091.994430357452,
                27387.37860640633,
            ],
            0.0,
            727.1143310992231,
        )
        g = PiecewiseLinearFunction{Float64}(
            [
                7.624249546967501,
                41.954942289256536,
                67.6242495469675,
                78.93810992854843,
                80.5458095491359,
                101.95494228925654,
                172.6242495469675,
                206.95494228925654,
            ],
            [
                0.0,
                824.0663800575257,
                2056.3871647988967,
                3414.2642165545385,
                3645.8094201138138,
                6236.719065086525,
                19878.032145878984,
                35672.63235722146,
            ],
            0.0,
            727.1143310992231,
        )
        @test PiecewiseLinearFunctions.search_intersection(f, g, 3, 1)[1] == false

        f = PiecewiseLinearFunction([1.0, 1.0], [1.0, 1.0], 0.0, 0.0)
        @test remove_redundant_breakpoints(f) ==
            PiecewiseLinearFunction([1.0], [1.0], 0.0, 0.0)

        h = PiecewiseLinearFunctions.PiecewiseLinearFunction{Float64}(
            [41.00004303958917, 80.9711826496009, 581.7160030371398],
            [-503.8664721869741, -500.7448203875389, 0.0],
            0.0,
            0.0,
        )
        @test convex_lower_bound(h) == PiecewiseLinearFunction{Float64}(
            [41.00004303958917], [-503.8664721869741], 0.0, 0.0
        )

        f = PiecewiseLinearFunctions.PiecewiseLinearFunction{Float64}(
            [0.0], [0.0], 0.0, 2.0
        )
        g = PiecewiseLinearFunctions.PiecewiseLinearFunction{Float64}(
            [0.0], [0.0], 0.0, 1.0
        )

        @test convex_meet(f, g) == PiecewiseLinearFunction{Float64}([0.0], [0.0], 0.0, 1.0)
        @test PiecewiseLinearFunctions.old_convex_meet(f, g) ==
            PiecewiseLinearFunction{Float64}([0.0], [0.0], 0.0, 1.0)
    end

    @testset "Convexity" begin
        f = PiecewiseLinearFunction([0.0, 1.0, 2.0, 3.0], [0.0, 0.0, 0.5, 1.5], 0.0, 1.0)
        @test is_convex(f) == true

        f = PiecewiseLinearFunction([0.0, 1.0, 2.0], [0.0, 1.0, 0.0], 0.0, -1.0)
        @test is_convex(f) == false

        f = PiecewiseLinearFunction([-0.5, 0.0, 0.5], [0.5, 0.25, 0.5], -1.0, 1.0)
        g = PiecewiseLinearFunction([0.0, 0.5, 1.0], [0.5, 0.4, 0.5], -0.5, 2.0)
        h = convex_meet(f, g)
        @test is_convex(f) && is_convex(g) && is_convex(h)

        h_min = min(f, g)
        X = -15:0.1:15
        @test all([h(x) <= h_min(x) for x in X])

        function random_convex_function(rng)
            random_slopes = sort(rand(rng, 10) * 10 .- 5)
            x = [0.0]
            y = [0.0]
            for slope in random_slopes[2:(end - 1)]
                push!(x, x[end] + 1.0)
                push!(y, y[end] + slope)
            end
            return PiecewiseLinearFunction(x, y, random_slopes[1], random_slopes[end])
        end

        nb_tests = 100
        for seed in 1:nb_tests
            rng = StableRNG(seed)
            f = random_convex_function(rng)
            g = random_convex_function(rng)
            @test is_convex(f) && is_convex(g)
            h = convex_meet(f, g)
            h2 = PiecewiseLinearFunctions.old_convex_meet(f, g)
            @test is_convex(h)
            fming = min(f, g)
            @test all([h(x) <= fming(x) for x in X])
            @test all([h(x) == h2(x) for x in X])
        end
    end
end

using ClimaReproducibilityTests: compute_mse, test_mse
using Test

@testset "compute_mse" begin
    dict_computed = Dict("A" => rand(3), "B" => rand(4), "C" => rand(5))
    dict_reference = Dict("A" => rand(3), "B" => rand(4), "C" => rand(5))

    computed_mse = compute_mse(;
        job_name = "MyTest",
        reference_keys = ["A", "B"],
        dict_computed,
        dict_reference,
    )
    for (var, reproducible) in test_mse(; computed_mse)
        @test !reproducible
    end

    dict_computed = Dict("A" => ones(3), "B" => ones(4), "C" => ones(5))
    dict_reference = Dict("A" => ones(3), "B" => ones(4), "C" => ones(5))

    computed_mse = compute_mse(;
        job_name = "MyTest",
        reference_keys = ["A", "B"],
        dict_computed,
        dict_reference,
    )
    for (var, reproducible) in test_mse(; computed_mse)
        @test reproducible
    end

end

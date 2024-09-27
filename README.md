# ClimaReproducibilityTests.jl

A package for enforcing reproducibility tests for CliMA repositories.

## Basic usage

The basic idea of this package, is that users can pass two `Dict`s of arrays
to `compute_mse`, and it will return the mean square error (MSE) per key in
the dictionaries.

We also provide a function, `test_mse(; computed_mse)`, to return a `Bool`
indicating whether the computed MSE is acceptable or not.

Here is an example:

```julia
using ClimaReproducibilityTests: compute_mse, test_mse
using Test

@testset "compute_mse" begin
	
	# Two dictionaries of arrays
    dict_computed = Dict("A" => rand(3), "B" => rand(4), "C" => rand(5))
    dict_reference = Dict("A" => rand(3), "B" => rand(4), "C" => rand(5))

    computed_mse = compute_mse(;
        job_name = "MyTest",
        reference_keys = ["A", "B"], # only compare these arrays
        dict_computed,
        dict_reference,
    )
    for (var, reproducible) in test_mse(; computed_mse)
        @test !reproducible # we don't expect that `dict_computed["A"] == dict_computed["B"]` for random arrays
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
        @test reproducible # we do expect that `dict_computed["A"] == dict_computed["B"]` for the same arrays
    end

end
```

module ClimaReproducibilityTests

import OrderedCollections
import PrettyTables

"""
    compute_mse(;
        job_name::String,
        reference_keys::Vector{String},
        dict_computed::AbstractDict,
        dict_reference::AbstractDict,
        compare_mse::Function = default_compare_mse,
    )

Returns a `Dict` with the keys `compare_keys` containing
mean-squared errors between `dict_computed` and `dict_reference`.
"""
function compute_mse(;
    job_name::String,
    reference_keys::Vector{String},
    dict_computed::AbstractDict,
    dict_reference::AbstractDict,
    is_reproducible::Function = default_is_reproducible,
)

    mse = OrderedCollections.OrderedDict()
    # Ensure z_tcc and fields are consistent lengths:
    n_keys = length(reference_keys)
    variables = map(x -> string(x), collect(reference_keys))
    computed_mse = zeros(n_keys)
    table_reference_mse = zeros(n_keys)
    mse_reductions = zeros(n_keys)
    data_scales_now = zeros(n_keys)
    data_scales_ref = zeros(n_keys)

    for (i, key) in enumerate(reference_keys)
        data_computed_arr = dict_computed[key]
        data_reference_arr = dict_reference[key]

        # Interpolate data
        # Compute data scale
        data_scale_now =
            sum(x -> abs(x), data_computed_arr) / length(data_computed_arr)
        data_scale_ref =
            sum(x -> abs(x), data_reference_arr) / length(data_reference_arr)
        data_scales_now[i] = data_scale_now
        data_scales_ref[i] = data_scale_ref

        # Compute mean squared error (mse)
        mse_single_var = sum((data_computed_arr .- data_reference_arr) .^ 2)
        computed_mse[i] = mse_single_var / data_scale_ref^2 # Normalize by data scale
        mse[key] = computed_mse[i]
    end

    # Tabulate output
    header = (
        ["Variable", "Data scale", "Data scale", "MSE"],
        ["", "Computed", "Reference", ""],
    )

    table_data = hcat(variables, data_scales_now, data_scales_ref, computed_mse)

    hl_worsened_mse = PrettyTables.Highlighter(
        (data, i, j) -> data[i, 4] > 0 && j == 4,
        PrettyTables.crayon"red bold",
    )
    @info "Regression tables for `$job_name`"
    PrettyTables.pretty_table(
        table_data;
        header,
        formatters = PrettyTables.ft_printf("%.16e", 4:5),
        header_crayon = PrettyTables.crayon"yellow bold",
        subheader_crayon = PrettyTables.crayon"green bold",
        highlighters = (hl_worsened_mse,),
        crop = :none,
    )

    return mse
end

default_is_reproducible(computed_mse::Real) =
    -sqrt(eps()) ≤ computed_mse ≤ sqrt(eps())

"""
    test_mse(;
        computed_mse::AbstractDict,
        is_reproducible::Function = default_is_reproducible,
    )

Returns a `Dict` with similar keys to `reference_mse`, containing
`Bool`s indicating that `compare_mse(computed_mse, reference_mse)`
passes for each key.
"""
function test_mse(;
    computed_mse::AbstractDict,
    is_reproducible::Function = default_is_reproducible,
)
    dict = Dict()
    for key in keys(computed_mse)
        dict[key] = default_is_reproducible(computed_mse[key])
    end
    return dict
end

end # module ClimaReproducibilityTests

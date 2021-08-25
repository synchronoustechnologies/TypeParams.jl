# TypeParams

This package provides the `@typeparams` macro which simplifies the definition of structs with many parametric types.

## Examples
```
julia> @macroexpand(
       @typeparams struct T
           a::{}
       end)
:(struct T{var"##a#1"}
      a::var"##a#1"
  end)

julia> @macroexpand(
       @typeparams struct T
           a::{<:Integer}
       end)
:(struct T{var"##a#1" <: Integer}
      a::var"##a#1"
  end)

julia> @macroexpand(
       @typeparams struct T
            a::{A}
       end)
:(struct T{A}
      a::A
  end)
```


## Acknowledgements

This package is heavily inspired by [AutoParameters.jl](https://github.com/pengwyn/AutoParameters.jl).
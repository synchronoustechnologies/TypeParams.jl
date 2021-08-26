# TypeParams

A key feature of Julia is that type annotations are not usually needed to achieve optimal performance.
For example, `foo(1,2)` runs equally fast regardless whether `foo()` is defined as `foo(a,b) = ...` or `foo(a::Int, b::Float64) = ...`.
Unfortunately, there is an important exception to this rule: writing
```julia
struct Foo
    a
    b
end
```
instead of
```julia
struct Foo
    a::Int
    b::Float64
end
```
will discard all compile-time type information on `a` and `b` and hence incur a significant performance penalty.
A common workaround to this problem is to introduce a new type parameter for each field:
```julia
struct Foo{A,B}
    a::A
    b::B
end
```
This recovers the flexibility of optional typing and preserves the performance of compile-time types, but keeping the fields and type parameters in sync can be quite laborious.

This package resolves this conflict by introducing a macro `@typeparams` which allows us to insert "generic" type parameters like the ones above using a simple syntax:
```julia
@typedef struct Foo
    a::{}
    b::{}
end
```
It further allows us to specify type constraints with zero overhead:
```julia
@typedef struct Foo
    a::{<:Integer}
    b::{<:Real}
end
```
Finally, `@typeparams` plays well with other features of the Julia language:
```julia
@typeparams struct MyVector{T} <: AbstractVector{T}
    data::{<:AbstractVector{T}}
end
Base.size(v::MyVector) = size(v.data)
Base.getindex(v::MyVector, i::Int) = v.data[i]

julia> MyVector([1,2,3])
3-element MyVector{Int64, Vector{Int64}}:
...
```

```julia
Base.@kwdef @typeparams struct Foo
    a::{} = 1
    b::{} = 1.0
end

julia> Foo()
Foo{Int64, Float64}(1, 1.0)
```

## Acknowledgements

This package is heavily inspired by [AutoParameters.jl](https://github.com/pengwyn/AutoParameters.jl).
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
This recovers the flexibility of optional typing and preserves the performance of compile-time types, but keeping the fields and type parameters in sync can be laborious.


## Usage

This package eliminates the fuss of generic type parameters by introducing a macro `@typeparams` which allows you to insert such type parameters using a simple syntax:
```julia
@typedef struct Foo
    a::{}
    b::{}
end
```
It further supports expressing type constraints with zero syntax overhead:
```julia
@typedef struct Foo
    a::{<:Integer}
    b::{<:Real}
end
```
Finally, `@typeparams` plays well with other features of the Julia language:

 - Explicit type parameters:
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

 - The `@kwdef` macro:
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
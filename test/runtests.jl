using TypeParams
using Test
using MacroTools: gensym_ids

@testset "@typeparams" begin
    @test @macroexpand(@typeparams struct T; end) == :(struct T{}; end)
    @test @macroexpand(@typeparams mutable struct T; end) == :(mutable struct T{}; end)
    @test @macroexpand(@typeparams struct T; a; end) == :(struct T{}; a; end)
    @test @macroexpand(@typeparams struct T; a::Int; end) == :(struct T{}; a::Int; end)
    @test @macroexpand(@typeparams struct T{A}; a::A; end) == :(struct T{A}; a::A; end)
    @test @macroexpand(@typeparams struct T; a; T(a) = new(a); end) == :(struct T{}; a; T(a) = new(a); end)

    @test @macroexpand(@typeparams struct T; a::{A}; end) == :(struct T{A}; a::A; end)
    @test @macroexpand(@typeparams struct T; a::{A<:Integer}; end) == :(struct T{A<:Integer}; a::A; end)
    @test @macroexpand(@typeparams struct T{A,B}; a::A; b::{B}; end) == :(struct T{A,B}; a::A; b::B; end)
    @test @macroexpand(@typeparams struct T; a1::{A}; a2::{A}; end) == :(struct T{A}; a1::A; a2::A; end)

    @test gensym_ids(@macroexpand(@typeparams struct T; a::{}; end)) == :(struct T{a_1}; a::a_1; end)
    @test gensym_ids(@macroexpand(@typeparams struct T; a::{<:Integer}; end)) == :(struct T{a_1<:Integer}; a::a_1; end)
    @test gensym_ids(@macroexpand(@typeparams struct T; a::{}; b::{}; end)) == :(struct T{a_1,b_2}; a::a_1; b::b_2; end)
end


Base.@kwdef @typeparams struct KWDef
    a::{} = 1
end
@testset "@kwdef interop" begin
    @test KWDef() == KWDef{Int}(1)
end

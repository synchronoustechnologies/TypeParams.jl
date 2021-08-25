module TypeParams

export @typeparams

"""
    @typeparams typedef

Automatically generate type parameters for fields of the form `fieldname::{...}`.

# Examples
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
"""
macro typeparams(typedef)
    typedef = macroexpand(__module__, typedef)
    @assert typedef isa Expr && typedef.head === :struct "@typeparams must be applied to a struct definition"
    typename = curly_typename!(typedef)
    paramnames = paramname.(typename.args[2:end])
    scan_typebody!(typedef.args[3],typename,paramnames)
    return esc(typedef)
end

"""
    curly_typename!(typedef)

Extract the type name and parameters from `typedef`.

# Examples
```jldoctest
julia> curly_typename!(:(struct Foo; end))
:(Foo{})
```
"""
function curly_typename!(typedef)
    typename_ref = Ref(typedef.args,2)
    if typename_ref[] isa Expr && typename_ref[].head === :<:
        typename_ref = Ref(typename_ref[].args,1)
    end
    if typename_ref[] isa Symbol
        typename_ref[] = Expr(:curly, typename_ref[])
    end
    return typename_ref[]
end

paramname(paramdef::Symbol) = paramdef
function paramname(paramdef::Expr)
    if paramdef.head === :<:
        @assert paramdef.args[1] isa Symbol "Invalid type parameter"
        return paramdef.args[1]
    end
    @assert false "Invalid type parameter"
end

function scan_typebody!(typebody, typename, paramnames)
    for item in typebody.args
        if !(item isa Expr); continue; end
        if item.head === :block
            scan_typebody!(item, typename)
            continue
        end
        if item.head === :(=)
            item = item.args[1]
        end
        if item.head === :(::)
            name = item.args[1]
            type = item.args[2]
            if type isa Expr && type.head === :braces
                if length(type.args) == 0
                    paramname = gensym(name)
                    paramdef = paramname
                elseif length(type.args) == 1
                    braces_content = type.args[1]
                    if braces_content isa Symbol
                        paramname = braces_content
                        paramdef = braces_content
                    elseif braces_content isa Expr && braces_content.head === :<:
                        if length(braces_content.args) == 1
                            paramname = gensym(name)
                            paramdef = :($paramname <: $(braces_content.args[1]))
                        elseif length(braces_content.args) == 2
                            paramname = braces_content.args[1]
                            paramdef = braces_content
                        else
                            @assert false "Invalid type parameter"
                        end
                    else
                        @assert false "Invalid type parameter"
                    end
                else
                    @assert false "Invalid type parameter"
                end
                item.args[2] = paramname
                if !(paramname in paramnames)
                    push!(typename.args, paramdef)
                    push!(paramnames, paramname)
                else
                    @assert paramdef isa Symbol "Type constraint on previously defined type parameter"
                end
            end
        end
    end
end

end # module

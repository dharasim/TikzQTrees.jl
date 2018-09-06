######################
### Abstract Trees ###
######################

"""
    AbstractTree{T}

abstract type for trees with values of type T

# Methods to implement
- `value(tree)`:
  Returns the value of the root of the tree
- `children(tree)`:
  Returns an iterator over the children of the root of the tree
"""
abstract type AbstractTree{T} end

"""
    value(tree)

Returns the value of the root of the tree
"""
function value(tree)
    tree.value
end

"""
    children(tree)

Returns an iterator over the children of the root of the tree
"""
function children(tree)
    tree.children
end

isleaf(tree) = isempty(children(tree))

function depth(tree)
    isleaf(tree) ? 1 : 1 + maximum(depth(c) for c in children(tree))
end

eltype(Tree::Type{<:AbstractTree{T}}) where T = Tree
IteratorSize(::Type{<:AbstractTree{T}}) where T = Base.SizeUnknown()

function iterate(tree::AbstractTree, state = [tree])
    if isempty(state)
        nothing
    else
        state[1], prepend!(state[2:end], children(state[1]))
    end
end

leafs(tree::AbstractTree) = [node for node in tree if isleaf(node)]

####################
### Simple Trees ###
####################

mutable struct SimpleTree{T} <: AbstractTree{T}
    value    :: T
    children :: Vector{SimpleTree{T}}
end

SimpleTree(value, T::Type=typeof(value)) = SimpleTree(value, SimpleTree{T}[])

# implement tree interface
value(tree::SimpleTree)    = tree.value
children(tree::SimpleTree) = tree.children

function map(f, tree::SimpleTree; uniform_type=true)
    node = if uniform_type
        SimpleTree(f(value(tree)))
    else
        SimpleTree(f(value(tree)), Any)
    end
    for child in children(tree)
        push!(children(node), map(f, child; uniform_type=uniform_type))
    end
    node
end

###################
### Tikz QTrees ###
###################

struct TikzQTree{T} <: AbstractTree{T}
    tree        :: T
    align_leafs :: Bool
    title       :: Union{String, Nothing}

    function TikzQTree(tree::T; align_leafs=false, title=nothing) where T
        new{T}(tree, align_leafs, title)
    end
end

# implement tree interface
value(t::TikzQTree)    = value(t.tree)
children(t::TikzQTree) = map(TikzQTree, children(t.tree))

function map(f, qtree::TikzQTree; uniform_type=true)
    TikzQTree(map(f, qtree.tree, uniform_type=uniform_type))
end

function show(io::IO, t::TikzQTree)
    if isleaf(t)
        print(io, value(t), ' ')
    else
        print(io, '[', '.', value(t), ' ')
        foreach(children(t)) do child
            print(io, child)
        end
        print(io, ']', ' ')
    end
end

# show TikzQTrees using TikzPictures.jl
showable(::MIME"image/svg+xml", ::TikzQTree) = true

function show(io::IO, ::MIME"image/svg+xml", t::TikzQTree)
    show(io, MIME"image/svg+xml"(), TikzPicture(t))
end

function TikzPicture(t::TikzQTree)
    title_node = if t.title != nothing
        # "\\node[align=center, font=\\bfseries, yshift=2em] (title) at (current bounding box.north) {$(t.title)};\n"
        "\\node[align=center, font=\\bfseries] (title) at (0,1) {$(t.title)};\n"
    else
        ""
    end

    if t.align_leafs
        d = depth(t) - 1
        TikzPicture(
            string(
                "\\tikzset{frontier/.style={distance from root=$d*30pt}}\n",
                title_node,
                "\\Tree ",
                t
            ),
            options = "level distance=30pt",
            preamble="\\usepackage{tikz-qtree}"
        )
    else
        TikzPicture(
            string(title_node, "\\Tree ", t),
            preamble="\\usepackage{tikz-qtree}"
        )
    end
end

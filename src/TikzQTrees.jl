module TikzQTrees

# from standard library
using Base.Iterators: drop

# from packages
using TikzPictures
using CSV
using LaTeXStrings

import TikzPictures: TikzPicture
import Base: show, showable, iterate, eltype, IteratorSize, map

export value, children, isleaf, leafs, depth
export SimpleTree, TikzQTree, qtree, @qtree
export plot_jazz_tree, read_jazz_tree

include("trees.jl")
include("qtree_from_expr.jl")
include("qtree_from_csv.jl")
include("qtree_from_string.jl")

end # module

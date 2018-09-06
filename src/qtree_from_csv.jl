################################
### matrix to tree functions ###
################################

function Base.length(table, i, j)
    ismissing(table[i, j]) && return 0
    l = 1
    while j+l <= size(table)[2] && ismissing(table[i, j+l])
        l += 1
    end
    l
end

function create_tree_node(table, i, j)
    @assert !ismissing(table[i, j])
    tree = SimpleTree(table[i, j])
    if i > 1
        for k in j:j+length(table,i,j)-1
            if !ismissing(table[i-1, k])
                push!(children(tree), create_tree_node(table, i-1, k))
            end
        end
    end
    tree
end

function trim_unary_chains!(tree)
    while length(children(tree)) == 1 &&
          value(tree) == value(first(children(tree)))
        tree.children = children(first(children(tree)))
    end
    for child in children(tree)
        trim_unary_chains!(child)
    end
    tree
end

function matrix_to_tree(table::Matrix)
    trim_unary_chains!(create_tree_node(table, size(table, 1), 1))
end

################################
### plot jazz tree functions ###
################################

function replace_all(string::AbstractString, replacements)
    for old_new in replacements
        string = replace(string, old_new)
    end
    string
end

function convert_jazz_notation(jazz_chord::Union{AbstractString,Missing})
    ismissing(jazz_chord) && return missing

    replacements = tuple(
        "^7"    => "^\\triangle",
        r"\^$"  => "",
        "7"     => "^7",
        "6"     => "^6",
        "%"     => "\\emptyset",
        "#"     => "\\sharp "
    )

    latexstring(replace_all(jazz_chord, replacements))
end

function plot_jazz_tree(csv_file::AbstractString)
    name = splitext(splitdir(csv_file)[2])[1]

    table = CSV.read(csv_file, delim=';', datarow=3) |>
        Matrix |>
        M -> M[:,1:findfirst(ismissing, M[2,:])-1] .|>
        convert_jazz_notation

    tree = matrix_to_tree(table)

    tp = TikzPicture(TikzQTree(tree, align_leafs=true, title=name))

    save(PDF(name), tp)
end

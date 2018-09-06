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

function qtree(table::AbstractMatrix; align_leafs=false, title=nothing)
    TikzQTree(
        trim_unary_chains!(create_tree_node(table, size(table, 1), 1)),
        align_leafs=align_leafs,
        title=title
    )
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

    latexstring(
        replace(
            replace_all(jazz_chord, replacements),
            r"_(\w+)" => s"_{\1}"
        )
    )
end

function read_jazz_tree(csv_file::AbstractString)
    title = splitext(splitdir(csv_file)[2])[1]
    table = Matrix(CSV.read(csv_file, delim=';', datarow=3))

    m = let k = findfirst(ismissing, table[:,1])
        k === nothing ? size(table, 1) : k-1
    end
    n = let k = findfirst(ismissing, table[2,:])
        k === nothing ? size(table, 2) : k-1
    end

    qtree(
        map(convert_jazz_notation, table[1:m, 1:n]),
        align_leafs=true,
        title=title
    )
end

function plot_jazz_tree(csv_file::AbstractString; format=:pdf)
    formats = (pdf=PDF, svg=SVG, tex=TEX, tikz=TIKZ)
    tree = read_jazz_tree(csv_file)
    save(getproperty(formats, format)(tree.title), TikzPicture(tree))
end


match(r"_(\w+)", "I_Bb")

replace("(I_Bb,V_Bb)", r"_(\w+)" => s"_{\1}")

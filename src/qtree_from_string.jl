function qtree(str; align_leafs=false, title=nothing)
    tree = tree_of_spans(bracket_spans(str))
    TikzQTree(_qtree(str, tree), align_leafs=align_leafs, title=title)
end

function _qtree(str, tree)
    i, j = value(tree)
    if isleaf(tree)
        m = match(r"\[\.(\w+) (.+)\]", str[i:j])
        preterminal = m[1]
        terminals = filter((!) ∘ isempty, split(m[2], ' '))
        SimpleTree(
            preterminal,
            [SimpleTree(t) for t in terminals]
        )
    else
        SimpleTree(
            match(r"\[\.(\w+) ", str[i:j])[1],
            [_qtree(str, child) for child in children(tree)]
        )
    end
end

function bracket_spans(
        str::AbstractString; open_bracket::Char='[', close_bracket::Char=']'
    )
    close_brackets = Int[]
    bracket_matches = Tuple{Int, Int}[]

    for i in length(str):-1:1
        if str[i] == close_bracket
            push!(close_brackets, i)
        elseif str[i] == open_bracket
            push!(bracket_matches, (i, pop!(close_brackets)))
        end
    end

    @assert isempty(close_brackets) "not a valid bracket expression"
    reverse(bracket_matches)
end

function tree_of_spans(spans)
    insert_spans!(SimpleTree(first(spans)), drop(spans, 1))
end

function insert_spans!(tree, spans)
    if isempty(spans)
        tree
    else
        insert_span!(tree, first(spans))
        insert_spans!(tree, drop(spans, 1))
    end
end

function insert_span!(tree, span)
    ⊏((a, b), (c, d)) = c < a && b < d
    i = findfirst(child -> span ⊏ value(child), children(tree))
    if i === nothing
        push!(children(tree), SimpleTree(span))
    else
        insert_span!(children(tree)[i], span)
    end
end

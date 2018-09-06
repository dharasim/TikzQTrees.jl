# construct TikzQTrees from Julia expressions using @qtree
latex_string(x...) = string('{', x..., '}')

_tree(x) = SimpleTree(latex_string(x))

_tree(n::LineNumberNode) = SimpleTree(latex_string("line", n.line))

function _tree(expr::Expr)
    if expr.head == :call
        head = expr.args[1] == :^ ? "\\textasciicircum" : expr.args[1]
        SimpleTree(latex_string(head), map(_tree, expr.args[2:end]))
    else
        SimpleTree(latex_string(expr.head), map(_tree, expr.args))
    end
end

macro qtree(expr)
    :( $(TikzQTree(_tree(expr))) )
end

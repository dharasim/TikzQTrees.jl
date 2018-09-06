using TikzQTrees
using Test
using CSV

qt = @qtree a*(b+c) == a*b + a*c
@test string(qt) == "[.{==} [.{*} {a} [.{+} {b} {c} ] ] [.{+} [.{*} {a} {b} ] [.{*} {a} {c} ] ] ] "

qt = @qtree α * (b + 3)
@test map(value, collect(qt)) == ["{*}", "{α}", "{+}", "{b}", "{3}"]
@test map(value, leafs(qt))   == ["{α}", "{b}", "{3}"]

qt = @qtree 1 * (2 + 3)
@test string(qt) == "[.{*} {1} [.{+} {2} {3} ] ] "
foo(x) = string(x, "bar")
@test string(map(foo, qt; uniform_type=false)) ==
    "[.{*}bar {1}bar [.{+}bar {2}bar {3}bar ] ] "

qt = @qtree function foo(a)
    d = (a - 2)^2
    e = 2.71
end
@test string(qt) == "[.{function} [.{foo} {a} ] [.{block} {line19} [.{=} {d} [.{\\textasciicircum} [.{-} {a} {2} ] {2} ] ] {line20} [.{=} {e} {2.71} ] ] ] "

@test plot_jazz_tree(joinpath(@__DIR__(), "allofme.csv")) isa Nothing

@test begin
    TikzQTree(
        qtree(Matrix(CSV.read(joinpath(@__DIR__(), "example_phrase.csv"), delim=';', datarow=1))),
        align_leafs = true,
        title = "Example phrase"
    )

    true
end

str = "[.DP [.D the ] [.NP [.N pictures ] [.PP [.P of ] [.NP Mary ] ] ] ] "
@test string(qtree(str)) == str

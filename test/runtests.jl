using TikzQTrees
using Test

qt = @qtree a*(b+c) == a*b + a*c
@test string(qt) == "[.== [.* a [.+ b c ]][.+ [.* a b ][.* a c ]]]"

qt = @qtree α * (b + 3)
@test map(value, collect(qt)) == [:*, :α, :+, :b, 3]
@test map(value, leafs(qt))   == [:α, :b, 3]

qt = @qtree 1 * (2 + 3)
@test string(qt) == "[.* 1 [.+ 2 3 ]]"
foo(x) = x isa Number ? x + 1 : x
@test string(map(foo, qt; uniform_type=false)) == "[.* 2 [.+ 3 4 ]]"

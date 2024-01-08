# parser for relaxed version of json to be used as input for mustache.bqn
# converts json into [parents,types,refs]‿names object
# - keys and values do not need quotes
# - all values are strings
# - trailing commas are allowed

⟨Parent, Delete⟩ ← •Import "helpers.bqn" 

ex←"
{
  foo: {
    bar: [{x: 1, y: 2}, {x:3, y:3}],
    baz: {w: 8, z: 9}
  }
}
"

type ← { 
  none⇐0 ⋄ str⇐1 ⋄ key⇐2 ⋄ val⇐3 ⋄ col⇐4 ⋄  com⇐5
  obj⇐curly_opn⇐6 ⋄ arr⇐sqr_opn⇐7 ⋄ curly_cls⇐8 ⋄ sqr_cls⇐9
}

# TODO validation with line/col numbers
{
   # t: typepes, r:references, n: names
   ch ← 𝕩 ⋄ t ← @ ⋄ r←@ ⋄ n ← @ ⋄ p ← @
   # remove whitespace TODO keep line and column numbers 
   { ch (¬ch∊(@+10)‿' ')⊸/↩ }
   # tokenize: types. 
   { t↩∨´type.curly_opn‿type.curly_cls‿type.sqr_opn‿type.sqr_cls‿type.col‿type.com ×ch⊸=¨"{}[]:," 
     t↩t∨(type.str×ch∊∾"0aA"+⟜↕¨10‿26‿26) }
   # tokenize: strings into reference and name vectors
   { m←t=type.str ⋄ f← »⊸< m ⋄ i←m×+`f ⋄ z ←f∨t≠type.str ⋄ n ↩ ⊏⟜ch¨⊔1-˜i ⋄ ch z⊸/↩ ⋄ t z⊸/↩ ⋄ r ↩ 1-˜z/f×i }
   # parse parents of brackets (ch no longer needed after tokenizing processes)
   { o←(t=type.curly_opn)∨t=type.sqr_opn ⋄ c←(t=type.curly_cls)∨t=type.sqr_cls ⋄ p↩ Parent +`o-c }
   # parse keys
   { m←t=type.col ⋄ s←t=type.str ⋄ t↩(¬m)/type.key¨⌾((s∧«m)⊸/)t ⋄ r (¬m)⊸/↩ ⋄ p↩(¬m) Delete p }
   # remove unneeded nodes - closing backets and commas
   { m←(t≠type.curly_cls)∧(t≠type.sqr_cls)∧(t≠type.com) ⋄ t m⊸/↩ ⋄ r m⊸/↩ ⋄ p↩m Delete p }
   # move object values parent to keys   
   { m←»t=type.key ⋄ p (m/»↕≠p)⌾(m⊸/) ↩ }
   •Show [p, t, r]
   •Show n
} ex

# parser for relaxed version of json to be used as input for mustache.bqn
# - keys and values do not need quotes
# - all values are strings
# - trailing commas are allowed

Parent ← { g←⊔¯1⌽𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 } # delete from parent vector
#Parent ← { (↕≠𝕩) ⋄ •Show ¯1⌽𝕩 }
ex←"
{
  foo: {
    bar: [{x: 1, y: 2}, {x:3, y:3}],
    baz: {w: 8, z: 9}
  }
}
"
type ← { 
  none⇐0 ⋄ str⇐1 ⋄ key⇐2 ⋄ val⇐3 ⋄ col⇐4 ⋄ curly⇐5 ⋄ angle⇐6 ⋄ com⇐7
}

{
   # t: typepes, r:references, n: names
   ch ← 𝕩 ⋄ t ← @ ⋄ r←@ ⋄ n ← @, p ← @
   # remove whitespace
   { ch (¬ch∊(@+10)‿' ')⊸/↩ }
   # tokenize typepes
   { t↩∨´⟨type.str×ch∊∾"0aA"+⟜↕¨10‿26‿26,type.curly×ch∊"{}", type.angle×ch∊"[]", type.col×ch=':',type.com×ch=','⟩}
   # tokenize strings into reference and name vectors
   { m←t=type.str ⋄ f← »⊸< m ⋄ i←m×+`f ⋄ z ←f∨t≠type.str ⋄ n ↩ ⊏⟜ch¨⊔1-˜i ⋄ ch z⊸/↩ ⋄ t z⊸/↩ ⋄ r ↩ 1-˜z/f×i }
   # tokenize keys
   { col←(t=type.col) ⋄ str←(t=type.str) ⋄ m ← str∧«col ⋄ z←¬col ⋄ t↩z/type.key¨⌾(m⊸/)t ⋄ ch z⊸/↩ ⋄ r z⊸/↩ }
   # TODO remove commas now that we have typeped nodes
   [ch,t,r]

   # init parent
   #{ p↩↕≠t }

   # TODO parent: arrays
   # TODO parent: brackets
  
} ex

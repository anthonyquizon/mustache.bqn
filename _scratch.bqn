•Show "---"
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
mustache ← •Import "mustache.bqn" 

a ← {
  peach⇐⟨
    {foo⇐333, bar⇐⟨{baz⇐444}, {baz⇐555}⟩}
  ⟩,
  each⇐⟨
    {foo⇐111, bar⇐222}
  ⟩,
  bleach⇐⟨
    {foo⇐111, bar⇐222}
  ⟩,
}

#mustache.ParseNs a
tpl ← mustache.Parse (•file.Chars "test.mustache")
tpl mustache.Compile a


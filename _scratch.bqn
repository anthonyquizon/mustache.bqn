•Show "---"
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
mustache ← •Import "mustache.bqn" 

a ← {
  peach⇐⟨
    {fig⇐333, apple⇐⟨
      {banana⇐444, cheese⇐"hello"}, 
      {banana⇐555, cheese⇐"weee"}
    ⟩}
  ⟩,
  each⇐⟨
    {lemon⇐111, mango⇐222}
  ⟩,
  grape⇐⟨
    {lemon⇐111, mango⇐222}
  ⟩,
}


#mustache.ParseNs a
tpl ← mustache.Parse (•file.Chars "test.mustache")
tpl mustache.Compile a


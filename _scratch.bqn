•Show "---"
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
mustache ← •Import "mustache.bqn" 

a ← {
  peach⇐⟨
    {fig⇐1, apple⇐⟨
      {cheese⇐"hello", banana⇐2, apple⇐"apple value"}, 
      {banana⇐3, cheese⇐"weee", apple⇐"also apple value"}
    ⟩}
  ⟩,
  fig⇐⟨
    {fig⇐1, apple⇐⟨
      {cheese⇐"fig cheese", banana⇐3}, 
      {banana⇐4, cheese⇐"also fig cheese"}
    ⟩}
  ⟩,
  each⇐⟨
    {banana⇐1, mango⇐2},
    {banana⇐1, mango⇐2},
    {banana⇐1, mango⇐2}
  ⟩,
  grape⇐⟨
    {lemon⇐3, mango⇐4}
  ⟩,
}

#⟨[p,t,r]⇐ptr,n⇐n⟩←mustache.ParseNs a

#(∾1↑¨t) Draw p
#tpl ← mustache.Parse (•file.Chars "test0.mustache")
tpl ← mustache.Parse (•file.Chars "test1.mustache")
[p,t,r] ← tpl.ptr
tpl mustache.Compile a


•Show "---"
# delete leaf nodes - match to parent tree

⟨Draw⟩ ← •Import "tree.bqn" 
Parent ⇐ { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }
mustache ← •Import "mustache.bqn" 

a ← {
  #peach⇐⟨
    #{fig⇐1, apple⇐⟨
      #{cheese⇐"hello", banana⇐2, apple⇐"apple value"}, 
      #{banana⇐3, cheese⇐"weee", apple⇐"also apple value"}
    #⟩}
  #⟩,
  #fig⇐⟨
    #{fig⇐1, apple⇐⟨
      #{cheese⇐"fig cheese", banana⇐3}, 
      #{banana⇐4, cheese⇐"also fig cheese"}
    #⟩}
  #⟩,
  each0⇐⟨{
    each1⇐⟨{
      each2⇐⟨
        {fig⇐0⋄banana⇐2},
        {fig⇐1⋄banana⇐3},
      ⟩
    }⟩
  },{
    each1⇐⟨{
      each2⇐⟨
        {fig⇐"a"⋄banana⇐"x"},
        {fig⇐"b"⋄banana⇐"y"},
        {fig⇐"c"⋄banana⇐"z"}
      ⟩
    }⟩
  }⟩,
  lemon⇐"hello lemon",
  grape⇐⟨
    {lemon⇐3, mango⇐4}
  ⟩,
}

#{
  #⟨[p,t,r]⇐ptr,n⇐n⟩←mustache.ParseNs a
  #(∾1↑¨r⊏n) Draw p 
#}
tpl ← mustache.Parse (•file.Chars "test0.mustache")
#tpl ← mustache.Parse (•file.Chars "test1.mustache")
#tpl ← mustache.Parse (•file.Chars "test2.mustache")
[p,t,r] ← tpl.ptr
tpl mustache.Compile a


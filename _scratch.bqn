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
  each0⇐⟨{
    each1⇐⟨{
      each2⇐⟨
        {fig⇐"fig value"⋄banana⇐"banana value",cat⇐"cat value"},
        {fig⇐"another fig value"⋄banana⇐"another banana value",cat⇐"another cat value"},
      ⟩
    }⟩
  },{
    each1⇐⟨{
      each2⇐⟨
        {fig⇐"a"⋄banana⇐"x", cat⇐"p"},
        {fig⇐"b"⋄banana⇐"y", cat⇐"q"},
        {fig⇐"c"⋄banana⇐"z", cat⇐"r"}
      ⟩
    }⟩
  }⟩,
  lemon⇐"hello lemon",
  grape⇐⟨
    {mango⇐"mango value" ⋄ lemon⇐"lemon value"}
  ⟩,
}

#{
  #⟨[p,t,r]⇐ptr,n⇐n⟩←mustache.ParseNs a
  #(∾1↑¨r⊏n) Draw p 
#}
tpl ← mustache.Parse (•file.Chars "test0.mustache")
#tpl ← mustache.Parse (•file.Chars "test1.mustache")
#tpl ← mustache.Parse (•file.Chars "test2.mustache")

#•Show •Type a
#[p,t,r] ← tpl.ptr
tpl mustache.Compile a
#"test0.mustache" mustache.Compile a


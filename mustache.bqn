# Reference: http://mustache.github.io/mustache.5.html
#            https://juuso.dev/blogPosts/barbell/barbell.html
opn‿cls ← "{{"‿"}}"

L←•Show

# types
types ← {
  b ⇐ 1 # base node
  s ⇐ 2 # start node
  e ⇐ 3 # end node
}

nested ← {
  Depth ⇐ {
        𝕊 𝕩 : 0 𝕊 𝕩
    ; 𝕨 𝕊 ⟨⟩ : ⟨𝕨⟩ 
    ; 𝕨 𝕊 𝕩 : 1=≡𝕩 ? 𝕨
    ; 𝕨 𝕊 𝕩 : ∾𝕨 𝕊 { 𝕨∾(𝕨+1)𝔽⊑1↓𝕩 }¨𝕩
  }

  Flatten ⇐ {
      𝕊 ⟨⟩ : ⟨⟨⟩⟩
    ; 𝕊 𝕩  : 3=≡𝕩 ? ∾ 𝕩
    ; 𝕊 𝕩  : ∾ 𝕊 { h‿t ← 𝕩 ⋄ ⟨h⟩ ∾ 𝔽 t }¨𝕩
  }
}

Delete ← { (/𝕨)(⊢-⍋)(¬𝕨)/𝕩 }
Parent ← { g←⊔𝕩 ⋄ (↕≠𝕩) {a‿w←𝕨 ⋄ (⊏⟜a 1-˜a⍋w)⌾(w⊸⊏) 𝕩 }´ (1↓(»g){𝕨‿𝕩}¨g) }

Depth ← { p ← 𝕩 
  L ↕≠p
}

Compile ← {
  # rp: replace parent, rv: replace values, r: references, t: types, p: parent, ch: characters, n: names
  rp‿rv ← 𝕨 ⋄ rn ← (≠rp)⥊¯1 ⋄ ch ← •file.Chars 𝕩 ⋄ r ← (≠ch)⥊¯1 ⋄ t ← p ← (≠ch)⥊0 ⋄ n ← @

  Print ← { 𝕊: •Show [rp, rv, rn] ⋄ •Show [p, t, r] ⋄ •Show n }

  # get open and close enclose bits
  o‿c ← {∨⟜»⍟(1-˜≠𝕩)(≠ch)↑𝕩⍷ch}¨opn‿cls

  # pass: mark names in types
  { t ↩ +`(»>⟜«o)+-(»⊸<c) }

  # pass: remove brackets
  { d ← (¬o∨c) ⋄ ch d⊸/ ↩ ⋄ p d⊸/ ↩ ⋄ t d⊸/ ↩ ⋄ r d⊸/ ↩ }

  # pass: names to '$' nodes with types and references to original names
  {
    i ← (0⊸≠≠¨)⊸/⊔(⊢-˜¬×+`)¬t=types.b

    nm ← (¬∊⟜"#/")⊸/¨ ⊏⟜ch¨i # names: extracted node strings
    b ← (≠ch)↑(/⁼0⊑¨i) # base nodes - start of nodes
    s ← types.s×b∧ch='#' # start nodes
    e ← types.e×b∧ch='/' # end nodes
    d ← (t=types.b)×¬b

    rn ↩ ¯1¨⌾(((≠nm)=nm⊐rv)⊸/) nm⊐rv
    n  ↩ (≍⟜⊐) nm
    r  ↩ (¬d)/(⊐nm)⌾(b⊸/) r
    p  ↩ d Delete p
    t  ↩ (¬d)/⌈´b‿s‿e
    ch ↩ (¬d)/'$'¨⌾(b⊸/) ch
  }

  # pass: construct parents from start/end nodes
  { p ↩ +`(»>⟜«(t=types.s))+-(»⊸<(t=types.e)) }

  Print @
  # pass: expand loops to flatten structure
  {
    # get depth of value tree
    # get depth of template tree

    L

    # bind variables to 
    #L (¯1≠rn)/rp
    #L (¯1≠rn)/rn
    #L (types.s=(p⊏t))
    #L (types.s=(p⊏t))∧(t=types.b)
    #o ← t=types.s ⋄ c ← t=types.e
    # delete parent node
  }

}

•Show "--"



json ← •Import "./json.bqn"

data ←  ⟨
  ⟨"points", ⟨
      ⟨"cx", "10"⟩, ⟨"cy", "1"⟩
      ⟨"cx", "10"⟩, ⟨"cy", "1"⟩
  ⟩⟩,
⟩

#•Show (Flatten data)
#•Show (Depth ⟨⟩)
#•Show (Depth data)≍(Flatten data)
#•Show Parent 0‿1‿2‿1‿2‿3‿2‿1‿2‿3‿3‿2‿3‿3‿2
p ← (Parent (nested.Depth data))
v ← (nested.Flatten data)
#L Depth p

#d ← [0,       1,         1,    2,    3,    2,    3]
#v ← ⟨"points","foo", "bar", "cx", "10", "cy", "12"⟩

#d ← ∨´(↕≠p)⊸=¨1‿2
## (⍸M)(⊢-1+⍸)(~M)⌿P
#L (¬d)
#L (/d)
#L (¬d)/p 
###L (/d)(⊢-1+/)(¬d)/p 


#L x ← 0‿0‿1‿0‿3‿0‿5
##L v
##L p
#L ((¬d)/v)≍x
#L ((¬d)/p)-x

#L (/d)(⊢-1+/)(¬d)/p


#{

#L p←0‿0‿1‿2‿20‿4‿4‿6‿7‿20‿9‿10‿10‿10‿9‿14‿15‿20‿17‿18‿2
#L t←3‿2‿1‿10‿4‿10‿2‿0‿7‿4‿2‿10‿9‿10‿2‿0‿7‿2‿0‿7‿3
#L (p⊏t)=4


#}

{
  p ← 0‿0‿0‿3‿3‿3
  c ← "abcdef"
  L [p,c]

   
}



#p‿v Compile "./test.mustache"

•Show "done"
